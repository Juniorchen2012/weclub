//
//  MosquittoClient.m
//
//  Copyright 2012 Nicholas Humfrey. All rights reserved.
//

#import "MosquittoClient.h"
#import "mosquitto.h"

@implementation MosquittoClient

@synthesize host;
@synthesize port;
@synthesize username;
@synthesize password;
@synthesize keepAlive;
@synthesize cleanSession;
@synthesize delegate;


static void on_connect(struct mosquitto *mosq, void *obj, int rc)
{
    MosquittoClient* client = (MosquittoClient*)obj;
    [[client delegate] didConnect:(NSUInteger)rc];
}

static void on_disconnect(struct mosquitto *mosq, void *obj, int rc)
{
    MosquittoClient* client = (MosquittoClient*)obj;
    [[client delegate] didDisconnect];
}

static void on_publish(struct mosquitto *mosq, void *obj, int message_id)
{
    MosquittoClient* client = (MosquittoClient*)obj;
    [[client delegate] didPublish:(NSUInteger)message_id];
}

static void on_message(struct mosquitto *mosq, void *obj, const struct mosquitto_message *message)
{
//    MosquittoMessage *mosq_msg = [[MosquittoMessage alloc] init];
//    mosq_msg.topic = [NSString stringWithUTF8String: message->topic];
//    mosq_msg.payload = [[NSString alloc] initWithBytes:message->payload length:message->payloadlen encoding:NSUTF8StringEncoding] ;
    NSData *keyData = [NSData dataWithBytes:message->payload length:message->payloadlen];
    NSString *topic = [NSString stringWithUTF8String:message->topic];
//    mosq_msg.data = keyData;
//    mosq_msg.payloadlen = mosq_msg.data.length;
    MosquittoClient* client = (MosquittoClient*)obj;
    
    [[client delegate] didReceiveData:keyData onTopic:topic];

//    [mosq_msg release];
}

static void on_subscribe(struct mosquitto *mosq, void *obj, int message_id, int qos_count, const int *granted_qos)
{
    MosquittoClient* client = (MosquittoClient*)obj;
    // FIXME: implement this
    [[client delegate] didSubscribe:message_id grantedQos:nil];
}

static void on_unsubscribe(struct mosquitto *mosq, void *obj, int message_id)
{
    MosquittoClient* client = (MosquittoClient*)obj;
    [[client delegate] didUnsubscribe:message_id];
}

static void on_log(struct mosquitto *mosq, void *obj, int level, char *msg) {
    MosquittoClient* client = (MosquittoClient *)obj;
    NSLog(@"level:%d", level);
    [[client delegate] didLog:[NSString stringWithUTF8String:(const char*)msg]];
}


// Initialize is called just before the first object is allocated
+ (void)initialize {
    mosquitto_lib_init();
}

+ (NSString*)version {
    int major, minor, revision;
    mosquitto_lib_version(&major, &minor, &revision);
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, revision];
}

- (MosquittoClient*) initWithClientId: (NSString*) clientId {
    if ((self = [super init])) {
        const char* cstrClientId = [clientId cStringUsingEncoding:NSUTF8StringEncoding];
        [self setHost: nil];
        [self setPort: 1883];
        [self setKeepAlive: 120];    //检查用户当前是否在线的时间     120s
        //NOTE: this isdisable clean to keep the broker remember this client
        if(cstrClientId) {
            self.cleanSession = NO;
        }else {
            self.cleanSession = YES;
        }
        mosq = mosquitto_new(cstrClientId, cleanSession, (void *)(self));
        
        mosquitto_connect_callback_set(mosq, on_connect);
        mosquitto_disconnect_callback_set(mosq, on_disconnect);
        mosquitto_publish_callback_set(mosq, on_publish);
        mosquitto_message_callback_set(mosq, on_message);
        mosquitto_subscribe_callback_set(mosq, on_subscribe);
        mosquitto_unsubscribe_callback_set(mosq, on_unsubscribe);
        mosquitto_log_callback_set(mosq, on_log);
        self.timer = nil;
    }
    [[AccountUser getSingleton] setMQTTconnected:NO];
    self.MQTTNetworkState = (int)-1;
    [self addObserver:self forKeyPath:@"MQTTNetworkState" options:NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectTryOnce) name:NOTIFICATION_KEY_CONNECTMQTT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnect) name:NOTIFICATION_KEY_DICCONNECT_MQTT object:nil];
    
    return self;
}

- (void)connectTryOnce{
    isStopConnect = NO;
    [self connect];
}

- (void) connect {
    if (!isStopConnect) {
        isStopConnect = YES;
    
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        
        [_rp checkIsLogin];
    }
}

- (void) connectMQTT {
    isStopConnect = NO;
    
    NSLog(@"connect... time:%d", nConnectTime);
    nConnectTime ++;
    
    if (nConnectTime > 100) {
        NSLog(@"stop connect... time:%d", nConnectTime - 100);
        return;
    }
    
    if (((myAccountUser.netWorkStatus & 0X02 ) == 2 )  || ![[AccountUser getSingleton] isLogin]) {
        [[AccountUser getSingleton] setMQTTconnected:NO];
        [self disconnect];
        self.MQTTNetworkState = -1;
        NSLog(@"用户注销 MQTT断开连接");
        if (self.timer && [self.timer isKindOfClass:[NSTimer class]]) {
            [self.timer invalidate];
            self.timer = nil;
        }
        if (self.connectTestTimer && [self.connectTestTimer isKindOfClass:[NSTimer class]]) {
            [self.connectTestTimer invalidate];
            self.connectTestTimer = nil;
        }
        if (mosq) {
            mosquitto_destroy(mosq);
            mosq = NULL;
        }
        return;
    }
    
    const char *cstrHost = [host cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cstrUsername = NULL, *cstrPassword = NULL;
    
    if (username)
        cstrUsername = [username cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (password)
        cstrPassword = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    // FIXME: check for errors
    mosquitto_username_pw_set(mosq, cstrUsername, cstrPassword);
    
    mosquitto_connect(mosq, cstrHost, port, keepAlive);
    
    // Setup timer to handle network events
    // FIXME: better way to do this - hook into iOS Run Loop select() ?
    // or run in seperate thread?
    if (self.timer) {
        if (![self.timer isKindOfClass:[NSTimer class]]) {
            NSLog(@"MosquittoClient : NSTimerError , timer");
            mosquitto_disconnect(mosq);
            mosquitto_destroy(mosq);
            return;
        }
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 // 1s
                                             target:self
                                           selector:@selector(loop:)
                                           userInfo:nil
                                            repeats:YES];
    
    if (self.connectTestTimer) {
        if (![self.connectTestTimer isKindOfClass:[NSTimer class]]) {
            [self.timer invalidate];
            NSLog(@"MosquittoClient : NSTimerError , connectTestTimer");
            mosquitto_disconnect(mosq);
            mosquitto_destroy(mosq);
            return;
        }
        [self.connectTestTimer invalidate];
        self.connectTestTimer = nil;
    }
    self.connectTestTimer = [NSTimer scheduledTimerWithTimeInterval:(1*10*60) // 10M
                                             target:self
                                           selector:@selector(checkConnectState)
                                           userInfo:nil
                                            repeats:YES];
    isReconnect = 0;
}

- (void)checkConnectState{
    NSLog(@"MosquittoClient : checkConnectState     nConnectTime:%d->0", nConnectTime);
    nConnectTime = 0;
//    if (![[AccountUser getSingleton] MQTTconnected]) {
//        [self connect];
//    }
    
}

- (void) connectToHost: (NSString*)aHost {
    [self setHost:aHost];
    [self connect];
}

- (void) reconnect {
    NSLog(@"reconnect...");
    mosquitto_reconnect(mosq);
}

- (void) disconnect {
    mosquitto_disconnect(mosq); 
}

- (void) loop: (NSTimer *)localTimer {
    
    if (isStopConnect) {
        return;
    }
    
    //如用户注销则断开连接
    if (((myAccountUser.netWorkStatus & 0X02 ) == 2 )  || ![[AccountUser getSingleton] isLogin]) {
        [[AccountUser getSingleton] setMQTTconnected:NO];
        [self disconnect];
        self.MQTTNetworkState = -1;
        NSLog(@"用户注销 MQTT断开连接");
        if (localTimer && [localTimer isKindOfClass:[NSTimer class]]) {
            [localTimer invalidate];
            localTimer = nil;
        }
        if (self.connectTestTimer && [self.connectTestTimer isKindOfClass:[NSTimer class]]) {
            [self.connectTestTimer invalidate];
            self.connectTestTimer = nil;
        }
        if (mosq) {
            mosquitto_destroy(mosq);
            mosq = NULL;
        }
        
        return;
    }
    //每10ms获取一次用户的数据
    int mosq_err_num = mosquitto_loop(mosq, 1, 1);
//    NSLog(@"mosq_err_num:%d     myAccountUser.netWorkStatus: %d", mosq_err_num , (myAccountUser.netWorkStatus & 0X02 ));
    if (self.MQTTNetworkState != mosq_err_num) {
        self.MQTTNetworkState = mosq_err_num;
    }
    
    //Mosquitto服务器重连处理
    //如果出现异常就先断开，之后再次请求连接
    int static reconnectCount = 0;
    int static num = 0;
    int static nNetworkChange = 0;
    //若网络状态发生改变或MQTT服务器断开连接则进行处理
    if (nNetworkChange != (myAccountUser.netWorkStatus & 0x01) || mosq_err_num != 0) {
        //如果网络连接但是MQTT服务断开连接（多次连接，但是每次连接都比上一次间隔时间长）
        if (0 != myAccountUser.netWorkStatus && mosq_err_num != 0) {
            reconnectCount ++;
            NSLog(@"MQTT未连接 reconnectCount ： %d", reconnectCount);
            if (reconnectCount/50 > num) {
                NSLog(@"MQTT未连接 ： %d", num);
                [self connect];
                reconnectCount = -reconnectCount;
                num += 10;
            }
        }
        //如果网络无法连接（仅尝试连接1次）
        else if (!(myAccountUser.netWorkStatus & 0x01))
        {
            NSLog(@"MQTT未连接 网络无法连接");
            [self connect];
        }
        //保留网络状态
        nNetworkChange = myAccountUser.netWorkStatus;
    }
    else{
        reconnectCount = 0;
        num = 0;
    }
}


- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
{
    const char* cstrTopic = [willTopic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[payload cStringUsingEncoding:NSUTF8StringEncoding];
    size_t cstrlen = [payload lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    mosquitto_will_set(mosq, cstrTopic, cstrlen, cstrPayload, willQos, retain);
}

- (void)checkMQTTNetworkState{
    _mosquitto_send_pingreq(mosq);
}


- (void)clearWill
{
    mosquitto_will_clear(mosq);
}


- (void)publishString: (NSString *)payload toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[payload cStringUsingEncoding:NSUTF8StringEncoding];
    size_t cstrlen = [payload lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    mosquitto_publish(mosq, NULL, cstrTopic, cstrlen, cstrPayload, qos, retain);
    
}

- (void)publishData:(NSData *)keyData toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain
{
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[keyData bytes];
    size_t cstrlen = keyData.length;
    mosquitto_publish(mosq, NULL, cstrTopic, cstrlen, cstrPayload, qos, retain);
}

- (int)getMosq_Mid{
    return mosquitto_getmosquittoMid(mosq);
}

- (void)subscribe: (NSString *)topic {
    [self subscribe:topic withQos:0];
}

- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_subscribe(mosq, NULL, cstrTopic, qos);
}

- (void)unsubscribe: (NSString *)topic {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_unsubscribe(mosq, NULL, cstrTopic);
}

- (void) setMessageRetry: (NSUInteger)seconds
{
    mosquitto_message_retry_set(mosq, (unsigned int)seconds);
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_CHECKISLOGIN]){
        if ([dic objectForKey:@"result"]) {
            NSString *resultStr = [dic objectForKey:@"result"];
            int result = [resultStr intValue];
            
            switch (result) {
                case 0:     //用户上次就在此设备登陆并安全退出
                case 1:     //用户未在其他客户端登陆
                            //  或用户以前在其他客户端登陆并安全退出
                {
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    [self connectMQTT];
                    break;
                }
                case -1://此用户已经在其他客户端登录
                case -2://此用户由于长时间未操作Session已经被清除
                case -3://Session为空
                {
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    //用户注销，跳转到登录界面
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dic objectForKey:@"msg"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                default:
                {
                    NSLog(@"CheckUserIsLogin    Error");
                    //用户注销，跳转到登录界面
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"CheckUserIsLogin    Error" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
            }
        }
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_CHECKISLOGIN]){
        NSDictionary *dic = infoDic;
        if ([dic objectForKey:@"result"]) {
            NSString *resultStr = [dic objectForKey:@"result"];
            int result = [resultStr intValue];
            
            switch (result) {
                case 0:     //用户上次就在此设备登陆并安全退出
                case 1:     //用户未在其他客户端登陆
                            //  或用户以前在其他客户端登陆并安全退出
                {
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    [self connectMQTT];
                    break;
                }
                case -1://此用户已经在其他客户端登录
                case -2://此用户由于长时间未操作Session已经被清除
                case -3://Session为空
                {
                    NSLog(@"%@", [dic objectForKey:@"msg"]);
                    //用户注销，跳转到登录界面
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dic objectForKey:@"msg"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                default:
                {
                    NSLog(@"CheckUserIsLogin    Error");
                    //用户注销，跳转到登录界面
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"CheckUserIsLogin    Error" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
            }
        }
    }
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_CHECKISLOGIN]){
        isStopConnect = NO;
        self.MQTTNetworkState = MOSQ_ERR_ERRNO;
        [self connectMQTT];
//        //用户注销，跳转到登录界面
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"登陆请求失败，请检查网络状态" delegate:Nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
    }
}

- (void) dealloc {
    NSLog(@"MosquittoClient dealloc");
    
    if (mosq) {
        mosquitto_destroy(mosq);
        mosq = NULL;
    }
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:NOTIFICATION_KEY_CONNECTMQTT];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath: NOTIFICATION_KEY_DICCONNECT_MQTT];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"MQTTNetworkState"];
    
    [super dealloc];
}

// FIXME: how and when to call mosquitto_lib_cleanup() ?

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"MQTTNetworkState"])
    {
        NSLog(@"NOTIFICATION_KEY_MQTT_CONNECT_STATE_CHANGE %d", self.MQTTNetworkState);
        /* 拼接状态改变内容
            “kind”：改变类型（NSString）
            ”old”：原始数值（NSString）
            “new“：新的数值（NSString）
        */
        NSMutableDictionary *MQTTNetworkStateDic = [[NSMutableDictionary alloc] initWithCapacity:3];
        [MQTTNetworkStateDic setObject:[[NSString alloc] initWithFormat:@"%d", [[change objectForKey:@"kind"] intValue]] forKey:@"kind"];
        [MQTTNetworkStateDic setObject:[[NSString alloc] initWithFormat:@"%d", [[change objectForKey:@"old"] intValue]] forKey:@"old"];
        [MQTTNetworkStateDic setObject:[[NSString alloc] initWithFormat:@"%d", self.MQTTNetworkState] forKey:@"new"];
        
        switch (self.MQTTNetworkState) {
            case MOSQ_ERR_SUCCESS:{
                myAccountUser.MQTTconnected = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_MQTT_CONNECT_STATE_CHANGE object:MQTTNetworkStateDic];
                break;
            }
            case MOSQ_ERR_CONN_LOST:{
                myAccountUser.MQTTconnected = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_MQTT_CONNECT_STATE_CHANGE object:MQTTNetworkStateDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CONNECTMQTT object:MQTTNetworkStateDic];
                break;
            }
            default:{
                myAccountUser.MQTTconnected = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_MQTT_CONNECT_STATE_CHANGE object:MQTTNetworkStateDic];
                break;
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
        if ([[AccountUser getSingleton] isLogin]) {
            [_rp logout];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_LOGOUT object:nil];
            isStopConnect = NO;
        }
    }
}

@end
