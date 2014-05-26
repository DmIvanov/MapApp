//
//  DIHeaderView.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 24.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DIHeaderViewDelegate;

@class DICardTVItem;

@interface DIHeaderView : UITableViewHeaderFooterView

@property (nonatomic) NSUInteger section;
@property (nonatomic, weak) id <DIHeaderViewDelegate> delegate;
@property (nonatomic, weak) DICardTVItem *item;

@end


@protocol DIHeaderViewDelegate <NSObject>

- (void)headerTapped:(DIHeaderView *)header;

@end