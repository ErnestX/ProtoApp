//
//  StatusView.h
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusView : UIView
@property UIView* teamView;
@property UIView* turnView;
@property UIView* roleView;
@property UIView* scoreView;

- (id) customInit;

@end
