//
//  PersonModel.m
//  glimworm_ibeacon
//
//  Created by Jonathan Carter on 22/12/2013.
//  Copyright (c) 2013 Jonathan Carter. All rights reserved.
//

#import "BTDeviceModel.h"
@import CoreLocation;
@import CoreBluetooth;

@implementation BTDeviceModel

@synthesize name;
@synthesize UUID;
@synthesize uuidref;
@synthesize RSSI;
@synthesize peripheral;
@synthesize ib_uuid;
@synthesize ib_major;
@synthesize ib_minor;
@synthesize found;
@synthesize ID;

-(void) dealloc {
//    [name release];
//    [occupation release];
//    [super dealloc];
}

@end
