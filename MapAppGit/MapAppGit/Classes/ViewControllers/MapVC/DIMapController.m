//
//  DIMapController.m
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DIMapController.h"

#import <CoreLocation/CoreLocation.h>

#import "RouteMe.h"

#import "DICloudeMadeManager.h"
#import "DINotificationNames.h"
#import "DIDefaults.h"
#import "DIHelper.h"


@interface DIMapController ()

@property (nonatomic, strong) DIMapSourceManager *mapSourceManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) RMMarker *currentLocationMarker;

@end


@implementation DIMapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mapSourceManager = [[DICloudeMadeManager alloc] init];
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_mapSourceManager setMapSourceForMapView:_mapView];
    _mapView.delegate = self;
    
#warning temporary commented
    if ([DIHelper offlineMode])
        [_mapView setConstraintsSW:[DIHelper SWBorderPoint]
                                NE:[DIHelper NEBorderPoint]];
    
    UIBarButtonItem *locButton = [[UIBarButtonItem alloc] initWithTitle:@"location"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(buttonLocationPressed)];
    self.navigationItem.rightBarButtonItem = locButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Location Service

- (void)buttonLocationPressed {
    
    if ([CLLocationManager locationServicesEnabled])
        [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = locations.lastObject;
    CLLocationCoordinate2D coord = location.coordinate;
    
    if (!_currentLocationMarker) {
        _currentLocationMarker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-red"]];
        [_mapView.markerManager addMarker:_currentLocationMarker AtLatLong:coord];
    }
    else
        [_mapView.markerManager moveMarkerWithAnimation:_currentLocationMarker AtLatLon:coord];
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
