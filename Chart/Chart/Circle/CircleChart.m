//
//  CircleView.m
//
//  Created by D on 2018/12/25.
//  Copyright © 2018年 D. All rights reserved.


#import "CircleChart.h"
#import "Macro.h"

@interface CircleChart ()

@end

#define CIRCLE_CENTER  CGPointMake(self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f)
#define CIRCLE_RADIUS      69.5
#define kAnimationDuration 1.0f

@implementation CircleChart
{
    @private
        CAShapeLayer * _bgCircleLayer;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.colorArr = @[ UIColorFromRGB(0x40BFF5), UIColorFromRGB(0x4ECF7C), UIColorFromRGB(0xFFBD21)];
    self.percentArr = @[ @(0.5), @(0.25), @(0.25) ];
    self.lineWidthArr = @[ @(21), @(11), @(11) ];
}

/**
  *  @brief   开始绘制圆环
  */
- (void)startDraw
{
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    if (![self correctData])  return;
    
    // 底部圆
    UIBezierPath * bgPath = [UIBezierPath bezierPathWithArcCenter:CIRCLE_CENTER
                                                           radius:CIRCLE_RADIUS
                                                       startAngle:-M_PI_2
                                                         endAngle:M_PI_2 * 3
                                                       clockwise:YES];
    _bgCircleLayer = [CAShapeLayer layer];
    _bgCircleLayer.fillColor   = [UIColor clearColor].CGColor;
    _bgCircleLayer.strokeColor = [UIColor whiteColor].CGColor;
    _bgCircleLayer.strokeStart = 0.0f;
    _bgCircleLayer.strokeEnd   = 1.0f;
    _bgCircleLayer.zPosition   = 1;
    _bgCircleLayer.lineWidth   = CIRCLE_RADIUS;
    _bgCircleLayer.path        = bgPath.CGPath;
    
    CGFloat start = 0.f;  // 开始
    CGFloat end = 0.f;    // 结束
    CGFloat innerRadius;  // 内环半径
    CGFloat outerRadius;  // 外环半径
    
    for (int i = 0, count = (int)self.percentArr.count; i < count; i++) {
        
        // 如果当前所占百分比 <= 0 不绘制
        if ([self.percentArr[i] floatValue] <= 0)  break;
        
        // 半径。根据展示的圆环宽度计算
        innerRadius = CIRCLE_RADIUS - [self.lineWidthArr[i] floatValue] / 2;
        outerRadius = CIRCLE_RADIUS + [self.lineWidthArr[i] floatValue] / 2;

        // end 位置
        end += [self.percentArr[i] floatValue];
        
        [self drawArcLayerAtIndex:i
                      innerRadius:innerRadius
                      outerRadius:outerRadius
                       startAngle:-M_PI_2 + M_PI * 2 * start
                         endAngle:-M_PI_2 + M_PI * 2 * end];
        
        // 当前的 end 位置是之后的 start
        start = end;
    }
    
    self.layer.mask = _bgCircleLayer;
    
    [self startStroke];
}

/**
  *  @brief   绘制圆环
  *  @param   index   顺时针绘制时的索引
  *  @param   innerRadius   内环半径
  *  @param   outerRadius   外环半径
  *  @param   startAngle   开始角度
  *  @param   endAngle   结束角度
  */
- (void)drawArcLayerAtIndex:(NSInteger)index innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    // 扇形
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CIRCLE_CENTER];
    [path addArcWithCenter:CIRCLE_CENTER radius:outerRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path closePath];
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    shapeLayer.fillColor = [self.colorArr[index] CGColor];
    shapeLayer.lineWidth = 2;
    [self.layer addSublayer:shapeLayer];
    
    // 遮罩，产生圆弧
    UIBezierPath * maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CIRCLE_CENTER];
    [maskPath addArcWithCenter:CIRCLE_CENTER radius:innerRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [maskPath closePath];
    
    CAShapeLayer * maskShapeLayer = [CAShapeLayer layer];
    maskShapeLayer.path = maskPath.CGPath;
    maskShapeLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskShapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    [self.layer addSublayer:maskShapeLayer];
}

/**
  *  @brief   开启动画
  */
- (void)startStroke
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = kAnimationDuration;
    animation.fromValue = @0.0f;
    animation.toValue   = @1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [_bgCircleLayer addAnimation:animation forKey:@"circleAnimation"];
}

/**
  *  @brief   检查数据是否正确
  */
- (BOOL)correctData
{
    return self.colorArr.count == self.percentArr.count && self.colorArr.count == self.lineWidthArr.count;
}

@end
