//
//  PieChartView.h
//
//  Created by D on 17/6/26.
//  Copyright © 2017年 D. All rights reserved.


#import <UIKit/UIKit.h>
#import "PieChartDrawView.h"
#import "PieChartLegend.h"


@class PieChartView;
@protocol PieChartViewDataSource <NSObject>
@required
/**
  *  @brief   返回饼图统计的数据数量
  */
- (NSInteger)pieChartViewDataCount;

/**
  *  @brief   获取指定索引位置的数据对象
  */
- (PieChartModel *)pieChartView:(PieChartView *)pieChartView index:(NSInteger)index;

@end



@interface PieChartView : UIView

@property (nonatomic, strong) PieChartConfig * pieConfig;  // 配置对象
@property (nonatomic, strong) NSArray<PieChartModel> * pieModels;   // 数据对象
@property (nonatomic, strong) NSArray<PieChartLegend> * pieLegend;  // 图例信息
@property (nonatomic, copy) NSString * pieChartText;  // 饼图的名称
@property (nonatomic, strong) id<PieChartViewDataSource> dataSource;

/**
  *  @brief   手动创建视图时，传入必须的对象
  */
- (instancetype)initWithFrame:(CGRect)frame
                  andPieModel:(NSArray<PieChartModel> *)pieModels
            andPieChartConfig:(PieChartConfig *)pieConfig;

/**
  *  @brief   单独传入所需的对象，与视图的创建分开
  */
- (void)setChartWithPieModel:(NSArray<PieChartModel> *)pieModels
           andPieChartConfig:(PieChartConfig *)pieConfig;

/**
  *  @brief   更新饼状图
  */
- (void)updatePieChart;

/**
  *  @brief   获取饼图高度
  */
- (CGFloat)pieChartViewHeight;

@end
