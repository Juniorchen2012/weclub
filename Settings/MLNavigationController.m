//
//  MLNavigationController.m
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#import "MLNavigationController.h"
#import "EditInfoViewController.h"
#import "ListViewController.h"
#import "TabBarController.h"
#import <QuartzCore/QuartzCore.h>

@interface MLNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
    
    UIPanGestureRecognizer *recognizer;
    
    UIImage *_image;
    
    BOOL once;          //
    NSInteger count;    //判断是向左划还是上下滑
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;

@property (nonatomic,assign) BOOL isMoving;

@end

@implementation MLNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.screenShotsList = [[[NSMutableArray alloc]initWithCapacity:2]autorelease];
        self.canDragBack = YES;
        
    }
    return self;
}

- (void)dealloc
{
    self.screenShotsList = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // draw a shadow for navigation view to differ the layers obviously.
    // using this way to draw shadow will lead to the low performace
    // the best alternative way is making a shadow image.
    //
    //self.view.layer.shadowColor = [[UIColor blackColor]CGColor];
    //self.view.layer.shadowOffset = CGSizeMake(5, 5);
    //self.view.layer.shadowRadius = 5;
    //self.view.layer.shadowOpacity = 1;
    
    UIImageView *shadowImageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]]autorelease];
    shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
    [self.view addSubview:shadowImageView];
    
    _isMoving = NO;
    recognizer = [[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                         action:@selector(paningGestureReceive:)]autorelease];
    [recognizer delaysTouchesBegan];
    [self.view addGestureRecognizer:recognizer];
    
    //    UIPanGestureRecognizer *recognizer = [[[UIPanGestureRecognizer alloc]initWithTarget:self
    //                                                                                 action:@selector(paningGestureReceive:)]autorelease];
    //    [recognizer delaysTouchesBegan];
    //    [self.view addGestureRecognizer:recognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"willappear");
    [self addGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.screenShotsList addObject:[self capture]];
    [super pushViewController:viewController animated:animated];
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

#pragma mark - Utility Methods -

// get the current view screen shot
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *img2 = nil;
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
            [view.layer renderInContext:UIGraphicsGetCurrentContext()];
            img2 = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsGetCurrentContext();
            
        }
    }
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(0, 0, 320, img.size.height);
    //UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"txtFieldBg.png"]];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:img2];
    imageView2.frame = CGRectMake(0, img.size.height, 320, img2.size.height);
    [view addSubview:imageView];
    [view addSubview:imageView2];
    
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img3 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img3;
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    
    //  NSLog(@"Move to:%f",x);
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    blackMask.alpha = alpha;
    
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    if ([self.topViewController isKindOfClass:[EditInfoViewController class]]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideKeyboard" object:nil];
//    }
//}
#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    NSLog(@"Paning..");
    if ([self.topViewController isKindOfClass:[EditInfoViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideKeyboard" object:nil];
    }
    
    if ([self.topViewController isKindOfClass:[ListViewController class]]) {
        return;
    }
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];

    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"1");
        _isMoving = YES;
        once = NO;
        count = 0;
        startTouch = touchPoint;
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)]autorelease];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[[UIImageView alloc]initWithImage:lastScreenShot]autorelease];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        //End paning, always check that if it should move right or move left automatically
    }else if (recoginzer.state == UIGestureRecognizerStateEnded && _isMoving){
        if (touchPoint.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        once = NO;
        for (UIView *oneView in self.topViewController.view.subviews){
            if ([oneView isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *)oneView).scrollEnabled = YES;
            }
            
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        once = NO;
        for (UIView *oneView in self.topViewController.view.subviews){
            if ([oneView isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *)oneView).scrollEnabled = YES;
            }
            
        }
        return;
    }else if (recognizer.state == UIGestureRecognizerStateChanged && _isMoving){
        NSLog(@"3");
        count++;
        if (count == 5) {
            once = YES;
            if ((touchPoint.x - startTouch.x)*(touchPoint.x - startTouch.x) < (touchPoint.y - startTouch.y)*(touchPoint.y - startTouch.y)) {
                NSLog(@"not moving");
                _isMoving = NO;
            }else if (touchPoint.x < startTouch.x){
                _isMoving = NO;
            }
        }
        
    }
    
    // it keeps move with touch
    if (_isMoving && once) {
        NSLog(@"moving 2");
//        for (UIView *oneView in self.topViewController.view.subviews){
//            if ([oneView isKindOfClass:[UIScrollView class]]) {
//                if (((UIScrollView *)oneView).dragging == YES || ((UIScrollView *)oneView).decelerating == YES) {
//                    _isMoving = NO;
//                    NSLog(@"%d",_isMoving);
//                    NSLog(@"%d",((UIScrollView *)oneView).scrollEnabled);
//                    return;
//                }
//                
//            }
//        }
        for (UIView *oneView in self.topViewController.view.subviews){
            if ([oneView isKindOfClass:[UIScrollView class]]) {
                ((UIScrollView *)oneView).scrollEnabled = NO;
            }
        }
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

- (void)removeGesture
{
    if (self.view.gestureRecognizers.count != 0) {
        [self.view removeGestureRecognizer:recognizer];
    }
}

- (void)addGesture
{
    if (self.view.gestureRecognizers.count == 0) {
        recognizer = [[[UIPanGestureRecognizer alloc]initWithTarget:self
                                                             action:@selector(paningGestureReceive:)]autorelease];
        [recognizer delaysTouchesBegan];
        [self.view addGestureRecognizer:recognizer];
    }
}

@end
