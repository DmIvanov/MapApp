//
//  DIMapSourceManager.h
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RMTileSource.h"

@class RMMapContents;

@interface DIMapSourceManager : NSObject

@property (nonatomic, strong) id<RMTileSource> tileSource;

- (void)setMapSourceWithMapContents:(RMMapContents *)contents;
- (void)makeDatabase;

@end
