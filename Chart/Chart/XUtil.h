//
//  XUtil.h
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

@interface XUtil : NSObject

+ (UIView *)viewFromXibFile:(NSString *)xibFile;

+ (CGFloat)calculateTextHeight:(NSString *)content width:(CGFloat)width font:(UIFont *)font;
+ (CGFloat)calculateTextWidth:(NSString *)content height:(CGFloat)height font:(UIFont *)font;

@end
