//
//  DISightShortView.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 19.07.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightShortView.h"

#import "NSString+RectForSize.h"
#import "DISightsManager.h"
#import "DISight.h"


@interface DISightShortView ()

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *buttonAdd;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;
@property (nonatomic, strong) IBOutlet UIView *bottomArrowView;

@property (nonatomic, strong) IBOutlet UILabel *labelWorkHours;
@property (nonatomic, strong) IBOutlet UILabel *labelPrice;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewWorkHours;
@property (nonatomic, strong) IBOutlet UIImageView  *imageRubles;

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
        [self refreshDateTimeInfo];
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

- (void)refreshDateTimeInfo {
    
    NSString *price;
    if (_sight.isFreeToday) {
        price = NSLocalizedString(@"sightCardFree", nil);
        _imageRubles.hidden = YES;
    }
    else {
        CGFloat priceFloat = [_sight.price floatValue];
        price = [NSString stringWithFormat:@"%lu", (unsigned long)priceFloat];
        _imageRubles.hidden = NO;
    }
    
    CGSize size = [price rectForSize:_labelPrice.frame.size
                                font:_labelPrice.font
                       lineBreakMode:NSLineBreakByWordWrapping].size;
    _labelPrice.text = price;
    CGRect frame = _labelPrice.frame;
    frame.size = size;
    _labelPrice.frame = frame;
    CGFloat xMax = CGRectGetMaxX(frame);
    frame = _imageRubles.frame;
    frame.origin.x = xMax + 6;
    _imageRubles.frame = frame;
    
    if ([_sight isClosedNow]) {
        _labelWorkHours.text = NSLocalizedString(@"sightCardClosedToday", nil);
        _imageViewWorkHours.image = [UIImage imageNamed:@"list_status_unavailable"];
    }
    else {
        NSDictionary *todayDict = [_sight todayWHDict];
        NSDate *timeOpen = todayDict[@"timeOpen"];
        NSDate *timeClose = todayDict[@"timeClose"];
        
        NSString *displayedHours = [[DISightsManager sharedInstance] openCloseStringFromDateOpen:timeOpen
                                                                                       dateClose:timeClose];
        _labelWorkHours.text = displayedHours;
        _imageViewWorkHours.image = [UIImage imageNamed:@"list_status_worktime"];
    }
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
