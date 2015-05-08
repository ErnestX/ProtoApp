//
//  StatusView.h
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerView.h"
#import "TeamView.h"

@interface StatusView : UIView
@property TeamView* teamView;
@property UIView* turnView;
@property UIView* roleView;
@property UIView* scoreView;
@property TimerView* timerView;

- (id) customInit;

@end
