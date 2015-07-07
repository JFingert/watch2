//
//  InterfaceController.m
//  watch2 WatchKit Extension
//
//  Created by Joshua Fingert on 6/23/15.
//  Copyright © 2015 JFingert. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import <CoreMotion/CoreMotion.h>

NSInputStream *inputStream;
NSOutputStream *outputStream;


@interface InterfaceController() <WCSessionDelegate>
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *answer;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *glanceImage;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *counterLabel;
@property (nonatomic, assign) int counter;
@end


@implementation InterfaceController: WKInterfaceController
@synthesize answer;
@synthesize city;
@synthesize summary;
@synthesize temp;
@synthesize motionManagaer;
@synthesize xVal, yVal, zVal;
@synthesize motionQue;
@synthesize socketList;
@synthesize socketName;
@synthesize socketResp;

NSMutableArray * messages;


- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
//    motionManagaer.accelerometerUpdateInterval = 30;
    motionManagaer = [[CMMotionManager alloc] init];
    motionQue = [NSOperationQueue mainQueue];
    
    [self initNetworkCommunication];
    messages = [[NSMutableArray alloc] init];
}

- (void)willActivate {
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
//    if (motionManagaer.accelerometerAvailable == false) {
//        NSLog(@"motion not supported");
//    }
//    if (motionManagaer.accelerometerAvailable == true) {
//        NSLog(@"accelerometer!");
//        NSOperationQueue* accelerometerQueue = [[NSOperationQueue alloc] init];
//        CMAccelerometerHandler handler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
//            NSLog(@"Accelerometer realtime values");
//            NSLog(@"x=%f", accelerometerData.acceleration.x);
//            NSLog(@"y=%f", accelerometerData.acceleration.y);
//            NSLog(@"z=%f", accelerometerData.acceleration.z);
//            NSLog(@"  ");
//        };
//        [motionManagaer startAccelerometerUpdatesToQueue:accelerometerQueue withHandler:[handler copy]];
//        
//    };

    NSLog(@"willActivate");
    
    
    [motionManagaer setAccelerometerUpdateInterval:0.1];
    [motionManagaer startAccelerometerUpdatesToQueue:motionQue withHandler:^(CMAccelerometerData *accel, NSError *error){
//        CMAcceleration a = accel.acceleration;
        NSLog(@"a.x %@", accel);
//        NSLog(@"a.y %f", a.y);
//        NSLog(@"a.z %f", a.z);
        if(!error) {
            NSLog(@"accel error!!!!!!!!!!!!! %@", error);
        } else {
            NSLog(@"Else!");
        }
    }];
    
    [motionManagaer startAccelerometerUpdates];
    NSObject *x = [motionManagaer accelerometerData];
    
    NSLog(@"x! %@", x);
}

- (void)didDeactivate {
    [super didDeactivate];
}

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler {
    NSLog(@"message: %@", message);

//    summary.text = [message objectForKey:@"summary"];
//    temp.text = [message objectForKey:@"temp"];
//    city.text = [message objectForKey:@"count"];
    
    
    //Use this to update the UI instantaneously (otherwise, takes a little while)
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [self.counterData addObject:counterValue];
//        [self.mainTableView reloadData];
//    });
}

- (void)session:(nonnull WCSession *)session didFinishFileTransfer:(nonnull WCSessionFileTransfer *)fileTransfer error:(nullable NSError *)error {
    // This method is called on the sending side when the file has successfully transfered.
    if (error) {
        NSLog(@"There was an error transferring the file: %@", error);
    }
    else {
        NSLog(@"The file was transfered succesfully!");
    }
}

//#pragma mark IBOutlets for Watch interface

- (IBAction)refreshButton {
    [self callForWeatherUpdate];
    NSLog(@"button click!");
}

- (void) callForWeatherUpdate {
    NSLog(@"callForWeather!");
    NSString *refresh = @"refresh";
    NSDictionary *refreshData = [[NSDictionary alloc] initWithObjects:@[refresh] forKeys:@[@"refresh"]];
    [[WCSession defaultSession] sendMessage:refreshData
                               replyHandler:^(NSDictionary *reply) {
                                   //handle reply from iPhone app here
                                   NSLog(@"reply! %@", reply);
                                   summary.text = [reply objectForKey:@"summary"];
                                   temp.text = [reply objectForKey:@"temp"];
                                   city.text = [reply objectForKey:@"count"];
                               }
                               errorHandler:^(NSError *error) {
                                   NSLog(@"ERROR! %@", error);
                               }
     ];
}

//socket stuff


- (void) sendMessage: (NSString *) message {
    NSString *response  = [NSString stringWithFormat:@"msg:%@", message];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 80, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
    //join
    NSString *response  = [NSString stringWithFormat:@"iam:%@", @"joshua"];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    NSLog(@"stream event %i", streamEvent);
    
    typedef enum {
        NSStreamEventNone = 0,
        NSStreamEventOpenCompleted = 1 << 0,
        NSStreamEventHasBytesAvailable = 1 << 1,
        NSStreamEventHasSpaceAvailable = 1 << 2,
        NSStreamEventErrorOccurred = 1 << 3,
        NSStreamEventEndEncountered = 1 << 4
    };
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            break;
            
        default:
            NSLog(@"Unknown event");
    }
}

- (void) messageReceived:(NSString *)message {
    
    [messages addObject:message];
//    NSLog(messages);

    
}




- (IBAction)bye {
    [self sendMessage:@"hello"];
}

- (IBAction)hi {
    [self sendMessage:@"goodbye"];
}
@end



