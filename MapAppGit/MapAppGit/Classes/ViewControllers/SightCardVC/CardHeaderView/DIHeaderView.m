//
//  DIHeaderView.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 24.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIHeaderView.h"

#import "DICardTVItem.h"

@interface DIHeaderView ()

@property (nonatomic, strong) IBOutlet UILabel *label;

@end

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

- (void)refreshContent {
    
    NSString *openCloseImageName = _item.opened ? @"info_button_collapseClosure" : @"info_button_expandClosure";
    _openCloseImageView.image = [UIImage imageNamed:openCloseImageName];
}

- (void)setItem:(DICardTVItem *)item {
    
    _item = item;
    _label.text = DILocalizedString(item.keyString);
}



@end
