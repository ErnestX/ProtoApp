//
//  GameView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "TeamView.h"

@implementation TeamView

- (id) customInitWithTeam:(BOOL)isInTeamOne
{
    TeamView* tv = [self initWithFrame:CGRectMake(10, 10, 200, 50)];
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    l.textColor = [UIColor whiteColor];
    
    if (isInTeamOne) {
        l.text = @"Team 1";
    } else {
        l.text = @"Team 2";
    }
    
    [tv addSubview:l];
    return tv;
}

@end
