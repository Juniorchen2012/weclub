//
//  RequestProxy.h
//  WeClub
//
//  Created by Archer on 13-3-13.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"
#import "Club.h"
#import "Utility.h"
#import "ChatListSaveProxy.h"

@protocol RequestProxyDelegate <NSObject>

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type;
- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type;
@optional
- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type;

@end

@interface RequestProxy : NSObject<ASIHTTPRequestDelegate,UIAlertViewDelegate>
{
    //id<RequestProxyDelegate> _delegate;
    ASIFormDataRequest *_request;
    ASINetworkQueue *_networkQueue;
    NSMutableArray *_requestArray;
    NSMutableArray *_responseDataArray;
}

@property (nonatomic,weak) id<RequestProxyDelegate> delegate;

- (id)init;
- (void)cancel;
- (void)sendDictionary:(NSMutableDictionary *)dic andURL:(NSString *)urlString andData:(NSDictionary *)dataDic;
- (void)sendRequest:(NSMutableDictionary *)dic type:(NSString *)type;
- (void)sendRequest:(NSMutableDictionary *)dic andData:(NSData *)data type:(NSString *)type;
- (void)getCookies;
- (void)loginWithKey:(NSString *)keyValue andPassWord:(NSString *)passWord andType:(NSString *)type andForce:(BOOL)forceLogin;
- (void)checkIsLogin;
- (void)registerWithPhoto:(NSData *)photo andDictionary:(NSMutableDictionary *)dic;
- (void)getUsersIFollow:(NSString *)ID total:(NSString *)total last:(NSString *)last;
- (void)getUsersFollowMe:(NSString *)ID total:(NSString *)total last:(NSString *)last;
- (void)getUsersBlackList:(NSString *)ID total:(NSString *)total last:(NSString *)last;
- (void)getUserInfoByKey:(NSString *)key andValue:(NSString *)value;
- (void)getUsersInfoByLocation:(NSString *)location PageSize:(NSString *)size StartKey:(NSString *)key;
- (void)getUserArticles:(NSString *)type count:(NSString *)count startKey:(NSString *)startKey id:(NSString *)ID key:(NSString *)key;
- (void)followPerson:(NSString *)numberid;
- (void)cancelFollowPerson:(NSString *)numberid;
- (void)blackAdd:(NSString *)numberid;
- (void)blackCancel:(NSString *)numberid;
- (void)reportPerson:(NSString *)type reason:(NSString *)reason numberid:(NSString *)numberid;
- (void)changeMainInfo:(NSDictionary *)dic andPhoto:(NSData *)data;
- (void)upUserPhoto:(NSData *)photoData;
- (void)changePrivacySetting:(NSDictionary *)dic;
- (void)logout;
- (void)getInformWithType:(NSString *)type total:(NSString *)total last:(NSString *)last;
- (void)testPrivateLetterWithNumberID:(NSString *)numberid;
- (void)testPublicSettingWithNumberID:(NSString *)numberid;
- (void)getImportFriendsWithPage:(NSString *)pageSize andStartKey:(NSString *)startKey;
- (void)followPersons:(NSMutableArray *)personList;
- (void)clearNoticeWithType:(NSString *)type;
- (void)searchUserWithID:(NSString *)userID total:(NSString *)total andStartKey:(NSString *)startKey;
- (void)changePassOrEmail:(NSString *)type withID:(NSString *)ID andOldPass:(NSString *)oldPass;

@end
