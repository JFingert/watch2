//
//  Entity.h
//  watch2
//
//  Created by Joshua Fingert on 7/2/15.
//  Copyright © 2015 JFingert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * temp;
@property (nonatomic, retain) NSDate * created;

@end

NS_ASSUME_NONNULL_END

#import "Entity+CoreDataProperties.h"
