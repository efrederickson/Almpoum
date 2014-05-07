#import <Preferences/Preferences.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>


@interface PSTableCell (Almpoum)
@property (nonatomic, retain) UIView *backgroundView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end

@interface PSListController (Almpoum)
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
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
    if (_specifiers == nil)
    {
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
        
        NSMutableArray *specifiers = [NSMutableArray array];
        [specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"Thank you"
                                                             target:self set:NULL get:NULL
                                                             detail:Nil
                                                               cell:PSStaticTextCell
                                                               edit:Nil]];
        _specifiers = specifiers;
    }
    return _specifiers;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    //[self.rootController popController];
    //[[super navigationController] popViewControllerAnimated:YES];
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

