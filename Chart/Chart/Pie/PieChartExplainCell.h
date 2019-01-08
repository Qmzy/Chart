//  饼状图信息解释视图 cell
//
//  PieChartExplainCell.h
//
//  Created by D on 17/7/4.
//  Copyright © 2017年 D. All rights reserved.


#import <UIKit/UIKit.h>

@class PieChartLegend;
@interface PieChartExplainCell : UICollectionViewCell

- (void)setCellWithData:(PieChartLegend *)legend;

@end
