//
//  PieViewController.m
//  Chart
//
//  Created by D on 2019/1/6.
//  Copyright © 2019年 D. All rights reserved.


#import "PieViewController.h"
#import "PieChartView.h"
#import "CircleChart.h"
#import "Macro.h"
#import "Masonry.h"
#import "XUtil.h"


@interface PieViewController ()

@property (nonatomic, weak) IBOutlet UIView * pieChartView;
@property (nonatomic, weak) IBOutlet UIView * circleChartView;
@property (nonatomic, strong) PieChartView * pieChart;   // 饼图
@property (nonatomic, strong) CircleChart * circleChart; // 圆环

@end


@implementation PieViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPieChart];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initCircleChart];
}


#pragma mark - Pie Chart

- (void)initPieChart
{
    // 初始化饼图
    PieChartConfig * config = [PieChartConfig new];
    config.lineColor = UIColorFromRGB(0xe6e6e6);
    
    self.pieChart = (PieChartView *) [XUtil viewFromXibFile:@"PieChartView"];
    self.pieChart.pieConfig = config;
    [self.pieChartView addSubview:self.pieChart];
    
    SELF_WEEK;
    [self.pieChart mas_makeConstraints:^(MASConstraintMaker * make) {
        
        SELF_STRONG;
        make.edges.equalTo(strongSelf.pieChartView);
    }];
    
    [self updatePieChartView];
}

/**
  *  @brief   更新饼图内容
  */
- (void)updatePieChartView
{
    [self.pieChart setPieChartText:@"个人运动达标统计"];
    
    PieChartLegend * lend1 = [[PieChartLegend alloc] init];
    lend1.legendTitle = @"不达标";
    lend1.legendImage = [self getExplainImage:1];  // 图例图片
    
    PieChartLegend * lend2 = [[PieChartLegend alloc] init];
    lend2.legendTitle = @"1级达标";
    lend2.legendImage = [self getExplainImage:2];  // 图例图片
    
    PieChartLegend * lend3 = [[PieChartLegend alloc] init];
    lend3.legendTitle = @"2级达标";
    lend3.legendImage = [self getExplainImage:3];  // 图例图片
    
    PieChartLegend * lend4 = [[PieChartLegend alloc] init];
    lend4.legendTitle = @"3级达标";
    lend4.legendImage = [self getExplainImage:4];  // 图例图片
    
    [self.pieChart setPieLegend:(NSArray<PieChartLegend> *)@[lend1, lend2, lend3, lend4]];
    
    PieChartModel * model1 = [[PieChartModel alloc] init];
    model1.isNilData = NO;
    model1.tip   = @"3天(3.5%)";
    model1.color = [self getColor:1];
    model1.percent = 0.03529;
    
    PieChartModel * model2 = [[PieChartModel alloc] init];
    model2.isNilData = NO;
    model2.tip   = @"8天(9.4%)";
    model2.color = [self getColor:2];
    model2.percent = 0.09411;
    
    PieChartModel * model3 = [[PieChartModel alloc] init];
    model3.isNilData = NO;
    model3.tip   = @"8天(9.4%)";
    model3.color = [self getColor:3];
    model3.percent = 0.09411;
    
    PieChartModel * model4 = [[PieChartModel alloc] init];
    model4.isNilData = NO;
    model4.tip   = @"66天(77.6%)";
    model4.color = [self getColor:4];
    model4.percent = 0.77647;
    
    [self.pieChart setPieModels:(NSArray<PieChartModel> *)@[model1, model2, model3, model4]];
    [self.pieChart updatePieChart];
}

- (UIColor *)getColor:(NSInteger)grade
{
    switch (grade) {
            
        case 1:
            return UIColorFromRGB(0xffbd21);
        case 2:
            return UIColorFromRGB(0x45c5c6);
        case 3:
            return UIColorFromRGB(0x8cd049);
        case 4:
            return UIColorFromRGB(0xff48a3);
        case 5:
            return UIColorFromRGB(0x40bff5);
        case 6:
            return UIColorFromRGB(0xff7676);
        case 7:
            return UIColorFromRGB(0xfa8700);
        case 8:
            return UIColorFromRGB(0x13d199);
        case 9:
            return UIColorFromRGB(0xf56ee4);
        case 10:
            return UIColorFromRGB(0xa869fd);
        default:
            break;
    }
    return nil;
}

- (UIImage *)getExplainImage:(NSInteger)grade
{
    switch (grade) {
            
        case 1:
            return [UIImage imageNamed:@"1级"];
        case 2:
            return [UIImage imageNamed:@"2级"];
        case 3:
            return [UIImage imageNamed:@"3级"];
        case 4:
            return [UIImage imageNamed:@"4级"];
        case 5:
            return [UIImage imageNamed:@"5级"];
        case 6:
            return [UIImage imageNamed:@"6级"];
        case 7:
            return [UIImage imageNamed:@"7级"];
        case 8:
            return [UIImage imageNamed:@"8级"];
        case 9:
            return [UIImage imageNamed:@"9级"];
        case 10:
            return [UIImage imageNamed:@"10级"];
        default:
            break;
    }
    return nil;
}


#pragma mark - Circle Chart
/**
  *  @brief   圆环
  */
- (void)initCircleChart
{
    if (_circleChart == nil) {
        _circleChart = (CircleChart *)[XUtil viewFromXibFile:@"CircleChart"];
        [self.circleChartView addSubview:self.circleChart];
    }
    
    SELF_WEEK;
    [self.circleChart mas_makeConstraints:^(MASConstraintMaker * make) {
        SELF_STRONG;
        make.edges.equalTo(strongSelf.circleChartView);
    }];
    [self.circleChartView layoutIfNeeded];
    
    self.circleChart.percentArr = @[ @(0.3), @(0.2), @(0.5) ];
    [self.circleChart startDraw];
}

@end
