//
//  MsgResender.h
//  WeClub
//
//  Created by mitbbs on 13-7-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgResender : NSObject 

+(MsgResender *)sharedInstance;

//获取发送数据ID（用户ID+发送时间）
-(NSString *)genMySendId;
//检测当前是否连接
-(bool)checkConnect;
//存储数据
-(NSString *)retainMessage:(NSDictionary *)dic Mid:(NSString*)mid;
//判断指定路径文件是否存在
-(BOOL)isFile:(NSString *)path;
//删除指定路径文件
-(BOOL)deleteFile:(NSString *)path;
//根据数据文件mid获取文件信息
-(NSDictionary *)getSendMessage:(NSString *)uniqueId;

@end
