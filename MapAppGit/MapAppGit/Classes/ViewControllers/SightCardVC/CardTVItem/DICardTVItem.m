//
//  DICardTVItem.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 24.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICardTVItem.h"

@implementation DICardTVItem

- (void)setHtmlString:(NSString *)htmlString {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ugLine5" withExtension:@"png"];
    if (url) {
        url = [url URLByDeletingLastPathComponent];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"images/"
                                                           withString:[url absoluteString]];
    }
    
    _htmlString = htmlString;
}

@end
