//
//  MixedCoding.h
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

//用于处理图文混编

#import <Foundation/Foundation.h>



@interface MixedCoding : NSObject

//将json串和二进制文件按照规定编码成NSData返回
+ (NSData *)encoding:(NSString *)json andData:(NSData *)data;
//将收到的data按规定解码成一个字典，包含两项，“string”是json串，“data”是二进制文件
+ (NSDictionary *)decoding:(NSData *)data;

@end
