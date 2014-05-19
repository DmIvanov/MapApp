//
//  DICell.m
//  CollectionView
//
//  Created by Dmitry Ivanov on 04.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICell.h"

#import "DISight.h"

@interface DICell ()

@property (nonatomic, strong) IBOutlet UIImageView *cellTitleView;
@property (nonatomic, strong) IBOutlet UIImageView *titleIcon;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *buttonInfo;
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
    _imageView.image = _image;
    _bottomLabel.text = _sight.history;
    [self fillButtonAddImage];
}

- (void)fillButtonAddImage {
    
    NSString *imageName;
    switch (_sight.sightType) {
        case SightTypeChosen:
            imageName = @"list_button_add_pressed";
            break;
        case SightTypeInteresting:
            imageName = @"";
            break;
        case SightTypeDone:
            imageName = @"";
            break;
        case SightTypeOther:
            imageName = @"";
            break;
        case SightTypeLocal:
            imageName = @"";
            break;
            
        default:
            break;
    }
    UIImage *buttonAddImage = [UIImage imageNamed:imageName];
    _buttonAdd.backgroundColor = [UIColor colorWithPatternImage:buttonAddImage];
}


@end
