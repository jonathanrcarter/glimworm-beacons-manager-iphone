//
//  NewScanCollectionViewCell.h
//  HiBeacons
//
//  Created by Jonathan Carter on 30/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewScanCollectionViewCell : UICollectionViewCell


@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *battery;
@property (nonatomic, strong) UIImageView *batteryImage;
@property (nonatomic, strong) UIImageView *beaconImage;

- (void)setNameLabel:(NSString*)S;
- (void)setBatteryLabel:(int)batterylevel;

@end
