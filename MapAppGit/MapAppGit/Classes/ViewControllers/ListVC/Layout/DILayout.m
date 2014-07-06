//
//  DILayout.m
//  CollectionView
//
//  Created by Dmitry Ivanov on 04.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DILayout.h"

#import "ListDefaults.h"


@interface DILayout ()
{
    UICollectionViewLayoutAttributes *_growingItemAttributes;
    CGFloat _bottomStart, _bottomStop;
}

@end

@implementation DILayout

- (id)init {
    
    self = [super init];
    if (!self)
        return nil;

    return self;
}


-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    // Very important — needed to re-layout the cells when scrolling.
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray* layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];

    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));

    //UICollectionViewLayoutAttributes *attr = layoutAttributesArray.lastObject;
    //NSLog(@"vis = %@, last = %@", NSStringFromCGRect(visibleRect), NSStringFromCGRect(attr.frame));
    
    CGFloat offset = self.collectionView.contentOffset.y;
    if (offset < 0) {
        _bottomStart = BOTTOM_START;
        _bottomStop = BOTTOM_STOP;
    }
    else {
        _bottomStart = BOTTOM_START + offset;
        _bottomStop = BOTTOM_STOP + offset;
    }
    
    if (!_growingItemAttributes)
        [self growingCellAtFirstTime:layoutAttributesArray];
    
    [self modifyGrowingItemsFrame];
    
    for (UICollectionViewLayoutAttributes* attributes in layoutAttributesArray)
    {
            if (CGRectIntersectsRect(attributes.frame, rect))
            {
                [self applyLayoutAttributes:attributes forVisibleRect:visibleRect];
            }
    }
    [self whoIsGrowingWithAttributesAfter:layoutAttributesArray];
    
    NSUInteger helpCellIndex = [self helpIndexItem];
    UICollectionViewLayoutAttributes* lastAttributes = layoutAttributesArray.lastObject;
    if (lastAttributes.indexPath.item == helpCellIndex) {
        CGRect frame = lastAttributes.frame;
        frame.size.height = CELL_HEIGHT_HELP;
        lastAttributes.frame = frame;
        DLog(@"growing - %d, help cell - %d, frame - %@", _growingItemAttributes.indexPath.item, lastAttributes.indexPath.item, NSStringFromCGRect(lastAttributes.frame));
    }
    
    return layoutAttributesArray;
}

- (void)growingCellAtFirstTime:(NSArray *)attributesArray {
    
    UICollectionViewLayoutAttributes *attributes;
    if (attributesArray.count > DEFAULT_GROWING_INDEX) {
        attributes = attributesArray[DEFAULT_GROWING_INDEX];
        CGRect frame = CGRectMake(0., CELL_HEIGHT_BIG, self.collectionView.frame.size.width, CELL_HEIGHT_SECOND);
        attributes.frame = frame;
    }
    _growingItemAttributes = attributes;
}

- (void)whoIsGrowingWithAttributesAfter:(NSArray *)attributesArray {
    
    UICollectionViewLayoutAttributes *attributes;

    for (NSInteger idx = attributesArray.count-1; idx >= 0; idx--) {
        UICollectionViewLayoutAttributes *nextAttr;
        if (idx != attributesArray.count-1 )
            nextAttr = attributesArray[idx+1];
        attributes = [self growingCellsAttributesForAttributes:attributesArray[idx]
                                             andNextAttributes:nextAttr];
        if (attributes)
            break;
    }

    if (attributes && attributes.indexPath.item != [self helpIndexItem])
        _growingItemAttributes = attributes;
    else
         DLog(@"No attributes for growing cell!");
}

- (UICollectionViewLayoutAttributes *)growingCellsAttributesForAttributes:(UICollectionViewLayoutAttributes *)attr andNextAttributes:(UICollectionViewLayoutAttributes *)nextAttr{
    
    CGFloat bottom = CGRectGetMaxY(attr.frame);
    CGFloat height = attr.frame.size.height;
    
    if (bottom > _bottomStart) {
        if (height > CELL_HEIGHT) {
            CGFloat delta = height - CELL_HEIGHT;
            CGRect newFrame = attr.frame;
            newFrame.size.height -= delta;
            newFrame.origin.y += delta;
            attr.frame = newFrame;
            UICollectionViewLayoutAttributes *growingAttr = [self growingCellsAttributesForAttributes:attr
                                                                                    andNextAttributes:nil];
            if (growingAttr)
                return growingAttr;
        }
        
    }
    else if (bottom >= _bottomStop && bottom < _bottomStart) {
        return attr;
    }
    else {
        if (nextAttr) {
            CGFloat deltaMove = CGRectGetMinY(nextAttr.frame) - CGRectGetMaxY(attr.frame);
            if (deltaMove > 0) {
                CGRect newFrame = attr.frame;
                newFrame.origin.y += deltaMove;
                attr.frame = newFrame;
                UICollectionViewLayoutAttributes *growingAttr = [self growingCellsAttributesForAttributes:attr
                                                                                        andNextAttributes:nil];
                if (growingAttr)
                    return growingAttr;
            }
        }
    }

    return nil;
}

//по нижней точке
- (void)modifyGrowingItemsFrame {
    
    CGRect frame = _growingItemAttributes.frame;
    CGFloat bottom = CGRectGetMaxY(frame);
    CGFloat ratio = (_bottomStart - bottom)/(_bottomStart - _bottomStop);
    CGFloat newHeight;
    if (ratio < 0)
        newHeight = CELL_HEIGHT;
    else if (ratio > 1)
        newHeight = CELL_HEIGHT_BIG;
    else
        newHeight = round(CELL_HEIGHT + (CELL_HEIGHT_BIG - CELL_HEIGHT)*ratio);
    
    CGRect newFrame = CGRectMake(frame.origin.x, bottom - newHeight, frame.size.width, newHeight);
    _growingItemAttributes.frame = newFrame;
}


-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes forVisibleRect:(CGRect)visibleRect
{
    // We want to skip supplementary views.
    if (attributes.representedElementKind)
        return;
    
    NSUInteger thisItem = attributes.indexPath.item;
    NSUInteger growingItem = _growingItemAttributes.indexPath.item;
    CGRect frame = _growingItemAttributes.frame;
    
    //big cell
    if (thisItem < growingItem) {
        CGFloat origY = CGRectGetMinY(frame) - (growingItem - thisItem)*CELL_HEIGHT_BIG;
        CGRect thisFrame = CGRectMake(0, origY, frame.size.width, CELL_HEIGHT_BIG);
        attributes.frame = thisFrame;
    }
    //small cell
    else if (thisItem > growingItem) {
        CGFloat origY = CGRectGetMaxY(frame) + (thisItem - growingItem - 1)*CELL_HEIGHT;
        CGRect thisFrame = CGRectMake(0, origY, frame.size.width, CELL_HEIGHT);
        attributes.frame = thisFrame;
    }
    //growing cell
    else {
        attributes.frame = _growingItemAttributes.frame;
    }
}

- (NSUInteger)helpIndexItem {
    
    return [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0] - 1;
}


@end
