//
//  TimerView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-07.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "TimerView.h"

@implementation TimerView
{
    NSInteger currentTime;
    UILabel* timeLabel;
}

- (void)customInit:(NSInteger)time
{
    currentTime = time;
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [timeLabel.font fontWithSize:30];
    [self addSubview:timeLabel];
    [self updateLabel];
}

- (void)tick
{
    if (currentTime >0) {
        currentTime -= 1;
        [self updateLabel];
    } else {
        NSLog(@"timerView:currentTime is already 0");
    }
}

- (NSInteger) getCurrentTime
{
    return currentTime;
}

- (void) updateLabel
{
    timeLabel.text = [NSString stringWithFormat:@"%ld",currentTime];
}

@end
