//
//  DICell.m
//  CollectionView
//
//  Created by Dmitry Ivanov on 04.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICell.h"

#import "DISightExtended.h"
#import "ListVC.h"
#import "DISightsManager.h"

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
    
    _titleLabel.text = [NSString stringWithFormat:@"%ld - %@", (unsigned long)_index, _sight.originalSight.name];
    _imageView.image = _sight.avatarImage;
    _bottomLabel.text = _sight.originalSight.shortDescriptionString;
    
    [self fillButtonAddImage];
}

- (void)fillButtonAddImage {
    
    NSString *imageName;
    switch (_sight.originalSight.sightType) {
        case SightTypeChosen:
            imageName = @"";
            break;
        case SightTypeInteresting:
            imageName = @"list_button_add_pressed";
            break;
        case SightTypeDone:
            imageName = @"";
            break;
        case SightTypeOther:
            imageName = @"list_button_add_released";
            break;
        case SightTypeLocal:
            imageName = @"";
            break;
            
        default:
            break;
    }
    UIImage *buttonAddImage = [UIImage imageNamed:imageName];
    [_buttonAdd setImage:buttonAddImage forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)buttonAddPressed:(id)sender {
    
    //[_listVC cellButtonAddPressed:self];
}


@end
