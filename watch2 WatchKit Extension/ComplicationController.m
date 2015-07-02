//
//  ComplicationController.m
//  watch2
//
//  Created by Joshua Fingert on 6/29/15.
//  Copyright © 2015 JFingert. All rights reserved.
//

#import "ComplicationController.h"
#import "ExtensionDelegate.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable NSDate *date))handler {
    handler(nil);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable NSDate *date))handler {
    handler(nil);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable CLKComplicationTimelineEntry *))handler {
    // Call the handler with the current timeline entry
    
    ExtensionDelegate* myDelegate = [[WKExtension sharedExtension] delegate];
    NSDictionary* data = [[myDelegate.complicationData valueForKey:@"ComplicationCurrentEntry"] valueForKey:@"ComplicationShortTextData"];
    NSLog(data);
    
    // Create the timeline entry object.
    CLKComplicationTimelineEntry* entry = nil;
    NSDate* now = [NSDate date];
    
    // Create the template and timeline entry.
    if (complication.family == CLKComplicationFamilyModularLarge) {
        CLKComplicationTemplateModularSmallSimpleText* textTemplate =
        [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
        textTemplate.textProvider = [CLKSimpleTextProvider
                                     textProviderWithText:data
                                     shortText:@"short text"];
        
        // Create the entry.
        entry = [CLKComplicationTimelineEntry entryWithDate:now
                                       complicationTemplate:textTemplate];
    }
    else {
        // ...configure entries for other complication families.
    }
    
    // Pass the timeline entry back to ClockKit.
    handler(entry);
    
    
//    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(__nullable NSArray<CLKComplicationTimelineEntry *> *entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(__nullable NSArray<CLKComplicationTimelineEntry *> *entries))handler {
    // Call the handler with the timeline entries after to the given date
    handler(nil);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(__nullable NSDate *updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    handler(nil);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(__nullable CLKComplicationTemplate *complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    handler(nil);
}

@end