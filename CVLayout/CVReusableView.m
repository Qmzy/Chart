//
//  CVReusableView.m
//
//  Created by D on 2018/4/17.
//  Copyright © 2018年 D. All rights reserved.


#import "CVReusableView.h"
#import "CVLayoutAttributes.h"


@implementation CVReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    if ([layoutAttributes isKindOfClass:[CVLayoutAttributes class]]) {
        
        CVLayoutAttributes * la = (CVLayoutAttributes *)layoutAttributes;
        self.backgroundColor = la.bgColor;
    }
}

@end
