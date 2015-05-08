//
//  StatusView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "StatusView.h"
#import "GlobalGetters.h"

@implementation StatusView
@synthesize teamView;
@synthesize turnView;
@synthesize roleView;
@synthesize scoreView;

- (id) initWithFrame:(CGRect)frame
{
    StatusView* sv = [super initWithFrame:frame];
    sv.backgroundColor = [UIColor blackColor];
    return sv;
}

- (id) customInit
{
    return [self initWithFrame:CGRectMake(0, 0, [GlobalGetters getScreenWidth], [GlobalGetters getStatusViewHeight])];
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGPoint arr[2];
    arr[0] = CGPointMake(0, self.frame.size.height - 1);
    arr[1] = CGPointMake(self.frame.size.width, self.frame.size.height - 1);
    
    CGContextStrokeLineSegments(ctx, arr, 2);
}

@end
