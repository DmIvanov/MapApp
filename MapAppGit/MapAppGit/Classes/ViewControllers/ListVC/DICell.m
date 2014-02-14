//
//  Cell.m
//  TableV
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DICell.h"

#import "DIDefaults.h"
#import "ListDefaults.h"

#define SMALL_SIZE          CGSizeMake(SCREEN_SIZE.width, CELL_HEIGHT)
#define BIG_SIZE            CGSizeMake(SCREEN_SIZE.width, CELL_HEIGHT_BIG)

#define DESCR_VIEW_FRAME    CGRectMake(0, CELL_HEIGHT, SCREEN_SIZE.width, CELL_HEIGHT_BIG - CELL_HEIGHT)
#define DESCR_LABEL_FRAME   CGRectMake(100, 0, SCREEN_SIZE.width - 110, CELL_HEIGHT_BIG - CELL_HEIGHT - 5)
#define IMAGE_FRAME         CGRectMake(5, 0, 90, CELL_HEIGHT_BIG - CELL_HEIGHT - 5)

#define COLOR1              [UIColor colorWithRed:218./255. green:165./255. blue:32./255. alpha:1.]
#define COLOR2              [UIColor colorWithRed:184./255. green:134./255. blue:11./255. alpha:1.]
#define COLOR3              [UIColor colorWithRed:139./255. green:69./255. blue:19./255. alpha:1.]
#define COLOR4              [UIColor colorWithRed:205./255. green:133./255. blue:63./255. alpha:1.]
#define COLOR5              [UIColor colorWithRed:244./255. green:164./255. blue:96./255. alpha:1.]
#define COLOR6              [UIColor colorWithRed:255./255. green:165./255. blue:0. alpha:1.]
#define COLOR0              [UIColor colorWithRed:255./255. green:215./255. blue:0. alpha:1.]

@interface DICell()
{
    UILabel *_titleLabel;
    UILabel *_descrLabel;
    UIView *_descView;
    UIImageView *_imageView;
}

@end

@implementation DICell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self addTarget:self action:@selector(touchedUp:) forControlEvents:UIControlEventTouchUpInside];
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
    UIColor *color;
    int i = _dataIndex%7;
    switch (i) {
        case 0:
            color = COLOR1;
            break;
        case 1:
            color = COLOR2;
            break;
        case 2:
            color = COLOR3;
            break;
        case 3:
            color = COLOR4;
            break;
        case 4:
            color = COLOR5;
            break;
        case 5:
            color = COLOR6;
            break;
        case 6:
            color = COLOR0;
            break;
        default:
            color = [UIColor lightGrayColor];
            break;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    [color setFill];
    //[[UIColor blackColor] setStroke];
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFill);
    CGPathRelease(path);
    
    CGSize titleSize = CGSizeMake(SMALL_SIZE.width - 20, SMALL_SIZE.height - 10);
    
    NSDictionary *attribute = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:20],
                                NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]};
    CGRect titleFrame = [_titleString boundingRectWithSize:titleSize
                                                   options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attribute
                                                   context:nil];
    titleFrame.origin.x += 10;
    titleFrame.origin.y +=5;
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        [self addSubview:_titleLabel];
        _titleLabel.text = _titleString;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.frame.size.height == CELL_HEIGHT) {
        if (_descView) {
            _descView.hidden = YES;
        }
    }
    else if (self.frame.size.height > CELL_HEIGHT) {
        if (!_descView) {
//            NSDictionary *attribute = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:16],
//                                        NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle]};
//            descrFrame = [_description boundingRectWithSize:DESCR_LABEL_FRAME.size
//                                                    options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
//                                                 attributes:attribute
//                                                    context:nil];
            _descView = [[UIView alloc] initWithFrame:DESCR_VIEW_FRAME];
            _descView.userInteractionEnabled = NO;
            [self addSubview:_descView];
            
            _descrLabel = [[UILabel alloc] initWithFrame:DESCR_LABEL_FRAME];
            _descrLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            _descrLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _descrLabel.numberOfLines = 10;
            _descrLabel.text = _description;
            [_descView addSubview:_descrLabel];
            
            UIImage *image = [UIImage imageWithData:_imageData];
            _imageView = [[UIImageView alloc] initWithFrame:IMAGE_FRAME];
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
            _imageView.image = image;
            [_descView addSubview:_imageView];
        }
        _descView.hidden = NO;
    }

}

- (void)touchedUp:(id)sender {
    
    if (_delegate) {
        [_delegate cellDidSelect:self];
    }
}

@end
