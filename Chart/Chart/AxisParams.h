//
//  AxisParams.h
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

/**
  *  @brief   坐标轴属性
  */
@interface AxisParams : NSObject

/**    x 轴    **/
@property (nonatomic, assign) BOOL needXAxis;   // 是否需要绘制 x 轴。默认：yes
@property (nonatomic, assign) BOOL isDashXAxis; // 虚线 x 轴。yes - 虚线   no - 实线。默认：no
@property (nonatomic, assign) BOOL needXScale;  // 是否需要绘制 x 轴刻度。默认：yes
@property (nonatomic, assign) BOOL needXValue;  // 是否显示 x 轴上的文本。默认：yes

@property (nonatomic, assign) CGFloat xAxisLMargin;
@property (nonatomic, assign) CGFloat xAxisRMargin;
@property (nonatomic, assign) CGFloat xValueOffset; // x 值与 y 轴的初始偏移量。默认：0

@property (nonatomic, strong) UIColor * xAxisColor;   // x 轴颜色。默认：0xF5F5F5
@property (nonatomic, strong) UIColor * xValueColor;  // x 轴文本颜色。默认：0xAFAFAF
@property (nonatomic, copy) NSString * xAxisUnit;     // x 轴单位

/**    y 轴    **/
@property (nonatomic, assign) BOOL needYAxis;   // 是否需要绘制 y 轴。默认：yes
@property (nonatomic, assign) BOOL isDashYAxis; // 虚线 y 轴。yes - 虚线   no - 实线。默认：no
@property (nonatomic, assign) BOOL needYScale;  // 是否需要绘制 y 轴刻度。默认：yes
@property (nonatomic, assign) BOOL isZeroYAxis; // y 轴的数据是否从 0 开始。默认：no
@property (nonatomic, assign) BOOL needYValue;  // 是否显示 y 轴上的文本。默认：yes
@property (nonatomic, assign) NSUInteger numberScaleOfYAxis; // y 轴刻度数，默认：4
@property (nonatomic, copy) NSString * yAxisUnit;     // y 轴单位

@property (nonatomic, assign) CGFloat maxYAxisValue;  // 最大值。默认 0
@property (nonatomic, assign) CGFloat minYAxisValue;  // 最小值。默认 0

@property (nonatomic, assign) CGFloat yAxisTMargin;
@property (nonatomic, assign) CGFloat yAxisBMargin;

@property (nonatomic, strong) UIColor * yAxisColor;   // y 轴颜色。默认：0xF5F5F5
@property (nonatomic, strong) UIColor * yValueColor;  // y 轴文本颜色。默认：0xAFAFAF

/**  参考线   **/
@property (nonatomic, assign) BOOL isNeedReferenceLine;     // 是否需要参考线。默认：yes
@property (nonatomic, strong) UIColor * referenceLineColor; // 参考线颜色。默认：#F2F2F2

@end
