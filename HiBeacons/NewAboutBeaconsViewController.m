//
//  NewAboutBeaconsViewController.m
//  HiBeacons
//
//  Created by Jonathan Carter on 21/10/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "NewAboutBeaconsViewController.h"

@interface NewAboutBeaconsViewController ()

@end

@implementation NewAboutBeaconsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)p_buy_button:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://glimwormbeacons.com/buy"]];
}

- (IBAction)p_faq_button:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://glimwormbeacons.com/faq/"]];
}

- (IBAction)p_email_support_button:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Support Request";
    // Email Content
    NSString *messageBody = @"Dear Glimworm Beacons,";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"info@glimwormbeacons.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (IBAction)p_affiliate_button:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://glimwormbeacons.com/affiliate-program/"]];

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
