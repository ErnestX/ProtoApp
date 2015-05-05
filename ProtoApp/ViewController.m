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

@interface ViewController ()

@end

@implementation ViewController
{
    StatusView* statusView;
    GameView* gameView;
    float STATUS_VIEW_HEIGHT;
}

- (void) customInit
{
    STATUS_VIEW_HEIGHT = 100;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customInit];
    
    statusView = [[StatusView alloc]initWithFrame:CGRectMake(0, 0, [self getScreenWidth], STATUS_VIEW_HEIGHT)];
    gameView = [[GameView alloc]initWithFrame:CGRectMake(0, STATUS_VIEW_HEIGHT, [self getScreenWidth], [self getScreenHeight] - STATUS_VIEW_HEIGHT)];
    
    [self.view addSubview:statusView];
    [self.view addSubview:gameView];
    
    [self setUpReadyComfirmationLayout];
    
    [self testRequest];
}


- (void) setUpReadyComfirmationLayout
{
    UISwitch* comfirmationSwitch = [[UISwitch alloc]initWithFrame:CGRectMake([self getScreenWidth]/2 - 10, [self getScreenHeight]/2 - STATUS_VIEW_HEIGHT, 20, 20)];
    UILabel* switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 100, 20)];
    switchLabel.text = @"READY";
    switchLabel.textColor = [UIColor whiteColor];
    [comfirmationSwitch addSubview:switchLabel];
    [gameView addSubview:comfirmationSwitch];
}

- (void) transitFromComfirmationToTeamAssignmentLayout
{
    
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

# pragma mark - Transition Helpers

/*
 remove all subviews form gameView
 */
- (void) clearGameView
{
   //stub
}

# pragma mark - Getters

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
                               if (connectionError || !data){
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

@end
