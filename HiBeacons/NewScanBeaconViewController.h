//
//  NewScanBeaconViewController.h
//  HiBeacons
//
//  Created by Jonathan Carter on 06/08/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import CoreBluetooth;
#import "AppStatus.h"
#import "GlimwormBeaconEdit.h"
#import "SpinnerView.h"

@class NewScanBeaconViewController;

@protocol NewScanBeaconViewControllerDelegate <NSObject>
- (void)addItemViewController:(NewScanBeaconViewController *)controller didFinishEnteringItem:(NSString *)item;
@end

@interface NewScanBeaconViewController : UIViewController <
    CLLocationManagerDelegate,
//    CBPeripheralManagerDelegate,
    CBCentralManagerDelegate,
//    CBPeripheralDelegate,
    UIApplicationDelegate,
    GlimwormBeaconEditDelegate> {
    AppStatus *appStatus;
}
@property (weak, nonatomic) IBOutlet UIView *innerView;

@property (nonatomic, weak) id <NewScanBeaconViewControllerDelegate> delegate;
@property (nonatomic, weak) id <GlimwormBeaconEditDelegate> gbedit_delegate;
@property (nonatomic, weak) id <SpinnerViewDelegate> spinner_delegate;
@property (nonatomic, weak) GlimwormBeaconEdit *gbedit;

@property (nonatomic, retain) AppStatus *appStatus;
@property (nonatomic, strong) CBPeripheral *peripheral;

/* added by j carter for glimworm beacons - end */
@property (weak, nonatomic) IBOutlet UITextField *p_uuid;
@property (weak, nonatomic) IBOutlet UITextField *p_name;
@property (weak, nonatomic) IBOutlet UITextField *p_pincode;
@property (weak, nonatomic) IBOutlet UITextField *p_major;
@property (weak, nonatomic) IBOutlet UITextField *p_minor;

@property (weak, nonatomic) IBOutlet UILabel *p_measuredpower;
@property (weak, nonatomic) IBOutlet UILabel *p_firmware;
@property (weak, nonatomic) IBOutlet UILabel *p_battlevel;



@property (weak, nonatomic) IBOutlet UILabel *p_advint;
- (IBAction)p_advintslider:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *p_advintslider;

- (IBAction)p_rangeslider:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *p_rangeslider;
@property (weak, nonatomic) IBOutlet UILabel *p_rangelabel;

@property (weak, nonatomic) IBOutlet UILabel *p_currentcommandlabel;



- (IBAction)p_reset:(id)sender;
- (IBAction)p_update:(id)sender;
- (IBAction)p_sendchanges:(id)sender;
- (IBAction)p_reload:(id)sender;


- (IBAction)connect_cancel_but:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *w_spinner;
@property (weak, nonatomic) IBOutlet UIView *WriteView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *write_spinner;
- (IBAction)write_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ConfigView;
@property (weak, nonatomic) IBOutlet UIView *WorkingView;

@property  (nonatomic, strong) NSString *currentInterval, *currentRange, *currentfirmware;


/* spinner */
-(IBAction)didPressSpinnerButton:(id)sender;


@end
