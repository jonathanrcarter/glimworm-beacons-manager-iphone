//
//  SpinnerView.m
//  HiBeacons
//
//  Created by Jonathan Carter on 18/10/2014.
//  Copyright (c) 2014 Nick Toumpelis. All rights reserved.
//

#import "SpinnerView.h"

@implementation SpinnerView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) cancel {
    [self.delegate SpinnerView:self cancel: nil];
}

- (void)cancelClicked:(UIButton*)button
{
    NSLog(@"Button  clicked.");
    [self cancel];
}

+(SpinnerView *)loadSpinnerIntoView:(UIView *)superView{
    // Create a new view with the same frame size as the superView
    SpinnerView *spinnerView = [[SpinnerView alloc] initWithFrame:superView.bounds];
    
    // If something's gone wrong, abort!
    if(!spinnerView){ return nil; }
    
    // Create a new image view, from the image made by our gradient method
    UIImageView *background = [[UIImageView alloc] initWithImage:[spinnerView addBackground]];
    
    // Make a little bit of the superView show through
    background.alpha = 0.7;
    
    [spinnerView addSubview:background];

    UIColor *lightGreenColour = [UIColor colorWithRed:109/255.0 green:136/255.0 blue:26/255.0 alpha:1.0];
    
    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(60, 180, 200, 150)];
    [vw setBackgroundColor:[UIColor whiteColor]];
    [vw setBackgroundColor:lightGreenColour];
    [spinnerView addSubview:vw];

    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(80, 200, 160, 50)];
    [cancel setBackgroundColor:[UIColor blackColor]];
    [cancel setTitle: @"Cancel" forState: UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel addTarget:spinnerView action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [spinnerView addSubview:cancel];

//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 260, 160, 50)];
//    [lbl setText: @"Connecting" ];
//    [lbl setTextColor:[UIColor whiteColor]];
//    [spinnerView addSubview:lbl];
    
    // This is the new stuff here ;)
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    
    // Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    
    // Place it in the middle of the view
    indicator.center = superView.center;
    
    // Add it into the spinnerView
    [spinnerView addSubview:indicator];
    
    // Start it spinning! Don't miss this step
    [indicator startAnimating];
    
    
    // Add the spinner view to the superView. Boom.
    [superView addSubview:spinnerView];

    
    
    
    
    
    // Create a new animation
    CATransition *animation = [CATransition animation];
    
    // Set the type to a nice wee fade
    [animation setType:kCATransitionFade];
    
    // Add it to the superView
    [[superView layer] addAnimation:animation forKey:@"layerAnimation"];
    return spinnerView;
}


-(void)removeSpinner{
    // Add this in at the top of the method. If you place it after you've remove the view from the superView it won't work!
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[[self superview] layer] addAnimation:animation forKey:@"layerAnimation"];
    
    // Take me the hells out of the superView!
    [super removeFromSuperview];
}

- (UIImage *)addBackground{
    // Create an image context (think of this as a canvas for our masterpiece) the same size as the view
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
    
    // Our gradient only has two locations - start and finish. More complex gradients might have more colours
    size_t num_locations = 2;
    
    // The location of the colors is at the start and end
    CGFloat locations[2] = { 0.0, 1.0 };
    
    // These are the colors! That's two RBGA values
    CGFloat components[8] = {
        0.4,0.4,0.4, 0.8,
        0.1,0.1,0.1, 0.5 };
    
    // Create a color space
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    
    // Create a gradient with the values we've set up
    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
    
    // Set the radius to a nice size, 80% of the width. You can adjust this
    float myRadius = (self.bounds.size.width*.8)/2;
    
    // Now we draw the gradient into the context. Think painting onto the canvas
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, kCGGradientDrawsAfterEndLocation);
    
    // Rip the 'canvas' into a UIImage object
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // And release memory
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    
    // … obvious.
    return image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
