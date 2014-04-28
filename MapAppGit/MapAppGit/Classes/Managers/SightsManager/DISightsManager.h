//
//  DISightsManager.h
//  
//
//  Created by Dmitry Ivanov on 15.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ListItem;
@class DISight;


@interface DISightsManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DISightsManager *)sharedInstance;
- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

- (ListItem *)createAndSaveItemWithName:(NSString *)name description:(NSString *)description imageData:(NSData *)data;
- (NSArray *)dataArray;

- (NSArray *)recognizedSights;

@end
