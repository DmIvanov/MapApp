//
//  DITilesDownloader.m
//
//
//  Created by Dmitry Ivanov on 28.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DITilesDownloader.h"

@interface DITilesDownloader()

@property (nonatomic, strong) id<RMTileSource> tileSource;
@property (nonatomic, strong) RMCachedTileSource *tileCacheManager;
@property (nonatomic, strong) NSMutableDictionary *dbDescription;

@end

@implementation DITilesDownloader

- (id) initWithSource:(id<RMTileSource>)source
{
    self = [super init];
    
    if (self) {
        _tileSource = source;
        _tileCacheManager = [[RMCachedTileSource alloc] initWithSource:source];
        _dbDescription = [NSMutableDictionary dictionary];
    }
	return self;
}


- (void)makeDatabase {
    
    
    //double lat = 59.93;
    //double lon = 30.3;
    _startPoint = CLLocationCoordinate2DMake(59.8928, 30.1981);
    _endPoint = CLLocationCoordinate2DMake(60.0033, 30.4117);
    _minZoom = 18;
    _maxZoom = 18;
    
    NSUInteger nZoom, xTile, yTile, startXTile, startYTile, endXTile, endYTile;
    
    NSUInteger zoom = _minZoom;
    for (; zoom <= _maxZoom; zoom++) {
        nZoom = pow(2, zoom);
        
        startXTile = [self xTileForNZoom:nZoom longitude:_startPoint.longitude];
        endXTile = [self xTileForNZoom:nZoom longitude:_endPoint.longitude];
        xTile = MIN(startXTile, endXTile);
        endXTile = MAX(startXTile, endXTile);
        
        NSMutableArray *arrayForZoom = [NSMutableArray array];
        for (; xTile <= endXTile; xTile++) {
            startYTile = [self yTileForNZoom:nZoom latitude:_startPoint.latitude];
            endYTile = [self yTileForNZoom:nZoom latitude:_endPoint.latitude];
            yTile = MIN(startYTile, endYTile);
            endYTile = MAX(startYTile, endYTile);
            
            NSMutableArray *arrayForX = [NSMutableArray array];
            for (; yTile <= endYTile; yTile++) {
                RMTile tile = {xTile, yTile, zoom};
                [_tileCacheManager tileImage:tile];
                [arrayForX addObject:@(yTile)];
            }
            NSString *key = [NSString stringWithFormat:@"%d", xTile];
            NSDictionary *dictForX = @{key : arrayForX};
            [arrayForZoom addObject:dictForX];
        }
        NSString *key = [NSString stringWithFormat:@"%d", zoom];
        _dbDescription[key] = arrayForZoom;
    }
    
    NSURL *path = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"dbDescription.plist"];
    [_dbDescription writeToURL:path atomically:YES];
    
}

- (int)yTileForNZoom:(int)nZoom latitude:(double)lat {
    
    return (1 - (log(tan(lat*M_PI/180) + 1/cos(lat*M_PI/180)) / M_PI)) / 2 * nZoom;
}

- (int)xTileForNZoom:(int)nZoom longitude:(double)lon {
 
    return ((lon + 180.) / 360) * nZoom;
}


@end
