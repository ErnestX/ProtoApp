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
    BOOL isColorSelected;
    CADisplayLink* displayLink;
    float dotAnimationSideLength;
    DotLayer* dotSelected;
    float selectedLayerZPosArchive;
    Colors selectedLayerColor;
    UIButton* confirmButton;
    UIButton* cancelButton;
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
//    UIView* gameView = [self superview];
//    [[gameView superview] sendSubviewToBack:gameView];
    
    dotSelected = dot;
    selectedLayerColor = (Colors)[colorPicker.sublayers indexOfObject:dotSelected];
    selectedLayerZPosArchive = dotSelected.zPosition;
    NSLog(@"color selected");
//    [CATransaction begin];
    
    // run animation
    dotSelected.zPosition = 100;
    dot.anchorPoint = CGPointMake(0.5, 0.5);
    dot.transform = CATransform3DMakeTranslation(dot.frame.size.width/2, dot.frame.size.height/2, 0);
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(selectDotAnimation)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    [CATransaction commit];
    
    // init buttons
    confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirmButton setTitle: @"Confirm" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(sectionDividerXPos + 40, [GlobalGetters getGameViewHeight]/2 - 50, 70, 50);
    [confirmButton addTarget:self action:@selector(confirmButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmButton];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle: @"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(sectionDividerXPos + 40, [GlobalGetters getGameViewHeight]/2 - 10, 70, 50);
    [cancelButton addTarget:self action:@selector(cancelButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    isColorSelected = true;
}

/*
 to be called by CADisplayLink
 */
- (void) selectDotAnimation
{
    NSLog(@"draw");
    if ([dotSelected getDotRaidus] < 600) {
        [dotSelected setDotRadius:[dotSelected getDotRaidus]+20];
        CGPoint position = dotSelected.position;
        dotSelected.frame = CGRectMake(0,0,dotSelected.frame.size.width + 40, dotSelected.frame.size.height + 40);
        dotSelected.position = position;
        [dotSelected setNeedsDisplay];
    } else {
        [displayLink invalidate];
    }
}

/*
 to be called by CADisplayLink
 */
- (void) unselectDotAnimation
{
    NSLog(@"undraw");
    if ([dotSelected getDotRaidus] > 50/1.5 - 5 + 1) {
        float newDotRadius;
        float newFrameSideLength;
        if ([dotSelected getDotRaidus] > 50/1.5 - 5 + 21) {
            newDotRadius = [dotSelected getDotRaidus]-20;
            newFrameSideLength = dotSelected.frame.size.width - 40;
        } else {
            newDotRadius = 50/1.5 - 5;
            newFrameSideLength = [GlobalGetters getGameViewHeight]/4/1.5;
        }
        
        [dotSelected setDotRadius:newDotRadius];
        CGPoint position = dotSelected.position;
        dotSelected.frame = CGRectMake(0,0,newFrameSideLength, newFrameSideLength);
        dotSelected.position = position;
        [dotSelected setNeedsDisplay];
    } else {
        [displayLink invalidate];
    }
}

- (IBAction)confirmButtonDown:(id)sender
{
    NSLog(@"confirmed");
    [controller sendAnswerToQuestion:selectedLayerColor];
}

- (IBAction)cancelButtonDown:(id)sender
{
    NSLog(@"canceled");
    // run animation
    [CATransaction begin];
    dotSelected.anchorPoint = CGPointMake(0, 0);
    dotSelected.transform = CATransform3DMakeTranslation(0, 0, 0);
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(unselectDotAnimation)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [CATransaction commit];
    // restore zPos
    dotSelected.zPosition = selectedLayerZPosArchive;
    
    isColorSelected = false;
}

@end
