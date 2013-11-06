//
//  ChatListSaveProxy.h
//  WeClub
//
//  Created by Archer on 13-2-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynthesizeSingleton.h"
#import "ChatFriend.h"
#import "ChatMessage.h"
#import "FriendModel.h"
#import "NSBubbleData.h"

@interface ChatListSaveProxy : NSObject<NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext *context;
    NSFetchedResultsController *results;
}

@property (nonatomic,retain) NSManagedObjectContext *context;
@property (nonatomic,retain) NSFetchedResultsController *results;

+ (ChatListSaveProxy *)sharedChatListSaveProxy;

- (void)addFriend:(FriendModel *)fri;
- (NSArray *)getFriends;
- (ChatFriend *)getFriendByID:(NSString *)ID;

#pragma mark - 删除信息
//删除所有好友，连带将与这个好友的聊天记录全部删除
- (void)removeAllFriend;
//删除指定好友，连带将与这个好友的聊天记录全部删除
- (void)removeFriend:(ChatFriend *)fri;
//删除所有好友的聊天记录聊天记录，不删除好友信息
- (void)removeAllMessages;
//删除指定好友的聊天记录，不删除好友信息
- (void)removeFriendMessages:(ChatFriend *) friend;
//删除指定聊天记录
- (void)removeMessage:(ChatMessage *)msg;
#pragma mark - 添加信息
- (void)addMessage:(NSBubbleData *)bubbleData to:(ChatFriend *)fri;
//- (void)getMessagesOfFriend:(FriendModel *)fri;
#pragma mark - 获得信息
- (ChatMessage *)getMessageWithText:(NSString *)text;
//根据Text和日期查询某条聊天记录
- (ChatMessage *)getMessageByText:(NSString *)text andDate:(NSDate *)date;
//获取与此好友发送的所有照片
- (NSArray *)getAllPICMessages:(ChatFriend *) friend;
//获取与此好友发送的所有照片(BubbleData)
- (NSArray *)getAllPICBubbleData:(ChatFriend *) friend;
//- (void)removeMessages:(NSArray *)msgs;
#pragma mark - 保存信息
- (void)saveUpdate;
- (void)testModel;

@end
