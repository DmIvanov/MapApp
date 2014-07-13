//
//  NSString+RectForSize.h
//  
//
//  Created by Aleksandr on 04.02.14.
//
//

#import <UIKit/UIKit.h>

@interface NSString (RectForSize)

- (CGRect)rectForSize:(CGSize)size font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
