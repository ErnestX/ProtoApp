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
#import "Dot.h"

@implementation DotLayer
{
    Colors colorEnum;
    CGColorRef color;
    float sideLength;
    //float dotRadius;
}

- (void) customInit:(Colors)c
{
    colorEnum = c;
    sideLength = 1100;//[GlobalGetters getGameViewHeight]/4/1.5;
    //dotRadius = 600; //50/1.5 - 5;
    self.frame = CGRectMake(0, 0, sideLength, sideLength);
    //[self setContentsScale:[UIScreen mainScreen].scale];
    //self.backgroundColor = [UIColor redColor].CGColor;
    
    Dot* d = [Dot layer];
    d.frame = self.frame;
    d.uiColor = [GlobalGetters uiColorFromColors:c];
    [self addSublayer:d];
    [d setNeedsDisplay];
    
    self.transform = CATransform3DMakeScale(0.04, 0.04, 0.04);
}

//- (void)drawInContext:(CGContextRef)ctx
//{
//    UIGraphicsPushContext(ctx);
//    
//    //color = [UIColor colorWithHue: colorEnum * (1.0/12.0) saturation:1 brightness:1 alpha:1].CGColor;
//    color = [GlobalGetters uiColorFromColors:colorEnum].CGColor;
//    CGContextSetFillColorWithColor(ctx, color);
////    CGContextFillEllipseInRect(ctx, CGRectMake((self.frame.size.width - dotRadius*2.0)/2.0, (self.frame.size.width - dotRadius*2.0)/2.0, dotRadius*2.0, dotRadius*2.0));
//    CGContextFillEllipseInRect(ctx, self.frame);
//    
//    UIGraphicsPopContext();
//}

//- (float)getDotRaidus
//{
//    return dotRadius;
//}

//- (void)setDotRadius:(float)r
//{
//    dotRadius = r;
//}

@end
