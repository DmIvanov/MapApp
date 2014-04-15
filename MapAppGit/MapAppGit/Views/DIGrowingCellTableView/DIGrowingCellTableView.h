//
//  DIGrowingCellTableView.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 06.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DIGrowingCell;
@class DIGrowingCellTableView;

typedef enum {
    ContentUP   = 1,
    ContentDown = 2
} ContentDirection;


@protocol DIGrowingCellTableViewDelegate <NSObject>

@required
- (NSUInteger)itemsCount;
- (DIGrowingCell *)cellForIndex:(NSUInteger)index;

@optional
- (void)tableViewIsScrolling:(DIGrowingCellTableView *)tableView;

@end


@interface DIGrowingCellTableView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<DIGrowingCellTableViewDelegate> delegate;

//scrolling properties
@property (nonatomic) ContentDirection direction;
@property (nonatomic) CGFloat deltaOffset;

@end
