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
    
    if ([self.keyString isEqualToString:@"listContacts"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"icon_metro_line5@2x" ofType:@"png"];
        //htmlString = [htmlString stringByReplacingOccurrencesOfString:@"Contacts.files/image001.png"
        //                                                   withString:path];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"Contacts.files/image002.jpg"
                                                           withString:path];
    }
    
    _htmlString = htmlString;
}

@end
