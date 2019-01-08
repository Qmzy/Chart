//
//  BarPoint.m
//  Chart
//
//  Created by CYKJ on 2019/1/7.
//  Copyright © 2019年 D. All rights reserved.


#import "BarPoint.h"

@implementation BarPoint

- (instancetype)initWithX:(CGFloat)x andY:(CGFloat)y
{
    if (self = [super init]) {
        self.point = CGPointMake(x, y);
        [self setDefaultAttribute];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setDefaultAttribute];
    }
    return self;
}

- (void)setDefaultAttribute
{
    self.backColor = [UIColor blackColor];
}

@end
