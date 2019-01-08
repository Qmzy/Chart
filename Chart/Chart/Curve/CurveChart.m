//
//  CurveView.m
//  CiYunApp
//
//  Created by CYKJ on 2018/12/25.
//  Copyright © 2018年 北京慈云科技有限公司. All rights reserved.


#import "CurveChart.h"
#import "CurvePromptView.h"
#import "Macro.h"
#import "XUtil.h"

@interface CurveChart ()

@property (nonatomic, strong) AxisLayer * axisLayer;
@property (nonatomic, strong) UIScrollView * bgScrollView;
@property (nonatomic, strong) NSMutableArray * allPoints;
@property (nonatomic, strong) UIView * gradientBgView;
@property (nonatomic, strong) CurvePromptView * promptView; // 提示内容视图
@property (nonatomic, strong) UITapGestureRecognizer * tap;

@end


@implementation CurveChart
{
    @private
        CGFloat _xSpace;
        CAShapeLayer * _yValueLayer;
        CAGradientLayer * _gradientLayer;
        CAShapeLayer * _dotLayer;    // 圆点
        CAShapeLayer * _crossLayer;  // 十字叉
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setDefaultAttribute];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setDefaultAttribute];
    }
    return self;
}

/**
  *  @brief   初始化参数值
  */
- (void)setDefaultAttribute
{
    self.isNeedDot = YES;
    self.isNeedGradient = NO;
    self.isNeedLowValue = YES;
    self.isPromptOnTaped = YES;

    self.drawColor = UIColorFromRGB(0x6FBA2C);
    self.dotColor = UIColorFromRGB(0xFFB214);
    self.fromColor = UIColorFromARGB(0xD491CA5F);
    self.toColor = UIColorFromARGB(0x0091CA5F);
    
    self.isHorizontalScroll = NO;
    self.maxCountPerScreen = 7;
    self.isShowAllXScaleValue = NO;
}

/**
  *  @brief   初始化滚动视图，用于趋势图的滑动查看
  */
- (void)initBgScrollView
{
    if (_bgScrollView == nil) {
        _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.axisLayer.params.xAxisLMargin, self.axisLayer.params.yAxisTMargin, self.axisLayer.drawW, self.axisLayer.drawH)];
        _bgScrollView.backgroundColor = [UIColor clearColor];
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_bgScrollView];
    }
    else if (_bgScrollView.layer.superlayer == nil) {
        [self.layer addSublayer:_bgScrollView.layer];
    }
}

/**
  *  @brief   清理图层
  */
- (void)clean
{
    [self.allPoints removeAllObjects];
    self.allPoints = nil;
    self.allPoints = [NSMutableArray array];
    
    [_axisLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_bgScrollView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _bgScrollView = nil;
    
    _yValueLayer   = nil;
    _gradientLayer = nil;
    _crossLayer    = nil;
    _dotLayer      = nil;
    
    [_gradientBgView removeFromSuperview];
    _gradientBgView = nil;
    _promptView.hidden = YES;
}

/**
  *  @brief   开始绘制
  */
- (void)drawCurveChartWithXValues:(NSArray *)x_values yValues:(NSArray *)y_values
{
    // 清除图层
    [self clean];
    
    self.xAxisValue = x_values;
    self.yAxisValue = y_values;
    
    // 初始化底部滚动视图
    [self initBgScrollView];
    
    // 绘制 x、y 轴
    [self.axisLayer drawXYAxis];
    
    // 计算 x 轴数据点间的间隔
    _xSpace = 0;
    
    // 可横向滚动 & 点数一屏显示不了时
    if (_isHorizontalScroll && y_values.count >= _maxCountPerScreen) {
        
        _xSpace = self.axisLayer.drawW / (_maxCountPerScreen - 1);
        CGFloat xAxisWidth = _xSpace * (double)(y_values.count - 1);
        _bgScrollView.contentSize = CGSizeMake(xAxisWidth, self.axisLayer.drawH);
    }
    else {
        _bgScrollView.contentSize = CGSizeMake(self.axisLayer.drawW, self.axisLayer.drawH);
        
        if (y_values.count > 1) {
            _xSpace = self.axisLayer.drawW / (y_values.count - 1);
        }
    }

    CGFloat max = [[self.axisLayer.yScaleLineAry  lastObject] floatValue];
    CGFloat min = [[self.axisLayer.yScaleLineAry firstObject] floatValue];
    // 像素比例。绘图区为顶部留白 15%
    CGFloat pixelRate = 1;
    if (max - min > 0) {
        pixelRate = self.axisLayer.drawH * 0.85 / (max - min);
    }

    // 获取所有的数据 point
    for (int i = 0; i < y_values.count; i++) {
        
        CGFloat x = _xSpace * i;  // + self.axisLayer.params.xAxisLMargin
        CGFloat y = _axisLayer.drawH + _axisLayer.params.yAxisTMargin - ([y_values[i] floatValue] - min) * pixelRate;

        CGPoint point = CGPointMake(x, y);

        if (self.isNeedDot) {
            UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x - 1, point.y - 1, 2, 2) cornerRadius:1];
            CAShapeLayer * layer = [CAShapeLayer layer];
            layer.strokeColor = self.dotColor.CGColor;
            layer.fillColor = self.dotColor.CGColor;
            layer.path = path.CGPath;
            [_bgScrollView.layer addSublayer:layer];
        }
        [_allPoints addObject:[NSValue valueWithCGPoint:point]];
    }

    if (_allPoints.count == 0)  return;
    
    [self drawChartLayer];
    [self drawGradientLayer];
}

/**
  *  @brief   绘制趋势图
  */
- (void)drawChartLayer
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint prePonit;
    BOOL isLow = YES; // 是否超出绘制区域
    
    for (int i = 0; i < _allPoints.count; i++) {
        
        CGPoint curPoint = [self.allPoints[i] CGPointValue];
        
        // 超出绘制区域
        if (curPoint.y > self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin) {
            
            if (self.isNeedLowValue) {
                
                curPoint = CGPointMake(curPoint.x, self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin);
                [path addCurveToPoint:curPoint controlPoint1:CGPointMake((prePonit.x + curPoint.x) / 2, prePonit.y) controlPoint2:CGPointMake((prePonit.x + curPoint.x) / 2, curPoint.y)];
                prePonit = curPoint;
            }
            else {
                isLow = YES;
            }
        }
        // 未超出
        else {
            if (isLow) {
                // 上一个超出绘制区域
                [path moveToPoint:curPoint];
            }
            else {
                // 三次曲线
                [path addCurveToPoint:curPoint controlPoint1:CGPointMake((prePonit.x + curPoint.x) / 2, prePonit.y) controlPoint2:CGPointMake((prePonit.x + curPoint.x) / 2, curPoint.y)];
            }
            prePonit = curPoint;
            isLow = NO;
        }
    }
    
    _yValueLayer = [CAShapeLayer layer];
    _yValueLayer.path = path.CGPath;
    _yValueLayer.strokeColor = self.drawColor.CGColor;
    _yValueLayer.fillColor   = [UIColor clearColor].CGColor;
    _yValueLayer.borderWidth = 2.0;
    [_bgScrollView.layer addSublayer:_yValueLayer];
}

/**
  *  @brief   添加渐变图层
  */
- (void)drawGradientLayer
{
    if (!self.isNeedGradient)  return;
    
    // 用于不规则区域渐变的 mask 图层
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    
    // 背景视图
    [_bgScrollView addSubview:self.gradientBgView];
    
    // 渐变图层
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.colors = @[ (id)[self.fromColor CGColor],
                              (id)[self.toColor CGColor] ];
    _gradientLayer.locations  = @[@(0), @(1.0f)];
    _gradientLayer.startPoint = CGPointMake(0.5, 0);
    _gradientLayer.endPoint   = CGPointMake(0.5, 1);
    
    CGFloat gradientX = 0.0;
    CGFloat gradientW = 0.0;
    CGFloat gradientH = self.axisLayer.drawH;
    CGFloat gradientY = self.axisLayer.params.yAxisTMargin;
    
    CGPoint prePonit;
    
    for (int i = 0; i < _allPoints.count; i++) {
        
        if (i == 0) {
            prePonit = [_allPoints[0] CGPointValue];
            // maskLayer 是相对于 gradientLayer 布局，所以 x 值为 0
            CGPathMoveToPoint(maskPath, NULL, 0, VIEW_H - self.axisLayer.params.yAxisBMargin);
            CGPathAddLineToPoint(maskPath, NULL, 0, prePonit.y - gradientY);
            gradientX = prePonit.x;
        }
        else {
            CGPoint curPoint = [_allPoints[i] CGPointValue];
            // 三次曲线
            CGPathAddCurveToPoint(maskPath, NULL, (prePonit.x + curPoint.x) / 2 - gradientX, prePonit.y - gradientY, (prePonit.x + curPoint.x) / 2 - gradientX, curPoint.y - gradientY, curPoint.x - gradientX, curPoint.y - gradientY);
            prePonit = curPoint;
            gradientW = curPoint.x - gradientX;
        }
        
        // 最后一个点
        if (i == _allPoints.count - 1) {
            CGPathAddLineToPoint(maskPath, NULL, prePonit.x - gradientX, VIEW_H - self.axisLayer.params.yAxisBMargin);
            _gradientLayer.frame = CGRectMake(gradientX, gradientY, gradientW, gradientH);
        }
    }
    
    maskLayer.path = maskPath;
    
    [_gradientLayer setMask:maskLayer];
    [_gradientBgView.layer addSublayer:_gradientLayer]; // 获得了 0.38 的透明度
    
    CGPathRelease(maskPath);
}


#pragma mark - Touch
/**
  *  @brief   界面被点击
  */
- (void)viewTaped:(UIGestureRecognizer *)gesture
{
    if (_allPoints.count == 0) return;
    
    // 获取在 _bgScrollView 视图上的坐标
    CGPoint point = [self convertPoint:[gesture locationInView:self] toView:_bgScrollView];
    
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    CGFloat w = _bgScrollView.contentSize.width;
    
    //判断临界情况。当前设定边界只能超出 10pt
    if (point.x < 0) {  // self.axisLayer.params.xAxisLMargin
        
        if (point.x > - 10) {
            x = 0.f;
        }
        else {
            return;
        }
    }
    else if (point.x > w) {  // VIEW_W - _axisLayer.params.xAxisRMargin
        
        if (point.x < w + 10) {
            x = w;
        }
        else {
            return;
        }
    }
    else {
        x = point.x;
    }
    
    if (point.y > _axisLayer.drawH) {  //  + _axisLayer.params.yAxisTMargin
        
        if (point.y < _axisLayer.drawH + 10) {
            y = _axisLayer.drawH;
        }
        else {
            return;
        }
    }
    else if (point.y < 0) {   // _axisLayer.params.yAxisTMargin
        
        if (point.y > -10) {
            y = 0;
        }
    }
    else {
        y = point.y;
    }
    
    [self drawCross:CGPointMake(x, y)];
}

/**
  *  @brief   绘制十字叉
  */
- (void)drawCross:(CGPoint)point
{
    // 先隐藏上次的
    [_crossLayer removeFromSuperlayer];
    _crossLayer = nil;
    [_dotLayer removeFromSuperlayer];
    _dotLayer = nil;
    _promptView.hidden = YES;

    // 计算出在 _allPoints 数组中对应的索引
    NSInteger index = (NSInteger)(point.x / _xSpace);
    index = MIN(_allPoints.count - 1, MAX(0, index));
    
    CGPoint verticalPoint = [_allPoints[index] CGPointValue];
    
    // 优先查找垂直方向。垂直方向上响应区域为 ± 20
    if (fabs(verticalPoint.y - point.y) <= 20) {
        
        [self adjustCrossLayer:verticalPoint];
        [self showPrompt:verticalPoint atIndex:index];
    }
    // 垂直方向没有满足的点，查找水平方向
    else {
        
        CGPoint horizontalPoint = CGPointZero;
        BOOL isAlready = NO; // 是否已经找到
        
        // 水平方向 ±15 的区域内查找。优先左侧查找
        for (NSInteger i = index - 1; i >= 0; i--) {
            horizontalPoint = [_allPoints[i] CGPointValue];
            
            if (point.x - horizontalPoint.x > 15)
                break;  // 超出了 15pt 的查找范围，结束
            
            if (fabs(horizontalPoint.y - point.y) <= 20) {
                [self adjustCrossLayer:horizontalPoint];
                [self showPrompt:horizontalPoint atIndex:i];
                isAlready = YES;
                break;
            }
        }
        
        if (isAlready)  return;
        
        for (NSInteger i = index + 1; i < index; i--) {
            horizontalPoint = [_allPoints[i] CGPointValue];
            
            if (point.x - horizontalPoint.x > 15)
                break;  // 超出了 15pt 的查找范围，结束
            
            if (fabs(horizontalPoint.y - point.y) <= 20) {
                [self adjustCrossLayer:horizontalPoint];
                [self showPrompt:horizontalPoint atIndex:i];
                break;
            }
        }
    }
}

/**
  *  @brief   调整十字叉、圆点的位置
  */
- (void)adjustCrossLayer:(CGPoint)point
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    // 横线
    [path moveToPoint:CGPointMake(0, point.y)];  // _axisLayer.params.xAxisLMargin
    [path addLineToPoint:CGPointMake(_bgScrollView.contentSize.width, point.y)];
    // 竖线
    [path moveToPoint:CGPointMake(point.x, _axisLayer.params.yAxisTMargin)];
    [path addLineToPoint:CGPointMake(point.x, _axisLayer.drawH + _axisLayer.params.yAxisTMargin)];
    
    _crossLayer = [CAShapeLayer layer];
    _crossLayer.path = path.CGPath;
    _crossLayer.lineWidth = 1.f;
    _crossLayer.strokeColor = UIColorFromRGB(0xFFE9BE).CGColor;
    _crossLayer.fillColor = [UIColor clearColor].CGColor;
    [_bgScrollView.layer addSublayer:_crossLayer];
    
    // 圆点
    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x - 2, point.y - 2, 4, 4) cornerRadius:2];
    
    _dotLayer = [CAShapeLayer layer];
    _dotLayer.path = path.CGPath;
    _dotLayer.strokeColor = [UIColor whiteColor].CGColor;
    _dotLayer.lineWidth = 1;
    _dotLayer.fillColor = self.dotColor.CGColor;
    [_bgScrollView.layer addSublayer:_dotLayer];
}

/**
  *  @brief   提示，调整位置
  */
- (void)showPrompt:(CGPoint)point atIndex:(NSInteger)index
{
    CGFloat y = MAX(self.axisLayer.params.yAxisTMargin + 10, point.y - 40 - 16/2);
    
    self.promptView.center = [self convertPoint:CGPointMake(point.x, y) fromView:_bgScrollView];
    
    NSString * xValue = nil;
    if (index >= 0 && index < self.yAxisValue.count) {
        xValue = [NSString stringWithFormat:@"%.0f 次/分", [self.yAxisValue[index] floatValue]];
    }
    
    NSString * yValue = nil;
    if (index >= 0 && index < self.xAxisValue.count) {
        yValue = self.xAxisValue[index];
    }
    [self.promptView setViewWithLeftValue:xValue rightValue:yValue];
    self.promptView.hidden = NO;
}


#pragma mark - SET/GET
/**
  *  @brief   设置是否展示"提示视图"的手势
  */
- (void)setIsPromptOnTaped:(BOOL)isPromptOnTaped
{
    // 添加点击手势
    if (isPromptOnTaped) {
        
        // 当前没有手势
        if (_tap == nil) {
            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
            [self addGestureRecognizer:_tap];
        }
    }
    // 移除点击手势 & 当前手势存在
    else if (_tap) {
        [self removeGestureRecognizer:_tap];
        _tap = nil;
    }
}

- (void)setFromColor:(UIColor *)fromColor
{
    _fromColor = fromColor;
    
    if (_toColor == nil)
        _toColor = fromColor;
}

- (void)setToColor:(UIColor *)toColor
{
    _toColor = toColor;
    
    if (_fromColor == nil) {
        _fromColor = toColor;
    }
}

- (void)setMaxCountPerScreen:(NSInteger)maxCountPerScreen
{
    _maxCountPerScreen = MAX(maxCountPerScreen, 2);
}

- (AxisLayer *)axisLayer
{
    if (_axisLayer == nil) {
        _axisLayer = [[AxisLayer alloc] init];//[AxisLayer sharedInstance];
        _axisLayer.frame = self.bounds;
        [self.layer addSublayer:_axisLayer];
    }
    else if (_axisLayer.superlayer == nil) {
        [self.layer addSublayer:_axisLayer];
    }
    return _axisLayer;
}

- (UIView *)gradientBgView
{
    if (_gradientBgView == nil) {
        _gradientBgView = [[UIView alloc] initWithFrame:CGRectMake( 0,
                                                                    0,
                                                                    _bgScrollView.contentSize.width,
                                                                    _bgScrollView.contentSize.height)];
        _gradientBgView.alpha = 0.38;
    }
    return _gradientBgView;
}

- (CurvePromptView *)promptView
{
    if (_promptView == nil) {
        _promptView = (CurvePromptView *)[XUtil viewFromXibFile:@"CurvePromptView"];
        _promptView.frame = CGRectMake(0, 0, 67, 16);
        _promptView.hidden = YES;
        [self addSubview:_promptView];
    }
    return _promptView;
}

@end
