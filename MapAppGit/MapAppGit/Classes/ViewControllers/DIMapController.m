//
//  DIMapController.m
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DIMapController.h"
#import "DIMapSourceManager.h"
#import "DICloudeMadeManager.h"


@interface DIMapController ()

@property (nonatomic, strong) id <DIMapSourceManager> mapSourceManager;

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

@end
