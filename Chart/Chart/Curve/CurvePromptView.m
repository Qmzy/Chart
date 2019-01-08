//
//  CurvePromptView.m
//  CiYunApp
//
//  Created by CYKJ on 2018/12/28.
//  Copyright © 2018年 北京慈云科技有限公司. All rights reserved.


#import "CurvePromptView.h"

@interface CurvePromptView ()

@property (weak, nonatomic) IBOutlet UILabel * leftLabel;
@property (weak, nonatomic) IBOutlet UILabel * rightLabel;

@end

@implementation CurvePromptView

- (void)setViewWithLeftValue:(NSString *)leftValue rightValue:(NSString *)rightValue
{
    self.leftLabel.text = leftValue;
    self.rightLabel.text = rightValue;
}

@end
