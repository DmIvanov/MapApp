//
//  DIBaseVC.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 14.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIBaseVC.h"

#import "DIBarButton.h"

@interface DIBaseVC ()

@end

@implementation DIBaseVC

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
    
    [self customizeNavibar];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[self imageForNavibar]
                                                  forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.frame = NAVIBAR_FRAME;
}

- (UIImage *)imageForNavibar {
    
    return [[UIImage imageNamed:@"list_buttonBar_background_128"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
}

- (void)customizeNavibar {
    
    _leftBarButton = [[DIBarButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    _leftBarButton.sideMode = SideModeLeft;
    _leftBarButton.insets = UIEdgeInsetsMake(0, 16, 0, 0);
    [_leftBarButton addTarget:self
                    action:@selector(barButtonLeftPressed)
          forControlEvents:UIControlEventTouchUpInside];
    _leftBarButton = [self customizeBarButton:_leftBarButton];
    if (_leftBarButton) {
        UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithCustomView:_leftBarButton];
        [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    }
    
    _rightBarButton = [[DIBarButton alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width - 44, 0, 44, 44)];
    _rightBarButton.sideMode = SideModeRight;
    _rightBarButton.insets = UIEdgeInsetsMake(0, 0, 0, 16);
    [_rightBarButton addTarget:self
                    action:@selector(barButtonRightPressed)
          forControlEvents:UIControlEventTouchUpInside];
    _rightBarButton = [self customizeBarButton:_rightBarButton];
    if (_rightBarButton) {
        UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithCustomView:_rightBarButton];
        [self.navigationItem setRightBarButtonItem:barButtonRight];
    }
}

//redefine in children
- (DIBarButton *)customizeBarButton:(DIBarButton *)button {
    
    return nil;
}

- (void)barButtonLeftPressed {
    
}

- (void)barButtonRightPressed {
    
}

@end
