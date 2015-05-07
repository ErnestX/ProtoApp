//
//  DotLayer.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-06.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DotLayer.h"
#import "GlobalGetters.h";

@implementation DotLayer
{
    Colors colorEnum;
    CGColorRef color;
    float sideLength;
    float dotRadius;
}

- (void) customInit:(Colors)c
{
    colorEnum = c;
    sideLength = [GlobalGetters getGameViewHeight]/4/1.5;
    dotRadius = 50/1.5 - 5;
    self.frame = CGRectMake(0, 0, sideLength, sideLength);
    self.anchorPoint = CGPointMake(0, 0); // the anchor point is the top left corner
}

- (void)drawInContext:(CGContextRef)ctx
{
    NSLog(@"drawing in context");
    UIGraphicsPushContext(ctx);
    
//    CGContextAddArc(ctx, sideLength/2, sideLength/2, sideLength, 0, 0, 0);
    color = [UIColor colorWithHue: colorEnum * (1.0/12.0) saturation:1 brightness:1 alpha:1].CGColor;
    CGContextSetFillColorWithColor(ctx, color);
    CGContextFillEllipseInRect(ctx, CGRectMake((self.frame.size.width - dotRadius*2.0)/2.0, (self.frame.size.width - dotRadius*2.0)/2.0, dotRadius*2.0, dotRadius*2.0));
    
    UIGraphicsPopContext();
}

- (float)getDotRaidus
{
    return dotRadius;
}

- (void)setDotRadius:(float)r
{
    dotRadius = r;
}

@end
