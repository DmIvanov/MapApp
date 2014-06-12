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

@interface DIMainVC ()

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
    
    [_pathField setStringValue:[url absoluteString]];
    NSDictionary *contentDict = [self recognizeContentAtDirectory:url];
}

-(void)openDialog {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *theDoc = [[panel URLs] objectAtIndex:0];
            [self processChosenURL:theDoc];
        }
    }];
}


- (NSDictionary *)objectDictAtURL:(NSURL *)url {
    
    NSURL *infoPath = [url URLByAppendingPathComponent:@"info.txt"];
    NSString *contentString = [NSString stringWithContentsOfURL:infoPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    if (contentString) {
        NSMutableDictionary *objectDict = [NSMutableDictionary new];
        NSArray *components = [contentString componentsSeparatedByString:@"\n\n\n"];
        for (NSString *compString in components) {
            NSArray *keyValueArray = [compString componentsSeparatedByString:@"\n\n"];
            if (keyValueArray.count > 1)
                [objectDict setValue:keyValueArray[1] forKey:keyValueArray[0]];
        }
        //NSLog(@"%@", objectDict);
        return objectDict;
    }
    else
        return nil;
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
                NSDictionary *objectDict = [self objectDictAtURL:objectFolderPath];
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
