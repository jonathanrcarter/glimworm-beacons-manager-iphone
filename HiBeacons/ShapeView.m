//
//  ShapeView.m
//  HiBeacons
//
//  Created by Jonathan Carter on 31/07/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "ShapeView.h"

@implementation ShapeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 4.0);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor grayColor].CGColor);
    CGRect rectangle = CGRectMake(-200 ,0,720,720);
    CGContextAddEllipseInRect(context, rectangle);
//    CGContextStrokePath(context);

    CGContextSetFillColorWithColor(context,
                                   [UIColor grayColor].CGColor);
    CGContextFillPath(context);
    
    [self bottomToTop];

}
- (void)bottomToTop {
    [self setFrame:CGRectMake(-100.0f, 700.0f , 520.0f, 720.0f)];
    self.alpha = 1.0;
    [UIView animateWithDuration: 6.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self setFrame:CGRectMake(-100.0f, -200.0f , 520.0f, 720.0f)];
                     }
                     completion:^(BOOL finished){
                     }];
    
    [UIView animateWithDuration: 4.0
                          delay: 3.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self bottomToTop];
                     }];
    
}



@end
