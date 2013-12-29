//
//  DITilesDownloader.h
//  
//
//  Created by Dmitry Ivanov on 28.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//


#import "RMCachedTileSource.h"

@interface DITilesDownloader : NSObject

@property (nonatomic) RMLatLong startPoint; //left top corner
@property (nonatomic) RMLatLong endPoint;   //right down corner

@property (nonatomic) NSUInteger minZoom;
@property (nonatomic) NSUInteger maxZoom;

- (id)initWithSource:(id<RMTileSource>)source;

- (void)makeDatabase;

@end
