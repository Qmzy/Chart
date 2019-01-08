//
//  BarChart.m
//  Chart
//
//  Created by CYKJ on 2019/1/6.
//  Copyright © 2019年 D. All rights reserved.


#import "BarChart.h"

@interface BarChart ()

@property (nonatomic, strong) AxisLayer * axisLayer;
@property (nonatomic, strong) UIScrollView * bgScrollView;
@property (nonatomic, strong) NSMutableArray<BarGraphAttribute> * dataSource;
@property (nonatomic, strong) UIView * gradientBgView;
//@property (nonatomic, strong) LinePromptView * promptView; // 提示内容视图
@property (nonatomic, strong) UITapGestureRecognizer * tap;

@end


@implementation BarChart
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
        _bgScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        // 当 scrollView 作为 view 的subView 时，scrollView.layer 也被加入到 view.layer 的 sublayers 中
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
        
        _dataSource = [[NSMutableArray<BarGraphAttribute> alloc] initWithCapacity:_numberOfChartView];
        
        CGFloat yMaxValue = 0.0;
        CGFloat yMinValue = 0.0;
        
        // 循环各个趋势图
        for (int i = 0; i < _numberOfChartView; i++) {
            
            BarGraphAttribute * attribute = [_delegate chartView:self graphAttributeAtIndex:i];
            [_dataSource addObject:attribute];
            
            if ([_delegate respondsToSelector:@selector(chartView:numberOfPointAtIndex:)]) {
                attribute.pointCount = [_delegate chartView:self numberOfPointAtIndex:i];
            }
            
            attribute.values = [NSMutableArray arrayWithCapacity:attribute.pointCount];
            
            // 循环每个点
            for (int j = 0; j < attribute.pointCount; j++) {
                if ([_delegate respondsToSelector:@selector(chartView:pointIndex:chartIndex:)]) {
                    BarPoint * point = [_delegate chartView:self pointIndex:j chartIndex:i];
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
  *  @brief   绘制圆柱图
  */
- (void)drawBarChart
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
        
        _xSpace = (self.axisLayer.drawW - _axisLayer.params.xValueOffset) / (_maxCountPerScreen - 1);
        CGFloat xAxisWidth = _xSpace * (double)(_maxPointCount - 1);
        _bgScrollView.contentSize = CGSizeMake(xAxisWidth, self.axisLayer.drawH);
    }
    else {
        _bgScrollView.contentSize = CGSizeMake(self.axisLayer.drawW, self.axisLayer.drawH);
        
        if (_maxPointCount > 1) {
            _xSpace = (self.axisLayer.drawW - _axisLayer.params.xValueOffset) / (_maxPointCount - 1);
        }
    }
    
    CGFloat max = [[self.axisLayer.yScaleLineAry  lastObject] floatValue];
    CGFloat min = [[self.axisLayer.yScaleLineAry firstObject] floatValue];
    // 像素比例。绘图区为顶部留白 15%
    CGFloat pixelRate = 1;
    if (max - min > 0) {
        pixelRate = self.axisLayer.drawH * 0.85 / (max - min);
    }
    
    CGFloat barOffset = 0.0;  // 多个圆柱趋势图之间的偏移量
    
    for (int i = 0; i < self.dataSource.count; i++) {
        
        BarGraphAttribute * attribute = self.dataSource[i];
        
        if (attribute.values.count == 0)  return;
        
        // 循环所有的数据点
        for (int j = 0; j < attribute.values.count; j++) {
            
            BarPoint * point = attribute.values[j];
            
            CGFloat x = _xSpace * j + _axisLayer.params.xValueOffset + barOffset;
            CGFloat y = _axisLayer.drawH + _axisLayer.params.yAxisTMargin - (point.yValue - min) * pixelRate;
            
            CGPoint p = CGPointMake(x, y);
            point.point = p;
        }
        
        if (attribute.isNeedGradient) {
            [self drawGradientBarChart:attribute];
        }
        else {
            [self drawChartLayer:attribute];
        }
        
        barOffset += attribute.barWidth;
    }
}

/**
  *  @brief   绘制趋势图
  */
- (void)drawChartLayer:(BarGraphAttribute *)attribute
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    CGPoint curPoint;
    
    for (int i = 0; i < attribute.values.count; i++) {
        
        curPoint = ((BarPoint *)attribute.values[i]).point;
        
        // 未超出绘制区域
        if (curPoint.y < self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin) {
            [path moveToPoint:CGPointMake(curPoint.x, self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin)];
            [path addLineToPoint:curPoint];
        }
    }
    
    CAShapeLayer * barLayer = [CAShapeLayer layer];
    CGRect rect = self.bounds;
    rect.size.height = self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin;
    barLayer.frame = rect;
    barLayer.path = path.CGPath;
    barLayer.strokeColor = attribute.barColor.CGColor;
    barLayer.fillColor = [UIColor clearColor].CGColor;
    barLayer.lineWidth = attribute.barWidth;
    barLayer.lineCap = (attribute.needCircleBar ? kCALineCapRound : kCALineCapButt);
    barLayer.masksToBounds = YES;

    if (attribute.needAnimation) { // 显示过渡动画
        CAAnimationGroup * group = [self animationGroup:barLayer
                                                keyPath:@"position.y"
                                              fromValue:@(barLayer.frame.origin.y + barLayer.frame.size.height)
                                                toValue:@((barLayer.frame.origin.y + barLayer.frame.size.height)/2)];
        [barLayer addAnimation:group forKey:nil];
    }
    
    [_bgScrollView.layer addSublayer:barLayer];
}

/**
  *  @brief   渐变色圆柱
  */
- (void)drawGradientBarChart:(BarGraphAttribute *)attribute
{
    CGPoint curPoint;
    CGFloat w = attribute.barWidth;
    CGFloat maxY = self.axisLayer.drawH + self.axisLayer.params.yAxisTMargin;
    NSMutableArray * gradientArr = [NSMutableArray arrayWithCapacity:attribute.values.count];
    
    for (int i = 0; i < attribute.values.count; i++) {
        
        curPoint = ((BarPoint *)attribute.values[i]).point;
        
        // 未超出绘制区域
        if (curPoint.y < maxY) {
            
            CAGradientLayer * gradientLayer = [CAGradientLayer new];
            gradientLayer.cornerRadius = attribute.barWidth / 2;
            gradientLayer.startPoint = CGPointMake(0.5, 0);
            gradientLayer.endPoint = CGPointMake(0.5, 1);
            gradientLayer.colors = @[ (id)[attribute.fromColor CGColor],
                                      (id)[attribute.toColor CGColor]  ];
            gradientLayer.anchorPoint = CGPointMake(0.5, 1);
            gradientLayer.frame = CGRectMake(curPoint.x - w / 2, curPoint.y, w, maxY - curPoint.y);
            [gradientArr addObject:gradientLayer];
        }
    }
    
    if (attribute.needAnimation) {  // 显示过渡动画
        for (CAGradientLayer * gLayer in gradientArr) {
            CAAnimationGroup * group = [self animationGroup:gLayer
                                                    keyPath:@"bounds.origin.y"
                                                  fromValue:@(gLayer.frame.origin.y + gLayer.frame.size.height)
                                                    toValue:@(gLayer.frame.origin.y)];
            [gLayer addAnimation:group forKey:nil];
        }
    }
    
    for (CAGradientLayer * gLayer in gradientArr) {
        [_bgScrollView.layer addSublayer:gLayer];
    }
}


- (CAAnimationGroup *)animationGroup:(CALayer *)layer keyPath:(NSString *)keyPath fromValue:(NSNumber *)fromValue toValue:(NSNumber *)toValue
{
    CABasicAnimation * am1 = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    am1.fromValue = [NSNumber numberWithFloat:0.0];
    am1.toValue = [NSNumber numberWithFloat:1];
    am1.removedOnCompletion = NO;
    am1.fillMode = kCAFillModeForwards;
    
    CABasicAnimation * am2 = [CABasicAnimation animationWithKeyPath:keyPath];
    am2.fromValue = fromValue;
    am2.toValue = toValue;
    am2.removedOnCompletion = NO;
    am2.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.duration = 0.8f;
    group.animations = [NSArray arrayWithObjects: am2, am1, nil];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    return group;
}


#pragma mark - SET/GET
/**
  *  @brief   设置是否展示"提示视图"的手势
  */
//- (void)setIsPromptOnTaped:(BOOL)isPromptOnTaped
//{
//    // 添加点击手势
//    if (isPromptOnTaped) {
//
//        // 当前没有手势
//        if (_tap == nil) {
//            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
//            [self addGestureRecognizer:_tap];
//        }
//    }
//    // 移除点击手势 & 当前手势存在
//    else if (_tap) {
//        [self removeGestureRecognizer:_tap];
//        _tap = nil;
//    }
//}

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

@end
