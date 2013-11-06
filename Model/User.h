//
//  User.h
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    NSString *name;//用户名
    NSString *userID;
    NSString *_sex;
    NSString *_activity;
    NSString *_approve_flag;
    NSString *_article_count;
    NSString *_article_today_count;
    NSString *_birthday;
    NSString *_close_flag;
    NSString *_email;
    NSString *_experience;
    NSString *_follow_club_count;
    NSString *_follow_me_count;
    NSString *_i_follow_count;
    NSString *_inclub_count;
    NSString *_level;
    NSString *_money;
    NSString *_reg_time;
    NSString *_numberID;
    NSString *_location;
    NSString *_locDescription;
    NSString *_photoID;
    NSString *_desc;
    NSString *_photoTime;
}
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *userID;
@property (nonatomic, retain) NSString *sex;
@property (nonatomic, retain) NSString *activity;
@property (nonatomic, retain) NSString *approve_flag;
@property (nonatomic, retain) NSString *article_count;
@property (nonatomic, retain) NSString *article_today_count;
@property (nonatomic, retain) NSString *birthday;
@property (nonatomic, retain) NSString *close_flag;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *experience;
@property (nonatomic, retain) NSString *follow_club_count;
@property (nonatomic, retain) NSString *follow_me_count;
@property (nonatomic, retain) NSString *i_follow_count;
@property (nonatomic, retain) NSString *inclub_count;
@property (nonatomic, retain) NSString *level;
@property (nonatomic, retain) NSString *money;
@property (nonatomic, retain) NSString *reg_time;
@property (nonatomic, retain) NSString *numberID;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *locDescription;
@property (nonatomic, retain) NSString *photoID;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *photoTime;

- (id)init;
- (void)clearUserInfo;

@end
