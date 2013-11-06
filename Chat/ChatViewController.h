//
//  ChatViewController.h
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

//聊天功能界面，一个聊天对象列表

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "MQTTSession.h"
#import "Constant.h"
#import "SessionPublishDataDelegate.h"
#import "MixedCoding.h"
#import "DetailViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ChatListSaveProxy.h"
#import "ChatFriend.h"
#import "FriendModel.h"
#import "ChatFriendCell.h"
#import "Utility.h"
#import "RequestProxy.h"
#import "MosquittoClient.h"
#import "MosquittoMessage.h"
#import "ZBarSDK.h"
#import "ChatMessageProxy.h"
#import "NoticeManager.h"

@interface ChatViewController : UIViewController<SessionPublishDataDelegate,UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate,RequestProxyDelegate,MosquittoClientDelegate,UIAlertViewDelegate>
{
    MQTTSession *_session;
//    NSMutableArray *_chattingList;
//    NSMutableArray *_detailList;
    NSArray *_friendList;
    UITableView *_tableView;
    DetailViewController *currentDetail;
    RequestProxy *_rp;
    BOOL reconnect;
//    int reconnectCount;
    
    MosquittoClient *_client;
    
    int reconnectTimeA;
    int reconnectTimeB;
    
    NSString *qrText;
    
    UIControl *holeView;
    UIView *titleViews;
    NSMutableArray *_menuItemArray;
    UIButton *cleanChatDetailBtn;
    
    int unLiseningVoice;
}

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIView      *reconnectedView;
@property (nonatomic, strong)DetailViewController *currentDetail;
@property (nonatomic, strong)MosquittoClient *_client;

//连接MQTT
- (void)connectMQTT;
//显示与具体某个好友的聊天记录，跳转到DetailViewController
- (void)showChatDetail:(NSInteger)index;
- (void)alert:(NSString *)msg;
//将收到的消息加入到数据库中，并更新未读等消息
- (void)addUnreadMsg:(NSDictionary *)dic;
//添加聊天好友
- (void)addChatingFriend:(NSNotification *)notification;

- (BOOL)isConnect;

#pragma mark - MQTT Callback methods
- (void)session:(MQTTSession*)sender handleEvent:(MQTTSessionEvent)eventCode;
- (void)session:(MQTTSession*)sender newMessage:(NSData*)data onTopic:(NSString*)topic;

@end
