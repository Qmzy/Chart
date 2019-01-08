//  曲线趋势图
//
//  CurveView.h
//  CiYunApp
//
//  Created by CYKJ on 2018/12/25.
//  Copyright © 2018年 北京慈云科技有限公司. All rights reserved.


#import <UIKit/UIKit.h>
#import "AxisLayer.h"


@interface CurveChart : UIView

@property (nonatomic, readonly, strong) AxisLayer * axisLayer;  // 坐标轴图层

@property (nonatomic, assign) BOOL isNeedDot;       // 是否显示圆点表示数据。默认：yes
@property (nonatomic, assign) BOOL isNeedLowValue;  // 是否显示低于 y 轴最低值的数据。yes - 显示，贴着 y 轴。默认：yes
@property (nonatomic, assign) BOOL isNeedGradient;  // 是否需要渐变色图层。默认：no
@property (nonatomic, assign) BOOL isPromptOnTaped; // 点击时是否出现提示。默认：yes

@property (nonatomic, strong) UIColor * drawColor;  // 趋势图绘制颜色。默认：0x6FBA2C
@property (nonatomic, strong) UIColor * dotColor;   // 圆点绘制颜色。默认：0xFFB214
@property (nonatomic, strong) UIColor * fromColor;  // 当 isNeedGradient = yes 时有效
@property (nonatomic, strong) UIColor * toColor;    // 当 isNeedGradient = yes 时有效

@property (nonatomic, assign) BOOL isHorizontalScroll;     // 是否可以左右滑动。默认：no
@property (nonatomic, assign) NSInteger maxCountPerScreen; // 一屏至多显示多少个点，isHorizontalScroll = yes 时有效。默认：7
@property (nonatomic, assign) BOOL isShowAllXScaleValue;   // 是否显示所有 x 轴刻度值。默认：no

@property (nonatomic, strong) NSArray * xAxisValue;  // x 值数组
@property (nonatomic, strong) NSArray * yAxisValue;  // y 值数组

/**
  *  @brief   画曲线图
  *  @param    x_values    x轴数值
  *  @param    y_values    y轴数值
  */
- (void)drawCurveChartWithXValues:(NSArray *)x_values yValues:(NSArray *)y_values;

- (void)clean;

@end
