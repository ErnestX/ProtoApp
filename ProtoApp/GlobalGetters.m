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

+ (UIColor*)uiColorFromColors:(Colors)c
{
    switch (c) {
        case 0:
            return [UIColor colorWithHue:0.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 1:
            return [UIColor colorWithHue:23.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 2:
            return [UIColor colorWithHue:34.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 3:
            return [UIColor colorWithHue:47.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 4:
            return [UIColor colorWithHue:60.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 5:
            return [UIColor colorWithHue:76.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 6:
            return [UIColor colorWithHue:93.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 7:
            return [UIColor colorWithHue:200.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 8:
            return [UIColor colorWithHue:219.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 9:
            return [UIColor colorWithHue:234.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 10:
            return [UIColor colorWithHue:272.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        case 11:
            return [UIColor colorWithHue:317.0/360.0 saturation:1 brightness:1 alpha:1];
            break;
        default:
            NSLog(@"global getter: not of type Colors (> 11 or < 0)");
            return nil;
    }
}

@end
