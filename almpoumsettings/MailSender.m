#import "MailSender.h"

@implementation MailSender

- (void)viewDidLoad {
    [super viewDidLoad];

    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:@"Almpoum"];
    [mailViewController setMessageBody:@"" isHTML:NO];
    [mailViewController setToRecipients:[NSArray arrayWithObjects:@"elijah.frederickson@gmail.com",@"andrewaboshartworks@gmail.com",nil]];
    [mailViewController addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:@"/var/mobile/Library/Preferences/com.efrederickson.almpoum.settings.plist"] mimeType:@"text/plain" fileName:@"almpoum.settings.plist"];
    
    [self presentViewController:mailViewController animated:YES completion:nil];
    [mailViewController release];
    //[[super navigationController] popViewControllerAnimated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[super navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload { }

- (void)dealloc { [super dealloc]; }
@end