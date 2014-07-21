//
//  DICell.m
//  CollectionView
//
//  Created by Dmitry Ivanov on 04.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICell.h"

#import "DISight.h"
#import "ListVC.h"
#import "DISightsManager.h"

@interface DICell ()

@property (nonatomic, strong) IBOutlet UIImageView *cellTitleView;
@property (nonatomic, strong) IBOutlet UIImageView *titleIcon;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *buttonAdd;
@property (nonatomic, strong) IBOutlet UIImageView *darkStripe;
@property (nonatomic, strong) IBOutlet UIView *bottomView;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;

@end

@implementation DICell

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    UIImage *titleBG = [[UIImage imageNamed:@"list_cell_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 0, 0, 0)];
    _cellTitleView.image = titleBG;
}

- (void)refreshContent {
    
    _titleLabel.text = [NSString stringWithFormat:@"%ld - %@", (unsigned long)_index, _sight.name];
    [self loadImage];
    _bottomLabel.text = _sight.shortDescr;
    
    [self fillButtonAddImage];
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


#pragma mark - Actions

- (IBAction)buttonAddPressed:(id)sender {
    
    //[_listVC cellButtonAddPressed:self];
}


@end
