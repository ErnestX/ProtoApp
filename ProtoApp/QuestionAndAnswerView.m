//
//  QuestionAndAnswerView.m
//  ProtoApp
//
//  Created by Jialiang Xiang on 2015-05-05.
//  Copyright (c) 2015 ElementsLab. All rights reserved.
//

#import "QuestionAndAnswerView.h"
#import "GlobalGetters.h"
#import "DotLayer.h"
#import "ColorsEnumType.h"

@implementation QuestionAndAnswerView{
    Colors question;
    ViewController* controller;
    CALayer* colorPicker;
    float sectionDividerXPos;
    float stepSize;
    BOOL colorSelected;
}

- (id)customInit:(Colors)color :(ViewController*)contr
{
    QuestionAndAnswerView* qaav = [super initWithFrame:CGRectMake(0, 0, [GlobalGetters getScreenWidth], [GlobalGetters getGameViewHeight])]; // set the frame the same as gameView's
    
    // set up iVars
    controller = contr;
    sectionDividerXPos = [GlobalGetters getScreenWidth] - ([GlobalGetters getGameViewHeight]/4.0*3.0/1.5);
    stepSize = [GlobalGetters getGameViewHeight] / 4.0 /1.5 - 17;
    question = color;
    colorSelected = false;
    
    colorPicker = [CALayer layer];
    colorPicker.frame = CGRectMake(sectionDividerXPos, [GlobalGetters getGameViewHeight]/3.0/2.0, [GlobalGetters getGameViewHeight]/4*3/1.5, [GlobalGetters getGameViewHeight]/1.5);
    [self.layer addSublayer:colorPicker];
    
    return qaav;
}

- (void)createAnswerSheet
{
    // bring gameview to front for animations.
    UIView* gameView = [self superview];
    [[gameView superview] bringSubviewToFront:gameView];
    
    // answers
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        [CATransaction begin];
        [CATransaction setAnimationDuration:1];
        float y = 34;
        for (NSInteger i = 0; i < 4; i++) {
            float x = 20;
            for (NSInteger j = 0; j < 3; j++) {
                DotLayer* dl = [colorPicker.sublayers objectAtIndex:(i*3)+j];
                dl.position = CGPointMake(x, y);

                x += stepSize;
            }
            y += stepSize;
        }
        [CATransaction commit];
    }];
    for (NSInteger i = 0; i < 12; i++) {
        DotLayer* dl = [DotLayer layer];
        [dl customInit:(Colors)i];
        dl.position = CGPointMake(colorPicker.frame.size.width/2 - dl.frame.size.width/2, colorPicker.frame.size.height/2 - dl.frame.size.height/2);
        [colorPicker addSublayer:dl];
        [dl setNeedsDisplay];
    }
    [CATransaction commit];
    
    // question
    CALayer* quesLayer = [CALayer layer];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        [CATransaction begin];
        [CATransaction setAnimationDuration:1.0];
        quesLayer.frame = CGRectMake(0, 0, sectionDividerXPos, [GlobalGetters getGameViewHeight]);
        [CATransaction commit];
    }];
    quesLayer.frame = CGRectMake(0, -1*[GlobalGetters getScreenHeight], sectionDividerXPos, [GlobalGetters getGameViewHeight]);
    quesLayer.backgroundColor = [UIColor colorWithHue: question * (1.0/12.0) saturation:1 brightness:1 alpha:1].CGColor;
    [self.layer addSublayer:quesLayer];
    [CATransaction commit];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began");
    [super touchesBegan:touches withEvent:event];
    CGPoint touchPoint = [(UITouch*)[touches anyObject] locationInView:self];
    
    if (!colorSelected) {
        for (CALayer* dot in colorPicker.sublayers) {
            if ([dot.modelLayer containsPoint:[dot convertPoint:touchPoint fromLayer:self.layer]]) {
                [self colorSelected:dot];
            }
        }
    }
}

- (void)colorSelected:(CALayer*) dot
{
    NSLog(@"color selected");
    [CATransaction begin];
    dot.anchorPoint = CGPointMake(0.5, 0.5);
    dot.transform = CATransform3DMakeTranslation(dot.frame.size.width/2, dot.frame.size.height/2, 0);

    
    
    [CATransaction commit];
}

@end
