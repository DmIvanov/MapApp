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
    
    if ([self.keyString isEqualToString:SIGHT_LIST_ITEM_CONTACTS]) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"ugLine5@2x" withExtension:@"png"];
        url = [url URLByDeletingLastPathComponent];
        //htmlString = [htmlString stringByReplacingOccurrencesOfString:@"Contacts.files/image001.png"
        //                                                   withString:path];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"images/"
                                                           withString:[url absoluteString]];
    }
    
    _htmlString = htmlString;
}

@end
