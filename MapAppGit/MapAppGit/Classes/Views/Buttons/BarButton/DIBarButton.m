//
//  DIBarButton.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 15.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIBarButton.h"

@implementation DIBarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIEdgeInsets)alignmentRectInsets {
    
    UIEdgeInsets insets;
    if (_sideMode == SideModeLeft) {
        insets = UIEdgeInsetsMake(0, 16, 0, 0);
    } else if (_sideMode == SideModeRight) { // IF_ITS_A_RIGHT_BUTTON
        insets = UIEdgeInsetsMake(0, 0, 0, 16);
    } else
        insets = UIEdgeInsetsMake(0, 0, 0, 0);
    return insets;
}

@end
