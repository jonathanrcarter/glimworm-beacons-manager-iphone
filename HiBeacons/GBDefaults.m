//
//  GBDefaults.m
//  HiBeacons
//
//  Created by Jonathan Carter on 19/10/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "GBDefaults.h"

@implementation GBDefaults

@synthesize uuid, minor, major;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.major = [aDecoder decodeObjectForKey:@"major"];
        self.minor = [aDecoder decodeObjectForKey:@"minor"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.major forKey:@"major"];
    [aCoder encodeObject:self.minor forKey:@"minor"];
}



@end
