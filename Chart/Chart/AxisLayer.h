//  坐标轴
//
//  AxisLayer.h
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import <QuartzCore/QuartzCore.h>
#import "Macro.h"
#import "AxisParams.h"

@interface AxisLayer : CAShapeLayer

@property (nonatomic, readonly, strong) AxisParams * params;

@property (nonatomic, strong) NSArray * xScaleLineAry;    // x 轴刻度线数组。有序
@property (nonatomic, strong) NSArray * yScaleLineAry;    // y 轴刻度线数组。有序。为 nil 时优先使用 referenceLineAry，然后使用 maxYAxisValue/minYAxisValue。当使用 maxYAxisValue/minYAxisValue 时需要 numberScaleOfYAxis 的值大于 0.
@property (nonatomic, strong) NSArray * referenceLineAry; // y 轴参考线数组。有序。

@property (nonatomic, readonly, assign) CGFloat drawW;  // 绘制区域宽度
@property (nonatomic, readonly, assign) CGFloat drawH;  // 绘制区域高度

/**
  *  @brief   绘制 x、y 轴
  */
- (void)drawXYAxis;
/**
  *  @brief   绘制参考线
  */
- (void)drawReferenceLine;

//ST_SINGLETON;

@end
