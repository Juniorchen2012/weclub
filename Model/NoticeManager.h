//
//  NoticeManager.h
//  WeClub
//
//  Created by mitbbs on 13-8-14.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoticeView.h"
#import "TabBarController.h"
#import "AppDelegate.h"
#import "CircleView.h"
#import "ArticleViewController.h"
#import "UserViewController.h"
#import "ClubListViewController.h"
#import "MKNumberBadgeView.h"

@class NoticeView;
@interface NoticeManager : NSObject<NSCoding>
{
    NSMutableDictionary             *_noticeDic;
    int                              _bbsFlag;
    int                              _chatNoticeCount;
    
    NoticeView                      *_clubNotice;
    NoticeView                      *_articleNotice;
    NoticeView                      *_userNotice;
    
    NoticeView                      *_bbsClubFollowNotice;
    NoticeView                      *_bbsClubAttentionNotice;
    NoticeView                      *_bbsUserAttentionNotice;
    NoticeView                      *_bbsUserFollowNotice;
    
    NSMutableArray                  *_adoptClubNoticeArray;
    int                              _adoptClubNoticeCount;
    int                              _bbsLoginResetFlag;
    
    
    NoticeView                      *_reconnectNotice;
}

+ (NoticeManager *)sharedNoticeManager;

- (void)resetBBSLoginAllNotices;
- (void)resetAllNotices;
- (void)resetSharedNoticeManger;
- (void)resetNoticeWithType:(NSString *)type;
- (NoticeView *)getNoticeWithType:(NSString *)type;
- (NSInteger)getNoticesCountWithType:(NSString *)type;
- (BOOL)noticeIsExistWithType:(NSString *)type;

- (void)resetBBSNoticeWithType:(NSString *)type;
- (void)resetClubAdoptNoticeWithId:(NSString *)numberId;

- (void)resetChatNotice:(int)count;
- (void)showNotice;

@end
