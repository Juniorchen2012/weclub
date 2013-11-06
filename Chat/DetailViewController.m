//
//  DetailViewController.m
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "DetailViewController.h"
#import "DAKeyboardControl.h"
#import "Header.h"
#import "PersonInfoViewController.h"
#import "MsgResender.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize delegate = _delegate;
@synthesize currentFriend = _currentFriend;
@synthesize followKeyBoard;
@synthesize coverButton;

+ (UIViewController *)getDetailViewController
{
    if (nil != self) {
        return self;
    }
}

#pragma mark - Init
- (id)initWithChatFriend:(ChatFriend *)f
{
    self = [super init];
    if (self) {
        _currentFriend = f;
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        
        [_rp testPrivateLetterWithNumberID:_currentFriend.friendID];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

#pragma mark - ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CHECKUNREAD object:nil];
//    self.view.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1];
    self.view.backgroundColor = [UIColor whiteColor];

    bubbleSourceData = [[NSMutableArray alloc] initWithArray:[_currentFriend getBubbleDataArray]];
    bubbleData = [[NSMutableArray alloc] initWithArray:[_currentFriend getLatestDataArray:10]];
    indexPage = [_currentFriend getPageCount:bubbleSourceData count:10] - 1;
    
//    bubbleData = [[NSMutableArray alloc] init];
//    [bubbleData addObjectsFromArray:[_currentFriend getBubbleDataArray]];
    
    followKeyBoard = false;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    bubbleView = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-109) andSomeOne:_currentFriend viewController:self];
    bubbleView.bubbleDataSource = self;
    bubbleView.navDelegate = self;
    bubbleView.backgroundColor = [UIColor clearColor];
    [bubbleView setHidden:NO];
    
    __block typeof(self)bself = self;
//    [bubbleView addPullToRefreshWithActionHandler:^{
//        if (bself.bubbleView.pullToRefreshView.state == SVPullToRefreshStateLoading) {
////            if (indexPage <= 0) {
////                [bself.bubbleView.pullToRefreshView setState:SVPullToRefreshStateStopped];
////                [bself.bubbleView.pullToRefreshView stopAnimating];
////            }
//            if([bself respondsToSelector:@selector(loadRecord)]) {
//                [bself performSelector:@selector(loadRecord)];
//            }
//        }
//
//    }];
    
    [self.view addSubview:bubbleView];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
//    [bubbleView.backgroundView addGestureRecognizer:tap];
//    [tap release];

//    bigButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    bigButton.frame = bubbleView.frame;
//    [bigButton addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchDown];
//    [bubbleView addSubview:bigButton];
    
    coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    coverButton.frame = bubbleView.frame;
    [coverButton addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [coverButton setHidden:YES];
    [self.view addSubview:coverButton];
    
    self.view.keyboardTriggerOffset = chatInput.normalInput.bounds.size.height;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        BOOL coverBlock = bself.followKeyBoard;
        if (coverBlock) {
            return;
        }
        CGRect toolBarFrame = chatInput.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - chatInput.normalInput.frame.size.height;
        chatInput.frame = toolBarFrame;
        
        CGRect tableViewFrame = bubbleView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y;
        bubbleView.frame = tableViewFrame;
        float offsetY = bubbleView.contentSize.height-bubbleView.frame.size.height;
        bubbleView.contentOffset = CGPointMake(0, offsetY>0?offsetY:0);
        
        coverButton.frame = bubbleView.frame;
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (chatInput.frame.origin.y != screenSize.height - 109 -(chatInput.normalInput.frame.size.height-45)) {
            [bself.coverButton setHidden:NO];
        }else{
            [bself.coverButton setHidden:YES];
        }
    }];

    
    chatInput = [[ChatInputView alloc] init];
    chatInput.delegate = self;
    [chatInput addObserver:self forKeyPath:@"recording" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.view addSubview:chatInput];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard) name:HIDEKEYBOARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushView:) name:PUSHVIEW object:nil];
    
    
    // Do any additional setup after loading the view from its nib.
    [bubbleView addPullToRefreshWithActionHandler:^{
        NSLog(@"bubbleView refresh...");
        [bself loadRecord];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [Utility hideWaitHUDForView];
    [bubbleView setHidden:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //修改Navigation的控件与用户名称
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 200, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont systemFontOfSize:20];
    headerLabel.text = _currentFriend.name;
    self.navigationItem.titleView = headerLabel;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    //=============================右上角目录按钮==========================================
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, 30, 30);
    [menuButton setImage:[UIImage imageNamed:@"rightitem.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showTitleViews) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:menuButton];
    self.navigationItem.rightBarButtonItem = rightbtn;
    
    _menuItemArray = [NSMutableArray arrayWithObjects:@"对方详细信息", @"清除聊天记录", nil];
    
    titleViews = [[UIView alloc]initWithFrame:CGRectMake(320-140, 4, 140, 40*[_menuItemArray count])];
    titleViews.backgroundColor = TINT_COLOR;
    holeView = [[UIControl alloc]initWithFrame:CGRectMake(0, 60, 320, myConstants.screenHeight)];
    
    UIView *line;
    
    friendInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendInfoBtn.frame = CGRectMake(0, 40*0, 140, 40);
    friendInfoBtn.tag = 2;
    [friendInfoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [friendInfoBtn setTitle:[_menuItemArray  objectAtIndex:0] forState:UIControlStateNormal];
    [friendInfoBtn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(1), 140, 1)];
    line.backgroundColor = [UIColor blackColor];
    [titleViews addSubview:line];
    [titleViews addSubview:friendInfoBtn];
    
    cleanChatDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cleanChatDetailBtn.frame = CGRectMake(0, 40*1, 140, 40);
    cleanChatDetailBtn.tag = 1;
    [cleanChatDetailBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cleanChatDetailBtn setTitle:[_menuItemArray  objectAtIndex:1] forState:UIControlStateNormal];
    [cleanChatDetailBtn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(2), 140, 1)];
    line.backgroundColor = [UIColor blackColor];
    [titleViews addSubview:line];
    [titleViews addSubview:cleanChatDetailBtn];
    
    holeView.backgroundColor = [UIColor clearColor];
    [holeView addSubview:titleViews];
    [holeView addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBarController.view addSubview:holeView];
    holeView.hidden = YES;
    //=============================右上角目录按钮==========================================
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [chatInput stopRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DestoryView
- (void)dealloc
{
    _delegate = nil;
    bubbleView = nil;
    bubbleData = nil;
    [chatInput removeObserver:self forKeyPath:@"recording"];
    chatInput = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDEKEYBOARD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PUSHVIEW object:nil];
}

#pragma mark - JunmpToOtherView
//退出当前界面
- (void)popViewController
{
    //处理当前正在播放音频的情况
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_STOPCHAT object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_STOPVOICE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:chatInput name:NOTIFICATION_KEY_SEND_TEXT object:nil];
//    if (chatInput.recording) {
//        chatInput.dr
//    }
    [self hideTitleViews];
    [self.navigationController popViewControllerAnimated:YES];
    _delegate = nil;
    bubbleView.dataSource = nil;
    bubbleView.bubbleDataSource = nil;
    bubbleView = nil;
    bubbleData = nil;
    bubbleSourceData = nil;
    chatInput = nil;
}

//显示指定界面
- (void)pushView:(NSNotification *)notification
{
    NSLog(@"push view...");
//    NSString *aaa = (NSString *)notification.object;
//    NSLog(@"aaa:%@",aaa);
    if (![notification.object isKindOfClass:[UIViewController class]]) {
        return;
    }
    UIViewController *viewToPush = (UIViewController *)notification.object;
    [self.navigationController pushViewController:viewToPush animated:YES];
}

//隐藏键盘
- (void)hideKeyBoard
{
    [coverButton setHidden:YES];
    NSLog(@"hideKeyBoard...");
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    followKeyBoard = NO;
    if (chatInput.isKeyBoardShow) {
        [chatInput.textToSend resignFirstResponder];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        CGRect r = chatInput.frame;
        r.origin.y = screenSize.height - 109-(chatInput.normalInput.frame.size.height-45);
        chatInput.frame = r;
        
        CGRect rect = bubbleView.frame;
        rect.size.height = r.origin.y;
        bubbleView.frame = rect;
        
        coverButton.frame = bubbleView.frame;
        [UIView commitAnimations];
    }
}

- (void)showExtra:(BOOL)extra
{
    followKeyBoard = extra;
}


#pragma mark - ChatInfomationController
//添加文字或者位置信息
- (void)addChatDetailText:(NSDictionary *)chatDetail
{
    //获取当前数据信息
    NSString *jsonString = [chatDetail objectForKey:JSONSTRING];
    NSLog(@"jsonString:%@",jsonString);
    
    NSDictionary *dic = [jsonString objectFromJSONString];
    
//    NSLog(@"dic:%@",dic);
    NSBubbleData *data;
    NSString *recievedString = [dic objectForKey:MSG_KEY_CONTENT];
    int type = [[dic objectForKey:MSG_KEY_TYPE] intValue];
    //添加文字信息
    switch (type) {
        case TYPE_TEXT:{
            //按照文字信息解析数据
            data = [[NSBubbleData alloc] initWithText:recievedString andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:nil withDataType:TYPE_TEXT];
            self.currentFriend.lastMsg = recievedString;
            break;
        }
        case TYPE_LOC:{
            if([dic objectForKey:MSG_KEY_LONGITUDE] == nil || [dic objectForKey:MSG_KEY_LATITUDE] == nil) {
                NSLog(@"error location");
                [self alertString:@"received invalid msg"];
                return;
            }
            //解析位置信息（经度，纬度，地点描述）
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[dic objectForKey:MSG_KEY_LATITUDE] forKey:LOC_LATITUDE];
            [dictionary setObject:[dic objectForKey:MSG_KEY_LONGITUDE] forKey:LOC_LONGITUDE];
            [dictionary setObject:[dic objectForKey:MSG_KEY_CONTENT] forKey:LOC_DISCRIPTION];
            NSString *js = [dictionary JSONString];
            //按照位置信息解析数据
            data = [[NSBubbleData alloc] initWithText:js andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:nil withDataType:TYPE_LOC];
            self.currentFriend.lastMsg = @"[位置]";
            break;
        }
//        case TYPE_SYSTEM:{
//            //按照系统数据解析数据，以文字形式发送数据
//            //更新发送信息
//            recievedString = @"您的好友刚刚加入微俱，快跟小伙伴联系起来吧~/n【微俱系统通知】";
//            
//            data = [[NSBubbleData alloc] initWithText:recievedString andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:nil withDataType:TYPE_TEXT];
//            self.currentFriend.lastMsg = recievedString;
//            break;
//        }
        default:
            break;
    }
    
    //设置当前数据为对方最后一条聊天记录
    self.currentFriend.lastDate = [NSDate date];
    
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    
    [[ChatListSaveProxy sharedChatListSaveProxy] addMessage:data to:_currentFriend];
    [bubbleData addObject:data];
    [bubbleView reloadData];
    
}

//添加聊天图片，音频和视频信息
- (void)addChatDetailTextAndData:(NSDictionary *)chatDetail
{
    //获取数据信息并解析
    NSString *jsonString = [chatDetail objectForKey:JSONSTRING];
    NSDictionary *dic = [jsonString objectFromJSONString];
    
    NSInteger type = [[dic objectForKey:MSG_KEY_TYPE] intValue];
    NSLog(@"msgType:%d",type);
    NSLog(@"recieve json:%@",dic);
    
    NSBubbleData *data;
    
    switch (type) {
        //添加照片信息
        case TYPE_PIC:
        {
            NSString *savePath = [self createSavePath:@"jpeg"];
            data = [[NSBubbleData alloc] initWithText:savePath andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:[chatDetail objectForKey:FILEDATA] withDataType:type];
            data.urlString = [dic objectForKey:MSG_KEY_URL];
            self.currentFriend.lastMsg = @"[图片]";
            break;
        }
        //添加视频信息
        case TYPE_VOICE:
        {
            data = [[NSBubbleData alloc] initWithText:nil andDate:[NSDate date] andType:BubbleTypeSomeoneElse andData:[chatDetail objectForKey:FILEDATA] withDataType:type];
            data.length = [[dic objectForKey:MSG_KEY_LENGTH] intValue];
            self.currentFriend.lastMsg = @"[语音]";
            data.isNewMessage = YES;
            break;
        }
        //添加视频信息
        case TYPE_VIDEO:
        {
            NSDate *now = [NSDate date];
            NSString *savePath = [self createSavePath:@"mp4"];
            data = [[NSBubbleData alloc] initWithText:savePath andDate:now andType:BubbleTypeSomeoneElse andData:[chatDetail objectForKey:FILEDATA] withDataType:type];
            data.urlString = [dic objectForKey:MSG_KEY_URL];
            data.length = [[dic objectForKey:MSG_KEY_LENGTH] intValue];
            self.currentFriend.lastMsg = @"[视频]";
            break;
        }
        default:
            break;
    }
    
    self.currentFriend.lastDate = [NSDate date];
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    
    [[ChatListSaveProxy sharedChatListSaveProxy] addMessage:data to:_currentFriend];
    [bubbleData addObject:data];
    [bubbleView reloadData];
    
}

//生成保存路径
- (NSString *)createSavePath:(NSString *)suffix
{
    //获取当前数据
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

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
//    NSLog(@"length:%d",[bubbleData count]);
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}
- (UIViewController *)getController
{
    return self;
}

-(BOOL)isConnect {
    return [_delegate isConnect];
}

//加载更多的数据（+10）
-(void)loadRecord {
    if (indexPage <= 0) {
        [bubbleView.pullToRefreshView stopAnimating];
//        [MBProgressHUD hideAllHUDsForView:bubbleView animated:YES];
//        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        return;
    }else {
        indexPage--;
    }
    NSArray *loadData = [_currentFriend loadPageData:bubbleSourceData index:indexPage count:10];
    [bubbleData addObjectsFromArray:loadData];
    [bubbleView refreshMove:NO cleanData:NO];
    [bubbleView.pullToRefreshView stopAnimating];
//    [MBProgressHUD hideAllHUDsForView:bubbleView animated:YES];
//    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

#pragma mark - ChatInputViewDelegate implementation

//发送文字信息
- (void)sendText:(NSString *)string
{
    //查看是否有权限与此用户私聊
//    if (!_authority) {
//        [self alertString:@"没有权限与该用户私聊"];
//        return;
//    }
    //获取文字信息数据
    NSBubbleData *data = [[NSBubbleData alloc] initWithText:string andDate:[NSDate date] andType:BubbleTypeMine andData:nil withDataType:TYPE_TEXT];
    NSString *mid = nil;
    //判断是否连接，若未连接则为当前数据获取mid
    if(![_delegate isConnect]) {
        mid = [[MsgResender sharedInstance] genMySendId];
        data.mid = mid;
    }
    
    [[ChatListSaveProxy sharedChatListSaveProxy] addMessage:data to:_currentFriend];
    [bubbleData addObject:data];
    [bubbleView reloadData];
    
    self.currentFriend.lastDate = [NSDate date];
    self.currentFriend.lastMsg = string;
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    NSDate *now = [NSDate date];
    
    [dic setObject:[NSNumber numberWithInt:TYPE_TEXT] forKey:MSG_KEY_TYPE]; //发送类型
    [dic setObject:[NSNumber numberWithFloat:[now timeIntervalSince1970]] forKey:MSG_KEY_DATE]; //发送日期
    [dic setObject:string forKey:MSG_KEY_CONTENT];  //发送内容
    [dic setObject:[AccountUser getSingleton].numberID forKey:MSG_KEY_FROM];    //发送人
    [dic setObject:_currentFriend.friendID forKey:MSG_KEY_TO];  //接受人
    AccountUser *user = [AccountUser getSingleton]; 
    NSString *sessionid = user.cookie.value;
    if (sessionid != nil && [sessionid isKindOfClass:[NSString class]]) {
//        [dic setObject:sessionid forKey:MSG_KEY_SESSIONID];
    }
    
    NSString *jsonString = [dic JSONString];
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,_currentFriend.friendID ];
    //如果MQTT服务器出于连接状态存储数据（存储在文件中）
    if(mid) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", nil]];
        [[MsgResender sharedInstance] retainMessage:dic Mid:mid];
    }
    
    //发送数据
    [_delegate publishText:jsonString To:receiver];
//    [[ChatMessageProxy sharedChatMessageProxy] sentTextMessage:string toFriend:_currentFriend];
    
}

//重新发送信息
-(void)resendMsg:(NSString *)mid {
    if (![_delegate isConnect]) {
        return;
    }
    NSDictionary *dic = [[MsgResender sharedInstance] getSendMessage:mid];
    if(dic) {
        NSData *data = [dic objectForKey:@"data"];
        NSString *json = [dic objectForKey:@"json"];
        NSString *receiver = [dic objectForKey:@"receiver"];
        if ([json isEqualToString:@""] || [receiver isEqualToString:@""]) {
            [self alertString:@"重发数据有错误！此条记录无法重发"];
            return;
        }
        if(data) {
            [_delegate publishText:json AndData:data To:receiver];
        }else {
            [_delegate publishText:json To:receiver];
        }
    }
    [bubbleView reloadData];
}

//发送视频和音频和照片
- (void)sendData:(NSData *)data withType:(NSInteger)type andFilePath:(NSString *)filePath andTimeLength:(float)timeLegnth
{
    NSBubbleData *bdata;
    NSString *mid = nil;
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,_currentFriend.friendID];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (type == TYPE_VIDEO) {
        //生成视频缩略图
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
        player.shouldAutoplay = NO;
        UIImage *img = [player thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];
        [player stop];
        player = nil;
        
        CGSize thumbSize = [Utility calSaveThumbSize:img.size];
        UIGraphicsBeginImageContext(CGSizeMake(thumbSize.width, thumbSize.height));
        [img drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
//        NSLog(@"newImg size:%f,%f",newImg.size.width,newImg.size.height);
        
//        NSData *thumbImg = UIImageJPEGRepresentation(img, 0.1);
//        NSLog(@"thumb length:%d",thumbImg.length);
        NSData *newThumb = UIImageJPEGRepresentation(newImg, 0.3);
        NSLog(@"newThumb length:%d",newThumb.length);
//        UIImageWriteToSavedPhotosAlbum(newImg, self, nil, nil);
        
        //添加到显示列表中
        bdata = [[NSBubbleData alloc] initWithText:filePath andDate:[NSDate date] andType:BubbleTypeMine andData:newThumb withDataType:type];
        self.currentFriend.lastMsg = @"[视频]";
        NSLog(@"Video Data %d", data.length);
        
    }else if(type == TYPE_PIC){
        //生成图片的缩略图
        UIImage *oldImg = [UIImage imageWithData:data];
        CGSize thumbSize = [Utility calSaveThumbSize:oldImg.size];
        UIGraphicsBeginImageContext(thumbSize);
        [oldImg drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
        UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *thumbData = UIImageJPEGRepresentation(newImg, 0.5);
        NSLog(@"data length:%d",data.length);
        NSLog(@"thumbData length:%d,size:%f,%f",thumbData.length,newImg.size.width,newImg.size.height);
        
        bdata = [[NSBubbleData alloc] initWithText:filePath andDate:[NSDate date] andType:BubbleTypeMine andData:thumbData withDataType:type];
        self.currentFriend.lastMsg = @"[图片]";

    }else if (type == TYPE_VOICE){
        bdata = [[NSBubbleData alloc] initWithText:filePath andDate:[NSDate date] andType:BubbleTypeMine andData:data withDataType:type];
        bdata.length = timeLegnth;
        [dic setObject:[NSNumber numberWithInt:bdata.length * 1000] forKey:MSG_KEY_LENGTH];
        self.currentFriend.lastMsg = @"[语音]";

    }
    NSDate *now = [NSDate date];
    
    [dic setObject:[NSNumber numberWithInt:type] forKey:MSG_KEY_TYPE];
    [dic setObject:[NSNumber numberWithFloat:[now timeIntervalSince1970]] forKey:MSG_KEY_DATE];
    [dic setObject:@"" forKey:MSG_KEY_CONTENT];
    [dic setObject:[AccountUser getSingleton].numberID forKey:MSG_KEY_FROM];
    [dic setObject:_currentFriend.friendID forKey:MSG_KEY_TO];
    AccountUser *user = [AccountUser getSingleton];
    NSString *sessionid = user.cookie.value;
    if (sessionid != nil && [sessionid isKindOfClass:[NSString class]]) {
        [dic setObject:sessionid forKey:MSG_KEY_SESSIONID];
    }
    if (type == TYPE_VIDEO) {
        
        //获取视频的时长
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
        
        int dur = asset.duration.value/asset.duration.timescale;
        int len = dur<=0 ? 1 : dur;
        
        [dic setObject:[NSNumber numberWithInt:len] forKey:MSG_KEY_LENGTH];
        bdata.length = len;
        
        //获取视频方向
        int rotateAngle = 0;
        NSArray *arr = [asset tracks];
        NSLog(@"arr length :%d",[arr count]);
        if ([arr count] != 0) {
            for (AVAssetTrack *track in arr) {
                CGAffineTransform m = track.preferredTransform;
                
                //判断视频方向
                if (m.a == 0 && m.b == 1 && m.c == -1 && m.d == 0) {
                    rotateAngle = -90;
                }else if (m.a == 0 && m.b == -1 && m.c == 1 && m.d == 0) {
                    rotateAngle = 90;
                }else if (m.a == -1 && m.b == 0 && m.c == 0 && m.d == -1){
                    rotateAngle = 180;
                }
            }
            
        }

        [dic setObject:[NSNumber numberWithInt:rotateAngle] forKey:MSG_KEY_ORI];
        [dic setObject:[NSNumber numberWithInt:1] forKey:MSG_KEY_PHONE];
    }
    
    NSString *jsonString = [dic JSONString];
    
    if(![_delegate isConnect]){
        mid = [[MsgResender sharedInstance] genMySendId];
        bdata.mid = mid;
    }
    
    if (type == TYPE_PIC || type == TYPE_VIDEO) {
//        [_delegate postText:dic AndData:data To:[NSString stringWithFormat:@"%@/%@",MQTTTopicHead,_currentFriend.friendID]];
        bdata.msgToPost = jsonString;
        bdata.needToPost = YES;
        bdata.requestIndex = -1;
    }else if (type == TYPE_VOICE){
        [_delegate publishText:jsonString AndData:data To:receiver];
    }

    if(mid && (jsonString != nil && receiver != nil && data != nil)) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, data, nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", @"data", nil]];
        [[MsgResender sharedInstance] retainMessage:dic Mid:mid];
    }
    NSLog(@"send jsonString:%@", jsonString);
    self.currentFriend.lastDate = now;
    
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    [[ChatListSaveProxy sharedChatListSaveProxy] addMessage:bdata to:_currentFriend];
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    [bubbleData addObject:bdata];
    [bubbleView reloadData];
    
}

//发送地理位置
- (void)sendLocation:(NSDictionary *)dic
{
    NSString *mid = nil;
    //添加到显示列表中
    NSBubbleData *bdata = [[NSBubbleData alloc] initWithText:[dic JSONString] andDate:[NSDate date] andType:BubbleTypeMine andData:nil withDataType:TYPE_LOC];
    if(![_delegate isConnect]) {
        mid = [[MsgResender sharedInstance] genMySendId];
        bdata.mid = mid;
    }
    [[ChatListSaveProxy sharedChatListSaveProxy] addMessage:bdata to:_currentFriend];
    [bubbleData addObject:bdata];
    [bubbleView reloadData];
    
    self.currentFriend.lastDate = [NSDate date];
    self.currentFriend.lastMsg = @"[位置]";
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSDate *now = [NSDate date];
    
    [dictionary setObject:[NSNumber numberWithInt:TYPE_LOC] forKey:MSG_KEY_TYPE];
    [dictionary setObject:[NSNumber numberWithFloat:[now timeIntervalSince1970]] forKey:MSG_KEY_DATE];
    [dictionary setObject:[dic objectForKey:LOC_DISCRIPTION] forKey:MSG_KEY_CONTENT];
    [dictionary setObject:[dic objectForKey:LOC_LATITUDE] forKey:MSG_KEY_LATITUDE];
    [dictionary setObject:[dic objectForKey:LOC_LONGITUDE] forKey:MSG_KEY_LONGITUDE];
    [dictionary setObject:[AccountUser getSingleton].numberID forKey:MSG_KEY_FROM];
    [dictionary setObject:_currentFriend.friendID forKey:MSG_KEY_TO];
    AccountUser *user = [AccountUser getSingleton];
    NSString *sessionid = user.cookie.value;
    if (sessionid != nil && [sessionid isKindOfClass:[NSString class]]) {
        [dictionary setObject:sessionid forKey:MSG_KEY_SESSIONID];
    }
    
    NSString *jsonString = [dictionary JSONString];
    NSString *receiver = [NSString stringWithFormat:@"%@/%@",MQTTTopicHead,_currentFriend.friendID];
    if(mid) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:jsonString, receiver, nil] forKeys:[NSArray arrayWithObjects:@"json", @"receiver", nil]];
        [[MsgResender sharedInstance] retainMessage:dic Mid:mid];
    }
    
    [_delegate publishText:jsonString To:receiver];
}

- (void)changeBubbleView:(CGFloat)y
{
    CGRect rect = bubbleView.frame;
    rect.size.height = y;
    bubbleView.frame = rect;
    coverButton.frame = bubbleView.frame;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (chatInput.frame.origin.y != screenSize.height - 109-(chatInput.normalInput.frame.size.height-45)) {
        [coverButton setHidden:NO];
    }else{
        [coverButton setHidden:YES];
    }
    float offsetY = bubbleView.contentSize.height-bubbleView.frame.size.height;
    bubbleView.contentOffset = CGPointMake(0, offsetY>0?offsetY:0);
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    if ([type isEqualToString:REQUEST_TYPE_PRIVATE_LETTER]) {
        NSString *pass = [[NSString alloc] initWithFormat:@"%@",[dic objectForKey:@"pass"]];
        
        if ([pass isKindOfClass:[NSString class]] && [pass isEqualToString:@"1"]) {
            //有私聊权限
            _authority = YES;
            NSDictionary *arrayMessage = [dic objectForKey:@"msg"];
            self.currentFriend.photo = [arrayMessage objectForKey:@"photo"];
            //FIXME:更新用户头像
            [bubbleView reloadData];
        }else if([pass isKindOfClass:[NSString class]] && [pass intValue] <= 0){
            //没有私聊权限
            _authority = NO;
            NSArray *arrayMessage = [[NSArray alloc] initWithArray:[dic objectForKey:@"msg"]];
            NSString *passMessage = [[NSString alloc] initWithFormat:@"%@",[arrayMessage objectAtIndex:0]];
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:nil message:passMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 110;
            [alert show];
        }else{
            NSLog(@"else");
        }
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器请求异常，请稍后再试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 110;
    [alert show];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器请求失败，请稍后再试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 110;
    [alert show];
}

- (void)alertString:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 110;
    [alert show];
    
}

- (BOOL)checkMQTTConnected
{
    AccountUser *user = [AccountUser getSingleton];
    if (!user.MQTTconnected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"私聊服务未连接，是否连接？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"连接", nil];
        alert.tag = 101;
        [alert show];
    }
    return user.MQTTconnected;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 101:
            //提示是否重新连接网络
            if (buttonIndex == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CONNECTMQTT object:nil];
            }
            break;
        case 102:
            //提示是否清空聊天记录
            if (buttonIndex == 1) {
                //停止所有的音频播放
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_STOPVOICE object:nil];
                
                [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
                [[ChatListSaveProxy sharedChatListSaveProxy] removeFriendMessages: self.currentFriend];
                [bubbleData removeAllObjects];
                [self.currentFriend setLastMsg:@" "];
                [self.currentFriend setLastDate:nil];
                [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
                [bubbleView reloadData];
            }
            break;
        case 110:{
            //请求失败或者没有权限私聊后的处理
            if (!_authority && buttonIndex == 0) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [Utility hideWaitHUDForView];
                [chatInput.textToSend setEditable:NO];
                [chatInput.voiceChatButton setEnabled:NO];
                [chatInput.extraButton setEnabled:NO];
//                [self popViewController];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - MenuButton
- (void)changeList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 1:
        {
//            //清屏
//            [bubbleView cleanData];//点击返回后再点击此用户清屏的信息还会回来
            //清除聊天记录
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否清除与此用户的所有聊天记录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
            alert.tag = 102;
            [alert show];
            break;
        }
        case 2:
        {
            //跳转到个人信息界面
            NSString *numberID = [_currentFriend friendID];
            if (numberID == nil) {
                [self alertString:@"没有numberid"];
                return;
            }
            PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] initWithNumberID:numberID];
            personInfo.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:personInfo animated:YES];
            break;
        }
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        default:
            break;
    }
    [self hideTitleViews];
}

//标题栏弹出隐藏处理
- (void)showTitleViews{
    if (holeView.hidden) {
        [holeView.layer addAnimation:[Utility createAnimationWithType:kCATransitionReveal withsubtype:kCATransitionFromTop withDuration:0] forKey:@"animation"];
        holeView.hidden = NO;
    }
    else{
        [self hideTitleViews];
    }
    
}

//标题栏隐藏处理
- (void)hideTitleViews{
    holeView.hidden = YES;
    //[[EGOCache currentCache]clearCache];
}

#pragma mark - 其他功能  -

#pragma mark 展现用户信息
-(void)showChatUserInfo:(id)user {
    if([user class] == [ChatFriend class]) {
        ChatFriend *friend = (ChatFriend *)user;
        PersonInfoViewController *v = [[PersonInfoViewController alloc] initWithNumberID:friend.friendID];
        [self.navigationController pushViewController:v animated:YES];
        return;
    }
    if([user class] == [AccountUser class]) {
        AccountUser *me = (AccountUser*)user;
        PersonInfoViewController *v = [[PersonInfoViewController alloc] initWithNumberID:me.numberID];
        [self.navigationController pushViewController:v animated:YES];
        return;
    }
    
    return;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"recording"]) {
        NSLog(@"changeUserInteraction %d:%@", ![[change objectForKey:@"new"] intValue], change);
        bubbleView.userInteractionEnabled = ![[change objectForKey:@"new"] intValue];
    }
}

@end
