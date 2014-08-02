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


#define LOCATION_MARKER_DIRECTED_IMAGE              [UIImage imageNamed:@"map-me-directed"]
#define LOCATION_MARKER_UNDIRECTED_IMAGE          [UIImage imageNamed:@"map-me-undirected"]


@interface DIMapController ()
{
    DISightShortView *_currentSightView;
    BOOL _positionSwitchedOn;
    BOOL _firstLocationDetection;
    CLLocationCoordinate2D _currentCoordinates;
    NSMutableArray *_sightMarkers;
}

@property (nonatomic, strong) IBOutlet UIImageView *scaleRoller;
@property (nonatomic, strong) IBOutlet UIView *scaleRollerBg;

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
        _sightMarkers = [NSMutableArray arrayWithCapacity:100];
        _dataArray = [NSMutableArray arrayWithArray:[[DISightsManager sharedInstance] dataArray]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sightStateChanged:)
                                                     name:DINOTIFICATION_SIGHT_STATE_CHANGED
                                                   object:nil];
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
    
    [self placeObjectsOnMap];
    [self setScaleRollerPosition];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingHeading];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Location Service

- (void)locationMonitoringStart {
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
        [_locationManager startMonitoringSignificantLocationChanges];
    if ([CLLocationManager headingAvailable])
        [_locationManager startUpdatingHeading];
}

- (void)locationMonitoringStop {
    
    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = locations.lastObject;
    _currentCoordinates = location.coordinate;
    
    [_mapView.markerManager moveMarkerWithAnimation:self.currentLocationMarker AtLatLon:_currentCoordinates];
    
    if (_firstLocationDetection) {
        [self locationDetectedFirstTime];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    DLog(@"Location Manager Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    CLLocationDirection direction = newHeading.trueHeading;
    CGFloat angle = 2*M_PI*(direction/360);
    
    _currentLocationMarker.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
    
    if (_firstLocationDetection) {
        [self locationDetectedFirstTime];
    }
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
    
    [self setScaleRollerPosition];
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


#pragma mark - Actions

- (IBAction)buttonPositionPressed:(UIButton *)sender {
    
    _positionSwitchedOn = !_positionSwitchedOn;
    if (_positionSwitchedOn) {
        [sender setImage:[UIImage imageNamed:@"map-button-to_center-pressed.png"]
                forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"map-button-to_center.png"]
                forState:UIControlStateHighlighted];
        [self switchLocationMonitoringOn];
    }
    else {
        [sender setImage:[UIImage imageNamed:@"map-button-to_center.png"]
                forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"map-button-to_center-pressed.png"]
                forState:UIControlStateHighlighted];
        [self switchLocationMonitoringOff];
    }
    
}

- (IBAction)buttonMinusPressed:(id)sender {
    
    [_mapView zoomOutToNextNativeZoomAt:self.view.center];
    [self setScaleRollerPosition];
}

- (IBAction)buttonPlusPressed:(id)sender {
    
    [_mapView zoomInToNextNativeZoomAt:self.view.center];
    [self setScaleRollerPosition];
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



#pragma mark - Other functions

- (void)placeObjectsOnMap {
    
    for (DISight *sight in _dataArray) {
        [self placeOneObjectOnMap:sight];
    }
}

- (void)placeOneObjectOnMap:(DISight *)sight {
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([sight.latitudeNumber floatValue], [sight.longitudeNumber floatValue]);
    UIImage *imageForMarker = [sight imageForMapMarker];
    DISimpleMarker *newMarker = [[DISimpleMarker alloc] initWithUIImage:imageForMarker
                                                            anchorPoint:CGPointMake(0.5, 1.)];
    newMarker.mapController = self;
    newMarker.sight = sight;
    [_sightMarkers addObject:newMarker];
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

- (void)switchLocationMonitoringOn {
    
    _firstLocationDetection = YES;
    
    [self.currentLocationMarker replaceUIImage:LOCATION_MARKER_DIRECTED_IMAGE];
    [self locationMonitoringStart];
}

- (void)switchLocationMonitoringOff {
 
    [_currentLocationMarker replaceUIImage:LOCATION_MARKER_UNDIRECTED_IMAGE];
    [self locationMonitoringStop];
}

- (void)locationDetectedFirstTime {
    
    [_mapView moveToLatLong:_currentCoordinates];
    _firstLocationDetection = NO;
}

- (void)sightStateChanged:(NSNotification *)notification {
    
    DISight *notifSight = notification.userInfo[@"sight"];
    for (DISimpleMarker *marker in _sightMarkers) {
        if (marker.sight == notifSight) {
            UIImage *newImage = [notifSight imageForMapMarker];
            [marker replaceUIImage:newImage];
            break;
        }
    }
}

- (void)setScaleRollerPosition {
 
    NSUInteger yIndent = 2;
    
    NSUInteger curZoom = floor(_mapView.contents.zoom);
    NSUInteger minZoom = _mapView.contents.minZoom;
    NSUInteger maxZoom = _mapView.contents.maxZoom;
    
    CGFloat rollerArea = _scaleRollerBg.frame.size.height - yIndent*2 - _scaleRoller.frame.size.height;
    CGFloat oneDegree = rollerArea/(maxZoom - minZoom);
    CGRect rollerFrame = _scaleRoller.frame;
    rollerFrame.origin.y = yIndent + oneDegree*(maxZoom - curZoom);
    
    _scaleRoller.frame = rollerFrame;
}


#pragma mark - Setters & getters

- (RMMarker *)currentLocationMarker {
    
    if (!_currentLocationMarker) {
        _currentLocationMarker = [[RMMarker alloc] initWithUIImage:LOCATION_MARKER_DIRECTED_IMAGE];
        [_mapView.markerManager addMarker:_currentLocationMarker AtLatLong:_currentCoordinates];
    }
    
    return _currentLocationMarker;
}

@end
