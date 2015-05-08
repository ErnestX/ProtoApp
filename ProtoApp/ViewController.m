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

#define HOST_NAME @"http://128.189.239.107:8080/ProtoApp/"

@interface ViewController ()

@end

@implementation ViewController
{
    StatusView* statusView;
    GameView* gameView;
    TimerView* timerView;
    BOOL TEAM;
    BOOL isCaptain;
    BOOL assignedTeam;
    NSInteger turn;
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
    assignedTeam = false;
    turn = 0;
    maxScorePossible = 10;
    myScore = 0;
    theirScore = 0;
}

#pragma mark - Actions
- (void) putInTeam:(BOOL)isInTeamOne
{
    TEAM = isInTeamOne;
    assignedTeam = true; // this should be the only line that can modify assignedTeam
    [self transitFromComfirmationToTeamAssignmentLayout:isInTeamOne];
}

- (BOOL) startNewRound
{
    if (assignedTeam) {
        turn += 1;
        [self transitFromTeamAssignmentToNewTurnLayout];
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
                             @"is_from_captain" : [NSNumber numberWithBool:YES]};
    
    __weak typeof(self) weakSelf = self;
    [mgr POST:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"captain submitted color successful");
          [weakSelf transitToSeeScoreLayout];

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error code: %ld", (long)operation.response.statusCode);
      }];
    
    [self transitToSeeScoreLayout];
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
    [self transitToSeeScoreLayout];
}

- (void) stopTimer
{
    // stop all timers
    [tickTimer invalidate];
    [timer invalidate];
    
    NSLog(@"question:%u | answer:%u",questionPickedByCaptain, answerProposed);
    
    NSInteger rawScore = [timerView getCurrentTime]; // rawScore: the time left
    NSInteger score;
    // if correct, uses rawScore. Else, uses the worst score
    if ((questionPickedByCaptain - answerProposed) == 6) {
        // correct!
        NSLog(@"correct");
        score = maxScorePossible - rawScore;
    } else {
        // wrong
        NSLog(@"wrong");
        score = maxScorePossible - 0;
    }
    
    // TODO: send score back to server
    
    NSLog(@"score = %ld", (long)score);
    [self transitToSeeScoreLayout];
}

- (void) increaseMyScoreBy:(NSInteger)ms TheirScoreBy:(NSInteger)ts
{
    // increase scores
    myScore += ms;
    theirScore += ts;
    
    [self showScores];
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
    tv.transform = CGAffineTransformMake(1, 0, 0, 1, [self getScreenWidth]/2 - 160, [self getGameViewHeight]/2 - 150);
    [statusView addSubview:tv];
    [weakSelf setNewGameViewPushAnimation:newGv additionalView:tv completionBlock:^(void) {
        [gameView removeFromSuperview];
        gameView = newGv;
        [self transformViewAnimated:tv endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, -150, -50) completionBlock:^(void){}];
    }];
}

#pragma mark NewTurn

- (void) transitFromTeamAssignmentToNewTurnLayout
{
    [b1 removeFromSuperview];
    b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b1 setTitle: @"Captain" forState:UIControlStateNormal];
    b1.frame = CGRectMake([self getScreenWidth] - 170, [self getGameViewHeight] - 40, 150, 50);
    [b1 addTarget:self action:@selector(assignAsCaptain) forControlEvents:UIControlEventTouchUpInside];
    
    b2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b2 setTitle: @"Minion" forState:UIControlStateNormal];
    b2.frame = CGRectMake([self getScreenWidth] - 60, [self getGameViewHeight] - 40, 70, 50);
    [b2 addTarget:self action:@selector(assignAsMinion) forControlEvents:UIControlEventTouchUpInside];
    
    [gameView addSubview:b1];
    [gameView addSubview:b2];
    
     __weak typeof(self) weakSelf = self;
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 200)];
    l.transform = CGAffineTransformMake(1, 0, 0, 1, [self getScreenWidth]/2 - 160, [self getGameViewHeight]/2 - 150);
    l.font = [l.font fontWithSize:100.0];
    l.text = [NSString stringWithFormat:@"Turn %ld",(long)turn];
    l.textColor = [UIColor whiteColor];
    [statusView addSubview:l];
    [self setNewGameViewPushAnimation:NULL additionalView:l completionBlock:^(void){
        [weakSelf transformViewAnimated:l endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, -20, -50) completionBlock:^(void){
            // after the animation
            if (![weakSelf isInOffendingTeam]) {
                // not our turn, go wait for question
                [weakSelf transitFromNewTurnToWaitForQuestion];
            }
        }];
    }];
}

/*
 return true if success, false if not in offending team
 */
- (BOOL) transitFromNewTurnToCaptainAssignLayout
{
    __weak typeof(self) weakSelf = self;
    if ([self isInOffendingTeam]) {
        UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 500, 200)];
        l.transform = CGAffineTransformMake(1, 0, 0, 1, [self getScreenWidth]/2 - 160, [self getGameViewHeight]/2 - 150);
        l.font = [l.font fontWithSize:100.0];
        l.textColor = [UIColor whiteColor];
        
        if (isCaptain) {
            l.text = [NSString stringWithFormat:@"Captain"];
            [statusView addSubview:l];
            
            [self setNewGameViewPushAnimation:NULL additionalView:l completionBlock:^(void){
                [weakSelf transformViewAnimated:l endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, 110, -50) completionBlock:^(void) {
                    [weakSelf transitFromCaptainAssignToCaptainPickColorLayout]; // go straight ahead
                }];
            }];
        } else {
            l.text = [NSString stringWithFormat:@"Minion"];
            [statusView addSubview:l];
            
            [self setNewGameViewPushAnimation:NULL additionalView:l completionBlock:^(void){
                [weakSelf transformViewAnimated:l endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, 110, -50) completionBlock:^(void) {
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
    NSLog(@"wait for the captain");
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
    NSDictionary *params = @{@"is_from_captain" : [NSNumber numberWithBool:NO]};
    
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
    
    timerView = [[TimerView alloc]initWithFrame:CGRectMake([GlobalGetters getScreenWidth] - 50, 30, 50, 50)];
    [timerView customInit:maxScorePossible];
    [statusView addSubview:timerView];
    
    // schedule timers
    tickTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:timerView selector:@selector(tick) userInfo:nil repeats:true];
    timer = [NSTimer scheduledTimerWithTimeInterval:maxScorePossible target:self selector:@selector(stopTimer) userInfo:nil repeats:false];
}

- (void) transitToSeeScoreLayout
{
    NSLog(@"see sccore");
}

- (void) showScores
{
    
}

- (void) transitFromSeeScoreToEndGameLayout
{
    
}

- (void) transitFromSeeScoreToNewTurnLayout
{
    
}

#pragma mark - Transition Helpers

/*
 Do not remove the old view or reassign gameView. Do those in the completion block
 */
- (void) setNewGameViewPushAnimation:(GameView*) newGameView additionalView:(UIView*)otherView completionBlock:(void (^)(void))completionBlock
{
    [self.view insertSubview:newGameView atIndex:1]; // put at buttom
    //[self.view addSubview:newGameView]; // put at the front
    
    CABasicAnimation *animation1 = [CABasicAnimation animation];
    animation1.keyPath = @"position.x";
    animation1.byValue = [NSNumber numberWithFloat: (-1 *[self getScreenWidth])];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation1.duration = 1.0;
    
    CABasicAnimation *animation2 = [CABasicAnimation animation];
    animation2.keyPath = @"position.x";
    animation2.fromValue = [NSNumber numberWithFloat:otherView.frame.origin.x + [self getScreenWidth] - 90];
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
    CGAffineTransform transf = v.transform;
    v.transform = transform;
    
    CABasicAnimation *animaiton = [CABasicAnimation animation];
    animaiton.keyPath = @"transform";
    animaiton.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(transf)];
    animaiton.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(transform)];
    [animaiton setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animaiton setBeginTime:CACurrentMediaTime()];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
//        v.transform = transform;
        completionBlock();
    }];
    [v.layer addAnimation:animaiton forKey:@"animation"];
    [CATransaction commit];
}

#pragma mark - Getters

- (BOOL) isInTeamOne
{
    return TEAM;
}

- (BOOL) isCaptain
{
    return isCaptain;
}

- (BOOL) isInOffendingTeam
{
    return TEAM == ((turn % 2)==1);
}

- (float) getGameViewHeight
{
//    return [self getScreenHeight] - STATUS_VIEW_HEIGHT;
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
    NSDictionary *params = @{@"uid" : uid};
    
    
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
