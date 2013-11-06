//
//  User.m
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize name,userID;
@synthesize sex = _sex;
@synthesize activity = _activity;
@synthesize approve_flag = _approve_flag;
@synthesize article_count = _article_count;
@synthesize article_today_count = _article_today_count;
@synthesize birthday = _birthday;
@synthesize close_flag = _close_flag;
@synthesize email = _email;
@synthesize experience = _experience;
@synthesize follow_club_count = _follow_club_count;
@synthesize follow_me_count = _follow_me_count;
@synthesize i_follow_count = _i_follow_count;
@synthesize inclub_count = _inclub_count;
@synthesize level = _level;
@synthesize money = _money;
@synthesize reg_time = _reg_time;
@synthesize numberID = _numberID;
@synthesize location = _location;
@synthesize locDescription = _locDescription;
@synthesize photoID = _photoID;
@synthesize desc = _desc;
@synthesize photoTime = _photoTime;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)clearUserInfo
{
    name = nil;
    userID = nil;
    _sex = nil;
    _activity = nil;
    _approve_flag = nil;
    _article_count = nil;
    _article_today_count = nil;
    _birthday = nil;
    _close_flag = nil;
    _email = nil;
    _experience = nil;
    _follow_club_count = nil;
    _follow_me_count = nil;
    _i_follow_count = nil;
    _inclub_count = nil;
    _level = nil;
    _money = nil;
    _reg_time = nil;
    _numberID = nil;
    _location = nil;
    _locDescription = nil;
    _photoID = nil;
    _desc = nil;
}

@end
