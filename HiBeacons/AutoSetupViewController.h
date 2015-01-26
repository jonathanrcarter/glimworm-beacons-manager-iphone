//
//  AutoSetupViewController.h
//  HiBeacons
//
//  Created by Jonathan Carter on 19/10/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlimwormBeaconEdit.h"
#import "GBDefaults.h"

@interface AutoSetupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *p_uuid;
@property (weak, nonatomic) IBOutlet UITextField *p_major;
@property (weak, nonatomic) IBOutlet UITextField *p_minor;
@property (weak, nonatomic) IBOutlet UIButton *p_save_as_default_button;
- (IBAction)p_save_as_default_button:(id)sender;
- (IBAction)p_reset_to_factory_settings:(id)sender;

- (IBAction)p_save_preset:(id)sender;
- (IBAction)p_load_preset:(id)sender;


@end
