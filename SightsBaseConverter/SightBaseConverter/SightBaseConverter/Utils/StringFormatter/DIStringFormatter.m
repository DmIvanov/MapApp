//
//  DIStringFormatter.m
//  SightBaseConverter
//
//  Created by Dmitry Ivanov on 06.07.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIStringFormatter.h"

@implementation DIStringFormatter

+ (NSString *)unknownCodingStringFromUrl:(NSURL *)url {
    
    NSString *contentString = [NSString stringWithContentsOfURL:url
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    if (contentString)
        return contentString;
    
    contentString = [NSString stringWithContentsOfURL:url
                                             encoding:NSWindowsCP1251StringEncoding
                                                error:nil];
    if (contentString)
        return contentString;
    
    return nil;
}

+ (NSString *)stringByChangingNewLineSymbolsForString:(NSString *)string {
    
    string = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    return string;
}

@end
