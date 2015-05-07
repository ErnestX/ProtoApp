//
//  Utilities.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "GlobalGetters.h"
#import <UIKit/UIKit.h>

@implementation GlobalGetters

+ (float)getStatusViewHeight
{
    return 100;
}

+ (float)getScreenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

+ (float)getScreenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (float)getGameViewHeight
{
    return [GlobalGetters getScreenHeight] - [GlobalGetters getStatusViewHeight];
}

+ (CGColorRef)cgcolorFromColors:(Colors)c
{
    return [UIColor colorWithHue:c * (1.0/12.0) saturation:1 brightness:1 alpha:1].CGColor;
}

@end
