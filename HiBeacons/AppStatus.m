//
//  AppStatus.m
//  HiBeacons
//
//  Created by Jonathan Carter on 18/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "AppStatus.h"

@implementation AppStatus

@synthesize currentStatus;

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
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


@end
