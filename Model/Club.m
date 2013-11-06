//
//  Club.m
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//
#import "Club.h"

@implementation Club

@synthesize ID,name,desc,memberCount,type, followCount,category,logoURL,position,distance,creator, createTM,lastactiveTime,shareCount,qrText, topicCount, articleCount, collectCount, browseCount,stickyCount,goodArticleCount, maxMemberCount,hardWorkDegree, starLevel,activeDegree,admin,viceAdmins,userType,friendClubs,followThisClub,memberList,media,applyjudge,friendClubCount,isClosed,mediaInfo,picTime;

-(id)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.ID = [dictionary objectForKey:KEY_ROW_KEY];
            self.name = [dictionary objectForKey:KEY_NAME];
            self.desc = [dictionary objectForKey:KEY_DESC];
            self.type = [[dictionary objectForKey:@"openType"] intValue];
            self.category = [dictionary objectForKey:KEY_CATEGORY];
            if ([category intValue]>=[myConstants.clubCategory count]) {
                self.category = @"0";
            }
            self.userType = [[dictionary objectForKey:KEY_MEMBER_TYPE] intValue];
            self.logoURL = [dictionary objectForKey:KEY_LOGO];
            self.distance = [Utility getDistanceString:[dictionary objectForKey:KEY_LOCATION]];
            self.creator = [dictionary objectForKey:KEY_CREATOR];
            self.createTM = [Utility getDate:[dictionary objectForKey:KEY_CREATE_TIME]];
            self.lastactiveTime = [dictionary objectForKey:KEY_LAST_ACTIVE_TIME];
            self.qrText = [dictionary objectForKey:KEY_QR];
            self.memberCount = [dictionary objectForKey:KEY_MEMBER_COUNT];
            self.followCount = [dictionary objectForKey:KEY_FOLLOW_COUNT];
            self.shareCount = [dictionary objectForKey:KEY_SHARE_COUNT];
            self.topicCount = [dictionary objectForKey:KEY_TOPIC_COUNT];
            self.articleCount = [dictionary objectForKey:KEY_ARTICLE_COUNT];
            self.collectCount = [dictionary objectForKey:KEY_COLLECT_COUNT];
            self.browseCount = [dictionary objectForKey:KEY_BROWSE_COUNT];
            self.stickyCount = [dictionary objectForKey:KEY_STICKY_COUNT];
            self.goodArticleCount = [dictionary objectForKey:KEY_GOOD_ART_COUNT];
            self.maxMemberCount = [dictionary objectForKey:KEY_MAX_MEM_COUNT];
            self.starLevel = [dictionary objectForKey:KEY_STARLEVEL];
            self.hardWorkDegree = [dictionary objectForKey:KEY_HARDWORK_DEGREE];
            self.activeDegree = [dictionary objectForKey:KEY_ACTIVE_DEGREE];
            self.viceAdmins = [dictionary objectForKey:KEY_VICE_ADMINS];
            self.friendClubCount = [dictionary objectForKey:KEY_FRIENDCLUB_NUM];
            self.picTime = [dictionary objectForKey:KEY_PIC_TIME];
            if ([[dictionary allKeys] containsObject:@"isAdopted"]) {
                self.isAdopted = [dictionary objectForKey:@"isAdopted"];
            }
            //        self.friendClubs = [dictionary objectForKey:KEY_FRIEND_CLUBS];
            //TO DO
        }
    }
    return self;
}

-(void)refreshClubDataWithDic:(NSDictionary *)dictionary{
    self.name = [dictionary objectForKey:KEY_NAME];
    self.desc = [dictionary objectForKey:KEY_DESC];
    self.type = [[dictionary objectForKey:@"openType"] intValue];
    self.category = [dictionary objectForKey:KEY_CATEGORY];
    if ([category intValue]>=[myConstants.clubCategory count]) {
        self.category = @"0";
    }
    self.logoURL = [dictionary objectForKey:KEY_LOGO];
    self.distance = [Utility getDistanceString:[dictionary objectForKey:KEY_LOCATION]];
    self.creator = [dictionary objectForKey:KEY_CREATOR];
    self.createTM = [Utility getDate:[dictionary objectForKey:KEY_CREATE_TIME]];
    self.lastactiveTime = [dictionary objectForKey:KEY_LAST_ACTIVE_TIME];
    self.qrText = [dictionary objectForKey:KEY_QR];
    self.memberCount = [dictionary objectForKey:KEY_MEMBER_COUNT];
    self.followCount = [dictionary objectForKey:KEY_FOLLOW_COUNT];
    self.shareCount = [dictionary objectForKey:KEY_SHARE_COUNT];
    self.topicCount = [dictionary objectForKey:KEY_TOPIC_COUNT];
    self.articleCount = [dictionary objectForKey:KEY_ARTICLE_COUNT];
    self.collectCount = [dictionary objectForKey:KEY_COLLECT_COUNT];
    
    self.browseCount = [dictionary objectForKey:KEY_BROWSE_COUNT];
    self.stickyCount = [dictionary objectForKey:KEY_STICKY_COUNT];
    self.goodArticleCount = [dictionary objectForKey:KEY_GOOD_ART_COUNT];
    self.maxMemberCount = [dictionary objectForKey:KEY_MAX_MEM_COUNT];
    self.starLevel = [dictionary objectForKey:KEY_STARLEVEL];
    self.picTime = [dictionary objectForKey:KEY_PIC_TIME];
//    self.hardWorkDegree = [Utility getStarLevel:[dictionary objectForKey:KEY_HARDWORK_DEGREE]];
    self.hardWorkDegree = [dictionary objectForKey:KEY_HARDWORK_DEGREE];
//    self.activeDegree = [Utility getStarLevel:[dictionary objectForKey:KEY_ACTIVE_DEGREE]];
    self.activeDegree = [dictionary objectForKey:KEY_ACTIVE_DEGREE];
    //    self.viceAdmins = [dictionary objectForKey:KEY_VICE_ADMINS];
    self.friendClubCount = [dictionary objectForKey:KEY_FRIENDCLUB_NUM];
    if ([[dictionary allKeys] containsObject:@"isAdopted"]) {
        self.isAdopted = [dictionary objectForKey:@"isAdopted"];
    }
    //        self.friendClubs = [dictionary objectForKey:KEY_FRIEND_CLUBS];
    //TO DO
}

-(void)clearClubData{
    self.name = nil;
    self.desc = nil;
    self.type = 0;
    self.category = nil;
    self.logoURL = nil;
    //  self.distance = nil;
    self.creator = nil;
    self.createTM = nil;
    self.lastactiveTime = nil;
    self.qrText = nil;
    self.memberCount = nil;
    self.followCount = nil;
    self.shareCount = nil;
    self.topicCount = nil;
    self.articleCount = nil;
    self.collectCount = nil;
    self.browseCount = nil;
    self.stickyCount = nil;
    self.goodArticleCount = nil;
    self.maxMemberCount = nil;
    self.starLevel = nil;
    self.hardWorkDegree = nil;
    self.activeDegree = nil;
    self.friendClubCount = nil;
    
    //self.friendClubs = [dictionary objectForKey:KEY_FRIEND_CLUBS];
}

-(void)print{
    //    DLog(@"俱乐部:Club==>ID:%@ name:%@ desc:%@ type:%@ category:%@ logoURL:%@ distance:%@ creator:%@ createTM:%@ recentActiveTM:%@ qrText:%@ memberCount:%@ followCount:%@ shareCount:%@ topicCount:%@ articleCount:%@ collectCount:%@ browseCount:%@ stickyCount:%@ goodArticleCount:%@ maxMemberCount:%@ starLevel:%@ hardWorkDegre:%@ activeDegree:%@ admin:%@ viceAdmins:%@",
    //          ID,name,desc,type,category,logoURL,distance,creator,createTM,recentActiveTM,qrText,memberCount,followCount,shareCount,topicCount,articleCount,collectCount,browseCount,stickyCount,goodArticleCount,maxMemberCount,starLevel,hardWorkDegree,activeDegree,admin,viceAdmins);
}
@end
