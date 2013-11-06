//
//  RequestQueue.m
//  WeClub
//
//  Created by Archer on 13-3-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "RequestQueue.h"

@implementation RequestQueue

SYNTHESIZE_SINGLETON_FOR_CLASS(RequestQueue);

- (id)init
{
    self = [super init];
    if (self) {
        _requestDic = [[NSMutableDictionary alloc] init];
        _requestIndex = 0;
    }
    return self;
}

- (int)addRequest:(ASIHTTPRequest *)request
{
    int index;
    [_requestDic setObject:request forKey:[NSString stringWithFormat:@"%d",_requestIndex]];
    index = _requestIndex;
    _requestIndex++;
    return index;
}

- (ASIHTTPRequest *)getRequest:(int)index
{
    ASIHTTPRequest *request;
    if ([[_requestDic allKeys] indexOfObject:[NSString stringWithFormat:@"%d",index]] == NSNotFound) {
        return nil;
    }else{
        request = [_requestDic objectForKey:[NSString stringWithFormat:@"%d",index]];
    }
    return request;
}

- (void)removeRequest:(int)index
{
    [_requestDic removeObjectForKey:[NSString stringWithFormat:@"%d",index]];
    if (_requestIndex >= 10000) {
        _requestIndex = 0;
    }
    NSLog(@"queue length:%d",[_requestDic count]);
}

- (void)cancelRequest:(int)index
{
    ASIHTTPRequest *request = [_requestDic objectForKey:[NSString stringWithFormat:@"%d",index]];
    [request cancel];
    [self removeRequest:index];
}

@end
