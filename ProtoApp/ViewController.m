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

@interface ViewController ()

@end

@implementation ViewController
{
    StatusView* statusView;
    GameView* gameView;
    BOOL TEAM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    statusView = [[StatusView alloc]customInit];
    gameView = [[GameView alloc]customInit];
    
    [self.view addSubview:gameView]; // make sure gameView is on the top
    [self.view addSubview:statusView];
    
    [self setUpReadyComfirmationLayout];
    
    [self testRequest];
}

#pragma mark - Actions
- (void) putInTeam:(BOOL)isInTeamOne
{
    TEAM = isInTeamOne;
    [self transitFromComfirmationToTeamAssignmentLayout:isInTeamOne];
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

    UIButton* b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b1 setTitle: @"team1" forState:UIControlStateNormal];
    b1.frame = CGRectMake([self getScreenWidth] - 150, [self getGameViewHeight] - 40, 70, 50);
    [b1 addTarget:self action:@selector(putInTeamOne) forControlEvents:UIControlEventTouchUpInside];
    UIButton* b2 = [UIButton buttonWithType:UIButtonTypeSystem];
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
    }
}

#pragma mark TeamAssign

- (void) transitFromComfirmationToTeamAssignmentLayout: (BOOL)isInTeamOne
{
    GameView* newGv = [[GameView alloc]customInit];
    TeamView* tv = [[TeamView alloc]customInitWithTeam:isInTeamOne];
    
    tv.transform = CGAffineTransformMake(1, 0, 0, 1, [self getScreenWidth]/2 - 170, [self getGameViewHeight]/2 - 150);
    // add to GV for now
    [statusView addSubview:tv];
    [self setNewGameViewPush:newGv:tv:^(void) {
        [gameView removeFromSuperview];
        gameView = newGv;
        [self transformViewAnimated:tv endTransform:CGAffineTransformMake(0.3, 0, 0, 0.3, -150, -50) completionBlock:^(void){}];
    }];
}

//- (void) setTeamView: (TeamView*)tv
//{
//    [tv removeFromSuperview];
//    tv.transform = CGAffineTransformMake(0.3, 0, 0, 0.3, -150, -60);
//    [statusView addSubview:tv];
//    
//    [self transitFromTeamAssignmentToNewTurnLayout];
//}

#pragma mark NewTurn

- (void) transitFromTeamAssignmentToNewTurnLayout
{
    GameView* newGv = [[GameView alloc]customInit];
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake([GlobalGetters getScreenWidth]/2 - 120, [GlobalGetters getGameViewHeight]/2 - 100, 500, 100)];
    l.font = [l.font fontWithSize:100.0];
    l.text = @"Turn 1"; // TODO: dynamilize this
    l.textColor = [UIColor whiteColor];
    [newGv addSubview:l];
    
//    [self setNewGameViewPush:newGv :^(void){
//    }];
}

/*
 return true if success, false if not in offending team
 */
- (BOOL) transitFromNewTurnToCaptainAssignLayout
{
    return true;
}

/*
 return ture if success, false if not the captain
 */
- (BOOL) transitFromCaptainAssignToCaptainPickColorLayout
{
    return true;
}

/*return true if success, false if is the captain
 */
- (BOOL) transitFromCaptainAssignToWaitForCaptainLayout
{
    return true;
}

/*
 return ture if success, false if not in defending team
 */
- (BOOL) transitFromNewTurnToWaitForQuestion
{
    return true;
}

- (void) transitFromWaitForQuestionToAnswerQuestionLayout
{
    
}

- (void) transitToSeeScoreLayout
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
 @effect:add the newView as a subview and transit to it by pushing from right. gameView will be assigned to the newView in the end.
 */
- (void) setNewGameViewPush:(GameView*) newGameView :(UIView*) otherView :(void (^)(void))completionBlock
{
    [self.view insertSubview:newGameView atIndex:0]; // put at buttom
    
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
    CABasicAnimation *animaiton = [CABasicAnimation animation];
    animaiton.keyPath = @"transform";
    animaiton.fromValue = [NSValue valueWithCATransform3D:v.layer.transform];
    animaiton.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(transform)];
    [animaiton setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animaiton setBeginTime:CACurrentMediaTime()+1.0];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        v.transform = transform;
        completionBlock();
    }];
    [v.layer addAnimation:animaiton forKey:@"animation"];
    [CATransaction commit];
    
    //tv.layer.transform = CATransform3DMakeAffineTransform(transform); //this will finish before the animation even begin due to the delay
}

#pragma mark - Getters

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

- (void) testRequest {
    NSString *path = @"http://localhost:8080/ProtoApp/MyServlet";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError || !data) {
                                   NSLog(@"error occurred !!!!");
                               } else {
//                                   NSString *str = [NSString stringWithFormat:@"key: %@ value: %@", response.];
                               }
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

@end