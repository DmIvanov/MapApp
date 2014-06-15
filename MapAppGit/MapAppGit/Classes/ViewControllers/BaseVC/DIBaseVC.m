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
    self.navigationController.navigationBar.frame = NAVIBAR_FRAME;
}

- (UIImage *)imageForNavibar {
    
    return [[UIImage imageNamed:@"list_buttonBar_background_128"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
}

- (void)customizeNavibar {
    
    DIBarButton *buttonLeft = [[DIBarButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    buttonLeft.sideMode = SideModeLeft;
    buttonLeft.insets = UIEdgeInsetsMake(0, 16, 0, 0);
    [buttonLeft addTarget:self
                    action:@selector(barButtonLeftPressed)
          forControlEvents:UIControlEventTouchUpInside];
    buttonLeft = [self customizeBarButton:buttonLeft];
    if (buttonLeft) {
        UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithCustomView:buttonLeft];
        [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    }
    
    DIBarButton *buttonRight = [[DIBarButton alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width - 44, 0, 44, 44)];
    buttonRight.sideMode = SideModeRight;
    buttonRight.insets = UIEdgeInsetsMake(0, 0, 0, 16);
    [buttonRight addTarget:self
                    action:@selector(barButtonRightPressed)
          forControlEvents:UIControlEventTouchUpInside];
    buttonRight = [self customizeBarButton:buttonRight];
    if (buttonRight) {
        UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithCustomView:buttonRight];
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
