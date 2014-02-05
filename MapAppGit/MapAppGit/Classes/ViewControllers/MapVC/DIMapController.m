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


@interface DIMapController ()
{
    BOOL _userIsInteracting;
    BOOL _noTilesReceived;
    BOOL _movingToBounds;
}

@property (nonatomic, strong) DIMapSourceManager *mapSourceManager;

@end


@implementation DIMapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mapSourceManager = [[DICloudeMadeManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_mapSourceManager setMapSourceForMapView:_mapView];
    _mapView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)checkTilesAvailability:(CGSize)delta {
    
    return [_mapView.contents isMovingAvailable:_mapView.frame delta:delta];
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
