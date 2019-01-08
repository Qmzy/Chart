//
//  CircleView.h
//
//  Created by D on 2018/12/25.
//  Copyright © 2018年 D. All rights reserved.


#import <UIKit/UIKit.h>

@interface CircleChart : UIView

@property (nonatomic, strong) NSArray * colorArr;     // 颜色值数组
@property (nonatomic, strong) NSArray * percentArr;   // 与颜色值一一对应的圆环百分比值数组
@property (nonatomic, strong) NSArray * lineWidthArr; // 与颜色值一一对应的绘制线条粗细值数组

- (void)startDraw;

@end
