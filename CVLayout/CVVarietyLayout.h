//  集合视图 UICollectionView 的自定义布局
//
//  CVVarietyLayout.h
//
//  Created by D on 17/5/11.
//  Copyright © 2017年 D. All rights reserved.


#import <UIKit/UIKit.h>

/**
  *  @brief   排版方式
  */
typedef NS_ENUM(NSInteger, CVVarietyLayoutMode) {

    // 横向居中：CollectionView 为单行布局，如果所有 cell 能够完全显示，那么 cells 居中。系统默认居左
    CVVarietyLayoutHorizontalCenterMode = 0,
    
    // 纵向居中：CollectionView 为多行布局，如果 cell 不能够填充满一行，那么这一行的 cells 居中。系统默认 cell 均匀布局
    CVVarietyLayoutVerticalCenterMode,
    
    // 纵向居左：CollectionView 为多行布局，如果 cell 不能够填充满一行，那么这一行的 cells 居左，cell 之间的间距固定
    CVVarietyLayoutVerticalLeftMode,
    
    // 纵向居右：CollectionView 为多行布局，如果 cell 不能够填充满一行，那么这一行的 cells 居右，cell 之间的间距固定
    CVVarietyLayoutVerticalRightMode,
};



@protocol CVVarietyDelegateFlowLayout <UICollectionViewDelegateFlowLayout>
@optional
/**
  *  @brief   返回 section 的 decoration（装饰）视图的背景色
  */
- (UIColor *)collectionView:(UICollectionView *)collectionView backgroundColorForSectionDecorationViewAtIndexPath:(NSIndexPath *)indexpath;

@end




@interface CVVarietyLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) IBInspectable CGFloat leftEdge;    // cell 与父视图左侧间隔。纵向时使用
@property (nonatomic, assign) IBInspectable CGFloat maxMargin;   // cell 之间的间距。与minSpacing 一致
@property (nonatomic, assign) IBInspectable NSInteger mode;      // 与 CVVarietyLayoutMode 对应

@end
