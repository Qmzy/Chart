//
//  PieChartDrawView.h
//
//  Created by D on 17/6/27.
//  Copyright © 2017年 D. All rights reserved.


#import <UIKit/UIKit.h>
#import "PieChartModel.h"
#import "PieChartConfig.h"


@interface PieChartDrawView : UIView

@property (nonatomic, strong) PieChartConfig * pieConfig;  // 配置对象
@property (nonatomic, strong) NSArray<PieChartModel> * pieModels;   // 数据对象

- (void)redraw;

@end
