//
//  CharMessageProxy.m
//  WeClub
//
//  本类负责聊天信息的交互
//
//  Created by mitbbs on 13-8-20.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChatMessageProxy.h"

@implementation ChatMessageProxy

SYNTHESIZE_SINGLETON_FOR_CLASS(ChatMessageProxy);

- (id)init{
    self = [super init];
    if (self) {
        //初始化MQTT连接（仅发送聊天信息和接受聊天信息的反馈信息）
        AccountUser *user = [AccountUser getSingleton];
        client = [[MosquittoClient alloc] initWithClientId:user.numberID];
        client.delegate = self;
        client.username = MQTTUserName;
        client.password = MQTTPassWord;
        client.host = MQTTHost;
        client.port = MQTTPort;
        [self showLog:@"MQTT服务器状态更新：正在连接...." logType:CHAT_SYSTEM_TYPE];
        [client connect];
        
        //初始化参数
        countOfSendMessages = 0;    //总共发送消息的计数
        didSendMessagesIdDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - 发送数据

/*  
 * 发送文字信息（包括表情信息）
 * 参数：
 *      strMessage      文字信息内容
 *      chatFriend      发送至的好友信息
 */
- (NSBubbleData *)sentTextMessage:(NSString *)strMessage toFriend:(ChatFriend *)chatFriend{
    NSBubbleData *messageBubbleData = nil;
    //获取发送所用JSONString
    NSDictionary *textMessageDic = [self getTextMessageDic:strMessage toFriend:chatFriend];
    
    //初始化BubbleData
    messageBubbleData = [[NSBubbleData alloc] initWithText:strMessage andDate:[NSDate date] andType:BubbleTypeMine andData:nil withDataType:TYPE_TEXT];
    //更新信息状态
    messageBubbleData.messageState = BubbleMessageNew;
    //获取信息的MID
    NSString *mid = [[MsgResender sharedInstance] genMySendId];
    messageBubbleData.mid = mid;
    //发送数据
    [self postTextMessage:messageBubbleData textMessageDic:textMessageDic toFriend:chatFriend];
    
    return messageBubbleData;
}

/*
 * 发送音频信息
 * 参数：
 *      strFilePath     音频文件路径
 *      chatFriend      发送至的好友信息
 */
- (NSBubbleData *)sentVoiceMessage:(NSString *)strFilePath toFriend:(ChatFriend *)chatFriend{
    NSBubbleData *messageBubbleData = nil;
    //获取发送所用JSONString
    NSDictionary *voiceMessageDic = [self getVoiceMessageDic:strFilePath toFriend:chatFriend];
    
    //初始化BubbleData
    messageBubbleData = [[NSBubbleData alloc] initWithText:strFilePath andDate:[NSDate date] andType:BubbleTypeMine andData:[voiceMessageDic objectForKey:@"data"] withDataType:TYPE_VOICE];
    //获取信息的MID
    NSString *mid = [[MsgResender sharedInstance] genMySendId];
    messageBubbleData.mid = mid;
    //更新信息发送状态
    messageBubbleData.messageState = BubbleMessageNew;
    //发送数据
    [self postVoiceMessage:messageBubbleData voiceMessageDic:voiceMessageDic toFriend:chatFriend];
    
    return messageBubbleData;
}

/*
 * 发送图片信息
 * 参数：
 *      strFilePath     图片文件路径
 *      chatFriend      发送至的好友信息
 */
- (NSBubbleData *)sentPicMessage:(NSString *)strFilePath toFriend:(ChatFriend *)chatFriend{
    NSBubbleData *messageBubbleData = nil;
    //获取发送所用JSONString
    NSDictionary *picMessageDic = [self getPicMessageDic:strFilePath toFriend:chatFriend];
    
    //生成图片的缩略图
    UIImage *oldImg = [UIImage imageWithContentsOfFile:strFilePath];
    CGSize thumbSize = [Utility calSaveThumbSize:oldImg.size];
    UIGraphicsBeginImageContext(thumbSize);
    [oldImg drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *thumbData = UIImageJPEGRepresentation(newImg, 0.5);
    
    //初始化BubbleData
    messageBubbleData = [[NSBubbleData alloc] initWithText:strFilePath andDate:[NSDate date] andType:BubbleTypeMine andData:thumbData withDataType:TYPE_PIC];
    //获取信息的MID
    NSString *mid = [[MsgResender sharedInstance] genMySendId];
    messageBubbleData.mid = mid;
    //更新信息发送状态
    messageBubbleData.messageState = BubbleMessageNew;
    //发送数据
    [self postPictureMessage:messageBubbleData picMessageDic:picMessageDic toFriend:chatFriend];
    
    return messageBubbleData;
}

/*
 * 发送视频信息
 * 参数：
 *      strFilePath     音频文件路径
 *      chatFriend      发送至的好友信息
 */
- (NSBubbleData *)sentVideoMessage:(NSString *)strFilePath toFriend:(ChatFriend *)chatFriend{
    NSBubbleData *messageBubbleData = nil;
    //获取发送所用JSONString
    NSDictionary *videoMessageDic = [self getVideoMessageDic:strFilePath toFriend:chatFriend];
    
    //生成视频缩略图
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:strFilePath]];
    player.shouldAutoplay = NO;
    UIImage *img = [player thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];
    [player stop];
    player = nil;
    CGSize thumbSize = [Utility calSaveThumbSize:img.size];
    UIGraphicsBeginImageContext(CGSizeMake(thumbSize.width, thumbSize.height));
    [img drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *newThumb = UIImageJPEGRepresentation(newImg, 0.3);
    
    //初始化BubbleData
    messageBubbleData = [[NSBubbleData alloc] initWithText:strFilePath andDate:[NSDate date] andType:BubbleTypeMine andData:newThumb withDataType:TYPE_VIDEO];
    //获取信息的MID
    NSString *mid = [[MsgResender sharedInstance] genMySendId];
    messageBubbleData.mid = mid;
    //更新信息发送状态
    messageBubbleData.messageState = BubbleMessageNew;
    //发送数据
    [self postVideoMessage:messageBubbleData videoMessageDic:videoMessageDic toFriend:chatFriend];
    
    return messageBubbleData;
}

/*
 * 发送位置信息
 * 参数：
 *      locationInfoDic 位置信息
 *      chatFriend      发送至的好友信息
 */
- (NSBubbleData *)sentLocationMessage:(NSDictionary *)locationInfoDic toFriend:(ChatFriend *)chatFriend{
    NSBubbleData *messageBubbleData = nil;
    //获取发送所用JSONString
    NSDictionary *locationMessageDic = [self getLocationMessageDic:locationInfoDic toFriend:chatFriend];
    
    //初始化BubbleData
    messageBubbleData = [[NSBubbleData alloc] initWithText:[locationInfoDic JSONString] andDate:[NSDate date] andType:BubbleTypeMine andData:nil withDataType:TYPE_LOC];
    //获取信息的MID
    NSString *mid = [[MsgResender sharedInstance] genMySendId];
    messageBubbleData.mid = mid;
    //更新信息发送状态
    messageBubbleData.messageState = BubbleMessageNew;
    //发送数据
    [self postLocationMessage:messageBubbleData locationMessageDic:locationMessageDic toFriend:chatFriend];
    
    return messageBubbleData;
}

#pragma mark - 数据处理
/* 获取文字信息发送数组
 * json         发送数据
 *          MSG_KEY_TYPE
 *          MSG_KEY_DATE
 *          MSG_KEY_CONTENT
 *          MSG_KEY_FROM
 *          MSG_KEY_TO
 *          MSG_KEY_SESSIONID
 * receiver     接受标识
 */
- (NSDictionary *)getTextMessageDic:(NSString *)strMessage toFriend:(ChatFriend *)chatFriend{
    NSMutableDictionary *dic = [self getBaseMessageDic:strMessage andMessageType:TYPE_TEXT toFriend:chatFriend];
    
    NSString *jsonString = [dic JSONString];
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,[chatFriend friendID] ];
    
    NSDictionary *textMessageDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", nil]];

    return textMessageDic;
}

/* 获取声音信息发送数据
 * json         发送数据
 *          MSG_KEY_TYPE
 *          MSG_KEY_DATE
 *          MSG_KEY_CONTENT
 *          MSG_KEY_FROM
 *          MSG_KEY_TO
 *          MSG_KEY_SESSIONID
 *
 *          MSG_KEY_LENGTH
 * data         发送的音频数据
 * receiver     接受标识
 */
- (NSDictionary *)getVoiceMessageDic:(NSString *)dataFilePath toFriend:(ChatFriend *)chatFriend{
    NSMutableDictionary *dic = [self getBaseMessageDic:@""  andMessageType:TYPE_VOICE toFriend:chatFriend];
    
    //信息长度
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:[[NSData alloc] initWithContentsOfFile:dataFilePath] error:nil];
    [player stop];
    float length = player.duration;
    [dic setObject:[NSNumber numberWithInt:((int)length+1) * 1000] forKey:MSG_KEY_LENGTH];
    
    NSString *jsonString = [dic JSONString];
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,chatFriend.friendID];
    
    NSDictionary *voiceMessageDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, [[NSData alloc] initWithContentsOfFile:dataFilePath], nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", @"data", nil]];
    
    return voiceMessageDic;
}

/* 获取图片信息发送数据
 * json         发送数据
 *          MSG_KEY_TYPE
 *          MSG_KEY_DATE
 *          MSG_KEY_CONTENT
 *          MSG_KEY_FROM
 *          MSG_KEY_TO
 *          MSG_KEY_SESSIONID
 * receiver     接受标识
 */
- (NSDictionary *)getPicMessageDic:(NSString *)dataFilePath toFriend:(ChatFriend *)chatFriend{
    NSMutableDictionary *dic = [self getBaseMessageDic:@""  andMessageType:TYPE_PIC toFriend:chatFriend];
    
    NSString *jsonString = [dic JSONString];
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,chatFriend.friendID];
    
    NSDictionary *picMessageDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, [[NSData alloc] initWithContentsOfFile:dataFilePath], nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", @"data", nil]];
    
    return picMessageDic;
}

/* 获取视频信息发送数据
 * json         发送数据
 *          MSG_KEY_TYPE
 *          MSG_KEY_DATE
 *          MSG_KEY_CONTENT
 *          MSG_KEY_FROM
 *          MSG_KEY_TO
 *          MSG_KEY_SESSIONID
 *
 *          MSG_KEY_LENGTH
 *          MSG_KEY_ORI
 *          MSG_KEY_PHONE
 * receiver     接受标识
 */
- (NSDictionary *)getVideoMessageDic:(NSString *)dataFilePath toFriend:(ChatFriend *)chatFriend{
    NSMutableDictionary *dic = [self getBaseMessageDic:@"" andMessageType:TYPE_VIDEO toFriend:chatFriend];
    
    //信息长度
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:dataFilePath] options:nil];
    int durtionTime = asset.duration.value/asset.duration.timescale;
    int voiceLengthTime = durtionTime<=0 ? 1 : durtionTime;
    [dic setObject:[NSNumber numberWithInt:voiceLengthTime] forKey:MSG_KEY_LENGTH];
    
    //获取视频方向
    int rotateAngle = 0;
    NSArray *arr = [asset tracks];
    NSLog(@"arr length :%d",[arr count]);
    if ([arr count] != 0) {
        for (AVAssetTrack *track in arr) {
            CGAffineTransform m = track.preferredTransform;
            //判断视频方向
            if (m.a == 0 && m.b == 1 && m.c == -1 && m.d == 0) {
                rotateAngle = -90;
            }else if (m.a == 0 && m.b == -1 && m.c == 1 && m.d == 0) {
                rotateAngle = 90;
            }else if (m.a == -1 && m.b == 0 && m.c == 0 && m.d == -1){
                rotateAngle = 180;
            }
        }
    }
    
    [dic setObject:[NSNumber numberWithInt:rotateAngle] forKey:MSG_KEY_ORI];
    [dic setObject:[NSNumber numberWithInt:1] forKey:MSG_KEY_PHONE];
    
    NSString *jsonString = [dic JSONString];
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,chatFriend.friendID];
    
    NSDictionary *videoMessageDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, [[NSData alloc] initWithContentsOfFile:dataFilePath], nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", @"data", nil]];
    
    return videoMessageDic;
}

/* 获取位置信息发送数据
 * json         发送数据
 *          MSG_KEY_TYPE
 *          MSG_KEY_DATE
 *          MSG_KEY_CONTENT
 *          MSG_KEY_FROM
 *          MSG_KEY_TO
 *          MSG_KEY_SESSIONID
 *
 *          MSG_KEY_LATITUDE
 *          MSG_KEY_LONGITUDE
 * receiver     接受标识
 */
- (NSDictionary *)getLocationMessageDic:(NSDictionary *)locationInfoDic toFriend:(ChatFriend *)chatFriend{
    NSMutableDictionary *dic = [self getBaseMessageDic:[locationInfoDic objectForKey:LOC_DISCRIPTION] andMessageType:TYPE_LOC toFriend:chatFriend];
    
    [dic setObject:[locationInfoDic objectForKey:LOC_LATITUDE] forKey:MSG_KEY_LATITUDE];
    [dic setObject:[locationInfoDic objectForKey:LOC_LONGITUDE] forKey:MSG_KEY_LONGITUDE];
    
    NSString *jsonString = [dic JSONString];
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,chatFriend.friendID];
    
    NSDictionary *locationMessageDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", nil]];
    
    return locationMessageDic;
}

/* 获取发送数据基础信息
 * json         发送数据
 *          MSG_KEY_TYPE
 *          MSG_KEY_DATE
 *          MSG_KEY_CONTENT
 *          MSG_KEY_FROM
 *          MSG_KEY_TO
 *          MSG_KEY_SESSIONID
 * receiver     接受标识
 */
- (NSMutableDictionary *)getBaseMessageDic:(NSString *)strMessage andMessageType:(int)messageType toFriend:(ChatFriend *)chatFriend{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    //发送类型
    [dic setObject:[NSNumber numberWithInt:messageType] forKey:MSG_KEY_TYPE];
    //发送日期
    [dic setObject:[NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]] forKey:MSG_KEY_DATE];
    //发送内容
    [dic setObject:strMessage forKey:MSG_KEY_CONTENT];
    //发送人
    [dic setObject:[AccountUser getSingleton].numberID forKey:MSG_KEY_FROM];
    //接收人
    [dic setObject:chatFriend.friendID forKey:MSG_KEY_TO];
    //Session
    AccountUser *user = [AccountUser getSingleton];
    NSString *sessionid = user.cookie.value;
    if (sessionid != nil && [sessionid isKindOfClass:[NSString class]]) {
        [dic setObject:sessionid forKey:MSG_KEY_SESSIONID];
    }
    return dic;
}

#pragma mark - 异步发送数据

//发送文字聊天信息
- (NSInteger)postTextMessage:(NSBubbleData *)chatBubbleData textMessageDic:(NSDictionary *)textMessageDic toFriend:(ChatFriend *)chatFriend{
    //判断当前信息是否为新的信息，若为新的则先存储
    if (chatBubbleData.messageState == BubbleMessageNew) {
        [[MsgResender sharedInstance] retainMessage:textMessageDic Mid:chatBubbleData.mid];
    }
    
    //存储数据
    [self coreDataSave:chatBubbleData toFriend:chatFriend];
    //修改字符串的字符集为UTF-8
    NSData *dataToSend = [MixedCoding encoding:[textMessageDic objectForKey:@"json"] andData:nil];
    
    //发送数据
    [client publishData:dataToSend toTopic:[textMessageDic objectForKey:@"receiver"] withQos:1 retain:NO];
    [self showLog:@"MQTT发送消息状态更新：正在发送消息...." logType:CHAT_SYSTEM_TYPE];
    
    return 0;
}

//发送音频聊天信息
- (NSInteger)postVoiceMessage:(NSBubbleData *)chatBubbleData voiceMessageDic:(NSDictionary *)voiceMessageDic toFriend:(ChatFriend *)chatFriend{
    //判断当前信息是否为新的信息，若为新的则先存储
    if (chatBubbleData.messageState == BubbleMessageNew) {
        [[MsgResender sharedInstance] retainMessage:voiceMessageDic Mid:chatBubbleData.mid];
    }
    
    //存储数据
    [self coreDataSave:chatBubbleData toFriend:chatFriend];
    //修改字符串的字符集为UTF-8并整合音频数据
    NSData *dataToSend = [MixedCoding encoding:[voiceMessageDic objectForKey:@"json"] andData:chatBubbleData.data];
    //发送数据
    [client publishData:dataToSend toTopic:[voiceMessageDic objectForKey:@"receiver"] withQos:1 retain:NO];
    [self showLog:@"MQTT发送消息状态更新：正在发送消息...." logType:CHAT_SYSTEM_TYPE];
    
    return 0;
}

//发送图片信息
- (NSInteger)postPictureMessage:(NSBubbleData *)chatBubbleData picMessageDic:(NSDictionary *)picMessageDic toFriend:(ChatFriend *)chatFriend{
    //判断当前信息是否为新的信息，若为新的则先存储
    if (chatBubbleData.mid) {
        [[MsgResender sharedInstance] retainMessage:picMessageDic Mid:chatBubbleData.mid];
    }

    //发送数据
    //根据url初始化请求
    NSURL *url = [NSURL URLWithString:UPLOADSERVER];
    _request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    NSData *data = [NSData dataWithContentsOfFile:chatBubbleData.text];
    [_request setData:data withFileName:@"image" andContentType:@"image/jpeg" forKey:@"microfile"];
    [_request setPostValue:chatBubbleData.msgToPost forKey:@"message"];
    _request.username = [[NSString alloc] initWithFormat:@"%d", chatBubbleData.dataType];
    //设置发送请求头部
    [_request buildRequestHeaders];
    
    _request.delegate = self;
    _request.uploadProgressDelegate = self;
    
    //获取发送请求的下标（为删除request和判断request是否成功做准备）
    chatBubbleData.requestIndex = [[RequestQueue sharedRequestQueue] addRequest:_request];
    chatBubbleData.msgToPost = [picMessageDic objectForKey:@"json"];
    chatBubbleData.needToPost = NO;
    chatBubbleData.messageState = BubbleMessageSeading;
    
    //存储数据
    [self coreDataSave:chatBubbleData toFriend:chatFriend];
    
    //开始异步发送信息
    [_request startAsynchronous];
    
    [self showLog:@"MQTT发送消息状态更新：正在发送消息...." logType:CHAT_SYSTEM_TYPE];
    
    return 0;
}

//发送视频信息
- (NSInteger)postVideoMessage:(NSBubbleData *)chatBubbleData videoMessageDic:(NSDictionary *)videoMessageDic toFriend:(ChatFriend *)chatFriend{
    //判断当前信息是否为新的信息，若为新的则先存储
    if (chatBubbleData.mid) {
        [[MsgResender sharedInstance] retainMessage:videoMessageDic Mid:chatBubbleData.mid];
    }
    
    //发送数据
    //根据url初始化请求
    NSURL *url = [NSURL URLWithString:UPLOADSERVER];
    _request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    NSData *data = [NSData dataWithContentsOfFile:chatBubbleData.text];
    [_request setData:data withFileName:@"video" andContentType:@"video/mpeg" forKey:@"microfile"];
    [_request setPostValue:chatBubbleData.msgToPost forKey:@"message"];
    _request.username = [[NSString alloc] initWithFormat:@"%d", chatBubbleData.dataType];
    //设置发送请求头部
    [_request buildRequestHeaders];
    
    _request.delegate = self;
    _request.uploadProgressDelegate = self;
    
    //获取发送请求的下标（为删除request和判断request是否成功做准备）
    chatBubbleData.requestIndex = [[RequestQueue sharedRequestQueue] addRequest:_request];
    chatBubbleData.msgToPost = [videoMessageDic objectForKey:@"json"];
    chatBubbleData.needToPost = NO;
    chatBubbleData.messageState = BubbleMessageSeading;
    
    //存储数据
    [self coreDataSave:chatBubbleData toFriend:chatFriend];
    
    //开始异步发送信息
    [_request startAsynchronous];
    
    [self showLog:@"MQTT发送消息状态更新：正在发送消息...." logType:CHAT_SYSTEM_TYPE];
    
    return 0;
}

//发送位置信息
- (NSInteger)postLocationMessage:(NSBubbleData *)chatBubbleData locationMessageDic:(NSDictionary *)locationMessageDic toFriend:(ChatFriend *)chatFriend{
    //判断当前信息是否为新的信息，若为新的则先存储
    if (chatBubbleData.mid) {
        [[MsgResender sharedInstance] retainMessage:locationMessageDic Mid:chatBubbleData.mid];
    }
    
    //存储数据
    [self coreDataSave:chatBubbleData toFriend:chatFriend];
    //修改字符串的字符集为UTF-8并整合音频数据
    NSData *dataToSend = [MixedCoding encoding:[locationMessageDic objectForKey:@"json"] andData:nil];
    //发送数据
    [client publishData:dataToSend toTopic:[locationMessageDic objectForKey:@"receiver"] withQos:1 retain:NO];
    [self showLog:@"MQTT发送消息状态更新：正在发送消息...." logType:CHAT_SYSTEM_TYPE];
    
    return 0;
}

#pragma mark - ASIHTTPDelegate（发送图片、视频和音频信息）
//发送开始时的回调函数
- (void)requestStarted:(ASIHTTPRequest *)request{
    [self showLog:@"ASIHTTP 开始发送数据" logType:CHAT_SYSTEM_TYPE];
    if (chatMessageDelegate) {
        [chatMessageDelegate chatMessageRequestStarted:request];
    }
}
//发送数据时的回调函数（发送数据的百分比）
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
    
    [self showLog:[[NSString alloc] initWithFormat:@"ASIHTTP 已经发送数据 ： %lld  发送百分比 ： %lld/%lld", bytes, request.totalBytesSent, request.postLength] logType:CHAT_SYSTEM_TYPE];
    if (chatMessageDelegate) {
        [chatMessageDelegate chatMessageRequest:request totalSendBytes:request.totalBytesSent didSendBytes:request.postLength];
    }
}
//发送完成时的回调函数
- (void)requestFinished:(ASIHTTPRequest *)request{
    //    NSLog(@"finish total length:%lld",request.contentLength);
    [self showLog:@"ASIHTTP Request已经发送成功" logType:CHAT_SYSTEM_TYPE];
    NSString *response = [request responseString];
    [self showLog:[[NSString alloc] initWithFormat:@"ASIHTTP Request : %@", response] logType:CHAT_SYSTEM_TYPE];
    
    if (chatMessageDelegate) {
        [chatMessageDelegate chatMessageRequestFinished:request];
    }
}
//发送失败时的回调函数
- (void)requestFailed:(ASIHTTPRequest *)request{
    [self showLog:@"ASIHTTP Request发送失败" logType:CHAT_SYSTEM_TYPE];
    
    if (chatMessageDelegate) {
        [chatMessageDelegate chatMessageRequestFailed:request];
    }
}

#pragma mark - MQTTDelegate （发送文字和位置信息）
//MQTT服务器已经连接的回调函数
- (void) didConnect: (NSUInteger)code{
    [self showLog:@"MQTT服务器状态更新：已经连接上...." logType:CHAT_SYSTEM_TYPE];
    
    AccountUser *user = [AccountUser getSingleton];
    user.MQTTconnected = YES;
    [client subscribe:[NSString stringWithFormat:@"%@/%@",MQTTTopicHead,user.numberID] withQos:1];
}
//MQTT服务器已经失去连接的回调函数
- (void) didDisconnect{
    [self showLog:@"MQTT发送消息状态更新：消息已经发送...." logType:CHAT_SYSTEM_TYPE];
}
//信息发送完成后的回调函数
- (void) didPublish: (NSUInteger)messageId{
    NSDictionary *returnMessagesSendInfoDictionary = nil;
    returnMessagesSendInfoDictionary = [self getMessageMID:messageId];
    
    ChatMessage *msg = [[ChatListSaveProxy sharedChatListSaveProxy] getMessageWithText:[returnMessagesSendInfoDictionary objectForKey:@"MessageText"]];
    msg.messageState = BubbleMessageSucceed;
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    
    if (nil != returnMessagesSendInfoDictionary) {
        [chatMessageDelegate chatMessageRequestFinished:returnMessagesSendInfoDictionary];
    }
    else{
        [self errorLog:@"MessageMidSaveError"];
    }
    [self showLog:@"MQTT发送消息状态更新：消息已经发送...." logType:CHAT_SYSTEM_TYPE];
}
//从MQTT服务器上获得数据后的回调函数
- (void) didReceiveData :(NSData *)keyData onTopic:(NSString *)topic{
    [self showLog:[[NSString alloc] initWithFormat:@"MQTT从服务器获得信息 ： %@", topic] logType:CHAT_SYSTEM_TYPE];
}
//从MQTT服务器上获得信息后的回调函数
- (void) didReceiveMessage: (MosquittoMessage*)mosq_msg{
    [self showLog:[[NSString alloc] initWithFormat:@"MQTT从服务器获得信息 : %@", mosq_msg] logType:CHAT_SYSTEM_TYPE];
}
//已经订阅信息后的回调函数
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos{
    [self showLog:[[NSString alloc] initWithFormat:@"MQTT订阅状态更新：已经订阅信息 (%d)", messageId] logType:CHAT_SYSTEM_TYPE];
}
//已经取消订阅信息后的回调函数
- (void) didUnsubscribe: (NSUInteger)messageId{
    [self showLog:[[NSString alloc] initWithFormat:@"MQTT订阅状态更新：已经取消订阅信息 (%d)", messageId] logType:CHAT_SYSTEM_TYPE];
}
//MQTT服务书写日志时的回调函数
- (void) didLog:(NSString *)msg{
    [self showLog:[[NSString alloc] initWithFormat:@"ChatMessageProxy didLog:%@", msg] logType:CHAT_SYSTEM_TYPE];
}


//将新生成的信息存储起来
- (BOOL)saveMsgResender:(NSDictionary *)message andMessage:(NSBubbleData *)bubbleData{
    if (bubbleData.messageState == BubbleMessageNew) {
        return [[MsgResender sharedInstance] retainMessage:message Mid:bubbleData.mid];
    }
    return NO;
}

//解析发送与返回的MQTT信息
- (void)analysisReturnMessage:(NSString *)message{
    
}

#pragma mark - MQTT服务器数据反馈处理
//存储发送数据的Text与JSONString和发送的mosq的Mid
- (BOOL)saveMidToDictionary:(NSString *)strJSONString andMessageText:(NSString *)messageText{
    
    NSInteger mosq_mid = [client getMosq_Mid];
    NSString *strMosqMid = nil;
    if (mosq_mid >= 0) {
        strMosqMid = [[NSString alloc] initWithFormat:@"%d", mosq_mid++];
    }
    else{
        return NO;
    }
    
    NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (!strJSONString || !messageText) {
        return NO;
    }
    [messageDic setObject:strJSONString forKey:@"MessageJson"];
    [messageDic setObject:messageText forKey:@"MessageText"];
    
    [didSendMessagesIdDictionary setObject:messageDic forKey:strMosqMid];
    return YES;
}

//根据MessageID获取发送数据的mid与Text
- (NSMutableDictionary *)getMessageMID:(int)mosqMID{
    if (mosqMID <= 0) {
        return nil;
    }
    NSString *mid = [[NSString alloc] initWithFormat:@"%d", mosqMID];
    NSMutableDictionary *messageDic = [didSendMessagesIdDictionary objectForKey:mid];
    if (nil != messageDic) {
        [didSendMessagesIdDictionary removeObjectForKey:mid];
        return messageDic;
    }
    return nil;
}

- (NSDictionary *)getReturnMessageDic:(NSInteger)messageID andMessageState:(NSBubbleMessageState)messageState{
    NSMutableDictionary *returnMessagesSendInfoDictionary = [[NSMutableDictionary alloc] init];
    NSBubbleData *bubbleData = [didSendMessagesIdDictionary objectForKey:[[NSString alloc] initWithFormat:@"%d", messageID]];
    
    //信息发送类型
    [returnMessagesSendInfoDictionary setObject:[[NSString alloc] initWithFormat:@"%d", [bubbleData type]] forKey:@"MessageType"];
    //信息MID
    [returnMessagesSendInfoDictionary setObject:[self getMessageMID:[[NSString alloc] initWithFormat:@"%d", messageID]] forKey:@"MessageMid"];
    //信息状态
    [returnMessagesSendInfoDictionary setObject:[[NSString alloc] initWithFormat:@"%d", messageState] forKey:@"MessageState"];
    
    if (nil == [returnMessagesSendInfoDictionary objectForKey:@"MessageMid"]) {
        return nil;
    }
    return returnMessagesSendInfoDictionary;
}

#pragma mark - CoreData数据处理
- (void) coreDataSave:(NSBubbleData *)chatBubbleData toFriend:(ChatFriend *)chatFriend{
    //存储数据
    [[ChatListSaveProxy sharedChatListSaveProxy] addMessage:chatBubbleData to:chatFriend];
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
}


#pragma mark - Log
- (void) errorLog:(NSString *)errorLog{
    NSLog(@"ChatMessageProxy %@", errorLog);
}

- (void) showLog:(NSString *)logFormat log:(id)log logType:(int)logType{
    if (!logFormat || !log || !logType) {
        [self errorLog:CHAT_ERR_INVAL];
    }
    [self showLog:[[NSString alloc] initWithFormat:logFormat, log] logType: logType];
}

- (void) showLog:(NSString *)log logType:(int)logType{
    
    if (!log || !logType) {
        [self errorLog:CHAT_ERR_INVAL];
    }
    
    switch (logType) {
        case CHAT_TEXT_TYPE:{
            #ifdef CHAT_TEXT_SHOW_LOG
            NSLog(@"ChatMessageProxy CHAT_TEXT_TYPE :%@", log);
            #endif
            break;
        }
        case CHAT_VOICE_TYPE:{
            #ifdef CHAT_VOICE_SHOW_LOG
            NSLog(@"ChatMessageProxy CHAT_VOICE_TYPE :%@", log);
            #endif
            break;
        }
        case CHAT_PICTURE_TYPE:{
            #ifdef CHAT_PICTURE_SHOW_LOG
            NSLog(@"ChatMessageProxy CHAT_PICTURE_TYPE :%@", log);
            #endif
            break;
        }
        case CHAT_VIDEO_TYPE:{
            #ifdef CHAT_VIDEO_SHOW_LOG
            NSLog(@"ChatMessageProxy CHAT_VIDEO_TYPE :%@", log);
            #endif
            break;
        }
        case CHAT_LOCATION_TYPE:{
            #ifdef CHAT_LOCATION_SHOW_LOG
            NSLog(@"ChatMessageProxy CHAT_LOCATION_TYPE :%@", log);
            #endif
            break;
        }
        case CHAT_SYSTEM_TYPE:{
            #ifdef MQTT_SHOW_LOG
            NSLog(@"ChatMessageProxy CHAT_SYSTEM_TYPE :%@", log);
            #endif
            break;
        }
        default:{
            [self errorLog:CHAT_ERR_INVAL];
            break;
        }
    }
}
@end
