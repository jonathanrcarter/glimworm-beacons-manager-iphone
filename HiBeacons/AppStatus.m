//
//  AppStatus.m
//  HiBeacons
//
//  Created by Jonathan Carter on 18/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "AppStatus.h"
#import "BTDeviceModel.h"

@implementation AppStatus

@synthesize currentStatus;
//@synthesize peripheral;
@synthesize ItemArray;
@synthesize manager;
@synthesize currentPeripheral;
//@synthesize peripheralisconnected;
//@synthesize peripheralisconnectedButNotRead;
//@synthesize peripheralisconnecting;
//@synthesize _currentChar;
//@synthesize connectActive;
//@synthesize currentcommand;
//@synthesize currentfirmware;
@synthesize isWorking;
@synthesize MIN;
@synthesize LASTPASS;
@synthesize incoming_uuid;
//@synthesize currentInterval;
//@synthesize currentRange;
//@synthesize q_error;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static AppStatus *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        currentStatus = @"active";
        ItemArray = Nil;
        manager = Nil;
        currentPeripheral = Nil;
        isWorking = FALSE;
        MIN = 0;
        LASTPASS = @"";
        incoming_uuid = @"00000000-0000-0000-0000-000000000000";
    }
    return self;
}



- (void)dealloc {
    // Should never be called, but just here for clarity really.
}



@end
