#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "UIKit/UIKit.h"
#import <AudioToolbox/AudioToolbox.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBScreenFlash.h>
#import <SpringBoard/SBApplication.h>
#import <dlfcn.h>
#import <MobileCoreServices/MobileCoreServices.h> // For the UTI types constants
#import "MLIMGURUploader.h"
#import <dlfcn.h>
#import <substrate.h>

@interface SBScreenFlash (iOS8)
+ (id)mainScreenFlasher;
- (void)flashColor:(id)arg1 withCompletion:(id)arg2;
@end

// For ScreenCrop
@interface DragWindow : UIWindow
@end

@interface SBScreenShotter
+(id)sharedInstance;
-(void)saveScreenshot:(BOOL)screenshot;
-(void)finishedWritingScreenshot:(id)screenshot didFinishSavingWithError:(id)error context:(void*)context;
@end

@interface UIRemoteApplication
-(void)didTakeScreenshot;
@end

@interface SBApplication (Almpoum)
-(UIRemoteApplication*)remoteApplication;
- (BOOL)statusBarHidden; // iOS 7-
- (_Bool)statusBarHiddenForCurrentOrientation; // iOS 8
@end

@interface BBBulletinRequest : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *sectionID;
@end

@interface SBBulletinBannerController : NSObject
+ (SBBulletinBannerController *)sharedInstance;
- (void)observer:(id)observer addBulletin:(BBBulletinRequest *)bulletin forFeed:(int)feed;
@end

extern "C" UIImage *_UICreateScreenUIImageWithRotation(BOOL rotate);
extern "C" UIImage* _UICreateScreenUIImage();

#define kPhotoShutterSystemSound 0x454
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.efrederickson.almpoum.settings.plist"
#define SETTINGS_EVENT "com.efrederickson.almpoum/reloadSettings"
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IMGUR_CLIENT_ID @"4fb524843c272ea"
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

BOOL enabled = YES;
NSString *albumName = @"Screenshots";
BOOL saveToCustomAlbum = YES;
BOOL showCameraFlash = YES;
BOOL darkenCameraFlash = NO;
BOOL playShutterSound = YES;
BOOL notifyApps = NO;
BOOL copyToClipboard = NO;
BOOL copyToPictures = NO;
int saveMode = 1;
BOOL uploadToPhotoStreams = YES;
BOOL hideStatusBar = NO;
BOOL alwaysSaveToImgur = NO;

static UIImage *screenshot;

static dispatch_queue_t queue = dispatch_queue_create("openActivityViewControllerQueue", NULL);

static UIWindow *window = nil;


static void reloadSettings(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    NSDictionary *prefs = [NSDictionary
        dictionaryWithContentsOfFile:SETTINGS_FILE];
    
    if ([prefs objectForKey:@"enabled"] != nil)
        enabled = [[prefs objectForKey:@"enabled"] boolValue];
    else
        enabled = YES;
 
    if ([prefs objectForKey:@"albumName"] != nil)
        albumName = [prefs objectForKey:@"albumName"];
    else
        albumName = @"Screenshots";

    if ([prefs objectForKey:@"saveToCustomAlbum"] != nil)
        saveToCustomAlbum = [[prefs objectForKey:@"saveToCustomAlbum"] boolValue];
    else
        saveToCustomAlbum = YES;
        
    if ([prefs objectForKey:@"showCameraFlash"] != nil)
        showCameraFlash = [[prefs objectForKey:@"showCameraFlash"] boolValue];
    else
        showCameraFlash = YES;
        
    if ([prefs objectForKey:@"darkenCameraFlash"] != nil)
        darkenCameraFlash = [[prefs objectForKey:@"darkenCameraFlash"] boolValue];
    else
        darkenCameraFlash = NO;
        
    if ([prefs objectForKey:@"playShutterSound"] != nil)
        playShutterSound = [[prefs objectForKey:@"playShutterSound"] boolValue];
    else
        playShutterSound = YES;
        
    if ([prefs objectForKey:@"notifyApps"] != nil)
        notifyApps = [[prefs objectForKey:@"notifyApps"] boolValue];
    else
        notifyApps = NO;
        
    if ([prefs objectForKey:@"copyToClipboard"] != nil)
        copyToClipboard = [[prefs objectForKey:@"copyToClipboard"] boolValue];
    else
        copyToClipboard = NO;

    if ([prefs objectForKey:@"copyToPictures"] != nil)
        copyToPictures = [[prefs objectForKey:@"copyToPictures"] boolValue];
    else
        copyToPictures = NO;
        
    if ([prefs objectForKey:@"saveMode"] != nil)
        saveMode = [[prefs objectForKey:@"saveMode"] intValue];
    else
        saveMode = 1;

    if ([prefs objectForKey:@"uploadToPhotoStreams"] != nil)
        uploadToPhotoStreams = [[prefs objectForKey:@"uploadToPhotoStreams"] boolValue];
    else
        uploadToPhotoStreams = YES;

    if ([prefs objectForKey:@"hideStatusBar"] != nil)
        hideStatusBar = [[prefs objectForKey:@"hideStatusBar"] boolValue];
    else
        hideStatusBar = NO;

    if ([prefs objectForKey:@"alwaysSaveToImgur"] != nil)
        alwaysSaveToImgur = [[prefs objectForKey:@"alwaysSaveToImgur"] boolValue];
    else
        alwaysSaveToImgur = NO;
}

static void saveScreenshot(UIImage *screenshot)
{
    if (saveToCustomAlbum)
    {
        ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];

        void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
            NSLog(@"Almpoum: saved to album: %@", [assetURL absoluteString]);
        };
        
        void (^failure)(NSError *) = ^(NSError *error) {
            if (error == nil) return;
            NSLog(@"Almpoum: failed to save to album: %@", [error description]);
        };

        [al saveImage:screenshot
            toAlbum:albumName
            completion:completion
            failure:failure];
    }
    else
    {
        UIImageWriteToSavedPhotosAlbum(screenshot, [%c(SBScreenShotter) sharedInstance], @selector(finishedWritingScreenshot:didFinishSavingWithError:context:), NULL);
    }
}

void showBanner()
{
    Class bulletinBannerController = objc_getClass("SBBulletinBannerController");
	Class bulletinRequest = objc_getClass("BBBulletinRequest");
    
	if (bulletinBannerController && bulletinRequest) {
		BBBulletinRequest *request = [[bulletinRequest alloc] init];
		request.title = @"Almpoum";
		request.message = @"The screenshot has been uploaded & the link has been copied to your clipboard.";
		request.sectionID = @"com.apple.camera";
		[(SBBulletinBannerController *)[bulletinBannerController sharedInstance] observer:nil addBulletin:request forFeed:2];
		return;
	}
}

%hook SBScreenFlash
// iOS 7.X
-(void) flashColor:(UIColor*)color
{
    if (darkenCameraFlash && enabled)
        %orig([UIColor blackColor]);
    else
        %orig;
}

// iOS 8.X
- (void)flashColor:(id)arg1 withCompletion:(id)arg2
{
    if (darkenCameraFlash && enabled)
        %orig([UIColor blackColor], arg2);
    else
        %orig;
}
%end

%hook SBScreenShotter // <UIAlertViewDelegate>
-(void)saveScreenshot:(BOOL)arg1 
{
    if (!enabled)
    {
        %orig;
        return;
    }

    screenshot = _UICreateScreenUIImageWithRotation(TRUE);
    //screenshot = _UICreateScreenUIImage();
    
    BOOL statusBarHidden = YES;

    if ([[(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication] respondsToSelector:@selector(statusBarHidden)])
   		statusBarHidden = [[(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication] statusBarHidden];
   	else
   		statusBarHidden = [[(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication] statusBarHiddenForCurrentOrientation];

    if(statusBarHidden == NO && hideStatusBar)
    {
        CGRect newSSFrame = CGRectMake(0, 20 * UIScreen.mainScreen.scale, screenshot.size.width * UIScreen.mainScreen.scale, (screenshot.size.height - 20) * UIScreen.mainScreen.scale);
            
        CGImageRef imageRef = CGImageCreateWithImageInRect(screenshot.CGImage, newSSFrame);
        screenshot = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    
    id dragWindow = %c(DragWindow);
    if (dragWindow)
    {
        DragWindow *window = [[%c(DragWindow) alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] frame]];
        [window makeKeyAndVisible];
    }

    id dragView = %c(DragView);
    if (dragView)
    {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.windowLevel = UIWindowLevelStatusBar;
        window.userInteractionEnabled = YES;
        [window makeKeyAndVisible];

        id drawView = [[%c(DragView) alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

        [window addSubview:drawView];
        return;
    }

	if (screenshot) {

        if (saveMode == 1) // Prompt
        { 
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Almpoum" message:@"What would you like to happen to that Screenshot?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
           [alert addButtonWithTitle:@"Save to Photo Library"];
           [alert addButtonWithTitle:@"Copy to the Clipboard"];
           [alert addButtonWithTitle:@"Upload to Imgur"];
           [alert addButtonWithTitle:@"Share..."];
           [alert show];
        }
        if (saveMode == 2 || copyToPictures) // Photo library
        { 
            saveScreenshot(screenshot);
        }
        if (saveMode == 3 || copyToClipboard) // pasteboard
        {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setData:UIImagePNGRepresentation(screenshot) forPasteboardType:(__bridge NSString *)kUTTypePNG];
        }
        if (saveMode == 4) // Both
        { 
            if (!copyToClipboard)
            {
                UIPasteboard *pb = [UIPasteboard generalPasteboard];
                [pb setData:UIImagePNGRepresentation(screenshot) forPasteboardType:(__bridge NSString *)kUTTypePNG];
            }
            
            if (!copyToPictures)
                saveScreenshot(screenshot);
        }
        if (saveMode == 5 || alwaysSaveToImgur) // IMGUR
        {
            [MLIMGURUploader uploadPhoto:UIImagePNGRepresentation(screenshot)
                title:@"Almpoum Screenshot"
                description:@""
                imgurClientID:IMGUR_CLIENT_ID
                completionBlock:^(NSString *result)
                {
                    if (result)
                    {
                        [[UIPasteboard generalPasteboard] setString:result];
                        showBanner();
                    }
                }
                failureBlock:^(NSURLResponse *a, NSError *b, NSInteger c){ }];
        }
        if (saveMode == 6)
        {
            if (window == nil) 
                window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    		window.windowLevel = 666666;


	        UIViewController *vc = [[UIViewController alloc] init];
		    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[screenshot] applicationActivities:nil];
            [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
                //[window resignKeyWindow];
                window.rootViewController = nil;
                window.hidden = YES;
                window = nil;
            }];

	    	window.rootViewController = vc;
	 		[window makeKeyAndVisible];
            [vc presentViewController:activityVC animated:YES completion:nil];
        }

        if (notifyApps && IS_OS_7_OR_LATER)
        {
            SBApplication *frontMostApplication = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
            [frontMostApplication.remoteApplication didTakeScreenshot];
        }

        if (showCameraFlash)
        {
        	if ([%c(SBScreenFlash) respondsToSelector:@selector(sharedInstance)])
	            [[%c(SBScreenFlash) sharedInstance] flash];
	        else
	            [[%c(SBScreenFlash) mainScreenFlasher] flashColor:UIColor.whiteColor withCompletion:nil];
        }
        if (playShutterSound)
            AudioServicesPlaySystemSound(kPhotoShutterSystemSound);

        //[[%c(SBScreenShotter) sharedInstance] finishedWritingScreenshot:nil didFinishSavingWithError:nil context:nil];
	} else {
		NSLog(@"Almpoum: _UICreateScreenUIImage[WithRotation] failed");
	}
}

%new
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if (buttonIndex == 1) 
    {
        // Photo library
        saveScreenshot(screenshot);
    }
    else if (buttonIndex == 2) 
    {
        // pasteboard
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setData:UIImagePNGRepresentation(screenshot) forPasteboardType:(__bridge NSString *)kUTTypePNG];
    }
    else if (buttonIndex == 3)
    { // IMGUR
        [MLIMGURUploader uploadPhoto:UIImagePNGRepresentation(screenshot)
            title:@"Almpoum Screenshot"
            description:@""
            imgurClientID:IMGUR_CLIENT_ID
            completionBlock:^(NSString *result)
                {
                    if (result)
                    {
                        [[UIPasteboard generalPasteboard] setString:result];
                        showBanner();
                    }
                }
            failureBlock:^(NSURLResponse *a, NSError *b, NSInteger c){ }];
    }
    else if (buttonIndex == 4) 
    {
        // share
        if (window == nil) 
            window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.windowLevel = 666666;
        // send initialization of UIActivityViewController in background
        //dispatch_async(queue, ^{
            UIViewController *vc = [[UIViewController alloc] init];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[screenshot] applicationActivities:nil];
            [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
                //[window resignKeyWindow];
                window.rootViewController = nil;
                window.hidden = YES;
                window = nil;
            }];

            window.rootViewController = vc;
            [window makeKeyAndVisible];
            //dispatch_sync(dispatch_get_main_queue(), ^{
                [vc presentViewController:activityVC animated:YES completion:nil];
            //});
        //});
    }
}
%end

%hook PLPhotoStreamsHelper
- (BOOL)shouldPublishScreenShots {
	if (enabled)
        return uploadToPhotoStreams;
    return %orig;
}
%end

// This is a hook for ScreenPainter
// https://github.com/Sassoty/ScreenPainter/
%hook DragView
- (void)showEndAlert
{
    screenshot = _UICreateScreenUIImage();

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Almpoum" message:@"What would you like to happen to that Screenshot?" delegate:[%c(SBScreenShotter) sharedInstance] cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Save to Photo Library"];
    [alert addButtonWithTitle:@"Copy to the Clipboard"];
    [alert addButtonWithTitle:@"Upload to Imgur"];
    [alert show];
}
%end

%hook SpringBoard
-(void) takeIt
{
    // This is a hook for ScreenCrop
    [(SBScreenShotter*)[%c(SBScreenShotter) sharedInstance] saveScreenshot:YES];
}
%end

%ctor
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ScreenCrop.dylib"])
        dlopen("/Library/MobileSubstrate/DynamicLibraries/ScreenCrop.dylib", RTLD_NOW | RTLD_GLOBAL);
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ScreenPainter.dylib"])
        dlopen("/Library/MobileSubstrate/DynamicLibraries/ScreenPainter.dylib", RTLD_NOW | RTLD_GLOBAL);

    %init;

    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &reloadSettings, CFSTR(SETTINGS_EVENT), NULL, 0);
    reloadSettings(nil, nil, nil, nil, nil);
}
