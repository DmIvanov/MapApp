//
//  DIHeaderView.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 24.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIHeaderView.h"

@implementation DIHeaderView

- (void)awakeFromNib {
    
    // set up the tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(recognizerTapped:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)recognizerTapped:(id)sender {
    
    [_delegate headerTapped:self];
}

@end
