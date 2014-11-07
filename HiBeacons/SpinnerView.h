//
//  SpinnerView.h
//  HiBeacons
//
//  Created by Jonathan Carter on 18/10/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SpinnerView;

@protocol SpinnerViewDelegate <NSObject>
- (void)SpinnerView:(SpinnerView *)controller cancel:(NSString *)item;
@end

@interface SpinnerView : UIView

@property  (nonatomic, weak) id <SpinnerViewDelegate> delegate;
+(SpinnerView *)loadSpinnerIntoView:(UIView *)superView;
-(void)removeSpinner;

@end
