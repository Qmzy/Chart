//
//  BarGraphAttribute.h
//  Chart
//
//  Created by CYKJ on 2019/1/7.
//  Copyright © 2019年 D. All rights reserved.


#import <UIKit/UIKit.h>

@class BarPoint;
@interface BarGraphAttribute : NSObject

@property (nonatomic, assign) BOOL needAnimation;   // 是否需要动画显示。默认：no

@property (nonatomic, strong) UIColor * barColor;   // 趋势图绘制颜色。默认：0x6FBA2C
@property (nonatomic, assign) CGFloat barWidth;     // 圆柱宽度。默认：8，最大不超过 30
@property (nonatomic, assign) BOOL needCircleBar;   // 柱子是否圆角化。默认：yes

@property (nonatomic, assign) BOOL isNeedGradient;  // 是否需要渐变色图层。默认：no
@property (nonatomic, strong) UIColor * fromColor;  // 当 isNeedGradient = yes 时有效
@property (nonatomic, strong) UIColor * toColor;    // 当 isNeedGradient = yes 时有效

@property (nonatomic, assign) NSInteger pointCount;  // 数据点的个数
@property (nonatomic, strong) NSMutableArray<BarPoint *> * values;

@property (nonatomic, assign) double maxValue;  //  y 轴上最大值
@property (nonatomic, assign) double minValue;  //  y 轴上最小值

@end

@protocol BarGraphAttribute <NSObject>

@end
