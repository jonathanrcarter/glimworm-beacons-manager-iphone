//
//  GBDefaults.h
//  HiBeacons
//
//  Created by Jonathan Carter on 19/10/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBDefaults : NSObject <NSCoding>

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *major;
@property (nonatomic, copy) NSString *minor;
@end
