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
#import "DISettingsManager.h"
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
    
    if ([DISettingsManager offlineMode])
        [_mapView setConstraintsSW:[DISettingsManager sharedInstance].SWBorderPoint
                                NE:[DISettingsManager sharedInstance].NEBorderPoint];
    
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

- (void)dealloc {
    
    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingHeading];
}


#pragma mark - Location Service

- (void)buttonLocationPressed {
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
        [_locationManager startMonitoringSignificantLocationChanges];
    if ([CLLocationManager headingAvailable])
        [_locationManager startUpdatingHeading];
}

- (IBAction)buttonZoomRoundingPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    if (button.selected) {
        [DIHelper sharedInstance].mapRoundingCeil = NO;
        button.selected = NO;
    }
    else {
        [DIHelper sharedInstance].mapRoundingCeil = YES;
        button.selected = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = locations.lastObject;
    CLLocationCoordinate2D coord = location.coordinate;
    
    if (!_currentLocationMarker) {
        _currentLocationMarker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"arrow.jpeg"]];
        [_mapView.markerManager addMarker:_currentLocationMarker AtLatLong:coord];
        [_mapView moveToLatLong:coord];
    }
    else {
        [_mapView.markerManager moveMarkerWithAnimation:_currentLocationMarker AtLatLon:coord];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    CLLocationDirection direction = newHeading.trueHeading;
    CGFloat angle = 2*M_PI*(direction/360);
    
    _currentLocationMarker.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}


#pragma mark - RMMapViewDelegate methods

- (void)singleTapOnMap:(RMMapView *)map At:(CGPoint)point {
/*
    if (map != _mapView)
        return;
    
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue"]];
    newMarker.anchorPoint = CGPointMake(0.5, 1.);
    RMLatLong touchPoint = [map.contents pixelToLatLong:point];
    //[_routePoints addObject:[DIMapConverter dictionaryFromCoordinate:touchPoint]];
    [map.markerManager addMarker:newMarker AtLatLong:touchPoint];
*/ 
}

- (void)afterMapZoom:(RMMapView *)map byFactor:(float)zoomFactor near:(CGPoint)center {
    
    //DLog(@"zoom - %f", _mapView.contents.zoom);
}


@end
