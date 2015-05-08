//
//  Dot.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-07.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "Dot.h"

@implementation Dot

@synthesize uiColor;

- (void)drawInContext:(CGContextRef)ctx
{
    [self setContentsScale:[UIScreen mainScreen].scale];
    
    UIGraphicsPushContext(ctx);
    
    CGContextSetFillColorWithColor(ctx, uiColor.CGColor);
    CGContextFillEllipseInRect(ctx, self.frame);
    
    UIGraphicsPopContext();
}

@end
