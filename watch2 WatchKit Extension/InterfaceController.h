//
//  InterfaceController.h
//  watch2 WatchKit Extension
//
//  Created by Joshua Fingert on 6/23/15.
//  Copyright © 2015 JFingert. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <CoreMotion/CoreMotion.h>

@interface InterfaceController : WKInterfaceController
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *city;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *summary;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *temp;

@property (strong, nonatomic) IBOutlet WKInterfaceButton *getWeather;

@property (nonatomic, strong) CMMotionManager *motionManagaer;
@property (nonatomic, strong) NSOperationQueue *motionQue;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *xVal;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *yVal;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *zVal;

@end
