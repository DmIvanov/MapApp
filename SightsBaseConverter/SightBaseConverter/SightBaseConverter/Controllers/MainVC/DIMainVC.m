//
//  DIMainVC.m
//  SightBaseConverter
//
//  Created by Dmitry Ivanov on 27.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIMainVC.h"

#import "DIAppDelegate.h"
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
        NSString *name = [filePath lastPathComponent];
        NSString *contentString = [NSString stringWithContentsOfURL:filePath
                                                           encoding:NSWindowsCP1251StringEncoding
                                                              error:nil];
        if ([ext isEqualToString:@"txt"]) {
            NSRange range = [name rangeOfString:@"Info"];
            if (range.location != NSNotFound) {
                NSArray *components = [contentString componentsSeparatedByString:@"\r\n\r\n\r\n"];
                for (NSString *compString in components) {
                    NSArray *keyValueArray = [compString componentsSeparatedByString:@"\r\n\r\n"];
                    if (keyValueArray.count > 1)
                        [objectDict setValue:keyValueArray[1] forKey:keyValueArray[0]];
                }

            }
        }
        
        else if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) {
            NSData *imageData = [NSData dataWithContentsOfURL:filePath];
            NSRange range = [name rangeOfString:@"avatar"];
            if (range.location != NSNotFound) {
                [objectDict setObject:imageData forKey:@"avatarData"];
            }
        }
        
        else if ([ext isEqualToString:@"html"] || [ext isEqualToString:@"htm"]) {
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
    
    NSArray *sightsFromCore = [(DIAppDelegate *)[NSApplication sharedApplication].delegate sightsArray];
    
    return @{@"sights" : sights};
}

- (void)recognizeHintsAtURL:(NSURL *)url {
    
    
}



- (NSArray *)recognizeScheduleArray:(NSString *)string {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:7];
    
    return array;
}

@end
