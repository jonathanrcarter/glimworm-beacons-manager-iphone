//
//  NewScanCollectionViewCell.m
//  HiBeacons
//
//  Created by Jonathan Carter on 30/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "NewScanCollectionViewCell.h"

@implementation NewScanCollectionViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.backgroundColor = [UIColor clearColor];
        
        /* name text */

        self.name = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 20)];
        [self.name setTextColor:[UIColor blackColor]];
        [self.name setBackgroundColor:[UIColor clearColor]];
        [self.name setFont:[UIFont fontWithName: @"Futura" size: 14.0f]];
        [self addSubview:self.name];
        [self setNameLabel:@""];

        /* battery text */

//        self.battery = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 20)];
//        [self.battery setTextColor:[UIColor blackColor]];
//        [self.battery setBackgroundColor:[UIColor clearColor]];
//        [self.battery setFont:[UIFont fontWithName: @"Futura" size: 12.0f]];
//        [self addSubview:self.battery];

        /* icon */

        self.beaconImage =[[UIImageView alloc] initWithFrame:CGRectMake(10,40,60,60)];
        self.beaconImage.image=[UIImage imageNamed:@"icon_128.png"];
        [self addSubview:self.beaconImage];

        /* battery image */
        self.batteryImage =[[UIImageView alloc] initWithFrame:CGRectMake(80,40,20,60)];
        [self addSubview:self.batteryImage];
        
    
    }
    return self;
}


- (void)setNameLabel:(NSString*)S {
    self.name.text = S;
}


- (void)setBatteryLabel:(int)batterylevel{
    NSString *lvl = @"Very Low";
    if (batterylevel > 20) lvl = @"Low";
    if (batterylevel > 40) lvl = @"Medium";
    if (batterylevel > 60) lvl = @"High";
    if (batterylevel > 80) lvl = @"Very High";
    
    [self.battery setText: [NSString stringWithFormat : @"Battery : %@", lvl]];

    self.battery.textColor = [UIColor colorWithRed:90 green:0 blue:0 alpha:1];
    if (batterylevel > 20) self.battery.textColor = [UIColor orangeColor];
    if (batterylevel > 40) self.battery.textColor = [UIColor orangeColor];
    if (batterylevel > 60) self.battery.textColor = [UIColor colorWithRed:0 green:60 blue:0 alpha:1];
    if (batterylevel > 80) self.battery.textColor = [UIColor colorWithRed:0 green:60 blue:0 alpha:1];

    NSString *lvlimg = @"bat_verylow.png";
    if (batterylevel > 20) lvlimg = @"bat_low.png";
    if (batterylevel > 40) lvlimg = @"bat_medium.png";
    if (batterylevel > 60) lvlimg = @"bat_high.png";
    if (batterylevel > 80) lvlimg = @"bat_veryhigh.png";

    self.batteryImage.image=[UIImage imageNamed:lvlimg];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

 
 [self setAdvIntervalFromSlider];
 [self setRangeLabelFromSlider];
 connectingStringDisplay.text = [NSString stringWithFormat:@"%@", [self displayFriendlyValueOf:q_str]];
 
 
 
 */

@end
