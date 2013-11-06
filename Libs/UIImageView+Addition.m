//
//  UIImageView+Addition.m
//  PhotoLookTest
//
//  Created by waco on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define kCoverViewTag           1234
#define kImageViewTag           1235
#define kAnimationDuration      0.3f
#define kImageViewWidth         300.0f
//#define kBackViewColor          [UIColor colorWithWhite:0.667 alpha:0.8f]
#define kBackViewColor          [UIColor colorWithWhite:0.38 alpha:0.8f]

#import "UIImageView+Addition.h"

@implementation UIImageView (UIImageViewEx)

- (void)hiddenView
{
    UIView *coverView = (UIView *)[[self window] viewWithTag:kCoverViewTag];
    [coverView removeFromSuperview];
}

- (void)hiddenViewAnimation
{    
    UIImageView *imageView = (UIImageView *)[[self window] viewWithTag:kImageViewTag];
    
    [UIView beginAnimations:nil context:nil];    
    [UIView setAnimationDuration:kAnimationDuration]; //动画时长
    CGRect rect = [self convertRect:self.bounds toView:self.window];
    imageView.frame = rect;
    
    [UIView commitAnimations];
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:kAnimationDuration];
    
}

//自动按原UIImageView等比例调整目标rect
- (CGRect)autoFitFrame
{
    //调整为固定宽，高等比例动态变化
    float width = kImageViewWidth;
    float targeHeight = (width*self.frame.size.height)/self.frame.size.width;
    UIView *coverView = (UIView *)[[self window] viewWithTag:kCoverViewTag];
    CGRect targeRect = CGRectMake(coverView.frame.size.width/2 - width/2, coverView.frame.size.height/2 - targeHeight/2, width, targeHeight);
    return targeRect;
}

- (void)imageTap
{    
    UIView *coverView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    coverView.backgroundColor = kBackViewColor;
    coverView.tag = kCoverViewTag;
    UITapGestureRecognizer *hiddenViewGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenViewAnimation)];
    [coverView addGestureRecognizer:hiddenViewGecognizer];
    [hiddenViewGecognizer release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];

    imageView.backgroundColor = [UIColor whiteColor];
    imageView.tag = kImageViewTag;
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = self.contentMode;
    CGRect rect = [self convertRect:self.bounds toView:self.window];
    imageView.frame = rect;
    
    UIView *bgView = [[UIView alloc]initWithFrame:imageView.frame];
    bgView.backgroundColor = [UIColor whiteColor];
    
//    [coverView addSubview:bgView];
    [coverView addSubview:imageView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if (iPhone5) {
        btn.frame = CGRectMake(120, 510, 80, 30);
    }else{
        btn.frame = CGRectMake(120, 410, 80, 30);
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    [btn setTitle:@"查看原图" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(viewLarge) forControlEvents:UIControlEventTouchDown];
//    [coverView addSubview:btn];
    [[self window] addSubview:coverView];
    [coverView release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration];    
    imageView.frame = [self autoFitFrame];
    bgView.frame = [self autoFitFrame];
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIO_STOP" object:@"CLUBINFO" userInfo:nil];
}

-(void)viewLarge{
    [self hiddenView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewLargePhoto" object:self.superview.superview userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.superview.superview.tag],@"articleNO",[NSNumber numberWithInt:self.tag],@"mediaNO", nil]];
}

- (void)addDetailShow
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
//    UISwipeGestureRecognizer *swipeGestureRecognizer1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doNothing)];
//    [swipeGestureRecognizer1 setDirection:UISwipeGestureRecognizerDirectionUp];
//    [self addGestureRecognizer:swipeGestureRecognizer1];
//    [swipeGestureRecognizer1 release];
}

@end