//
//  DIMapController.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DIMapController.h"

#import "RMCloudMadeMapSource.h"


#define CONST_MAP_KEY_cloud @"a4573beea76a420f8f8b8f941f082492"


@interface DIMapController ()

@end

@implementation DIMapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) setMapSourceWithNumber:(int)number
{
    _mapView.contents.tileSource = [[RMCloudMadeMapSource alloc] initWithAccessKey:CONST_MAP_KEY_cloud styleNumber:1];
}

@end
