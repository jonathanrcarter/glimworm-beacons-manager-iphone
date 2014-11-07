//
//  AppStatus.h
//  HiBeacons
//
//  Created by Jonathan Carter on 18/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTDeviceModel.h"
@import CoreLocation;
@import CoreBluetooth;
#import "GBDefaults.h"


@interface AppStatus : NSObject {
    NSString *currentStatus;
    CBCentralManager *manager;
    NSMutableArray *ItemArray;
    BTDeviceModel* currentPeripheral;
    bool isWorking;
    int MIN;
    NSString *LASTPASS;
    NSString *incoming_uuid;
}

@property (nonatomic, retain) NSString *currentStatus;
@property (nonatomic, strong) CBCentralManager *manager;
@property  (nonatomic, strong) NSMutableArray *ItemArray;
@property  (nonatomic, strong) BTDeviceModel* currentPeripheral;
@property  (nonatomic) bool isWorking;
@property  (nonatomic) int MIN;
@property  (nonatomic, strong) NSString *LASTPASS;
@property  (nonatomic, strong) NSString *incoming_uuid;


+ (id)sharedManager;



@end