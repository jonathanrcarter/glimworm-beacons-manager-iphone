//
//  BTScanModule.h
//  HiBeacons
//
//  Created by Jonathan Carter on 30/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <Foundation/Foundation.h>


@import CoreLocation;
@import CoreBluetooth;


@interface BTScanModule : NSObject <    CLLocationManagerDelegate,
                                        CBPeripheralManagerDelegate,
                                        CBCentralManagerDelegate,
                                        CBPeripheralDelegate,
                                        UIApplicationDelegate>
{
    NSString *currentStatus;
}

@property (nonatomic, retain) NSString *currentStatus;

+ (id)sharedManager;

@end
