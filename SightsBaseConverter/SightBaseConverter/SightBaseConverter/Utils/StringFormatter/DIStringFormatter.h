//
//  DIStringFormatter.h
//  SightBaseConverter
//
//  Created by Dmitry Ivanov on 06.07.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIStringFormatter : NSObject

+ (NSString *)unknownCodingStringFromUrl:(NSURL *)url;
+ (NSString *)stringByChangingNewLineSymbolsForString:(NSString *)string;

@end
