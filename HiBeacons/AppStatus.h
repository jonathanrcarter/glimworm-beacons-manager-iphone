//
//  AppStatus.h
//  HiBeacons
//
//  Created by Jonathan Carter on 18/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppStatus : NSObject {
    NSString *currentStatus;
}

@property (nonatomic, retain) NSString *currentStatus;

+ (id)sharedManager;

@end