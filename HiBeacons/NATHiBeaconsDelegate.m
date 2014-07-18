//
//  NATHiBeaconsDelegate.m
//  HiBeacons
//
//  Created by Nick Toumpelis on 2013-10-06.
//  Copyright (c) 2013-2014 Nick Toumpelis.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NATHiBeaconsDelegate.h"
#import "AppStatus.h"

@implementation NATHiBeaconsDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    AppStatus *Status = [AppStatus sharedManager];
    Status.currentStatus = @"not active";
    
    NSLog(@"application RESIGNED ACTIVE ");

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"application ENTER BG ");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"application ENTER FG ");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     this is called when the application returns from hacing the pairing window
     */
    NSLog(@"applicationDidBecomeActive");
    AppStatus *Status = [AppStatus sharedManager];
    Status.currentStatus = @"active";

//    UIViewController* root = _window.rootViewController;
//    UINavigationController* navController = (UINavigationController*)root;
//    NATViewController * mycontroller = (NATViewController *)[[navController viewControllers] objectAtIndex:0];
//    [mycontroller a];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"application WILL TERMINATE ");
}

@end
