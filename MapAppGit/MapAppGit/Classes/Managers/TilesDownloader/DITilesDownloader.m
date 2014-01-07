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

@end

@implementation DITilesDownloader

- (id) initWithSource:(id<RMTileSource>)source
{
    self = [super init];
    
    if (self) {
        _tileSource = source;
        _tileCacheManager = [[RMCachedTileSource alloc] initWithSource:source];
    }
	return self;
}


- (void)makeDatabase {
    
    
    //double lat = 59.93;
    //double lon = 30.3;
    _startPoint = CLLocationCoordinate2DMake(59.8928, 30.1981);
    _endPoint = CLLocationCoordinate2DMake(60.0033, 30.4117);
    _minZoom = 10;
    _maxZoom = 16;
    
    double lat, lon, latStep, lonStep;
    NSUInteger nZoom, xTile, yTile;
    
    NSUInteger zoom = _minZoom;
    for (; zoom <= _maxZoom; zoom++) {
        nZoom = pow(2, zoom);
        latStep = [self xStepForNZoom:nZoom];
        lonStep = [self yStep:nZoom firstLatitude:_startPoint.latitude];
        lon = _startPoint.longitude;
        for (; lon < _endPoint.longitude; lon += lonStep) {
            xTile = [self xTileForNZoom:nZoom longitude:lon];
            lat = _startPoint.latitude;
            for (; lat < _endPoint.latitude; lat += latStep) {
                yTile = [self yTileForNZoom:nZoom latitude:lat];
                RMTile tile = {xTile, yTile, zoom};
                [_tileCacheManager tileImage:tile];
            }
        }
    }
}

- (double)xStepForNZoom:(int)nZoom {
    
    return 360. / nZoom;
}

- (double)yStep:(int)nZoom firstLatitude:(int)lat {
    
    double yTile = [self yTileForNZoom:nZoom latitude:lat];
    double yTileNext = yTile;
    double stepLat = 0.;
    while (yTile - yTileNext < 1.) {
        stepLat += 0.0000001;
        double lat2 = lat + stepLat;
        yTileNext = [self yTileForNZoom:nZoom latitude:lat2];
    }
    
    return stepLat;
}

- (int)yTileForNZoom:(int)nZoom latitude:(double)lat {
    
    return (1 - (log(tan(lat*M_PI/180) + 1/cos(lat*M_PI/180)) / M_PI)) / 2 * nZoom;
}

- (int)xTileForNZoom:(int)nZoom longitude:(double)lon {
 
    return ((lon + 180.) / 360) * nZoom;
}


@end
