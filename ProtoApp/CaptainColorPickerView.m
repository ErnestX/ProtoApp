//
//  CaptainColorPickerView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "CaptainColorPickerView.h"
#import "GlobalGetters.h"

@implementation CaptainColorPickerView

- (id)customInit
{
    CaptainColorPickerView* ccpv = [super initWithFrame:CGRectMake(0, 0, [GlobalGetters getScreenWidth], [GlobalGetters getGameViewHeight])]; // set the frame the same as gameView's
    self.backgroundColor = [UIColor blueColor];
    
    CALayer* colorRing = [CALayer layer];
    [self.layer addSublayer:colorRing];
    colorRing.backgroundColor = [UIColor redColor].CGColor;
    
    for (NSInteger i = 0; i < 12; i++) {
        CALayer* colorCard = [CALayer layer];
        colorCard.frame = CGRectMake(500, 500, 100, 100);
        [colorRing addSublayer:colorCard];
    }
    
    return ccpv;
}

@end
