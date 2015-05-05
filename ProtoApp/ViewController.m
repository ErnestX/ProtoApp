//
//  ViewController.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-04.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UILabel *lblTest = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200.0)];
    lblTest.text = @"TEST";
    lblTest.font = [UIFont fontWithName:@"helvetica" size:50.0];
    lblTest.textAlignment = NSTextAlignmentCenter;
    lblTest.textColor = [UIColor darkTextColor];
    
    [self.view addSubview:lblTest];
    
    [self connectMyself];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) connectMyself {
    NSString *path = @"http://localhost:8080/ProtoApp/ConnectServlet";
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSString *uid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSDictionary *params = @{@"uid" : uid};
    [mgr POST:path
   parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"connect myself successful");
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error code: %ld", (long)error.code);
      }];
    
    
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
//    [request setHTTPMethod:@"GET"];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[[NSOperationQueue alloc] init]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                               if (connectionError || !data){
//                                   NSLog(@"error occurred !!!!");
//                               } else {
//
//
//                               }
//                           }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
