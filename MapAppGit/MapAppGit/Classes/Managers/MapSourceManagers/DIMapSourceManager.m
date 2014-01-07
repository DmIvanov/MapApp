//
//  DIMapSourceManager.m
//  
//
//  Created by Dmitry Ivanov on 06.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIMapSourceManager.h"
#import "DITilesDownloader.h"


@interface DIMapSourceManager()

@property (nonatomic, strong) DITilesDownloader *downloader;

@end


@implementation DIMapSourceManager

- (id)init {
    
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (void)setMapSourceForMapView:(RMMapView *)mapView {
    
    mapView.contents.tileSource = self.tileSource;
}

- (void)makeDatabase {
    
    _downloader = [[DITilesDownloader alloc] initWithSource:self.tileSource];
    [_downloader makeDatabase];
}

@end
