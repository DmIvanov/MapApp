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
        _insets = UIEdgeInsetsZero;
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
    
    //define insets in customizeBarButton: of your VC
    return _insets;
}

@end
