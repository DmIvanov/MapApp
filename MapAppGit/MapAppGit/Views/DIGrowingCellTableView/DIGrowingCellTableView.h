//
//  DIGrowingCellTableView.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 06.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DIGrowingCell;

@protocol DIGrowingCellTableViewDelegate <NSObject>

@required
- (NSUInteger)itemsCount;
- (DIGrowingCell *)cellForIndex:(NSUInteger)index;

@end


@interface DIGrowingCellTableView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<DIGrowingCellTableViewDelegate> delegate;

@end
