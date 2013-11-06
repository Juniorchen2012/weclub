//
//  MixedCoding.m
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "MixedCoding.h"
#import "Header.h"

@implementation MixedCoding

+ (NSData *)encoding:(NSString *)json andData:(NSData *)data
{
    NSMutableData *returnData = [[NSMutableData alloc] init];
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    int length = jsonData.length;
    unsigned char first = length/256;
    unsigned char second = length%256;
    unsigned char bytes[] = {first,second};
    [returnData appendBytes:bytes length:2];
    [returnData appendData:jsonData];
    
    if (data != nil) {
        [returnData appendData:data];
    }
    return [returnData copy];
}

+ (NSDictionary *)decoding:(NSData *)data
{
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc] init];
    
    unsigned char bytes[2];
    [data getBytes:&bytes range:NSMakeRange(0, 2)];
    int length = bytes[0]*256+bytes[1];

    if (data.length < length + 2) {
        //数据长度不足
        [returnDic setObject:[NSNumber numberWithInt:MIXEDCODING_STATE_MISSING] forKey:MIXEDCODING_STATE];
    }else if (data.length == length + 2){
        //只有文字，没有二进制文件
        [returnDic setObject:[NSNumber numberWithInt:MIXEDCODING_STATE_TEXT] forKey:MIXEDCODING_STATE];
        NSData *jsonData = [data subdataWithRange:NSMakeRange(2, length)];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [returnDic setObject:json forKey:JSONSTRING];
//        [json release];
    }else{
        //有文字和二进制文件
        [returnDic setObject:[NSNumber numberWithInt:MIXEDCODING_STATE_TEXTDATA] forKey:MIXEDCODING_STATE];
        NSData *jsonData = [data subdataWithRange:NSMakeRange(2, length)];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [returnDic setObject:json forKey:JSONSTRING];
//        [json release];
        
        NSData *fileData = [data subdataWithRange:NSMakeRange(length+2, data.length-length-2)];
        [returnDic setObject:fileData forKey:FILEDATA];
    }
    
    return [returnDic copy];
}

@end
