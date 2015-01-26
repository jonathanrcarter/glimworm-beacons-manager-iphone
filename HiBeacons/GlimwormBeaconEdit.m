@import CoreLocation;
@import CoreBluetooth;
#import "BTDeviceModel.h"
#import "GlimwormBeaconEdit.h"
#import "AppStatus.h"
#import "GBDefaults.h"

@interface GlimwormBeaconEdit()
@end


@implementation GlimwormBeaconEdit

@synthesize delegate;
@synthesize currentfirmware, incoming_uuid, BTYPE, PDATE, PDATELONG, q_error;
@synthesize p_advintslider_value, p_battlevel_text, p_firmware_text, p_major_text, p_measuredpower_text,p_battslider_value;
@synthesize p_minor_text, p_name_text, p_pdate_text, p_pincode_text, p_rangeslider_value, p_uuid_text, p_modeslider_value;
@synthesize Queue;
@synthesize currentChar, currentcommand, peripheral;
@synthesize peripheralisconnected, peripheralisconnectedButNotRead, peripheralisconnecting;
@synthesize connectActive;
@synthesize currentInterval, currentRange, currentMode, currentBatt;


+ (GlimwormBeaconEdit *)sharedInstance {
    static GlimwormBeaconEdit *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (id)init {
    if (self = [super init]) {
        currentfirmware = @"";
        incoming_uuid = @"00000000-0000-0000-0000-000000000000";
        BTYPE = @"";
        PDATE = @"";
        PDATELONG = 0;
        q_error = NO;

        p_firmware_text = @"";
        p_pdate_text = @"";
        p_major_text = @"";
        p_minor_text = @"";
        p_uuid_text = @"";
        p_name_text = @"";
        p_pincode_text = @"";
        p_measuredpower_text = @"";
        p_rangeslider_value = 0;
        p_advintslider_value = 0;
        p_modeslider_value = 0;
        p_battslider_value = 0;
        p_battlevel_text = @"";
    }
    return self;
}

#pragma mark - Callbacks

- (void) working {
    [self.delegate GlimwormBeaconEdit:self working: nil];
}
- (void) writing {
    [self.delegate GlimwormBeaconEdit:self writing: nil];
}

- (void) done {
    [self.delegate GlimwormBeaconEdit:self done: nil];
}
- (void) donewriting {
    [self.delegate GlimwormBeaconEdit:self donewriting: nil];
}
- (void) redraw_form {
    [self.delegate GlimwormBeaconEdit:self doneRedrawForm: nil];
}

- (void) p_close_window {
    [self.delegate GlimwormBeaconEdit:self p_close_window: nil];
}

- (void) connectingStringDisplay:(NSString *)S {
    [self.delegate GlimwormBeaconEdit:self connectingStringDisplay: S];
}

- (void) cancel_and_close_window {

    [self cancelLookForPeripheralServices];
    
    if ([AppStatus sharedInstance].currentPeripheral != Nil) {
        if(peripheral && ([peripheral state] == CBPeripheralStateConnecting )) {
            [[AppStatus sharedInstance].manager cancelPeripheralConnection:peripheral];
            peripheralisconnecting = NO;
            peripheralisconnected = NO;
            peripheralisconnectedButNotRead = NO;
        }
    }
    connectActive = NO;
    Queue = [NSMutableArray arrayWithObjects:nil];
    
    [self.delegate GlimwormBeaconEdit:self cancel_and_close_window: nil];
}

- (void)cancel_due_to_faulure {
    [self cancel_and_close_window];
}

- (IBAction)connect_cancel_but:(id)sender {
    [self cancel_and_close_window];
}



#pragma mark - utility conversions
- (NSString *) uuidToString:(CFUUIDRef)UUID {
    NSString *retval = CFBridgingRelease(CFUUIDCreateString(NULL, UUID));
    return retval;
}

- (NSString *) hex2dec:(NSString *)HEX {
    
    unsigned int ibmajor;
    NSScanner* scanner = [NSScanner scannerWithString:HEX];
    [scanner scanHexInt:&ibmajor];
    NSString *dec_string = [[NSString alloc] initWithFormat:@"%u", ibmajor];
    return dec_string;
}

- (NSString *) hex2dec_min256:(NSString *)HEX {
    
    unsigned int ibmajor;
    NSScanner* scanner = [NSScanner scannerWithString:HEX];
    [scanner scanHexInt:&ibmajor];
    NSString *dec_string = [[NSString alloc] initWithFormat:@"%u", (256 - ibmajor)];
    return dec_string;
}

#pragma mark - just some necessary stuff

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)pm
{
    NSLog(@"peripheral state update %d",pm.state);
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"central state update %d",central.state);
}


#pragma mark - Configuration Popup window


/**
 
 connect to a peripheral
 
 */

-(void)tryToConnect {
    [[AppStatus sharedInstance].manager connectPeripheral:[AppStatus sharedInstance].currentPeripheral.peripheral
                                                  options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @NO,
                                                            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @NO,
                                                            CBConnectPeripheralOptionNotifyOnNotificationKey: @NO}];
    connectActive = YES;

}
-(void)tryToLookForServies {
    lookForPeripheralServicesCounter = 0;
    [self lookForPeripheralServices:[AppStatus sharedInstance].currentPeripheral.peripheral];
}
-(BOOL)connect {
    
    
    NSLog(@"gb connect 01");
    if ([AppStatus sharedInstance].currentPeripheral != Nil) {
        NSLog(@"gb connect 02");
        

        NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:[[[AppStatus sharedInstance] currentPeripheral] UUID]];
        NSArray *peripheralArray = [[[AppStatus sharedInstance] manager] retrievePeripheralsWithIdentifiers:@[nsUUID]];
        NSLog(@"MCS %@",peripheralArray);
        
        if ([peripheralArray count] > 0) {
            NSLog(@"found");
            peripheralisconnected = false;
            peripheralisconnecting = true;
            connectActive = true;
            [AppStatus sharedInstance].currentPeripheral.peripheral = [peripheralArray objectAtIndex:0];
            [AppStatus sharedInstance].currentPeripheral.peripheral.delegate = self;
            [self tryToConnect];
            [self tryToLookForServies];
            [self manageConnectionStateStart];
            return true;
        }
        
        
        
        if (!peripheralisconnected && !peripheralisconnecting) {
            NSLog(@"gb connect 03");

            if (!connectActive) {
                NSLog(@"gb connect 04a");
                [AppStatus sharedInstance].manager.delegate = self;
                NSLog(@"gb connect 04b");
                [AppStatus sharedInstance].currentPeripheral.peripheral.delegate = self;
                NSLog(@"gb connect 04c");
                [self tryToConnect];
//                [[AppStatus sharedInstance].manager connectPeripheral:[AppStatus sharedInstance].currentPeripheral.peripheral options:nil];
//                [[AppStatus sharedInstance].manager connectPeripheral:[AppStatus sharedInstance].currentPeripheral.peripheral
//                                              options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @NO,
//                                                        CBConnectPeripheralOptionNotifyOnDisconnectionKey: @NO,
//                                                        CBConnectPeripheralOptionNotifyOnNotificationKey: @NO}];

            
                
                NSLog(@"gb connect 04d");
//                connectActive = YES;
                NSLog(@"gb connect 04e");
                [self tryToLookForServies];
                //[self lookForPeripheralServices:[AppStatus sharedInstance].currentPeripheral.peripheral];

                [self manageConnectionStateStart];
                
                return true;
            }
        }
    }
    return false;
    /*
     NSLog(@"DIDSELECTROWATINDEXPATH %@", btm);
     NSLog(@"DIDSELECTROWATINDEXPATH %@", btm.ib_uuid);
     NSLog(@"DIDSELECTROWATINDEXPATH %@", btm.ib_major);
     NSLog(@"DIDSELECTROWATINDEXPATH %@", btm.ib_minor);
     NSLog(@"DIDSELECTROWATINDEXPATH %@", btm.name);
     
     self.p_uuid.text = btm.ib_uuid;
     self.p_major.text = btm.ib_major;
     self.p_minor.text = btm.ib_minor;
     */
//    self.p_uuid.layer.borderColor = [[UIColor grayColor]CGColor];
    
}

static const NSTimeInterval kLXCBConnectingTimeout = 10.0;

- (void)startConnectionTimeoutMonitor:(CBPeripheral *)aperipheral {
    [self cancelConnectionTimeoutMonitor:aperipheral];
    [self performSelector:@selector(connectionDidTimeout:)
               withObject:peripheral
               afterDelay:kLXCBConnectingTimeout];
}

- (void)cancelConnectionTimeoutMonitor:(CBPeripheral *)aperipheral {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(connectionDidTimeout:)
                                               object:aperipheral];
}

- (void)connectionDidTimeout:(CBPeripheral *)aperipheral {
    [[AppStatus sharedInstance].manager cancelPeripheralConnection:aperipheral];
}

/**

 did connect to a peripheral
 
 */

CBPeripheral *tempPeripheral = nil;

-(void) cancelLookForPeripheralServices {
    if (tempPeripheral != nil) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(lookForPeripheralServices:)
                                                   object:tempPeripheral];
    }
    tempPeripheral = nil;
    
}

bool manageConnectionStateRunning = false;
bool manageConnectionStateDebug = false;

- (void) manageConnectionStateStart {
    if (manageConnectionStateRunning == false) {
        manageConnectionStateRunning = true;
        [self manageConnectionState];
    }
}

- (void) manageConnectionState {
    
    if (manageConnectionStateDebug) NSLog(@"gb GBE MCS (tp: %@)",[AppStatus sharedInstance].currentPeripheral.peripheral);
    


    NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:[[[AppStatus sharedInstance] currentPeripheral] UUID]];
    NSArray *peripheralArray = [[[AppStatus sharedInstance] manager] retrievePeripheralsWithIdentifiers:@[nsUUID]];
    if (manageConnectionStateDebug)  NSLog(@"MCS %@",peripheralArray);

    NSArray *array = [@"FFE0,FFE1,ffe0,ffe1" componentsSeparatedByString:@","];
    if (manageConnectionStateDebug)  NSLog(@"MCS %@",[[[AppStatus sharedInstance] manager]retrieveConnectedPeripheralsWithServices:array]);

    
//    NSLog(@"MCS %@",[[[AppStatus sharedInstance] manager]retrievePeripheralsWithIdentifiers:array]);
//    NSLog(@"MCS %@",[[[AppStatus sharedInstance] manager]retrieveConnectedPeripheralsWithServices:array]);
    
    
    
    if ([AppStatus sharedInstance].currentPeripheral.peripheral != nil) {
        if (manageConnectionStateDebug) NSLog(@"gb GBE MCS (p:d: %@ )", [[AppStatus sharedInstance].currentPeripheral.peripheral description]);
        if (manageConnectionStateDebug) NSLog(@"gb GBE MCS (p:s:d: %@ )", [[[AppStatus sharedInstance].currentPeripheral.peripheral services] description]);
    }
    [self performSelector:@selector(manageConnectionState) withObject:nil afterDelay:1.0];
}


int lookForPeripheralServicesCounter = 0;

- (void) lookForPeripheralServices:(CBPeripheral *)aPeripheral {
    
//    NSLog(@"gb GBE connectED-delay (name: %@ )", [aPeripheral name]);
    NSLog(@"gb GBE connectED-delay (description: %@ )", [aPeripheral description]);
//    NSLog(@"gb GBE connectED-delay (state: %d )", [aPeripheral state]);
    NSLog(@"gb GBE connectED-delay (appstate: %@ )", [AppStatus sharedInstance].currentStatus);
    lookForPeripheralServicesCounter++;
    NSLog(@"gb GBE connectED-delay (counter: %d )", lookForPeripheralServicesCounter);
    

    [self cancelLookForPeripheralServices];
    
    if ([[AppStatus sharedInstance].currentStatus isEqualToString:@"active"]) {
        if (aPeripheral.state == 0) {
            NSLog(@"gb GBE connectED-delay :: NOT CONNECTED ");
            if (lookForPeripheralServicesCounter > 10) {
                [self tryToConnect];
                [self tryToLookForServies];
                return;
            }
        } else if (aPeripheral.state == 1) {
            NSLog(@"gb GBE connectED-delay :: CONNECTING ");
            if (lookForPeripheralServicesCounter > 10) {
                [self tryToConnect];
                [self tryToLookForServies];
                return;
            }
        } else if (aPeripheral.state == 2) {
            NSLog(@"gb GBE connectED-delay :: CONNECTED ");
            connectActive = NO;
            peripheralisconnected = YES;
            peripheralisconnecting = NO;
            peripheralisconnectedButNotRead = YES;
            [aPeripheral setDelegate:self];
            [aPeripheral discoverServices:nil];
            return;
        }
    }

    NSLog(@"gb GBE connectED-delay (** TRY AGAIN IN 2s)");

    tempPeripheral = aPeripheral;
    [self performSelector:@selector(lookForPeripheralServices:) withObject:aPeripheral afterDelay:0.5];
    
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    NSLog(@"gb GBE FAILED(p: %@ )", aPeripheral);
    NSLog(@"gb GBE FAILED(e: %@ )", error);
    [self cancelConnectionTimeoutMonitor:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
//    NSLog(@"gb GBE connectED (name: %@ )", [aPeripheral name]);
    NSLog(@"gb GBE connectED (description: %@ )", [aPeripheral description]);
    [self cancelConnectionTimeoutMonitor:peripheral];
    
    //    NSLog(@"gb GBE connectED (state: %d )", [aPeripheral state]);

//    if (aPeripheral.state != 0) {
//        tempPeripheral = aPeripheral;
//        [self performSelector:@selector(lookForPeripheralServices:) withObject:aPeripheral afterDelay:2.0];
//    } else {
//        NSLog(@"gb GBE connectED NOT PERFORMING SELECTOR");
//        
//    }
//
//
//    connectActive = NO;
//    peripheralisconnected = YES;
//    peripheralisconnecting = NO;
//    peripheralisconnectedButNotRead = YES;
//    [aPeripheral setDelegate:self];
//    [aPeripheral discoverServices:nil];
}






//
//-(void) activate:(NSNotification *)pNotification {
//    NSLog(@"application activate ");
//    if (peripheralIsConnectedButNotRead) {
//        NSLog(@"application activate READ");
//        [self q_readall];
//    }
//}


/**

 did discover services
 
 */

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {

    [self cancelLookForPeripheralServices];
    
    NSLog(@"gb NAT GBE peripheral servicesDISCOVERED (n: %@ )", [aPeripheral name]);
    NSLog(@"gb NAT GBE peripheral servicesDISCOVERED (d: %@ )", [aPeripheral description]);
    NSLog(@"gb NAT GBE peripheral servicesDISCOVERED (s: %@ )", [aPeripheral services]);
    if ([aPeripheral state] != 2) {
        NSLog(@"gb NAT GBE peripheral Discovered service but state is disconnected");
        [self tryToConnect];
        [self tryToLookForServies];
        
    }
    if ([aPeripheral services] == nil) {
        NSLog(@"gb NAT GBE peripheral Discovered service TRYAGAIN NULL");
        [aPeripheral discoverServices:nil];
        return;
    }
    if ([aPeripheral services].count == 0) {
        NSLog(@"gb NAT GBE peripheral Discovered service TRYAGAIN ZEROLENGTH");
        [aPeripheral discoverServices:nil];
        return;
    }
    for (CBService *service in aPeripheral.services) {
        NSLog(@"gb NAT GBE peripheral Discovered service s: %@", service);
        NSLog(@"gb NAT GBE peripheral Discovered service u: %@", service.UUID);
        NSLog(@"gb NAT GBE peripheral Discovered service d: %@", service.description);
        
        /* connect to serial bluetooth */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
        {
            NSLog(@"gb NAT GBE peripheral Discovered service FFE0 **n lookfor characteristics **");
            [aPeripheral discoverCharacteristics:nil forService:service];
        }
    }
}


/**
 
 did discover characteristics for a peripheral
 
 */


- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"gb NAT GBE peripheral characteristicsDISCOVERED (s: %@ )", [service description]);
    NSLog(@"gb NAT GBE peripheral characteristicsDISCOVERED (c: %@ )", [service characteristics]);

    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
    {
        NSLog(@"gb NAT GBE peripheral characteristicsDISCOVERED SUCCESS 01");
        for (CBCharacteristic *aChar in service.characteristics)
        {
            NSLog(@"gb NAT GBE peripheral characteristicsDISCOVERED (aCHAR: %@ )", [aChar description]);

            /* Set notification on heart rate measurement */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
            {
                NSLog(@"gb Found a serial connectionCharacteristic, properties %@", aChar.UUID);
                
                //                [p_name_ml setStringValue:@"Found a serial connectionCharacteristic, enquiring about name"];
                NSLog(@"gb serial 01");
                
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"gb serial 02");
                currentChar = aChar;
                NSLog(@"gb serial 03");
                NSLog(@"gb serial 03 char:%@",[aChar description]);
                peripheral = aPeripheral;
                NSLog(@"gb serial 04");
                NSLog(@"gb serial 04 per:%@",[peripheral description]);
                [self working];
                NSLog(@"gb serial 05");
                [self performSelector:@selector(q_readall_auto) withObject:self afterDelay:3.0];
                NSLog(@"gb serial 06");
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"gb -- didWriteValueForCharacteristic");
    NSLog(@"gb -- didWriteValueForCharacteristic err %@", error);
    NSLog(@"gb -- didWriteValueForCharacteristic characteristic %@", characteristic);
    NSLog(@"gb -- didWriteValueForCharacteristic characteristic.value %@", characteristic.value);
    NSLog(@"gb -- didWriteValueForCharacteristic characteristic.UUID %@", characteristic.UUID);
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
    {
        NSLog(@"gb -- didWriteValueForCharacteristic *MATHCHED* ");
        
        if( (characteristic.value)  || !error )
        {
            NSLog(@"gb wrote characteristic val: %@ , %@", characteristic.value, characteristic.UUID);
            //            [p_log setStringValue: [[NSString alloc] initWithFormat:@"written : %@", characteristic.value] ];
        } else {
            NSLog(@"gb -- didWriteValueForCharacteristic err %@", error.debugDescription);
            NSLog(@"gb -- didWriteValueForCharacteristic err %@", error.description);
            
        }
    }
    
}

- (BOOL) has16advertisments {
    if ([currentfirmware isEqualToString:@"V517"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V518"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V519"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V520"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V521"]) return FALSE;
    if ([currentfirmware isEqualToString:@"V522"]) return FALSE;
    return TRUE;
}

- (BOOL) isUSBBeacon {
    if ([BTYPE isEqualToString:@"000300030003"]) return TRUE;
    return FALSE;
}
- (BOOL) isFirstBeaconType {
    if ([BTYPE isEqualToString:@"000100010001"]) return TRUE;
    return FALSE;
}
- (BOOL) isCapableOfSettingModes {
    if ([BTYPE isEqualToString:@"000100020001"]) return TRUE;
    if ([BTYPE isEqualToString:@"000300030003"]) return TRUE;
    return FALSE;
}
- (BOOL) isCapableOfSettingBatteryLevel {
    if ([BTYPE isEqualToString:@"000100020001"]) return TRUE;
    if ([BTYPE isEqualToString:@"000300030003"]) return TRUE;
    return FALSE;
}


/**
 static variables for queue management
 */
static const NSTimeInterval kLXCBRequestTimeout = 1.0;



- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"gb -- didUpdateValueForCharacteristic");
    [self cancelRequestTimeoutMonitor:characteristic];
    
    /* Updated value for heart rate measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
    {
        if( (characteristic.value)  || !error )
        {
            /* Update UI with heart rate data */
            NSLog(@"gb updated characteristic val: %@ , %@, error %@", characteristic.value, characteristic.UUID, error);
            
            NSString *str=[[NSString alloc] initWithBytes:characteristic.value.bytes length:characteristic.value.length encoding:NSUTF8StringEncoding];
            NSLog(@"gb retval %@", str);
            
            //NSString *logmessage = [[NSString alloc] initWithFormat:@"'%@' : '%@'", currentcommand, str];
            
            
            NSLog(@"gb currentcommand %@", currentcommand);
            NSLog(@"gb currentcommand:retval %@", str);
            peripheralisconnecting = NO;
            
            if ([currentcommand isEqualToString:@"GB+BTYPE"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                NSLog(@"gb returns %@",str);
                if (array.count > 1) {
                    BTYPE = array[1];
                } else {
                    NSLog(@"gb ERR returns %@",str);
                }
            }
            
            if ([currentcommand isEqualToString:@"GB+PDATE"]) {
                NSLog(@"gb returns %@",str);
                if (str.length > 1) {
                    PDATE = [[NSString alloc] initWithFormat:@"%@", str];
                    PDATELONG = [str longLongValue];
                    p_pdate_text = PDATE;
                } else {
                    PDATELONG = 0;
                    PDATE = @"";
                    p_pdate_text = @"";
                    NSLog(@"gb ERR returns %@",str);
                }
            }
            
            if ([currentcommand isEqualToString:@"AT+VERS?"]) {
                
                
                peripheralisconnectedButNotRead = NO;
                
                NSArray *array = [str componentsSeparatedByString:@" "];
                if (array.count > 1) {
                    p_firmware_text = array[1];
                    currentfirmware = [[NSString alloc] initWithFormat:@"%@", array[1]];
                    
                    if ([currentfirmware isEqualToString:@"V517"]) {
                        // dvert 0 = 100 , 1 = 1280
                    } else if ([currentfirmware isEqualToString:@"V518"]) {
                    } else if ([currentfirmware isEqualToString:@"V519"]) {
                    } else if ([currentfirmware isEqualToString:@"V520"]) {
                    } else if ([currentfirmware isEqualToString:@"V521"]) {
                    } else if ([currentfirmware isEqualToString:@"V522"]) {
                    } else if ([currentfirmware isEqualToString:@"V523"]) {
                    } else if ([currentfirmware isEqualToString:@"V524"]) {
                    } else if ([currentfirmware isEqualToString:@"V525"]) {
                    } else if ([currentfirmware isEqualToString:@"V526"]) {
                    }
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
                
            }
            
            if ([currentcommand isEqualToString:@"AT+MARJ?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                p_major_text = [self hex2dec:array[1]];
            }
            if ([currentcommand isEqualToString:@"AT+MINO?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                p_minor_text = [self hex2dec:array[1]];
            }
            
            if ([currentcommand isEqualToString:@"AT+IBE0?"]) {
                NSArray *array = [str componentsSeparatedByString:@"x"];
                incoming_uuid = @"00000000-0000-0000-0000-000000000000";
                if (array.count > 1) {
                    incoming_uuid = [NSString stringWithFormat:@"%@%@",
                                     array[1],
                                     [incoming_uuid substringWithRange:NSMakeRange(8,28)]
                                     ];
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            if ([currentcommand isEqualToString:@"AT+IBE1?"]) {
                NSArray *array = [str componentsSeparatedByString:@"x"];
                if (array.count > 1 && [incoming_uuid length] == 36) {
                    incoming_uuid = [NSString stringWithFormat:@"%@-%@-%@-%@",
                                     [incoming_uuid substringWithRange:NSMakeRange(0,8)],
                                     [array[1] substringWithRange:NSMakeRange(0,4)],
                                     [array[1] substringWithRange:NSMakeRange(4,4)],
                                     [incoming_uuid substringWithRange:NSMakeRange(19,17)]
                                     ];
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            if ([currentcommand isEqualToString:@"AT+IBE2?"]) {
                NSArray *array = [str componentsSeparatedByString:@"x"];
                if (array.count > 1 && [incoming_uuid length] == 36) {
                    incoming_uuid = [NSString stringWithFormat:@"%@-%@-%@%@",
                                     [incoming_uuid substringWithRange:NSMakeRange(0,18)],
                                     [array[1] substringWithRange:NSMakeRange(0,4)],
                                     [array[1] substringWithRange:NSMakeRange(4,4)],
                                     [incoming_uuid substringWithRange:NSMakeRange(28,8)]
                                     ];
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            if ([currentcommand isEqualToString:@"AT+IBE3?"]) {
                NSArray *array = [str componentsSeparatedByString:@"x"];
                if (array.count > 1 && [incoming_uuid length] == 36) {
                    incoming_uuid = [NSString stringWithFormat:@"%@%@",
                                     [incoming_uuid substringWithRange:NSMakeRange(0,28)],
                                     [array[1] substringWithRange:NSMakeRange(0,8)]
                                     ];
                    p_uuid_text = incoming_uuid;
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            
            
            if ([currentcommand isEqualToString:@"AT+NAME?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    NSLog(@"gb name array %@",array[1]);
                    p_name_text = array[1];
                    NSLog(@"gb p_name_text %@",p_name_text);
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            if ([currentcommand isEqualToString:@"AT+PASS?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    NSLog(@"gb pass array %@",array[1]);
                    p_pincode_text = array[1];
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            if ([currentcommand isEqualToString:@"AT+TYPE?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    int val = [array[1] intValue];
                    if (val == 0) {
                        p_pincode_text = @"";
                    }
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            
            if ([currentcommand isEqualToString:@"AT+MEA??"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                NSLog(@"gb measured power : %@",[self hex2dec_min256:array[1]]);
                p_measuredpower_text = [self hex2dec_min256:array[1]];
                
            }
            if ([currentcommand isEqualToString:@"AT+ADTY?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                int val = [array[1] intValue];
                NSLog(@"gb mode %@",array[1]);
                p_modeslider_value = val;
            }
            
            
            if ([currentcommand isEqualToString:@"AT+POWE?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                NSLog(@"gb array %@",array[1]);
                int val = [array[1] intValue];
                p_rangeslider_value = val;
//                [self setRangeLabelFromSlider];
                
                if (val == 0) {
                    //                    p5m.state = 0;
                    //                    p50m.state = 0;
                    //                    p100m.state = 0;
                }
                if (val == 1) {
                    //                    p5m.state = 1;
                    //                    p50m.state = 0;
                    //                    p100m.state = 0;
                }
                if (val == 2) {
                    //                    p5m.state = 0;
                    //                    p50m.state = 1;
                    //                    p100m.state = 0;
                }
                if (val == 3) {
                    //                    p5m.state = 0;
                    //                    p50m.state = 0;
                    //                    p100m.state = 1;
                }
            }
            
            if ([currentcommand isEqualToString:@"AT+ADVI?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    
                    NSLog(@"gb adv array %@",array[1]);
//                    int val = [array[1] intValue];
                    NSString *Val = array[1];
                    
                    //                [self clearadvertisingbuttonstates];
                    
                    if ([self has16advertisments] == FALSE) {
                        
                        if ([Val isEqualToString:@"0"]) p_advintslider_value = 0;
                        if ([Val isEqualToString:@"1"]) p_advintslider_value = 15;
                    } else {
                        if ([Val isEqualToString:@"0"]) p_advintslider_value = 0;
                        if ([Val isEqualToString:@"1"]) p_advintslider_value = 1;
                        if ([Val isEqualToString:@"2"]) p_advintslider_value = 2;
                        if ([Val isEqualToString:@"3"]) p_advintslider_value = 3;
                        if ([Val isEqualToString:@"4"]) p_advintslider_value = 4;
                        if ([Val isEqualToString:@"5"]) p_advintslider_value = 5;
                        if ([Val isEqualToString:@"6"]) p_advintslider_value = 6;
                        if ([Val isEqualToString:@"7"]) p_advintslider_value = 7;
                        if ([Val isEqualToString:@"8"]) p_advintslider_value = 8;
                        if ([Val isEqualToString:@"9"]) p_advintslider_value = 9;
                        if ([Val isEqualToString:@"A"]) p_advintslider_value = 10;
                        if ([Val isEqualToString:@"B"]) p_advintslider_value = 11;
                        if ([Val isEqualToString:@"C"]) p_advintslider_value = 12;
                        if ([Val isEqualToString:@"D"]) p_advintslider_value = 13;
                        if ([Val isEqualToString:@"E"]) p_advintslider_value = 14;
                        if ([Val isEqualToString:@"F"]) p_advintslider_value = 15;
                    }
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            
            if ([currentcommand isEqualToString:@"AT+BATC?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                int val = [array[1] intValue];
                NSLog(@"gb batc %@",array[1]);
                p_battslider_value = val;
            }
            
            if ([currentcommand isEqualToString:@"AT+BATT?"]) {
                
                NSLog(@"gb batt currentcommand MATCHED");
                
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    
                    double dv = [array[1] doubleValue];
                    NSLog(@"gb bat array %@",array[1]);
                    NSLog(@"gb bat array intvalue %ld",(long)[array[1] integerValue]);
                    NSLog(@"gb bat array intvalue %d",[array[1] intValue]);
                    NSLog(@"gb bat array intvalue %f",dv);
                    p_battlevel_text = [NSString stringWithFormat:@"Battery :%d %%", [array[1] intValue]];
                } else {
                    NSLog(@"gb ERR returns %@",str);
                    q_error = YES;
                }
            }
            
//            [self q_next];
            [self performSelector:@selector(q_next) withObject:self afterDelay:0.2];
            
        }
    }
}

#pragma mark - request timeout code
// thanks to https://github.com/liquidx/CoreBluetoothPeripheral/blob/48ff54b31b41e5ca01fae496e3548209f6da9e8b/CoreBluetoothOSXCentral/CoreBluetoothOSXCentral/LXCBCentralClient.m


- (void)startRequestTimeout:(CBCharacteristic *)characteristic {
    @try {
        [self cancelRequestTimeoutMonitor:characteristic];
        [self performSelector:@selector(requestDidTimeout:)
                   withObject:characteristic
                   afterDelay:kLXCBRequestTimeout];
        //NSLog(@"gb startRequestTimeout : timeout spawned");
    }
    @catch (NSException * e) {
        //NSLog(@"gb startRequestTimeout : Exception: %@", e);
    }
    @finally {
        //NSLog(@"gb startRequestTimeout : finally");
    }
}

- (void)cancelRequestTimeoutMonitor:(CBCharacteristic *)characteristic {
    @try {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(requestDidTimeout:)
                                                   object:characteristic];
    }
    @catch (NSException * e) {
        //NSLog(@"gb cancelRequestTimeout : Exception: %@", e);
    }
    @finally {
        //NSLog(@"gb cancelRequestTimeout : finally");
    }
}

- (void)requestDidTimeout:(CBCharacteristic *)characteristic {
    NSLog(@"gb requestDidTimeout: %@", characteristic);
    [self q_next];
    //    NSError *error = [[self class] errorWithDescription:@"Unable to request data from BTLE device."];
    //    [self.delegate centralClient:self
    //        requestForCharacteristic:characteristic
    //                         didFail:error];
    //    [self.connectedPeripheral setNotifyValue:NO
    //                           forCharacteristic:characteristic];
}


#pragma mark - send methods
- (void)q_readall_auto {
    
    
    //
    //    if ([Status.currentStatus isEqualToString:@"active"]) {
    NSLog(@"q_readall_auto : application was in state [%@]",[AppStatus sharedInstance].currentStatus);
    
    if ([[AppStatus sharedInstance].currentStatus isEqualToString:@"active"]) {
        [self q_readall];
    } else {
        NSLog(@"q_readall_auto : application was NOT active");
    }
    
}
- (void)q_readall {
    
    
    NSString *get0 = [[NSString alloc] initWithFormat:@"GB+BTYPE"];
    NSString *get0a = [[NSString alloc] initWithFormat:@"GB+PDATE"];
    NSString *get1 = [[NSString alloc] initWithFormat:@"AT+VERS?"];
    NSString *get2 = [[NSString alloc] initWithFormat:@"AT+BATT?"];
    NSString *get2a = [[NSString alloc] initWithFormat:@"AT+BATC?"];
    NSString *get3 = [[NSString alloc] initWithFormat:@"AT+ADVI?"];
    NSString *get4 = [[NSString alloc] initWithFormat:@"AT+POWE?"]; // 0 1 2 3 2 = std
    NSString *get4a = [[NSString alloc] initWithFormat:@"AT+MEA??"]; // 0 1 2 3 2 = std
    NSString *get4b = [[NSString alloc] initWithFormat:@"AT+ADTY?"]; // 0 1 2 3 2 = std
    NSString *get5 = [[NSString alloc] initWithFormat:@"AT+PASS?"]; // 2 PIN
    NSString *get6 = [[NSString alloc] initWithFormat:@"AT+MARJ?"]; // 2 PIN
    NSString *get7 = [[NSString alloc] initWithFormat:@"AT+MINO?"]; // 2 PIN
    NSString *get8 = [[NSString alloc] initWithFormat:@"AT+IBE0?"]; // 2 PIN
    NSString *get9 = [[NSString alloc] initWithFormat:@"AT+IBE1?"]; // 2 PIN
    NSString *get10 = [[NSString alloc] initWithFormat:@"AT+IBE2?"]; // 2 PIN
    NSString *get11 = [[NSString alloc] initWithFormat:@"AT+IBE3?"]; // 2 PIN
    NSString *get12 = [[NSString alloc] initWithFormat:@"AT+TYPE?"]; // 2 PIN
    NSString *get13 = [[NSString alloc] initWithFormat:@"AT+NAME?"]; // 2 PIN
    
    
    //    NSString *get6 = [[NSString alloc] initWithFormat:@"AT+MEAS?"]; // Value
    
    Queue = [NSMutableArray arrayWithObjects:@"clearerror",get0,get0a,get1,get2,get2a,get3,get4,get4a,get4b,get5,get6,get7,get8,get9,get10,get11,get12,get13,@"checkerror",@"done",nil];
    
    NSLog(@"\ngb ----- END GET VALUE  ----- ");
    [self q_next];
}

- (void)q_next {
    
    // than you to https://github.com/mattjgalloway/MJGFoundation/blob/master/Source/Model/MJGStack.m for the queue code
    
    NSLog(@"\ngb ----- v next ----- ");
    NSLog(@"gb Q_NEXT");
    NSLog(@"gb Q_NEXT CNT %lu ",(unsigned long)Queue.count);
    
    if (Queue.count > 0) {
        
        NSString *q_str = [Queue objectAtIndex:0];
        [Queue removeObjectAtIndex:(0)];
        NSLog(@"gb Q_NEXT STR %@", q_str);

        [self connectingStringDisplay: q_str];
        
        if ([q_str isEqualToString:@"close"]) {
            currentcommand = @"";
            [self p_close_window];
            return;
        }
        if ([q_str isEqualToString:@"done"]) {
            currentcommand = @"";
            [self redraw_form];
            [self q_next];
            return;
        }
        if ([q_str isEqualToString:@"checkerror"]) {
            if (q_error == YES) {
                
                UILocalNotification *notification = [UILocalNotification new];
                
                // Notification details
                notification.alertBody = [NSString stringWithFormat:@"There was an error GBEDIT"];
                notification.alertAction = NSLocalizedString(@"View Details", nil);
                notification.soundName = UILocalNotificationDefaultSoundName;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
            }
            [self q_next];
            return;
        }
        if ([q_str isEqualToString:@"clearerror"]) {
            q_error = NO;
            PDATELONG = 0;
            PDATE = @"";
            p_pdate_text = @"";
            [self q_next];
            return;
        }
        if ([q_str isEqualToString:@"skip"]) {
            [self q_next];
            return;
        }
        
        
        /* skip this if the versions are too old */
        /* v517
         1. Add AT+IBEA command (Open close iBeacon)
         2. Add AT+MARJ command (Query/Set iBeacon marjor)
         3. Add AT+MINO command (Query/Set iBeacon minor)
         */
        
        if ([currentfirmware isEqualToString:@"V517"] && [currentcommand isEqualToString:@"AT+MEA??"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V518"] && [currentcommand isEqualToString:@"AT+MEA??"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V519"] && [currentcommand isEqualToString:@"AT+MEA??"]) {
            [self q_next];
            return;
        }
        
        if ([currentfirmware isEqualToString:@"V517"] && [currentcommand isEqualToString:@"AT+MEA??"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V518"] && [currentcommand isEqualToString:@"AT+MEA??"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V519"] && [currentcommand isEqualToString:@"AT+MEA??"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V520"] && [currentcommand isEqualToString:@"AT+MEA??"]) {
            [self q_next];
            return;
        }
        
        
        currentcommand = [[NSString alloc] initWithFormat:@"%@", q_str];
        
        //NSData *data = [q_str dataUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [q_str dataUsingEncoding:[NSString defaultCStringEncoding]];
        
        //        NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        //        [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
        

        if (currentChar == nil) {
            NSLog(@"gb Q_NEXT CANCEL currentChar = null");
            [self cancel_due_to_faulure];
            [self q_next];
            return;
        }
        NSLog(@"gb PERIPHERALSTATE %d",[peripheral state]);
        if(peripheral && ([peripheral state] != CBPeripheralStateConnected )) {
            NSLog(@"gb Q_NEXT CANCEL due to failure , state is not = %d",CBPeripheralStateConnected);
            [self cancel_due_to_faulure];
            return;
        }
        
        NSLog(@"gb Q_NEXT ON TO THE COMMAND WRITE");
        [peripheral writeValue:data forCharacteristic:currentChar type:CBCharacteristicWriteWithoutResponse];
        NSLog(@"gb Q_NEXT ON TO THE COMMAND SET TIMEOUT");
        [self startRequestTimeout:currentChar];
        NSLog(@"gb Q_NEXT ON TO THE COMMAND END");
    } else {
        currentcommand = @"";
        [self connectingStringDisplay: @""];
        [self donewriting];
        [self done];
    }
    
}

- (void)p_writeall {
    
    // thanks for the formaating of the hex to http://stackoverflow.com/questions/5473896/objective-c-converting-an-integer-to-a-hex-value
    
    [self writing];
    
    NSString *ibmajor_str_val = [[NSString alloc] initWithFormat:@"%04X", [self.p_major_text intValue]];
    NSString *ibminor_str_val = [[NSString alloc] initWithFormat:@"%04X", [self.p_minor_text intValue]];
    
    NSString *ibmajor_str = [[NSString alloc] initWithFormat:@"AT+MARJ0x%@%@",
                             [ibmajor_str_val substringWithRange:NSMakeRange(0,2)],
                             [ibmajor_str_val substringWithRange:NSMakeRange(2,2)]];
    
    
    NSString *ibminor_str = [[NSString alloc] initWithFormat:@"AT+MINO0x%@%@",
                             [ibminor_str_val substringWithRange:NSMakeRange(0,2)],
                             [ibminor_str_val substringWithRange:NSMakeRange(2,2)]];
    
    
    NSString *adv = [NSString stringWithFormat:@"AT+ADVI%@",currentInterval];
    
    NSString *range = [NSString stringWithFormat:@"AT+POWE%@",currentRange];
    NSString *mode = @"skip";
    if ([self isCapableOfSettingModes]) {
        mode = [NSString stringWithFormat:@"AT+ADTY%@",currentMode];
    }
    
    NSString *srange = @"GB+SRANGE";
    NSString *stopsleepmode = @"AT+PWRM1";
    NSString *showbatt = @"AT+BATC1";
    
    NSLog(@"AAAAAAAAAA :: STR %@",currentRange);
    NSLog(@"AAAAAAAAAA :: PDATE %@",PDATE);
    NSLog(@"AAAAAAAAAA :: LONG %ld",PDATELONG);
    
    if ([currentRange isEqualToString:@"2"]) {
        NSLog(@"AAAAAAAAAA :: CASE 1 ");
        srange = @"skip";
        stopsleepmode = @"skip";
    }
    if ([self isFirstBeaconType]) {
        if (PDATELONG < 1406451969) {
            // this version we started with the SRANGE
            NSLog(@"AAAAAAAAAA :: CASE 2 ");
            srange = @"skip";
            stopsleepmode = @"skip";
        } else {
            showbatt = @"AT+BATC0";
        }
    } else {
        stopsleepmode = @"skip";
        srange = @"skip";
        showbatt = @"AT+BATC0";
    }
    if ([self isCapableOfSettingBatteryLevel]) {
        showbatt = [NSString stringWithFormat:@"AT+BATC%@",currentBatt];
    }
    
    /////
    
    NSString *power = @"skip";
    if ([currentRange isEqualToString:@"0"]) {
        power = @"AT+MEAA8";    //
        power = @"AT+MEAAE";
    } else if ([currentRange isEqualToString:@"1"]) {
        power = @"AT+MEAB8";    // 72
        //power = @"AT+MEABF";
    } else if ([currentRange isEqualToString:@"2"]) {
        power = @"AT+MEAC5";    // 59
        power = @"AT+MEAC0";
    } else if ([currentRange isEqualToString:@"3"]) {
        power = @"AT+MEAC5";
    }
    
    
    
    
    NSString *name_str = [[NSString alloc] initWithFormat:@"AT+NAME%@           ",
                          (self.p_name_text.length > 11 ) ? [self.p_name_text.uppercaseString substringWithRange:NSMakeRange(0, 11)] : self.p_name_text.uppercaseString];
    
    NSString *pass0 = @"skip";
    NSString *pass1 = @"skip";
    NSString *pass2 = @"skip";
    
    if (self.p_pincode_text.length == 6) {
        pass0 = @"AT+TYPE0";
        pass1 = [NSString stringWithFormat:@"AT+PASS%@",self.p_pincode_text];
        pass2 = @"AT+TYPE2";
    } else if (self.p_pincode_text.length == 0) {
        pass0 = @"AT+TYPE0";
    }
    
    
    // format   74278bda-b644-4520-8f0c-720eaf059935
    //          0        9    14   19   24  28
    
    if (self.p_uuid_text.length == 36) {
        NSString *ib0 = [NSString stringWithFormat:@"AT+IBE0%@",
                         [[self.p_uuid_text uppercaseString] substringWithRange:NSMakeRange(0, 8)]
                         ];
        
        NSString *ib1 = [NSString stringWithFormat:@"AT+IBE1%@%@",
                         [[self.p_uuid_text uppercaseString] substringWithRange:NSMakeRange(9, 4)],
                         [[self.p_uuid_text uppercaseString] substringWithRange:NSMakeRange(14, 4)]
                         ];
        
        NSString *ib2 = [NSString stringWithFormat:@"AT+IBE2%@%@",
                         [[self.p_uuid_text uppercaseString] substringWithRange:NSMakeRange(19, 4)],
                         [[self.p_uuid_text uppercaseString] substringWithRange:NSMakeRange(24, 4)]
                         ];
        
        NSString *ib3 = [NSString stringWithFormat:@"AT+IBE3%@",
                         [[self.p_uuid_text uppercaseString] substringWithRange:NSMakeRange(28, 8)]
                         ];
        
        Queue = [NSMutableArray arrayWithObjects:@"clearerror",ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,adv,pass0,pass1,pass2,name_str,showbatt,range,power,mode,srange,stopsleepmode,@"checkerror",nil];
        
        
    } else {
        Queue = [NSMutableArray arrayWithObjects:@"clearerror",ibmajor_str,ibminor_str,adv,pass0,pass1,pass2,name_str,showbatt,range,power,mode,srange,stopsleepmode,@"checkerror",nil];
        
    }
    
    //    Queue = [NSMutableArray arrayWithObjects:ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,nil];
    //    Queue = [NSMutableArray arrayWithObjects:ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,name_str,nil];
    
    //    [self q_next];
    
    [self performSelector:@selector(q_next) withObject:self afterDelay:0.2];
    
    
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
    //    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
    
}




- (void)cleanupconnection {
    [self cancelLookForPeripheralServices];

    if ([AppStatus sharedInstance].currentPeripheral != Nil) {

        if(peripheral && ([peripheral state] == CBPeripheralStateConnecting )) {
            [[AppStatus sharedInstance].manager cancelPeripheralConnection:peripheral];
        }
        if(peripheral && ([peripheral state] == CBPeripheralStateConnected ))
        {
            /* Disconnect if it's already connected */
            if (currentChar != Nil) {
                [peripheral setNotifyValue:NO forCharacteristic:currentChar];
            }
            [[AppStatus sharedInstance].manager cancelPeripheralConnection:peripheral];
        }
    }

    connectActive = NO;
    
    currentChar = Nil;
    peripheral = Nil;
    [AppStatus sharedInstance].currentPeripheral = Nil;
    peripheralisconnected = NO;
    peripheralisconnecting = NO;
    peripheralisconnectedButNotRead = NO;
}

- (void)cleacupcancelledconnection {

    if ([AppStatus sharedInstance].currentPeripheral != Nil) {
        
        if([AppStatus sharedInstance].currentPeripheral.peripheral && peripheralisconnected == YES && peripheralisconnectedButNotRead == NO)
        {
            
            @try {
                
                //            NSString *name_str = [[NSString alloc] initWithFormat:@"AT+NAME%@",
                //                                  ([[p_name stringValue] length] > 11 ) ? [[[p_name stringValue] uppercaseString] substringWithRange:NSMakeRange(0, 11)] : [[p_name stringValue] uppercaseString]
                //                                  ];
                
                NSString *reset = @"AT+RESET";
                Queue = [NSMutableArray arrayWithObjects:reset,@"close",nil];
                [self q_next];
                return;
                
            }
            @catch (NSException * e) {
                NSLog(@"gb Exception: %@", e);
            }
            @finally {
            }
        } else if ([AppStatus sharedInstance].currentPeripheral.peripheral && peripheralisconnected == NO) {
            if (peripheral && peripheral != Nil) {
                [[AppStatus sharedInstance].manager cancelPeripheralConnection:peripheral];
            }
        }
    }
    [self p_close_window];
}




@end
