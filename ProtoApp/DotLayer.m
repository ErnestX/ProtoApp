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
    CGColorRef color;
    float sideLength;
    float dotRadius;
}

- (void) customInit:(Colors)c
{
    sideLength = [GlobalGetters getGameViewHeight]/4/1.5;
    dotRadius = 50/1.5 - 5;
    self.frame = CGRectMake(0, 0, sideLength, sideLength);
    self.anchorPoint = CGPointMake(0, 0); // the anchor point is the top left corner
    color = [UIColor colorWithHue: c * (1.0/12.0) saturation:1 brightness:1 alpha:1].CGColor;
    
//    self.backgroundColor = [UIColor redColor].CGColor;
}

- (void)drawInContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    
    CGContextAddArc(ctx, sideLength/2, sideLength/2, sideLength, 0, 0, 0);
    CGContextSetFillColorWithColor(ctx, color);
    CGContextFillEllipseInRect(ctx, CGRectMake((sideLength - dotRadius*2.0)/2.0, (sideLength - dotRadius*2.0)/2.0, dotRadius*2.0, dotRadius*2.0));
    
//    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
//    
//    CGPoint arr[2];
//    arr[0] = CGPointMake(0, 0);
//    arr[1] = CGPointMake(100, 200);
//    
//    CGContextStrokeLineSegments(ctx, arr, 2);
    
    UIGraphicsPopContext();
}

@end
