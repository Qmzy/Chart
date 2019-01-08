//
//  XUtil.m
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import "XUtil.h"

@implementation XUtil

+ (UIView *)viewFromXibFile:(NSString *)xibFile
{
    NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:xibFile owner:nil options:nil];
    return [nibContents firstObject];
}

/**
  *  @brief   固定宽度，计算文字的长度
  */
+ (CGFloat)calculateTextHeight:(NSString *)content width:(CGFloat)width font:(UIFont *)font
{
    CGRect rect = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName : font}
                                        context:nil];
    
    return rect.size.height + 1;  // 系统计算时未加入行之间的间隙，所以+1多增加一行
}

/**
  *  @brief   固定长度，计算文字的宽度
  */
+ (CGFloat)calculateTextWidth:(NSString *)content height:(CGFloat)height font:(UIFont *)font
{
    CGRect rect = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName : font}
                                        context:nil];
    
    return rect.size.width + 1;
}

@end
