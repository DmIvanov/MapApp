//
//  DILocationManager.m
//  
//
//  Created by Dmitry Ivanov on 22.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DILocationManager.h"

#import <CoreLocation/CoreLocation.h>

@interface DILocationManager()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation DILocationManager

+ (DILocationManager *)sharedInstance {
    
    static DILocationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DILocationManager alloc] initSingletone];
    });
    return sharedInstance;
}

- (id)initSingletone {
    
    self = [super init];
    if (self) {
        _locationManager = [CLLocationManager new];
        [_locationManager startMonitoringSignificantLocationChanges];
    }
    return self;
}

- (void)dealloc {
    
    //[_locationManager stopMonitoringSignificantLocationChanges];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = locations.lastObject;
    CLLocationCoordinate2D coord = location.coordinate;
    [self checkHintsForCurrentCoordinate:coord];
}


- (void)checkHintsForCurrentCoordinate:(CLLocationCoordinate2D)coordinate {
    
}

@end
