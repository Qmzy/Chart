//
//  AxisParams.m
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import "AxisParams.h"
#import "Macro.h"

#define X_AXIS_L_MARGIN      43
#define X_AXIS_R_MARGIN      31
#define Y_AXIS_T_MARGIN      0
#define Y_AXIS_B_MATGIN      11
#define Y_AXIS_SCALE_COUNT   4

@implementation AxisParams

- (instancetype)init
{
    if (self = [super init]) {
        self.needXAxis    = YES;
        self.needXScale   = YES;
        self.needYAxis    = YES;
        self.needYScale   = YES;
        self.needXValue   = YES;
        self.needYValue   = YES;
        self.isDashXAxis  = NO;
        self.isDashYAxis  = NO;
        self.isZeroYAxis  = NO;
        self.xAxisLMargin = X_AXIS_L_MARGIN;
        self.xAxisRMargin = X_AXIS_R_MARGIN;
        self.yAxisTMargin = Y_AXIS_T_MARGIN;
        self.yAxisBMargin = Y_AXIS_B_MATGIN;
        self.xValueOffset = 0;
        self.maxYAxisValue = 0;
        self.minYAxisValue = 0;
        self.numberScaleOfYAxis  = Y_AXIS_SCALE_COUNT;
        self.xAxisColor = UIColorFromRGB(0xF5F5F5);
        self.xValueColor = UIColorFromRGB(0xAFAFAF);
        self.yAxisColor = UIColorFromRGB(0xF5F5F5);
        self.yValueColor = UIColorFromRGB(0xAFAFAF);
        self.referenceLineColor  = UIColorFromRGB(0xF2F2F2);
        self.isNeedReferenceLine = YES;
    }
    return self;
}

/**
  *  @brief   设置 y 轴刻度数量
  */
- (void)setNumberScaleOfYAxis:(NSUInteger)numberScaleOfYAxis
{
    // 错误数据处理。避免除数为 0，这里不能给任意值
    if (numberScaleOfYAxis <= 0)
        return;
    
    _numberScaleOfYAxis = numberScaleOfYAxis;
}

@end
