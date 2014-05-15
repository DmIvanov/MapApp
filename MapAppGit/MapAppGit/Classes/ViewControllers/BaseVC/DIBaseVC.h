//
//  DIBaseVC.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 14.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DIBarButton;

@interface DIBaseVC : UIViewController

//redefine in children
- (DIBarButton *)customizeBarButton:(DIBarButton *)button;
- (void)barButtonLeftPressed;
- (void)barButtonRightPressed;

- (void)setStatusBarHiddenWithStaticFrames:(BOOL)hidden;

@end
