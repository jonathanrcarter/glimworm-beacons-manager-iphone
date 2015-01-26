//
//  NewScanViewController.h
//  HiBeacons
//
//  Created by Jonathan Carter on 30/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppStatus.h"
#import "NewScanBeaconViewController.h"
@import CoreLocation;
@import CoreBluetooth;


@interface NewScanViewController : UIViewController <
//    CLLocationManagerDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    //CBPeripheralManagerDelegate,
    CBCentralManagerDelegate,
    //CBPeripheralDelegate,
    UIApplicationDelegate,
    NewScanBeaconViewControllerDelegate> {
    NSString *LASTPASS;
}

@property (nonatomic, retain) NSString *LASTPASS;
@property (weak, nonatomic) IBOutlet UISwitch *Switch;
- (IBAction)Switch:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewCell *cviewcell;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *cviewflow;

@property (weak, nonatomic) IBOutlet UIView *container;

@end
