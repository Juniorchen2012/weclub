//
//  Request.m
//  WeClub
//
//  Created by mitbbs on 13-8-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "Request.h"
#import "Header.h"

@implementation Request

- (id)init
{
    self = [super init];
    if (self) {
        rp = [[RequestProxy alloc]init];
    }
    return self;
}

-(void)cancelRequest{
    [rp cancel];
}
//获取用户类型
-(void)getUserType:(NSString *)clubID withDelegate:(id)delegate{
    rp.delegate = delegate;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:clubID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
}

//获取基本信息
-(void)getBaseInfo:(NSString *)clubID withDelegate:(id)delegate{
    rp.delegate = delegate;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    [dic setValue:clubID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_CLUB_GET_BASICINFO andData:nil];
}

-(void)getBaseInfoByName:(NSString *)clubName withDelegate:(id)delegate{
    rp.delegate = delegate;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:clubName forKey:@"clubname"];
    [rp sendDictionary:dic andURL:URL_CLUB_SEARCH_BASEINFO_BY_NAME andData:nil];
}

//获取版主版副
-(void)getModerator:(NSString *)clubID withDelegate:(id)delegate{
    rp.delegate = delegate;
    NSMutableDictionary *postDic = [[NSMutableDictionary alloc]init];
    [postDic setValue:clubID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:postDic andURL:URL_CLUB_GET_ADMINS andData:nil];
}

//获取展示窗口请求
-(void)getDisplayWindows:(NSString *)clubID withDelegate:(id)delegate{
    rp.delegate = delegate;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:clubID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_CLUB_GET_DISPLAY_WINDOW andData:nil];
}

//增加伪币
-(void)addCoin{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"100000" forKey:@"money"];
    [rp sendDictionary:dic andURL:REQUEST_URL_CHANGEMAININFO andData:nil];
}

//获取友情俱乐部请求
-(void)getFriendClub:(NSString *)clubID withStartKeystring:(NSString *)startkey withDelegate:(id)delegate{
    rp.delegate = delegate;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:startkey forKey:KEY_STARTKEY];
    [dic setValue:clubID forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:@"1000" forKey:KEY_PAGESIZE];
    [rp sendDictionary:dic andURL:URL_CLUB_GET_FRIENTCLUB andData:nil];
}

//获取伪币数
-(void)checkMoneyWithDelegate:(id)delegate{
    rp.delegate = delegate;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:myAccountUser.numberID forKey:@"numberid"];
    [rp sendDictionary:dic andURL:URL_USER_GET_MONEY andData:nil];
}

@end
