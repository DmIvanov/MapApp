//
//  DIAppDelegate.m
//  SightBaseConverter
//
//  Created by Dmitry Ivanov on 27.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIAppDelegate.h"

#import "DIMainVC.h"
#import "DISight.h"

@implementation DIAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _mainVC = [DIMainVC new];
    [self.window.contentView addSubview:_mainVC.view];
    _mainVC.view.frame = ((NSView *)self.window.contentView).bounds;
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "DI.SightBaseConverter" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"DI.SightBaseConverter"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SightBaseConverter" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSURL *directory = [_directoryURL URLByAppendingPathComponent:@"SightsBase"];
    NSError *error = nil;
    
    NSDictionary *properties = [directory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[directory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [directory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [directory URLByAppendingPathComponent:@"SightsBase.sqlite"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (DISight *)createAndSaveItemFromDictionary:(NSDictionary *)dict {
    
    DISight *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"DISight"
                                                      inManagedObjectContext:self.managedObjectContext];
    if (newItem) {
        
        [self fillSight:newItem fromDictionary:dict];
        
        NSError *error;
        if ([self.managedObjectContext save:&error]) {
            NSLog(@"AppDelegate: ListItem %@ successfully saved", newItem.name);
        }
        else {
            NSLog(@"AppDelegate: Failed to save the context. Error = %@", error);
        }
    }
    else {
        NSLog(@"AppDelegate: Failed to create new ListItem.");
    }
    
    return newItem;
}

- (NSArray *)sightsArray {
    
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DISight"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request
                                                              error:&error];
    if (error) {
        NSLog(@"AppDelegate: Failed to execute NFetchRequest. Error = %@", error);
    }
    
    return items;
}

- (void)fillSight:(DISight *)sight fromDictionary:(NSDictionary *)dict {
    
    sight.name = dict[@"Name"] != nil ? dict[@"Name"] : @"";
    sight.history = dict[@"History"] != nil ? dict[@"History"] : @"";
    sight.latitudeNumber = @(30.0);//[self recognizeLatitudeFromCoordString:dict[@"Coordinates"]];
    sight.longitudeNumber = @([self recognizeLongitudeFromCoordString:dict[@"Coordinates"]]);
    sight.shortDescriptionString = dict[@"ShortDescription"] != nil ? dict[@"ShortDescription"] : @"";
    sight.scheduleString = dict[@"ScheduleString"] != nil ? dict[@"ScheduleString"] : @"";
    sight.scheduleArrayString = dict[@"Schedule"] != nil ? dict[@"Schedule"] : @"";
    sight.priceNumber = @([dict[@"Price"] doubleValue]);
    sight.sightType = [dict[@"SightType"] unsignedIntegerValue];
    sight.priceCategories = dict[@"PriceCategories"] != nil ? dict[@"PriceCategories"] : @"";
    sight.priceAdditional = dict[@"PriceAdditional"] != nil ? dict[@"PriceAdditional"] : @"";
    sight.about = dict[@"About"] != nil ? dict[@"About"] : @"";
    sight.now = dict[@"Now"] != nil ? dict[@"Now"] : @"";
    sight.direction = dict[@"Direction"] != nil ? dict[@"Direction"] : @"";
    sight.interesting = dict[@"Interesting"] != nil ? dict[@"Interesting"] : @"";
    sight.mustSee = dict[@"MustSee"] != nil ? dict[@"MustSee"] : @"";
    sight.address = dict[@"Address"] != nil ? dict[@"Address"] : @"";
    sight.phones = dict[@"Phones"] != nil ? dict[@"Phones"] : @"";
    sight.metro = dict[@"Metro"] != nil ? dict[@"Metro"] : @"";
}

- (double)recognizeLatitudeFromCoordString:(NSString *)string {
    
    NSArray *components = [string componentsSeparatedByString:@" "];
    if (components.count > 1) {
        double lat = [(NSString *)components[0] doubleValue];
        return lat;
    }
    return 0.;
}

- (double)recognizeLongitudeFromCoordString:(NSString *)string {
    
    NSArray *components = [string componentsSeparatedByString:@" "];
    if (components.count > 1)
        return [components[1] doubleValue];
    return 0.;
}

@end
