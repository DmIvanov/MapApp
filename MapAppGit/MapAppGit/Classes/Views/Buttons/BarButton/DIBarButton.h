//
//  DIBarButton.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 15.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BarButtonSideMode) {
    SideModeDefault,
    SideModeLeft,
    SideModeRight,
};

@interface DIBarButton : UIButton

@property (nonatomic) BarButtonSideMode sideMode;

@end
