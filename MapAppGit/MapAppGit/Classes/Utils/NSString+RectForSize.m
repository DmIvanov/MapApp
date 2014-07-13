//
//  NSString+RectForSize.m
//
//
//  Created by Aleksandr on 04.02.14.
//
//

#import "NSString+RectForSize.h"

@implementation NSString (RectForSize)

- (CGRect)rectForSize:(CGSize)size font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode {
    
    CGRect rect = CGRectZero;
    if (!font)
        return rect;
    
    if (OSVersionIsAtLeastiOS7()) {
        NSDictionary *attribute = @{NSFontAttributeName:font,
                                    NSParagraphStyleAttributeName:[NSParagraphStyle defaultParagraphStyle]};
        rect = [self boundingRectWithSize:size
                                  options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                               attributes:attribute
                                  context:nil];
    }
    rect.size = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    
    return rect;
}

@end
