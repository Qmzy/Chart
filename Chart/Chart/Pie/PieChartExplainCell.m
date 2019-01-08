//
//  PieChartExplainCell.m
//
//  Created by D on 17/7/4.
//  Copyright © 2017年 北京慈云科技有限公司. All rights reserved.


#import "PieChartExplainCell.h"
#import "PieChartLegend.h"


@interface PieChartExplainCell ()

@property (weak, nonatomic) IBOutlet UIImageView * gradeImageView;
@property (weak, nonatomic) IBOutlet UILabel * gradeLabel;

@end


@implementation PieChartExplainCell

- (void)setCellWithData:(PieChartLegend *)legend
{
    self.gradeImageView.image = legend.legendImage;
    
    self.gradeLabel.text = legend.legendTitle;
}

@end
