//
//  NoticeView.h
//  WeClub
//
//  Created by Archer on 13-4-9.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticeManager.h"
#import "ClubListViewController.h"

@interface NoticeView : UIView<NSCoding>
{
    int                          _noticeNumber;
    NSString                    *_noticeType;
    UIButton                    *_noticeButton;
    
    NSString                    *_adoptClubId;
    NSString                    *_tips;
}

@property (nonatomic, strong) UIButton *noticeButton;
@property (nonatomic, assign) int noticeNumber;
@property (nonatomic, strong) NSString *noticeType;
@property (nonatomic, strong) NSString *adoptClubId;
@property (nonatomic, strong) NSString *tips;

- (id)initWithNumber:(int)number andType:(NSString *)type;
- (id)initClubAdopt:(NSDictionary *)dic;
- (id)initReconnectedWithDic:(NSDictionary *)dic;

@end
