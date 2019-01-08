//
//  PieChartModel.h
//
//  Created by D on 17/6/26.
//  Copyright © 2017年 D. All rights reserved.


#import <UIKit/UIKit.h>

/**
  *  @brief   饼图单个内容显示信息
  */
@interface PieChartModel : NSObject

@property (nonatomic, copy) NSString * tip;      // 指引线文本。"6天(25%)"
@property (nonatomic, strong) UIColor * color;   // 扇形区域颜色值。"0x6FBA2C"
@property (nonatomic, assign) CGFloat percent;   // 占比。取值 0 ~ 1

@property (nonatomic, assign) BOOL isNilData;    // 是否是无数据时自建的数据。默认：no

@end


@protocol PieChartModel <NSObject>
@end
