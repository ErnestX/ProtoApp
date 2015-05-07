//
//  TimerView.h
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-07.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerView : UIView

- (void)customInit;
- (void)tick;
- (NSInteger) getCurrentTime;

@end
