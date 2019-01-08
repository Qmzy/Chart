//
//  BarChart.h
//  Chart
//
//  Created by D on 2019/1/6.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>
#import "AxisLayer.h"
#import "BarGraphAttribute.h"
#import "BarPoint.h"

@class BarChart;
@protocol BarChartDelegate <NSObject>
@required
/**
  *  @brief   设置趋势图个数
  *  @param   chart   趋势图对象
  *  @param   chartIndex   趋势图的索引
  */
- (NSInteger)chartView:(BarChart *)chart numberOfPointAtIndex:(NSInteger)chartIndex;

/**
  *  @brief   设置每个趋势图的属性
  *  @param   chart   趋势图对象
  *  @param   chartIndex   趋势图的索引
  */
- (BarGraphAttribute *)chartView:(BarChart *)chart graphAttributeAtIndex:(NSInteger)chartIndex;

/**
  *  @brief   设置趋势图每个点的绘制属性
  *  @param   chart   趋势图对象
  *  @param   pointIndex   某个趋势图的第几个点
  *  @param   chartIndex   趋势图的索引
  */
- (BarPoint *)chartView:(BarChart *)chart pointIndex:(NSInteger)pointIndex chartIndex:(NSInteger)chartIndex;

@optional
/**
  *  @brief  设置趋势图数量
  */
- (NSInteger)numberOfChartView:(BarChart *)chart;

@end




@interface BarChart : UIView

@property (nonatomic, readonly, strong) AxisLayer * axisLayer;  // 坐标轴图层

@property (nonatomic, assign) BOOL isPromptOnTaped;        // 点击时是否出现提示。默认：yes
@property (nonatomic, assign) BOOL isHorizontalScroll;     // 是否可以左右滑动。默认：no
@property (nonatomic, assign) BOOL isShowAllXScaleValue;   // 是否显示所有 x 轴刻度值。默认：no
@property (nonatomic, assign) NSInteger maxCountPerScreen; // 一屏至多显示多少个点，isHorizontalScroll = yes 时有效。默认：7
@property (nonatomic, assign) NSInteger numberOfChartView; // 趋势图的组数。默认：0

@property (nonatomic, weak) id<BarChartDelegate> delegate;

/**
  *  @brief   绘制圆柱图
  */
- (void)drawBarChart;

- (void)clean;

@end
