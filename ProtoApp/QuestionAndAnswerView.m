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

@implementation QuestionAndAnswerView {
    Colors question;
    ViewController* controller;
    CALayer* colorPicker;
    float sectionDividerXPos;
    float stepSize;
    BOOL isColorSelected;
    CADisplayLink* displayLink;
    float dotAnimationSideLength;
    DotLayer* dotSelected;
    float selectedLayerZPosArchive;
    CATransform3D selectedLayerTransformArchive;
    Colors selectedLayerColor;
    UIButton* confirmButton;
    UIButton* cancelButton;
    CALayer* card;
}

- (id)customInit:(Colors)color :(ViewController*)contr
{
    QuestionAndAnswerView* qaav = [super initWithFrame:CGRectMake(0, 0, [GlobalGetters getScreenWidth], [GlobalGetters getGameViewHeight])]; // set the frame the same as gameView's
    
    // set up iVars
    controller = contr;
    sectionDividerXPos = [GlobalGetters getScreenWidth] - ([GlobalGetters getGameViewHeight]/4.0*3.0/1.5);
    stepSize = [GlobalGetters getGameViewHeight] / 4.0 /1.5 - 17;
    question = color;
    isColorSelected = false;
    
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
        float y = 74;
        for (NSInteger i = 0; i < 4; i++) {
            float x = 70;
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
    quesLayer.backgroundColor = [GlobalGetters uiColorFromColors:question].CGColor;
    [self.layer addSublayer:quesLayer];
    [CATransaction commit];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began");
    [super touchesBegan:touches withEvent:event];
    CGPoint touchPoint = [(UITouch*)[touches anyObject] locationInView:self];
    
    if (!isColorSelected) {
        for (DotLayer* dot in colorPicker.sublayers) {
            if ([dot.modelLayer containsPoint:[dot convertPoint:touchPoint fromLayer:self.layer]]) {
                [self colorSelected:dot];
            }
        }
    }
}

- (void)colorSelected:(DotLayer*) dot
{
    // send gameview to back for animations.
    UIView* gameView = [self superview];
    [[gameView superview] sendSubviewToBack:gameView];
    
    dotSelected = dot;
    selectedLayerColor = (Colors)[colorPicker.sublayers indexOfObject:dotSelected];
    selectedLayerZPosArchive = dotSelected.zPosition;
    selectedLayerTransformArchive = dotSelected.transform;
    NSLog(@"color selected");
    
    // run animation
    dotSelected.zPosition = 100;
    dotSelected.transform = CATransform3DMakeScale(1, 1, 1);
    
    // init buttons
    confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirmButton setTitle: @"CONFIRM" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(sectionDividerXPos + 130, [GlobalGetters getGameViewHeight]/2 - 50, 70, 50);
    [confirmButton addTarget:self action:@selector(confirmButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmButton];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle: @"CANCEL" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(sectionDividerXPos + 130, [GlobalGetters getGameViewHeight]/2 - 10, 70, 50);
    [cancelButton addTarget:self action:@selector(cancelButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    isColorSelected = true;
}

- (void) confirmAnimation
{
    // bring gameView to front for animation effect
    UIView* gameView = [self superview];
    [[gameView superview] bringSubviewToFront:gameView];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
       [controller answerSentForQuestion:selectedLayerColor]; // make sure the view transit after the animaiton is finished
    }];
    card.position = CGPointMake(card.position.x, card.position.y - [GlobalGetters getScreenHeight]);
    [CATransaction commit];
}

- (IBAction)confirmButtonDown:(id)sender
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        // make sure the animation runs only after the dot layer has been removed
        [confirmButton removeFromSuperview];
        [cancelButton removeFromSuperview];
        
        [self confirmAnimation];
    }];
    
    card = [CALayer layer];
    card.frame = CGRectMake(sectionDividerXPos, 0, colorPicker.frame.size.width, [GlobalGetters getGameViewHeight]);
    card.backgroundColor = [GlobalGetters uiColorFromColors:selectedLayerColor].CGColor;
    [self.layer addSublayer:card];
    
    [dotSelected removeFromSuperlayer];
    
    [CATransaction commit];
}

- (IBAction)cancelButtonDown:(id)sender
{
    // run animation
    dotSelected.transform = selectedLayerTransformArchive;

    // restore zPos
    dotSelected.zPosition = selectedLayerZPosArchive;
    
    [confirmButton removeFromSuperview];
    [cancelButton removeFromSuperview];
    
    isColorSelected = false;
}

@end
