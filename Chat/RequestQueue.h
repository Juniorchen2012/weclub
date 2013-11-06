//
//  RequestQueue.h
//  WeClub
//
//  Created by Archer on 13-3-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface RequestQueue : NSObject
{
    NSMutableDictionary *_requestDic;
    int _requestIndex;
}

+ (RequestQueue *)sharedRequestQueue;

- (int)addRequest:(ASIHTTPRequest *)request;
- (ASIHTTPRequest *)getRequest:(int)index;
- (void)removeRequest:(int)index;
- (void)cancelRequest:(int)index;

@end
