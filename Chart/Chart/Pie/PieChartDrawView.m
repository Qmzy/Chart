//
//  PieChartDrawView.m
//
//  Created by D on 17/6/27.
//  Copyright © 2017年 D. All rights reserved.


#import "PieChartDrawView.h"


#define SELF_X_HALF   self.frame.size.width / 2
#define SELF_Y_HALF   self.frame.size.height/ 2
#define TEXT_W        70
#define TEXT_H        15
#define LINE_DEGREE   45

typedef NS_ENUM(NSInteger, PieChartTipLineDirection) {

    PieChartTipLineDirectionRightTop,    // 右上
    PieChartTipLineDirectionRightBottom, // 右下
    PieChartTipLineDirectionLeftTop,     // 左上
    PieChartTipLineDirectionLeftBottom,  // 左下
};

@implementation PieChartDrawView
{
    CGFloat _lastTurnPointY;  // 上一个转折点的 y 值。用于避免两个提示语（占比很小）之间相隔太近
    PieChartTipLineDirection _lastDirection;  // 上一次的方向
}
- (void)redraw
{
    if (self.pieModels.count == 1) {
        
        // 如果只有一条数据，不需要间隙
        self.pieConfig.sectorSpace = 0;
    }
    _lastTurnPointY = -1;
    _lastDirection  = -1;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 起点角度
    CGFloat angle_start = 0;
    
    CGPoint centerP = CGPointMake(SELF_X_HALF, SELF_Y_HALF);
    
    for (PieChartModel * model in self.pieModels) {
        
        CGFloat angle = model.percent * 2 * M_PI;
        // 终点角度
        CGFloat angle_end = angle_start + angle;
        
        // 绘制圆环
        [self drawArcByBezierPath:model
                           center:centerP
                       angleStart:angle_start
                         angleEnd:angle_end];
        
        // 数据为自建数据，绘制无数据提示
        if (model.isNilData) {
            
            [self drawNilTipMask:ctx center:centerP];   return;
        }
        
        // 绘制指引线
        CGFloat dotAngle = (angle_end + angle_start) / 2.0;
        CGFloat x = 0;
        CGFloat y = 0;
        
        if (self.pieConfig.isNeedCircleDot) {
            
            x = centerP.x + (self.pieConfig.radius + self.pieConfig.dotMargin) * cos(dotAngle);
            y = centerP.y + (self.pieConfig.radius + self.pieConfig.dotMargin) * sin(dotAngle);
        }
        else {
            x = centerP.x + self.pieConfig.radius * cos(dotAngle);
            y = centerP.y + self.pieConfig.radius * sin(dotAngle);
        }
        
        [self drawLineAndTipText:model
                    cgContextRef:ctx
                               x:x
                               y:y
                           angle:dotAngle];
        
        angle_start = angle_end;
    }
    
    [self drawCircleMask:centerP];
}

/**
  *  @brief   绘制扇形
  */
- (void)drawArcByBezierPath:(PieChartModel *)model center:(CGPoint)center angleStart:(CGFloat)angle_start angleEnd:(CGFloat)angle_end
{
    UIBezierPath * arcPath = [UIBezierPath bezierPath];
    
    [arcPath moveToPoint:center];
    [arcPath addArcWithCenter:center
                       radius:self.pieConfig.radius
                   startAngle:angle_start
                     endAngle:angle_end
                    clockwise:YES];
    [arcPath closePath];
    
    arcPath.lineWidth = self.pieConfig.sectorSpace;
    
    [self.pieConfig.spaceColor setStroke];
    [model.color setFill];
    
    [arcPath fill];
    [arcPath stroke];
}

/**
  *  @brief   绘制圆形遮罩
  */
- (void)drawCircleMask:(CGPoint)center
{
    CGFloat radius = self.pieConfig.radius - self.pieConfig.renderRadius;
    
    UIBezierPath * arcPath = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:radius
                                                        startAngle:0
                                                          endAngle:M_PI * 2
                                                         clockwise:YES];
    [self.backgroundColor set];
    
    [arcPath fill];
    [arcPath stroke];
}

- (void)drawNilTipMask:(CGContextRef)ctx center:(CGPoint)center
{
    [self drawCircleMask:center];
    
    CGFloat w = (self.pieConfig.radius - self.pieConfig.renderRadius) * 2;
    CGRect rect = CGRectMake(center.x - w/2, center.y - TEXT_H/2, w, TEXT_H);
    
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    // 文本属性
    NSDictionary * attri = @{ NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                              NSForegroundColorAttributeName : self.pieConfig.nilTipColor,
                              NSParagraphStyleAttributeName : paragraph };
    
    [self.pieConfig.nilTip drawInRect:rect withAttributes:attri];
}

/**
  *  @brief   绘制提示内容
  *
  *  @param   x   指引线起点的 X 轴数值
  *  @param   y   指引线起点的 Y 轴数值
  */
- (void)drawLineAndTipText:(PieChartModel *)model
              cgContextRef:(CGContextRef)ctx
                         x:(CGFloat)x
                         y:(CGFloat)y
                     angle:(CGFloat)angle
{
    // 指引线的拐点
    CGPoint lineTurnPoint = CGPointZero;
    // 指引线的终点
    CGPoint lineEndPoint = CGPointZero;
    // 文字的起点
    CGPoint textPoint = CGPointZero;
    
    
    if (self.pieConfig.isNeedCircleDot) {
   
        // 小圆点中心
        CGPoint dotCenterPoint = CGPointMake(x, y);
        
        // 绘制小圆点
        UIBezierPath * arcPath = [UIBezierPath bezierPathWithArcCenter:dotCenterPoint
                                                                radius:4
                                                            startAngle:0
                                                              endAngle:M_PI * 2
                                                             clockwise:YES];
        [model.color set];

        [arcPath fill];
        [arcPath stroke];
    }

    // 拐点方向
    PieChartTipLineDirection direction = [self directionOfLineTurn:x andY:y];
    
    lineTurnPoint = [self pointOfLineTurn:direction
                                        x:x
                                        y:y];
    
    lineEndPoint  = [self pointOfLineEnd:direction lineTurnPoint:lineTurnPoint];
    
    // 文字的长度
    // CGSize size = [model.tip sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:11.0] }];

    textPoint = [self pointOfText:direction lineTurnPoint:lineTurnPoint];

    // 绘制指引线
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x,y);
    CGContextAddLineToPoint(ctx, lineTurnPoint.x, lineTurnPoint.y);
    CGContextAddLineToPoint(ctx, lineEndPoint.x, lineEndPoint.y);
    CGContextSetLineWidth(ctx, 1.0);
    //画笔的颜色
    // CGContextSetRGBStrokeColor( ctx , r , g , b , 1);
    // 填充颜色
    if (self.pieConfig.lineColor == nil) {
        
        CGContextSetStrokeColorWithColor(ctx, model.color.CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(ctx, self.pieConfig.lineColor.CGColor);
    }
    CGContextStrokePath(ctx);

    // 绘制文本
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
    
    if (direction == PieChartTipLineDirectionLeftTop
        || direction == PieChartTipLineDirectionLeftBottom) {
        
        paragraph.alignment = NSTextAlignmentLeft;
    }
    else{
        paragraph.alignment = NSTextAlignmentRight;
    }
    
    [model.tip drawInRect:CGRectMake(textPoint.x, textPoint.y, TEXT_W, TEXT_H)
           withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                             NSForegroundColorAttributeName : self.pieConfig.tipLColor,
                             NSParagraphStyleAttributeName : paragraph }];
}

/**
  *  @brief   返回指引线拐角的方向
  *
  *  @param   x   指引线起点 X 轴值
  *  @param   y   指引线起点 Y 轴值
  */
- (PieChartTipLineDirection)directionOfLineTurn:(CGFloat)x andY:(CGFloat)y
{
    if (x > SELF_X_HALF && y > SELF_Y_HALF) {
        return PieChartTipLineDirectionRightBottom;
    }
    else if (x > SELF_X_HALF) {
        return PieChartTipLineDirectionRightTop;
    }
    else if (y > SELF_Y_HALF) {
        return PieChartTipLineDirectionLeftBottom;
    }
    else {
        return PieChartTipLineDirectionLeftTop;
    }
}

/**
  *  @brief   根据指引线拐角方向计算得到拐点坐标
  *
  *  @param   x   指引线起点 X 轴值
  *  @param   y   指引线起点 Y 轴值
  *
  *  @return   拐点坐标
  */
- (CGPoint)pointOfLineTurn:(PieChartTipLineDirection)direction
                         x:(CGFloat)x
                         y:(CGFloat)y
{
    CGPoint point;
    
    NSInteger multi = self.pieConfig.isNeedCircleDot ? 1 : 2;
    CGFloat radian = [self transformDegreeToRadian:LINE_DEGREE];
    
    switch (direction) {
            
        case PieChartTipLineDirectionLeftTop:
        {
            point.x = x - self.pieConfig.dotMargin * multi * cos(radian);
            point.y = y - self.pieConfig.dotMargin * multi * sin(radian);
        }
            break;
            
        case PieChartTipLineDirectionLeftBottom:
        {
            point.x = x - self.pieConfig.dotMargin * multi * cos(radian);
            point.y = y + self.pieConfig.dotMargin * multi * sin(radian);
        }
            break;
            
        case PieChartTipLineDirectionRightTop:
        {
            point.x = x + self.pieConfig.dotMargin * multi * cos(radian);
            point.y = y - self.pieConfig.dotMargin * multi * sin(radian);
        }
            break;
        
        case PieChartTipLineDirectionRightBottom:
        {
            point.x = x + self.pieConfig.dotMargin * multi * cos(radian);
            point.y = y + self.pieConfig.dotMargin * multi * sin(radian);
        }
            break;
            
        default:
            break;
    }
    
    // 调整 y 值，避免两个提示语重叠
    if (_lastTurnPointY > 0 && (_lastDirection == direction)) {
        
        switch (direction) {
                
            // 左下、右下部分，当前转折点的 y 值小于上一个转折点的 y 值加上 15
            case PieChartTipLineDirectionLeftBottom:
            case PieChartTipLineDirectionRightBottom:
            {
                CGFloat y = point.y;
                // 之前的在上方
                if (_lastTurnPointY < point.y && point.y - _lastTurnPointY < 15) {
                    y = _lastTurnPointY + 15;
                    
                    // 超出屏幕
                    if (y > self.frame.size.height) {
                        y = _lastTurnPointY - 15;
                    }
                }
                // 之前的在下方
                else if (_lastTurnPointY > point.y && _lastTurnPointY - point.y < 15) {
                    y = _lastTurnPointY - 15;
                }
                
                point.y = y;
            }
                break;
                // 左上、右上部分，转折点的 y 值小于上一个转折点的 y 值减去 15
            case PieChartTipLineDirectionLeftTop:
            case PieChartTipLineDirectionRightTop:
            {
                CGFloat y = point.y;
                // 之前的在上方
                if (_lastTurnPointY < point.y && point.y - _lastTurnPointY < 15) {
                    y = _lastTurnPointY + 15;
                }
                // 之前的在下方
                else if (_lastTurnPointY > point.y && _lastTurnPointY - point.y < 15) {
                    y = _lastTurnPointY - 15;
                    
                    // 超出屏幕
                    if (y - 15 < 0) {
                        y = _lastTurnPointY + 15;
                    }
                }
                
                point.y = y;
            }
                break;
                
            default:
                break;
        }
    }
    _lastTurnPointY = point.y;
    _lastDirection = direction;
    
    return point;
}

/**
  *  @brief   获取指引线终点的坐标
  */
- (CGPoint)pointOfLineEnd:(PieChartTipLineDirection)direction lineTurnPoint:(CGPoint)point
{
    CGPoint endP;
    
    switch (direction) {
            
        case PieChartTipLineDirectionLeftTop:
        case PieChartTipLineDirectionLeftBottom:
        {
            endP.x = point.x - TEXT_W;
        }
            break;
        
        case PieChartTipLineDirectionRightTop:
        case PieChartTipLineDirectionRightBottom:
        {
            endP.x = point.x + TEXT_W;
        }
            break;

        default:
            break;
    }
    
    endP.y = point.y;
    
    return endP;
}

/**
  *  @brief   获取文本控件起点坐标
  */
- (CGPoint)pointOfText:(PieChartTipLineDirection)direction lineTurnPoint:(CGPoint)point
{
    CGPoint textPoint;
    
    switch (direction) {
            
        case PieChartTipLineDirectionLeftTop:
        case PieChartTipLineDirectionLeftBottom:
        {
            textPoint.x = point.x - TEXT_W;
        }
            break;
        
        case PieChartTipLineDirectionRightTop:
        case PieChartTipLineDirectionRightBottom:
        {
            textPoint.x = point.x;
        }
            break;
            
        default:
            break;
    }
    
    textPoint.y = point.y - TEXT_H;
    
    return textPoint;
}

- (CGFloat)transformDegreeToRadian:(CGFloat)degree
{
    return degree * M_PI / 180;
}

@end
