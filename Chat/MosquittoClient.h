//
//  MosquittoClient.h
//
//  Copyright 2012 Nicholas Humfrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MosquittoMessage.h"
#import "send_mosq.h"
#import "AccountUser.h"

@protocol MosquittoClientDelegate

- (void) didConnect: (NSUInteger)code;
- (void) didDisconnect;
//信息发送完成后的回调函数
- (void) didPublish: (NSUInteger)messageId;
- (void) didReceiveData :(NSData *)keyData onTopic:(NSString *)topic;
- (void) didReceiveMessage: (MosquittoMessage*)mosq_msg;
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos;
- (void) didUnsubscribe: (NSUInteger)messageId;
- (void) didLog:(NSString *)msg;

@end


@interface MosquittoClient : NSObject <RequestProxyDelegate>{
    struct mosquitto *mosq;
    NSString *host;
    unsigned short port;
    NSString *username;
    NSString *password;
    unsigned short keepAlive;
    BOOL cleanSession;
    
    id<MosquittoClientDelegate> delegate;
//    NSTimer *timer;
//    NSTimer *connectTestTimer;
    
    int isReconnect;
    int MQTTNetworkState;
    int nConnectTime;               //在指定时间内连接服务器的次数，若超过30此则暂停发送请求，待10分钟后再重新连接
    BOOL isStopConnect;
    
    RequestProxy *_rp;          //查看此用户是否在其他设备上登录
}

@property (readwrite,retain) NSString *host;
@property (readwrite,assign) unsigned short port;
@property (readwrite,retain) NSString *username;
@property (readwrite,retain) NSString *password;
@property (readwrite,assign) unsigned short keepAlive;
@property (readwrite,assign) BOOL cleanSession;
@property (readwrite,retain) id<MosquittoClientDelegate> delegate;
@property (readwrite,retain) MosquittoMessage *mosq_msg;
@property (readwrite,assign) int MQTTNetworkState;
@property (readwrite,retain) NSTimer *timer;
@property (readwrite,retain) NSTimer *connectTestTimer;

+ (void) initialize;
+ (NSString*) version;

- (MosquittoClient*) initWithClientId: (NSString *)clientId;
- (void) setMessageRetry: (NSUInteger)seconds;
- (void) connect;
- (void) connectToHost: (NSString*)host;
- (void) reconnect;
- (void) disconnect;

- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
- (void)clearWill;

- (void)publishString: (NSString *)payload toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain;
- (void)publishData:(NSData *)keyData toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain;
- (void)subscribe: (NSString *)topic;
- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos;
- (void)unsubscribe: (NSString *)topic;


// This is called automatically when connected
- (int)getMosq_Mid;
- (void) loop: (NSTimer *)timer;
- (void)checkMQTTNetworkState;

@end
