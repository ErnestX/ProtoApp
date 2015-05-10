//
//  ViewController.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-04.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "ViewController.h"
#import "StatusView.h"
#import "GameView.h"
#import "TeamView.h"
#import "GlobalGetters.h"
#import "CaptainColorPickerView.h"
#import "QuestionAndAnswerView.h"
#import "TimerView.h"

#define HOST_NAME @"http://128.189.237.129:8080/ProtoApp/"

@interface ViewController ()

@end

@implementation ViewController
{
    StatusView* statusView;
    GameView* gameView;
    BOOL IS_IN_TEAM_ONE;
    BOOL isCaptain;
    BOOL alreadyAssignedTeam;
    NSInteger turnNumber;
    NSInteger totalNumberOfRounds;
    
    UIButton* b1;
    UIButton* b2;
    
    NSTimer* tickTimer;
    NSTimer* timer;
    
    Colors questionPickedByCaptain;
    Colors answerProposed;
    
    NSInteger maxScorePossible; // used as the time the player have
    NSInteger myScore;
    NSInteger theirScore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customInit];
    
    statusView = [[StatusView alloc]customInit];
    gameView = [[GameView alloc]customInit];
    
    [self.view addSubview:gameView]; // make sure gameView is on the top
    [self.view addSubview:statusView];
    
    [self setUpReadyComfirmationLayout];
}

- (void) customInit
{

    alreadyAssignedTeam = false;
    turnNumber = 0;
    maxScorePossible = 30;
    myScore = 0;
    theirScore = 0;
    totalNumberOfRounds = 1;
}

#pragma mark - Actions
- (void) putInTeam:(BOOL)isInTeamOne
{
    IS_IN_TEAM_ONE = isInTeamOne;
    alreadyAssignedTeam = true; // this should be the only line that can modify assignedTeam
    [self transitFromComfirmationToTeamAssignmentLayout:isInTeamOne];
}

- (BOOL) startNewRound
{
    if (alreadyAssignedTeam) {
        if (turnNumber < totalNumberOfRounds) {
            turnNumber += 1;
            [self transitToNewTurnLayout];
        } else {
            [self endGame];
        }
        return true;
    } else {
        return false;
    }
}

- (BOOL) assignRole:(BOOL)isCapt
{
    if ([self isInOffendingTeam]) {
        isCaptain = isCapt;
        [self transitFromNewTurnToCaptainAssignLayout];
        return true;
    } else {
        return false;
    }
}

- (void) sendColorPicked:(Colors) color
{
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSLog(@"color chosen: %d", color);

    NSString *path = [NSString stringWithFormat:@"%@%@", HOST_NAME, @"ChooseColorServlet"];
    NSDictionary *params = @{@"color_chosen" : [NSNumber numberWithInt:color],
                             @"is_from_captain" : [NSNumber numberWithBool:YES],
                             @"curr_turn" : [NSNumber numberWithInt:turnNumber]};
    __weak typeof(self) weakSelf = self;

    [mgr POST:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"captain submitted color successful");
          [weakSelf waitForScore];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error code: %ld", (long)operation.response.statusCode);
      }];
    
    [self transitToSeeScoreLayoutWithQuestion:100 CorrectAnswer:100 MyAnswer:100];
}

- (BOOL) setQuestionAndStartTimer: (Colors)question
{
    if (![self isInOffendingTeam]) {
        [self transitFromWaitForQuestionToAnswerQuestionLayout:question];
        return true;
    } else {
        return false;
    }
}

- (void) answerSentForQuestion:(Colors)color
{
    NSLog(@"answer chosen: %d", color);
    answerProposed = color;
    [self stopTimer];
}

- (void) stopTimer
{
    // stop all timers
    [tickTimer invalidate];
    [timer invalidate];
    
    NSLog(@"question:%u | answer:%u",questionPickedByCaptain, answerProposed);
    
    NSInteger rawScore = [statusView.timerView getCurrentTime]; // rawScore: the time left
    NSInteger score;
    
    // if correct, uses rawScore. Else, uses the worst score
    if (abs(questionPickedByCaptain - answerProposed) == 6) {
        // correct!
        NSLog(@"correct");
        score = maxScorePossible - rawScore;
    } else {
        // wrong
        NSLog(@"wrong");
        score = maxScorePossible - 0;
    }
    
    [self transitToSeeScoreLayoutWithQuestion:questionPickedByCaptain CorrectAnswer:abs(6 - questionPickedByCaptain) MyAnswer:answerProposed];
    
    NSString *path = [NSString stringWithFormat:@"%@%@", HOST_NAME, @"ScoreServlet"];
    NSDictionary *params = @{@"is_questioning" : [NSNumber numberWithBool:NO],
                             @"is_waiting" : [NSNumber numberWithBool:NO],
                             @"my_score" : [NSNumber numberWithInteger:score]};

    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    __weak typeof(self) weakSelf = self;

    [mgr POST:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSNumber *temp = (NSNumber *)[responseObject objectForKey:@"is_score_ready"];
          BOOL isReady = [temp boolValue];
          if (isReady) {
              double avgScore = [(NSNumber *)[responseObject objectForKey:@"avg_score"] doubleValue];
              [weakSelf increaseMyScoreBy:0 TheirScoreBy:avgScore];
              
              NSLog(@"score = %ld", (long)score);
              return;
          } else {
              [weakSelf waitForScore];
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error code: %ld", (long)operation.response.statusCode);
      }];
    
}

- (void) waitForScore {
    
    NSString *path = [NSString stringWithFormat:@"%@%@", HOST_NAME, @"ScoreServlet"];
    NSDictionary *params = @{@"is_questioning" : [NSNumber numberWithBool:IS_IN_TEAM_ONE],
                             @"is_waiting" : [NSNumber numberWithBool:YES],
                             @"my_score" : [NSNumber numberWithInt:-1]};
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    __weak typeof(self) weakSelf = self;
    
    [mgr POST:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSNumber *temp = (NSNumber *)[responseObject objectForKey:@"is_score_ready"];
          BOOL isReady = [temp boolValue];
          if (isReady){
              double avgScore = [(NSNumber *)[responseObject objectForKey:@"avg_score"] doubleValue];
              if (IS_IN_TEAM_ONE)
                  [weakSelf increaseMyScoreBy:avgScore TheirScoreBy:0];
              else [weakSelf increaseMyScoreBy:0 TheirScoreBy:avgScore];
              return;
          } else {
              [weakSelf waitForScore];
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error code: %ld", (long)operation.response.statusCode);
          
      }];

}

- (void) increaseMyScoreBy:(NSInteger)ms TheirScoreBy:(NSInteger)ts
{
    NSLog(@"loglogloglog");
    
    // increase scores
    myScore += ms;
    theirScore += ts;
    
    [self performSelector:@selector(showScores)
               withObject:NULL
               afterDelay:1.0];
//    [self showScores];
}

- (void) endGame
{
    [self transitFromSeeScoreToEndGameLayout];
}

#pragma mark - Layouts And Controls

#pragma mark Comfirmation

- (void) setUpReadyComfirmationLayout
{
    UISwitch* comfirmationSwitch = [[UISwitch alloc]initWithFrame:CGRectMake([self getScreenWidth]/2 - 10, [self getScreenHeight]/2 - [GlobalGetters getStatusViewHeight], 20, 20)];
    [comfirmationSwitch addTarget:self action:@selector(comfirmationSwitchOn:) forControlEvents:UIControlEventValueChanged];
    
    UILabel* switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 100, 20)];
    switchLabel.text = @"READY";
    switchLabel.textColor = [UIColor whiteColor];
    [comfirmationSwitch addSubview:switchLabel];
    [gameView addSubview:comfirmationSwitch];

    b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b1 setTitle: @"team1" forState:UIControlStateNormal];
    b1.frame = CGRectMake([self getScreenWidth] - 150, [self getGameViewHeight] - 40, 70, 50);
    [b1 addTarget:self action:@selector(putInTeamOne) forControlEvents:UIControlEventTouchUpInside];
     b2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b2 setTitle: @"team2" forState:UIControlStateNormal];
    b2.frame = CGRectMake([self getScreenWidth] - 80, [self getGameViewHeight] - 40, 70, 50);
    [b2 addTarget:self action:@selector(putInTeamTwo) forControlEvents:UIControlEventTouchUpInside];
    [gameView addSubview:b1];
    [gameView addSubview:b2];
}

- (IBAction)comfirmationSwitchOn:(id) sender
{
    if (((UISwitch*)sender).on) {
        ((UISwitch*)sender).enabled = FALSE;
        NSLog(@"ready");
        // TODO: call readyToStartGame
        [self connectMyself];
    }
}

#pragma mark TeamAssign

- (void) transitFromComfirmationToTeamAssignmentLayout: (BOOL)isInTeamOne
{
    GameView* newGv = [[GameView alloc]customInit];
    
    //buttons for testing
    b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b1 setTitle: @"StartsNewRound" forState:UIControlStateNormal];
    b1.frame = CGRectMake([self getScreenWidth] - 150, [self getGameViewHeight] - 40, 150, 50);
    [b1 addTarget:self action:@selector(startNewRound) forControlEvents:UIControlEventTouchUpInside];
    [newGv addSubview:b1];
    
    __weak typeof(self) weakSelf = self;
    TeamView* tv = [[TeamView alloc]customInitWithTeam:isInTeamOne];
    
    tv.transform = CGAffineTransformMake(1, 0, 0, 1, [self getScreenWidth]/2 - 260, [self getGameViewHeight]/2 - 150);
    [statusView addSubview:tv];
    statusView.teamView = tv;
    
    [weakSelf setNewGameViewPushAnimation:newGv additionalView:tv completionBlock:^(void) {
        [gameView removeFromSuperview];
        gameView = newGv;
        [self transformViewAnimated:tv endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, -150, -50) completionBlock:^(void){}];
    }];
}

#pragma mark NewTurn

- (void) transitToNewTurnLayout
{
    [b1 removeFromSuperview];
    b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b1 setTitle: @"Captain" forState:UIControlStateNormal];
    b1.frame = CGRectMake([self getScreenWidth] - 170, [self getGameViewHeight] - 40, 150, 50);
    [b1 addTarget:self action:@selector(assignAsCaptain) forControlEvents:UIControlEventTouchUpInside];
    [b2 removeFromSuperview];
    b2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b2 setTitle: @"Minion" forState:UIControlStateNormal];
    b2.frame = CGRectMake([self getScreenWidth] - 60, [self getGameViewHeight] - 40, 70, 50);
    [b2 addTarget:self action:@selector(assignAsMinion) forControlEvents:UIControlEventTouchUpInside];
    [gameView addSubview:b1];
    [gameView addSubview:b2];
    
    
    
    [statusView.turnView removeFromSuperview];
    [statusView.roleView removeFromSuperview];
    questionPickedByCaptain = 100;
    answerProposed = 100;
    
     __weak typeof(self) weakSelf = self;
    UILabel* turnV = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 200)];
    turnV.transform = CGAffineTransformMake(1, 0, 0, 1, [self getScreenWidth]/2 - 160, [self getGameViewHeight]/2 - 150);
    turnV.font = [turnV.font fontWithSize:100.0];
    turnV.text = [NSString stringWithFormat:@"Turn %ld",(long)turnNumber];
    turnV.textColor = [UIColor whiteColor];
    [statusView addSubview:turnV];
    statusView.turnView = turnV;
    
    [self setNewGameViewPushAnimation:NULL additionalView:turnV completionBlock:^(void){
        [weakSelf transformViewAnimated:turnV endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, -20, -50) completionBlock:^(void){
            // after the animation
            if (![weakSelf isInOffendingTeam]) {
                // not our turn, go wait for question
                [weakSelf transitFromNewTurnToWaitForQuestion];
            } else {
                if (turnNumber != 1) [weakSelf assignCapViaServer];
            }
        }];
    }];
}

- (void) assignCapViaServer {
    if (turnNumber != 1) {
        NSString *path = [NSString stringWithFormat:@"%@%@", HOST_NAME, @"ConnectServlet"];
        AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
        NSString *uid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        NSDictionary *params = @{@"uid" : uid,
                                 @"is_assign_cap" : [NSNumber numberWithBool:YES]};
        __weak typeof(self) weakSelf = self;
        
        [mgr POST:path
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSNumber *temp = (NSNumber *)[responseObject objectForKey:@"is_ready"];
              BOOL isReady = [temp boolValue];
              if (isReady){
                  NSNumber *result = (NSNumber *)[responseObject objectForKey:@"is_cap"];
                  BOOL isCap = [result boolValue];
                  [weakSelf assignRole:isCap];
                  return;
                  
              } else {
                  [weakSelf assignCapViaServer];
              }
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error code: %ld", (long)operation.response.statusCode);
          }];
    }

}

/*
 return true if success, false if not in offending team
 */
- (BOOL) transitFromNewTurnToCaptainAssignLayout
{
    __weak typeof(self) weakSelf = self;
    if ([self isInOffendingTeam]) {
        UILabel* roleV = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 200)];
        roleV.transform = CGAffineTransformMake(1, 0, 0, 1, [self getScreenWidth]/2 - 60, [self getGameViewHeight]/2 - 150);
        roleV.font = [roleV.font fontWithSize:100.0];
        roleV.textColor = [UIColor whiteColor];
        
        if (isCaptain) {
            roleV.text = [NSString stringWithFormat:@"Captain"];
            [statusView addSubview:roleV];
            statusView.roleView = roleV;
            
            [self setNewGameViewPushAnimation:NULL additionalView:roleV completionBlock:^(void){
                [weakSelf transformViewAnimated:roleV endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, 110, -50) completionBlock:^(void) {
                    [weakSelf transitFromCaptainAssignToCaptainPickColorLayout]; // go straight ahead
                }];
            }];
        } else {
            roleV.text = [NSString stringWithFormat:@"Minion"];
            [statusView addSubview:roleV];
            statusView.roleView = roleV;
            
            [self setNewGameViewPushAnimation:NULL additionalView:roleV completionBlock:^(void){
                [weakSelf transformViewAnimated:roleV endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, 110, -50) completionBlock:^(void) {
                    [weakSelf transitFromCaptainAssignToWaitForCaptainLayout]; // go ahead
                }];
            }];
        }
        return true;
    } else {
        return false;
    }
}

/*
 return ture if success, false if not the captain
 */
- (BOOL) transitFromCaptainAssignToCaptainPickColorLayout
{
    // no need for transition??? (the color ring just shows up)
    
    if (isCaptain) {
        CaptainColorPickerView* ccpv = [[CaptainColorPickerView alloc]customInit:self];
        [gameView addSubview:ccpv];
        [ccpv generateColorRing];
        return true;
    } else {
        return false;
    }
}

/*return true if success, false if is the captain
 */
- (BOOL) transitFromCaptainAssignToWaitForCaptainLayout
{
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(430, 240, 300, 100)];
    l.text = @"waiting for the captain";
    l.textColor = [UIColor whiteColor];
    [gameView addSubview:l];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center  = CGPointMake([GlobalGetters getScreenWidth]/2, [GlobalGetters getGameViewHeight]/2);
    [gameView addSubview:spinner];
    [spinner startAnimating];
    
    NSLog(@"wait for the captain");
    [self waitForScore];
    return true;
}

/*
 return ture if success, false if not in defending team
 */
- (BOOL) transitFromNewTurnToWaitForQuestion
{
        // buttons for testing
        [b1 removeFromSuperview];
        [b2 removeFromSuperview];
        
        b1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [b1 setTitle: @"red" forState:UIControlStateNormal];
        b1.frame = CGRectMake([self getScreenWidth] - 170, [self getGameViewHeight] - 40, 150, 50);
        [b1 addTarget:self action:@selector(whatIsTheComplimentOfRed) forControlEvents:UIControlEventTouchUpInside];
        
        b2 = [UIButton buttonWithType:UIButtonTypeSystem];
        [b2 setTitle: @"blue" forState:UIControlStateNormal];
        b2.frame = CGRectMake([self getScreenWidth] - 60, [self getGameViewHeight] - 40, 70, 50);
        [b2 addTarget:self action:@selector(whatIsTheComplimentOfBlue) forControlEvents:UIControlEventTouchUpInside];
        
        [gameView addSubview:b1];
        [gameView addSubview:b2];

    NSLog(@"waiting for the question");
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@%@", HOST_NAME, @"ChooseColorServlet"];
    NSDictionary *params = @{@"is_from_captain" : [NSNumber numberWithBool:NO],
                             @"curr_turn" : [NSNumber numberWithInt:turnNumber]};
    
    __weak typeof(self) weakSelf = self;
    [mgr POST:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          NSNumber *temp = (NSNumber *)[responseObject objectForKey:@"is_color_ready"];
          BOOL isReady = [temp boolValue];
          if (isReady){
              NSNumber *colorID = (NSNumber *)[responseObject objectForKey:@"color_id"];
              Colors question = (Colors)[colorID integerValue];
              NSLog(@"question is color: %d", question);
              
              [weakSelf transitFromWaitForQuestionToAnswerQuestionLayout:[colorID intValue]];
              return;
              
          } else {
              [weakSelf transitFromNewTurnToWaitForQuestion];
          }
          
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error code: %ld", (long)operation.response.statusCode);
      }];
    
    return true;
}

- (void) transitFromWaitForQuestionToAnswerQuestionLayout:(Colors)q
{
    questionPickedByCaptain = q;
    answerProposed = 100; //make sure it is wrong if the player made no choice
    
    QuestionAndAnswerView* qaav = [[QuestionAndAnswerView alloc]customInit:q:self];
    [gameView addSubview: qaav];
    [qaav createAnswerSheet];
    
    TimerView* timerV = [[TimerView alloc]initWithFrame:CGRectMake([GlobalGetters getScreenWidth] - 50, 30, 50, 50)];
    [timerV customInit:maxScorePossible];
    [statusView addSubview:timerV];
    statusView.timerView = timerV;
    
    // schedule timers
    tickTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:timerV selector:@selector(tick) userInfo:nil repeats:true];
    timer = [NSTimer scheduledTimerWithTimeInterval:maxScorePossible target:self selector:@selector(stopTimer) userInfo:nil repeats:false];
}

- (void) transitToSeeScoreLayoutWithQuestion:(Colors)q CorrectAnswer:(Colors)ca MyAnswer:(Colors)ma
{
    NSLog(@"see sccore");
    
    [statusView.timerView  removeFromSuperview];
    [statusView.scoreView removeFromSuperview];
    
    GameView* newGv = [[GameView alloc]customInit];
    
    [b1 removeFromSuperview];
    
    [b2 removeFromSuperview];
    b2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b2 setTitle: @"show" forState:UIControlStateNormal];
    b2.frame = CGRectMake([self getScreenWidth] - 60, [self getGameViewHeight] - 40, 70, 50);
    [b2 addTarget:self action:@selector(increaseMyScoreBy:TheirScoreBy:) forControlEvents:UIControlEventTouchUpInside];
    
    [newGv addSubview:b2];
    
    if (IS_IN_TEAM_ONE != turnNumber % 2) {
        UILabel* question = [[UILabel alloc]initWithFrame:CGRectMake(300, 200, 300, 100)];
        question.text = @"Question";
        question.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
        question.textColor = [GlobalGetters uiColorFromColors:q];
        [newGv addSubview:question];
        
        UILabel* answer = [[UILabel alloc]initWithFrame:CGRectMake(440, 200, 300, 100)];
        answer.text = @"AnswerKey";
        answer.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
        answer.textColor = [GlobalGetters uiColorFromColors:abs(q - 6)];
        [newGv addSubview:answer];
        
        UILabel* myAnswer = [[UILabel alloc]initWithFrame:CGRectMake(600, 200, 300, 100)];
        myAnswer.text = @"MyAnswer";
        myAnswer.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
        myAnswer.textColor = [GlobalGetters uiColorFromColors:ma];
        [newGv addSubview:myAnswer];
    }
    
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(430, 240, 300, 100)];
    l.text = @"waiting for the scores";
    l.textColor = [UIColor whiteColor];
    [newGv addSubview:l];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center  = CGPointMake([GlobalGetters getScreenWidth]/2, [GlobalGetters getGameViewHeight]/2);
    [newGv addSubview:spinner];
    [spinner startAnimating];
    
     __weak typeof(self) weakSelf = self;
    [weakSelf setNewGameViewPushAnimation:newGv additionalView:nil completionBlock:^(void){
        [gameView removeFromSuperview];
        gameView = newGv;
    }];
}

- (void) showScores
{
    [self.view bringSubviewToFront:statusView];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        for (UIView* v in gameView.subviews) {
            [v removeFromSuperview];
        }
        
        b1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [b1 setTitle: @"StartsNewRound" forState:UIControlStateNormal];
        b1.frame = CGRectMake([self getScreenWidth] - 150, [self getGameViewHeight] - 40, 150, 50);
        [b1 addTarget:self action:@selector(startNewRound) forControlEvents:UIControlEventTouchUpInside];
        [gameView addSubview:b1];
        
        [statusView.scoreView removeFromSuperview];
        
        UILabel* scoreV = [[UILabel alloc] initWithFrame:CGRectMake(200, 200, 700, 200)];
        scoreV.textColor = [UIColor whiteColor];
        scoreV.text = [NSString stringWithFormat:@"Our Score: %ld | Their Score: %ld", (long)myScore, (long)theirScore];
        scoreV.font = [scoreV.font fontWithSize:40.0];
        scoreV.alpha = 0;
        [statusView addSubview:scoreV];
        statusView.scoreView = scoreV;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^(void){
            [self transformViewAnimated:scoreV endTransform:CGAffineTransformMake(0.7, 0, 0, 0.7, 150, -250) completionBlock:^(void){}];
        }];
        [UIView beginAnimations:@"fade in" context:nil];
        scoreV.alpha = 1;
        [UIView commitAnimations];
        [CATransaction commit];
        
    }];
    
    [UIView beginAnimations:@"fade out" context:nil];
    for (UIView* v in gameView.subviews) {
        v.alpha = 0;
    }
    [UIView commitAnimations];
    [CATransaction commit];
    
    [self performSelector:@selector(startNewRound) withObject:NULL afterDelay:2];
}

- (void) transitFromSeeScoreToEndGameLayout
{
    NSLog(@"game over");
    
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(380, 240, 350, 100)];
    l.text = @"GAME OVER";
    l.textColor = [UIColor whiteColor];
    l.font = [l.font fontWithSize:50.0];
    [gameView addSubview:l];
}

#pragma mark - Transition Helpers

/*
 Do not remove the old view or reassign gameView. Do those in the completion block
 the gameViews are animated using position, while the extra view is animated by transform. 
 */
- (void) setNewGameViewPushAnimation:(GameView*) newGameView additionalView:(UIView*)otherView completionBlock:(void (^)(void))completionBlock
{
    //[self.view insertSubview:newGameView atIndex:0]; // put above the old gameview. For some unknown reason I cannot simply put it on the top, or its subview (the label) won't be displayed. s
    [self.view insertSubview:newGameView aboveSubview:gameView];
    
    CABasicAnimation *animation1 = [CABasicAnimation animation];
    animation1.keyPath = @"position.x";
    animation1.byValue = [NSNumber numberWithFloat: (-1 *[self getScreenWidth])];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation1.duration = 1.0;
    
    CABasicAnimation *animation2 = [CABasicAnimation animation];
    animation2.keyPath = @"transform.translation.x";
    animation2.fromValue = [NSNumber numberWithFloat:otherView.layer.transform.m41 + [self getScreenWidth]];
    animation2.byValue = [NSNumber numberWithFloat: (-1 *[self getScreenWidth])];
    [animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation2.duration = 1.0;
    
    CABasicAnimation *animation3 = [CABasicAnimation animation];
    animation3.keyPath = @"position.x";
    animation3.fromValue = [NSNumber numberWithFloat:[self getScreenWidth] * 1.5];
    animation3.byValue = [NSNumber numberWithFloat: (-1 *[self getScreenWidth])];
    [animation3 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation3.duration = 1.0;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completionBlock];
    [gameView.layer addAnimation:animation1 forKey:@"animation1"];
    [otherView.layer addAnimation:animation2 forKey:@"animation2"];
    [newGameView.layer addAnimation:animation3 forKey:@"animation3"];
    [CATransaction commit];
}

- (void) transformViewAnimated: (UIView*)v endTransform:(CGAffineTransform) transform completionBlock:(void (^)(void))completionBlock
{
    
    [self.view bringSubviewToFront:statusView];
    
    // store and set transform
    CGAffineTransform transfArchive = v.transform;
    v.transform = transform;
    
    CABasicAnimation *animaiton = [CABasicAnimation animation];
    animaiton.keyPath = @"transform";
    animaiton.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(transfArchive)];
    animaiton.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(transform)];
    [animaiton setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animaiton setDuration:1];
    [animaiton setBeginTime:CACurrentMediaTime()];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        completionBlock();
    }];
    [v.layer addAnimation:animaiton forKey:@"animation"];
    [CATransaction commit];
}

#pragma mark - Getters

- (BOOL) isInTeamOne
{
    return IS_IN_TEAM_ONE;
}

- (BOOL) isCaptain
{
    return isCaptain;
}

- (BOOL) isInOffendingTeam
{
    return IS_IN_TEAM_ONE == ((turnNumber % 2)==1);
}

- (float) getGameViewHeight
{
    return gameView.frame.size.height;
}

- (float) getScreenHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

- (float) getScreenWidth
{
    return [[UIScreen mainScreen] bounds].size.width;
}


- (void) connectMyself {
//    NSString *path = @"http://localhost:8080/ProtoApp/ConnectServlet";
    NSString *path = [NSString stringWithFormat:@"%@%@", HOST_NAME, @"ConnectServlet"];
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSString *uid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSDictionary *params = @{@"uid" : uid,
                             @"is_assign_cap" : [NSNumber numberWithBool:NO]};
    
    
    __weak typeof(self) weakSelf = self;
    [mgr POST:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSNumber *temp = (NSNumber *)[responseObject objectForKey:@"is_ready"];
          BOOL isReady = [temp boolValue];
          if (isReady){
              NSNumber *teamNumber = (NSNumber *)[responseObject objectForKey:@"team_num"];
              [weakSelf putInTeam:[teamNumber isEqualToNumber:[NSNumber numberWithInt:1]]];
              
              [weakSelf startNewRound];
              
              NSNumber *cap = (NSNumber *)[responseObject objectForKey:@"is_captain"];
              BOOL isCap = [cap boolValue];
              [weakSelf assignRole:isCap];
              NSLog(@"connect myself successful");
              return;
          } else {
              [weakSelf connectMyself];
          }
          
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error code: %ld", (long)operation.response.statusCode);
      }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods For Testing
- (void) putInTeamOne
{
    [self putInTeam:true];
}

- (void) putInTeamTwo
{
    [self putInTeam:false];
}

- (void) assignAsCaptain
{
    [self assignRole:true];
}

- (void) assignAsMinion
{
    [self assignRole:false];
}

- (void) whatIsTheComplimentOfRed
{
    [self setQuestionAndStartTimer:RED];
}

- (void) whatIsTheComplimentOfBlue
{
    [self setQuestionAndStartTimer:BLUE];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
