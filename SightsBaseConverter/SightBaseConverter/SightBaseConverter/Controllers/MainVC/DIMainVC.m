//
//  DIMainVC.m
//  SightBaseConverter
//
//  Created by Dmitry Ivanov on 27.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIMainVC.h"

#import "DIAppDelegate.h"
#import "DIStringFormatter.h"

#import "DISight.h"
#import "DIHint.h"

#define FOLDER_PATH_DEFAULTS_KEY        @"sightBaseConverter_folderPath"

@interface DIMainVC ()
{
    NSString *_directoryString;
}

@property (nonatomic, strong) IBOutlet NSButton *buttonFolder;
@property (nonatomic, strong) IBOutlet NSTextField *pathField;
@property (nonatomic, strong) IBOutlet NSTextView *textView;

@end

@implementation DIMainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)loadView {
    
    [super loadView];
    
    _directoryString = [[NSUserDefaults standardUserDefaults] objectForKey:FOLDER_PATH_DEFAULTS_KEY];
    if (_directoryString)
        [_pathField setStringValue:_directoryString];
}

- (IBAction)buttonFolderPressed:(id)sender {
    
    [self openDialog];
}

- (void)processChosenURL:(NSURL *)url {
    
    if (!url)
        return;
    
    DIAppDelegate *appDelegate = (DIAppDelegate *)[NSApplication sharedApplication].delegate;
    appDelegate.directoryURL = [url URLByDeletingLastPathComponent];
    
    NSString *lastComponent = [url lastPathComponent];
    if (![lastComponent isEqualToString:@"Objects"]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Нет-нет.."
                                         defaultButton:@"Попробовать снова"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Выберите саму папку Objects!"];
        [alert runModal];
        return;
    }
    
    NSString *urlString = [url absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:FOLDER_PATH_DEFAULTS_KEY];
    [_pathField setStringValue:urlString];
    [self recognizeContentAtDirectory:url];
}

-(void)openDialog {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setDirectoryURL:[NSURL URLWithString:_directoryString]];
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *theDoc = [[panel URLs] objectAtIndex:0];
            [self processChosenURL:theDoc];
        }
    }];
}


- (NSDictionary *)objectDictFromFiles:(NSArray *)objectFiles {
    
    NSMutableDictionary *objectDict = [NSMutableDictionary new];

    for (NSURL *filePath in objectFiles) {
        NSString *ext = [filePath pathExtension];
        ext = [ext lowercaseString];
        NSString *name = [filePath lastPathComponent];
        NSString *contentString;
        
        if ([ext isEqualToString:@"txt"]) {
            contentString = [DIStringFormatter unknownCodingStringFromUrl:filePath];
            contentString = [DIStringFormatter stringByChangingNewLineSymbolsForString:contentString];
            NSRange range = [name rangeOfString:@"info"];
            if (range.location != NSNotFound) {
                NSArray *components = [contentString componentsSeparatedByString:@"\n\n\n"];
                for (NSString *compString in components) {
                    NSArray *keyValueArray = [compString componentsSeparatedByString:@"\n\n"];
                    if (keyValueArray.count > 1)
                        [objectDict setValue:keyValueArray[1] forKey:keyValueArray[0]];
                }

            }
            range = [name rangeOfString:@"workingHours"];
            if (range.location != NSNotFound) {
                NSArray *array = [self workingHoursArrayFromString:contentString];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
                [objectDict setValue:data forKey:@"workingHours"];
            }
        }
        
        else if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) {
            NSData *imageData = [NSData dataWithContentsOfURL:filePath];
            NSRange range = [name rangeOfString:@"avatar"];
            if (range.location != NSNotFound) {
                [objectDict setObject:imageData forKey:@"avatarData"];
            }
            range = [name rangeOfString:@"small"];
            if (range.location != NSNotFound) {
                [objectDict setObject:imageData forKey:@"smallAvatarData"];
            }
        }
        
        else if ([ext isEqualToString:@"html"] || [ext isEqualToString:@"htm"]) {
            contentString = [DIStringFormatter unknownCodingStringFromUrl:filePath];
            NSArray *comp = [name componentsSeparatedByString:@"."];
            if (comp.count == 2) {
                NSString *key = comp[0];
                [objectDict setObject:contentString forKey:key];
            }
        }
        //NSLog(@"%@", objectDict);
    }

    return objectDict;
}



//- (DIHint *)hintFromSightDictionary:(NSDictionary *)dict {
//    
//    DIHint *hint = [DIHint new];
//    hint.latitude = [self recognizeLatitudeFromCoordString:dict[@"Coordinates"]];
//    hint.longitude = [self recognizeLongitudeFromCoordString:dict[@"Coordinates"]];
//    hint.text = dict
//}

- (NSDictionary *)recognizeContentAtDirectory:(NSURL *)url {
    
    NSMutableArray *sights = [NSMutableArray arrayWithCapacity:100];
//    NSMutableArray *hints = [NSMutableArray arrayWithCapacity:100];
    
    //NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self pathForObjectsFolder] error:nil];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                              includingPropertiesForKeys:nil
                                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                   error:nil];
    for (int count = 0; count < [directoryContent count]; count++)
    {
        NSString *fileName = [directoryContent[count] lastPathComponent];
        NSURL *objectFolderPath = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
        if ([fileName isEqualToString:@"_Hints"]) {
            [self recognizeHintsAtURL:objectFolderPath];
        }
        else {
            NSArray *objectFolderContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:objectFolderPath
                                                                         includingPropertiesForKeys:nil
                                                                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                              error:nil];
            if (objectFolderContent.count) {
                NSDictionary *objectDict = [self objectDictFromFiles:objectFolderContent];
                DISight *sight = [(DIAppDelegate *)[NSApplication sharedApplication].delegate createAndSaveItemFromDictionary:objectDict];
                if (sight) {
                    [sights addObject:sight];
                    [_textView insertText:[NSString stringWithFormat:@"Recognized: %@", sight.name]];
                    [_textView insertText:@"\n"];
                }
            }
        }
    }
    
    //NSArray *sightsFromCore = [(DIAppDelegate *)[NSApplication sharedApplication].delegate sightsArray];
    
    return @{@"sights" : sights};
}

- (void)recognizeHintsAtURL:(NSURL *)url {
    
    
}



- (NSArray *)workingHoursArrayFromString:(NSString *)string {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:366];
    NSArray *days = [string componentsSeparatedByString:@"\n"];
    for (NSString *day in days) {
        if ([day isEqualToString:@""])
            continue;
        NSArray *fields = [day componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSAssert(fields.count >= 3, @"Wrong date format in Working Hours");
        NSArray *time = [(NSString *)fields[1] componentsSeparatedByString:@"-"];
        NSAssert(fields.count >= 2, @"Wrong date format in Working Hours");
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSDate *date1 = [dateFormat dateFromString:(NSString *)time[0]];
        NSDate *date2 = [dateFormat dateFromString:(NSString *)time[1]];
        NSDictionary *dayDictInside = @{@"timeOpen"     : date1,
                                        @"timeClose"    : date2,
                                        @"free"         : (NSString *)fields[2]};
        NSDictionary *dict = @{(NSString *)fields[0]: dayDictInside};
        [array addObject:dict];
    }
    
    return array;
}

@end
