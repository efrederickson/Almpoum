#import <Preferences/Preferences.h>
#import "MailSender.h"

@interface AlmpoumSettingsListController: PSListController
{
}
@end

@implementation AlmpoumSettingsListController// : UIViewController <MFMailComposeViewControllerDelegate>
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"AlmpoumSettings" target:self] retain];
	}
	return _specifiers;
}

-(void) sendEmail
{
    MailSender *email = [[MailSender alloc] init];
    [self pushController:email];
    //[self.rootController popControllerWithAnimation:YES];
    //popNavigationItem
    //[email release];
}
@end

@interface ASettings2ListController : PSListController {
}
@end

@implementation ASettings2ListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Settings2" target:self] retain];
	}
	return _specifiers;
}
@end