//
//  DITilesDownloader.m
//
//
//  Created by Dmitry Ivanov on 28.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DITilesDownloader.h"
#import "DIHelper.h"

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
    
    if ([DIHelper downloadingTilesFromFileSystem])
        [self makeDBFromFolder];
    else
        [self makeDBFromRemoteSource];
}

- (void)makeDBFromRemoteSource {
    
    //double lat = 59.93;
    //double lon = 30.3;
    _startPoint = CLLocationCoordinate2DMake(59.8928, 30.1981);
    _endPoint = CLLocationCoordinate2DMake(60.0033, 30.4117);
    _minZoom = 10;
    _maxZoom = 18;
    
    NSUInteger nZoom, xTile, yTile, startXTile, startYTile, endXTile, endYTile;
    
    NSUInteger zoom = _minZoom;
    
    RMTile tile = {597, 298, 10};
    [_tileCacheManager tileImage:tile];
    
    RMTile tile2 = {598, 298, 10};
    [_tileCacheManager tileImage:tile2];
    
    RMTile tile3 = {1195, 596, 11};
    [_tileCacheManager tileImage:tile3];
    
    RMTile tile4 = {1196, 596, 11};
    [_tileCacheManager tileImage:tile4];
    
    RMTile tile5 = {1196, 596, 11};
    [_tileCacheManager tileImage:tile5];
    
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
            NSString *key = [NSString stringWithFormat:@"%@", @(xTile)];
            NSDictionary *dictForX = @{key : arrayForX};
            [arrayForZoom addObject:dictForX];
        }
        NSString *key = [NSString stringWithFormat:@"%@", @(zoom)];
        _dbDescription[key] = arrayForZoom;
    }
    
    NSURL *path = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"dbDescription.plist"];
    [_dbDescription writeToURL:path atomically:YES];
    
}

- (int)yTileForNZoom:(NSUInteger)nZoom latitude:(double)lat {
    
    return (1 - (log(tan(lat*M_PI/180) + 1/cos(lat*M_PI/180)) / M_PI)) / 2 * nZoom;
}

- (int)xTileForNZoom:(NSUInteger)nZoom longitude:(double)lon {
 
    return ((lon + 180.) / 360) * nZoom;
}


- (void)makeDBFromFolder {
    
    [[DIHelper sharedInstance] downloadTilesToDBFromFolder];
}


@end
