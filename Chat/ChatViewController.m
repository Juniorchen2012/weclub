//
//  ChatViewController.m
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "ChatViewController.h"
#import "PersonInfoViewController.h"
#import "CircleView.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"ChatViewController init");
        self.view.backgroundColor = [UIColor grayColor];
        
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        
        AccountUser *user = [AccountUser getSingleton];
        if (!_client) {
            _client = [[MosquittoClient alloc] initWithClientId:user.numberID];
        }
        _client.delegate = self;
        _client.username = MQTTUserName;
        _client.password = MQTTPassWord;
        _client.host = MQTTHost;
        _client.port = MQTTPort;
        reconnect = YES;
        reconnectTimeA = 1;
        reconnectTimeB = 1;
        [_client connect];
        NSLog(@"_client.cleanSession : %d", _client.cleanSession);
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnect) name:NOTIFICATION_KEY_CONNECTMQTT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout) name:NOTIFICATION_KEY_LOGOUT object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _friendList = [[ChatListSaveProxy sharedChatListSaveProxy] getFriends];

    UIImageView *bg = [[UIImageView alloc] init];
    bg.frame = self.view.frame;
    bg.image = [[UIImage imageNamed:@"chat_friendlist_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 4, 1)];
//    [self.view addSubview:bg];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _reconnectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, screenSize.height - 109) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
//    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_reconnectedView];
    [self.view addSubview:_tableView];
    
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont systemFontOfSize:20];
    self.navigationItem.titleView = headerLabel;
    
    UIButton *_addFriendButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_addFriendButton setImage:[UIImage imageNamed:@"scan_tdc.png"] forState:UIControlStateNormal];
    [_addFriendButton addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_addFriendButton];
    
//    UIBarButtonItem *addFriendBtn = [[UIBarButtonItem alloc] initWithTitle:@"扫一扫" style:UIBarButtonItemStylePlain target:self action:@selector(scan)];
//    self.navigationItem.rightBarButtonItem = addFriendBtn;
    
    reconnect = YES;
    
    //二维码扫描
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addChatingFriend:) name:NOTIFICATION_KEY_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearSession) name:NOTIFICATION_KEY_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout) name:NOTIFICATION_KEY_DISTORYMQTTCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distroyMQTT) name:NOTIFICATION_KEY_DESTROY_MQTT object:nil];
    
    
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    currentDetail = nil;
    _friendList = [[ChatListSaveProxy sharedChatListSaveProxy] getFriends];
    [self.view reloadInputViews];
    [_tableView reloadData];
    [_client checkMQTTNetworkState];
}

- (void)viewDidAppear:(BOOL)animated
{
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    if (![[AccountUser getSingleton] MQTTconnected]) {
        label.text = @"私聊(未连接)";
    }
    else{
        label.text = @"私聊";
    }
}

- (void)dealloc
{
//    [super dealloc];
//    [_session release];
    NSLog(@"ChatViewController dealloc");
    _session = nil;
    [_client disconnect];
    _client = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"ChatViewController MemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearSession
{
    reconnect = NO;
//    [_session close];
//    _session = nil;
    [_client disconnect];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_LOGOUT object:nil];
}

- (void)connectMQTT
{
    NSLog(@"connectMQTT...");

    if (_session == nil) {
        NSString *numberID = [AccountUser getSingleton].numberID;
        if (numberID == nil) {
            [self alert:@"请重新登录"];
        }

//        _session = [[MQTTSession alloc] initWithClientId:numberID];
        
        AccountUser *user = [AccountUser getSingleton];
        NSHTTPCookie *cookie = user.cookie;
        NSLog(@"ttttt:%@",[cookie description]);
        NSString *sessionid = cookie.value;
        NSLog(@"sessionid:%@",sessionid);
        
        _session = [[MQTTSession alloc] initWithClientId:user.numberID userName:MQTTUserName password:MQTTPassWord keepAlive:10000 cleanSession:NO];
//        _session = [[MQTTSession alloc] initWithClientId:numberID userName:MQTTUserName password:MQTTPassWord keepAlive:10000 cleanSession:NO willTopic:nil willMsg:nil willQoS:2 willRetainFlag:NO];
        [_session setDelegate:self];
    }
    [_session connectToHost:MQTTHost port:MQTTPort];
    
}

//- (void)showChatDetail:(NSInteger)index
//{
//    NSLog(@"showChatDetail...");
//    currentDetail = nil;
//    currentDetail = [[DetailViewController alloc] initWithChatLog:nil];
//    currentDetail.delegate = self;
//    currentDetail.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:currentDetail animated:YES];
//}

#pragma mark - SessionPublishDataDelegate Callback methods
- (void)publishText:(NSString *)msg To:(NSString *)receiver
{
    NSLog(@"publishText...");
    if(![self isConnect]){
        return;
    }
    NSData *dataToSend = [MixedCoding encoding:msg andData:nil];
//    [_session publishData:dataToSend onTopic:reciever];
//    [_session publishDataAtLeastOnce:dataToSend onTopic:reciever];
//    [_session publishDataAtLeastOnce:dataToSend onTopic:reciever retain:NO];
    [_client publishData:dataToSend toTopic:receiver withQos:1 retain:NO];
 
}

- (void)publishText:(NSString *)msg AndData:(NSData *)data To:(NSString *)receiver
{
    NSLog(@"publishTextAndData...");
    if(![self isConnect]){
        return;
    }
    NSData *dataToSend = [MixedCoding encoding:msg andData:data];
//    [_session publishData:dataToSend onTopic:reciever];
//    [_session publishDataAtLeastOnce:dataToSend onTopic:reciever];
//    [_session publishData:dataToSend onTopic:reciever];
//    [_session publishDataAtLeastOnce:dataToSend onTopic:reciever retain:NO];
//    [_client publishString:nil toTopic:nil withQos:2 retain:NO];
    [_client publishData:dataToSend toTopic:receiver withQos:1 retain:NO];
    NSLog(@"send data length:%d",dataToSend.length);
 
    
}

- (void)y  :(NSDictionary *)dic AndData:(NSData *)data To:(NSString *)reciever
{
    //    NSData *dataToSend = [MixedCoding encoding:msg andData:data];
    //    [_session publishData:dataToSend onTopic:reciever];
    //    NSLog(@"send data length:%d",dataToSend.length);
    
    NSURL *url = [NSURL URLWithString:UPLOADSERVER];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    NSLog(@"fuck length:%d",data.length);
    int type = [[dic objectForKey:MSG_KEY_TYPE] intValue];
    if (type == TYPE_PIC) {
        NSLog(@"11");
        [request setData:data withFileName:@"image" andContentType:@"image/jpeg" forKey:@"microfile"];
    }else if(type == TYPE_VIDEO){
        [request setData:data withFileName:@"video" andContentType:@"video/mpeg" forKey:@"microfile"];
    }
    NSString *msg = [dic JSONString];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    //    [request setFile:path forKey:@"microfile"];
    //    [request setPostValue:data forKey:@"microfile"];
    [request setPostValue:msg forKey:@"message"];
    NSLog(@"msg:%@",msg);
    [request buildRequestHeaders];
    request.delegate = self;
    request.uploadProgressDelegate = self;
    [request startAsynchronous];
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    NSLog(@"send bytes:%lld",bytes);
    NSLog(@"kkkkk:%lld/%lld",request.totalBytesSent,request.postLength);
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    NSLog(@"finish total length:%lld",request.contentLength);
    NSString *response = [request responseString];
    NSLog(@"gogogo:%@",response);
}

#pragma mark - MQTT Callback methods
- (void)session:(MQTTSession*)sender handleEvent:(MQTTSessionEvent)eventCode
{
    switch (eventCode) {
        case MQTTSessionEventConnected:
            NSLog(@"connected");
//            [sender subscribeTopic:[NSString stringWithFormat:@"%@/%@",MQTTTopicHead,[AccountUser getSingleton].numberID]];
            [sender subscribeToTopic:[NSString stringWithFormat:@"%@/%@",MQTTTopicHead,[AccountUser getSingleton].numberID] atLevel:2];
            break;
        case MQTTSessionEventConnectionRefused:
            NSLog(@"connection refused");
            break;
        case MQTTSessionEventConnectionClosed:
            NSLog(@"connection closed");
//            [_session close];
            if (reconnect) {
                [self connectMQTT];
            }
            break;
        case MQTTSessionEventConnectionError:
            NSLog(@"connection error");
            
            if (reconnect) {
                NSLog(@"reconnecting...");
                [self connectMQTT];
            }
            break;
        case MQTTSessionEventProtocolError:
            NSLog(@"protocol error");
            break;
    }
}

- (void)session:(MQTTSession*)sender newMessage:(NSData*)data onTopic:(NSString*)topic
{
    if (![topic isEqualToString:[NSString stringWithFormat:@"%@/%@",MQTTTopicHead,[AccountUser getSingleton].numberID]]) {
        return;
    }
    
    NSLog(@"recieve data length:%d",data.length);
    NSDictionary *recievedData = [MixedCoding decoding:data];
    
    int state = [[recievedData objectForKey:MIXEDCODING_STATE] intValue];
    
    NSString *jsonString = [recievedData objectForKey:JSONSTRING];
    
    NSLog(@"MQTT recieve data:%@",jsonString);
//    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *msgInfo = [jsonString objectFromJSONString];
//    NSLog(@"string:%@,msgInfo:%@",jsonString,msgInfo);
    NSString *friendID = [msgInfo objectForKey:MSG_KEY_FROM];
//    NSLog(@"from:%@",friendID);
    //处理不符合格式的数据
    if (msgInfo == nil || jsonString == nil) {
        NSLog(@"无法处理数据！！！");
        return;
    }
    if ([[NSString stringWithFormat:@"%@",friendID]isEqualToString:@"888"] ) {
        NSDictionary *noticeDic = [msgInfo objectForKey:MSG_KEY_CONTENT];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"checkCurrentController" object:noticeDic];
        return;
    }
    //解析10000
    if ([friendID isKindOfClass:[NSString class]] && [friendID isEqualToString:@"10000"]) {
        NSDictionary *noticeDic = [msgInfo objectForKey:MSG_KEY_CONTENT];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_UPDATENOTICE object:noticeDic];
        return;
    //解析9998    关注的用户首次登录微俱
    } else if ([friendID isKindOfClass:[NSString class]] && [friendID isEqualToString:@"9998"] && (int)[[msgInfo objectForKey:MSG_KEY_TYPE] isEqualToString:@"5"]) {
        [self addUnreadMsg:recievedData];
        return;
    //解析9997
    }else if ([friendID isKindOfClass:[NSString class]] && [friendID isEqualToString:@"9997"] && (int)[[msgInfo objectForKey:MSG_KEY_TYPE] isEqualToString:@"6"]) {
        NSDictionary *noticeDic = [msgInfo objectForKey:MSG_KEY_CONTENT];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_UPDATENOTICE object:noticeDic];
        return;
        //解析9999
    }else if ([friendID isKindOfClass:[NSString class]] && [friendID isEqualToString:@"9999"]){
        NSString *content = [msgInfo objectForKey:MSG_KEY_CONTENT];
        if ([content isKindOfClass:[NSString class]] && [content isEqualToString:@"kick"]) {
            reconnect = FALSE;
            AccountUser *user = [AccountUser getSingleton];
            
            user.netWorkStatus |=0x02;//被踢了
            
            [_client disconnect];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号已在其它地方登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 102;
            [alert show];
        }
        return;
    }
    
    if (currentDetail != nil && [currentDetail.currentFriend.friendID isEqualToString:friendID]) {
        
        switch (state) {
            case MIXEDCODING_STATE_MISSING:
                NSLog(@"MIXEDCODING_STATE_MISSING...");
                [self alert:@"error data!"];
                break;
            case MIXEDCODING_STATE_TEXT:
                NSLog(@"MIXEDCODING_STATE_TEXT...");
                [currentDetail addChatDetailText:recievedData];
                break;
            case MIXEDCODING_STATE_TEXTDATA:
                NSLog(@"MIXEDCODING_STATE_TEXTDATA...");
                [currentDetail addChatDetailTextAndData:recievedData];
                break;
                
            default:
                break;
        }
    }else{
        [self addUnreadMsg:recievedData];
    }
    
    if (currentDetail == nil) {
        [_tableView reloadData];
    }
}

- (void)addUnreadMsg:(NSDictionary *)dic
{
    NSString *jsonString = [dic objectForKey:JSONSTRING];
    NSMutableDictionary *msgInfo = [jsonString objectFromJSONString];
    NSString *friendID = [msgInfo objectForKey:MSG_KEY_FROM];
    
    if ([friendID isEqualToString:@"9998"]) {
        NSDictionary *msgContent = [msgInfo objectForKey:MSG_KEY_CONTENT];
        friendID = [msgContent objectForKey:@"numberid"];
        NSString *msgInfoString = [msgContent objectForKey:@"tips"];
        
        NSMutableDictionary *msgNewInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
        [msgNewInfo setObject:@"0" forKey:MSG_KEY_TYPE];
        [msgNewInfo setObject:msgInfoString forKey:MSG_KEY_CONTENT];
        [msgNewInfo setObject:friendID forKey:MSG_KEY_FROM];
        [msgNewInfo setObject:[msgInfo objectForKey:MSG_KEY_TO] forKey:MSG_KEY_TO];
        [msgNewInfo setObject:[msgInfo objectForKey:MSG_KEY_DATE] forKey:MSG_KEY_DATE];
        
        msgInfo = msgNewInfo;
        msgNewInfo = nil;
    }
    
    ChatFriend *friend = [[ChatListSaveProxy sharedChatListSaveProxy] getFriendByID:friendID];
    
    
    if (friend == nil) {
        
        FriendModel *newFriend = [[FriendModel alloc] init];
        newFriend.friendID = friendID;
        AccountUser *user = [AccountUser getSingleton];
        newFriend.masterID = user.numberID;
        [[ChatListSaveProxy sharedChatListSaveProxy] addFriend:newFriend];
        
        friend = [[ChatListSaveProxy sharedChatListSaveProxy] getFriendByID:friendID];
        
        [_rp getUserInfoByKey:@"numberid" andValue:friendID];
        
    }
    
    friend.lastDate = [NSDate date];
    friend.unread = friend.unread+1;
//    friend.lastMsg = @"new message";
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHECKUNREAD object:nil];
    
    //生成bubble，加入数据
    NSBubbleData *bubbleData;
    int state = [[dic objectForKey:MIXEDCODING_STATE] intValue];
    if (state == MIXEDCODING_STATE_MISSING) {
        NSLog(@"missing message data!");
        return;
    }else if (state == MIXEDCODING_STATE_TEXT){
        int type = [[msgInfo objectForKey:MSG_KEY_TYPE] intValue];
        if (type == TYPE_TEXT) {
            bubbleData = [[NSBubbleData alloc] initWithText:[msgInfo objectForKey:MSG_KEY_CONTENT] andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:nil withDataType:TYPE_TEXT];
            friend.lastMsg = [msgInfo objectForKey:MSG_KEY_CONTENT];
        }else if (type == TYPE_LOC){
            if(msgInfo) {
                if([msgInfo objectForKey:MSG_KEY_LATITUDE] == nil || [msgInfo objectForKey:MSG_KEY_LONGITUDE] == nil) {
                        NSLog(@"error position");
                       [self alert:@"invalid position data"];
                        return;
                }
            }
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[msgInfo objectForKey:MSG_KEY_LATITUDE] forKey:LOC_LATITUDE];
            [dictionary setObject:[msgInfo objectForKey:MSG_KEY_LONGITUDE] forKey:LOC_LONGITUDE];
            [dictionary setObject:[msgInfo objectForKey:MSG_KEY_CONTENT] forKey:LOC_DISCRIPTION];
            NSString *js = [dictionary JSONString];
            
            bubbleData = [[NSBubbleData alloc] initWithText:js andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:nil withDataType:TYPE_LOC];
            friend.lastMsg = @"[位置]";
        }
    }else if (state == MIXEDCODING_STATE_TEXTDATA){
        int type = [[msgInfo objectForKey:MSG_KEY_TYPE] intValue];
        switch (type) {
            case TYPE_PIC:
            {
                NSString *savePath = [self createSavePath:@"jpeg"];
                bubbleData = [[NSBubbleData alloc] initWithText:savePath andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:[dic objectForKey:FILEDATA] withDataType:type];
                bubbleData.urlString = [msgInfo objectForKey:MSG_KEY_URL];
                friend.lastMsg = @"[图片]";
                break;
            }
            case TYPE_VOICE:
            {
                bubbleData = [[NSBubbleData alloc] initWithText:nil andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:[dic objectForKey:FILEDATA] withDataType:type];
                bubbleData.length = [[msgInfo objectForKey:MSG_KEY_LENGTH] intValue];
                bubbleData.isNewMessage = YES;
                friend.lastMsg = @"[语音]";
                break;
            }
            case TYPE_VIDEO:
            {
                NSDate *now = [NSDate date];
                NSString *savePath = [self createSavePath:@"mp4"];
                bubbleData = [[NSBubbleData alloc] initWithText:savePath andDate:now andType:BubbleTypeSomeoneElse andData:[dic objectForKey:FILEDATA] withDataType:type];
                bubbleData.urlString = [msgInfo objectForKey:MSG_KEY_URL];
                bubbleData.length = [[msgInfo objectForKey:MSG_KEY_LENGTH] intValue];
                friend.lastMsg = @"[视频]";
                break;
            }
            default:
                break;
        }
    }
    if (bubbleData == nil) {
        [self alert:@"error data:bubbleData nil"];
    }else{
        [[ChatListSaveProxy sharedChatListSaveProxy] addMessage:bubbleData to:friend];
    }
    
    _friendList = [[ChatListSaveProxy sharedChatListSaveProxy] getFriends];
    [_tableView reloadData];
}

- (void)alert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
//    [alert release];
    
}

//UItableview datasource ,delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friendList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"friendCell";
    
    ChatFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[ChatFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    ChatFriend *friend = [_friendList objectAtIndex:indexPath.row];
    [cell.photoView setImageWithURL:USER_HEAD_IMG_URL(@"small", friend.photo) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    NSString *unreadStr = nil;
    if(friend.unread > 100) {
        unreadStr = @"99+";
    }else {
        unreadStr = [NSString stringWithFormat:@"%d", friend.unread];
    }
    if(friend.unread > 0) {
        CGRect unReadFrame = cell.photoView.frame;
        unReadFrame.origin.x = 0;
        unReadFrame.origin.y = -5;
        unReadFrame.size.width += 5;
        UIView *hint = [[CircleView alloc] initWithFrame:unReadFrame text:unreadStr radius:10];
        [hint setTag:11];
        [cell.photoView addSubview:hint];
    }else {
        for (UIView *v in [cell.photoView subviews]) {
            if(v.tag == 11) {
                [v removeFromSuperview];
            }
        }
    }
    
    [cell setName:friend.name];
    [cell setLastDate:friend.lastDate];
    //cell.lastMsgLabel.text = friend.lastMsg;
    cell.lastMsgLabel.text = @"";
    [self clearView:cell.lastMsgLabel];
    [Utility emotionAttachString:friend.lastMsg toView:cell.lastMsgLabel font:12 isCut:YES];
    
    if ([friend.sex isEqualToString:@"0"]) {
        UIImage *male = [UIImage imageNamed:@"user_male.png"];
        cell.sexView.image = male;
    }else if ([friend.sex isEqualToString:@"1"]){
        UIImage *female = [UIImage imageNamed:@"user_female.png"];
        cell.sexView.image = female;
    }
    
    return cell;
}

-(void)clearView:(UIView *)sv {
    for(UIView *v in [sv subviews]) {
        [v removeFromSuperview];
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[AccountUser getSingleton] MQTTconnected]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.detailsLabelText = @"加载中...";
        hud.removeFromSuperViewOnHide = YES;
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatFriend *friend = [_friendList objectAtIndex:indexPath.row];
    NSInteger a = 0;
    friend.unread = a;
//    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHECKUNREAD object:nil];
    
//    //处理MQTT服务器可以连接但是无法connect的状况
//    if (![[AccountUser getSingleton] MQTTconnected]) {
//        [Utility showHUD:@"聊天服务器有点累了\n请稍后再试试~"];
//        [tableView reloadData];
//        return;
//    }
    
    currentDetail = nil;
    currentDetail = [[DetailViewController alloc] initWithChatFriend:friend];
    currentDetail.delegate = self;
    currentDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:currentDetail animated:YES];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView setEditing:YES animated:YES];
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"delete...");
    ChatFriend *friend = [_friendList objectAtIndex:indexPath.row];
    
    [[ChatListSaveProxy sharedChatListSaveProxy] removeFriend:friend];
    
    _friendList = [[ChatListSaveProxy sharedChatListSaveProxy] getFriends];
    [_tableView reloadData];
}

- (NSString *)createSavePath:(NSString *)suffix
{
    //生成保存路径
    NSDate *now = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%f.%@",[now timeIntervalSince1970],suffix];
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [arr objectAtIndex:0];
    NSString *filePath;
    if ([suffix isEqualToString:@"mp4"]) {
        filePath = [documentDir stringByAppendingPathComponent:@"movie"];
    }else if ([suffix isEqualToString:@"jpeg"]){
        filePath = [documentDir stringByAppendingPathComponent:@"image"];
    }else if ([suffix isEqualToString:@"amr"]){
        filePath = [documentDir stringByAppendingPathComponent:@"voice"];
    }else{
        return @"suffix error!";
    }
    filePath = [filePath stringByAppendingPathComponent:fileName];
    NSLog(@"create recieve filePath:%@",filePath);
    return filePath;
}

- (void)addChatingFriend:(NSNotification *)notification
{
    NSLog(@"22222222222222222");
    FriendModel *fri = (FriendModel *)notification.object;
    NSLog(@"%@,%@",fri.name,fri.photo);
    ChatFriend *friend = [[ChatListSaveProxy sharedChatListSaveProxy] getFriendByID:fri.friendID];
    if (friend == nil) {
        [[ChatListSaveProxy sharedChatListSaveProxy] addFriend:fri];
        friend = [[ChatListSaveProxy sharedChatListSaveProxy] getFriendByID:fri.friendID];
    }
    
//    _friendList = [[ChatListSaveProxy sharedChatListSaveProxy] getFriends];
//    [_tableView reloadData];
    currentDetail = nil;
    currentDetail = [[DetailViewController alloc] initWithChatFriend:friend];
    currentDetail.delegate = self;
    currentDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationController pushViewController:currentDetail animated:YES];
//    [self.navigationController performSelector:@selector(pushViewController:animated:) withObject:currentDetail afterDelay:0.0];
    
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_USERINFO]) {
        
        NSDictionary *msgDic = [dic objectForKey:@"msg"];
        NSDictionary *infoDic = [msgDic objectForKey:@"info"];
        
        
        //添加新的friend
        ChatFriend *friend = [[ChatListSaveProxy sharedChatListSaveProxy] getFriendByID:[infoDic objectForKey:@"numberid"]];
        friend.name = [infoDic objectForKey:@"name"];
        friend.photo = [infoDic objectForKey:@"photo"];
        friend.sex = [infoDic objectForKey:@"sex"];
        friend.masterID = [AccountUser getSingleton].numberID;
        [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
        
        
        _friendList = [[ChatListSaveProxy sharedChatListSaveProxy] getFriends];
        [_tableView reloadData];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    
}

#pragma mark - MosquittoClientDelegate
- (void) didConnect: (NSUInteger)code
{
    NSLog(@"did connect...");
    
    AccountUser *user = [AccountUser getSingleton];
    user.MQTTconnected = YES;
    [_client subscribe:[NSString stringWithFormat:@"%@/%@",MQTTTopicHead,user.numberID] withQos:1];
}

-(BOOL)isConnect {
    BOOL ret = NO;
    AccountUser *user = [AccountUser getSingleton];
    
//    return NO;
    
    if(!(user.netWorkStatus & 0x01)) {
        [Utility hideWaitHUDForView];
        [Utility showHUD:@"抱歉，当前网络不可用，请检查网络连接."];
    }else if (reconnect && !(user.netWorkStatus & 0x02) && !(user.MQTTconnected)) {
        [_client connect];
        ret = user.MQTTconnected;
        if(!ret){
            [Utility hideWaitHUDForView];
            [Utility showHUD:@"抱歉，服务器秀逗了，请稍后..."];
        }
    }else if (user.netWorkStatus & 0x02) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号已在其它地方登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 102;
        [alert show];
    }else {
        ret = YES;
    }
    
    return ret;
}

- (void) didDisconnect
{
    NSLog(@"did disconnect...");
    AccountUser *user = [AccountUser getSingleton];
    user.MQTTconnected = NO;
//    if (reconnect && !(user.netWorkStatus & 0x01)) {
//        NSLog(@"reconnect...");
//        if (reconnectTimeB >= 30) {
//            reconnectTimeB = 30;
//        }
//        [_client performSelector:@selector(connect) withObject:nil afterDelay:reconnectTimeB];
//        reconnectTimeB = reconnectTimeA + reconnectTimeB;
//        reconnectTimeA = reconnectTimeB - reconnectTimeA;
//    }
}

- (void) didPublish: (NSUInteger)messageId
{
    NSLog(@"didPublish :%d",messageId);
}

- (void) didReceiveData:(NSData *)keyData onTopic:(NSString *)topic
{
    [self session:nil newMessage:keyData onTopic:topic];
    NSLog(@"新数据!!!!");
//    NSDictionary *dic = [MixedCoding decoding:keyData];
//    NSLog(@"dic:%@",dic);
}

- (void) didReceiveMessage: (MosquittoMessage*)mosq_msg
{
    NSLog(@"did receive message...%@",[mosq_msg description]);
    NSDictionary *dic = [MixedCoding decoding:mosq_msg.data];
    NSLog(@"dic :%@",dic);
}

- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray *)qos
{
    
}

- (void) didUnsubscribe: (NSUInteger)messageId
{
    
}

-(void)didLog:(NSString*)msg {
    NSLog(@"%@", msg);
}

- (void)distroyMQTT{
    [_client.timer invalidate];
}

- (void)handleLogout{
    [_client.timer invalidate];
    [_client.connectTestTimer invalidate];
    [_client disconnect];
    _client = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            reconnectTimeA = 1;
            reconnectTimeB = 1;
            reconnect = YES;
            [_client connect];
        }
    }else if (alertView.tag == 102){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_LOGOUT object:nil];
    }
    if (1 == alertView.tag) {
        if (1 == buttonIndex) {
            [self copy:qrText];             //拷贝信息到粘贴板
        }else{
            return;
        }
    }
}

- (void)handleConnectMQTTNotification:(NSNotification *)notification
{
//    [Utility showHUD:@"私聊服务正在连接"];
//    [SVProgressHUD showWithStatus:@"私聊服务正在连接"];
    reconnectTimeA = 1;
    reconnectTimeB = 1;
    reconnect = YES;
//    [_client connect];
}

#pragma mark
#pragma mark 扫描二维码实现

// - (void)scan{
//     
// }
//执行扫描功能

 - (void)scan{
     ZBarReaderViewController *reader = [ZBarReaderViewController new];
     reader.videoQuality = 0;
     reader.readerDelegate = self;
     reader.supportedOrientationsMask = ZBarOrientationMaskAll;
     reader.cameraFlashMode = -1;
     ZBarImageScanner *scanner = reader.scanner;
     
     
     UIView *view = [[UIView alloc]initWithFrame:reader.view.frame];
     view.backgroundColor = [UIColor blackColor];
     [scanner setSymbology: ZBAR_I25 config: ZBAR_CFG_ENABLE to: 0];
     
     [self presentModalViewController: reader animated: YES];
 }
 
 //扫描后数据处理
 - (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
 {
     id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
     ZBarSymbol *symbol = nil;
     for(symbol in results)
         break;
     NSLog(@"%@",symbol.data);
     NSString *s = [[Utility qrAnalyse:symbol.data] objectForKey:@"type"];
     if ( 2 == [s intValue]) {
         PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
         personInfoView.hidesBottomBarWhenPushed = YES;
         [self.navigationController pushViewController:personInfoView animated:YES];
     }else if (1 == [s intValue]){
         ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
         clubInfoView.hidesBottomBarWhenPushed = YES;
         [self.navigationController pushViewController:clubInfoView animated:YES];
     }else{
         UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"] AndTitle:@"扫描二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
         alert.tag = 1;
         qrText = [[Utility qrAnalyse:symbol.data] objectForKey:@"id"];
     }
     
     [reader dismissModalViewControllerAnimated: YES];
 }

//拷贝函数执行
-(void)copy:(NSString*)str {
    
    NSString *copyString = [[NSString alloc] initWithFormat:@"%@",str];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyString];
}
 
// - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
// if (1 == alertView.tag) {
// if (1 == buttonIndex) {
// [self copy:qrText];             //拷贝信息到粘贴板
// }else{
// return;
// }
// }
// return;
// }

@end
