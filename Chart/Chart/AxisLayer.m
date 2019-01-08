//
//  AxisLayer.m
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import "AxisLayer.h"

#define DRAW_W  (VIEW_W - self.params.xAxisLMargin - self.params.xAxisRMargin)
#define DRAW_H  (VIEW_H - self.params.yAxisTMargin - self.params.yAxisBMargin)

@interface AxisLayer ()
@property (nonatomic, readwrite, strong) AxisParams * params;
@end


@implementation AxisLayer
{
    @private
        CAShapeLayer * _axisLayer;
        CAShapeLayer * _xScaleLayer;
        CAShapeLayer * _yScaleLayer;
        CAShapeLayer * _yReferenceLayer;
}
@synthesize yScaleLineAry = _yScaleLineAry;

static AxisLayer * singleton;
//
//- (instancetype)sharedInstance
//{
//    return [[self class] sharedInstance];
//}
//
//+ (instancetype)sharedInstance
//{
//    static dispatch_once_t once;
//    dispatch_once( &once, ^{
//        singleton = [[self alloc] init];
//    });
//    return singleton;
//}
//
//+ (id)allocWithZone:(struct _NSZone *)zone
//{
//    if (singleton == nil) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            singleton = [super allocWithZone:zone];
//        });
//    }
//    return singleton;
//}
//
//- (instancetype)init
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        singleton = [super init];
//        singleton.params = [[AxisParams alloc] init];
//    });
//    return singleton;
//}

- (instancetype)init
{
    if (self = [super init]) {
        self.params = [[AxisParams alloc] init];
    }
    return self;
}

/// 绘制 x、y 坐标轴
- (void)drawXYAxis
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    // y 轴
    if (self.params.needYAxis) {
        [path moveToPoint:CGPointMake(self.params.xAxisLMargin, self.params.yAxisTMargin)];
        [path addLineToPoint:CGPointMake(self.params.xAxisLMargin, VIEW_H - self.params.yAxisBMargin)];
    }
    
    // x 轴
    if (self.params.needXAxis) {
        if (path.isEmpty) {
            [path moveToPoint:CGPointMake(self.params.xAxisLMargin, VIEW_H - self.params.yAxisBMargin)];
        }
        [path addLineToPoint:CGPointMake(VIEW_W - self.params.xAxisRMargin, VIEW_H - self.params.yAxisBMargin)];
    }
    
    [_axisLayer removeFromSuperlayer];
    _axisLayer = nil;
    
    if (!path.isEmpty) {
        _axisLayer = [CAShapeLayer layer];
        _axisLayer.path        = path.CGPath;
        _axisLayer.strokeColor = self.params.xAxisColor.CGColor;
        _axisLayer.fillColor   = self.params.xAxisColor.CGColor;
        _axisLayer.borderWidth = 2.0;
        [self addSublayer:_axisLayer];
    }
    
    [self drawXScale];
    [self drawYScale];
    [self drawReferenceLine];
}


#pragma mark - X Scale
/**
  *  @brief   设置 x 轴刻度线数组
  */
- (void)setXScaleLineAry:(NSArray *)xScaleLineAry
{
    _xScaleLineAry = xScaleLineAry;
    
    [self drawXScale];
}

/**
  *  @brief   绘制 x 轴刻度
  */
- (void)drawXScale
{
    [_xScaleLayer removeFromSuperlayer];
    _xScaleLayer = nil;

    if (_xScaleLineAry.count == 0) return;
    
    // 刻度间隔
    CGFloat xSpace = 0;
    
    if (_xScaleLineAry.count > 1) {
        xSpace = (DRAW_W - self.params.xValueOffset) / (_xScaleLineAry.count - 1);
    }
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGFloat w = 25.0;
    CGFloat h = 11.0;
    CGFloat xOffset = (self.params.needYValue ? 0 : w/2);
    
    for (int i = 0; i < _xScaleLineAry.count; i++) {
        
        CGFloat x = self.params.xAxisLMargin + xSpace * i + self.params.xValueOffset;
        
        // 刻度
        if (self.params.needXScale) {
            CGPoint point = CGPointMake(x , VIEW_H - self.params.yAxisBMargin);
            [path moveToPoint:point];
            [path addLineToPoint:CGPointMake(point.x, point.y - 3)];
        }
        
        // 文本  TODO
        if (self.params.needXValue) {
            CATextLayer * textLayer = [self textLayer];
            // CATextLayer 没有垂直居中属性，两种方式：1、计算 y 偏移量    2、NSMutableParagraphStyle 设置 NSBaselineOffsetAttributeName
            // 方式 1
            textLayer.frame = CGRectMake((i == 0) ? x - xOffset : x - w/2, DRAW_H + (self.params.yAxisBMargin - h)/2, w, h);
            textLayer.string = _xScaleLineAry[i];
            textLayer.foregroundColor = self.params.xValueColor.CGColor; // 字体颜色
            // 方式 2
            //textLayer.frame = CGRectMake((i == 0) ? x - xOffset : x - w/2, DRAW_H, w, self.params.yAxisBMargin);
            //NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:_xScaleLineAry[i] attributes:@{ NSBaselineOffsetAttributeName : @((h - self.params.yAxisBMargin) / 2), NSForegroundColorAttributeName : self.params.xValueColor, NSFontAttributeName : [UIFont fontWithName:@"PingFang-SC-Medium" size:8.0] }];  // 设置垂直方向偏移量、文本颜色、字体大小
            //textLayer.string = attributedString;
            [self addSublayer:textLayer];
        }
    }
    
    if (!path.isEmpty) {
        _xScaleLayer = [CAShapeLayer layer];
        _xScaleLayer.path        = path.CGPath;
        _xScaleLayer.strokeColor = [UIColor blackColor].CGColor;
        _xScaleLayer.fillColor   = [UIColor clearColor].CGColor;
        _xScaleLayer.borderWidth = 2.0;
        [self addSublayer:_xScaleLayer];
    }
}


#pragma mark - Y Scale
/**
  *  @brief   设置 y 轴刻度数组
  */
- (void)setYScaleLineAry:(NSArray *)yScaleLineAry
{
    _yScaleLineAry = yScaleLineAry;
    
    self.params.numberScaleOfYAxis = yScaleLineAry.count;
    
    [self drawYScale];
}

/**
  *  @brief   绘制 y 轴刻度
  */
- (void)drawYScale
{
    [_yScaleLayer removeFromSuperlayer];
    _yScaleLayer = nil;
    
    if (_yScaleLineAry.count == 0) return;
    
    // 刻度间隔
    CGFloat ySpace = 0;
    
    if (self.params.numberScaleOfYAxis > 1) {
        // 绘图区为顶部留白 15%
        ySpace = self.drawH * 0.85 / (self.params.numberScaleOfYAxis - 1);
    }
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    for (int i = 0; i < _yScaleLineAry.count; i++) {
        
        CGFloat y = self.drawH + self.params.yAxisTMargin - ySpace * i;
        
        // 刻度
        if (self.params.needYScale) {
            CGPoint point = CGPointMake(self.params.xAxisLMargin, y);
            [path moveToPoint:point];
            [path addLineToPoint:CGPointMake(point.x + 3, point.y)];
        }
        
        // 文本  TODO
        if (self.params.needYValue) {
            CATextLayer * textLayer = [self textLayer];
            textLayer.frame  = CGRectMake(self.params.xAxisLMargin - 15, y - 11/2.0, 15, 11);
            textLayer.foregroundColor = self.params.yValueColor.CGColor;  // 字体颜色
            textLayer.string = [NSString stringWithFormat:@"%.0f", [_yScaleLineAry[i] floatValue]];
            [self addSublayer:textLayer];
        }
    }
    
    if (!path.isEmpty) {
        _yScaleLayer = [CAShapeLayer layer];
        _yScaleLayer.path = path.CGPath;
        _yScaleLayer.strokeColor = [UIColor blackColor].CGColor;
        _yScaleLayer.fillColor = [UIColor clearColor].CGColor;
        _yScaleLayer.borderWidth = 2.0;
        [self addSublayer:_yScaleLayer];
    }
}


#pragma mark - Reference Line
/**
  *  @brief   绘制参考线
  */
- (void)drawReferenceLine
{
    [_yReferenceLayer removeFromSuperlayer];
    _yReferenceLayer = nil;
    
    if (!self.referenceLineAry || self.referenceLineAry.count == 0 || !self.params.isNeedReferenceLine)  return;
    
    CGFloat max = [[self.referenceLineAry  lastObject] floatValue];
    CGFloat min = [[self.referenceLineAry firstObject] floatValue];
    // 像素比例。绘图区为顶部留白 15%
    CGFloat pixelRate = self.drawH * 0.85 / (max - min);
    
    // 虚线数组
    //CGFloat pattern[] = { 5, 2 };
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    for (int i = 0, count = (int)self.referenceLineAry.count; i < count; i++) {
        
        CGFloat h = ([self.referenceLineAry[i] floatValue] - min) * pixelRate;
        [path moveToPoint:CGPointMake(self.params.xAxisLMargin, DRAW_H + self.params.yAxisTMargin - h)];
        [path addLineToPoint:CGPointMake(VIEW_W - self.params.xAxisRMargin, DRAW_H + self.params.yAxisTMargin - h)];
        // count - 数组长度    phase ：初始跳过长度。path 绘制用于 context 上下文中。
        //[path setLineDash:pattern count:2 phase:0];
    }
    
    _yReferenceLayer = [CAShapeLayer layer];
    _yReferenceLayer.lineDashPattern = @[ @(5), @(2) ];
    _yReferenceLayer.path = path.CGPath;
    _yReferenceLayer.strokeColor = self.params.referenceLineColor.CGColor;
    _yReferenceLayer.fillColor = [UIColor clearColor].CGColor;
    _yReferenceLayer.lineWidth = 0.5;
    [self addSublayer:_yReferenceLayer];
}


#pragma mark - GET
/**
  *  @brief   获取 y 轴刻度线数组
  */
- (NSArray *)yScaleLineAry
{
    if (_yScaleLineAry && _yScaleLineAry.count > 0)
        return _yScaleLineAry;
    
    if (_referenceLineAry && _referenceLineAry.count > 0) {
        self.yScaleLineAry = _referenceLineAry;
        return _yScaleLineAry;
    }
    
    if (self.params.maxYAxisValue > self.params.minYAxisValue) {
        NSMutableArray * mArr = [NSMutableArray arrayWithObjects:@(self.params.minYAxisValue), nil];
        
        // 刻度数 > 1
        if (self.params.numberScaleOfYAxis > 1) {
            CGFloat interval = (self.params.maxYAxisValue - self.params.minYAxisValue) / (self.params.numberScaleOfYAxis - 1);
            
            for (int i = 1; i < self.params.numberScaleOfYAxis; i++) {
                [mArr addObject:@(self.params.minYAxisValue + interval * i)];
            }
        }
        
        // 当刻度数 = 1 时，只有一个 _minYAxisValue 值
        self.yScaleLineAry = [mArr copy];
        
        return _yScaleLineAry;
    }
    
    return nil;
}

/**
  *  @brief   文本绘制图层
  */
- (CATextLayer *)textLayer
{
    CATextLayer * layer = [[CATextLayer alloc] init];
    layer.contentsScale = [UIScreen mainScreen].scale;  // 渲染分辨率（重要），否则显示模糊
    //layer.wrapped = NO;  // 分行显示
    //layer.truncationMode = kCATruncationNone;  // 超长显示时，省略号位置
    layer.font = CGFontCreateWithFontName((__bridge CFStringRef)@"PingFang-SC-Medium"); // 字体名称
    layer.fontSize = 8.0;  // 字体大小
    layer.alignmentMode = kCAAlignmentCenter;  // 字体对齐方式

    return layer;
}

- (CGFloat)drawW
{
    return DRAW_W;
}

- (CGFloat)drawH
{
    return DRAW_H;
}

@end
