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
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 200)];
    l.textColor = [UIColor whiteColor];
    l.font = [l.font fontWithSize:100.0];
    [l adjustsFontSizeToFitWidth];
    
    if (isInTeamOne) {
        l.text = @"Team 1";
    } else {
        l.text = @"Team 2";
    }
    
    return l;
}

@end
