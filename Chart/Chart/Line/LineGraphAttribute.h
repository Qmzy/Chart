//
//  LineGraphAttribute.h
//  Chart
//
//  Created by CYKJ on 2019/1/4.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

/**   存储趋势图绘制时的：判断值、颜色值、数据值   **/
@class LinePoint;
@interface LineGraphAttribute : NSObject

@property (nonatomic, assign) BOOL isNeedDot;       // 是否显示圆点表示数据。默认：yes
@property (nonatomic, assign) BOOL isNeedGradient;  // 是否需要渐变色图层。默认：no
@property (nonatomic, assign) BOOL needAnimation;   // 是否需要动画显示。默认：no

@property (nonatomic, strong) UIColor * drawColor;   // 趋势图绘制颜色。默认：0x6FBA2C
@property (nonatomic, strong) UIColor * dotColor;    // 圆点绘制颜色。默认：0xFFB214
@property (nonatomic, strong) UIColor * fromColor;   // 当 isNeedGradient = yes 时有效
@property (nonatomic, strong) UIColor * toColor;     // 当 isNeedGradient = yes 时有效
@property (nonatomic, assign) CGFloat dotRadius;     // 圆点半径。默认：2

@property (nonatomic, assign) NSInteger pointCount;  // 数据点的个数
@property (nonatomic, strong) NSMutableArray<LinePoint *> * values;

@property (nonatomic, assign) double maxValue;  //  y 轴上最大值
@property (nonatomic, assign) double minValue;  //  y 轴上最小值

@end


@protocol LineGraphAttribute <NSObject>

@end
