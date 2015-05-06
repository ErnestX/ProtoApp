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

@interface ViewController ()

@end

@implementation ViewController
{
    StatusView* statusView;
    GameView* gameView;
    BOOL TEAM;
    float STATUS_VIEW_HEIGHT;
}

- (void) customInit
{
    STATUS_VIEW_HEIGHT = 100;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customInit];
    
    statusView = [[StatusView alloc]customInit];
    gameView = [[GameView alloc]customInit];
    
    [self.view addSubview:statusView];
    [self.view addSubview:gameView];
    
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
    UISwitch* comfirmationSwitch = [[UISwitch alloc]initWithFrame:CGRectMake([self getScreenWidth]/2 - 10, [self getScreenHeight]/2 - STATUS_VIEW_HEIGHT, 20, 20)];
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
    [newGv addSubview:tv];
    
    [self setNewGameViewPush:newGv];
    NSLog(@"MARK");
}

- (void) transitFromTeamAssignmentToNewTurnLayout
{
    
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
 @effect:add the newView as a subview and transit to it by pushing from right. gameView will be assigned to the newView in the end
 */
- (void) setNewGameViewPush:(GameView*) newView
{
    float SPEED = 1500;
    // position the new view so that it's on the right of the old one.
    newView.frame = CGRectMake([self getScreenWidth], STATUS_VIEW_HEIGHT, newView.frame.size.width, newView.frame.size.height);
    
    [self.view addSubview:newView];
    
    // push both of them
//    [UIView animateWithDuration:1.0 animations:^(void) {
//         newView.frame = CGRectMake(newView.frame.origin.x - SPEED, newView.frame.origin.y, newView.frame.size.width, newView.frame.size.height);
//         gameView.frame = CGRectMake(gameView.frame.origin.x - SPEED, gameView.frame.origin.y, gameView.frame.size.width, gameView.frame.size.height);
//    }];
    CABasicAnimation *animation1 = [CABasicAnimation animation];
    animation1.keyPath = @"position.x";
    animation1.fromValue = [NSNumber numberWithFloat:[self getScreenWidth]/2];
    animation1.byValue = [NSNumber numberWithFloat: (-1 *[self getScreenWidth])];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation1.duration = 1.0;
    CABasicAnimation *animation2 = [CABasicAnimation animation];
    animation2.keyPath = @"position.x";
    animation2.fromValue = [NSNumber numberWithFloat:[self getScreenWidth] * 1.5];
    animation2.byValue = [NSNumber numberWithFloat: (-1 *[self getScreenWidth])];
    [animation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    animation2.duration = 1.0;
    
    [gameView.layer addAnimation:animation1 forKey:@"animation1"];
    [newView.layer addAnimation:animation2 forKey:@"animation2"];
    newView.frame = gameView.frame;
    
    gameView = newView;
}

#pragma mark - Getters

- (float) getGameViewHeight
{
    return [self getScreenHeight] - STATUS_VIEW_HEIGHT;
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