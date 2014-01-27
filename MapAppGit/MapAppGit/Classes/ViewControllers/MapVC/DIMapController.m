//
//  DIMapController.m
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DIMapController.h"

#import "RouteMe.h"
#import "DICloudeMadeManager.h"
#import "DINotificationNames.h"
#import "DIDefaults.h"


#define TILE_SIZE           256


@interface DIMapController ()
{
    BOOL _userIsInteracting;
    BOOL _noTilesReceived;
    BOOL _movingToBounds;
}

@property (nonatomic, strong) DIMapSourceManager *mapSourceManager;
@property (nonatomic, strong) NSDictionary *dbDescription;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end


@implementation DIMapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mapSourceManager = [[DICloudeMadeManager alloc] init];
       
        NSString *path = [[NSBundle mainBundle] pathForResource:@"dbDescription" ofType:@"plist"];
        _dbDescription = [[NSDictionary alloc] initWithContentsOfFile:path];
        if (!_dbDescription)
            _dbDescription = [NSDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(noTileInDB:)
                                                     name:NO_TILE_IN_DB
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_mapSourceManager setMapSourceForMapView:_mapView];
    _mapView.delegate = self;
    _mapView.contents.tilesUpdateDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)noTileInDB:(NSNotification *)notification {
    
    _noTilesReceived = YES;
    [self checkTiles];
}

- (CGSize)sizeForZoom:(NSUInteger)zoom {
    
    if (!_mapView.contents)
        return CGSizeZero;
    
    NSString *key = [NSString stringWithFormat:@"%d", zoom];
    NSArray *tilesArrayForZoom = _dbDescription[key];
    
    if (!tilesArrayForZoom || !tilesArrayForZoom.count)
        return CGSizeZero;
    
    int width = tilesArrayForZoom.count * TILE_SIZE;
    NSDictionary *firstElement = tilesArrayForZoom[0];
    NSArray *arrayForX = firstElement[firstElement.allKeys[0]];
    int height = arrayForX.count * TILE_SIZE;
    
    return CGSizeMake(width, height);
}

- (void)checkTiles {
    
    if (!_userIsInteracting && _noTilesReceived) {
        CGRect rect = [_mapView.contents.imagesOnScreen imagesRectOnscreen];
        [self moveContentsToRect:rect];
    }
    _noTilesReceived = NO;
}

- (void)moveContentsToRect:(CGRect)tilesRect {
    
    double deltaX;
    if (tilesRect.origin.x < 0) {
        deltaX = _mapView.frame.size.width - tilesRect.origin.x - tilesRect.size.width;
        if (deltaX < 0)
            deltaX = 0.;
    }
    else
        deltaX = -tilesRect.origin.x;

    double deltaY;
    if (tilesRect.origin.y < 0) {
        deltaY = _mapView.frame.size.height - tilesRect.origin.y - tilesRect.size.height;
        if (deltaY < 0)
            deltaY = 0.;
    }
    else
        deltaY = -tilesRect.origin.y;
    
    CGSize delta = CGSizeMake(deltaX, deltaY);
    
    [_mapView moveBy:delta];
    
    _movingToBounds = YES;
}

#pragma mark - RMMapViewDelegate methods

- (void)beforeMapMove:(RMMapView*)map {
 
    _userIsInteracting = YES;
}

- (void)afterMapMove:(RMMapView*)map {
    
    RMMapContents *contents = _mapView.contents;
    RMTileImageSet *images = contents.imagesOnScreen;
    if (_movingToBounds) {
        CGRect rect = [contents.imagesOnScreen imagesRectOnscreen];
        BOOL contained = CGRectContainsRect(rect, [contents screenBounds]);
        if (!contained) {
            [images addTiles:[contents tileBounds]
                 ToDisplayIn:[contents screenBounds]];
        }
        _movingToBounds = NO;
    }
}

- (void)afterMapTouch:(RMMapView *)map {
    
    _userIsInteracting = NO;
    [self checkTiles];
}


#pragma mark - RMTilesUpdateDelegate methods
- (void)regionUpdate:(RMSphericalTrapezium)region {
    
}


#pragma mark - RMMapViewDelegate methods

- (void)singleTapOnMap:(RMMapView *)map At:(CGPoint)point {
    
    if (map != _mapView)
        return;
    
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue"]];
    RMLatLong touchPoint = [map.contents pixelToLatLong:point];
    //[_routePoints addObject:[DIMapConverter dictionaryFromCoordinate:touchPoint]];
    [map.markerManager addMarker:newMarker AtLatLong:touchPoint];
}


@end
