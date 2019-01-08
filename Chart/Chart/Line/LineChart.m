//
//  LineChart.m
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import "LineChart.h"
#import "LinePoint.h"
#import "LineGraphAttribute.h"
#import "LinePromptView.h"
#import "Macro.h"
#import "XUtil.h"

@interface LineChart ()

@property (nonatomic, strong) AxisLayer * axisLayer;
@property (nonatomic, strong) UIScrollView * bgScrollView;
@property (nonatomic, strong) NSMutableArray<LineGraphAttribute> * dataSource;
@property (nonatomic, strong) UIView * gradientBgView;
@property (nonatomic, strong) LinePromptView * promptView; // 提示内容视图
@property (nonatomic, strong) UITapGestureRecognizer * tap;

@end


@implementation LineChart
{
    @private
        CGFloat _xSpace;
        NSInteger _maxPointCount;  // 多个趋势图点数最大值
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
    self.backgroundColor = [UIColor clearColor];
    self.isNeedLowValue = YES;
    self.isPromptOnTaped = YES;
    self.isHorizontalScroll = NO;
    self.isShowAllXScaleValue = NO;
    self.maxCountPerScreen = 7;
    self.numberOfChartView = 0;
    _xSpace = 1.0;
    _maxPointCount = 0;
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
        _bgScrollView.clipsToBounds = NO;
        [self addSubview:_bgScrollView];
    }
    else if (_bgScrollView.layer.superlayer == nil) {
        [self.layer addSublayer:_bgScrollView.layer];
    }
}

/**
  *  @brief  设置趋势图个数
  */
- (void)initChartCount
{
    if ([_delegate respondsToSelector:@selector(numberOfChartView:)]) {
        _numberOfChartView = [_delegate numberOfChartView:self];
    }
    
    _numberOfChartView = MAX(0, _numberOfChartView);
}

/**
  *  @brief   设置各个趋势图的绘制属性
  */
- (void)initChartAttribute
{
    if ([_delegate respondsToSelector:@selector(chartView:graphAttributeAtIndex:)]) {
        
        _dataSource = [[NSMutableArray<LineGraphAttribute> alloc] initWithCapacity:_numberOfChartView];
        
        CGFloat yMaxValue = 0.0;
        CGFloat yMinValue = 0.0;
        
        // 循环各个趋势图
        for (int i = 0; i < _numberOfChartView; i++) {
            
            LineGraphAttribute * attribute = [_delegate chartView:self graphAttributeAtIndex:i];
            [_dataSource addObject:attribute];
            
            if ([_delegate respondsToSelector:@selector(chartView:numberOfPointAtIndex:)]) {
                attribute.pointCount = [_delegate chartView:self numberOfPointAtIndex:i];
            }
            
            attribute.values = [NSMutableArray arrayWithCapacity:attribute.pointCount];
            
            // 循环每个点
            for (int j = 0; j < attribute.pointCount; j++) {
                if ([_delegate respondsToSelector:@selector(chartView:pointIndex:chartIndex:)]) {
                    LinePoint * point = [_delegate chartView:self pointIndex:j chartIndex:i];
                    [attribute.values addObject:point];
                }
            }
            
            if (i == 0) {
                _maxPointCount = attribute.pointCount;
                yMaxValue = attribute.maxValue;
                yMinValue = attribute.minValue;
                continue;
            }
            
            // 最大点数
            if (attribute.pointCount > _maxPointCount) {
                _maxPointCount = attribute.pointCount;
            }
            
            // y 轴最大值
            if (attribute.maxValue > yMaxValue) {
                yMaxValue = attribute.maxValue;
            }
            
            // 最小值
            if (attribute.minValue < yMinValue) {
                yMinValue = attribute.minValue;
            }
        }
        
        self.axisLayer.params.maxYAxisValue = yMaxValue;
        self.axisLayer.params.minYAxisValue = yMinValue;
    }
    else {
        self.axisLayer.params.maxYAxisValue = 100;
        self.axisLayer.params.minYAxisValue = 0;
    }
}

/**
  *  @brief   清理图层
  */
- (void)clean
{
    [self.dataSource removeAllObjects];
    self.dataSource = nil;
    
    [_axisLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_bgScrollView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _bgScrollView = nil;
}

/**
  *  @brief   开始绘制
  */
- (void)drawLineChart
{
    // 清除图层
    [self clean];

    // 初始化底部滚动视图
    [self initBgScrollView];
    
    [self initChartCount];
    [self initChartAttribute];
    
    // 绘制 x、y 轴
    [self.axisLayer drawXYAxis];
    
    // 计算 x 轴数据点间的间隔
    _xSpace = 0;
    
    // 可横向滚动 & 点数一屏显示不了时
    if (_isHorizontalScroll && _maxPointCount >= _maxCountPerScreen) {
        
        _xSpace = self.axisLayer.drawW / (_maxCountPerScreen - 1);
        CGFloat xAxisWidth = _xSpace * (double)(_maxPointCount - 1);
        _bgScrollView.contentSize = CGSizeMake(xAxisWidth, self.axisLayer.drawH);
    }
    else {
        _bgScrollView.contentSize = CGSizeMake(self.axisLayer.drawW, self.axisLayer.drawH);
        
        if (_maxPointCount > 1) {
            _xSpace = self.axisLayer.drawW / (_maxPointCount - 1);
        }
    }
    
    CGFloat max = [[self.axisLayer.yScaleLineAry  lastObject] floatValue];
    CGFloat min = [[self.axisLayer.yScaleLineAry firstObject] floatValue];
    // 像素比例。绘图区为顶部留白 15%
    CGFloat pixelRate = 1;
    if (max - min > 0) {
        pixelRate = self.axisLayer.drawH * 0.85 / (max - min);
    }
    
    
    for (int i = 0; i < self.dataSource.count; i++) {

        LineGraphAttribute * attribute = self.dataSource[i];
        
        if (attribute.values.count == 0)  return;
        
        // 循环所有的数据点
        for (int j = 0; j < attribute.values.count; j++) {
            
            LinePoint * point = attribute.values[j];
            
            CGFloat x = _xSpace * j;
            CGFloat y = _axisLayer.drawH + _axisLayer.params.yAxisTMargin - (point.yValue - min) * pixelRate;
            
            CGPoint p = CGPointMake(x, y);
            point.point = p;
            
            if (attribute.isNeedDot) {
                UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(p.x - attribute.dotRadius, p.y - attribute.dotRadius, attribute.dotRadius * 2, attribute.dotRadius * 2) cornerRadius:attribute.dotRadius];
                CAShapeLayer * layer = [CAShapeLayer layer];
                layer.strokeColor = attribute.dotColor.CGColor;
                layer.fillColor   = attribute.dotColor.CGColor;
                layer.path = path.CGPath;
                [_bgScrollView.layer addSublayer:layer];
            }
        }
        
        [self    drawChartLayer:attribute];
        [self drawGradientLayer:attribute];
    }
}

/**
  *  @brief   绘制趋势图
  */
- (void)drawChartLayer:(LineGraphAttribute *)attribute
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint prePonit;
    BOOL isLow = YES; // 是否超出绘制区域
    
    for (int i = 0; i < attribute.values.count; i++) {
        
        CGPoint curPoint = ((LinePoint *)attribute.values[i]).point;
        
        // 超出绘制区域
        if (curPoint.y > self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin) {
            
            if (self.isNeedLowValue) {
                curPoint = CGPointMake(curPoint.x, self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin);
                [path addLineToPoint:curPoint];
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
                // 直线
                [path addLineToPoint:curPoint];
            }
            prePonit = curPoint;
            isLow = NO;
        }
    }
    
    CAShapeLayer * yValueLayer = [CAShapeLayer layer];
    yValueLayer.path = path.CGPath;
    yValueLayer.strokeColor = attribute.drawColor.CGColor;
    yValueLayer.fillColor   = [UIColor clearColor].CGColor;
    yValueLayer.borderWidth = 2.0;
    
    if (attribute.needAnimation) { // 显示过渡动画
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 1;
        animation.fromValue = @(0.0);
        animation.toValue = @(1.0);
        [yValueLayer addAnimation:animation forKey:@"strokeEnd"];
    }
    
    [_bgScrollView.layer addSublayer:yValueLayer];
}

/**
 *  @brief   添加渐变图层
 */
- (void)drawGradientLayer:(LineGraphAttribute *)attribute
{
    if (!attribute.isNeedGradient)  return;
    
    // 用于不规则区域渐变的 mask 图层
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    
    // 背景视图
    [_bgScrollView addSubview:self.gradientBgView];
    
    // 渐变图层
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[ (id)[attribute.fromColor CGColor],
                               (id)[attribute.toColor CGColor] ];
    gradientLayer.locations  = @[@(0), @(1.0f)];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint   = CGPointMake(0.5, 1);
    
    CGFloat gradientX = 0.0;
    CGFloat gradientW = 0.0;
    CGFloat gradientH = self.axisLayer.drawH;
    CGFloat gradientY = self.axisLayer.params.yAxisTMargin;
    
    CGPoint prePonit;
    
    for (int i = 0; i < attribute.values.count; i++) {
        
        if (i == 0) {
            prePonit = ((LinePoint *)attribute.values[0]).point;
            // maskLayer 是相对于 gradientLayer 布局，所以 x 值为 0
            CGPathMoveToPoint(maskPath, NULL, 0, VIEW_H - self.axisLayer.params.yAxisBMargin);
            CGPathAddLineToPoint(maskPath, NULL, 0, prePonit.y - gradientY);
            gradientX = prePonit.x;
        }
        else {
            CGPoint curPoint = ((LinePoint *)attribute.values[i]).point;
            CGPathAddLineToPoint(maskPath, NULL, curPoint.x - gradientX, curPoint.y - gradientY);
            prePonit = curPoint;
            gradientW = curPoint.x - gradientX;
        }
        
        // 最后一个点
        if (i == attribute.values.count - 1) {
            CGPathAddLineToPoint(maskPath, NULL, prePonit.x - gradientX, VIEW_H - self.axisLayer.params.yAxisBMargin);
            gradientLayer.frame = CGRectMake(gradientX, gradientY, gradientW, gradientH);
        }
    }
    
    maskLayer.path = maskPath;
    
    [gradientLayer setMask:maskLayer];
    [_gradientBgView.layer addSublayer:gradientLayer]; // 获得了 0.38 的透明度
    
    CGPathRelease(maskPath);
}


#pragma mark - Touch
/**
 *  @brief   界面被点击
 */
- (void)viewTaped:(UIGestureRecognizer *)gesture
{
//    if (_allPoints.count == 0) return;
    
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
//    [_crossLayer removeFromSuperlayer];
//    _crossLayer = nil;
//    [_dotLayer removeFromSuperlayer];
//    _dotLayer = nil;
//    _promptView.hidden = YES;
    
    // 计算出在 _allPoints 数组中对应的索引
    NSInteger index = (NSInteger)(point.x / _xSpace);
//    index = MIN(_allPoints.count - 1, MAX(0, index));
    
    CGPoint verticalPoint;// = [_allPoints[index] CGPointValue];
    
    // 优先查找垂直方向。垂直方向上响应区域为 ± 20
    if (fabs(verticalPoint.y - point.y) <= 20) {
        
//        [self adjustCrossLayer:verticalPoint];
//        [self showPrompt:verticalPoint atIndex:index];
    }
    // 垂直方向没有满足的点，查找水平方向
    else {
        
        CGPoint horizontalPoint = CGPointZero;
        BOOL isAlready = NO; // 是否已经找到
        
        // 水平方向 ±15 的区域内查找。优先左侧查找
        for (NSInteger i = index - 1; i >= 0; i--) {
//            horizontalPoint = [_allPoints[i] CGPointValue];
            
            if (point.x - horizontalPoint.x > 15)
                break;  // 超出了 15pt 的查找范围，结束
            
            if (fabs(horizontalPoint.y - point.y) <= 20) {
//                [self adjustCrossLayer:horizontalPoint];
//                [self showPrompt:horizontalPoint atIndex:i];
                isAlready = YES;
                break;
            }
        }
        
        if (isAlready)  return;
        
        for (NSInteger i = index + 1; i < index; i--) {
//            horizontalPoint = [_allPoints[i] CGPointValue];
            
            if (point.x - horizontalPoint.x > 15)
                break;  // 超出了 15pt 的查找范围，结束
            
            if (fabs(horizontalPoint.y - point.y) <= 20) {
//                [self adjustCrossLayer:horizontalPoint];
//                [self showPrompt:horizontalPoint atIndex:i];
                break;
            }
        }
    }
}

/**
 *  @brief   调整十字叉、圆点的位置
 */
//- (void)adjustCrossLayer:(CGPoint)point
//{
//    UIBezierPath * path = [UIBezierPath bezierPath];
//    // 横线
//    [path moveToPoint:CGPointMake(0, point.y)];  // _axisLayer.params.xAxisLMargin
//    [path addLineToPoint:CGPointMake(_bgScrollView.contentSize.width, point.y)];
//    // 竖线
//    [path moveToPoint:CGPointMake(point.x, _axisLayer.params.yAxisTMargin)];
//    [path addLineToPoint:CGPointMake(point.x, _axisLayer.drawH + _axisLayer.params.yAxisTMargin)];
//
//    _crossLayer = [CAShapeLayer layer];
//    _crossLayer.path = path.CGPath;
//    _crossLayer.lineWidth = 1.f;
//    _crossLayer.strokeColor = UIColorFromRGB(0xFFE9BE).CGColor;
//    _crossLayer.fillColor = [UIColor clearColor].CGColor;
//    [_bgScrollView.layer addSublayer:_crossLayer];
//
//    // 圆点
//    path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x - 2, point.y - 2, 4, 4) cornerRadius:2];
//
//    _dotLayer = [CAShapeLayer layer];
//    _dotLayer.path = path.CGPath;
//    _dotLayer.strokeColor = [UIColor whiteColor].CGColor;
//    _dotLayer.lineWidth = 1;
//    _dotLayer.fillColor = self.dotColor.CGColor;
//    [_bgScrollView.layer addSublayer:_dotLayer];
//}
//
///**
// *  @brief   提示，调整位置
// */
//- (void)showPrompt:(CGPoint)point atIndex:(NSInteger)index
//{
//    CGFloat y = MAX(self.axisLayer.params.yAxisTMargin, point.y - 40 - 16/2);
//
//    self.promptView.center = [self convertPoint:CGPointMake(point.x, y) fromView:_bgScrollView];
//
//    NSString * xValue = nil;
//    if (index >= 0 && index < self.yAxisValue.count) {
//        xValue = [NSString stringWithFormat:@"%.0f 次/分", [self.yAxisValue[index] floatValue]];
//    }
//
//    NSString * yValue = nil;
//    if (index >= 0 && index < self.xAxisValue.count) {
//        yValue = self.xAxisValue[index];
//    }
//    [self.promptView setViewWithLeftValue:xValue rightValue:yValue];
//    self.promptView.hidden = NO;
//}


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

- (LinePromptView *)promptView
{
    if (_promptView == nil) {
        _promptView = (LinePromptView *)[XUtil viewFromXibFile:@"LinePromptView"];
//        _promptView.frame = CGRectMake(0, 0, 67, 16);
//        _promptView.hidden = YES;
//        [self addSubview:_promptView];
    }
    return _promptView;
}

@end
