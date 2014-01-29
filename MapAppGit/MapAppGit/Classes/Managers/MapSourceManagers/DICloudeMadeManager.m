//
//  DICloudeMadeManager.m
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DICloudeMadeManager.h"
#import "RMCloudMadeMapSource.h"


#define APP_KEY                     @"a4573beea76a420f8f8b8f941f082492"
#define MAP_STYLE_NUMBER            119909


@implementation DICloudeMadeManager

- (id)init {
    
    self = [super init];
    if (self) {
        self.tileSource = [[RMCloudMadeMapSource alloc] initWithAccessKey:APP_KEY styleNumber:MAP_STYLE_NUMBER];
    }
    
    return self;
}


@end
