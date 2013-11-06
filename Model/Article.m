//
//  TopicArticle.m
//  WeClub
//
//  Created by chao_mit on 13-1-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "Article.h"

@implementation Article
@synthesize userName,postTime,distance,avatarURL,content,replyCount,browseCount,collectCount,shareCount,media,articleStyle,articleID,rowKey,replyRowkey,repliedArticle,subjectRowKey,isDigest,isOnTop,followtheArticleFlag,articleClubID,articleLocation,articleClubName,followCount,replyNO,mediaInfo;
-(id)initWithDictionary:(NSDictionary *)dictionary;
{
    if (self = [super init]) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.articleID = [dictionary objectForKey:KEY_ID];
            self.userName = [dictionary objectForKey:KEY_AUTHOR];
            self.postTime = [dictionary objectForKey:KEY_POST_TIME];
            self.distance = [Utility getDistanceString:[dictionary objectForKey:@"location"]];
            self.avatarURL = [dictionary objectForKey:KEY_AVATAR];
            self.content = [dictionary objectForKey:KEY_CONTENT];
            if ([[dictionary objectForKey:@"replyNo"] isKindOfClass:[NSString class]]) {
                self.replyNO = [dictionary objectForKey:@"replyNo"];
            }else{
                self.replyNO = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"replyNo"]];
            }
            self.replyCount = [NSString stringWithFormat:@"%@",[dictionary objectForKey:KEY_REPLY_COUNT]];

            if (!replyCount) {
                replyCount = @"0";
            }
            if ([[dictionary objectForKey:KEY_BROWSE_COUNT] isKindOfClass:[NSString class]]) {
                self.browseCount = [dictionary objectForKey:KEY_BROWSE_COUNT];
            }else{
                self.browseCount = [NSString stringWithFormat:@"%@",[dictionary objectForKey:KEY_BROWSE_COUNT]];
            }
            if (!browseCount) {
                browseCount = @"0";
            }
            

            if ([[dictionary objectForKey:KEY_COLLECT_COUNT] isKindOfClass:[NSString class]]) {
                self.collectCount = [dictionary objectForKey:KEY_COLLECT_COUNT];
            }else{
                self.collectCount = [NSString stringWithFormat:@"%@",[dictionary objectForKey:KEY_COLLECT_COUNT]];
            }
            if (!collectCount) {
                collectCount = @"0";
            }
            if ([[dictionary objectForKey:KEY_SHARE_COUNT] isKindOfClass:[NSString class]]) {
                self.shareCount = [dictionary objectForKey:KEY_SHARE_COUNT];
            }else{
                self.shareCount = [NSString stringWithFormat:@"%@",[dictionary objectForKey:KEY_SHARE_COUNT]];
            }
            if (!shareCount) {
                shareCount = @"0";
            }
            
            if ([[dictionary objectForKey:@"followNum"] isKindOfClass:[NSString class]]) {
            self.followCount = [dictionary objectForKey:@"followNum"];

            }else{
                self.followCount = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"followNum"]];
            }

            if (!followCount) {
                followCount = @"0";
            }
            if ([[dictionary objectForKey:KEY_MEDIA] isKindOfClass:[NSArray class]]) {
                self.media = [dictionary objectForKey:KEY_MEDIA];
            }
            self.articleStyle = [dictionary objectForKey:KEY_ARTICLE_STYLE];
            self.subjectRowKey = [dictionary objectForKey:KEY_ARTICLE_SUBJECT_ROW_KEY];
            self.rowKey = [dictionary objectForKey:KEY_ARTICLE_ROW_KEY];
            self.replyRowkey = [dictionary objectForKey:KEY_ARTICLE_REPLY_ROW_KEY];
            self.isDigest = [[dictionary objectForKey:@"isDigest"] intValue];
            self.isOnTop = [[dictionary objectForKey:@"isTop"] intValue];
            self.followtheArticleFlag = [[dictionary objectForKey:KEY_ARTICLE_ISFOLLOW]intValue];
            self.articleClubID = [dictionary objectForKey:@"clubId"];
            self.articleLocation = [dictionary objectForKey:KEY_LOCATION];
            self.articleClubName = [dictionary objectForKey:@"clubName"];
            self.mediaInfo = [dictionary objectForKey:KEY_ATTACHMENT_INFO];
        }
    }
    return self;
}

-(void)refreshArticleDataWithDic:(NSDictionary *)dictionary{
    if ([dictionary objectForKey:KEY_ID]) {
        self.articleID = [dictionary objectForKey:KEY_ID];
    }
    
    if ([dictionary objectForKey:KEY_AUTHOR]) {
        self.userName = [dictionary objectForKey:KEY_AUTHOR];
    }
    if ([dictionary objectForKey:KEY_POST_TIME]) {
        self.postTime = [dictionary objectForKey:KEY_POST_TIME];
    }
    
    if ([dictionary objectForKey:@"location"]) {
        self.distance = [Utility getDistanceString:[dictionary objectForKey:@"location"]];
    }
    self.avatarURL = [dictionary objectForKey:KEY_AVATAR];
    self.content = [dictionary objectForKey:KEY_CONTENT];
    self.replyCount = [dictionary objectForKey:KEY_REPLY_COUNT];
    if (!replyCount) {
        replyCount = @"0";
    }
    self.browseCount = [dictionary objectForKey:KEY_BROWSE_COUNT];
    if (!browseCount) {
        browseCount = @"0";
    }
    self.collectCount = [dictionary objectForKey:KEY_COLLECT_COUNT];
    if (!collectCount) {
        collectCount = @"0";
    }
    self.shareCount = [dictionary objectForKey:KEY_SHARE_COUNT];
    if (!shareCount) {
        shareCount = @"0";
    }
    
    self.followCount = [dictionary objectForKey:@"followNum"];
    if (!followCount) {
        followCount = @"0";
    }
    self.media = [dictionary objectForKey:KEY_MEDIA];
    self.articleStyle = [dictionary objectForKey:KEY_ARTICLE_STYLE];
    self.subjectRowKey = [dictionary objectForKey:KEY_ARTICLE_SUBJECT_ROW_KEY];
    self.rowKey = [dictionary objectForKey:KEY_ARTICLE_ROW_KEY];
    self.replyRowkey = [dictionary objectForKey:KEY_ARTICLE_REPLY_ROW_KEY];
    self.isDigest = [[dictionary objectForKey:@"isDigest"] intValue];
    self.isOnTop = [[dictionary objectForKey:@"isTop"] intValue];
    self.followtheArticleFlag = [[dictionary objectForKey:KEY_ARTICLE_ISFOLLOW]intValue];
    self.articleClubID = [dictionary objectForKey:@"clubId"];
    self.articleLocation = [dictionary objectForKey:KEY_LOCATION];
    self.articleClubName = [dictionary objectForKey:@"clubName"];
    self.mediaInfo = [dictionary objectForKey:KEY_ATTACHMENT_INFO];
    //        self.friendClubs = [dictionary objectForKey:KEY_FRIEND_CLUBS];
    //TO DO
}

-(void)print{
    NSLog(@"\n文章:TopicArticle==>\n userName:%@\n postTime:%@\n distance:%@\n avatar:%@\n content:%@\n replyCount:%@\n browseCount:%@\n collectCount:%@\n shareCount:%@\n media:%@\narticleStyle:%@\narticleRowKey%@\n  replyRowKey%@\nsubjectRowKey%@",userName,postTime,distance,avatarURL,content,replyCount,browseCount,collectCount,shareCount,media,articleStyle,rowKey,replyRowkey,subjectRowKey);
}
@end
