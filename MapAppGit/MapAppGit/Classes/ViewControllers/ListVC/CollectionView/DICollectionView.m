//
//  DICollectionView.m
//  Around About
//
//  Created by Dmitry Ivanov on 02.08.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICollectionView.h"

@implementation DICollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    
    if (!_noOffsetChanging)
        [super setContentOffset:contentOffset];
}

@end
