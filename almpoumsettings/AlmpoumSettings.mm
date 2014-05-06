#import <Preferences/Preferences.h>
#import "HeaderCell.h"
#import "AlmpoumFooterCell.h"

@interface AlmpoumSettingsListController: PSListController {
}
@end

@implementation AlmpoumSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"AlmpoumSettings" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
