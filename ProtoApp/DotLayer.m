//
//  DotLayer.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-06.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DotLayer.h"
#import "GlobalGetters.h"
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
    sideLength = 1100;
    self.frame = CGRectMake(0, 0, sideLength, sideLength);
    
    Dot* d = [Dot layer];
    d.frame = self.frame;
    d.uiColor = [GlobalGetters uiColorFromColors:c];
    [self addSublayer:d];
    [d setNeedsDisplay];
    
    self.transform = CATransform3DMakeScale(0.04, 0.04, 0.04);
}

@end
