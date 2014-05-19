//
//  DICell.h
//  CollectionView
//
//  Created by Dmitry Ivanov on 04.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DISight;

@interface DICell : UICollectionViewCell

@property (nonatomic, strong) DISight *sight;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSUInteger index;

- (void)refreshContent;

@end
