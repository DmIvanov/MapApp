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
#import "RMMercatorToScreenProjection.h"

#import "DICloudeMadeManager.h"
#import "DISettingsManager.h"
#import "DISightsManager.h"

#import "DISightCardVC.h"
#import "DIListMapVC.h"

#import "DISight.h"
#import "DIHelper.h"
#import "DISimpleMarker.h"
#import "DISightShortView.h"


@interface DIMapController ()
{
    DISightShortView *_currentSightView;
}

@property (nonatomic, strong) DIMapSourceManager *mapSourceManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) RMMarker *currentLocationMarker;
@property (nonatomic, strong) NSMutableArray  *dataArray;

@end


@implementation DIMapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //_mapSourceManager = [[DICloudeMadeManager alloc] init];
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        
        _dataArray = [NSMutableArray arrayWithArray:[[DISightsManager sharedInstance] dataArray]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[_mapSourceManager setMapSourceForMapView:_mapView];
    _mapView.delegate = self;
    
    if ([DISettingsManager offlineMode])
        [_mapView setConstraintsSW:[DISettingsManager sharedInstance].SWBorderPoint
                                NE:[DISettingsManager sharedInstance].NEBorderPoint];
    
    UIBarButtonItem *locButton = [[UIBarButtonItem alloc] initWithTitle:@"location"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(buttonLocationPressed)];
    self.navigationItem.rightBarButtonItem = locButton;
    
    [self placeObjectsOnMap];
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


#pragma mark - RMMapView interactions

- (void)singleTapOnMap:(RMMapView *)map At:(CGPoint)point {
    
    if (_currentSightView)
        [self hideCurrentSightView];
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

- (void)markerTapped:(DISimpleMarker *)marker withTouches:(NSSet *)touches event:(UIEvent *)event {
    
    if (_currentSightView)
        [self hideCurrentSightView];
    
    //UITouch *touch = [[touches allObjects] objectAtIndex:0];
    //CGPoint position = [touch locationInView:_mapView];
    CGPoint position = [_mapView.contents.mercatorToScreenProjection projectXYPoint:marker.projectedLocation];
    position = CGPointMake(position.x, position.y - marker.bounds.size.height/2);    //arrow points into the center of the marker
    
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DISightShortView"
                                                 owner:self
                                               options:nil];
    _currentSightView = arr.firstObject;
    _currentSightView.frame     = self.view.frame;
    _currentSightView.delegate  = self;
    _currentSightView.sight     = marker.sight;
    CGPoint newMarkerPosition = [_currentSightView markerPoint];
    CGSize delta = CGSizeMake(newMarkerPosition.x-position.x, newMarkerPosition.y-position.y);
    [_mapView moveBy:delta];
    [self showSightView:_currentSightView];
}


#pragma mark - Other functions

- (void)placeObjectsOnMap {
    
//    for (DISightExtended *sight in _dataArray) {
//        [self placeOneObjectOnMap:sight];
//    }
    DISight *sight = _dataArray.firstObject;
    [self placeOneObjectOnMap:sight];
    
    sight = _dataArray[1];
    [self placeOneObjectOnMap:sight];
}

- (void)placeOneObjectOnMap:(DISight *)sight {
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([sight.latitudeNumber floatValue], [sight.longitudeNumber floatValue]);
    UIImage *imageForMarker = [sight imageForMapMarker];
    DISimpleMarker *newMarker = [[DISimpleMarker alloc] initWithUIImage:imageForMarker
                                                            anchorPoint:CGPointMake(0.5, 1.)];
    newMarker.mapController = self;
    newMarker.sight = sight;
    [_mapView.markerManager addMarker:newMarker AtLatLong:coord];
}

- (void)showSightView:(DISightShortView *)view {
    
    [_listMapController sightViewIsShowingOnMap:YES];
    
    view.alpha = 0.;
    [self.view addSubview:view];
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 1.;
                     }];
}

- (void)hideCurrentSightView {
    
    [self hideSightView:_currentSightView];
}

- (void)hideSightView:(DISightShortView *)view {
    
    [_listMapController sightViewIsShowingOnMap:NO];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 0.;
                     } completion:^(BOOL finished) {
                         [view removeFromSuperview];
                         if (view == _currentSightView)
                             _currentSightView = nil;
                     }];
}


#pragma mark - DISightShortViewDelegate methods

- (void)openSightCardFromView:(DISightShortView *)view {
    
    DISightCardVC *sightCard = [DISightCardVC new];
    sightCard.sight = view.sight;
    [self.listMapController.navigationController pushViewController:sightCard
                                                           animated:YES];
}

- (void)dismissView:(DISightShortView *)view {
    
    [self hideSightView:view];
}

@end
