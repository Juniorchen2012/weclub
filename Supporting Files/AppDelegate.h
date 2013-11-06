//
//  AppDelegate.h
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>
#import "LoginViewController.h"
#import "DirectLoginViewController.h"
#import "AccountUser.h"
#import "StartPageViewController.h"

@class TabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *nav;
    Reachability *reach;
}
@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) TabBarController *TabC;
@property (retain, nonatomic) StartPageViewController *startPageView;

@end
