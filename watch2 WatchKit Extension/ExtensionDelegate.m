//
//  ExtensionDelegate.m
//  watch2 WatchKit Extension
//
//  Created by Joshua Fingert on 6/23/15.
//  Copyright © 2015 JFingert. All rights reserved.
//

#import "ExtensionDelegate.h"

@implementation ExtensionDelegate

@synthesize complicationData;
@synthesize ComplicationCurrentEntry;

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
    ComplicationCurrentEntry = @{@"ComplicationShortTextData": @"test data"};
    complicationData = [NSDictionary dictionaryWithObjectsAndKeys:ComplicationCurrentEntry,@"ComplicationCurrentEntry", nil];
    NSLog(@"didfinishlaunching!");
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

@end
