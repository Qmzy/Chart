//
//  CVLayoutAttributes.m
//
//  Created by D on 2018/4/17.
//  Copyright © 2018年 D. All rights reserved.


#import "CVLayoutAttributes.h"


@implementation CVLayoutAttributes

+ (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath
{
    CVLayoutAttributes * layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    
    layoutAttributes.bgColor = [UIColor clearColor];

    return layoutAttributes;
}

@end
