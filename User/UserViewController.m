//
//  UserViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoticeView:) name:NOTIFICATION_KEY_UPDATENOTICE object:nil];
        
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _userList = [[UserListViewController alloc] init];
    _userList.hidesBottomBarWhenPushed = YES;
    
    if (!_chatView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_DISTORYMQTTCONNECT object:nil];
        _chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
    }
    _chatView.hidesBottomBarWhenPushed = YES;
    
    if (![[AccountUser getSingleton] MQTTconnected]) {
        _aheadTitleStr = @"私聊(未连接)";
    }
    else{
        _aheadTitleStr = @"私聊";
    }
    
    self.tabBar.alpha = 0;
    self.tabBar.hidden = YES;

    NSArray *barItemArray = [NSArray arrayWithObjects:_userList, _chatView, nil];
    self.viewControllers = barItemArray;
    self.selectedIndex = 1;
    [_changeViewButton setHidden:YES];
    for (UIView *v in self.view.subviews) {
        NSLog(@"bb:%f,%f,%f,%f",v.frame.origin.x,v.frame.origin.y,v.frame.size.width,v.frame.size.height);
        CGRect f = v.frame;
        if (f.size.height == 49) {
            f.origin.y = f.origin.y + 49;
        }else{
            f.size.height = f.size.height + 49;
        }
        v.frame = f;
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserListNotification:) name:NOTIFICATION_KEY_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserListNotification:) name:NOTIFICATION_KEY_USERLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToChatTab:) name:NOTIFICATION_KEY_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToFollowTab) name:NOTIFICATION_KEY_FOLLOWLIST object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToAttentionTab) name:NOTIFICATION_KEY_ATTENTIONLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeChatPageTitle:) name:NOTIFICATION_KEY_MQTT_CONNECT_STATE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNotifications) name:NOTIFICATION_KEY_LOGOUT object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.isIFollowUser) {
        [self switchToAttentionTab];
    }
    if (self.isFollowMeUser) {
        [self switchToFollowTab];
    }
    [super viewWillAppear:animated];
    myConstants = [Constants getSingleton];
    
    //搜索按钮
    UIButton *searchClubBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchClubBtn.frame = CGRectMake(0, 0, 30, 30);
    [searchClubBtn setBackgroundImage:[UIImage imageNamed:ICON_SEARCH] forState:UIControlStateNormal];
    [searchClubBtn addTarget:self action:@selector(goSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithCustomView:searchClubBtn];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    //rightBarButtonItem
    UIBarButtonItem *rightbtn;
    
    //转换显示方式按钮
    _changeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _changeViewButton.frame = CGRectMake(0, 0,30, 30);
    [_changeViewButton setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    [_changeViewButton addTarget:_userList action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    
    //扫一扫按钮
    _addFriendButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_addFriendButton setImage:[UIImage imageNamed:@"scan_tdc.png"] forState:UIControlStateNormal];
    [_addFriendButton addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.selectedIndex == 1) {
        rightbtn = [[UIBarButtonItem alloc]initWithCustomView:_addFriendButton];
        [self switchToChatTab:nil];
    }
    else
    {
        rightbtn = [[UIBarButtonItem alloc]initWithCustomView:_changeViewButton];
    }
    self.navigationItem.rightBarButtonItem = rightbtn;
    
    //titleView
    _headerTitleButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 170, 24)];
    [_headerTitleButton addTarget:self action:@selector(popOverView:) forControlEvents:UIControlEventTouchUpInside];
    _headerTitleButton.backgroundColor = [UIColor clearColor];
    if (titleLbl == nil) {
        titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 24)];
        [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
        titleLbl.text = _aheadTitleStr;
        titleLbl.textColor = NAVIFONT_COLOR;
        titleLbl.backgroundColor = [UIColor clearColor];
        CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
        titleLbl.frame = CGRectMake(0, 0, labelsize.width, 24);
        titleViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"x.png"]];
        titleViewArrow.frame = CGRectMake(labelsize.width + 20, 2, 20, 20);
        titleViewArrow.backgroundColor = [UIColor clearColor];
        connectMQTTActivityIndictor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        connectMQTTActivityIndictor.frame = CGRectMake(0, 13, 20, 20);
        [self calHeaderViewFrame];
        [_headerTitleButton addSubview:titleLbl];
        [_headerTitleButton addSubview:titleViewArrow];
        [_headerTitleButton addSubview:connectMQTTActivityIndictor];
        self.navigationItem.titleView = _headerTitleButton;
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    if (![[AccountUser getSingleton] MQTTconnected] && self.selectedIndex == 1) {
        [Utility hideWaitHUDForView];
        [Utility showHUD:@"服务器偷了个懒\n请检查网络或者稍后再试"];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)popOverView:(id)sender
{
    UIButton *btn = (UIButton *)sender;
//    btn.backgroundColor = [UIColor colorWithRed:189/255.0 green:197/255.0 blue:207/255.0 alpha:1];
    titleViewArrow.image = [UIImage imageNamed:@"y.png"];
    
    UserListTableViewController *table = [[UserListTableViewController alloc] initWithStyle:UITableViewStylePlain];
    table.tableView.scrollEnabled = NO;
    table.tableView.backgroundColor = TINT_COLOR;
    table.tableView.separatorColor = [UIColor blackColor];
    
    _popOver = [[FPPopoverController alloc] initWithViewController:table];
    _popOver.tint = FPPopoverDefaultTint;
    _popOver.delegate = self;
    _popOver.arrowDirection = FPPopoverArrowDirectionAny;
    
    [_popOver presentPopoverFromView:btn];
}

- (void)calHeaderViewFrame
{
    CGSize titleLabelSize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake((_headerTitleButton.frame.size.width-titleLabelSize.width-20)/2.0, 0, titleLabelSize.width, 24);
    titleViewArrow.frame = CGRectMake(titleLbl.frame.origin.x+titleLbl.frame.size.width, 2, 20, 20);
    connectMQTTActivityIndictor.frame = CGRectMake(titleLbl.frame.origin.x - 23, 13, 20, 20);
}

- (void)handleUserListNotification:(NSNotification *)notification
{
    [_popOver dismissPopoverAnimated:YES];
    _popOver = nil;
    
    NSNumber *index = notification.object;
    NSString *str = [[Constants getSingleton].userListArray objectAtIndex:([index intValue]+1)%5];
    NSLog(@"recieve choice:%@",str);
    
    titleLbl.text = str;
    [self calHeaderViewFrame];

    if ([index intValue] == 4) {
        self.selectedIndex = 1;
        [_changeViewButton setHidden:YES];
        [_addFriendButton setHidden:NO];
        [self changeChatPageTitle:nil];
        UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:_addFriendButton];
        self.navigationItem.rightBarButtonItem = rightbtn;
    }else{
        self.selectedIndex = 0;
        [_changeViewButton setHidden:NO];
        [_addFriendButton setHidden:YES];
        UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:_changeViewButton];
        self.navigationItem.rightBarButtonItem = rightbtn;
    }
}

- (void)switchToChatTab:(NSNotification *)notification
{
    NSLog(@"111111111111111111");
    [self.navigationController popToViewController:self animated:NO];
    self.selectedIndex = 1;
    [_changeViewButton setHidden:YES];
    [_addFriendButton setHidden:NO];
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:_addFriendButton];
    self.navigationItem.rightBarButtonItem = rightbtn;
    if (![[AccountUser getSingleton] MQTTconnected]) {
        titleLbl.text = @"私聊(未连接)";
//        [connectMQTTActivityIndictor startAnimating];
    }
    else{
        titleLbl.text = @"私聊";
//        [connectMQTTActivityIndictor stopAnimating];
    }
    [self calHeaderViewFrame];
    if (notification != nil) {
        [_chatView addChatingFriend:notification];
    }
}

- (void)changeChatPageTitle:(NSNotification *)notification{
    UILabel *label = (UILabel *)self.navigationItem.titleView;
    if (self.selectedIndex != 1) {
        return;
    }
    if (![[AccountUser getSingleton] MQTTconnected]) {
        titleLbl.text = @"私聊(未连接)";
        _aheadTitleStr = @"私聊(未连接)";
//        [connectMQTTActivityIndictor startAnimating];
    }
    else{
        titleLbl.text = @"私聊";
        _aheadTitleStr = @"私聊";
//        [connectMQTTActivityIndictor stopAnimating];
    }
    [self calHeaderViewFrame];
}

- (void)switchToFollowTab
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_USERLIST object:[NSNumber numberWithInt:1]];
    _aheadTitleStr = @"关注我的人";
    self.isFollowMeUser = 0;
}

- (void)switchToAttentionTab
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_USERLIST object:[NSNumber numberWithInt:0]];
    _aheadTitleStr = @"我关注的人";
    self.isIFollowUser = 0;
}

- (void)showNoticeView:(NSNotification *)notification
{
    NSDictionary *noticeDic = (NSDictionary *)notification.object;
    if ([noticeDic isKindOfClass:[NSDictionary class]]) {
        NSString *userNotice = [noticeDic objectForKey:@"user"];
        int noticeNumber = [userNotice intValue];
        if (noticeNumber > 0) {
            [_notice removeFromSuperview];
            _notice = nil;
            _notice = [[NoticeView alloc] initWithNumber:noticeNumber andType:@"user"];
            [self.view addSubview:_notice];
        }
        
        NSString *bbsUserAttention = [noticeDic objectForKey:@"bbsUserAttention"];
        int bbsUserNumber = [bbsUserAttention integerValue];
        if (bbsUserNumber == 1) {
            NoticeView *bbsAttentionNotice = [[NoticeView alloc] initWithNumber:-200 andType:@"user"];
            [self.view addSubview:bbsAttentionNotice];
        }
    }
    
}

#pragma mark - FPPopoverControllerDelegate
- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController{
    
}
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController
{
    titleViewArrow.image = [UIImage imageNamed:@"x.png"];
    UIView *view = self.navigationItem.titleView;
    view.backgroundColor = [UIColor clearColor];
}

//搜索
-(void)goSearch{
    ClubSearchViewController *searchView = [[ClubSearchViewController alloc]initWithSearchType:2];
    searchView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:searchView animated:YES];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([type isEqualToString:REQUEST_TYPE_PRIVATE_LETTER]){
        NSString *pass = [dic objectForKey:@"pass"];
        //        NSLog(@"result:%@,%@",result,[result class]);
        //        NSString *msg = [[dic objectForKey:@"msg"] objectAtIndex:0];
        //        [self alertString:msg];
        if ([pass isKindOfClass:[NSString class]] && [pass isEqualToString:@"1"]) {
            FriendModel *friend = [[FriendModel alloc] init];
            friend.friendID = [dic objectForKey:@"numberid"];
            friend.masterID = [AccountUser getSingleton].numberID;
            NSDictionary *msgDic = [dic objectForKey:@"msg"];
            NSLog(@"_dataDic:%@",dic);
            friend.name = [msgDic objectForKey:@"name"];
            friend.sex = [msgDic objectForKey:@"sex"];
            friend.photo = [msgDic objectForKey:@"photo"];
            friend.lastMsg = @"";
            [[ZBarManager sharedZBarManager] back];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_ADDFRIEND object:friend];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_INFOMENU object:nil];
        }else{
            [[ZBarManager sharedZBarManager] back];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"没有权限与该用户私聊" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [self alertString:excepDesc andTag:101];
    [[ZBarManager sharedZBarManager] back];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:excepDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 101;
    [alert show];
    //    [self popViewController];
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //    [self popViewController];
    
}
#pragma mark
#pragma mark 扫描二维码实现
//执行扫描功能

//- (void)scan{
//    
//}


- (void)scan{
    UINavigationController *reader = [[ZBarManager sharedZBarManager]getReaderWithDelegate:self helpStr:@"请扫描微俱用户"];
    [ZBarManager sharedZBarManager].helpFlag = @"3";
    [self presentModalViewController:reader animated:YES];
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
}

 //扫描后数据处理
- (void) imagePickerController: (UIImagePickerController*) reader
didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
    break;
    NSLog(@"%@",symbol.data);
    NSString *s = [[Utility qrAnalyse:symbol.data] objectForKey:@"type"];
    if ( 2 == [s intValue]) {
        [_rp testPrivateLetterWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        return;
//    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
//    personInfoView.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:personInfoView animated:YES];
    }else if (1 == [s intValue]){
    ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
    clubInfoView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:clubInfoView animated:YES];
    }else{
        UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"] AndTitle:@"扫描二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
        alert.tag = 1;
        qrText = [[Utility qrAnalyse:symbol.data] objectForKey:@"id"];
    }
     [[ZBarManager sharedZBarManager] back];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([ZBarManager sharedZBarManager].scanFlag != 0) {
        return;
    }
    [ZBarManager sharedZBarManager].scanFlag++;
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *code =[(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            
            [[ZBarManager sharedZBarManager] back];
            NSString *s = [[Utility qrAnalyse:code] objectForKey:@"type"];
            if ( 2 == [s intValue]) {
                [_rp testPrivateLetterWithNumberID:[[Utility qrAnalyse:code] objectForKey:@"id"]];
                return;
                //    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
                //    personInfoView.hidesBottomBarWhenPushed = YES;
                //    [self.navigationController pushViewController:personInfoView animated:YES];
            }else if (1 == [s intValue]){
                ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:code] objectForKey:@"id"]];
                clubInfoView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:clubInfoView animated:YES];
            }else{
                UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:code] objectForKey:@"id"] AndTitle:@"扫描二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
                alert.tag = 1;
                qrText = [[Utility qrAnalyse:code] objectForKey:@"id"];
            }
            break;
        }
    }
}
 
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
     if (1 == alertView.tag) {
     if (1 == buttonIndex) {
         [self copy:qrText];             //拷贝信息到粘贴板
     }else{
         return;
     }
 }
 return;
 }

//拷贝函数执行
-(void)copy:(NSString*)str {
    
    NSString *copyString = [[NSString alloc] initWithFormat:@"%@",str];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyString];
}

//获取所有视图——为添加提示信息所用
-(NSArray *)getAllView{
    NSArray *allView = nil;
    
    if (nil != _chatView && nil != _userList) {
        allView = [[NSArray alloc] initWithObjects: _chatView.tableView,
                                                    _userList.userTableView,
                                                    _userList.pullToScroll, nil];
    }
    return allView;
}

- (UIView *)getReconnectView
{
    if (_chatView) {
        return _chatView.reconnectedView;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    return view;
}

@end
