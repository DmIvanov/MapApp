//
//  DISightShortView.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 19.07.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightShortView.h"

#import "DISight.h"


@interface DISightShortView ()

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *buttonAdd;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;
@property (nonatomic, strong) IBOutlet UIView *bottomArrowView;

@end

@implementation DISightShortView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma marrk - Setters & getters 

- (void)setSight:(DISight *)sight {
    
    if (_sight != sight) {
        _sight = sight;
        [self loadImage];
        [self fillButtonAddImage];
        _titleLabel.text = sight.name;
        _bottomLabel.text = _sight.shortDescr;
    }
}

- (CGPoint)markerPoint {
    
    return CGPointMake(SCREEN_SIZE.width/2, 404.);
}


#pragma mark

- (void)loadImage {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:_sight.smallAvatarData];
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = image;
        });
    });
}

- (void)fillButtonAddImage {
    
    UIImage *image = [_sight imageForBigButtonAdd];
    [_buttonAdd setImage:image forState:UIControlStateNormal];
}


#pragma mark - Touch events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:_bottomArrowView];
    if ([_bottomArrowView pointInside:touchLocation withEvent:event]) {
        [_delegate dismissView:self];
    }
    else
        [_delegate openSightCardFromView:self];
}


@end
