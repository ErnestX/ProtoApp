//
//  ViewController.h
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-04.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorsEnumType.h"
#import "AFNetworking.h"

@interface ViewController : UIViewController

- (void) putInTeam: (BOOL)isInTeamOne;

/*
 returns false if not assigned a team yet
 */
- (BOOL) startNewRound;

/*
 returns false if not in the offending team
 */
- (BOOL) assignRole: (BOOL)isCaptain;

- (BOOL) setQuestionAndStartTimer: (Colors)question;

- (void) increaseScoreBy: (NSInteger)s;

/*
 returns false if not assigned to any team
 */
- (BOOL) isInTeamOne;

/*
 returns false if not in offending team
 */
- (BOOL) isCaptain;

@end

