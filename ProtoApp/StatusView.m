//
//  StatusView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

- (id) initWithFrame:(CGRect)frame
{
    StatusView* sv = [super initWithFrame:frame];
    sv.backgroundColor = [UIColor blackColor];
    return sv;
}

- (id) customInit
{
    float STATUS_VIEW_HEIGHT = 100;
    return [self initWithFrame:CGRectMake(0, 0, [self getScreenWidth], STATUS_VIEW_HEIGHT)];
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    
    CGPoint arr[2];
    arr[0] = CGPointMake(0, self.frame.size.height - 1);
    arr[1] = CGPointMake(self.frame.size.width, self.frame.size.height - 1);
    
    CGContextStrokeLineSegments(ctx, arr, 2);
}

- (float) getScreenHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

- (float) getScreenWidth
{
    return [[UIScreen mainScreen] bounds].size.width;
}

@end
