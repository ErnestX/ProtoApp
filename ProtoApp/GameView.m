//
//  GameView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "GameView.h"

@implementation GameView

- (id) initWithFrame:(CGRect)frame
{
    GameView* gv = [super initWithFrame:frame];
    gv.backgroundColor = [UIColor blackColor];
    return gv;
}

- (id) customInit
{
    float STATUS_VIEW_HEIGHT = 100;
    return [self initWithFrame:CGRectMake(0, STATUS_VIEW_HEIGHT, [self getScreenWidth], [self getScreenHeight] - STATUS_VIEW_HEIGHT)];
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
