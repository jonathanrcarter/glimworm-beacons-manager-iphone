//
//  CustomScrollView.m
//  HiBeacons
//
//  Created by Jonathan Carter on 21/01/2015.
//  Copyright (c) 2015 Nick Toumpelis. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

@synthesize subViewRect;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

@end
