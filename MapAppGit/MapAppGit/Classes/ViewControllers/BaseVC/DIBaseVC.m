//
//  DIBaseVC.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 14.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIBaseVC.h"

#import "DIDefaults.h"
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
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[self imageForNavibar]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (UIImage *)imageForNavibar {
    
    return [[UIImage imageNamed:@"list_buttonBar_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 20, 0)];
}

- (void)customizeNavibar {
    
    DIBarButton *buttonLeft = [[DIBarButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    buttonLeft.sideMode = SideModeLeft;
    [buttonLeft addTarget:self
                    action:@selector(barButtonLeftPressed)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithCustomView:[self customizeBarButton:buttonLeft]];
    [self.navigationItem setLeftBarButtonItem:barButtonLeft];
    
    DIBarButton *buttonRight = [[DIBarButton alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width - 44, 0, 44, 44)];
    buttonRight.sideMode = SideModeRight;
    [buttonRight addTarget:self
                    action:@selector(barButtonRightPressed)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithCustomView:[self customizeBarButton:buttonRight]];
    [self.navigationItem setRightBarButtonItem:barButtonRight];
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

/*
@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect {
    UIImage *image = ;
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
*/