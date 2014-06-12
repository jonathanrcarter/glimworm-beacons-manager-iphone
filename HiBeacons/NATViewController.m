//
//  NATViewController.m
//  HiBeacons
//
//  Created by Nick Toumpelis on 2013-10-06.
//  Copyright (c) 2013-2014 Nick Toumpelis.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NATViewController.h"
#import "BTDeviceModel.h"

/* glimworm beacon default uuid */
static NSString * const kUUID = @"74278bda-b644-4520-8f0c-720eaf059935";
static NSString * const kIdentifier = @"SomeIdentifier";

static NSString * const kOperationCellIdentifier = @"OperationCell";
static NSString * const kBeaconCellIdentifier = @"BeaconCell";

static NSString * const kMonitoringOperationTitle = @"Monitoring";
static NSString * const kAdvertisingOperationTitle = @"Advertising";
static NSString * const kRangingOperationTitle = @"Ranging";
static NSString * const kConfigOperationTitle = @"Configure";
static NSUInteger const kNumberOfSections = 2;
static NSUInteger const kNumberOfAvailableOperations = 4;
static CGFloat const kOperationCellHeight = 44;
static CGFloat const kBeaconCellHeight = 52;
static CGFloat const kBLECellHeight = 82;
static NSString * const kBeaconSectionTitle = @"Looking for beacons...";
static NSString * const kBLESectionTitle = @"Looking for configurable beacons ...";
static CGPoint const kActivityIndicatorPosition = (CGPoint){205, 12};
static NSString * const kBeaconsHeaderViewIdentifier = @"BeaconsHeader";

static void * const kMonitoringOperationContext = (void *)&kMonitoringOperationContext;
static void * const kRangingOperationContext = (void *)&kRangingOperationContext;

typedef NS_ENUM(NSUInteger, NTSectionType) {
    NTOperationsSection,
    NTDetectedBeaconsSection
};

typedef NS_ENUM(NSUInteger, NTOperationsRow) {
    NTMonitoringRow,
    NTAdvertisingRow,
    NTRangingRow,
    NTConfigRow
};

/* added by j carter for glimworm beacons - start*/
BTDeviceModel* currentPeripheral = Nil;
CBCharacteristic *_currentChar = Nil;
NSString *currentcommand = @"";
NSString *currentfirmware = @"";
bool isWorking = FALSE;
int MIN = 0;
NSString *LASTPASS = @"761298";

static const NSTimeInterval kLXCBScanningTimeout = 10.0;
static const NSTimeInterval kLXCBConnectingTimeout = 10.0;
static const NSTimeInterval kLXCBRequestTimeout = 5.0;



/* added by j carter for glimworm beacons - end */


@interface NATViewController ()

@property(nonatomic, strong) CBPeripheral *connectedPeripheral;
@property(nonatomic, strong) CBService *connectedService;
@property(nonatomic, strong) CBCharacteristic *currentChar;


@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray *detectedBeacons;
@property (nonatomic, weak) UISwitch *monitoringSwitch;
@property (nonatomic, weak) UISwitch *advertisingSwitch;
@property (nonatomic, weak) UISwitch *configSwitch;
@property (nonatomic, weak) UISwitch *rangingSwitch;
@property (nonatomic, unsafe_unretained) void *operationContext;

/* added by j carter for glimworm beacons - start */
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property  (nonatomic, strong) NSMutableArray *ItemArray;
/* added by j carter for glimworm beacons - end */
@property (weak, nonatomic) IBOutlet UITextField *p_uuid;
@property (weak, nonatomic) IBOutlet UITextField *p_major;
@property (weak, nonatomic) IBOutlet UITextField *p_minor;
@property (weak, nonatomic) IBOutlet UITextField *p_name;
@property (weak, nonatomic) IBOutlet UITextField *p_pincode;
@property (weak, nonatomic) IBOutlet UILabel *p_firmware;
- (IBAction)p_reset:(id)sender;
- (IBAction)p_update:(id)sender;
- (IBAction)p_sendchanges:(id)sender;
- (IBAction)p_reload:(id)sender;
- (IBAction)connect_cancel_but:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *w_spinner;
@property (weak, nonatomic) IBOutlet UIView *WriteView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *write_spinner;
- (IBAction)write_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *p_advint;
- (IBAction)p_advintslider:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *p_advintslider;
@property (weak, nonatomic) IBOutlet UILabel *p_battlevel;

@end
@implementation NATViewController
@synthesize ConfigView;


#pragma mark - Index path management
- (NSArray *)indexPathsOfRemovedBeacons:(NSArray *)beacons
{
    NSMutableArray *indexPaths = nil;
    
    NSUInteger row = 0;
    for (CLBeacon *existingBeacon in self.detectedBeacons) {
        BOOL stillExists = NO;
        for (CLBeacon *beacon in beacons) {
            if ((existingBeacon.major.integerValue == beacon.major.integerValue) &&
                (existingBeacon.minor.integerValue == beacon.minor.integerValue)) {
                stillExists = YES;
                break;
            }
        }
        if (!stillExists) {
            if (!indexPaths)
                indexPaths = [NSMutableArray new];
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:NTDetectedBeaconsSection]];
        }
        row++;
    }
    
    return indexPaths;
}

- (NSArray *)indexPathsOfInsertedBeacons:(NSArray *)beacons
{
    NSMutableArray *indexPaths = nil;
    
    NSUInteger row = 0;
    for (CLBeacon *beacon in beacons) {
        BOOL isNewBeacon = YES;
        for (CLBeacon *existingBeacon in self.detectedBeacons) {
            if ((existingBeacon.major.integerValue == beacon.major.integerValue) &&
                (existingBeacon.minor.integerValue == beacon.minor.integerValue)) {
                isNewBeacon = NO;
                break;
            }
        }
        if (isNewBeacon) {
            if (!indexPaths)
                indexPaths = [NSMutableArray new];
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:NTDetectedBeaconsSection]];
        }
        row++;
    }
    
    return indexPaths;
}

- (NSArray *)indexPathsForBeacons:(NSArray *)beacons
{
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSUInteger row = 0; row < beacons.count; row++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:NTDetectedBeaconsSection]];
    }
    
    return indexPaths;
}

- (NSIndexSet *)insertedSections
{
    if (self.rangingSwitch.on && [self.beaconTableView numberOfSections] == kNumberOfSections - 1) {
        return [NSIndexSet indexSetWithIndex:1];
    } else {
        return nil;
    }
}

- (NSIndexSet *)deletedSections
{
    if (!self.rangingSwitch.on && [self.beaconTableView numberOfSections] == kNumberOfSections) {
        return [NSIndexSet indexSetWithIndex:1];
    } else {
        return nil;
    }
}

- (NSArray *)filteredBeacons:(NSArray *)beacons
{
    // Filters duplicate beacons out; this may happen temporarily if the originating device changes its Bluetooth id
    NSMutableArray *mutableBeacons = [beacons mutableCopy];
    
    NSMutableSet *lookup = [[NSMutableSet alloc] init];
    for (int index = 0; index < [beacons count]; index++) {
        CLBeacon *curr = [beacons objectAtIndex:index];
        NSString *identifier = [NSString stringWithFormat:@"%@/%@", curr.major, curr.minor];
        
        // this is very fast constant time lookup in a hash table
        if ([lookup containsObject:identifier]) {
            [mutableBeacons removeObjectAtIndex:index];
        } else {
            [lookup addObject:identifier];
        }
    }
    
    return [mutableBeacons copy];
}

#pragma mark - Table view functionality
- (NSString *)detailsStringForBeacon:(CLBeacon *)beacon
{
    NSString *proximity;
    switch (beacon.proximity) {
        case CLProximityNear:
            proximity = @"Near";
            break;
        case CLProximityImmediate:
            proximity = @"Immediate";
            break;
        case CLProximityFar:
            proximity = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximity = @"Unknown";
            break;
    }
    
    NSString *format = @"%@, %@ • %@ • %f • %li";
    return [NSString stringWithFormat:format, beacon.major, beacon.minor, proximity, beacon.accuracy, beacon.rssi];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case NTOperationsSection: {
            cell = [tableView dequeueReusableCellWithIdentifier:kOperationCellIdentifier];
            switch (indexPath.row) {
                case NTMonitoringRow:
                    cell.textLabel.text = kMonitoringOperationTitle;
                    self.monitoringSwitch = (UISwitch *)cell.accessoryView;
                    [self.monitoringSwitch addTarget:self
                                              action:@selector(changeMonitoringState:)
                                    forControlEvents:UIControlEventTouchUpInside];
                    break;
                case NTAdvertisingRow:
                    cell.textLabel.text = kAdvertisingOperationTitle;
                    self.advertisingSwitch = (UISwitch *)cell.accessoryView;
                    [self.advertisingSwitch addTarget:self
                                               action:@selector(changeAdvertisingState:)
                                     forControlEvents:UIControlEventValueChanged];
                    break;
                case NTConfigRow:
                    cell.textLabel.text = kConfigOperationTitle;
                    self.configSwitch = (UISwitch *)cell.accessoryView;
                    [self.configSwitch addTarget:self
                                               action:@selector(changeConfigState:)
                                     forControlEvents:UIControlEventValueChanged];
                    break;

                case NTRangingRow:
                default:
                    cell.textLabel.text = kRangingOperationTitle;
                    self.rangingSwitch = (UISwitch *)cell.accessoryView;
                    [self.rangingSwitch addTarget:self
                                           action:@selector(changeRangingState:)
                                 forControlEvents:UIControlEventValueChanged];
                    break;
            }
        }
            break;
        case NTDetectedBeaconsSection:
        default: {
            
            if (self.configSwitch.on) {
                BTDeviceModel *beacon = self.ItemArray[indexPath.row];
                cell = [tableView dequeueReusableCellWithIdentifier:kBeaconCellIdentifier];
                if (!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                  reuseIdentifier:kBeaconCellIdentifier];
                cell.textLabel.text = [NSString stringWithFormat : @"%@ (%d%%)", beacon.name,beacon.batterylevel];
                cell.detailTextLabel.text = [NSString stringWithFormat : @"%@", beacon.UUID];
                cell.detailTextLabel.textColor = [UIColor grayColor];
                
            } else {
            
                CLBeacon *beacon = self.detectedBeacons[indexPath.row];
            
                cell = [tableView dequeueReusableCellWithIdentifier:kBeaconCellIdentifier];
            
                if (!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                              reuseIdentifier:kBeaconCellIdentifier];
            
                cell.textLabel.text = beacon.proximityUUID.UUIDString;
                cell.detailTextLabel.text = [self detailsStringForBeacon:beacon];
                cell.detailTextLabel.textColor = [UIColor grayColor];
            }
        }
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.rangingSwitch.on || self.configSwitch.on) {
        return kNumberOfSections;       // All sections visible
    } else {
        return kNumberOfSections - 1;   // Beacons section not visible
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case NTOperationsSection:
            return kNumberOfAvailableOperations;
        case NTDetectedBeaconsSection:
        default:
            if (self.configSwitch.on) {
                return self.ItemArray.count;
            } else {
                return self.detectedBeacons.count;
            }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case NTOperationsSection:
            return nil;
        case NTDetectedBeaconsSection:
        default:
            if (self.configSwitch.on) {
                return kBLESectionTitle;
            } else {
                return kBeaconSectionTitle;
            }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case NTOperationsSection:
            return kOperationCellHeight;
        case NTDetectedBeaconsSection:
        default:
            if (self.configSwitch.on) {
                return kBLECellHeight;
            } else {
                return kBeaconCellHeight;
            }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView =
    [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kBeaconsHeaderViewIdentifier];
    
    // Adds an activity indicator view to the section header
    UIActivityIndicatorView *indicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [headerView addSubview:indicatorView];
    
    indicatorView.frame = (CGRect){kActivityIndicatorPosition, indicatorView.frame.size};
    
    [indicatorView startAnimating];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"DIDSELECTROWATINDEXPATH %@", indexPath);
    NSLog(@"DIDSELECTROWATINDEXPATH ITEM %ld", (long)indexPath.item);
    
    switch (indexPath.section) {
        case NTDetectedBeaconsSection:
        default:
            if (self.configSwitch.on) {
                if (ConfigView.hidden == YES) {
                    ConfigView.hidden = NO;
                    BTDeviceModel *btm = [self.ItemArray objectAtIndex:indexPath.item];
                    
                    currentPeripheral = btm;
                    [self working];
                    [self connect];
                    
                    [self.p_uuid becomeFirstResponder];
                }
            }
    }
}


#pragma mark - Common
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kIdentifier];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
}

- (void)createLocationManager
{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
}

#pragma mark - Beacon configuration
- (void)changeConfigState:sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (self.rangingSwitch.on) {
        self.configSwitch.on = false;
        return;
    }
    if (theSwitch.on) {
        [self startConfigurationMonitoring];
    } else {
        [self stopConfigurationMonitoring];
    }
}

- (void)startConfigurationMonitoring
{

    
    [self clearItemArray];

    if (!self.manager) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.manager.delegate = self;
        self.beaconTableView.delegate = self;
    } else {
        [self startScan];
        
    }
}

- (void)stopConfigurationMonitoring
{

    [self stopScan];
    [self updateBLEtable];
    
//    [self.beaconTableView beginUpdates];
//    if (deletedSections)
//        [self.beaconTableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
//    [self.beaconTableView endUpdates];
    [self clearItemArray];
    
    NSLog(@"Turned off config.");

}
- (void)startScan {

    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES};
    [self.manager scanForPeripheralsWithServices:nil options:options];

    NSLog(@"Scanning Bluetooth");
    
}
- (void)stopScan {
    [self.manager stopScan];
}

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

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"state update");
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog( @"state update powered on");
        [self startScan];
    }
    else if (central.state == CBCentralManagerStatePoweredOff) {
        NSLog(@"state update powered off");
//        NSAlert *alert = [NSAlert alertWithMessageText:@"Bluetooth is currently powered off." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
//        [alert runModal];
    }
    else if (central.state == CBCentralManagerStateUnauthorized) {
        NSLog(@"state update powered unauthorized");
//        NSAlert *alert = [NSAlert alertWithMessageText:@"The app is not authorized to use Bluetooth Low Energy." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
//        [alert runModal];
    }
    else if (central.state == CBCentralManagerStateUnsupported) {
        NSLog(@"state update powered unsupported");
//        NSAlert *alert = [NSAlert alertWithMessageText:@"The platform/hardware doesn't support Bluetooth Low Energy." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
//        [alert runModal];
    }
    
    
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //NSString *value = [[NSString alloc] initWithFormat:@"disc %@ %@ %@", peripheral.name, RSSI, [peripheral.identifier UUIDString]];
    NSString *_name = [[NSString alloc] initWithFormat:@"%@", peripheral.name];
    //NSString *u = [peripheral.identifier UUIDString];
    NSString *_uuid = [peripheral.identifier UUIDString];
    
    NSLog(@"ADDATA u %@",advertisementData);
    
    NSData* versionInfo = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    
    NSLog(@"versionInfo u %@",versionInfo);

    NSNumber* isconnectable = [advertisementData objectForKey:CBAdvertisementDataIsConnectable];
    
    NSLog(@"isconnectable u %@",isconnectable);

    NSDictionary* servicedata = [advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
    NSLog(@"servicedata u %@",servicedata);

    int batt = 0;
    
    BOOL fnd = NO;
    CBUUID *_key;
    for (_key in [servicedata allKeys]){
        NSData *obj;
        obj = [servicedata objectForKey: _key];
        NSLog(@"key : %@  value : %@",_key.data,obj);
        
        NSString *__key = [[NSString alloc] initWithFormat:@"%@", _key.data];
        NSString *__val = [[NSString alloc] initWithFormat:@"%@", obj];
        if ([__key isEqualToString:@"<b000>"]) {
            fnd = YES;
            NSString *batt_level = [NSString stringWithFormat:@"%@",
                                    [__val substringWithRange:NSMakeRange(6, 3)]];
            
            NSString *batt_level_int;
            batt_level_int = [self hex2dec:batt_level];
            batt = [batt_level_int intValue];
            
        }
    };
    
    if (!fnd) {
        return;
    }

    NSLog(@"Battery level : %d",batt);

    /*[servicedata enumerateKeysAndObjectsUsingBlock::^(id key, id object, BOOL *stop) {
        NSLog(@"The key is %@", key);
        NSLog(@"The value is %@", object);
    }];*/

    
    /*

     kCBAdvDataChannel = 38;
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = GLBeacon;
     kCBAdvDataServiceData =     {
        "Unknown (<b000>)" = <00000042>;
     };
     kCBAdvDataServiceUUIDs =     (
        "Unknown (<ffe0>)"
     );
     kCBAdvDataTxPowerLevel = 0;
     
     */
    NSLog(@"ADDATA u %@",[advertisementData allValues]);
    
    
    //NSLog(@"CFSTRINGREF u %@",u);   // this is just the UUID
    //NSLog(@"CFSTRINGREF U %@",_uuid);
    //NSLog(@"CFSTRINGREF N %@",_name);
    
    
    @try {

        if (_uuid == NULL) _uuid = @"";
        if (_name == NULL) _name = @"";
        
        for (int i=0; i < [self.ItemArray count]; i++) {
            BTDeviceModel *m = [self.ItemArray objectAtIndex:i];
            
            //NSLog(@"CFSTRINGREF MNAME %@",m.name);
            //NSLog(@"CFSTRINGREF UUID %@",m.UUID);

            //NSLog(@"CFSTRINGREF UUID %@ _uuid %@",m.UUID, _uuid);
            
            if ([m.UUID isEqualToString: (_uuid)])
            {
                //NSLog(@"** MATCHED **");
                m.RSSI = RSSI;
                m.name = _name;
                m.batterylevel = batt;
                
                /*for (CBService* service in peripheral.services)
                {
                    NSString *__uuid = [[NSString alloc] initWithFormat:@"LS : %@", service.UUID];
                    NSLog(@"%@",__uuid);
                }*/
                
                
                for (id key in [advertisementData allKeys]){
                    id obj = [advertisementData objectForKey: key];
                    
                    //NSLog(@"key : %@  value : %@",key,obj);
                    
                    NSString *_key = [[NSString alloc] initWithFormat:@"%@", key];
                    
                    if ([_key isEqualToString:@"kCBAdvDataManufacturerData"]) {
                        NSString *ss2 = [NSString stringWithFormat:@"%@",obj];
                        //NSLog(@"ss2 : %@",ss2);
                        NSString *ib_uuid = [NSString stringWithFormat:@"%@-%@-%@-%@-%@%@",
                                             [ss2 substringWithRange:NSMakeRange(10, 8)],
                                             [ss2 substringWithRange:NSMakeRange(19, 4)],
                                             [ss2 substringWithRange:NSMakeRange(23, 4)],
                                             [ss2 substringWithRange:NSMakeRange(28, 4)],
                                             [ss2 substringWithRange:NSMakeRange(32, 4)],
                                             [ss2 substringWithRange:NSMakeRange(37, 8)]
                                             ];
                        NSString *ib_major = [NSString stringWithFormat:@"%@%@",
                                              [ss2 substringWithRange:NSMakeRange(46, 2)],
                                              [ss2 substringWithRange:NSMakeRange(48, 2)]];
                        
                        
                        NSString *ib_minor = [NSString stringWithFormat:@"%@%@",
                                              [ss2 substringWithRange:NSMakeRange(50, 2)],
                                              [ss2 substringWithRange:NSMakeRange(52, 2)]];
                        
                        m.ib_uuid = ib_uuid;
                        m.ib_major = [self hex2dec:ib_major];
                        m.ib_minor = [self hex2dec:ib_minor];
//                        [self findItemInAccountArray:m];
                        
                    }
                }
                
                return;
            }
        }
        
        [peripheral discoverServices:Nil];
        
        BTDeviceModel * pm = [[BTDeviceModel alloc] init];
        pm.name = _name;
        pm.UUID = _uuid;
        pm.RSSI = RSSI;
        pm.peripheral = peripheral;
        pm.ib_uuid = @"";
        pm.ib_major = @"";
        pm.ib_minor = @"";
        pm.batterylevel = batt;
        
        /*
        NSLog(@"%@",value);
        NSLog(@"%@", [advertisementData description]);
        NSLog(@"1000 %@",value);
        NSLog(@"2000 %@", [advertisementData description]);
        */
        
        for (id key in [advertisementData allKeys]){
            id obj = [advertisementData objectForKey: key];
            
            //NSLog(@"key : %@  value : %@",key,obj);
            
            NSString *_key = [[NSString alloc] initWithFormat:@"%@", key];
            
            
            if ([_key isEqualToString:@"kCBAdvDataManufacturerData"]) {
                NSString *ss2 = [NSString stringWithFormat:@"%@",obj];
                NSString *ib_uuid = [NSString stringWithFormat:@"%@-%@-%@-%@-%@%@",
                                     [ss2 substringWithRange:NSMakeRange(10, 8)],
                                     [ss2 substringWithRange:NSMakeRange(19, 4)],
                                     [ss2 substringWithRange:NSMakeRange(23, 4)],
                                     [ss2 substringWithRange:NSMakeRange(28, 4)],
                                     [ss2 substringWithRange:NSMakeRange(32, 4)],
                                     [ss2 substringWithRange:NSMakeRange(37, 8)]
                                     ];
                NSString *ib_major = [NSString stringWithFormat:@"%@",
                                      [ss2 substringWithRange:NSMakeRange(46, 4)]];
                
                NSString *ib_minor = [NSString stringWithFormat:@"%@",
                                      [ss2 substringWithRange:NSMakeRange(50, 4)]];
                
                /*
                NSLog(@"AdvDataArray: IBUUID : %@ ",ib_uuid);
                NSLog(@"AdvDataArray: IBMAJOR : %@ ",ib_major);
                NSLog(@"AdvDataArray: IBINOR : %@ ",ib_minor);
                */
                pm.ib_uuid = ib_uuid;
                pm.ib_major = [self hex2dec:ib_major];
                pm.ib_minor = [self hex2dec:ib_minor];
                
                
            }
        }
        
        [self insertObject:pm inItemArrayAtIndex:[self.ItemArray count]];
//        [self insertObject:pm inItemArrayAtIndex:0];
//        [self findItemInAccountArray:pm];
        
        
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    @finally {
//        NSLog(@"Array is now: %@", self.ItemArray);
        [self updateBLEtable];
        
    
    }
}

-(void)updateBLEtable {

    NSIndexSet *insertedSections;
    if (self.configSwitch.on && [self.beaconTableView numberOfSections] == kNumberOfSections - 1) {
        insertedSections = [NSIndexSet indexSetWithIndex:1];
        [self.beaconTableView beginUpdates];
        [self.beaconTableView insertSections:insertedSections withRowAnimation:UITableViewRowAnimationFade];
        [self.beaconTableView endUpdates];
        return;
    }

    if (!self.configSwitch.on && [self.beaconTableView numberOfSections] == kNumberOfSections) {
        NSLog(@"DELETING SECTION");
        insertedSections = [NSIndexSet indexSetWithIndex:1];
        [self.beaconTableView beginUpdates];
        [self.beaconTableView deleteSections:insertedSections withRowAnimation:UITableViewRowAnimationFade];
        [self.beaconTableView endUpdates];
        return;
    }
    
    if (self.configSwitch.on) {
    
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (NSUInteger row = [self.beaconTableView numberOfRowsInSection:1]; row < self.ItemArray.count; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:NTDetectedBeaconsSection]];
        }
        [self.beaconTableView beginUpdates];
        [self.beaconTableView insertRowsAtIndexPaths:indexPaths  withRowAnimation:UITableViewRowAnimationFade];
        [self.beaconTableView endUpdates];
    }
    
}

#pragma mark - Updating the ITEMS array

-(void)insertObject:(BTDeviceModel *)p inItemArrayAtIndex:(NSUInteger)index {
    [self.ItemArray insertObject:p atIndex:index];
}

-(void)removeObjectFromItemArrayAtIndex:(NSUInteger)index {
    [self.ItemArray removeObjectAtIndex:index];
}

-(NSArray*)itemArray {
    return self.ItemArray;
}

-(void)clearItemArray {
    if (!self.ItemArray) {
        self.ItemArray = [NSMutableArray arrayWithObjects:nil];
    } else {
        [self.ItemArray removeAllObjects];
    }
}


#pragma mark - Beacon ranging
- (void)changeRangingState:sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (self.configSwitch.on) {
        self.rangingSwitch.on = false;
        return;
    }
    
    if (theSwitch.on) {
        [self startRangingForBeacons];
    } else {
        [self stopRangingForBeacons];
    }
}

- (void)startRangingForBeacons
{
    self.operationContext = kRangingOperationContext;
    
    [self createLocationManager];
    
    self.detectedBeacons = [NSArray array];
    [self turnOnRanging];
}

- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        self.rangingSwitch.on = NO;
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [self createBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);
}

- (void)stopRangingForBeacons
{
    if (self.locationManager.rangedRegions.count == 0) {
        NSLog(@"Didn't turn off ranging: Ranging already off.");
        return;
    }
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    NSIndexSet *deletedSections = [self deletedSections];
    self.detectedBeacons = [NSArray array];
    
    [self.beaconTableView beginUpdates];
    if (deletedSections)
        [self.beaconTableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
    [self.beaconTableView endUpdates];
    
    NSLog(@"Turned off ranging.");
}

#pragma mark - Beacon region monitoring
- (void)changeMonitoringState:sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on) {
        [self startMonitoringForBeacons];
    } else {
        [self stopMonitoringForBeacons];
    }
}

- (void)startMonitoringForBeacons
{
    self.operationContext = kMonitoringOperationContext;
    
    [self createLocationManager];
    
    [self turnOnMonitoring];
}

- (void)turnOnMonitoring
{
    NSLog(@"Turning on monitoring...");
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        NSLog(@"Couldn't turn on region monitoring: Region monitoring is not available for CLBeaconRegion class.");
        self.monitoringSwitch.on = NO;
        return;
    }
    
    [self createBeaconRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"Monitoring turned on for region: %@.", self.beaconRegion);
}

- (void)stopMonitoringForBeacons
{
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"Turned off monitoring");
}

#pragma mark - Location manager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        if (self.operationContext == kMonitoringOperationContext) {
            NSLog(@"Couldn't turn on monitoring: Location services are not enabled.");
            self.monitoringSwitch.on = NO;
            return;
        } else {
            NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
            self.rangingSwitch.on = NO;
            return;
        }
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        if (self.operationContext == kMonitoringOperationContext) {
            NSLog(@"Couldn't turn on monitoring: Location services not authorised.");
            self.monitoringSwitch.on = NO;
            return;
        } else {
            NSLog(@"Couldn't turn on ranging: Location services not authorised.");
            self.rangingSwitch.on = NO;
            return;
        }
    }
    
    if (self.operationContext == kMonitoringOperationContext) {
        self.monitoringSwitch.on = YES;
    } else {
        self.rangingSwitch.on = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    NSArray *filteredBeacons = [self filteredBeacons:beacons];
    
    if (filteredBeacons.count == 0) {
        NSLog(@"No beacons found nearby.");
    } else {
        NSLog(@"Found %lu %@.", (unsigned long)[filteredBeacons count],
                [filteredBeacons count] > 1 ? @"beacons" : @"beacon");
    }
    
    NSIndexSet *insertedSections = [self insertedSections];
    NSIndexSet *deletedSections = [self deletedSections];
    NSArray *deletedRows = [self indexPathsOfRemovedBeacons:filteredBeacons];
    NSArray *insertedRows = [self indexPathsOfInsertedBeacons:filteredBeacons];
    NSArray *reloadedRows = nil;
    if (!deletedRows && !insertedRows)
        reloadedRows = [self indexPathsForBeacons:filteredBeacons];
    
    self.detectedBeacons = filteredBeacons;
    
    [self.beaconTableView beginUpdates];
    if (insertedSections)
        [self.beaconTableView insertSections:insertedSections withRowAnimation:UITableViewRowAnimationFade];
    if (deletedSections)
        [self.beaconTableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
    if (insertedRows)
        [self.beaconTableView insertRowsAtIndexPaths:insertedRows withRowAnimation:UITableViewRowAnimationFade];
    if (deletedRows)
        [self.beaconTableView deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationFade];
    if (reloadedRows)
        [self.beaconTableView reloadRowsAtIndexPaths:reloadedRows withRowAnimation:UITableViewRowAnimationNone];
    [self.beaconTableView endUpdates];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region: %@", region);
    
    [self sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited region: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *stateString = nil;
    switch (state) {
        case CLRegionStateInside:
            stateString = @"inside";
            break;
        case CLRegionStateOutside:
            stateString = @"outside";
            break;
        case CLRegionStateUnknown:
            stateString = @"unknown";
            break;
    }
    NSLog(@"State changed to %@ for region %@.", stateString, region);
}

#pragma mark - Local notifications
- (void)sendLocalNotificationForBeaconRegion:(CLBeaconRegion *)region
{
    UILocalNotification *notification = [UILocalNotification new];
    
    // Notification details
    notification.alertBody = [NSString stringWithFormat:@"Entered beacon region for UUID: %@",
        region.proximityUUID.UUIDString];   // Major and minor are not available at the monitoring stage
    notification.alertAction = NSLocalizedString(@"View Details", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark - Beacon advertising
- (void)changeAdvertisingState:sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on) {
        [self startAdvertisingBeacon];
    } else {
        [self stopAdvertisingBeacon];
    }
}

- (void)startAdvertisingBeacon
{
    NSLog(@"Turning on advertising...");
    
    [self createBeaconRegion];
    
    if (!self.peripheralManager)
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    [self turnOnAdvertising];
}

- (void)turnOnAdvertising
{
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral manager is off.");
        self.advertisingSwitch.on = NO;
        return;
    }
    
    time_t t;
    srand((unsigned) time(&t));
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                     major:rand()
                                                                     minor:rand()
                                                                identifier:self.beaconRegion.identifier];
    NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];
    
    NSLog(@"Turning on advertising for region: %@.", region);
}

- (void)stopAdvertisingBeacon
{
    [self.peripheralManager stopAdvertising];
    
    NSLog(@"Turned off advertising.");
}

#pragma mark - Beacon advertising delegate methods
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
{
    if (error) {
        NSLog(@"Couldn't turn on advertising: %@", error);
        self.advertisingSwitch.on = NO;
        return;
    }
    
    if (peripheralManager.isAdvertising) {
        NSLog(@"Turned on advertising.");
        self.advertisingSwitch.on = YES;
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral manager is off.");
        self.advertisingSwitch.on = NO;
        return;
    }

    NSLog(@"Peripheral manager is on.");
    [self turnOnAdvertising];
}
-(void) peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"isreadytoupdatesubscribers");
}

#pragma mark - Configuration Popup window

-(void)connect {

    if (currentPeripheral != Nil) {
        [self.manager connectPeripheral:currentPeripheral.peripheral options:nil];
    }
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
    self.p_uuid.layer.borderColor = [[UIColor grayColor]CGColor];
    
}

/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFontFamily:@"FagoOfficeSans-Regular" forView:self.view andSubViews:YES];
}
-(void)setFontFamily:(NSString*)fontFamily forView:(UIView*)view andSubViews:(BOOL)isSubViews
{
    if ([view isKindOfClass:[UILabel class]])
    {
        UILabel *lbl = (UILabel *)view;
        [lbl setFont:[UIFont fontWithName:fontFamily size:[[lbl font] pointSize]]];
    }
    
    if (isSubViews)
    {
        for (UIView *sview in view.subviews)
        {
            [self setFontFamily:fontFamily forView:sview andSubViews:YES];
        }
    }
}
 */
- (void)viewWillAppear:(BOOL)animated {

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(activate:)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(activate:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}

bool peripheralIsConnected = NO;
bool peripheralIsConnecting = NO;
bool peripheralIsConnectedButNotRead = NO;

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@" connectED ( %@ )", [aPeripheral name]);
    
    peripheralIsConnected = YES;
    peripheralIsConnecting = NO;
    peripheralIsConnectedButNotRead = YES;
    [self stopScan];
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

-(void) activate:(NSNotification *)pNotification {
    NSLog(@"application activate ");
    if (peripheralIsConnectedButNotRead) {
        NSLog(@"application activate READ");
        [self q_readall];
    }
}


- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    
    NSLog(@" servicesDISCOVERED ( %@ )", [aPeripheral name]);
    for (CBService *service in aPeripheral.services) {
        NSLog(@"Discovered service s: %@", service);
        NSLog(@"Discovered service u: %@", service.UUID);
        
        /* connect to serial bluetooth */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
        {
            [aPeripheral discoverCharacteristics:nil forService:service];
        }
    }
}
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* Set notification on heart rate measurement */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
            {
                NSLog(@"Found a serial connectionCharacteristic, properties %@", aChar.UUID);
                
//                [p_name_ml setStringValue:@"Found a serial connectionCharacteristic, enquiring about name"];
                
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
                _currentChar = aChar;
                _peripheral = aPeripheral;
                
                [self working];
                [self performSelector:@selector(q_readall) withObject:self afterDelay:3.0];
//                [self q_readall];
                
                
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"-- didWriteValueForCharacteristic");
    NSLog(@"-- didWriteValueForCharacteristic err %@", error);
    NSLog(@"-- didWriteValueForCharacteristic characteristic %@", characteristic);
    NSLog(@"-- didWriteValueForCharacteristic characteristic.value %@", characteristic.value);
    NSLog(@"-- didWriteValueForCharacteristic characteristic.UUID %@", characteristic.UUID);
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
    {
        NSLog(@"-- didWriteValueForCharacteristic *MATHCHED* ");

        if( (characteristic.value)  || !error )
        {
            NSLog(@"wrote characteristic val: %@ , %@", characteristic.value, characteristic.UUID);
//            [p_log setStringValue: [[NSString alloc] initWithFormat:@"written : %@", characteristic.value] ];
        } else {
            NSLog(@"-- didWriteValueForCharacteristic err %@", error.debugDescription);
            NSLog(@"-- didWriteValueForCharacteristic err %@", error.description);
            
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

/*
 this is the one that gets called
 */

NSString *incoming_uuid = @"00000000-0000-0000-0000-000000000000";


- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"-- didUpdateValueForCharacteristic");
    [self cancelRequestTimeoutMonitor:characteristic];
    
    /* Updated value for heart rate measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
    {
        if( (characteristic.value)  || !error )
        {
            /* Update UI with heart rate data */
            NSLog(@"updated characteristic val: %@ , %@", characteristic.value, characteristic.UUID);
            
            NSString *str=[[NSString alloc] initWithBytes:characteristic.value.bytes length:characteristic.value.length encoding:NSUTF8StringEncoding];
            NSLog(@"retval %@", str);
            
            //NSString *logmessage = [[NSString alloc] initWithFormat:@"'%@' : '%@'", currentcommand, str];
            
            
            NSLog(@"currentcommand %@", currentcommand);
            NSLog(@"currentcommand:retval %@", str);
            peripheralIsConnecting = NO;
            
            if ([currentcommand isEqualToString:@"GB+BTYPE"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                NSLog(@"GB returns %@",str);
                if (array.count > 1) {
                    
                } else {
                    NSLog(@"ERR returns %@",str);
                }
            }
            
            if ([currentcommand isEqualToString:@"AT+VERS?"]) {
                
                peripheralIsConnectedButNotRead = NO;
                
                NSArray *array = [str componentsSeparatedByString:@" "];
                if (array.count > 1) {
                    self.p_firmware.text = array[1];
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
                    NSLog(@"ERR returns %@",str);
                    q_error = YES;
                }
                
            }
            
            if ([currentcommand isEqualToString:@"AT+MARJ?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                self.p_major.text = [self hex2dec:array[1]];
            }
            if ([currentcommand isEqualToString:@"AT+MINO?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                self.p_minor.text = [self hex2dec:array[1]];
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
                    NSLog(@"ERR returns %@",str);
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
                    NSLog(@"ERR returns %@",str);
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
                    NSLog(@"ERR returns %@",str);
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
                    self.p_uuid.text = incoming_uuid;
                } else {
                    NSLog(@"ERR returns %@",str);
                    q_error = YES;
                }
            }


            
            if ([currentcommand isEqualToString:@"AT+NAME?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    NSLog(@"array %@",array[1]);
                    self.p_name.text = array[1];
                } else {
                    NSLog(@"ERR returns %@",str);
                    q_error = YES;
                }
            }
            if ([currentcommand isEqualToString:@"AT+PASS?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    NSLog(@"array %@",array[1]);
                    self.p_pincode.text = array[1];
                } else {
                    NSLog(@"ERR returns %@",str);
                    q_error = YES;
                }
            }

            if ([currentcommand isEqualToString:@"AT+TYPE?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                    int val = [array[1] intValue];
                    if (val == 0) {
                        self.p_pincode.text = @"";
                    }
                } else {
                    NSLog(@"ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            
            if ([currentcommand isEqualToString:@"AT+POWE?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                NSLog(@"array %@",array[1]);
                int val = [array[1] intValue];
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
                
                    NSLog(@"array %@",array[1]);
                    int val = [array[1] intValue];
                    NSString *Val = array[1];
                    
                    //                [self clearadvertisingbuttonstates];
                    
                    if ([self has16advertisments] == FALSE) {
                        
                        if ([Val isEqualToString:@"0"]) self.p_advintslider.value = 0;
                        if ([Val isEqualToString:@"1"]) self.p_advintslider.value = 15;
                    } else {
                        if ([Val isEqualToString:@"0"]) self.p_advintslider.value = 0;
                        if ([Val isEqualToString:@"1"]) self.p_advintslider.value = 1;
                        if ([Val isEqualToString:@"2"]) self.p_advintslider.value = 2;
                        if ([Val isEqualToString:@"3"]) self.p_advintslider.value = 3;
                        if ([Val isEqualToString:@"4"]) self.p_advintslider.value = 4;
                        if ([Val isEqualToString:@"5"]) self.p_advintslider.value = 5;
                        if ([Val isEqualToString:@"6"]) self.p_advintslider.value = 6;
                        if ([Val isEqualToString:@"7"]) self.p_advintslider.value = 7;
                        if ([Val isEqualToString:@"8"]) self.p_advintslider.value = 8;
                        if ([Val isEqualToString:@"9"]) self.p_advintslider.value = 9;
                        if ([Val isEqualToString:@"A"]) self.p_advintslider.value = 10;
                        if ([Val isEqualToString:@"B"]) self.p_advintslider.value = 11;
                        if ([Val isEqualToString:@"C"]) self.p_advintslider.value = 12;
                        if ([Val isEqualToString:@"D"]) self.p_advintslider.value = 13;
                        if ([Val isEqualToString:@"E"]) self.p_advintslider.value = 14;
                        if ([Val isEqualToString:@"F"]) self.p_advintslider.value = 15;
                    }
                    [self setAdvIntervalFromSlider];
                } else {
                    NSLog(@"ERR returns %@",str);
                    q_error = YES;
                }
            }
            
            
            
            if ([currentcommand isEqualToString:@"AT+BATT?"]) {
                
                NSLog(@"currentcommand MATCHED");
                
                NSArray *array = [str componentsSeparatedByString:@":"];
                if (array.count > 1) {
                
                    double dv = [array[1] doubleValue];
                    NSLog(@"array %@",array[1]);
                    NSLog(@"array intvalue %ld",(long)[array[1] integerValue]);
                    NSLog(@"array intvalue %d",[array[1] intValue]);
                    NSLog(@"array intvalue %f",dv);
                    self.p_battlevel.text = [NSString stringWithFormat:@"Battery :%d %%", [array[1] intValue]];
                } else {
                    NSLog(@"ERR returns %@",str);
                    q_error = YES;
                }
//                [p_batterylevel setDoubleValue:dv];
//                [p_batterlevel_txt setDoubleValue:dv];
                
//                [p_log setStringValue: @"Battery level" ];
            }
            
            
            
            [self q_next];
            
        }
    }
}
NSString *currentInterval = @"";

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

- (void)q_readall {
    
    
    NSString *get0 = [[NSString alloc] initWithFormat:@"GB+BTYPE"];
    NSString *get1 = [[NSString alloc] initWithFormat:@"AT+VERS?"];
    NSString *get2 = [[NSString alloc] initWithFormat:@"AT+BATT?"];
    NSString *get3 = [[NSString alloc] initWithFormat:@"AT+ADVI?"];
    NSString *get4 = [[NSString alloc] initWithFormat:@"AT+POWE?"]; // 0 1 2 3 2 = std
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
    
    Queue = [NSMutableArray arrayWithObjects:@"clearerror",get0,get1,get2,get3,get4,get5,get6,get7,get8,get9,get10,get11,get12,get13,@"checkerror",nil];
    
    [self q_next];
}


#pragma mark - request timeout code 
// thanks to https://github.com/liquidx/CoreBluetoothPeripheral/blob/48ff54b31b41e5ca01fae496e3548209f6da9e8b/CoreBluetoothOSXCentral/CoreBluetoothOSXCentral/LXCBCentralClient.m


- (void)startRequestTimeout:(CBCharacteristic *)characteristic {
    [self cancelRequestTimeoutMonitor:characteristic];
    [self performSelector:@selector(requestDidTimeout:)
               withObject:characteristic
               afterDelay:kLXCBRequestTimeout];
}

- (void)cancelRequestTimeoutMonitor:(CBCharacteristic *)characteristic {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(requestDidTimeout:)
                                               object:characteristic];
}

- (void)requestDidTimeout:(CBCharacteristic *)characteristic {
    NSLog(@"requestDidTimeout: %@", characteristic);
    [self q_next];
//    NSError *error = [[self class] errorWithDescription:@"Unable to request data from BTLE device."];
//    [self.delegate centralClient:self
//        requestForCharacteristic:characteristic
//                         didFail:error];
//    [self.connectedPeripheral setNotifyValue:NO
//                           forCharacteristic:characteristic];
}


#pragma mark - sending queue

NSMutableArray *Queue;
bool q_error = NO;

- (void)q_next {
    
    // than you to https://github.com/mattjgalloway/MJGFoundation/blob/master/Source/Model/MJGStack.m for the queue code
    
    NSLog(@"Q_NEXT");
    NSLog(@"Q_NEXT CNT %lu ",(unsigned long)Queue.count);
    
    if (Queue.count > 0) {
        
        NSString *q_str = [Queue objectAtIndex:0];
        [Queue removeObjectAtIndex:(0)];
        NSLog(@"Q_NEXT STR %@", q_str);
        
        if ([q_str isEqualToString:@"close"]) {
            currentcommand = @"";
            
            [self p_close_window];
            return;
        }
        if ([q_str isEqualToString:@"checkerror"]) {
            if (q_error == YES) {

                UILocalNotification *notification = [UILocalNotification new];
                
                // Notification details
                notification.alertBody = [NSString stringWithFormat:@"There was an error"];
                notification.alertAction = NSLocalizedString(@"View Details", nil);
                notification.soundName = UILocalNotificationDefaultSoundName;
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
            }
            [self q_next];
            return;
        }
        if ([q_str isEqualToString:@"clearerror"]) {
            q_error = NO;
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
        
        if ([currentfirmware isEqualToString:@"V517"] && [currentcommand isEqualToString:@"AT+MEAS?"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V518"] && [currentcommand isEqualToString:@"AT+MEAS?"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V519"] && [currentcommand isEqualToString:@"AT+MEAS?"]) {
            [self q_next];
            return;
        }
        
        if ([currentfirmware isEqualToString:@"V517"] && [currentcommand isEqualToString:@"AT+MEAS?"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V518"] && [currentcommand isEqualToString:@"AT+MEAS?"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V519"] && [currentcommand isEqualToString:@"AT+MEAS?"]) {
            [self q_next];
            return;
        }
        if ([currentfirmware isEqualToString:@"V520"] && [currentcommand isEqualToString:@"AT+MEAS?"]) {
            [self q_next];
            return;
        }
        
        
        currentcommand = [[NSString alloc] initWithFormat:@"%@", q_str];
        
        //NSData *data = [q_str dataUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [q_str dataUsingEncoding:[NSString defaultCStringEncoding]];
        
//        NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
//        [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
        [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithoutResponse];
        [self startRequestTimeout:_currentChar];
    } else {
        currentcommand = @"";
        [self donewriting];
        [self done];
    }
    
}


- (void)p_set {
    
    // thanks for the formaating of the hex to http://stackoverflow.com/questions/5473896/objective-c-converting-an-integer-to-a-hex-value
    
    [self writing];
    
    NSString *ibmajor_str_val = [[NSString alloc] initWithFormat:@"%04X", [self.p_major.text intValue]];
    NSString *ibminor_str_val = [[NSString alloc] initWithFormat:@"%04X", [self.p_minor.text intValue]];
    
    NSString *ibmajor_str = [[NSString alloc] initWithFormat:@"AT+MARJ0x%@%@",
                             [ibmajor_str_val substringWithRange:NSMakeRange(0,2)],
                             [ibmajor_str_val substringWithRange:NSMakeRange(2,2)]];
    
    
    NSString *ibminor_str = [[NSString alloc] initWithFormat:@"AT+MINO0x%@%@",
                             [ibminor_str_val substringWithRange:NSMakeRange(0,2)],
                             [ibminor_str_val substringWithRange:NSMakeRange(2,2)]];
    
    
    NSString *adv = [NSString stringWithFormat:@"AT+ADVI%@",currentInterval];
    
    
    NSString *name_str = [[NSString alloc] initWithFormat:@"AT+NAME%@           ",
                          (self.p_name.text.length > 11 ) ? [self.p_name.text.uppercaseString substringWithRange:NSMakeRange(0, 11)] : self.p_name.text.uppercaseString];

    NSString *pass0 = @"skip";
    NSString *pass1 = @"skip";
    NSString *pass2 = @"skip";

    if (self.p_pincode.text.length == 6) {
        pass0 = @"AT+TYPE0";
        pass1 = [NSString stringWithFormat:@"AT+PASS%@",self.p_pincode.text];
        pass2 = @"AT+TYPE2";
    } else if (self.p_pincode.text.length == 0) {
        pass0 = @"AT+TYPE0";
    }
    
    NSString *showbatt = @"AT+BATC1";
    
    // format   74278bda-b644-4520-8f0c-720eaf059935
    //          0        9    14   19   24  28
    
    if (self.p_uuid.text.length == 36) {
        NSString *ib0 = [NSString stringWithFormat:@"AT+IBE0%@",
                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(0, 8)]
                         ];
        
        NSString *ib1 = [NSString stringWithFormat:@"AT+IBE1%@%@",
                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(9, 4)],
                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(14, 4)]
                         ];
        
        NSString *ib2 = [NSString stringWithFormat:@"AT+IBE2%@%@",
                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(19, 4)],
                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(24, 4)]
                         ];
        
        NSString *ib3 = [NSString stringWithFormat:@"AT+IBE3%@",
                         [[self.p_uuid.text uppercaseString] substringWithRange:NSMakeRange(28, 8)]
                         ];
        
        Queue = [NSMutableArray arrayWithObjects:@"clearerror",ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,adv,pass0,pass1,pass2,name_str,showbatt,@"checkerror",nil];
        

    } else {
        Queue = [NSMutableArray arrayWithObjects:@"clearerror",ibmajor_str,ibminor_str,adv,pass0,pass1,pass2,name_str,showbatt,@"checkerror",nil];
        
    }
    
//    Queue = [NSMutableArray arrayWithObjects:ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,nil];
//    Queue = [NSMutableArray arrayWithObjects:ibmajor_str,ibminor_str,ib0,ib1,ib2,ib3,name_str,nil];
    
    [self q_next];
    
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

-(void)p_close_window {

    
    if (currentPeripheral != Nil) {
        
        if(currentPeripheral.peripheral && ([currentPeripheral.peripheral state] == CBPeripheralStateConnecting )) {
            [self.manager cancelPeripheralConnection:currentPeripheral.peripheral];
        }
        if(currentPeripheral.peripheral && ([currentPeripheral.peripheral state] == CBPeripheralStateConnected ))
        {
            /* Disconnect if it's already connected */
            if (_currentChar != Nil) {
                [currentPeripheral.peripheral setNotifyValue:NO forCharacteristic:_currentChar];
            }
            [self.manager cancelPeripheralConnection:currentPeripheral.peripheral];
        }
    }
    
    _currentChar = Nil;
    currentPeripheral = Nil;
    peripheralIsConnected = NO;
    peripheralIsConnecting = NO;
    peripheralIsConnectedButNotRead = NO;

    [self stopConfigurationMonitoring];
    [self startConfigurationMonitoring];
    
    [ConfigView endEditing:YES];
    ConfigView.hidden = YES;
}

#pragma mark - working views


-(void) working {
    self.WorkingView.hidden = FALSE;
    [self.WorkingView setFrame: [self.view bounds]];
    [self.w_spinner startAnimating];
    
}

-(void) done {
    self.WorkingView.hidden = TRUE;
    [self.w_spinner stopAnimating];
}


- (void)writing {
    self.WriteView.hidden = FALSE;
    [self.WriteView setFrame: [self.view bounds]];
    [self.write_spinner startAnimating];
}

- (void)donewriting {
    self.WriteView.hidden = TRUE;
    [self.write_spinner stopAnimating];
}





- (IBAction)p_reset:(id)sender {
    MIN = [self.p_minor.text intValue];
    MIN++;
    self.p_major.text = @"1";
    self.p_pincode.text = LASTPASS;
    self.p_minor.text = [[NSString alloc] initWithFormat:@"%d",MIN];
    self.p_uuid.text = @"74278bda-b644-4520-8f0c-720eaf059935";
    self.p_advintslider.value = 9;
    self.p_name.text = [[NSString alloc] initWithFormat:@"GWB_%@_%@",self.p_major.text,self.p_minor.text];
    [self setAdvIntervalFromSlider];
}

- (IBAction)p_update:(id)sender {

    MIN = [self.p_minor.text intValue];
    LASTPASS = self.p_pincode.text;
    
    if (currentPeripheral != Nil) {
        
        if(currentPeripheral.peripheral && peripheralIsConnected == YES && peripheralIsConnectedButNotRead == NO)
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
                NSLog(@"Exception: %@", e);
            }
            @finally {
            }
        } else if (currentPeripheral.peripheral && peripheralIsConnected == NO) {
            if (currentPeripheral != Nil) {
                [self.manager cancelPeripheralConnection:currentPeripheral.peripheral];
            }
        }
    }
    
    [self p_close_window];



}

- (IBAction)p_sendchanges:(id)sender {
    [self p_set];
}
- (IBAction)p_reload:(id)sender {
    if (currentPeripheral != Nil) {
        if(currentPeripheral.peripheral && ([currentPeripheral.peripheral state] == CBPeripheralStateConnected )) {
            [self working];
            [self q_readall];
        }
    }
}

- (IBAction)connect_cancel_but:(id)sender {
    if (currentPeripheral != Nil) {
        if(currentPeripheral.peripheral && ([currentPeripheral.peripheral state] == CBPeripheralStateConnecting )) {
            [self.manager cancelPeripheralConnection:currentPeripheral.peripheral];
            peripheralIsConnecting = NO;
            peripheralIsConnected = NO;
            peripheralIsConnectedButNotRead = NO;
        }
    }
    [self done];
}



- (IBAction)write_cancel:(id)sender {
}
- (IBAction)p_advintslider:(id)sender {
    self.p_advint.text = [NSString stringWithFormat:@"%f", self.p_advintslider.value];
    [self setAdvIntervalFromSlider];
    
}
@end
