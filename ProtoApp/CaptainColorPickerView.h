//
//  CaptainColorPickerView.h
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface CaptainColorPickerView : UIView

- (id)customInit:(ViewController*) contr;
- (void)generateColorRing;

@end
