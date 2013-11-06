//
//  ChatMessage.m
//  WeClub
//
//  Created by Archer on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChatMessage.h"
#import "ChatFriend.h"


@implementation ChatMessage

@dynamic date;          //发送时间
@dynamic type;          //本人发送或他人发送标示
@dynamic text;          //发送文字信息
@dynamic dataType;      //数据类型：TYPE_TEXT文字信息 TYPE_PIC图片 TYPE_VOICE声音信息 TYPE_VIDEO视频信息 TYPE_LOC位置信息
@dynamic data;          //发送数据内容
@dynamic urlString;     //发送数据的网络地址
@dynamic length;        //发送数据的长度
@dynamic needToPost;    //发送数据是否需要上传标示
@dynamic msgToPost;     //发送到的用户信息
@dynamic requestIndex;  //发送请求的下标
@dynamic master;        //发送的用户信息
@dynamic mid;           //发送时间标示（本标示做为数据是否发送成功，若成功则至0）
@dynamic messageState;  //信息发送状态
@dynamic isNewMessage;  //判断是否为未读新信息

@end