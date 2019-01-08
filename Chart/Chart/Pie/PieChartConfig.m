//
//  PieChartConfig.m
//
//  Created by D on 17/6/26.
//  Copyright © 2017年 D. All rights reserved.


#import "PieChartConfig.h"
#import "Macro.h"

@implementation PieChartConfig

- (instancetype)init
{
    if (self = [super init]) {
    
        self.radius       = 75;
        self.renderRadius = 22.5;
        self.sectorSpace  = 2;
        self.dotMargin    = 10;
        
        self.spaceColor = [UIColor whiteColor];
        self.lineColor  = nil;
        self.tipLColor  = UIColorFromRGB(0x222222);
        self.nilColor   = UIColorFromRGB(0xeeeeee);
        self.nilTipColor = UIColorFromRGB(0x999999);
        
        self.isNeedCircleDot = NO;
        self.isNilDraw = YES;
        self.isNeedExplain = YES;
        
        self.itemsInRow = 4;
        
        self.nilTip = @"数据不足";
    }
    return self;
}

@end
