//  饼图右上角的图例信息
//
//  PieChartLegend.h
//
//  Created by D on 2017/7/19.
//  Copyright © 2017年 D. All rights reserved.


#import <UIKit/UIKit.h>

@interface PieChartLegend : NSObject

@property (nonatomic, copy) NSString  * legendTitle;  // 图例标题
@property (nonatomic, strong) UIImage * legendImage;  // 图例图片

@property (nonatomic, assign) CGFloat legendWidth;    // 标题宽度
@property (nonatomic, assign) CGFloat legendHeight;   // 图例的高度

@end


@protocol PieChartLegend <NSObject>
@end
