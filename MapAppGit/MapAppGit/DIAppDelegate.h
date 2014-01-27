//
//  DIAppDelegate.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListItem.h"

@interface DIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (ListItem *)createAndSaveItemWithName:(NSString *)name description:(NSString *)description imageData:(NSData *)data;
- (NSArray *)dataArray;

@end
