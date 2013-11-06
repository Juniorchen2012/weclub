//
//  CharMessageProxy.h
//  WeClub
//
//  Created by mitbbs on 13-8-20.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSBubbleData.h"
#import "MosquittoClient.h"
#import "MsgResender.h"
#import "MixedCoding.h"
#import "RequestQueue.h"

//文字信息最大字符数
#define MAXTEXTMESSAGELENGTH 1000

//信息发送状态
#define MESSAGE_SEND_SUCCEED @"1"   //发送成功
#define MESSAGE_SEND_FAILED @"-1"   //发送失败
#define MESSAGE_SEND_SENDING @"0"   //发送中

//信息类型
#define CHAT_TEXT_TYPE 1            //文字表情
#define CHAT_VOICE_TYPE 2           //声音
#define CHAT_PICTURE_TYPE 3         //图片
#define CHAT_VIDEO_TYPE 4           //视频
#define CHAT_LOCATION_TYPE 5        //位置
#define CHAT_SYSTEM_TYPE 6          //系统信息

//日志状态
#define MQTT_SHOW_LOG @1            //是否查看信息交互的日志的日志
#define CHAT_TEXT_SHOW_LOG @1       //是否查看发送文字表情的日志
#define CHAT_VOICE_SHOW_LOG @1      //是否查看发送声音的日志
#define CHAT_PICTURE_SHOW_LOG @1    //是否查看发送图片的日志
#define CHAT_VIDEO_SHOW_LOG @1      //是否查看发送视频的日志
#define CHAT_LOCATION_SHOW_LOG @1   //是否查看发送位置的日志

//错误信息
#define CHAT_ERR_INVAL @"参数不合法"

@protocol ChatMessageDelegate <NSObject>

@optional
//开始发送聊天信息的回调函数
- (void)chatMessageRequestStarted:(id)requestInfo;
//发送聊天信息结束时的回调函数
- (void)chatMessageRequestFinished:(id)requestInfo;
//发送聊天信息失败时的回调函数
- (void)chatMessageRequestFailed:(id)requestInfo;
//发送过程中的回调函数
- (void)chatMessageRequest:(id)request totalSendBytes:(long long)totalBytes didSendBytes:(long long)bytes;
@end

@interface ChatMessageProxy : NSObject <ASIHTTPRequestDelegate,ASIProgressDelegate,MosquittoClientDelegate>
{
    id <ChatMessageDelegate> chatMessageDelegate;
    
    MosquittoClient *client;            //文字、语音和位置发送接口
    ASIFormDataRequest *_request;       //图片和视频发送接口
    
    NSInteger countOfSendMessages;
    NSMutableDictionary *didSendMessagesIdDictionary;
    
}

+ (ChatMessageProxy *)sharedChatMessageProxy;

#pragma mark - 发送数据
//发送文字信息
- (NSBubbleData *)sentTextMessage:(NSString *)strMessage toFriend:(ChatFriend *)chatFriend;
//发送图片信息
- (NSBubbleData *)sentPicMessage:(NSString *)strFilePath toFriend:(ChatFriend *)chatFriend;
//发送音频信息
- (NSBubbleData *)sentVoiceMessage:(NSString *)strFilePath toFriend:(ChatFriend *)chatFriend;
//发送视频信息
- (NSBubbleData *)sentVideoMessage:(NSString *)strFilePath toFriend:(ChatFriend *)chatFriend;
//发送位置信息
- (NSBubbleData *)sentLocationMessage:(NSDictionary *)locationInfoDic toFriend:(ChatFriend *)chatFriend;
#pragma mark - 发送数据反馈

#pragma mark - 数据处理
//获取文字信息发送数组
- (NSDictionary *)getTextMessageDic:(NSString *)strMessage  toFriend:(ChatFriend *)chatFriend;
@end
