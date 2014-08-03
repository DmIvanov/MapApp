//
//  DISightsManager.h
//  
//
//  Created by Dmitry Ivanov on 15.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DISight;

@interface DISightsManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DISightsManager *)sharedInstance;
- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

- (NSArray *)dataArray;

- (NSString *)timeStringFromDate:(NSDate *)date;
- (NSString *)insideDateStringFromDate:(NSDate *)date;
- (NSString *)outsideDateStringFromDate:(NSDate *)date;
- (NSString *)openCloseStringFromDateOpen:(NSDate *)open dateClose:(NSDate *)close;
- (NSString *)weekDayFromDateString:(NSString *)dateString;

//no idea how to make coreData saving works with this stuff...
//- (void)setValue:(id)value forKey:(NSString *)key forObjectWithId:(NSManagedObjectID *)objId;
//temporary dirty way without coreData instead
- (void)setSightType:(NSNumber *)typeValue forSight:(DISight *)sight;

@end
