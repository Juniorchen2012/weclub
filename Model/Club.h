//
//  Club.h
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Header.h"

@interface Club : NSObject
{
    NSString * ID;//唯一数字俱乐部号
    NSString * name;//名称
    NSString * desc;//描述
    NSString * picTime;//版标更新时间
    int type;//类型"公开" "私密"
    NSString *isClosed;//俱乐部是否已经关闭
    NSString * category;//俱乐部类别 "风景" "人文"
    NSString * logoURL;//版标
    NSString * position;//位置
    NSString * distance;//距离
    NSString * creator;//创建者
    NSString * createTM;//创建时间
    NSString * lastactiveTime;//最近活动时间
    NSString * qrText;//二维码
    
    //TODO 数目先用nsstring代替int型
    NSString * memberCount;//会员数
    NSString * followCount;//关注数
    NSString * collectCount;//收藏数
    NSString * shareCount;//分享次数
    NSString * topicCount;//主题数
    NSString * articleCount;//文章数
    NSString * browseCount;//浏览次数
    NSString * stickyCount;//置顶数
    NSString * goodArticleCount;//精华区文章数
    NSString * maxMemberCount;//最大会员容量
    NSString * starLevel;//星级
    NSString * hardWorkDegree;//版主勤劳度
    NSString * activeDegree;//活跃度
    NSString * friendClubCount;//友情俱乐部个数
    NSString * isAdopted;//是否被领取
    
//    User *admin;//版主
    NSDictionary *admin;//版主

    NSMutableArray *media;//展示内容
    NSDictionary *mediaInfo;//展示窗口附件信息时间长度
    NSArray *viceAdmins;//版副
    NSMutableArray *friendClubs;//友情俱乐部
    NSMutableArray *memberList;//会员列表
    BOOL applyjudge;//是否已申请该俱乐部
    
    int userType;//当前登陆用户对该俱乐部的权限
    int followThisClub;//是否关注了该俱乐部
}
@property(nonatomic, copy) NSString * ID;
@property(nonatomic, copy) NSString * name;
@property(nonatomic, copy) NSString * desc;
@property(nonatomic, assign) int  type;
@property(nonatomic, copy) NSString * category;
@property(nonatomic, copy) NSString * logoURL;
@property(nonatomic, copy) NSString * position;
@property(nonatomic, copy) NSString * distance;
@property(nonatomic, copy) NSString * creator;
@property(nonatomic, copy) NSDictionary * mediaInfo;
@property(nonatomic, copy) NSString * createTM;
@property(nonatomic, copy) NSString * lastactiveTime;
@property(nonatomic, copy) NSString * qrText;
@property(nonatomic, copy) NSString * friendClubCount;
@property(nonatomic, copy) NSString * memberCount;
@property(nonatomic, copy) NSString * collectCount;
@property(nonatomic, copy) NSString * followCount;
@property(nonatomic, copy) NSString * shareCount;
@property(nonatomic, copy) NSString * topicCount;
@property(nonatomic, copy) NSString * articleCount;
@property(nonatomic, copy) NSString * browseCount;
@property(nonatomic, copy) NSString * stickyCount;
@property(nonatomic, copy) NSString * goodArticleCount;
@property(nonatomic, copy) NSString * maxMemberCount;
@property(nonatomic, copy) NSString * starLevel;
@property(nonatomic, copy) NSString * isClosed;
@property(nonatomic, copy) NSString * picTime;
@property(nonatomic, assign) BOOL applyjudge;
@property(nonatomic, copy) NSString * hardWorkDegree;
@property(nonatomic, copy) NSString * activeDegree;
//@property(nonatomic, copy) User *admin;
@property(nonatomic, retain) NSDictionary *admin;
@property(nonatomic, assign)int userType;
@property(nonatomic, assign)int followThisClub;
@property(nonatomic, retain) NSArray *viceAdmins;
@property(nonatomic, retain) NSMutableArray *media;
@property(nonatomic, retain) NSMutableArray *friendClubs;
@property(nonatomic, retain) NSMutableArray *memberList;
@property(nonatomic, copy) NSString * isAdopted;

-(id)initWithDictionary:(NSDictionary *)dictionary;
-(void)print;
-(void)clearClubData;
-(void)refreshClubDataWithDic:(NSDictionary *)dictionary;

@end
