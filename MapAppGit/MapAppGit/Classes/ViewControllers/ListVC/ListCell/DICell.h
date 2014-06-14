//
//  DICell.h
//  CollectionView
//
//  Created by Dmitry Ivanov on 04.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ListVC;

@class DISightExtended;

@interface DICell : UICollectionViewCell

@property (nonatomic, weak) ListVC *listVC;

@property (nonatomic, strong) DISightExtended *sight;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSUInteger index;

- (void)refreshContent;

@end
