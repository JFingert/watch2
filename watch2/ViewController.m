//
//  ViewController.m
//  watch2
//
//  Created by Joshua Fingert on 6/23/15.
//  Copyright © 2015 JFingert. All rights reserved.
//

#import "ViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <WCSessionDelegate>
@property (strong, nonatomic) IBOutlet UITextField *myTextField;
@property (strong, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *counterData;

@property (nonatomic, assign) int counter;

@end

@implementation ViewController

@synthesize myTextField;
@synthesize label;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    NSLog(@"viewdidload");
    
//    if ([CLLocationManager locationServicesEnabled]) {
//        self.locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.delegate = self;
//        [self.locationManager startUpdatingLocation];
//    } else {
//        NSLog(@"Location services are not enabled");
//    }
    self.counter = 0;
    [self getWeather];
}

NSString *latlong = @"45.532814,-122.689296";
NSString *city = @"";

- (void) getWeather {
    self.counter++;
    //fetch weather 45.532814,-122.689296
    NSString *baseUrl = @"https://api.forecast.io/forecast/";
    NSString *apiKey = @"8783b7b8e12ec2201c7d2e9f20666411/";
    NSString *urlConcat = [NSString stringWithFormat:@"%@%@%@", baseUrl, apiKey, latlong];
    NSLog(@"getWeather %@", urlConcat);
    
//    NSURL *url = [[NSURL alloc] initWithString:urlConcat];
    NSURL *url = [NSURL URLWithString:@"https://api.forecast.io/forecast/8783b7b8e12ec2201c7d2e9f20666411/45.532814,-122.689296"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
     {
         
         if (data.length > 0 && error == nil)
         {
             NSDictionary *weather = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
             NSDictionary *currently = [weather objectForKey:@"currently"];
             NSLog(@"currently: %@", [currently valueForKey:@"summary"]);
             
             
             NSString *summary = [NSString stringWithFormat:@"%@", [currently valueForKey:@"summary"]];
             NSString *temp = [NSString stringWithFormat:@"%@", [currently valueForKey:@"temperature"]];
             
             label.text = summary;
             NSString *refreshes = [NSString stringWithFormat:@"%d", self.counter ];
             
             //                 NSDictionary *applicationData = @{@"summary": summary, @"temp": temp, @"city": city};
             
             NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[summary, temp, refreshes] forKeys:@[@"summary", @"temp", @"count"]];
             
             [[WCSession defaultSession] sendMessage:applicationData
                                        replyHandler:^(NSDictionary *reply) {
                                            //handle reply from iPhone app here
                                            NSLog(@"reply! %@", reply);
                                        }
                                        errorHandler:^(NSError *error) {
                                            //catch any errors here
                                        }
              ];
         }
        }];
    [task resume];
    }

         
         
         

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler {
    NSLog(@"message!!!: %@", message);
    
    if([[message objectForKey:@"refresh"]  isEqual: @"refresh"]) {
        [self getWeather];
    }
    
    
    //Use this to update the UI instantaneously (otherwise, takes a little while)
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //        [self.counterData addObject:counterValue];
    //        [self.mainTableView reloadData];
    //    });
}
- (IBAction)manuallyGetWeather:(id)sender {
    [self getWeather];
}


@end
