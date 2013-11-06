//
//  MsgResender.m
//  WeClub
//
//  Created by mitbbs on 13-7-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "MsgResender.h"
#import "Header.h"

static MsgResender* instance = nil;

@implementation MsgResender

+(MsgResender *)sharedInstance {
    return instance;
}


+(void)initialize {
    if(self == [MsgResender class]) {
        instance = [[self alloc] init];
    }
}

-(bool)checkConnect {
    return myAccountUser.netWorkStatus;
}

//生成mid（UserID + Time）
-(NSString *)genMySendId {
    return [NSString stringWithFormat:@"%@%@", myAccountUser.numberID, [NSNumber numberWithLong:(long)[[NSDate date] timeIntervalSince1970]]];
}

-(NSString*)getSavePath:(NSString *)uniqueid {
    NSArray *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [NSString stringWithFormat:@"%@/%@", [directory objectAtIndex:0], uniqueid];
}


-(NSString *)retainMessage:(NSDictionary *)dic Mid:(NSString*)mid {
        if (!mid) {
            return nil;
        }
        [dic writeToFile:[self getSavePath:mid] atomically:YES];
        return mid;
}

-(BOOL)isFile:(NSString *)path {
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
    
}

-(BOOL)deleteFile:(NSString *)path {
    if([self isFile:path]) {
        NSError *error;
        BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if(!ret) {
            NSLog(@"deleteFileError:%@", [error description]);
        }
        return ret;
    }
    return true;
}


-(NSDictionary *)getSendMessage:(NSString *)uniqueId {
    NSString *path = [self getSavePath:uniqueId];
    if([self isFile:path])
        return  [[NSDictionary alloc] initWithContentsOfFile:path];
    return nil;
}

@end
