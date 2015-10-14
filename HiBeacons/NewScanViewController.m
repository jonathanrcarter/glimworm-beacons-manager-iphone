//
//  NewScanViewController.m
//  HiBeacons
//
//  Created by Jonathan Carter on 30/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "NewScanViewController.h"
#import "BTDeviceModel.h"
#import "ShapeView.h"
#import "NewScanCollectionViewCell.h"
#import "NewScanBeaconViewController.h"

@interface NewScanViewController ()

/* UI */
@property (weak, nonatomic) IBOutlet UISwitch *MainSwitch;
@property (weak, nonatomic) IBOutlet UIView *Collection;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *CollectionOutlet;


@end

@implementation NewScanViewController
@synthesize LASTPASS;
@synthesize Switch;
@synthesize collectionView;


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
    Switch.on = NO;
    [self.collectionView registerClass:[NewScanCollectionViewCell class] forCellWithReuseIdentifier:@"BeaconCell"];

}
- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"view scanner did appear");
    [self resumeConfigurationMonitoring];
}
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"view scanner did DIS-appear");
    [self pauseConfigurationMonitoring];
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

#pragma mark - Beacon configuration - missing functions

- (void) updateBLEtable {

//    NSLog(@"Update Table");
//    NSLog(@"Array is now: %@", appStatus.ItemArray);

    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
}
- (void) updateBLEtableIfNeeded {
    
//    NSLog(@"Update Table");
//    NSLog(@"Array is now: %@", appStatus.ItemArray);
    
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    
}


#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [[AppStatus sharedInstance].ItemArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NewScanCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"BeaconCell" forIndexPath:indexPath];

    BTDeviceModel *btm = [[AppStatus sharedInstance].ItemArray objectAtIndex:indexPath.row];

    [cell setNameLabel:btm.name];
    [cell setBatteryLabel:btm.batterylevel];

    return cell;
}

// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/


#pragma mark - UICollectionViewDelegate

UINavigationController *navigationController;
//- (void)navigationController:(UINavigationController*)navigationController;
//- (void)userDetails:(NewScanBeaconViewController*)userDetails;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cv::didSelectItemAtIndexPath ");

    // TODO: Select Item

    BTDeviceModel *btm = [[AppStatus sharedInstance].ItemArray objectAtIndex:indexPath.row];
    [AppStatus sharedInstance].currentPeripheral = btm;
    
    NewScanBeaconViewController * userDetails = [[NewScanBeaconViewController alloc] init];
    
    userDetails.delegate = self;
    
    navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:userDetails];

    navigationController.navigationBar.hidden = YES;
    
    [self presentViewController:navigationController animated:YES completion: nil];
    [self pauseConfigurationMonitoring];
    
}

- (void)addItemViewController:(NewScanBeaconViewController *)controller didFinishEnteringItem:(NSString *)item
{
    NSLog(@"This was returned from NewScanBeaconViewController BBB %@",item);
    //[self resumeConfigurationMonitoring];
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *searchTerm = self.searches[indexPath.section]; FlickrPhoto *photo =
//    self.searchResults[searchTerm][indexPath.row];
    // 2
    CGSize retval = CGSizeMake(140, 100);
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 2, 5, 2);
}
#pragma mark - Updating the ITEMS array

-(void)insertObject:(BTDeviceModel *)p inItemArrayAtIndex:(NSUInteger)index {
    [[AppStatus sharedInstance].ItemArray insertObject:p atIndex:index];
}

-(void)removeObjectFromItemArrayAtIndex:(NSUInteger)index {
    [[AppStatus sharedInstance].ItemArray removeObjectAtIndex:index];
}

-(NSArray*)itemArray {
    return [AppStatus sharedInstance].ItemArray;
}

-(void)clearItemArray {
    if (![AppStatus sharedInstance].ItemArray) {
        [AppStatus sharedInstance].ItemArray = [NSMutableArray array];
    } else {
        [[AppStatus sharedInstance].ItemArray removeAllObjects];
    }
}

#pragma mark - Beacon configuration
- (IBAction)Switch:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on) {
        [self startConfigurationMonitoring];
    } else {
        [self stopConfigurationMonitoring];
    }
}


//- (void)changeConfigState:sender
//{
//    UISwitch *theSwitch = (UISwitch *)sender;
//    if (theSwitch.on) {
//        [self startConfigurationMonitoring];
//    } else {
//        [self stopConfigurationMonitoring];
//    }
//}

- (void)startConfigurationMonitoring
{
    
    
    [self clearItemArray];
    
    if (![AppStatus sharedInstance].manager) {
        
        [AppStatus sharedInstance].manager = [[CBCentralManager alloc] initWithDelegate:self
                                                                                  queue:nil
                                                                                options:@{CBCentralManagerOptionRestoreIdentifierKey : @"00000000-0000-0000-0000-000000000003"}];
        [AppStatus sharedInstance].manager.delegate = self;
    } else {
        [self startScan];
        
    }
    [self updateBLEtable];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    NSLog(@"Will restore state %@",dict);
}

- (void)pauseConfigurationMonitoring
{
    if (Switch.on) {
        [self stopScan];
        [self updateBLEtable];
    }

}

- (void)resumeConfigurationMonitoring
{
    if (Switch.on) {
        [self startScan];
        [self updateBLEtable];
    }
    
}

- (void)stopConfigurationMonitoring
{
    
    [self stopScan];
    [self updateBLEtable];
    Switch.on = NO;
    
    //    [self.beaconTableView beginUpdates];
    //    if (deletedSections)
    //        [self.beaconTableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationFade];
    //    [self.beaconTableView endUpdates];
//    [self clearItemArray];
    
    NSLog(@"Turned off config.");
    
}

- (void)startScan {
    
//    ShapeView *myView = [[ShapeView alloc] initWithFrame: CGRectMake(20, 100, 280, 250)];
//    [self.view addSubview:myView];
    
    [AppStatus sharedInstance].manager.delegate = self;
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES};
    [[AppStatus sharedInstance].manager scanForPeripheralsWithServices:nil options:options];
    Switch.on = YES;

    NSLog(@"Scanning Bluetooth");
    
}
- (void)stopScan {
    [[AppStatus sharedInstance].manager stopScan];
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

- (NSString *) hex2dec_min256:(NSString *)HEX {
    
    unsigned int ibmajor;
    NSScanner* scanner = [NSScanner scannerWithString:HEX];
    [scanner scanHexInt:&ibmajor];
    NSString *dec_string = [[NSString alloc] initWithFormat:@"%u", (256 - ibmajor)];
    return dec_string;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"state update");
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog( @"state update powered on");
//        [self startScan];
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
//- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)pm
//{
//    NSLog(@"peripheral state update %d",pm.state);
//}

int lock = 0;

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    if (lock == 1) return;
    lock = 1;
    
    NSString *_name = [[NSString alloc] initWithFormat:@"%@", peripheral.name];
    NSString *_uuid = [peripheral.identifier UUIDString];
    NSDictionary* servicedata = [advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
    
    int batt = 0;
    
    BOOL fnd = NO;
    CBUUID *_key;
    for (_key in [servicedata allKeys]){
        NSData *obj;
        obj = [servicedata objectForKey: _key];
        //NSLog(@"key : %@  value : %@",_key.data,obj);
        
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
        lock = 0;
        return;
    }
    
    @try {
        
        if (_uuid == NULL) _uuid = @"";
        if (_name == NULL) _name = @"";
        
        for (int i=0; i < [[AppStatus sharedInstance].ItemArray count]; i++) {
            BTDeviceModel *m = [[AppStatus sharedInstance].ItemArray objectAtIndex:i];
            
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
                [self updateBLEtableIfNeeded];
                lock = 0;
                return;
            }
        }
        
//        [peripheral discoverServices:Nil];
        
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
        [self insertObject:pm inItemArrayAtIndex:[[AppStatus sharedInstance].ItemArray count]];
        //        [self insertObject:pm inItemArrayAtIndex:0];
        //        [self findItemInAccountArray:pm];
        
        
    }
    @catch (NSException * e) {
        //NSLog(@"Exception: %@", e);
    }
    @finally {
        //        NSLog(@"Array is now: %@", self.ItemArray);
        [self updateBLEtableIfNeeded];
        
        
    }
    lock = 0;
}

@end
