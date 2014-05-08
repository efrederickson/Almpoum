#import <Preferences/Preferences.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>

#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.efrederickson.almpoum.settings.plist"


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

@interface AlmpoumSettingsListController: PSListController {}
@end

@implementation AlmpoumSettingsListController// : UIViewController <MFMailComposeViewControllerDelegate>
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"AlmpoumSettings" target:self] retain];
	}
	return _specifiers;
}

-(id) init
{
    id obj = [super init];
    
    /*UIImage* image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AlmpoumSettings.bundle/heart@2x.png"]; //[UIImage imageNamed:@"heart.png"];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:nil action:nil];
    ((UINavigationItem*)self.navigationItem).rightBarButtonItem = button;*/
    
    UIImage* image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AlmpoumSettings.bundle/heart@2x.png"];
    CGRect frameimg = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(heartWasTouched)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    ((UINavigationItem*)self.navigationItem).rightBarButtonItem=mailbutton;
    [someButton release];
    
    return obj;
}


-(void) heartWasTouched
{
    SLComposeViewController *composeController = [SLComposeViewController
                                                  composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    [composeController setInitialText:@"I’m loving #Almpoum from @Daementor and @DrewPlex, it’s been keeping my screenshots nice and organized!"];
    
    [self presentViewController:composeController
                       animated:YES completion:nil];
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:SETTINGS_FILE] autorelease];
    [dict setValue:@1 forKey:@"useExtremeLanguage"];
    [dict writeToFile:SETTINGS_FILE atomically:YES];
}

@end

@interface ASettings2ListController : PSListController { }
@end

@implementation ASettings2ListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Settings2" target:self] retain];
	}
	return _specifiers;
}
@end

@interface AlmpoumSupportController : PSListController<MFMailComposeViewControllerDelegate> {
    MFMailComposeViewController *mailViewController;
}
@end

@implementation AlmpoumSupportController

-(id) specifiers {
    if (!mailViewController && [MFMailComposeViewController canSendMail])
    {
        mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Almpoum"];
        [mailViewController setMessageBody:@"" isHTML:NO];
        [mailViewController setToRecipients:[NSArray arrayWithObjects:@"elijah.frederickson@gmail.com",@"andrewaboshartworks@gmail.com",nil]];
        [mailViewController addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:@"/var/mobile/Library/Preferences/com.efrederickson.almpoum.settings.plist"] mimeType:@"text/plain" fileName:@"almpoum.settings.plist"];
        
        [self.rootController presentViewController:mailViewController animated:YES completion:nil];
        //[mailViewController release];
    }
    //[[super navigationController] popViewControllerAnimated:YES];
        
    return nil;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}

@end

@interface CustomGiantCell : PSTableCell {
    UIImageView *_background;
}
@end

@implementation CustomGiantCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/AlmpoumSettings.bundle/logo@2x.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        [self addSubview:_background];
    }
    return self;
}
@end

@interface CustomGiantFooterCell : PSTableCell {
    UIImageView *_background;
}
@end

@implementation CustomGiantFooterCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/AlmpoumSettings.bundle/footer@2x.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        [self addSubview:_background];
    }
    return self;
}

@end

@interface MakersListController : PSListController { }
@end

@implementation MakersListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Makers" target:self] retain];
	}
	return _specifiers;
}

-(void) openGithub
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ioc://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ioc://github.com/mlnlover11/Almpoum"]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/mlnlover11/Almpoum"]];
    }
}
@end

@interface GiantMakerCell1 : PSTableCell {
    UIImageView *_background;
    UILabel *label;
    UILabel *label2;
    UIButton *twitterButton;
    UIButton *githubButton;
    UIButton *emailButton;
}
@end

@implementation GiantMakerCell1
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/AlmpoumSettings.bundle/elijah@2x.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        _background.frame = CGRectMake(9, 18, 65, 65);
        [self addSubview:_background];
        
        CGRect frame = [self frame];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 18, frame.size.width, frame.size.height)];
        [label setText:@"Elijah Frederickson"];
        [label setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
        else
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:21]];

        [self addSubview:label];
        
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 42, frame.size.width, frame.size.height)];
        NSDictionary *dict = [[[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE] autorelease];
        BOOL useExtremeLanguage = [[dict valueForKey:@"useExtremeLanguage"] intValue] == 1 ? YES : NO;
        if (useExtremeLanguage)
            [label2 setText:@"The L33T Developer"];
        else
            [label2 setText:@"The Developer"];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
        [self addSubview:label2];
    }
    return self;
}

@end

@interface GiantMakerCell2 : PSTableCell {
    UIImageView *_background;
    UILabel *label;
    UILabel *label2;
}
@end

@implementation GiantMakerCell2
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [[UIImage alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/AlmpoumSettings.bundle/andrew@2x.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        _background.frame = CGRectMake(9, 18, 65, 65);
        [self addSubview:_background];
        
        CGRect frame = [self frame];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 18, frame.size.width, frame.size.height)];
        [label setText:@"Andrew Abosh"];
        [label setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
        else
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:21]];
        
        [self addSubview:label];
        
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 42, frame.size.width, frame.size.height)];
        
        NSDictionary *dict = [[[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE] autorelease];
        BOOL useExtremeLanguage = [[dict valueForKey:@"useExtremeLanguage"] intValue] == 1 ? YES : NO;
        if (useExtremeLanguage)
            [label2 setText:@"Le Artist Of Le Graphics."];
        else
            [label2 setText:@"The Graphic Artist"];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
        
        [self addSubview:label2];
        
        //self->action = @selector(cellClicked);
    }
    return self;
}
@end

@interface openTwitterElijahController : PSListController { }
@end

@implementation openTwitterElijahController
- (id)specifiers {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/daementor"]];
	return nil;
}

- (void)viewDidAppear:(BOOL)arg1 {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}
@end

@interface openTwitterAndrewController : PSListController { }
@end

@implementation openTwitterAndrewController
- (id)specifiers {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/drewplex"]];
    return nil;
}

- (void)viewDidAppear:(BOOL)arg1 {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
    
    //[super popController];
    //[self.navigationController popToViewController:self.rootController animated:YES];
    //int count = [self.navigationController.viewControllers count];
    //[navController popToViewController:[navController.viewControllers objectAtIndex:0] animated:YES];
}
@end