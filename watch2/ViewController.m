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
#import <MagicalRecord/MagicalRecord.h>
#import "Entity.h"

@interface ViewController () <WCSessionDelegate>
@property (strong, nonatomic) IBOutlet UITextField *myTextField;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *counterData;
@property (nonatomic, assign) int counter;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController

@synthesize myTextField;
@synthesize label;
@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
//    self.fetchedResultsController = [Entity MR_fetchAllSortedBy:@"timestamp" ascending:NO withPredicate:nil groupBy:nil delegate:self];
//    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Entity"];
    
    
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
             
//             Entity *entity = [Entity MR_createEntity];
//             entity.created = [NSDate date];
//             entity.temp = temp;
             
//             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *defaultContext){
             
             

                 
//             }];
//             Entity *entity = [Entity MR_createEntity];
             
//             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//                 Entity *localEntity = [Entity MR_createEntityInContext:localContext];
//                 localEntity.created = [NSDate date];
//                 localEntity.temp = temp;
//             } completion:^(BOOL success, NSError *error) {
//                 // This block runs in main thread
//             }];
             
//             NSLog(@"%@", [Entity MR_findAll]);

             
//             NSArray * tempFound = [Entity MR_findAll];
             
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

//- (void)saveContext {
//    [[NSManagedObjectContext defaultContext] saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
//        if (success) {
//            NSLog(@"You successfully saved your context.");
//        } else if (error) {
//            NSLog(@"Error saving context: %@", error.description);
//        }
//    }];
//}

         
         
         

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler {
//    NSLog(@"message!!!: %@", message);
    
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

- (IBAction)triggerFile:(id)sender {
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"cx" withExtension:@"jpg"];
//    NSLog(@"triggerFile: ", fileUrl);
    //    [[WCSessionFileTransfer defaultFileSession] transferFile:fileUrl metadata:<#(nullable NSDictionary<NSString *,id> *)#>metadata]
    [[WCSession defaultSession] transferFile:fileUrl metadata:nil];
}

- (IBAction)getCoreData:(id)sender {
    [self latestWeather];
}

- (void) latestWeather {
    NSArray *entities = [Entity MR_findAllSortedBy:@"created"
                                         ascending:NO];
    NSMutableArray *latest = [NSMutableArray array];

//    NSLog(@"getCoreData! %@", entities);
    for (int i = 0; i < 3; i++) {
        NSLog(@"created! %@",[[entities objectAtIndex:i] created]);
//        NSLog([[entities objectAtIndex:i] valueForKey:@"created"]);
        NSDate *created = [[entities objectAtIndex:i] created];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:MM, M/d"];
        
        //Optionally for time zone conversions
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
        
        NSString *stringFromDate = [formatter stringFromDate:created];
        NSString *temp = [[entities objectAtIndex:i] valueForKey:@"temp"];
//        NSLog(@"temp %@", temp, @"date %@", stringFromDate);
//        NSLog(created);
        NSString *weatherString = [[stringFromDate stringByAppendingString:@" - "]stringByAppendingString:temp];
        [latest insertObject: weatherString atIndex: i];
//        NSLog(@"weatherString %@", weatherString);
//        NSLog(@"latest: %@", latest);
    }
    
    NSArray *tempObjs = @[[latest objectAtIndex:0], [latest objectAtIndex:1], [latest objectAtIndex:2]];
    
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:tempObjs forKeys:@[@"one", @"two", @"three"]];
    
    [[WCSession defaultSession] sendMessage:applicationData
                               replyHandler:^(NSDictionary *reply) {
                                   //handle reply from iPhone app here
                                   NSLog(@"reply! %@", reply);
                               }
                               errorHandler:^(NSError *error) {
                                   //catch any errors here
                                   NSLog(@"ERROR!!! %@", error);
                               }
     ];
}
//}];
//}

//core data

//+ (id)insertNewObjectForEntityForName:(NSString *)entityName {
//    inManagedObjectContext:(NSManagedObjectContext *)context
//}


@end
