//
//  ChatFriend.m
//  WeClub
//
//  Created by Archer on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChatFriend.h"
#import "ChatMessage.h"

@implementation ChatFriend

@dynamic friendID;
@dynamic photo;
@dynamic name;
@dynamic lastMsg;
@dynamic lastDate;
@dynamic unread;
@dynamic messages;
@dynamic sex;
@dynamic masterID;

- (NSArray *)loadPageData:(NSArray *)dataSource index:(NSInteger)pageNo count:(NSInteger)count
{
    if (count <= 0 || pageNo < 0 || !dataSource) {
        return nil;
    }
    
    NSInteger pageCount = [self getPageCount:dataSource count:count];
    NSLog(@"%d", pageCount);
    if(pageCount < pageNo) {
        return nil;
    }
    
        NSInteger offset =  pageNo * count;
        NSRange range = NSMakeRange(offset, count);
        return [dataSource subarrayWithRange:range];
}

- (NSInteger)getPageCount:(NSArray *)dataSource count:(NSInteger)count {
    if (count <= 0 ||  !dataSource) {
        return 0;
    }
    return (NSInteger)ceil((float)[dataSource count] / (float)count);
}

- (NSArray *)getLatestDataArray:(NSInteger)count {
        NSArray *data = [self getBubbleDataArray];
    if(count >= [data count]) {
        return data;
    }else {
        
        NSInteger pageIndex = [self getPageCount:data count:count] - 1;
        NSInteger offset =  pageIndex * count;
        NSInteger realCount =  [data count] % count > 0 ? [data count] % count : count;
        NSRange range = NSMakeRange(offset, realCount);
        
        NSArray *reusltArray = [data subarrayWithRange:range];
        data = nil;
        return reusltArray;
    }
}

//将集合messages中的元素整理成NSBubbleData并排序后返回
- (NSArray *)getBubbleDataArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *sortedArray;
    
    for (ChatMessage *msg in self.messages) {
        NSBubbleData *data = [[NSBubbleData alloc] initWithText:msg.text andDate:msg.date andType:[msg.type intValue] andData:msg.data withDataType:[msg.dataType intValue]];
        data.urlString = msg.urlString;
        data.length = [msg.length intValue];
        data.needToPost = msg.needToPost;
        data.msgToPost = msg.msgToPost;
        data.requestIndex = [msg.requestIndex intValue];
        data.mid = msg.mid;
        data.isNewMessage = msg.isNewMessage;
        [array addObject:data];
    }
    
    //按照时间NSDate升序排序
    sortedArray = [array sortedArrayUsingComparator:^(id item1,id item2){
        NSBubbleData *data1 = item1;
        NSBubbleData *data2 = item2;
        NSComparisonResult result = (NSComparisonResult)[data1.date compare:data2.date];
        return result;
    }];
    
    array = nil;
    
    return sortedArray;
}

//将集合messages中的元素整理成NSBubbleData并排序后返回
- (NSMutableArray *)getBubbleDataMutableArray
{
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self getMessagesDataArray]];
    return array;
}

//获取messages中所有元素，排序并返回
- (NSArray *)getMessagesDataArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *sortedArray;
    
    for (ChatMessage *msg in self.messages) {
        [array addObject:msg];
    }
    
    //按照时间NSDate升序排序
    sortedArray = [array sortedArrayUsingComparator:^(id item1,id item2){
        
        NSBubbleData *data1 = item1;
        NSBubbleData *data2 = item2;
        
        NSComparisonResult result = (NSComparisonResult)[data1.date compare:data2.date];
        
        return result;
        
    }];
    
    return sortedArray;
}

@end
