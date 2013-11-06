//
//  ChatFriend.h
//  WeClub
//
//  Created by Archer on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSBubbleData.h"

@class ChatMessage;

@interface ChatFriend : NSManagedObject

@property (nonatomic, retain) NSString * friendID;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * lastMsg;
@property (nonatomic, retain) NSDate *lastDate;
@property (nonatomic, assign) NSInteger unread;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) NSString *sex;
@property (nonatomic, retain) NSString *masterID;

- (NSArray *)getBubbleDataArray;
//将集合messages中的元素整理成NSBubbleData并排序后返回
- (NSMutableArray *)getBubbleDataMutableArray;

- (NSArray *)loadPageData:(NSArray *)dataSource index:(NSInteger)pageNo count:(NSInteger)count;
- (NSInteger)getPageCount:(NSArray *)dataSource count:(NSInteger)count;
- (NSArray *)getLatestDataArray:(NSInteger)count;
//获取messages中所有元素，排序并返回
- (NSArray *)getMessagesDataArray;
@end

@interface ChatFriend (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(ChatMessage *)value;
- (void)removeMessagesObject:(ChatMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;


@end
