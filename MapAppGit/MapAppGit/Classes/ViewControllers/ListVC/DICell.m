//
//  Cell.m
//  TableV
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICell.h"

#import "ListDefaults.h"

#define SMALL_SIZE          CGSizeMake(SCREEN_SIZE.width, CELL_HIGH)
#define BIG_SIZE            CGSizeMake(SCREEN_SIZE.width, CELL_HIGH_BIG)

@interface DICell()
{

}

@end

@implementation DICell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)init
{    
    CGRect frame = CGRectMake(0, 0, SMALL_SIZE.width, SMALL_SIZE.height);
    self = [self initWithFrame:frame];
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    [[UIColor lightGrayColor] setFill];
    [[UIColor blackColor] setStroke];
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(path);
}

-(void)setCellHight:(float)hight {
    
    if (hight == self.frame.size.height) //no hight changing
        return;
    
    CGRect newBounds = self.bounds;
    newBounds.size.height = hight;
    self.bounds = newBounds;
    
    NSLog(@"   cell - %d new high = %.2f", _dataIndex, self.frame.size.height);
    
    //content changing
}

- (void)moveToY:(float)y {
    
    float delta = y - self.frame.origin.y;
    [self moveToDeltaY:delta];
}

- (void)moveToDeltaY:(float)deltaY {
    
    NSLog(@"   cell - %d orig = %.2f high = %.2f", _dataIndex, self.frame.origin.y, self.frame.size.height);
    CGRect newFrame = self.frame;
    newFrame.origin.y += deltaY;
    self.frame = newFrame;
    NSLog(@">> cell - %d orig = %.2f high = %.2f", _dataIndex, self.frame.origin.y, self.frame.size.height);
}


@end
