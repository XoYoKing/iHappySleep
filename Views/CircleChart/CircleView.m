//
//  CircleView.m
//  CircleChart
//
//  Created by 诺之家 on 15/12/8.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "CircleView.h"
#import "myHeader.h"

#define PI 3.14159265358979323846
#define radius SCREEN_WIDTH/6

@implementation CircleView

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

//计算弧度
static inline float radians(double degrees)
{
    return degrees * PI / 180;
}
//画实心圆弧
static inline void drawArc(CGContextRef ctx, CGPoint point, float angle_start, float angle_end, UIColor* color)
{
    CGContextMoveToPoint(ctx, point.x, point.y);
    CGContextSetFillColor(ctx, CGColorGetComponents( [color CGColor]));
    CGContextAddArc(ctx, point.x, point.y, radius,  angle_start, angle_end, 0);
    CGContextFillPath(ctx);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    
    float angle_start = radians(0.0);
    float angle_end = radians(_radiansVeryGood);
    drawArc(ctx, self.center, angle_start, angle_end, [UIColor colorWithRed:0xc6/255.0 green:0xff/255.0 blue:0x8c/255.0 alpha:1]);
    
    angle_start = angle_end;
    angle_end = radians(_radiansGeneral);
    drawArc(ctx, self.center, angle_start, angle_end, [UIColor colorWithRed:0xff/255.0 green:0xf7/255.0 blue:0x8c/255.0 alpha:1]);
    
    angle_start = angle_end;
    angle_end = radians(_radiansBad);
    drawArc(ctx, self.center, angle_start, angle_end, [UIColor colorWithRed:0xff/255.0 green:0xd3/255.0 blue:0x87/255.0 alpha:1]);
    
    angle_start = angle_end;
    angle_end = radians(_radiansVeryBad);
    drawArc(ctx, self.center, angle_start, angle_end, [UIColor colorWithRed:0x8c/255.0 green:0xeb/255.0 blue:0xff/255.0 alpha:1]);
}

@end
