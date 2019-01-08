//
//  ViewController.m
//  Chart
//
//  Created by CYKJ on 2019/1/3.
//  Copyright © 2019年 D. All rights reserved.


#import "LineViewController.h"
#import "CurveChart.h"
#import "LineChart.h"
#import "XUtil.h"
#import "Macro.h"
#import "Masonry.h"

@interface LineViewController () <LineChartDelegate>
{
    CGFloat _curveChartMaxPointValue;
    CGFloat _curveChartMinPointValue;
    
    __block CGFloat _lineChartMaxPointValue1;
    __block CGFloat _lineChartMinPointValue1;
    __block CGFloat _lineChartMaxPointValue2;
    __block CGFloat _lineChartMinPointValue2;
    
    __block CGFloat _animationLineChartMaxPointValue;
    __block CGFloat _animationLineChartMinPointValue;
}
@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;
@property (nonatomic, weak) IBOutlet UIView * curveChartBg;
@property (weak, nonatomic) IBOutlet UIView * lineChartBg;
@property (weak, nonatomic) IBOutlet UIView * gradientBg;
@property (weak, nonatomic) IBOutlet UIView * animationLineChartBg;

@property (nonatomic, strong) CurveChart * curveChart;
@property (nonatomic, strong) LineChart * lineChart;
@property (nonatomic, strong) LineChart * animationLineChart;

@property (nonatomic, strong) NSArray * timeValues;
@property (nonatomic, strong) NSArray * dataValues;

@property (nonatomic, strong) NSArray * lineTimeValues;
@property (nonatomic, strong) NSArray * lineDataValues;

@property (nonatomic, strong) NSArray * animationLineTimeValues;
@property (nonatomic, strong) NSArray * animationLineDataValues;

@end

@implementation LineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initCurveChart];
    [self initLineChart];
    [self initAnimationLineChart];
}


#pragma mark - CurveChart

- (void)initCurveChart
{
    if (_curveChart == nil) {
        // ①、确定趋势图的位置与大小
        _curveChart = (CurveChart *)[XUtil viewFromXibFile:@"CurveChart"];
        _curveChart.frame = self.curveChartBg.bounds;
        [self.curveChartBg addSubview:_curveChart];
        [self.view layoutIfNeeded];
    }
    
    // ②、设置趋势图用于绘制的属性
    _curveChart.axisLayer.params.needYAxis = NO;
    _curveChart.axisLayer.params.needYScale = NO;
    _curveChart.axisLayer.params.needXAxis = NO;
    _curveChart.axisLayer.params.needXScale = NO;
    _curveChart.isNeedGradient = YES;
    _curveChart.isNeedDot = NO;
    _curveChart.isNeedLowValue = NO;
    _curveChart.isHorizontalScroll = YES;
    _curveChart.maxCountPerScreen = 288;
    _curveChart.axisLayer.xScaleLineAry    = @[@"0:00", @"12:00", @"23:59"];
    _curveChart.axisLayer.referenceLineAry = @[ @(54), @(84), @(115), @(145) ];
    
    // ③、开始绘制
    [self setYAxisMaxMinValue];
    [self.curveChart drawCurveChartWithXValues:self.timeValues yValues:self.dataValues];
}

- (void)setYAxisMaxMinValue
{
    int i = 0;
    
    for (NSNumber * data in self.dataValues) {
        
        if (i == 0) {
            _curveChartMaxPointValue = data.floatValue;
            _curveChartMinPointValue = data.floatValue;
        }
        else if (data.floatValue > _curveChartMaxPointValue) {
            _curveChartMaxPointValue = data.floatValue;
        }
        else if (data.floatValue < _curveChartMinPointValue){
            _curveChartMinPointValue = data.floatValue;
        }
        
        ++i;
    }
    
    self.curveChart.axisLayer.params.maxYAxisValue = _curveChartMaxPointValue;
    self.curveChart.axisLayer.params.minYAxisValue = _curveChartMinPointValue;
}

/**
  *  @brief   时间数组
  */
- (NSArray *)timeValues
{
    if (_timeValues == nil) {
        
        static NSMutableArray * mArr;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            NSDateFormatter * df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"HH:mm"];
            NSDate * zero = [df dateFromString:@"00:00"];
            NSDate * date;
            
            mArr = [NSMutableArray arrayWithCapacity:288];
            
            for (NSInteger i = 0; i < 24 * 60; i += 5) {
                date = [zero dateByAddingTimeInterval:i * 60];
                [mArr addObject:[df stringFromDate:date]];
            }
        });
        
        _timeValues = [NSArray arrayWithArray:mArr];
    }
    return _timeValues;
}

/**
  *  @brief   数值数组
  */
- (NSArray *)dataValues
{
    if (_dataValues == nil) {
        NSString * data = @"66,62,61,61,61,61,61,61,63,62,63,63,63,63,63,66,64,62,62,61,61,63,61,62,62,66,66,66,66,60,61,64,64,63,63,61,63,62,62,60,59,59,58,56,60,55,57,56,61,56,57,55,60,61,63,65,63,61,64,63,62,61,61,61,61,61,61,62,62,63,62,62,60,61,62,62,63,63,62,63,63,63,63,62,60,58,61,69,72,75,67,66,66,66,68,69,69,73,69,69,67,81,77,72,71,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,67,74,74,68,66,71,75,69,70,72,72,69,69,69,66,66,75,75,71,67,68,68,66,73,74,74,75,72,66,68,72,68,68,71,70,65,62,64,64,65,63,63,62,74,75,71,69,65,69,72,72,69,69,67,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0";
        _dataValues = [data componentsSeparatedByString:@","];
    }
    return _dataValues;
}


#pragma mark - LineChart

- (void)initLineChart
{
    if (_lineChart == nil) {
        // ①、确定趋势图的位置与大小
        _lineChart = (LineChart *)[XUtil viewFromXibFile:@"LineChart"];
        _lineChart.frame = self.lineChartBg.bounds;
        [self.lineChartBg addSubview:_lineChart];
        [self.view layoutIfNeeded];
    }

    // ②、设置趋势图用于绘制的属性
    _lineChart.delegate = self;
    _lineChart.axisLayer.params.needYAxis = NO;
    _lineChart.axisLayer.params.needYScale = NO;
    _lineChart.axisLayer.params.needXAxis = NO;
    _lineChart.axisLayer.params.needXScale = NO;
    _lineChart.isNeedLowValue = NO;
    _lineChart.axisLayer.xScaleLineAry    = @[@"12/28", @"12/29", @"12/30", @"12/31", @"01/01", @"01/02", @"01/03"];
    _lineChart.axisLayer.referenceLineAry = @[];

    // ③、开始绘制
    [self setLineChartYAxisMaxMinValue];
    [self.lineChart drawLineChart];
}

- (void)setLineChartYAxisMaxMinValue
{
    NSArray * arr1 = self.lineDataValues[0];
    
    [arr1 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if (idx == 0) {
            self->_lineChartMaxPointValue1 = obj.floatValue;
            self->_lineChartMinPointValue1 = obj.floatValue;
        }
        else if (obj.floatValue > self->_lineChartMaxPointValue1) {
            self->_lineChartMaxPointValue1 = obj.floatValue;
        }
        else if (obj.floatValue < self->_lineChartMinPointValue1){
            self->_lineChartMinPointValue1 = obj.floatValue;
        }
    }];
    
    NSArray * arr2 = self.lineDataValues[1];
    
    [arr2 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0) {
            self->_lineChartMaxPointValue2 = obj.floatValue;
            self->_lineChartMinPointValue2 = obj.floatValue;
        }
        else if (obj.floatValue > self->_lineChartMaxPointValue2) {
            self->_lineChartMaxPointValue2 = obj.floatValue;
        }
        else if (obj.floatValue < self->_lineChartMinPointValue2){
            self->_lineChartMinPointValue2 = obj.floatValue;
        }
    }];
}

/**
  *  @brief   直线趋势图 - x 轴方向数据
  */
- (NSArray *)lineTimeValues
{
    if (_lineTimeValues == nil) {
        _lineTimeValues = @[ @[@"12/28", @"12/29", @"12/30", @"12/31", @"01/01", @"01/02", @"01/03"], @[@"12/28", @"12/29", @"12/30", @"12/31", @"01/01", @"01/02", @"01/03"] ];
    }
    return _lineTimeValues;
}

/**
  *  @brief   直线趋势图 - y 轴方向数据
  */
- (NSArray *)lineDataValues
{
    if (_lineDataValues == nil) {
        _lineDataValues = @[ @[@"9193", @"8596", @"3174", @"3", @"4548", @"9028", @"5173"], @[@"5173", @"9193", @"4548", @"8596", @"9028", @"3", @"3174"] ];
    }
    return _lineDataValues;
}


#pragma mark - Animation LineChart

- (void)initAnimationLineChart
{
    [self drawChartGradientView:UIColorFromRGB(0x00E3AE)
                        toColor:UIColorFromRGB(0x9BE15D)];
    
    if (_animationLineChart == nil) {
        // ①、确定趋势图的位置与大小
        _animationLineChart = (LineChart *)[XUtil viewFromXibFile:@"LineChart"];
        _animationLineChart.frame = self.animationLineChartBg.bounds;
        [self.animationLineChartBg addSubview:_animationLineChart];
        [self.view layoutIfNeeded];
    }
    
    // ②、设置趋势图用于绘制的属性
    _animationLineChart.delegate = self;
    _animationLineChart.axisLayer.params.needYAxis = NO;
    _animationLineChart.axisLayer.params.needYScale = NO;
    _animationLineChart.axisLayer.params.needXAxis = NO;
    _animationLineChart.axisLayer.params.needXScale = NO;
    _animationLineChart.axisLayer.params.isNeedReferenceLine = NO;
    _animationLineChart.axisLayer.params.needYValue = NO;
    _animationLineChart.axisLayer.params.xValueColor = [UIColor whiteColor];
    _animationLineChart.axisLayer.params.yAxisBMargin = 40;
    _animationLineChart.axisLayer.xScaleLineAry = @[@"12/28", @"12/29", @"12/30", @"12/31", @"01/01", @"昨天", @"今天"];
    
    // ③、开始绘制
    [self setAnimationLineChartYAxisMaxMinValue];
    [self.animationLineChart drawLineChart];
}

/**
  *  @brief   绘制渐变图层
  */
- (void)drawChartGradientView:(UIColor *)fromColor toColor:(UIColor *)toColor
{
    CAGradientLayer * gradientLayer =  [CAGradientLayer layer];
    [gradientLayer setFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, CGRectGetHeight(self.gradientBg.bounds))];
    [gradientLayer setColors:@[ (id)[fromColor CGColor], (id)[toColor CGColor]]];
    [gradientLayer setStartPoint:CGPointMake(0, 0.9)];
    [gradientLayer setEndPoint:CGPointMake(1, 0.1)];
    
    [self.gradientBg.layer addSublayer:gradientLayer];
}

- (void)setAnimationLineChartYAxisMaxMinValue
{
    [self.animationLineDataValues enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        
        if (idx == 0) {
            self->_animationLineChartMaxPointValue = obj.floatValue;
            self->_animationLineChartMinPointValue = obj.floatValue;
        }
        else if (obj.floatValue > self->_animationLineChartMaxPointValue) {
            self->_animationLineChartMaxPointValue = obj.floatValue;
        }
        else if (obj.floatValue < self->_animationLineChartMinPointValue){
            self->_animationLineChartMinPointValue = obj.floatValue;
        }
    }];
}

/**
  *  @brief   直线趋势图 - x 轴方向数据
  */
- (NSArray *)animationLineTimeValues
{
    if (_animationLineTimeValues == nil) {
        _animationLineTimeValues = @[ @"12/28", @"12/29", @"12/30", @"12/31", @"01/01", @"01/02", @"01/03" ];
    }
    return _animationLineTimeValues;
}

/**
  *  @brief   直线趋势图 - y 轴方向数据
  */
- (NSArray *)animationLineDataValues
{
    if (_animationLineDataValues == nil) {
        _animationLineDataValues = @[ @"4", @"4548", @"9028", @"9219", @"8386", @"62", @"0" ];
    }
    return _animationLineDataValues;
}


#pragma mark - LineChartDelegate
/**
  *   @brief   趋势图代理方法。确定趋势图的个数，每个趋势图的点数，每个点的属性等。
  */
- (NSInteger)numberOfChartView:(LineChart *)chart
{
    if (chart == self.lineChart) {
        return self.lineDataValues.count;
    }
    return 1;
}

- (NSInteger)chartView:(LineChart *)chart numberOfPointAtIndex:(NSInteger)chartIndex
{
    if (chart == self.lineChart) {
        return [self.lineDataValues[chartIndex] count];
    }
    return self.animationLineDataValues.count;
}

- (LineGraphAttribute *)chartView:(LineChart *)chart graphAttributeAtIndex:(NSInteger)chartIndex
{
    LineGraphAttribute * attribute = [[LineGraphAttribute alloc] init];
    attribute.isNeedGradient = YES;
    
    if (chart == self.lineChart) {
        
        attribute.isNeedDot = NO;
        if (chartIndex == 0) {
            attribute.maxValue = _lineChartMaxPointValue1;
            attribute.minValue = _lineChartMinPointValue1;
            attribute.drawColor = UIColorFromRGB(0x00baff);
            attribute.fromColor = UIColorFromRGB(0xfff2aa);
        }
        else {
            attribute.maxValue = _lineChartMaxPointValue2;
            attribute.minValue = _lineChartMinPointValue2;
            attribute.drawColor = UIColorFromRGB(0x6FBA2C);
            attribute.fromColor = UIColorFromRGB(0xc2f5b2);
        }
    }
    else {
        attribute.isNeedDot = YES;
        attribute.needAnimation = YES;
        attribute.maxValue = _animationLineChartMaxPointValue;
        attribute.minValue = _animationLineChartMinPointValue;
        attribute.drawColor = [UIColor whiteColor];
        attribute.dotColor  = [UIColor whiteColor];
        attribute.fromColor = [UIColor colorWithWhite:1 alpha:0.5];
        attribute.toColor   = [UIColor colorWithWhite:1 alpha:0.1];

    }
    return attribute;
}

- (LinePoint *)chartView:(LineChart *)chart pointIndex:(NSInteger)pointIndex chartIndex:(NSInteger)chartIndex
{
    LinePoint * point = [[LinePoint alloc] init];
    
    if (chart == self.lineChart) {
        point.xValue = self.lineTimeValues[chartIndex][pointIndex];
        point.yValue = [self.lineDataValues[chartIndex][pointIndex] floatValue];
    }
    else {
        point.xValue = self.animationLineTimeValues[pointIndex];
        point.yValue = [self.animationLineDataValues[pointIndex] floatValue];
    }
    
    return point;
}

@end
