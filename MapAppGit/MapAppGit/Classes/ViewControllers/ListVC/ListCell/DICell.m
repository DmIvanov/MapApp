//
//  DICell.m
//  CollectionView
//
//  Created by Dmitry Ivanov on 04.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICell.h"

#import "NSString+RectForSize.h"

#import "DISight.h"
#import "ListVC.h"
#import "DISightsManager.h"

#define LABEL_PRICE_FRAME           CGRectMake(209., 12., 101., 21.)
#define LABEL_WORKHOURS_FRAME       CGRectMake(35., 12., 149., 21.)


@interface DICell ()

@property (nonatomic, strong) IBOutlet UIImageView *cellTitleView;
@property (nonatomic, strong) IBOutlet UIImageView *titleIcon;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *buttonAdd;
@property (nonatomic, strong) IBOutlet UIImageView *darkStripe;
@property (nonatomic, strong) IBOutlet UIView *bottomView;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;

@property (nonatomic, strong) IBOutlet UILabel *labelWorkHours;
@property (nonatomic, strong) IBOutlet UILabel *labelPrice;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewWorkHours;
@property (nonatomic, strong) IBOutlet UIImageView  *imageRubles;

@end

@implementation DICell

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    UIImage *titleBG = [[UIImage imageNamed:@"list_cell_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 0, 0, 0)];
    _cellTitleView.image = titleBG;
}

- (void)refreshContent {
    
    _titleLabel.text = _sight.name;
    [self fillSmallIconImage];
    [self loadImage];
    _bottomLabel.text = _sight.shortDescr;
    [self refreshDateTimeInfo];
    [self fillButtonAddImage];
}

- (void)refreshDateTimeInfo {
    
    _labelPrice.frame       = LABEL_PRICE_FRAME;
    _labelWorkHours.frame   = LABEL_WORKHOURS_FRAME;
    
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

- (void)fillSmallIconImage {
    
    UIImage *image = [_sight imageForListCell];
    _titleIcon.image = image;
}


#pragma mark - Actions

- (IBAction)buttonAddPressed:(id)sender {
    
    //[_listVC cellButtonAddPressed:self];
}


@end
