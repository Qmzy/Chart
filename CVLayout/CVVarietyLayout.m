//
//  CVVarietyLayout.m
//  CiYunApp
//
//  Created by D on 17/5/11.
//  Copyright © 2017年 D. All rights reserved.


#import "CVVarietyLayout.h"
#import "CVLayoutAttributes.h"
#import "CVReusableView.h"
#import <objc/runtime.h>


#define CV_WIDTH   CGRectGetWidth(self.collectionView.frame)

static NSString * kDecorationReuseIdentifier = @"kDecorationReuseIdentifier";

IB_DESIGNABLE
@implementation CVVarietyLayout

+ (Class)layoutAttributesClass
{
    return [CVLayoutAttributes class];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [self registerClass:[CVReusableView class] forDecorationViewOfKind:kDecorationReuseIdentifier];
}

- (CGSize)collectionViewContentSize
{
    return [super collectionViewContentSize];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray * attributes = [super layoutAttributesForElementsInRect:rect];

    if (attributes.count > 0) {
        
        switch (self.mode) {
            case CVVarietyLayoutHorizontalCenterMode:
            {
                [self horizontalCenter:attributes];
            }
                break;
                
            case CVVarietyLayoutVerticalCenterMode:
            {
                [self verticalCenter:attributes];
            }
                break;
                
            case CVVarietyLayoutVerticalLeftMode:
            {
                [self verticalLeft:attributes];
            }
                break;
             
            case CVVarietyLayoutVerticalRightMode:
            {
                [self verticalRight:attributes];
            }
            default:
                break;
        }
    }
    
    attributes = [self decorationAttributes:attributes];

    return attributes;
}

/**
  *  @brief   处理 section 的背景色
  */
- (NSArray<UICollectionViewLayoutAttributes *> *)decorationAttributes:(NSArray<UICollectionViewLayoutAttributes *> *)attributes
{
    NSMutableArray * allAttributes = [NSMutableArray arrayWithArray:attributes];
    
    // 保存住上一个"某一行的第一个 item"，section 中的最后一个 decorationAttributes 的 fram 不需要加 minimumLineSpacing
    __block UICollectionViewLayoutAttributes * lastAttribute = nil;
    
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 查找某一行的第一个 item
        if (obj.representedElementKind == UICollectionElementCategoryCell
            && obj.frame.origin.x == self.sectionInset.left) {
            
            // 获取 decoration view 的布局对象
            CVLayoutAttributes * decorationAttributes = [CVLayoutAttributes layoutAttributesForDecorationViewOfKind:kDecorationReuseIdentifier withIndexPath:obj.indexPath];
            
            CGFloat y = obj.frame.origin.y;
            CGFloat h = obj.frame.size.height;
            // lastAttribute 存在 & 与当前的是同一个 section
            if (lastAttribute && lastAttribute.indexPath.section == obj.indexPath.section) {
                y -= self.minimumLineSpacing;
                h += self.minimumLineSpacing;
            }
            
            // 设置 decoration view 的 frame，让它占据整行
            decorationAttributes.frame = CGRectMake(0, y, self.collectionViewContentSize.width, h);
            
            // 设置 decoration view 的背景色
            if (self.collectionView.delegate != nil && [self.collectionView.delegate respondsToSelector:@selector(collectionView:backgroundColorForSectionDecorationViewAtIndexPath:)]) {
                
                id<CVVarietyDelegateFlowLayout> delegate = (id<CVVarietyDelegateFlowLayout>)self.collectionView.delegate;
                decorationAttributes.bgColor = [delegate collectionView:self.collectionView backgroundColorForSectionDecorationViewAtIndexPath:obj.indexPath];
            }
            
            // 设置zIndex，表示在 item 的后面
            decorationAttributes.zIndex = obj.zIndex - 1;
            
            [allAttributes addObject:decorationAttributes];
            
            // 记录
            lastAttribute = obj;
        }
    }];
    
    return allAttributes;
}

/**
  *  @brief   横向居中排版。系统默认居左
  */
- (void)horizontalCenter:(NSArray<UICollectionViewLayoutAttributes *> *)attributes
{
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    __block CGFloat c = 0;    // 显示的 cell + header + footer 的数量
    __block CGFloat w = 0;    // 显示的 cell + header + footer 的宽度之和
    __block CGFloat hfC = 0;  // 显示的 header + footer 的数量
    
    [attributes enumerateObjectsUsingBlock:^( UICollectionViewLayoutAttributes * _Nonnull obj,
                                              NSUInteger idx,
                                              BOOL * _Nonnull stop) {
        // 判断 obj 是否显示
        if (CGRectIntersectsRect(self.collectionView.bounds, obj.frame)) {
            
            c++;
            w += obj.frame.size.width;
            
            // 判断 obj 是否是 cell，不是即为 header 或 footer
            if (obj.representedElementCategory != UICollectionElementCategoryCell) {
                hfC++;
            }
        }
        else {
            *stop = YES;
        }
    }];
    
    /*  处理以下情形：所有视图都已显示。包括 cell、header、footer
           */
    if (c == attributes.count) {  
        
        // 左右间距
        CGFloat lrEdge = (CV_WIDTH - w - (c-hfC-1) * self.maxMargin) /2;
        lrEdge = MAX(0.0, lrEdge);
        // 第一个 cell 的 起始 x
        w = self.headerReferenceSize.width + lrEdge;
        
        [attributes enumerateObjectsUsingBlock:^( UICollectionViewLayoutAttributes * _Nonnull obj,
                                                  NSUInteger idx,
                                                  BOOL * _Nonnull stop) {
            
            if (idx < c && [self collectionViewDidScrolled:obj]) {
                CGRect frame = obj.frame;
                frame.origin.x = w;
                w += frame.size.width + self.maxMargin;
                obj.frame = frame;
            }
        }];
    }
}

/**
  *  @brief   判断是否已经滑动了。没有 header、footer 时，所有 cell 已显示，但已经有偏移量时执行 reloadData
  */
- (BOOL)collectionViewDidScrolled:(UICollectionViewLayoutAttributes *)attribute
{
    return attribute.representedElementCategory == UICollectionElementCategoryCell && attribute.frame.origin.x + attribute.frame.size.width < CV_WIDTH;
}

/**
  *  @brief   纵向居中排版。系统默认
  */
- (void)verticalCenter:(NSArray<UICollectionViewLayoutAttributes *> *)attributes
{
    self.scrollDirection = UICollectionViewScrollDirectionVertical;

    NSInteger count = attributes.count;
    
    __block CGFloat hC = 0;    // 某一行 item 数
    __block CGFloat index = 0; // 索引
    __block CGFloat w = 0;
    
    // 只有一个 cell
    if (count == 1) {
        
        UICollectionViewLayoutAttributes * curAttribute = [attributes firstObject];
        CGRect frame = curAttribute.frame;
        frame.origin.x = (CV_WIDTH - frame.size.width)/2;
        curAttribute.frame = frame;
        return;
    }
    
    // 存在多个 item
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0) {
            w += obj.frame.size.width;
            hC++;
        }
        else {
            
            UICollectionViewLayoutAttributes * prevLayoutAttributes = attributes[idx - 1];
            
            BOOL isLineEnd = NO; // 是否换行了，或者是否到了最后一个 item
            BOOL isLast = NO;    // 是否是最后一个 item
            
            // 换行了，但不是最后一个 item
            if(obj.frame.origin.y != prevLayoutAttributes.frame.origin.y && idx < count-1){
                
                isLineEnd = YES;
            }
            // 换行了，且是最后一个 item
            else if (obj.frame.origin.y != prevLayoutAttributes.frame.origin.y){
                
                isLineEnd = YES;
                isLast = YES;
                CGRect frame = obj.frame;
                frame.origin.x = (CV_WIDTH - frame.size.width)/2;
                obj.frame = frame;
            }
            // 未换行，且不是最后一个 item
            else if (idx < count-1) {
                
                w += obj.frame.size.width;
                hC++;
            }
            // 未换行，但是最后一个 item
            else {
                
                w += obj.frame.size.width;
                hC++;
                isLineEnd = YES;
                isLast = YES;
            }
            
            if (isLineEnd) {
                
                // 左右间距
                CGFloat lrEdge = (CV_WIDTH - w - (hC-1)*self.maxMargin - 2*self.leftEdge) / 2;
                w = lrEdge + self.leftEdge;
                
                for (NSInteger i = index; i < index + hC; i++) {
                    
                    UICollectionViewLayoutAttributes * attribute = attributes[i];
                    CGRect frame = attribute.frame;
                    frame.origin.x = w;
                    w += frame.size.width + self.maxMargin;
                    attribute.frame = frame;
                }
                
                if (isLast == NO) {
                    
                    w  = obj.frame.size.width;
                    index += hC;
                    hC = 1;
                }
            }
        }
    }];
}

/**
  *  @brief   纵向居左排版
  */
- (void)verticalLeft:(NSArray<UICollectionViewLayoutAttributes *> *)attributes
{
    self.scrollDirection = UICollectionViewScrollDirectionVertical;

    [attributes enumerateObjectsUsingBlock:^( UICollectionViewLayoutAttributes * _Nonnull obj,
                                              NSUInteger idx,
                                              BOOL * _Nonnull stop) {
        
        CGRect frame = obj.frame;
        
        if(idx == 0){
            frame.origin.x = 0;
        }
        else{
            // 上一个的布局对象
            UICollectionViewLayoutAttributes * prevLayoutAttributes = attributes[idx - 1];
            
            if(obj.frame.origin.y != prevLayoutAttributes.frame.origin.y){
                frame.origin.x = 0;
            }
            else {
                frame.origin.x = prevLayoutAttributes.frame.origin.x + prevLayoutAttributes.frame.size.width + self.maxMargin;
            }
        }
        obj.frame = frame;
    }];
}

/**
  *  @brief   纵向居右排版
  */
- (void)verticalRight:(NSArray<UICollectionViewLayoutAttributes *> *)attributes
{
    self.scrollDirection = UICollectionViewScrollDirectionVertical;

    __block CGFloat originX = 0;
    __block CGFloat originY = CGFLOAT_MAX;
    
    // 倒序查找
    [[[attributes reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^( UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGRect frame = obj.frame;

        // 不同行
        if (frame.origin.y != originY) {
            
            frame.origin.x = CV_WIDTH - frame.size.width;
        }
        // 同一行
        else {
            frame.origin.x = originX - self.maxMargin - frame.size.width;
        }
        originX = frame.origin.x;
        originY = frame.origin.y;
    
        obj.frame = frame;
    }];
}

@end
