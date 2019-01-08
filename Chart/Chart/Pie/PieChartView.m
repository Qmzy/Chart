//
//  PieChartView.m
//
//  Created by D on 17/6/26.
//  Copyright © 2017年 D. All rights reserved.


#import "PieChartView.h"
#import "PieChartExplainCell.h"
#import "Macro.h"


#define CELL_H     10
#define CELL_SPACE 5
#define LINE_SPACE 2

@interface PieChartView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView * pieChartExplainCV;  // 饼图信息解释视图
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * pieChartExplainCVHeightConstraint;
@property (weak, nonatomic) IBOutlet PieChartDrawView * pieChartDrawView;  // 饼图绘制视图
@property (weak, nonatomic) IBOutlet UILabel * pieChartTitleLabel;   // 饼图标题
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * pieChartDrawViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * pieChartTitleLabelBottomConstraint;

@property (strong, nonatomic) NSArray<PieChartLegend> * nilDatas; // 无数据时，图例的数据源
@property (strong, nonatomic) NSArray<PieChartLegend> * realData; // 实际的数据

@end


static NSString * CELL_XIBF = @"PieChartExplainCell";
static NSString * CELL_RUID = @"PieChartExplainCell_RUID";

@implementation PieChartView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // 创建无数据时的数据源
    NSArray * titleArr = @[@"达标等级一", @"达标等级二", @"达标等级三", @"达标等级四"];
    NSArray * explainImageArr = @[@"1级", @"2级", @"3级", @"4级"];
    
    NSMutableArray<PieChartLegend> * mArr = [NSMutableArray<PieChartLegend> new];
    
    for (NSInteger i = 0; i < titleArr.count; i++) {
        
        PieChartLegend * legend = [PieChartLegend new];
        legend.legendTitle = titleArr[i];
        legend.legendImage = [UIImage imageNamed:explainImageArr[i]];
        
        [mArr addObject:legend];
    }
    
    self.nilDatas = mArr;
    // 注册复用
    [self.pieChartExplainCV registerNib:[UINib nibWithNibName:CELL_XIBF bundle:nil]
             forCellWithReuseIdentifier:CELL_RUID];
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.pieConfig = [PieChartConfig new];
        self.pieChartText = nil;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                  andPieModel:(NSArray<PieChartModel> *)pieModels
            andPieChartConfig:(PieChartConfig *)pieConfig
{
    if (self = [super initWithFrame:frame]) {
        
        self.pieModels = pieModels;
        self.pieConfig = pieConfig;
    }
    return self;
}

- (void)setChartWithPieModel:(NSArray<PieChartModel> *)pieModels
           andPieChartConfig:(PieChartConfig *)pieConfig
{
    self.pieModels = pieModels;
    self.pieConfig = pieConfig;
}

/**
  *  @brief    设置数据源并更新集合视图
  */
- (void)setPieModels:(NSArray<PieChartModel> *)pieModels
{
    _pieModels = pieModels;
    
    self.pieChartDrawView.pieModels = pieModels;
}

- (void)setPieLegend:(NSArray<PieChartLegend> *)pieLegend
{
    _pieLegend = pieLegend;
    
    [self updateCollectionView];
}

/**
  *  @brief   更新集合视图
  */
- (void)updateCollectionView
{
    self.realData = self.pieLegend ? : self.nilDatas;
    
    // 总数量
    NSInteger count = self.realData.count;
    
    // 集合视图宽度
    CGFloat w = 0;
    // 行数
    NSInteger rows = count > 0 ? 1 : 0;

    for (NSInteger i = 0; i < count; i++) {
        
        PieChartLegend * legend = self.realData[i];
        legend.legendHeight = self.pieConfig.itemsHeight;
        
        if (w + legend.legendWidth > SCREEN_WIDTH - 30) {
            
            w = legend.legendWidth;
            
            rows++;
        }
        else {
            w += legend.legendWidth + CELL_SPACE;
        }
    }
    
    self.pieChartExplainCVHeightConstraint.constant = rows*CELL_H + LINE_SPACE*(rows - 1) + 2;
    
    [self.pieChartExplainCV reloadData];
}

/**
  *  @brief   设置参数
  */
- (void)setPieConfig:(PieChartConfig *)pieConfig
{
    _pieConfig = pieConfig;
    _pieConfig.itemsHeight = CELL_H;
    
    self.pieChartDrawView.pieConfig = pieConfig;
    
    // 更新约束
    self.pieChartDrawViewHeightConstraint.constant = pieConfig.radius * 2 + 50;
}

/**
  *  @brief   设置文本内容、修改约束
  */
- (void)setPieChartText:(NSString *)pieChartText
{
    if (pieChartText && pieChartText.length > 0) {
        
        NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentCenter;
        paragraph.lineSpacing = 6;
        
        self.pieChartTitleLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:pieChartText attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName : UIColorFromRGB(0x666666), NSParagraphStyleAttributeName : paragraph }];
        
        self.pieChartTitleLabelBottomConstraint.constant = 30;
    }
    else {
        self.pieChartTitleLabelBottomConstraint.constant = 0;
    }
}

/**
  *  @brief   更新饼图信息
  */
- (void)updatePieChart
{
    // 检查代理
    if (self.dataSource && [self.dataSource pieChartViewDataCount] > 0) {
        
        NSMutableArray<PieChartModel> * mArr = [NSMutableArray<PieChartModel> array];
        
        for (NSInteger i = 0; i < [self.dataSource pieChartViewDataCount]; i++) {
            
            [mArr addObject:[self.dataSource pieChartView:self index:i]];
        }
        
        self.pieModels = mArr;
    }
    else if (self.pieModels == nil || self.pieModels.count == 0) {
        
        if (self.pieConfig.isNilDraw) {
            
            PieChartModel * model = [[PieChartModel alloc] init];
            model.tip = self.pieConfig.nilTip;
            model.color = self.pieConfig.nilColor;
            model.percent = 1;
            model.isNilData = YES;
            
            // 赋值。注意：没有对 self.pieModels 进行赋值，因为 self.pieModels 用于做判断
            self.pieChartDrawView.pieModels = [NSArray<PieChartModel> arrayWithObject:model];
        }
        else {
            return;
        }
    }
    
    // 重新绘制
    [self.pieChartDrawView redraw];
}

/**
  *  @brief   获取饼图高度
  */
- (CGFloat)pieChartViewHeight
{
    CGFloat topHeight = 75 + self.pieChartExplainCVHeightConstraint.constant;
    CGFloat drawHeight = self.pieConfig.radius * 2 + 64;   // 64 = 折线高度 + 文本高度
    CGFloat bottomHeight = 85;
    
    return topHeight + drawHeight + bottomHeight;
}


#pragma mark - UICollectionViewDelegate/DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.realData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PieChartExplainCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_RUID forIndexPath:indexPath];
    
    [cell setCellWithData:self.realData[indexPath.item]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PieChartLegend * legend = self.realData[indexPath.item];
    
    return CGSizeMake(legend.legendWidth, legend.legendHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CELL_SPACE;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return LINE_SPACE;
}

@end

