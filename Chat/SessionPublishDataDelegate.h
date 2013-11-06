//
//  SessionPublishDataDelegate.h
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SessionPublishDataDelegate <NSObject>

- (void)publishText:(NSString *)msg To:(NSString *)reciever;
- (void)publishText:(NSString *)msg AndData:(NSData *)data To:(NSString *)reciever;
- (void)postText:(NSDictionary *)dic AndData:(NSData *)data To:(NSString *)reciever;
- (BOOL)isConnect;
@end
