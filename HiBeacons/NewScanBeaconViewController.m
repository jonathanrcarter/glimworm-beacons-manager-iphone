//
//  NewScanBeaconViewController.m
//  HiBeacons
//
//  Created by Jonathan Carter on 06/08/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "NewScanBeaconViewController.h"
#import "BTDeviceModel.h"
#include <QuartzCore/QuartzCore.h>
//#include <QuartzCore/QuartzCore.framework>


/* glimworm beacon default uuid */
static NSString * const kUUID = @"74278bda-b644-4520-8f0c-720eaf059935";
static NSString * const kIdentifier = @"SomeIdentifier";
static void * const kMonitoringOperationContext = (void *)&kMonitoringOperationContext;
static void * const kRangingOperationContext = (void *)&kRangingOperationContext;

//static const NSTimeInterval kLXCBRequestTimeout = 5.0;
//static const NSTimeInterval kLXCBActivateTimeout = 5.0;


@interface NewScanBeaconViewController ()

@end

@implementation NewScanBeaconViewController

@synthesize delegate;
@synthesize gbedit_delegate;
@synthesize spinner_delegate;

//@synthesize appStatus;
@synthesize peripheral;
@synthesize p_advint;
@synthesize p_advintslider;
@synthesize p_battlevel;
@synthesize p_firmware;
@synthesize p_major;
@synthesize p_measuredpower;
@synthesize p_minor;
@synthesize p_name;
@synthesize p_pincode;
@synthesize p_rangelabel;
@synthesize p_rangeslider;
@synthesize p_uuid;
@synthesize p_build;
@synthesize p_rel;
@synthesize p_beacontype;
//@synthesize w_spinner;
//@synthesize WorkingView;
//@synthesize write_spinner;
//@synthesize WriteView;
@synthesize p_currentcommandlabel;
@synthesize currentRange, currentInterval, currentfirmware, currentMode, currentBatt;
@synthesize p_modelabel, p_modeslider;
@synthesize v_scrollview, v_view1;


@synthesize innerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [GlimwormBeaconEdit sharedInstance].delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"DID LOAD");
    [self connect];
}


- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"DID APPEAR");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Beacon configuration

//- (void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//    NSLog(@"state update");
//    
//    if (central.state == CBCentralManagerStatePoweredOn) {
//        NSLog( @"state update powered on");
//        //        [self startScan];
//    }
//    else if (central.state == CBCentralManagerStatePoweredOff) {
//        NSLog(@"state update powered off");
//    }
//    else if (central.state == CBCentralManagerStateUnauthorized) {
//        NSLog(@"state update powered unauthorized");
//    }
//    else if (central.state == CBCentralManagerStateUnsupported) {
//        NSLog(@"state update powered unsupported");
//    }
//}


//-(void) activate:(NSNotification *)pNotification {
//    NSLog(@"application activate ");
//    if ([GlimwormBeaconEdit sharedInstance].peripheralisconnectedButNotRead) {
//        NSLog(@"application activate READ");
//        [self q_readall];
//    }
//}


//#pragma mark - Local notifications
//- (void)sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region
//{
//    UILocalNotification *notification = [UILocalNotification new];
//    
//    // Notification details
//    notification.alertBody = [NSString stringWithFormat:@"Entered beacon region for UUID: %@",
//                              region.proximityUUID.UUIDString];   // Major and minor are not available at the monitoring stage
//    notification.alertAction = NSLocalizedString(@"View Details", nil);
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//}

- (BOOL) has16advertisments {
    if ([currentfirmware isEqualToString:@"V517"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V518"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V519"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V520"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V521"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V522"]) return FALSE;
    return TRUE;
}


#pragma mark - Configuration Popup window

-(void)connect {

    if ( [[GlimwormBeaconEdit sharedInstance] connect]) {
        [self working];
        self.p_uuid.layer.borderColor = [[UIColor grayColor]CGColor];
    }
    
}


- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller working:(NSString *)item
{
    [self working];
}
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller writing:(NSString *)item
{
    [self writing];
}

- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller connectingStringDisplay:(NSString *)item
{
    NSLog(@"BeaconViewController - connectingStringDisplay callback - %@",item);
    if ([item isEqualToString:@"done"]) {
        p_currentcommandlabel.text = @"";
    } else {
        p_currentcommandlabel.text = item;
    }
}
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller sendMessage:(NSString *)item
{
    NSLog(@"%@",item);
}
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller done:(NSString *)item
{
    [self done];
}
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller donewriting:(NSString *)item
{
    [self donewriting];
}
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller p_close_window:(NSString *)item
{
    [self p_close_window];
}
- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller cancel_and_close_window:(NSString *)item
{
    [self cancel_and_close_window];
}


- (void)GlimwormBeaconEdit:(GlimwormBeaconEdit *)controller doneRedrawForm:(NSString *)item
{
    NSLog(@"REDRAW FORM!!!!");
    [self performSelector:@selector(setFormvaluesFromGBedit) withObject:self afterDelay:0.5];

}

-(void)setFormvaluesFromGBedit {
    self.p_firmware.text = [GlimwormBeaconEdit sharedInstance].p_firmware_text;
    self.p_major.text = [GlimwormBeaconEdit sharedInstance].p_major_text;
    self.p_minor.text = [GlimwormBeaconEdit sharedInstance].p_minor_text;
    self.p_uuid.text = [GlimwormBeaconEdit sharedInstance].p_uuid_text;
    self.p_name.text = [GlimwormBeaconEdit sharedInstance].p_name_text;
    self.p_pincode.text = [GlimwormBeaconEdit sharedInstance].p_pincode_text;
    self.p_measuredpower.text = [GlimwormBeaconEdit sharedInstance].p_measuredpower_text;
    self.p_rangeslider.value = [GlimwormBeaconEdit sharedInstance].p_rangeslider_value;
    [self setRangeLabelFromSlider];
    self.p_advintslider.value = [GlimwormBeaconEdit sharedInstance].p_advintslider_value;
    [self setAdvIntervalFromSlider];
    self.p_battlevel.text = [GlimwormBeaconEdit sharedInstance].p_battlevel_text;
    self.currentfirmware = [GlimwormBeaconEdit sharedInstance].currentfirmware;
    self.p_rel.text = [GlimwormBeaconEdit sharedInstance].PDATE;
    self.p_build.text = [GlimwormBeaconEdit sharedInstance].BTYPE;
    if ([GlimwormBeaconEdit sharedInstance].isUSBBeacon) {
        self.p_beacontype.text = @"USB Beacon";
    } else {
        self.p_beacontype.text = @"Battery Beacon";
    }
    if ([GlimwormBeaconEdit sharedInstance].isCapableOfSettingModes) {
        [self.p_modeslider setEnabled:TRUE];
        self.p_modeslider.value = [self ModeSliderValueFromActualValue:[GlimwormBeaconEdit sharedInstance].p_modeslider_value];
        [self setModeSliderFromSlider];
    } else {
        self.p_modeslider.value = 0;
        self.currentMode = @"0";
        self.p_modelabel.text = @"connectable";
        [self.p_modeslider setEnabled:false];
    }
    if ([GlimwormBeaconEdit sharedInstance].isCapableOfSettingBatteryLevel) {
        [self.p_battslider setEnabled:TRUE];
        self.p_battslider.value = [GlimwormBeaconEdit sharedInstance].p_battslider_value;
        [self setBatterySliderFromSlider];
    } else {
        self.p_battslider.value = [GlimwormBeaconEdit sharedInstance].p_battslider_value;
        [self setBatterySliderFromSlider];
        [self.p_battslider setEnabled:false];
    }
    
}
-(void)setGBeditValuesFromForm {
    [GlimwormBeaconEdit sharedInstance].p_firmware_text = self.p_firmware.text;
    [GlimwormBeaconEdit sharedInstance].p_major_text = self.p_major.text;
    [GlimwormBeaconEdit sharedInstance].p_minor_text = self.p_minor.text;
    [GlimwormBeaconEdit sharedInstance].p_uuid_text = self.p_uuid.text;
    [GlimwormBeaconEdit sharedInstance].p_name_text = self.p_name.text;
    [GlimwormBeaconEdit sharedInstance].p_pincode_text = self.p_pincode.text;
    [GlimwormBeaconEdit sharedInstance].p_measuredpower_text = self.p_measuredpower.text;
    [GlimwormBeaconEdit sharedInstance].p_rangeslider_value = self.p_rangeslider.value;
    [GlimwormBeaconEdit sharedInstance].p_modeslider_value = [self ActualValueFromModeSliderValue:(int)self.p_modeslider.value];
    [GlimwormBeaconEdit sharedInstance].p_battslider_value = self.p_battslider.value;
    [GlimwormBeaconEdit sharedInstance].currentInterval = currentInterval;
    [GlimwormBeaconEdit sharedInstance].currentRange = currentRange;
    [GlimwormBeaconEdit sharedInstance].currentMode = currentMode;
    [GlimwormBeaconEdit sharedInstance].currentBatt = currentBatt;
//    gbedit.currentRange =

    
    [GlimwormBeaconEdit sharedInstance].p_advintslider_value = self.p_advintslider.value;
    [GlimwormBeaconEdit sharedInstance].p_battlevel_text = self.p_battlevel.text;
}


-(void)setRangeLabelFromSlider {
    self.p_rangeslider.value = roundf(self.p_rangeslider.value);
    switch ((int)self.p_rangeslider.value) {
        case 0:
            self.p_rangelabel.text = @"range : 10m";
            currentRange = @"0";
            break;
        case 1:
            self.p_rangelabel.text = @"range : 20m";
            currentRange = @"1";
            break;
        case 2:
            self.p_rangelabel.text = @"range : 50m";
            currentRange = @"2";
            break;
        case 3:
            self.p_rangelabel.text = @"range : 100m";
            currentRange = @"3";
            break;
    }
}
-(int)ModeSliderValueFromActualValue:(int) val {
    switch (val) {
        case 1:
            return 0;
        case 2:
            return 1;
        case 3:
            return 1;
        default:
            return 0;
    }
}
-(int)ActualValueFromModeSliderValue:(int) val {
    switch (val) {
        case 2:
            return 2;
        case 3:
            return 2;
        case 1:
            return 2;
        default:
            return 0;
    }
}

-(void)setBatterySliderFromSlider {
    self.p_battslider.value = roundf(self.p_battslider.value);
    switch ((int)self.p_battslider.value) {
        case 1:
            self.p_battslider_label.text = @"battery level ON";
            currentBatt = @"1";
            break;
        default:
            self.p_battslider_label.text = @"battery level OFF";
            currentBatt = @"0";
            break;
    }
}

-(void)setModeSliderFromSlider {
    self.p_modeslider.value = roundf(self.p_modeslider.value);
    switch ((int)self.p_modeslider.value) {
        case 0:
            self.p_modelabel.text = @"connectable";
            currentMode = @"0";
            break;
//        case 1:
//            self.p_modelabel.text = @"do not use";
//            currentMode = @"1";
//            break;
        case 1:
            self.p_modelabel.text = @"un-connectable";
            currentMode = @"2";
            break;
        case 2:
            self.p_modelabel.text = @"un-connectable";
            currentMode = @"2";
            break;
        case 3:
            self.p_modelabel.text = @"un-connectable";
            currentMode = @"3";
            break;
        default:
            self.p_modelabel.text = @"connectable";
            currentMode = @"0";
            break;
    }
}

-(void)setAdvIntervalFromSlider {
    
    self.p_advintslider.value = roundf(self.p_advintslider.value);
    
    if ([self has16advertisments] == FALSE) {
        switch ((int)self.p_advintslider.value) {
            case 0:
                self.p_advint.text = @"100ms";
                currentInterval = @"0";
                break;
            default:
                self.p_advint.text = @"100ms";
                currentInterval = @"1";
                break;
        }
        
    } else {
        
        switch ((int)self.p_advintslider.value) {
            case 0:
                self.p_advint.text = @"100ms";
                currentInterval = @"0";
                break;
            case 1:
                self.p_advint.text = @"152ms";
                currentInterval = @"1";
                break;
            case 2:
                self.p_advint.text = @"211ms";
                currentInterval = @"2";
                break;
            case 3:
                self.p_advint.text = @"318ms";
                currentInterval = @"3";
                break;
            case 4:
                self.p_advint.text = @"417ms";
                currentInterval = @"4";
                break;
            case 5:
                self.p_advint.text = @"546ms";
                currentInterval = @"5";
                break;
            case 6:
                self.p_advint.text = @"760ms";
                currentInterval = @"6";
                break;
            case 7:
                self.p_advint.text = @"852ms";
                currentInterval = @"7";
                break;
            case 8:
                self.p_advint.text = @"1022ms";
                currentInterval = @"8";
                break;
            case 9:
                self.p_advint.text = @"1280ms";
                currentInterval = @"9";
                break;
            case 10:
                self.p_advint.text = @"2s";
                currentInterval = @"A";
                break;
            case 11:
                self.p_advint.text = @"3s";
                currentInterval = @"B";
                break;
            case 12:
                self.p_advint.text = @"4s";
                currentInterval = @"C";
                break;
            case 13:
                self.p_advint.text = @"5s";
                currentInterval = @"D";
                break;
            case 14:
                self.p_advint.text = @"6s";
                currentInterval = @"E";
                break;
            case 15:
                self.p_advint.text = @"7s";
                currentInterval = @"F";
                break;
        }
    }
    
}


- (void)q_readall_auto {
    
    [[GlimwormBeaconEdit sharedInstance] q_readall_auto];
    
}
- (void)q_readall {
    
    [[GlimwormBeaconEdit sharedInstance] q_readall];

}


#pragma mark - sending queue


- (void)p_set {

    [self writing];
    [self setGBeditValuesFromForm];
    
    
//    // thanks for the formaating of the hex to http://stackoverflow.com/questions/5473896/objective-c-converting-an-integer-to-a-hex-value
//    
//    [self writing];
//    
//    NSString *ibmajor_str_val = [[NSString alloc] initWithFormat:@"%04X", [self.p_major.text intValue]];
//    NSString *ibminor_str_val = [[NSString alloc] initWithFormat:@"%04X", [self.p_minor.text intValue]];
//    
//    NSString *ibmajor_str = [[NSString alloc] initWithFormat:@"AT+MARJ0x%@%@",
//                             [ibmajor_str_val substringWithRange:NSMakeRange(0,2)],
//                             [ibmajor_str_val substringWithRange:NSMakeRange(2,2)]];
//    
//    
//    NSString *ibminor_str = [[NSString alloc] initWithFormat:@"AT+MINO0x%@%@",
//                             [ibminor_str_val substringWithRange:NSMakeRange(0,2)],
//                             [ibminor_str_val substringWithRange:NSMakeRange(2,2)]];
//    
//    
//    NSString *adv = [NSString stringWithFormat:@"AT+ADVI%@",currentInterval];
//    
//    NSString *range = [NSString stringWithFormat:@"AT+POWE%@",currentRange];
//    
//    
//    NSString *name_str = [[NSString alloc] initWithFormat:@"AT+NAME%@           ",
//                          (self.p_name.text.length > 11 ) ? [self.p_name.text.uppercaseString substringWithRange:NSMakeRange(0, 11)] : self.p_name.text.uppercaseString];
//    
//    NSString *pass0 = @"skip";
//    NSString *pass1 = @"skip";
//    NSString *pass2 = @"skip";
//    
//    if (self.p_pincode.text.length == 6) {
//        pass0 = @"AT+TYPE0";
//        pass1 = [NSString stringWithFormat:@"AT+PASS%@",self.p_pincode.text];
//        pass2 = @"AT+TYPE2";
//    } else if (self.p_pincode.text.length == 0) {
//        pass0 = @"AT+TYPE0";
//    }
//    
//    NSString *showbatt = @"AT+BATC1";
//    
//    // format   74278bda-b644-4520-8f0c-720eaf059935
//    //          0        9    14   19   24  28
//    
//    if (self.p_uuid.text.length == 36) {
//        NSString *ib0 = [NSString stringWithFormat:@"AT+IBE0%@",
//                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(0, 8)]
//                         ];
//        
//        NSString *ib1 = [NSString stringWithFormat:@"AT+IBE1%@%@",
//                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(9, 4)],
//                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(14, 4)]
//                         ];
//        
//        NSString *ib2 = [NSString stringWithFormat:@"AT+IBE2%@%@",
//                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(19, 4)],
//                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(24, 4)]
//                         ];
//        
//        NSString *ib3 = [NSString stringWithFormat:@"AT+IBE3%@",
//                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(28, 8)]
//                         ];
//        
//        gbedit.Queue = [NSMutableArray arrayWithObjects:@"clearerror",ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,adv,pass0,pass1,pass2,name_str,showbatt,range,@"checkerror",nil];
//        
//        
//    } else {
//        gbedit.Queue = [NSMutableArray arrayWithObjects:@"clearerror",ibmajor_str,ibminor_str,adv,pass0,pass1,pass2,name_str,showbatt,range,@"checkerror",nil];
//        
//    }
    
    //    Queue = [NSMutableArray arrayWithObjects:ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,nil];
    //    Queue = [NSMutableArray arrayWithObjects:ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,name_str,nil];
    
    [[GlimwormBeaconEdit sharedInstance] p_writeall];
    
    /*
     NSAlert *alert = [[NSAlert alloc] init];
     [alert addButtonWithTitle:ibmajor_str];
     [alert addButtonWithTitle:ibminor_str];
     [alert setMessageText:str];
     [alert setInformativeText:str];
     [alert setAlertStyle:NSWarningAlertStyle];
     [alert runModal];
     */
    
    //    size_t length = (sizeof SET) - 1; //string literals have implicit trailing '\0'
    //    NSData *data = [NSData dataWithBytes:SET length:length];
    //    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    //    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    //    [currentPeripheral.peripheral writeValue:data forCharacteristic:appStatus._currentChar type:CBCharacteristicWriteWithResponse];
    
}

-(void)p_close_window {
    
    
    [[GlimwormBeaconEdit sharedInstance] cleanupconnection];
    
    //    [self stopConfigurationMonitoring];
    //    [self startConfigurationMonitoring];
    
//    [ConfigView endEditing:YES];
//    ConfigView.hidden = YES;
    
    NSString *itemToPassBack = @"Pass this value back to ViewControllerA";
    [self.delegate addItemViewController:self didFinishEnteringItem:itemToPassBack];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    
}

#pragma mark - working views


-(void) working {
    [self showSpinner];
}

-(void) done {
    [self hideSpinner];
}


- (void)writing {
    [self showSpinner];
}

- (void)donewriting {
    [self hideSpinner];
}





- (IBAction)p_reset:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *d_uuid = [defaults objectForKey:@"uuid"];
    NSString *d_major = [defaults objectForKey:@"major"];
    NSString *d_minor = [defaults objectForKey:@"minor"];
    if ([d_uuid isEqualToString:@""]) d_uuid =  @"74278bda-b644-4520-8f0c-720eaf059935";
    if ([d_major isEqualToString:@""]) d_major =  @"1";
    if ([d_minor isEqualToString:@""]) d_minor =  @"1";

    if ([self.p_minor.text isEqualToString:@""]) self.p_minor.text =  d_minor;

    [AppStatus sharedInstance].MIN = [self.p_minor.text intValue];
    [AppStatus sharedInstance].MIN++;
    self.p_major.text = d_major;
    self.p_pincode.text = [AppStatus sharedInstance].LASTPASS;
    self.p_minor.text = [[NSString alloc] initWithFormat:@"%d",[AppStatus sharedInstance].MIN];
    self.p_uuid.text = d_uuid;
    self.p_advintslider.value = 9;
    self.p_name.text = [[NSString alloc] initWithFormat:@"GWB_%@_%@",self.p_major.text,self.p_minor.text];
    self.p_rangeslider.value = 2;
    [self setAdvIntervalFromSlider];
    [self setRangeLabelFromSlider];
    
}

-(void) close_update_window {
    [AppStatus sharedInstance].MIN = [self.p_minor.text intValue];
    [AppStatus sharedInstance].LASTPASS = self.p_pincode.text;
    [[GlimwormBeaconEdit sharedInstance] cleacupcancelledconnection];
//    [self p_close_window];
    
}


- (IBAction)p_update:(id)sender {
    
    [self close_update_window];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) { // UIAlertView with tag 1 detected
        if (buttonIndex == 0)
        {
            NSLog(@"user pressed Button Indexed 0");
            // Any action can be performed here
        }
        else
        {
            NSLog(@"user pressed Button Indexed 1");
            // Any action can be performed here
            [self p_set];
        }
    }
}
- (IBAction)p_sendchanges:(id)sender {

    NSString *mess = @"";
    
    if ([GlimwormBeaconEdit sharedInstance].isCapableOfSettingBatteryLevel) {
        if ([currentBatt isEqualToString:@"1"]) {
            if ([currentInterval intValue] > 3) {
                mess = @"Displaying the battery level in the beacon signal drains the battery at the 211ms advertising interval.  \n\nAre you sure you want to use this combination of values?";
            }
        }
    }
    
    if ([mess isEqualToString:@""]) {
        if ([self.p_pincode.text isEqualToString:@""] == false) {
            if ([GlimwormBeaconEdit sharedInstance].isCapableOfSettingModes) {
                mess = @"Under IOS8 and above connecting to a beacon with a PINCODE can take a few attempts.  \n\nIf you are deploying in a production environment you can set the 'unconnectable' setting and then the beacons will be un-connctable from 60s after conencting battery or USB power.  \n\nThis is the reccommended setting for production installations in which case we reccommend removing the PINCODE";
            }
        }
    }
    
    
    if ([mess isEqualToString:@""]) {
        [self p_set];
        return;
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Warning"
                                                       message: mess
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Continue",nil];
        
        [alert setTag:1];
        [alert show];
    }
}
- (IBAction)p_reload:(id)sender {
    NSLog(@"SSS1");
    if ([AppStatus sharedInstance].currentPeripheral != Nil) {
        NSLog(@"SSS2");
        if([GlimwormBeaconEdit sharedInstance].peripheral && ([[GlimwormBeaconEdit sharedInstance].peripheral state] == CBPeripheralStateConnected )) {
            NSLog(@"SSS3");
            [[GlimwormBeaconEdit sharedInstance] working];
            NSLog(@"SSS4");
            [[GlimwormBeaconEdit sharedInstance] q_readall];
            NSLog(@"SSS5");
        }
    }
}

- (void)cancel_and_close_window {
    [self close_update_window];
    [self done];
}

- (void)cancel_due_to_faulure {
    [self cancel_and_close_window];
}

- (IBAction)connect_cancel_but:(id)sender {
    [self cancel_and_close_window];
}



- (IBAction)write_cancel:(id)sender {
}
- (IBAction)p_advintslider:(id)sender {
    self.p_advint.text = [NSString stringWithFormat:@"%f", self.p_advintslider.value];
    [self setAdvIntervalFromSlider];
    
}

- (IBAction)p_rangeslider:(id)sender {
    self.p_rangelabel.text = [NSString stringWithFormat:@"%f", self.p_rangeslider.value];
    [self setRangeLabelFromSlider];
}

#pragma mark - spinner 
/* spinner */
-(IBAction)didPressSpinnerButton:(id)sender {
    // Load a new spinnerView into the current view
    [SpinnerView loadSpinnerIntoView:self.view];
}

SpinnerView * spinner = nil;
-(void)showSpinner {
    if (spinner == nil) {
        spinner =  [SpinnerView loadSpinnerIntoView:self.view];
        spinner.delegate = self;
    }
}
-(void)hideSpinner {
    if (spinner != nil) {
        [spinner removeSpinner];
        spinner = nil;
    }
}
- (void)SpinnerView:(SpinnerView *)controller cancel:(NSString *)item
{
    NSLog(@"CANCEL CALLBACK !!!!");
    [self cancel_and_close_window];
    
}

#pragma mark - put away the keyboard


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch begin %@",event);
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([p_uuid isFirstResponder] && [touch view] != p_uuid) {
        [p_uuid resignFirstResponder];
    }
    if ([p_major isFirstResponder] && [touch view] != p_major) {
        [p_major resignFirstResponder];
    }
    if ([p_minor isFirstResponder] && [touch view] != p_minor) {
        [p_minor resignFirstResponder];
    }
    if ([p_name isFirstResponder] && [touch view] != p_name) {
        [p_name resignFirstResponder];
    }
    if ([p_pincode isFirstResponder] && [touch view] != p_pincode) {
        [p_pincode resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}




- (IBAction)p_modeslider:(id)sender {
    [self setModeSliderFromSlider];
    
}
- (IBAction)p_battslider:(id)sender {
    [self setBatterySliderFromSlider];
}
@end
