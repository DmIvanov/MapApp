//
//  DIGrowingCellTableView.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 06.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DIGrowingCellTableViewDelegate <UIScrollViewDelegate>

@required
- (NSUInteger)itemsCount;

@end


@interface DIGrowingCellTableView : UIScrollView

@property (nonatomic, weak) id<DIGrowingCellTableViewDelegate> delegate;

@end
