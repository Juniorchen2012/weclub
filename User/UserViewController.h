//
//  UserViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import "Utility.h"
#import <Foundation/Foundation.h>
#import "FPPopoverController.h"
#import "UserListTableViewController.h"
#import "UserListViewController.h"
#import "ChatViewController.h"
#import "NoticeView.h"
#import "SuperUserListViewController.h"
#import "ZBarSDK.h"
#import "ZBarManager.h"
@class UserListViewController;
@interface UserViewController : UITabBarController<FPPopoverControllerDelegate>{
    //处理下拉列表的view
    UILabel *titleLbl;
    UIView *holeView;
    UIImageView *titleViewArrow;
    UIActivityIndicatorView *connectMQTTActivityIndictor;
    UIView *titleViews;
    UIButton *_changeViewButton;
    UIButton *_addFriendButton;
    UIButton *_headerTitleButton;
    UIButton *titleView;//标题栏
    
    FPPopoverController *_popOver;
    UserListViewController *_userList;
    ChatViewController *_chatView;
    NSString *_aheadTitleStr;
    
    NoticeView *_notice;
    
    NSString *qrText;
    
    RequestProxy *_rp;
    
}
@property (strong) UIButton *_addFriendButton;
@property (strong) UIButton *_headerTitleButton;

@property (nonatomic,assign) NSInteger isFollowMeUser;
@property (nonatomic,assign) NSInteger isIFollowUser;

- (void)popOverView:(id)sender;
- (void)handleUserListNotification:(NSNotification *)notification;
- (void)switchToChatTab:(NSNotification *)notification;
- (void)showNoticeView:(NSNotification *)notification;
- (NSArray *)getAllView;
- (UIView *)getReconnectView;

@end
