#import <Preferences/Preferences.h>
#import <SettingsKit/SKListControllerProtocol.h>
#import <SettingsKit/SKTintedListController.h>
#import <SettingsKit/SKStandardController.h>
#import <SettingsKit/SKPersonCell.h>
#import <SettingsKit/SKSharedHelper.h>
#import <SettingsKit/SKListItemsController.h>

@interface PSTableCell (Almpoum)
@property (nonatomic, retain) UIView *backgroundView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end

@interface PSListController (Almpoum)
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
-(UINavigationController*)navigationController;
@end

@interface AlmpoumSettingsListController: SKStandardController
@end
@interface ASettings2ListController : SKTintedListController<SKListControllerProtocol>
@end
@interface AlmpoumMakersListController : SKTintedListController<SKListControllerProtocol>
@end
@interface ElijahPersonCell : SKPersonCell
@end
@interface AndrewPersonCell : SKPersonCell
@end
@interface AlmpoumListItemsController : SKListItemsController
@end


@implementation AlmpoumSettingsListController
-(BOOL) showHeartImage { return YES; }
-(BOOL) tintNavigationTitleText { return NO; }
-(BOOL) shiftHeartImage { return YES; }
-(NSString*) shareMessage { return @"I’m loving #Almpoum from @Daementor and @DrewPlex, it’s been keeping my screenshots nice and organized!"; }
-(UIColor*) heartImageColor { return [UIColor colorWithRed:122/255.0f green:155/255.0f blue:153/255.0f alpha:1.0f]; }
-(UIColor*) navigationTintColor { return [UIColor colorWithRed:122/255.0f green:155/255.0f blue:153/255.0f alpha:1.0f]; }
-(NSString*) headerText { return @"Almpoum"; }
-(NSString*) headerSubText { return @"By Elijah and Andrew"; }
-(UIColor*) headerColor { return [UIColor colorWithRed:74/255.0f green:74/255.0f blue:74/255.0f alpha:1.0f]; }
-(UIColor*) iconColor { return [UIColor colorWithRed:122/255.0f green:155/255.0f blue:153/255.0f alpha:1.0f]; }
-(NSString*) customTitle { return @""; }
-(NSString*)postNotification { return @"com.efrederickson.almpoum/reloadSettings"; }
-(NSString*)defaultsFileName { return @"com.efrederickson.almpoum.settings"; }
-(NSArray*) emailAddresses { return @[@"elijah.frederickson@gmail.com", @"andrewaboshartworks@gmail.com"]; }
-(NSString*) emailBody { return @""; }
-(NSString*) emailSubject { return @"Almpoum"; }
-(NSString*) enabledDescription { return @"Quickly enable or disable Almpoum."; }
-(NSString*) footerText { return @"© 2014 Elijah Frederickson & Andrew Abosh"; }

-(NSString*) settingsListControllerClassName { return @"ASettings2ListController"; }
-(NSString*) makersListControllerClassName { return @"AlmpoumMakersListController"; }

-(void) loadSettingsListController
{
    ASettings2ListController *a = [[ASettings2ListController alloc] init];
    [self pushController:a animate:YES];
}
-(void) loadAlmpoumMakersListController
{
    AlmpoumMakersListController *a = [[AlmpoumMakersListController alloc] init];
    [self pushController:a animate:YES];
}
@end

@implementation ASettings2ListController
-(UIColor*) navigationTintColor { return [UIColor colorWithRed:122/255.0f green:155/255.0f blue:153/255.0f alpha:1.0f]; }
-(NSString*) plistName { return @"Settings2"; }
-(BOOL) showHeartImage { return NO; }
@end

@implementation  ElijahPersonCell
-(NSString*)personDescription { return @"The Developer"; }
-(NSString*)name { return @"Elijah Frederickson"; }
-(NSString*)twitterHandle { return @"daementor"; }
-(NSString*)imageName { return @"elijah.png"; } /* should be a circular image, 200x200 retina */
@end

@implementation AndrewPersonCell
-(NSString*)personDescription { return @"The Graphic Artist"; }
-(NSString*)name { return @"Andrew Abosh"; }
-(NSString*)twitterHandle { return @"drewplex"; }
-(NSString*)imageName { return @"andrew.png"; } /* should be a circular image, 200x200 retina */
@end


@implementation AlmpoumMakersListController
-(UIColor*) navigationTintColor { return [UIColor colorWithRed:122/255.0f green:155/255.0f blue:153/255.0f alpha:1.0f]; }
-(BOOL) showHeartImage { return NO; }
-(NSString*) customTitle { return @"The Makers"; }

- (id)customSpecifiers {
    return @[
             @{ @"cell": @"PSGroupCell" },
             @{
                 @"cell": @"PSLinkCell",
                 @"cellClass": @"ElijahPersonCell",
                 @"height": @100,
                 @"action": @"openElijahTwitter"
                 },
             @{ @"cell": @"PSGroupCell" },
             @{
                 @"cell": @"PSLinkCell",
                 @"cellClass": @"AndrewPersonCell",
                 @"height": @100,
                 @"action": @"openAndrewTwitter"
                 },
             @{ @"cell": @"PSGroupCell" },
             @{
                 @"cell": @"PSLinkCell",
                 @"label": @"Source Code",
                 @"action": @"openGithub",
                 @"icon": @"github.png"
                 },
             ];
}

-(void) openGithub
{
    [SKSharedHelper openGitHub:@"mlnlover11/Almpoum"];
}

-(void) openElijahTwitter
{
    [SKSharedHelper openTwitter:@"daementor"];
}

-(void) openAndrewTwitter
{
    [SKSharedHelper openTwitter:@"drewplex"];
}
@end

@implementation AlmpoumListItemsController
-(UIColor*) navigationTintColor { return [UIColor colorWithRed:122/255.0f green:155/255.0f blue:153/255.0f alpha:1.0f]; }
@end
