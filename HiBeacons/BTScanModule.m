//
//  BTScanModule.m
//  HiBeacons
//
//  Created by Jonathan Carter on 30/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "BTScanModule.h"

@implementation BTScanModule

@synthesize currentStatus;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static BTScanModule *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        currentStatus = @"active";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


@end
