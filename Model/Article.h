//
//  TopicArticle.h
//  WeClub
//
//  Created by chao_mit on 13-1-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header.h"

@interface Article : NSObject
{
    NSString *rowKey;//文章rowKey
    NSString *replyRowkey;//回复文章的rowKey
    NSString *subjectRowKey;//主题文章的rowKey
    NSString *articleID;//文章ID
    NSString *userName;//发文用户名
    NSString *postTime;//发文时间
    NSString *distance;//距离
    NSString *avatarURL;//头像
    NSString *content;//文章内容
    NSString *replyNO;//回复序号
    NSString *articleLocation;//发文位置
    
    NSString *replyCount;//回复数
    NSString *browseCount;//浏览数
    NSString *collectCount;//收藏数
    NSString *shareCount;//分享数
    NSString *followCount;//收藏数
    NSArray *media;//展示内容
    NSDictionary *mediaInfo;//附件信息
    NSString *articleStyle;//文章样式
    
    int isDigest;//置顶文章标记
    int isOnTop;//精华文章标记
    int followtheArticleFlag;//关注文章标记
    NSString *articleClubID;//文章所在俱乐部的ID
    NSString *articleClubName;//文章所在俱乐部名称

    Article *repliedArticle;//被回复文章
}
@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *postTime;
@property(nonatomic, copy) NSString *distance;
@property(nonatomic, copy) NSString *avatarURL;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSString *replyCount;
@property(nonatomic, copy) NSString *followCount;
@property(nonatomic, copy) NSString *browseCount;
@property(nonatomic, copy) NSString *collectCount;
@property(nonatomic, copy) NSString *shareCount;
@property(nonatomic, copy) NSString *articleStyle;
@property(nonatomic, copy) NSString *articleID;
@property(nonatomic, copy) NSDictionary *mediaInfo;
@property(nonatomic, copy) NSString *rowKey;
@property(nonatomic, copy) NSString *articleClubID;
@property(nonatomic, copy) NSString *articleClubName;
@property(nonatomic, copy) NSString *replyRowkey;
@property(nonatomic, copy) NSString *subjectRowKey;
@property(nonatomic, copy) NSString *articleLocation;
@property(nonatomic, copy) NSString *replyNO;
@property(nonatomic, retain) NSArray *media;
@property(nonatomic, assign) int isDigest;//精华
@property(nonatomic, assign) int isOnTop;//置顶
@property(nonatomic, assign) int followtheArticleFlag;//置顶

@property(nonatomic, retain) Article *repliedArticle;
-(id)initWithDictionary:(NSDictionary *)dictionary;
-(void)refreshArticleDataWithDic:(NSDictionary *)dictionary;
- (void)print;
@end
