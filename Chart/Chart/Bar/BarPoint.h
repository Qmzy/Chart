//
//  BarPoint.h
//  Chart
//
//  Created by CYKJ on 2019/1/7.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

@interface BarPoint : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, strong) UIColor * backColor; // 背景颜色：默认：黑色

@property (nonatomic, copy) NSString * xValue;     // x 数值
@property (nonatomic, assign) CGFloat yValue;      // y 数值
@property (nonatomic, copy) NSString * xLabelText; // x 描述文字
@property (nonatomic, copy) NSString * yLabelText; // y 描述文字

@property (nonatomic, retain) NSArray<NSString *> * promptMsgs;  // 提示文本信息

/**
  *  @brief   初始化
  */
- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y;

@end
