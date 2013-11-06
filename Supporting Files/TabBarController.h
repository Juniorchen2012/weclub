//
//  TabBarController.h
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatFriend.h"
#import "MLNavigationController.h"
#import "NoticeManager.h"
#import "CircleView.h"
#import "MKNumberBadgeView.h"

@class ClubListViewController;
@class UserViewController;
@class ArticleViewController;
@class SettingsViewController;
@class ChatViewController;

@interface TabBarController : UITabBarController
{
    UILabel *_clubNoticeLabel;
    UILabel *_articleNoticeLabel;
    UILabel *_userNoticeLabel;
    UIImageView *_tabtag_unread;
    
    MKNumberBadgeView *_clubNoticeCircle;
    MKNumberBadgeView *_articleNoticeCircle;
    MKNumberBadgeView *_userNoticeCircle;
    
    TabBarController        *_tabSelf;
    UIViewController *goController;
}
@property (strong, nonatomic) ClubListViewController *clublist;
@property (strong, nonatomic) UserViewController *user;
@property (strong, nonatomic) ChatViewController *chatView;
@property (strong, nonatomic) ArticleViewController *article;
@property (strong, nonatomic) SettingsViewController *settings;
@property (strong, nonatomic) UINavigationController *nav1;
@property (strong, nonatomic) UINavigationController *nav2;
@property (strong, nonatomic) UINavigationController *nav3;
@property (strong, nonatomic) UINavigationController *nav4;
@property (strong, nonatomic) Club *lastAdoptClub;
@property (nonatomic, retain) UIImageView *selectedbtn_bg;
@property (nonatomic, retain) UILabel *clubNoticeLabel;
@property (nonatomic, retain) UILabel *articleNoticeLabel;
@property (nonatomic, retain) UILabel *userNoticeLabel;
@property (nonatomic, retain) UIView *clubNoticeCircle;
@property (nonatomic, retain) UIView *articleNoticeCircle;
@property (nonatomic, retain) UIView *userNoticeCircle;

- (void)switchToUserTab;
- (void)switchToInformCenter:(NSNotification *)notification;
- (void)switchToClubTab;
- (void)switchToAtricleTab;
- (void)mentionMeAtricle;
- (void)followMeUser;
- (void)iFollowUser;
- (TabBarController *)getTabBar;

- (void)cleanAllNotice;

@end
