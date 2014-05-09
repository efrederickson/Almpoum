#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "UIKit/UIKit.h"
#import <AudioToolbox/AudioToolbox.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBScreenFlash.h>
#import <SpringBoard/SBApplication.h>
#import <dlfcn.h>
#import <MobileCoreServices/MobileCoreServices.h> // For the UTI types constants

@interface SBScreenShotter
+(id)sharedInstance;
-(void)saveScreenshot:(BOOL)screenshot;
-(void)finishedWritingScreenshot:(id)screenshot didFinishSavingWithError:(id)error context:(void*)context;
@end

@interface UIRemoteApplication
-(void)didTakeScreenshot;
@end

@interface SBApplication (CSS)
-(UIRemoteApplication*)remoteApplication;
@end

extern "C" UIImage *_UICreateScreenUIImageWithRotation(BOOL rotate);
#define kPhotoShutterSystemSound 0x454
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.efrederickson.almpoum.settings.plist"
#define SETTINGS_EVENT "com.efrederickson.almpoum/reloadSettings"
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

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

static UIImage *screenshot;

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

%hook SBScreenFlash
-(void) flashColor:(UIColor*)color
{
    if (darkenCameraFlash && enabled)
        %orig([UIColor blackColor]);
    else
        %orig;
}
%end

%hook SBScreenShotter // <UIAlertViewDelegate>
-(void)saveScreenshot:(BOOL)arg1 
{
    if (!enabled)
    {
        NSLog(@"Almpoum: calling orig because disabled");
        %orig;
        return;
    }

    screenshot = _UICreateScreenUIImageWithRotation(TRUE);
	if (screenshot) {
        if (saveMode == 1) // Prompt
        { 
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Almpoum" message:@"What would you like to happen to that Screenshot?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [alert addButtonWithTitle:@"Save to Photo Library"];
            [alert addButtonWithTitle:@"Copy to the Clipboard"];
            [alert addButtonWithTitle:@"Both"];
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
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setData:UIImagePNGRepresentation(screenshot) forPasteboardType:(__bridge NSString *)kUTTypePNG];
            
            saveScreenshot(screenshot);
        }

        if (notifyApps && IS_OS_7_OR_LATER)
        {
            SBApplication *frontMostApplication = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
            [frontMostApplication.remoteApplication didTakeScreenshot];
        }

        if (showCameraFlash)
            [[%c(SBScreenFlash) sharedInstance] flash];
        if (playShutterSound)
            AudioServicesPlaySystemSound(kPhotoShutterSystemSound);

        //[[%c(SBScreenShotter) sharedInstance] finishedWritingScreenshot:nil didFinishSavingWithError:nil context:nil];
	} else {
		NSLog(@"Almpoum: _UICreateScreenUIImageWithRotation failed");
	}
}

%new
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // Photo library
        saveScreenshot(screenshot);
    }
    else if (buttonIndex == 2) {
        // pasteboard
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setData:UIImagePNGRepresentation(screenshot) forPasteboardType:(__bridge NSString *)kUTTypePNG];
    }
    else if (buttonIndex == 3) {
        // both
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setData:UIImagePNGRepresentation(screenshot) forPasteboardType:(__bridge NSString *)kUTTypePNG];
            
        saveScreenshot(screenshot);
    }
}
%end

%hook PLPhotoStreamsHelper

- (BOOL)shouldPublishScreenShots {
	return enabled ? uploadToPhotoStreams : %orig;
}

%end

%ctor
{
    %init;
    NSLog(@"Almpoum: initialized SpringBoard hooks");

    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &reloadSettings, CFSTR(SETTINGS_EVENT), NULL, 0);
    reloadSettings(nil, nil, nil, nil, nil);
}