//
//  LineGraphAttribute.m
//  Chart
//
//  Created by CYKJ on 2019/1/4.
//  Copyright © 2019年 D. All rights reserved.


#import "LineGraphAttribute.h"
#import "Macro.h"

@implementation LineGraphAttribute

- (instancetype)init
{
    if (self = [super init]) {
        self.isNeedDot = YES;
        self.isNeedGradient = NO;
        self.needAnimation = NO;
        self.drawColor = UIColorFromRGB(0x6FBA2C);
        self.dotColor  = UIColorFromRGB(0xFFB214);
        self.fromColor = UIColorFromARGB(0xD491CA5F);
        self.toColor   = UIColorFromARGB(0x0091CA5F);
        self.dotRadius = 2;
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

@end
