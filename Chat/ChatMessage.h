//
//  ChatMessage.h
//  WeClub
//
//  Created by Archer on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSBubbleData.h"

@class ChatFriend;

@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * dataType;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * msgToPost;
@property (nonatomic, assign) Boolean needToPost;
@property (nonatomic, retain) NSNumber * requestIndex;
@property (nonatomic, retain) ChatFriend *master;
@property (nonatomic, retain) NSString * mid;
@property (nonatomic, assign) NSBubbleMessageState messageState;
@property (nonatomic, assign) BOOL isNewMessage;

@end
