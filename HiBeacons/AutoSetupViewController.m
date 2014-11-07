//
//  AutoSetupViewController.m
//  HiBeacons
//
//  Created by Jonathan Carter on 19/10/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "AutoSetupViewController.h"

@interface AutoSetupViewController ()

@end


@implementation AutoSetupViewController

@synthesize gbedit, appStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        gbedit = [GlimwormBeaconEdit sharedManager];
        appStatus = [AppStatus sharedManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"Loaded auto setup view");
    [self loadDefaults];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touched");
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_p_uuid isFirstResponder] && [touch view] != _p_uuid) {
        [_p_uuid resignFirstResponder];
    }
    if ([_p_major isFirstResponder] && [touch view] != _p_major) {
        [_p_major resignFirstResponder];
    }
    if ([_p_minor isFirstResponder] && [touch view] != _p_minor) {
        [_p_minor resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
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


#define TAG_SAVE 1

NSString *l = @"";

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == TAG_SAVE) {
        if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
            // Cancel button response

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_p_uuid.text forKey:[NSString stringWithFormat:@"%@_uuid",l]];
            [defaults setObject:_p_major.text forKey:[NSString stringWithFormat:@"%@_major",l]];
            [defaults setObject:_p_minor.text forKey:[NSString stringWithFormat:@"%@_minor",l]];
            [defaults synchronize];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Preset Saved"
                                                           message: @"You can load this using the LOAD PRESET button"
                                                          delegate: self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil,nil];
            [alert show];
        }
    }
}



- (IBAction)p_save_preset:(id)sender {
    NSLog(@"pressed button - save preset %@",sender);
    UIButton *b = (UIButton *) sender;
    l = b.titleLabel.text;

    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Save Preset Saved"
                                                   message: [NSString stringWithFormat:@"Do you want to overwrite preset %@",l]
                                                  delegate: self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    
    alert.tag = TAG_SAVE;
    [alert show];
}
- (IBAction)p_load_preset:(id)sender {
    NSLog(@"pressed button - load preset %@",sender);
    UIButton *b = (UIButton *) sender;
    
    NSString *l = b.titleLabel.text;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _p_uuid.text = [defaults objectForKey:[NSString stringWithFormat:@"%@_uuid",l]];
    _p_major.text = [defaults objectForKey:[NSString stringWithFormat:@"%@_major",l]];
    _p_minor.text = [defaults objectForKey:[NSString stringWithFormat:@"%@_minor",l]];
    
}


- (IBAction)p_save_as_default_button:(id)sender {
    NSLog(@"pressed button");

    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_p_uuid.text forKey:@"uuid"];
    [defaults setObject:_p_major.text forKey:@"major"];
    [defaults setObject:_p_minor.text forKey:@"minor"];
    [defaults synchronize];
}

- (IBAction)p_reset_to_factory_settings:(id)sender {
    NSLog(@"factory reset");
    
    _p_uuid.text = @"74278bda-b644-4520-8f0c-720eaf059935";
    _p_major.text = @"1";
    _p_minor.text = @"1";;
    
}


#pragma mark Load and save defaults

- (void) loadDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _p_uuid.text = [defaults objectForKey:@"uuid"];
    _p_major.text = [defaults objectForKey:@"major"];
    _p_minor.text = [defaults objectForKey:@"minor"];
}


@end
