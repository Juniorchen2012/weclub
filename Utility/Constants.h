//
//  User.h
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
{
    NSArray *urls;
    NSArray *clubNames;
    NSArray *content;
    NSArray *pics;
    
    NSArray *clubCategory;
    NSArray *talkArea;
    NSArray *userNames;
    NSArray *userAvatars;
    NSArray *article_media_pics;
    NSArray *replyArticleContent;
    NSArray *clubTypeNames;
    NSArray *listTypeNames;
    NSArray *articleListNames;
    NSArray *postStyleNames;
    NSArray *userTypeNames;
    NSArray *clubOperateNames;
    NSArray *shareTypeNames;
    NSMutableArray *articleLists;//已发文章的文章列表
    //设置页面
    NSArray *itemNames;
    
    CGFloat screenHeight;
    
    NSMutableArray *searchHistoryItems;//
    
    NSArray *faceImageNames;  //表情字符串
    NSArray *userListArray;   //用户列表选项
    NSArray *reportTypeNames;//举报类型名称,未审批，已审批，已拒绝
    
    //设置页面4数组，一切为了国际化
    NSArray *settingArr1;
    NSArray *settingArr2;
    NSArray *settingArr3;
    NSArray *settingArr4;
    //私聊权限数组
    NSArray *chatSettingArr;
    
    NSDictionary *mainDic;
    NSDictionary *mitBBSDic;//俱乐部字典
    NSArray *mitbbsCategory;//mitbbs的俱乐部分类
    int serverNO;//服务器
    int BARHEIGHT;//ios的navigationconller的view都是占满整个屏幕的
}
@property(nonatomic, retain)NSArray *urls;
@property(nonatomic, retain)NSArray *pics;
@property(nonatomic, retain)NSArray *talkArea;
@property(nonatomic, retain)NSArray *article_media_pics;
@property(nonatomic, retain)NSArray *clubNames;
@property(nonatomic, retain)NSArray *content;
@property(nonatomic, retain)NSArray *userNames;
@property(nonatomic, retain)NSArray *userAvatars;
@property(nonatomic, retain)NSArray *clubTypeNames;
@property(nonatomic, retain)NSArray *listTypeNames;
@property(nonatomic, retain)NSArray *articleListNames;
@property(nonatomic, retain)NSArray *userTypeNames;
@property(nonatomic, retain)NSArray *postStyleNames;
@property(nonatomic, retain)NSArray *replyArticleContent;
@property(nonatomic, retain)NSArray *itemNames;
@property(nonatomic, retain)NSArray *clubOperateNames;
@property(nonatomic, retain)NSArray *clubCategory;
@property(nonatomic, retain)NSMutableArray *articleLists;
@property(nonatomic, retain)NSMutableArray *searchHistoryItems;
@property(nonatomic, assign)CGFloat screenHeight;
@property(nonatomic, retain)NSArray *faceImageNames;
@property(nonatomic, retain)NSArray *shareTypeNames;
@property(nonatomic, retain)NSArray *reportTypeNames;
@property(nonatomic, retain)NSArray *userListArray;
@property(nonatomic, retain)NSArray *settingArr1;
@property(nonatomic, retain)NSArray *settingArr2;
@property(nonatomic, retain)NSArray *settingArr3;
@property(nonatomic, retain)NSArray *settingArr4;
@property(nonatomic, retain)NSArray *chatSettingArr;
@property (nonatomic, retain) NSDictionary *mainDic;
@property (nonatomic, retain) NSDictionary *mitBBSDic;
@property(nonatomic, retain) NSArray * mitbbsCategory;
@property(nonatomic, assign) int serverNO;//服务器
@property(nonatomic, assign) int BARHEIGHT;

+(Constants*)getSingleton;
@end
