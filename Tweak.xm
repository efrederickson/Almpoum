#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "UIKit/UIKit.h"
#import <AudioToolbox/AudioToolbox.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBScreenFlash.h>
#import <SpringBoard/SBApplication.h>

@interface UIRemoteApplication
-(void)didTakeScreenshot;
@end

@interface SBApplication (CSS)
-(UIRemoteApplication*)remoteApplication;
@end

extern "C" UIImage *_UICreateScreenUIImageWithRotation(BOOL rotate);
#define kPhotoShutterSystemSound 0x454
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.efrederickson.almpoum.plist"
#define SETTINGS_EVENT "com.efrederickson.almpoum/reloadSettings"

BOOL enabled = YES;
NSString *albumName = @"Screenshots";

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
        albumName = [[prefs objectForKey:@"albumName"] stringValue];
    else
        albumName = @"Screenshots";
}

%group MAIN
%hook SBScreenShotter
-(void)saveScreenshot:(BOOL)arg1 
{
    if (!enabled)
    {
        %orig;
        return;
    }

    UIImage *screenshot = _UICreateScreenUIImageWithRotation(TRUE);
	if (screenshot) {
		ALAssetsLibrary *al = [[ALAssetsLibrary alloc] init];
        
        void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
            NSLog(@"Almpoum: saved to album: %@", [assetURL absoluteString]);
        };
        
        void (^failure)(NSError *) = ^(NSError *error) {
            if (error == nil) return;
            NSLog(@"Almpoum: failed to save to album: %@", [error description]);
        };

        [al saveImage:screenshot
            toAlbum:@"Test Screenshot Album"
            completion:completion
            failure:failure];
            
        SBApplication *frontMostApplication = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
        [frontMostApplication.remoteApplication didTakeScreenshot];
        
        [(SBScreenFlash *)[%c(SBScreenFlash) sharedInstance] flash];
		AudioServicesPlaySystemSound(kPhotoShutterSystemSound);
	} else {
		NSLog(@"Almpoum: _UICreateScreenUIImageWithRotation failed");
	}
}
%end
%end // group MAIN

%group ClipShot
%hook CSScreenShotter
- (void)saveScreenshotToCameraRoll:(UIImage *)screenshot 
{
    if (!enabled)
    {
        %orig;
        return;
    }

    if (screenshot) {
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
	} else {
    }
}
%end
%end // group ClipShot

%ctor
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ClipShot.dylib"])
    {
        %init(ClipShot);
        NSLog(@"Almpoum: initialized ClipShot hooks");
    }
    else
    {
        %init(MAIN);
        NSLog(@"Almpoum: initialized SpringBoard hooks");
    }

    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &reloadSettings, CFSTR(SETTINGS_EVENT), NULL, 0);
    reloadSettings(nil, nil, nil, nil, nil);
}