//
//  PieChartLegend.m
//
//  Created by D on 2017/7/19.
//  Copyright © 2017年 D. All rights reserved.


#import "PieChartLegend.h"
#import "XUtil.h"

#define LEGENDIMAGE_W    11

@implementation PieChartLegend

- (instancetype)init
{
    if (self = [super init]) {
        
        _legendTitle  = @"";
        _legendHeight = 10;
        
        self.legendWidth = 0;
    }
    return self;
}

- (void)setLegendTitle:(NSString *)legendTitle
{
    _legendTitle = legendTitle;
    
    self.legendWidth = [self getTitleWidth];
}

- (void)setLegendHeight:(CGFloat)legendHeight
{
    _legendHeight = legendHeight;
    
    self.legendWidth = [self getTitleWidth];
}

/**
  *  @brief   用于计算不确定长度的 title 内容的宽度
  */
- (CGFloat)getTitleWidth
{
    return [XUtil calculateTextWidth:self.legendTitle
                              height:self.legendHeight
                                font:[UIFont systemFontOfSize:9.0]] + LEGENDIMAGE_W;
}

@end
