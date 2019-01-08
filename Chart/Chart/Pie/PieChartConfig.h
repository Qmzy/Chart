//
//  PieChartConfig.h
//
//  Created by D on 17/6/26.
//  Copyright © 2017年 D. All rights reserved.


#import <UIKit/UIKit.h>

/**
  *  @brief   参数配置
  */
@interface PieChartConfig : NSObject

@property (nonatomic, assign) CGFloat radius;        // 视图半径。默认：75
@property (nonatomic, assign) CGFloat renderRadius;  // 圆环半径。默认：22.5
@property (nonatomic, assign) CGFloat sectorSpace;   // 扇形间的间距。默认：2
@property (nonatomic, assign) CGFloat dotMargin;     // 圆点与饼图的距离。默认：10

@property (nonatomic, strong) UIColor * spaceColor;  // 间隙的颜色。默认：白色
@property (nonatomic, strong) UIColor * lineColor;   // 指引线颜色。默认：nil。为空时取 spaceColor
@property (nonatomic, strong) UIColor * tipLColor;   // 提示文本颜色。默认：0x222222
@property (nonatomic, strong) UIColor * nilColor;    // 数据为空时扇形颜色。默认：0xeeeeee
@property (nonatomic, strong) UIColor * nilTipColor; // 数据为空时提示语颜色。默认：0x999999

@property (nonatomic, assign) BOOL isNeedCircleDot;  // 提示语控件是否需要圆点。默认：no
@property (nonatomic, assign) BOOL isNilDraw;        // 数据为空时是否绘制。默认：yes
@property (nonatomic, assign) BOOL isNeedExplain;    // 是否需要饼图信息解释视图。默认：yes - 需要

@property (nonatomic, assign) NSInteger itemsInRow;  // 饼图图例一行的项数。默认：4
@property (nonatomic, assign) CGFloat itemsHeight;   // 饼图图例一行的高度

@property (nonatomic, copy) NSString * nilTip;       // 数据为空时提示语。在 isNilDraw = yes 时有效
@end
