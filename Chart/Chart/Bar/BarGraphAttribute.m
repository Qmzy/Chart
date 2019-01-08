//
//  BarGraphAttribute.m
//  Chart
//
//  Created by CYKJ on 2019/1/7.
//  Copyright © 2019年 D. All rights reserved.


#import "BarGraphAttribute.h"
#import "Macro.h"

@implementation BarGraphAttribute

- (instancetype)init
{
    if (self = [super init]) {
        self.isNeedGradient = NO;
        self.needAnimation = NO;
        self.barColor  = UIColorFromRGB(0x6FBA2C);
        self.fromColor = UIColorFromARGB(0xD491CA5F);
        self.toColor   = UIColorFromARGB(0x0091CA5F);
        self.barWidth  = 8.0;
        self.needCircleBar = YES;
        self.pointCount = 0;
        self.maxValue  = 0;
        self.minValue  = 0;
    }
    return self;
}

- (void)setFromColor:(UIColor *)fromColor
{
    _fromColor = fromColor;
    
    if (_toColor == nil)    _toColor = fromColor;
}

- (void)setToColor:(UIColor *)toColor
{
    _toColor = toColor;
    
    if (_fromColor == nil)  _fromColor = toColor;
}

- (void)setBarWidth:(CGFloat)barWidth
{
    _barWidth = MIN(30, MAX(barWidth, 4));
}

@end
