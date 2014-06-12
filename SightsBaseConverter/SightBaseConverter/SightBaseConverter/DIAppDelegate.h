//
//  DIAppDelegate.h
//  SightBaseConverter
//
//  Created by Dmitry Ivanov on 27.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DIMainVC;
@class DISight;

@interface DIAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet DIMainVC *mainVC;
@property (nonatomic, strong) NSURL *directoryURL;

- (IBAction)saveAction:(id)sender;

- (DISight *)createAndSaveItemFromDictionary:(NSDictionary *)dict;
- (NSArray *)sightsArray;

@end
