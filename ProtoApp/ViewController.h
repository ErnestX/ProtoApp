//
//  ViewController.h
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-04.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorsEnumType.h"

@interface ViewController : UIViewController

- (void) putInTeam: (BOOL)isInTeamOne;

/*
 Starts new round. Starts a new game if this is the first round
 Returns false if not assigned a team yet
 */
- (BOOL) startNewRound;

/*
 returns false if not in the offending team
 */
- (BOOL) assignRole: (BOOL)isCaptain;

/*
 returns false if not in the defending team
 */
- (BOOL) setQuestionAndStartTimer: (Colors)question;

/*
 returns false if not in the offending team
 */
- (BOOL) increaseMyScoreBy: (NSInteger)s;

/*
 returns false if not in the defending team
 */
- (BOOL) increaseTheirScoreBy: (NSInteger)s;

/*
 returns false if not assigned to any team
 */
- (BOOL) isInTeamOne;

/*
 returns false if not in offending team
 */
- (BOOL) isCaptain;

- (void) endGame;

@end

