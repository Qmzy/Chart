//
//  BarViewController.m
//  Chart
//
//  Created by D on 2019/1/6.
//  Copyright © 2019年 D. All rights reserved.


#import "BarViewController.h"
#import "BarChart.h"
#import "XUtil.h"


@interface BarViewController () <BarChartDelegate>
{
    CGFloat _barChartMaxPointValue1;
    CGFloat _barChartMinPointValue1;
    
    CGFloat _barChartMaxPointValue2;
    CGFloat _barChartMinPointValue2;
}
@property (nonatomic, weak) IBOutlet UIView * barChartView;
@property (weak, nonatomic) IBOutlet UIView * animationBarChartView;
@property (weak, nonatomic) IBOutlet UIView * gradientBarChartView;
@property (nonatomic, strong) BarChart * barChart;
@property (nonatomic, strong) BarChart * animationBarChart;
@property (nonatomic, strong) BarChart * gradientBarChart;

@property (nonatomic, strong) NSArray * timeValues;
@property (nonatomic, strong) NSArray * dataValues;

@end


@implementation BarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initBarChart];
    [self initAnimationBarChart];
    [self initGradientBarChart];
}

- (void)initBarChart
{
    if (_barChart == nil) {
        // ①、确定趋势图的位置与大小
        _barChart = (BarChart *)[XUtil viewFromXibFile:@"BarChart"];
        _barChart.frame = self.barChartView.bounds;
        [self.barChartView addSubview:_barChart];
        [self.view layoutIfNeeded];
    }
    
    // ②、设置趋势图用于绘制的属性
    _barChart.delegate = self;
    _barChart.axisLayer.params.needYAxis  = NO;
    _barChart.axisLayer.params.needYScale = NO;
    _barChart.axisLayer.params.needXAxis  = NO;
    _barChart.axisLayer.params.needXScale = NO;
    _barChart.axisLayer.params.needYValue = NO;
    _barChart.axisLayer.params.yAxisBMargin = 25;
    _barChart.axisLayer.params.xValueOffset = 16;
    _barChart.axisLayer.xScaleLineAry    = self.timeValues;
    _barChart.axisLayer.referenceLineAry = @[];
    
    // ③、开始绘制
    [self setBarChartYAxisMaxMinValue];
    [self.barChart drawBarChart];
}

- (void)initAnimationBarChart
{
    if (_animationBarChart == nil) {
        _animationBarChart = (BarChart *)[XUtil viewFromXibFile:@"BarChart"];
        _animationBarChart.frame = self.animationBarChartView.bounds;
        [self.animationBarChartView addSubview:_animationBarChart];
        [self.view layoutIfNeeded];
    }
    
    _animationBarChart.delegate = self;
    _animationBarChart.axisLayer.params.needYAxis  = NO;
    _animationBarChart.axisLayer.params.needYScale = NO;
    _animationBarChart.axisLayer.params.needXAxis  = NO;
    _animationBarChart.axisLayer.params.needXScale = NO;
    _animationBarChart.axisLayer.params.needYValue = NO;
    _animationBarChart.axisLayer.params.yAxisBMargin = 25;
    _animationBarChart.axisLayer.params.xValueOffset = 16;
    _animationBarChart.axisLayer.xScaleLineAry    = self.timeValues;
    _animationBarChart.axisLayer.referenceLineAry = @[];
    
    [self setBarChartYAxisMaxMinValue];
    [self.animationBarChart drawBarChart];
}

- (void)initGradientBarChart
{
    if (_gradientBarChart == nil) {
        _gradientBarChart = (BarChart *)[XUtil viewFromXibFile:@"BarChart"];
        _gradientBarChart.frame = self.gradientBarChartView.bounds;
        [self.gradientBarChartView addSubview:_gradientBarChart];
        [self.view layoutIfNeeded];
    }
    
    _gradientBarChart.delegate = self;
    _gradientBarChart.axisLayer.params.needYAxis  = NO;
    _gradientBarChart.axisLayer.params.needYScale = NO;
    _gradientBarChart.axisLayer.params.needXAxis  = NO;
    _gradientBarChart.axisLayer.params.needXScale = NO;
    _gradientBarChart.axisLayer.params.needYValue = NO;
    _gradientBarChart.axisLayer.params.yAxisBMargin = 25;
    _gradientBarChart.axisLayer.params.xValueOffset = 16;
    _gradientBarChart.axisLayer.xScaleLineAry    = self.timeValues;
    _gradientBarChart.axisLayer.referenceLineAry = @[];
    
    [self setBarChartYAxisMaxMinValue];
    [self.gradientBarChart drawBarChart];
}

- (void)setBarChartYAxisMaxMinValue
{
    [self.dataValues.firstObject enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
            
        if (idx == 0) {
            self->_barChartMaxPointValue1 = obj.floatValue;
            self->_barChartMinPointValue1 = obj.floatValue;
        }
        else if (obj.floatValue > self->_barChartMaxPointValue1) {
            self->_barChartMaxPointValue1 = obj.floatValue;
        }
        else if (obj.floatValue < self->_barChartMinPointValue1){
            self->_barChartMinPointValue1 = obj.floatValue;
        }
    }];
    
    [self.dataValues.lastObject enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        
        if (idx == 0) {
            self->_barChartMaxPointValue2 = obj.floatValue;
            self->_barChartMinPointValue2 = obj.floatValue;
        }
        else if (obj.floatValue > self->_barChartMaxPointValue2) {
            self->_barChartMaxPointValue2 = obj.floatValue;
        }
        else if (obj.floatValue < self->_barChartMinPointValue2){
            self->_barChartMinPointValue2 = obj.floatValue;
        }
    }];
}

/**
  *  @brief   圆柱趋势图 - x 轴方向数据
  */
- (NSArray *)timeValues
{
    if (_timeValues == nil) {
        _timeValues = @[@"12/28", @"12/29", @"12/30", @"12/31", @"01/01", @"01/02", @"01/03"];
    }
    return _timeValues;
}

/**
 *  @brief   圆柱趋势图 - y 轴方向数据
 */
- (NSArray *)dataValues
{
    if (_dataValues == nil) {
        _dataValues = @[ @[@"4548", @"9028", @"9219", @"8386", @"62", @"10763", @"8744"], @[@"4453", @"2456", @"8845", @"7483", @"8824", @"849", @"6885"] ];
    }
    return _dataValues;
}


#pragma mark - BarChartDelegate

- (NSInteger)numberOfChartView:(BarChart *)chart
{
    if (_barChart == chart) {
        return self.dataValues.count;
    }
    return 1;
}

- (NSInteger)chartView:(BarChart *)chart numberOfPointAtIndex:(NSInteger)chartIndex
{
    if (_barChart == chart) {
        if (chartIndex == 0) {
            return [self.dataValues.firstObject count];
        }
        else {
            return [self.dataValues.lastObject count];
        }
    }
    return [self.dataValues.firstObject count];
}

- (BarGraphAttribute *)chartView:(BarChart *)chart graphAttributeAtIndex:(NSInteger)chartIndex
{
    BarGraphAttribute * attribute = [[BarGraphAttribute alloc] init];
    attribute.maxValue = _barChartMaxPointValue1;
    attribute.minValue = 0; //_barChartMinPointValue;
    attribute.barColor = UIColorFromRGB(0x75AC47);
    
    if (_barChart == chart) {
        
        attribute.needCircleBar = NO;
        
        if (chartIndex == 0) {
            attribute.barColor = UIColorFromRGB(0x00baff);
        }
        else {
            attribute.barColor = UIColorFromRGB(0xCC0000);
            attribute.maxValue = _barChartMaxPointValue2;
        }
    }
    else if (_animationBarChart == chart) {
        attribute.needAnimation = YES;
    }
    else if (_gradientBarChart == chart) {
        attribute.needAnimation = YES;
        attribute.isNeedGradient = YES;
        attribute.fromColor = UIColorFromRGB(0x00E3AE);
        attribute.toColor   = UIColorFromRGB(0x9BE15D);
    }
    
    return attribute;
}

- (BarPoint *)chartView:(BarChart *)chart pointIndex:(NSInteger)pointIndex chartIndex:(NSInteger)chartIndex
{
    BarPoint * point = [[BarPoint alloc] init];
    
    point.xValue = self.timeValues[pointIndex];
    if (_barChart == chart) {
        if (chartIndex == 0) {
            point.yValue = [self.dataValues.firstObject[pointIndex] floatValue];
        }
        else {
            point.yValue = [self.dataValues.lastObject[pointIndex] floatValue];
        }
    }
    else {
        point.yValue = [self.dataValues.firstObject[pointIndex] floatValue];
    }
    
    return point;
}

@end
