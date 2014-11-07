//
//  RoundedCornerView.m
//  HiBeacons
//
//  Created by Jonathan Carter on 07/11/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "RoundedCornerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RoundedCornerView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = TRUE;
        
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
