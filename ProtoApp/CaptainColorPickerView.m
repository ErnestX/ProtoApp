//
//  CaptainColorPickerView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "CaptainColorPickerView.h"
#import "GlobalGetters.h"

@implementation CaptainColorPickerView {
    float colorCardHeight;
    float colorCardWidth;
    CALayer* colorRing;
}

- (void)iVarInit
{
    colorCardHeight = 200;
    colorCardWidth = 100;
    colorRing = [CALayer layer];
    colorRing.frame = self.layer.frame;
    [self.layer addSublayer:colorRing];
}

- (id)customInit
{
    CaptainColorPickerView* ccpv = [super initWithFrame:CGRectMake(0, 0, [GlobalGetters getScreenWidth], [GlobalGetters getGameViewHeight])]; // set the frame the same as gameView's
    [self iVarInit];
    //self.backgroundColor = [UIColor blueColor];
    
    //colorRing.backgroundColor = [UIColor redColor].CGColor;
    return ccpv;
}


- (void)generateColorRing
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        [CATransaction begin];
        [CATransaction setAnimationDuration:2];
        for (NSInteger i = 0; i < 12; i++) {
            for (NSInteger j = i; j < 12; j++) {
                // transform all cards in range
                CALayer* c = [colorRing.sublayers objectAtIndex:j];
                //            c.position = CGPointMake(c.position.x + 10, c.position.y);
                
                c.transform = CATransform3DTranslate(c.transform, 0, 200, 0);
                c.transform = CATransform3DRotate(c.transform, M_PI/6, 0, 0, 1);
                c.transform = CATransform3DTranslate(c.transform, 0, -200, 0);
                
                c.backgroundColor = [UIColor colorWithHue:j * (1.0/12.0) saturation:1 brightness:1 alpha:1].CGColor;
            }
        }
        [CATransaction commit];
    }];
    for (NSInteger i = 0; i < 12; i++) {
        CALayer* colorCard = [CALayer layer];
        colorCard.frame = CGRectMake([GlobalGetters getScreenWidth]/2 - 50, 30, colorCardWidth, colorCardHeight);
        //colorCard.backgroundColor = [UIColor colorWithHue:0.5 saturation:1 brightness:0.5 alpha:1].CGColor;
        [colorRing addSublayer:colorCard];
    }
    [CATransaction commit];
    
}

@end
