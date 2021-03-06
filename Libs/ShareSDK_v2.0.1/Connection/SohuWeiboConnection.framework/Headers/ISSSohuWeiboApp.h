//
//  Created by ShareSDK.cn on 13-1-14.
//  官网地址:http://www.ShareSDK.cn
//  技术支持邮箱:support@sharesdk.cn
//  官方微信:ShareSDK   （如果发布新版本的话，我们将会第一时间通过微信将版本更新内容推送给您。如果使用过程中有任何问题，也可以通过微信与我们取得联系，我们将会在24小时内给予回复）
//  商务QQ:4006852216
//  Copyright (c) 2013年 ShareSDK.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDKCoreService/ShareSDKCoreService.h>
#import "ISSSohuWeiboAuthSession.h"
#import "SSSohuWeiboUser.h"
#import "SSSohuWeiboErrorInfo.h"
#import "SSSohuWeiboStatus.h"

/**
 *	@brief	请求方式
 */
typedef enum
{
	SSSohuWeiboRequestMethodGet = 0, /**< GET方式 */
	SSSohuWeiboRequestMethodPost = 1, /**< POST方式 */
	SSSohuWeiboRequestMethodMultipartPost = 2 /**< Multipart POST方式，用于上传文件的api接口 */
}
SSSohuWeiboRequestMethod;


/**
 *	@brief	搜狐微博应用
 */
@protocol ISSSohuWeiboApp <ISSCOpenApp>

/**
 *	@brief	获取授权帐号
 *
 *	@return	授权帐号
 */
- (id<ISSCAccount>)account;

/**
 *	@brief	获取消费者Key
 *
 *	@return	消费者Key
 */
- (NSString *)consumerKey;

/**
 *	@brief	获取消费者密钥
 *
 *	@return	消费者密钥
 */
- (NSString *)consumerSecret;

/**
 *	@brief	授权应用
 *
 *	@return	授权会话
 */
- (id<ISSSohuWeiboAuthSession>)authorize;

/**
 *	@brief	注册用户信息
 *
 *	@param 	user 	用户信息
 *
 *	@return	YES 表示注册成功， NO 表示注册失败
 */
- (BOOL)registerUser:(SSSohuWeiboUser *)user;

/**
 *	@brief	注销用户信息
 *
 *	@param 	user 	用户信息
 *
 *	@return	YES 表示注销成功， NO 表示注销失败
 */
- (BOOL)unregisterUser:(SSSohuWeiboUser *)user;

/**
 *	@brief	获取注册用户信息
 *
 *	@param 	uid 	用户ID
 *
 *	@return	返回用户信息，nil表示尚未注册
 */
- (SSSohuWeiboUser *)getUser:(NSString *)uid;

/**
 *	@brief	获取默认注册用户
 *
 *	@return	默认注册用户
 */
- (SSSohuWeiboUser *)defaultUser;

/**
 *	@brief	设置默认注册用户
 *
 *	@param 	defaultUser 	默认注册用户
 */
- (void)setDefaultUser:(SSSohuWeiboUser *)defaultUser;

/**
 *	@brief	检测用户是否已授权
 *
 *	@param 	error 	错误信息
 *
 *	@return	YES 表示没有授权，NO 表示已授权
 */
- (BOOL)checkUnauthWithError:(SSSohuWeiboErrorInfo *)error;

/**
 *	@brief	设置凭证
 *
 *	@param 	credential 	授权凭证信息
 */
- (void)setCredential:(SSSohuWeiboCredential *)credential;

/**
 *	@brief	调用开放平台API
 *
 *	@param 	path 	路径
 *	@param 	params 	请求参数
 *  @param  user    授权用户,如果传入nil则表示默认的授权用户
 *  @param  result  返回回调
 *  @param  fault   失败回调
 */
- (void)api:(NSString *)path
     method:(SSSohuWeiboRequestMethod)method
     params:(id<ISSCOAuthParameters>)params
       user:(SSSohuWeiboUser *)user
     result:(void(^)(id responder))result
      fault:(void(^)(SSSohuWeiboErrorInfo *error))fault;

/**
 *	@brief	获取当前授权用户信息
 *
 *  @param  result  返回回调
 */
- (void)showMe:(void(^)(BOOL result, SSSohuWeiboUser *user, SSSohuWeiboErrorInfo *error))result;

/**
 *	@brief	发布微博信息
 *
 *	@param 	status 	微博内容
 *  @param  result  返回回调
 */
- (void)updateWithStatus:(NSString *)status
                  result:(void(^)(SSCShareSessionState state, SSSohuWeiboStatus *status, SSSohuWeiboErrorInfo *error))result;

/**
 *	@brief	发送微博并上传图片。
 *
 *	@param 	status 	微博内容
 *	@param 	pic 	图片
 *  @param  result  返回回调
 */
- (void)uploadWithStatus:(NSString *)status
                     pic:(id<ISSCAttachment>)pic
                  result:(void(^)(SSCShareSessionState state, SSSohuWeiboStatus *status, SSSohuWeiboErrorInfo *error))result;


@end
