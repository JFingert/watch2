//
//  ExtensionDelegate.h
//  watch2 WatchKit Extension
//
//  Created by Joshua Fingert on 6/23/15.
//  Copyright © 2015 JFingert. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>
@property (strong, nonatomic) NSDictionary *complicationData;
@property (strong, nonatomic) NSDictionary *ComplicationCurrentEntry;
@end
