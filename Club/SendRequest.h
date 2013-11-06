//
//  SendRequest.h
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface SendRequest : NSObject
+(ASIFormDataRequest*)sendRequestWithURL:(NSString*)postURLString WithpostData:(NSDictionary*)postDic;
+(ASIFormDataRequest*)sendRequest:(NSString*)postURLString WithpostData:(NSDictionary*)postDic;
+(void)printRequestError:(ASIFormDataRequest*)request;
@end
