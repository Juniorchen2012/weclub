//
//  ClubInfoViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-11.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//
/*
 请求:
 获取俱乐部基本信息searchBaseById
 获取展示窗口checkWindows
 获取俱乐部友情俱乐部searchFriendClub
 获取俱乐部版主版副searchModeratorById
 
 判断登录用户对友情俱乐部的身份
 对当前俱乐部的身份判断在进入该俱乐部前就进行了判断
 */
#import "ClubInfoViewController.h"
#import "InviteProcessViewController.h"
#import "AudioPlay.h"
@interface ClubInfoViewController ()

@end
@implementation ClubInfoViewController
{
    int              _loginFlag;
}

@synthesize club,isLoadMore,isFromScan;

//离开页面时，停止所有音乐的播放
-(void)viewWillDisappear:(BOOL)animated{
//    [rp cancel];
//    [request cancelRequest];
    [audioPlay stop];
    [[VideoPlayer getSingleton] VideoDownLoadCancel];
    [self stop];
    
}

- (id)initWithClubRowKey:(NSString *)myClubRowKey
{
    self = [super init];
    if (self) {
        clubRowKey = myClubRowKey;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [request getModerator:club.ID withDelegate:self];//影响管理按钮的刷新
    [request getBaseInfo:club.ID withDelegate:self];
    [myTable reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    [self refreshData];
    [self refreshView];
    [self refreshFriendClubView];
    [self prepareImageView];
    [self refreshDisplayView];
    //    [self getUserType];
    [self refreshNavigationItem];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"俱乐部信息";
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    request = [[Request alloc]init];
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    //手势操作
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    imgArray = [[NSMutableArray alloc]init];
    friendList = [[NSMutableArray alloc]init];
    photos = [[NSMutableArray alloc] init] ;
    
    myScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44)];
    [myScroll setContentSize:CGSizeMake(320, 780)];
    
    //background
    bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 260)];
    bg.image = [UIImage imageNamed:@"bg.png"];
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [myScroll addSubview:bg];
    
    myTable = [[MLTableView alloc]initWithFrame:CGRectMake(0, 264, 320, 600) style:UITableViewStyleGrouped];
    myTable.scrollEnabled = NO;
    myTable.backgroundView = nil;
    myTable.backgroundColor = [UIColor whiteColor];
    myTable.showsVerticalScrollIndicator = NO;
    myTable.delegate = self;
    myTable.dataSource = self;
    myTable.scrollsToTop = NO;
    myScroll.scrollsToTop = YES;
    [myScroll addSubview:myTable];
    [self.view addSubview:myScroll];
    [self createView];
    
    __weak __block typeof(self)bself = self;
    __weak UIScrollView *blockScroll = myScroll;
    [myScroll addPullToRefreshWithActionHandler:^{
        if (blockScroll.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself refreshData];
        }
    }];
    [myScroll addInfiniteScrollingWithActionHandler:^{
        bself.isLoadMore = YES;
        [bself getFriendClub];
    }];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [ notificationCenter addObserver:self selector:@selector(done) name:MPMoviePlayerPlaybackDidFinishNotification object:nil ];
    [ notificationCenter addObserver:self selector:@selector(audioStop:) name:@"AUDIO_STOP" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceRefresh:) name:@"forceRefreshClubInfo" object:nil];
    
    isLoadMore = NO;
    audioPlay = [AudioPlay getSingleton];
    videoPlay = [VideoPlayer getSingleton];
    if (clubRowKey) {
        Club *myClub = [[Club alloc]init];
        myClub.ID = clubRowKey;
        self.club = myClub;
        [self refreshData];
    }
    [self getFriendClub];
}

#pragma mark -
#pragma mark 权限发生变化时，强制刷新界面
-(void)forceRefresh:(NSNotification *)notification{
    if (![club.ID isEqualToString:[notification.object objectForKey:@"clubrowkey"]]) {
        return;
    }
    UIAlertView * alert = [Utility MsgBox:@"您在该俱乐部的权限发生了变化需要刷新该页面!" AndTitle:nil AndDelegate:self AndCancelBtn:@"刷新" AndOtherBtn:nil withStyle:0];
    alert.tag = 3;
    return;
}

#pragma mark -
#pragma mark 各个view初始化
- (void)createView{
    //版标
    _logo = [[UIImageView alloc]init];
    _logo.frame = CGRectMake(5, 5, 60, 60);
    _logo.layer.masksToBounds = YES;
    _logo.layer.cornerRadius = 5;
    _logo.userInteractionEnabled = YES;
    [Utility addTapGestureRecognizer:_logo withTarget:self action:@selector(viewLargeLogo)];
    [myScroll addSubview:_logo];
    
    //俱乐部名称
    _nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 20)];
    [Utility styleLbl:_nameLbl withTxtColor:COLOR_BLACK withBgColor:nil withFontSize:16];
    _nameLbl.font = [UIFont boldSystemFontOfSize:16];
    
    //是否关注该俱乐部的标志
    UIImageView * followstatIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"follow_count.png"]];
    followstatIcon.frame = CGRectMake(80, 45, 12, 12);
    
    //俱乐部距离
    UIImageView * distaneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location.png"]];
    distaneIcon.frame = CGRectMake(0, 43, 12, 12);
    _distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 80, 20)];
    [Utility styleLbl:_distanceLbl withTxtColor:nil withBgColor:nil withFontSize:14];
    
    UIView *TopView = [[UIView alloc]initWithFrame:CGRectMake(70, 5, 250, 14)];
    [TopView addSubview:_nameLbl];
    [TopView addSubview:_distanceLbl];
    [TopView addSubview:distaneIcon];
    if (!club.followThisClub) {
        [TopView addSubview:followstatIcon];
    }
    [myScroll addSubview:TopView];
    
    //会员数和关注数按钮
    _segment = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"会员",@"关注", nil]];
    _segment.momentary = YES;
    _segment.frame = CGRectMake(10, 70, 300, 30);
    _segment.selectedSegmentIndex = -1;
    _segment.segmentedControlStyle = UISegmentedControlStylePlain;
    [_segment addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
    [myScroll addSubview:_segment];
    
    //俱乐部描述
    _descLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 105, 300, 58)];
    _descLbl.text = @"";
    _descLbl.numberOfLines = 0;
    [Utility styleLbl:_descLbl withTxtColor:COLOR_BLACK withBgColor:nil withFontSize:18];
    [myScroll addSubview:_descLbl];
    [myScroll addSubview:_displayView];
    
    //俱乐部号
    clubIDLbl = [[UILabel alloc]initWithFrame:CGRectMake(70, 7, 180, 58)];
    clubIDLbl.text = @"";
    [Utility styleLbl:clubIDLbl withTxtColor:COLOR_BLACK withBgColor:nil withFontSize:13];
    [myScroll addSubview:clubIDLbl];
    
    //友情俱乐部提示
    _friendClubHint = [[UIView alloc]initWithFrame:CGRectMake(10, 684, 90, 20)];
    friendClubLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
    friendClubLbl.text = @"友情俱乐部";
    [friendClubLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:18]];
    friendClubLbl.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 25, 300, 2)];
    line.backgroundColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
    [_friendClubHint addSubview:friendClubLbl];
    [_friendClubHint addSubview:line];
    [myScroll addSubview:_friendClubHint];
}

#pragma mark -
#pragma mark UISegmentControl事件
-(void)segmentDidChange:(id)sender{
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *mySegment = sender;
        ListViewController *listView = [[ListViewController alloc]init] ;
        listView.club = self.club;
        listView.listType = mySegment.selectedSegmentIndex;
        [self.navigationController pushViewController:listView animated:YES];
        listView.title = @"俱乐部会员列表";
    }
}

#pragma mark -
#pragma mark 请求的代理
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    [myScroll.pullToRefreshView stopAnimating];
    [myScroll.infiniteScrollingView stopAnimating];
    if ([type isEqualToString:URL_CLUB_GET_BASICINFO]) {
        [club refreshClubDataWithDic:[dic objectForKey:KEY_DATA]];
        _loginFlag = [[[dic objectForKey:KEY_DATA] objectForKey:@"hasPhoto"] integerValue];
        [self refreshView];
        [self refreshNavigationItem];
        [self refreshFriendClubView];
    }else if ([type isEqualToString:URL_CLUB_GET_FRIENTCLUB]){
        startKey = [[dic objectForKey:KEY_DATA] objectForKey:KEY_STARTKEY];
        NSArray *dicList = [[dic objectForKey:KEY_DATA] objectForKey:@"clublist"];
        if (!isLoadMore) {
            [friendList removeAllObjects];
        }
        for (NSDictionary *clubDic in dicList) {
            Club *friendClub = [[Club alloc]initWithDictionary:clubDic];
            [friendList addObject:friendClub];
        }
        club.friendClubs = friendList;
        WeLog(@"FRIENDCLUB COUTN:%d",[friendList count]);
        [self refreshFriendClubView];
    }else if ([type isEqualToString:URL_CLUB_GET_ADMINS]){
        NSDictionary *adminsDic = [dic objectForKey:KEY_DATA];
        club.admin = [[adminsDic objectForKey:KEY_ADMIN] objectAtIndex:0];
        club.viceAdmins = [adminsDic objectForKey:KEY_VICE_ADMINS];
        [self refreshView];
        [myTable reloadData];
        [self refreshNavigationItem];
    }else if ([type isEqualToString:URL_CLUB_GET_DISPLAY_WINDOW]){
        NSMutableArray *mediaArray = [[NSMutableArray alloc]init];
        [mediaArray addObjectsFromArray:[dic objectForKey:KEY_DATA]];
        club.media = mediaArray;
        club.mediaInfo = [dic objectForKey:KEY_ATTACHMENT_INFO];
        [imgArray description];
        [self refreshDisplayView];
        [audioPlay stop];
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]) {
        //判断如果有权限在跳入新界面
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (-1 == friendclubToGoNO) {
            club.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
            ClubUpgradeViewController *clubUpgradeView;
            FriendClubManageViewController *friendClubManageView;
            ClubProfileEditViewController *clubProfileEditView;
            ClubMemberAssignViewController *clubMemAssignView;
            DisplayWinManageViewController *displayManageView;
            InviteViewController *inviteView;
            ApplyProcessViewController *applyProcessView;
            ReportManageViewController *reportManageView;
            //    if ((club.userType == USER_TYPE_ADMIN)||([myAccountUser.name  isEqualToString:[club.admin  objectForKey:KEY_NAME]]))
            if ((club.userType == USER_TYPE_ADMIN)){
                switch (actionsheetBtnIndex) {
                    case 0:
                        applyProcessView = [[ApplyProcessViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:applyProcessView animated:YES];
                        break;
                    case 1:
                        reportManageView = [[ReportManageViewController alloc] initWithClubID:club.ID];
                        [self.navigationController pushViewController:reportManageView animated:YES];
                        break;
                    case 2:
                        clubMemAssignView = [[ClubMemberAssignViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:clubMemAssignView animated:YES];
                        break;
                    case 3:
                        clubProfileEditView = [[ClubProfileEditViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:clubProfileEditView animated:YES];
                        break;
                    case 4:
                        displayManageView = [[DisplayWinManageViewController alloc]initWithClub:self.club];
                        displayManageView.isClub = YES;
                        [self.navigationController pushViewController:displayManageView animated:YES];
                        break;
                    case 5:
                        friendClubManageView = [[FriendClubManageViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:friendClubManageView animated:YES];
                        break;
                    case 6:
                        inviteView = [[InviteViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:inviteView animated:YES];
                        break;
                    case 7:
                        clubUpgradeView = [[ClubUpgradeViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:clubUpgradeView animated:YES];
                        break;
                    case 8:
                    default:
                        break;
                }
            }else if((club.userType == USER_TYPE_VICE_ADMIN)||([club.viceAdmins containsObject:myAccountUser.name])){
                switch (actionsheetBtnIndex) {
                    case 0:
                        applyProcessView = [[ApplyProcessViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:applyProcessView animated:YES];
                        break;
                    case 1:
                        reportManageView = [[ReportManageViewController alloc] initWithClubID:club.ID];
                        [self.navigationController pushViewController:reportManageView animated:YES];
                        break;
                    case 2:
                        clubMemAssignView = [[ClubMemberAssignViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:clubMemAssignView animated:YES];
                        break;
                    case 3:
                        clubProfileEditView = [[ClubProfileEditViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:clubProfileEditView animated:YES];
                        break;
                    case 4:
                        displayManageView = [[DisplayWinManageViewController alloc]initWithClub:self.club];
                        displayManageView.isClub = YES;
                        [self.navigationController pushViewController:displayManageView animated:YES];
                        break;
                    case 5:
                        friendClubManageView = [[FriendClubManageViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:friendClubManageView animated:YES];
                        break;
                    case 6:
                        inviteView = [[InviteViewController alloc]initWithClub:self.club];
                        [self.navigationController pushViewController:inviteView animated:YES];
                        break;
                    default:
                        break;
                }
            }else{
                [Utility showHUD:@"您的身份已发生变化，没有权限执行该操作。"];
            }
        }else{
            Club *friendClub;
            if (friendclubToGoNO == -2) {
                friendClub = [[Club alloc]init];
                friendClub.ID = club.ID;
            }else{
                friendClub = [club.friendClubs objectAtIndex:friendclubToGoNO];
            }
            friendClub.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
            friendClub.type = [[dic objectForKey:@"openType"] intValue];
            club.isClosed = [dic objectForKey:@"isclose"];
            if ([club.isClosed intValue]) {
                [Utility MsgBox:@"该俱乐部已关闭"];
                return;
            }
            if (friendClub.type && friendClub.userType == 0) {
                
                UIAlertView *alert = [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
                alert.tag = 2;
                return;
            }
            friendClub.followThisClub = [[dic objectForKey:KEY_FOLLOW_THIS_CLUB] intValue];
            ClubViewController *clubView = [[ClubViewController alloc]init];
            clubView.club = friendClub;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
            WeLog(@"登陆用户在该俱乐部的身份%d,俱乐部类型%d",friendClub.userType,friendClub.type);
            clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
            [self.navigationController pushViewController:clubView animated:YES];
        }
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [self stop];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [self stop];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)prepareImageView{
    [imgArray removeAllObjects];
    for (NSString *st in club.media) {
        NSString *displayType = [st substringFromIndex:([st length]-1)];
        if ([displayType isEqualToString:TYPE_ATTACH_PICTURE]) {
            [imgArray addObject:ClubImageURL(st, TYPE_RAW)];
        }
    }
}

-(void)stop{
    [myScroll.pullToRefreshView stopAnimating];
    [myScroll.infiniteScrollingView stopAnimating];
}

#pragma mark -
#pragma mark 获取友情俱乐部请求
-(void)getFriendClub{
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [myTable.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            [myScroll.infiniteScrollingView stopAnimating];
            return;
        }
    }else{
        startKeystring = @"0";
    }
    [request getFriendClub:club.ID withStartKeystring:startKeystring withDelegate:self];
}

#pragma mark -
#pragma mark 刷新数据
-(void)refreshData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [request getModerator:club.ID withDelegate:self];
    [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    [request getBaseInfo:club.ID withDelegate:self];
    [self getFriendClub];
    [request getDisplayWindows:club.ID withDelegate:self];
}

//当前登陆用户在某个俱乐部的身份发生改变，正好在俱乐部信息页
-(void)refreshAfterChange{
    UIAlertView *alert = [Utility MsgBox:@"您在该俱乐部的权限发生变化需要刷新页面" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"确定" AndOtherBtn:nil withStyle:0];
    alert.tag = 3;
}

#pragma mark -
#pragma mark 刷新展示窗口
-(void)refreshDisplayView{
    [_displayView removeFromSuperview];
    _displayView = [[UIView alloc]initWithFrame:CGRectMake(14, _descLbl.frame.origin.y+_descLbl.frame.size.height+5, 292, 125)];
    for (int i = 0; i < [club.media count]; i++) {
        NSString * singleMedia = [club.media objectAtIndex:i];
        NSString *type = [singleMedia substringFromIndex:([singleMedia length]-1)];
        EGOImageButton *imgView = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:ATTACHMENT_PIC_HOLDER] delegate:self];
        //附件时间长度
        UILabel *audioLengthLbl = [[UILabel alloc]init];
        [Utility styleLbl:audioLengthLbl withTxtColor:ATTACHTIME_LENGTH_LBL_COLOR withBgColor:nil withFontSize:10];
        audioLengthLbl.textAlignment = NSTextAlignmentCenter;
        if ([club.mediaInfo isKindOfClass:[NSDictionary class]]) {
            if (![type isEqualToString:TYPE_ATTACH_PICTURE]) {
                audioLengthLbl.frame = CGRectMake(0, 45, 60, 15);
                audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[club.mediaInfo objectForKey:singleMedia] objectForKey:DURATION]];
                [imgView addSubview:audioLengthLbl];
            }
        }
        if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
            //图片
            imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ATTACHMENT_PIC_HOLDER ofType:@"jpg"]];
            [imgView setImageURL:ClubImageURL(singleMedia, TYPE_THUMB)];
            [imgView addTarget:self action:@selector(viewDiplayPICS:) forControlEvents:UIControlEventTouchUpInside];
        }else if ([type isEqualToString:TYPE_ATTACH_AUDIO]){
            //音频
            [imgView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
            [imgView addTarget:self action:@selector(audioPlay:) forControlEvents:UIControlEventTouchUpInside];
        }else if ([type isEqualToString:TYPE_ATTACH_VIDEO]){
            //视频
            audioLengthLbl.backgroundColor = [UIColor blackColor];
            audioLengthLbl.alpha = 0.7;
            imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:VIDEO_PIC_HOLDER ofType:@"png"]];
            [imgView setImageURL:ClubImageURL(singleMedia, TYPE_THUMB)];
            [imgView addTarget:self action:@selector(videoPlay:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:VIDEO_PLAY_ICON]];
            videoIcon.frame = CGRectMake(20,20,20,20);
            [imgView addSubview:videoIcon];
        }
        imgView.frame = CGRectMake(76.5*(i%4), 76.5*(i/4), 60, 60);
        imgView.tag = i;
        [Utility psImageView:imgView];
        [_displayView addSubview:imgView];
    }
    [myScroll addSubview:_displayView];
    //改变其他view的frame
    int rowNum;
    if (![club.media count]) {
        rowNum = 0;
    }else if ([club.media count]<5){
        rowNum = 1;
    }else{
        rowNum = 2;
    }
    bg.frame = CGRectMake(0, 0, 320, _displayView.frame.origin.y+76.5*rowNum);
    //    myTable.frame = CGRectMake(0, 264-76.5*rowNum, 320, 600);
    myTable.frame = CGRectMake(0, _displayView.frame.origin.y+76.5*rowNum, 320, 600);
    //    friendClubHint.frame = CGRectMake(10, 684-76.5*rowNum, 90, 20);
    //    myTable.backgroundColor = COLOR_RED;
    WeLog(@"mytable%f",myTable.frame.size.height);
    _friendClubHint.frame = CGRectMake(10, myTable.frame.origin.y+myTable.contentSize.height, 90, 20);
    [self refreshFriendClubView];
    //    friendClubHint.frame = CGRectMake(10, 0, 90, 20);
    //    myTable.tableFooterView = friendClubHint;
}

#pragma mark -
#pragma mark 刷新友情俱乐部列表
-(void)refreshFriendClubView{
    int i;
    [friendClubView removeFromSuperview];
    friendClubView = [[UIView alloc]initWithFrame:CGRectMake(10, 675, 0, 0)];
    //  friendClubView = [[UIView alloc]initWithFrame:CGRectMake(10, 40, 0, 0)];
    if ([club.friendClubs count]) {
        friendClubLbl.text = [NSString stringWithFormat:@"友情俱乐部:(%@)",club.friendClubCount];
    }else{
        friendClubLbl.text = @"友情俱乐部(无)";
    }
    for (i = 0; i < [club.friendClubs count]; i++) {
        EGOImageButton* imgPhoto = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:LOGO_PIC_HOLDER] delegate:self];
        [Utility psImageView:imgPhoto];
        Club *friendClub = [club.friendClubs objectAtIndex:i];
        [imgPhoto setImageURL:CLUB_LOGO_URL(friendClub.ID,TYPE_THUMB,friendClub.picTime)];
        imgPhoto.tag = i;
        [imgPhoto setFrame:CGRectMake(80*(i%4), (i/4)*80, 60, 60)];
        [imgPhoto addTarget:self action:@selector(goFriendClub:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *clubNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(80*(i%4), (i/4)*80+65, 60, 14)];
        clubNameLbl.textAlignment = UITextAlignmentCenter;
        [Utility styleLbl:clubNameLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        clubNameLbl.text = friendClub.name;
        
        [friendClubView addSubview:clubNameLbl];
        [friendClubView addSubview:imgPhoto];
        if (friendClub.type) {
            UIImageView * OpentTypeImg = [[UIImageView alloc]initWithFrame:CGRectMake(80*(i%4)+5, (i/4)*80+45, 10, 10)];
            OpentTypeImg.image = [UIImage imageNamed:@"si.png"];
            [friendClubView addSubview:OpentTypeImg];
        }
        if (friendClub.userType == 1) {
            UIImageView * Identifyimg;
            Identifyimg = [[UIImageView alloc]initWithFrame:CGRectMake(80*(i%4)+50, (i/4)*80+45, 10, 10)];
            Identifyimg.image = [UIImage imageNamed:@"ban.png"];
            [friendClubView addSubview:Identifyimg];
        }else if (friendClub.userType == 2) {
            UIImageView * Identifyimg;
            Identifyimg = [[UIImageView alloc]initWithFrame:CGRectMake(80*(i%4)+50, (i/4)*80+45, 10, 10)];
            Identifyimg.image = [UIImage imageNamed:@"fu.png"];
            [friendClubView addSubview:Identifyimg];
        }
    }
    if (i%4) {
        [friendClubView setFrame:CGRectMake(0, 30, 320, (i/4+1)*80)];
    }else{
        [friendClubView setFrame:CGRectMake(0, 30, 320, (i/4)*80)];
    }
    
    [_friendClubHint addSubview:friendClubView];
    CGRect cgr = _friendClubHint.frame;
    cgr.size.width = friendClubView.frame.size.width;
    cgr.size.height = friendClubView.frame.size.height+30;
    _friendClubHint.frame = cgr;
    WeLog(@"friendClubHint Height:%f",_friendClubHint.frame.size.height);
    //    friendClubHint.backgroundColor = [UIColor blueColor];
    //    friendClubView.backgroundColor = [UIColor redColor];
    //  [myScroll addSubview:friendClubView];
    
    [myScroll setContentSize:CGSizeMake(320, _friendClubHint.frame.origin.y+_friendClubHint.frame.size.height-20)];
}

//获取登录用户对该俱乐部的身份_friendClubHint
-(void)getUserType{
    [request getUserType:club.ID withDelegate:self];
}

#pragma mark -
#pragma mark 版主版副的编辑按选项
-(void)editClub{
    BOOL isViceAdmin = NO;
    for (NSDictionary *dic in club.viceAdmins) {
        if ([[dic objectForKey:KEY_NAME] isEqualToString:myAccountUser.name]
            ) {
            isViceAdmin = YES;
        }
    }
    UIActionSheet *ac;
    //    if ((club.userType == USER_TYPE_ADMIN) ||([myAccountUser.name  isEqualToString:[club.admin  objectForKey:KEY_NAME]]))
    if ((club.userType == USER_TYPE_ADMIN) ||[myAccountUser.name  isEqualToString:[club.admin  objectForKey:KEY_NAME]]){
        ac = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作"
                                         delegate:self
                                cancelButtonTitle:@"取消"
                           destructiveButtonTitle:nil
                                otherButtonTitles:@"会员申请管理",@"举报管理",@"会员管理",@"俱乐部信息修改",@"展示窗口",@"友情俱乐部",@"邀请我关注的用户",@"升级",nil];
    }else if((club.userType == USER_TYPE_VICE_ADMIN)||isViceAdmin){
        ac = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作"
                                         delegate:self
                                cancelButtonTitle:@"取消"
                           destructiveButtonTitle:nil
                                otherButtonTitles:@"会员申请管理",@"举报管理",@"会员管理",@"俱乐部信息修改",@"展示窗口",@"友情俱乐部",@"邀请我关注的用户",nil];
    }
    ac.actionSheetStyle = UIBarStyleBlackTranslucent;
	[ac showInView:self.view];
}

#pragma mark -
#pragma mark ActionSheet代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    friendclubToGoNO = -1;
    actionsheetBtnIndex = buttonIndex;
    if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"取消"]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self getUserType];
    }
}

#pragma mark -
#pragma mark AlertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //申请加入俱乐部
    if (2 == alertView.tag ) {
        if (buttonIndex == 1) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            Club *friendClub = [club.friendClubs objectAtIndex:friendclubToGoNO];
            [dic setValue:friendClub.ID forKey:KEY_CLUB_ROW_KEY];
            [rp sendDictionary:dic andURL:URL_CLUB_JOIN andData:nil];
        }
        return;
    }
    //权限变化之后刷新该页面
    if (3 == alertView.tag ) {
        [request getModerator:club.ID withDelegate:self];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.dimBackground = YES;
    }
}

#pragma mark -
#pragma mark 获取数据，更新view
-(void)refreshView{
    CLUB_LOGO(_logo, club.ID,club.picTime);
    _nameLbl.text = club.name;
    _distanceLbl.text = club.distance;
    clubIDLbl.text = [NSString stringWithFormat:@"俱乐部号:%@",club.ID];
    _descLbl.text = club.desc;
    [Utility removeSubViews:_descLbl];
    [self attachString:_descLbl.text toView:_descLbl];
    //    CGFloat lblHeight = [Utility getSizeByContent:descLbl.text withWidth:300 withFontSize:13];
    CGFloat lblHeight = [Utility getMixedViewHeight:_descLbl.text withWidth:300];
    _descLbl.frame = CGRectMake(10, 105, 300, lblHeight);
    _descLbl.text = @"";
    memberCountLbl.text = [NSString stringWithFormat:@"%@会员",club.memberCount];
    followCountLbl.text = [NSString stringWithFormat:@"%@关注",club.followCount];
    topicCountLbl.text = club.topicCount;
    shareCountLbl.text = club.shareCount;
    [_segment setTitle:[NSString stringWithFormat:@"会员%@",club.memberCount] forSegmentAtIndex:0];
    [_segment setTitle:[NSString stringWithFormat:@"关注%@",club.followCount] forSegmentAtIndex:1];
    [myTable reloadData];
}

#pragma mark -
#pragma mark 音频播放
-(void)audioPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    int indexNum = btn.tag;
    WeLog(@"AudoURL%@",ClubImageURL([club.media objectAtIndex:btn.tag],TYPE_RAW));
    [audioPlay playAudiowithType:@"clubAudio" withView:sender withFileName:[club.media objectAtIndex:indexNum] withStyle:0];
}

#pragma mark -
#pragma mark 播放视频
-(void)videoPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    WeLog(@"AudoURL%@",ClubImageURL([club.media objectAtIndex:btn.tag],TYPE_RAW));
    //    [videoPlay playVideoWithName:[club.media objectAtIndex:btn.tag] withType:@"clubVideo"];
    [videoPlay playVideoWithURL:[NSString stringWithFormat:@"%@/%@/club/file?name=%@&type=%@",HOST,PHP,[club.media objectAtIndex:btn.tag] ,TYPE_RAW] withType:@"articleVideo" view:self];
}

//视频播放完毕
-(void)done{
    [movie.view removeFromSuperview];
    movie = nil;
}

//跳转到列表页面（会员列表或关注者列表）
-(void)goList:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    ListViewController *listView = [[ListViewController alloc]init] ;
    listView.club = self.club;
    listView.listType = tap.view.tag;
    [self.navigationController pushViewController:listView animated:YES];
    listView.title = @"俱乐部会员列表";
}

//跳转到友情俱乐部页面
- (void)goFriendClub:(id)sender{
    EGOImageButton*btn = (EGOImageButton *)sender;
    friendclubToGoNO = btn.tag;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    if (friendclubToGoNO == -2) {
        [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    }else{
        Club *friendClub = [club.friendClubs objectAtIndex:friendclubToGoNO];
        [dic setValue:friendClub.ID forKey:KEY_CLUB_ROW_KEY];
    }
    
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (3 == indexPath.row) {
        NSMutableString * viceString = [[NSMutableString alloc] initWithString:@""];
        for (NSDictionary* viceDic in club.viceAdmins) {
            [viceString appendString:[viceDic objectForKey:KEY_NAME]];
            [viceString appendString:@"\n"];
        }
        CGFloat lblHeight = [Utility getSizeByContent:viceString withWidth:200 withFontSize:17];
        if (lblHeight+10 < 44) {
            return 44;
        }
        return lblHeight+10;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //中间加空格
    NSArray *clubInfoItems = [NSArray arrayWithObjects:@"创  建  者",@"创建时间",@"版       主",@"版       副",@"活  跃  度",@"版主勤劳度",@"俱乐部类别",@"俱乐部类型",@"主题文章数",@"最大会员数", nil];
    NSUInteger row = [indexPath row];
	static NSString * Identifier = @"ClubInfoCell";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    [Utility removeSubViews:cell.contentView];
    //=====
    UILabel *itemLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 100, 100)];
    itemLbl.backgroundColor = [UIColor clearColor];
    itemLbl.text = [NSString stringWithFormat:@"%@:",[clubInfoItems objectAtIndex:row]];
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [itemLbl.text sizeWithFont:itemLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    itemLbl.frame = CGRectMake(15, 10, labelsize.width, labelsize.height);
    [cell.contentView addSubview:itemLbl];
    if (indexPath.row == 4) {
        UIView *starViews = [[UIView alloc]initWithFrame:CGRectMake(labelsize.width+20, 10, 100, 44)];
        starViews.tag = 3;//用已在没有星级的情况下填写"无"字,只在俱乐部信息页添加，所以用tag来区别
        [Utility initStarLevelView:club.activeDegree withStarView:starViews];
        [cell.contentView addSubview:starViews];
    }else if (indexPath.row == 5){
        UIView *starViews = [[UIView alloc]initWithFrame:CGRectMake(labelsize.width+20, 10, 100, 44)];
        starViews.tag = 3;
        WeLog(@"活跃度%@%d",club.hardWorkDegree,[club.hardWorkDegree intValue]);
        [Utility initStarLevelView:club.hardWorkDegree withStarView:starViews];
        [cell.contentView addSubview:starViews];
    }else{
        UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(labelsize.width+20, -1, 200, 44)];
        content.textColor = [UIColor grayColor];
        content.font = [UIFont fontWithName:FONT_NAME_ARIAL size:17];
        content.numberOfLines = 0;
        content.backgroundColor = [UIColor clearColor];
        NSMutableString *viceString;
        NSDictionary* viceDic;
        switch (indexPath.row) {
            case 0:
                content.text = club.creator;
                break;
            case 1:
                content.text = club.createTM;
                break;
            case 2:
                content.text = [club.admin  objectForKey:KEY_NAME];
                if (!content.text || ![content.text length]) {
                    content.text = @"无";
                }
                break;
            case 3:
                viceString = [[NSMutableString alloc] initWithString:@""];
                for (viceDic in club.viceAdmins) {
                    [viceString appendString:[viceDic objectForKey:KEY_NAME]];
                    [viceString appendString:@"\n"];
                }
                WeLog(@"版副%@",viceString);
                if ([[viceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]) {
                    content.text = viceString;
                    WeLog(@"版副:%@",viceString);
                }else{
                    content.text = @"无";
                }
                content.backgroundColor = COLOR_RED;
                CGFloat lblHeight = [Utility getSizeByContent:content.text withWidth:200 withFontSize:17];
                content.frame = CGRectMake(labelsize.width+20, 10, 200, lblHeight);
                break;
            case 4:
                content.text = club.ID;
                break;
            case 6:
                content.text = [myConstants.clubCategory objectAtIndex:[club.category intValue]];
                break;
            case 7:
                if (club.type) {
                    content.text = @"私密";
                }else{
                    content.text = @"公开";
                }
                break;
            case 8:
                content.text = club.articleCount;
                break;
            case 9:
                content.text = club.maxMemberCount;
            default:
                break;
        }
        [cell.contentView addSubview:content];
    }
    return cell;
}

- (void)back{
    [rp cancel];
    [request cancelRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark 进入二维码页面
-(void)goQRView{
    TDCCardViewController *tdView = [[TDCCardViewController alloc]init];
    tdView.isPerson = NO;
    tdView.club = club;
    [self.navigationController pushViewController:tdView animated:YES];
}

//根据登陆用户和所进入的俱乐部定制管理按钮
-(void)refreshNavigationItem{
    UIButton *qrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
    [qrBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    [qrBtn addTarget:self action:@selector(goQRView) forControlEvents:UIControlEventTouchUpInside];
    [qrBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [qrBtn setTitle:@"二维码" forState:UIControlStateNormal];
    UIBarButtonItem *menuBtnItem1 = [[UIBarButtonItem alloc]initWithCustomView:qrBtn];
    WeLog(@"刷新管理按钮");
    BOOL isViceAdmin = NO;
    for (NSDictionary *dic in club.viceAdmins) {
        if ([[dic objectForKey:KEY_NAME] isEqualToString:myAccountUser.name]
            )       {
            isViceAdmin = YES;
        }
    }
    if (([myAccountUser.name  isEqualToString:[club.admin  objectForKey:KEY_NAME]])||isViceAdmin) {
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
        [menuBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
        [menuBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        
        UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
        
        if ([club.isAdopted isEqualToString:@"0"]) {
            [menuBtn setTitle:@"领取" forState:UIControlStateNormal];
            [menuBtn addTarget:self action:@selector(adopt) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [menuBtn setTitle:@"管理" forState:UIControlStateNormal];
            [menuBtn addTarget:self action:@selector(editClub) forControlEvents:UIControlEventTouchUpInside];
        }
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:menuBtnItem, menuBtnItem1, nil];
    }else{
        if (isFromScan) {
            UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            goBtn.tag = -2;
            goBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH+20, RIGHT_BAR_ITEM_HEIGHT);
            [goBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
            [goBtn addTarget:self action:@selector(goFriendClub:) forControlEvents:UIControlEventTouchUpInside];
            [goBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
            [goBtn setTitle:@"进入版面" forState:UIControlStateNormal];
            UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:goBtn];
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.rightBarButtonItem = menuBtnItem;
        }else{
            self.navigationItem.rightBarButtonItems = nil;
            self.navigationItem.rightBarButtonItem = menuBtnItem1;
        }
    }
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate查看图片大图
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

//查看大图
-(void)viewLargeLogo{
    [photos removeAllObjects];
    if (photos) {
        [photos addObject:[MWPhoto photoWithURL:CLUB_LOGO_URL(club.ID, TYPE_RAW,club.picTime)]];
    }
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    nav.navigationBar.translucent = NO;

    [mwBrowser setInitialPageIndex:0];
    [self presentModalViewController:nav animated:YES];
}

//查看图片
-(void)viewDiplayPICS:(id)sender{
    UIButton *btn = (UIButton*)sender;
    [photos removeAllObjects];
    for (int i = 0; i < [imgArray count]; i++) {
        if (photos) {
            [photos addObject:[MWPhoto photoWithURL:[imgArray objectAtIndex:i]]];
        }
    }
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    nav.navigationBar.translucent = NO;

    [mwBrowser setInitialPageIndex:[imgArray indexOfObject:ClubImageURL([club.media objectAtIndex:btn.tag], TYPE_RAW)]];
    [self presentModalViewController:nav animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self cutMixedString:str];
    //    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [targetView addSubview:btn];
                        x += subSize.width;
                    }else{
                        int index = 0;
                        while (x + [piece sizeWithFont:font].width > maxWidth) {
                            NSString *subString = [piece substringToIndex:index];
                            while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                                index++;
                                subString = [piece substringToIndex:index];
                            }
                            index--;
                            if (index <= 0) {
                                x = 0;
                                y += 22;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(x, y, subSize.width, 22);
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle:subString forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                            [targetView addSubview:btn];
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                    }
                    
                }else{
                    if (x + 22 > maxWidth) {
                        x = 0;
                        y += 22;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, 22, 22);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    [targetView addSubview:imgView];
                    x += 22;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 22;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    WeLog(@"piece width%f",[piece sizeWithFont:font].width);
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        WeLog(@"piece %@x+piece_width%f maxWidth%f",piece,x + [piece sizeWithFont:font].width,maxWidth);
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                            WeLog(@"test subString%@",subString);
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:subString forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        btn.userInteractionEnabled = NO;
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        WeLog(@"index%dpiece.length%d",index,piece.length-1);
                        if (index <= piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            WeLog(@"left substring%@",piece);
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
    //    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

- (NSMutableArray *)cutMixedString:(NSString *)str
{
    //    WeLog(@"str to be cut:%@",str);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int pStart = 0;
    int pEnd = 0;
    
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"["]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            NSRange range1 = [subString rangeOfString:@"["];
            NSRange range2 = [subString rangeOfString:@"]"];
            if (range2.location != NSNotFound && range2.location > range1.location) {
                NSString *strPiece = [subString substringToIndex:range2.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"h"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 9) {
                NSString *headStr = [subString substringToIndex:7];
                //                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"http://"]) {
                    NSRange range = [subString rangeOfString:@" "];
                    if (range.location != NSNotFound) {
                        NSString *strPiece = [subString substringToIndex:range.location+1];
                        [returnArray addObject:strPiece];
                        pEnd += strPiece.length;
                        pStart = pEnd;
                        pEnd--;
                    }
                }
            }
            
        }else if ([a isEqualToString:@"\n"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 2) {
                NSString *headStr = [subString substringToIndex:1];
                //                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"\n"]) {
                    
                    [returnArray addObject:headStr];
                    pEnd += headStr.length;
                    pStart = pEnd;
                    pEnd--;
                }
            }
        }
        pEnd++;
    }
    if (pStart != pEnd) {
        NSString *strPiece = [str substringFromIndex:pStart];
        [returnArray addObject:strPiece];
    }
    
    return returnArray;
}

-(void)audioStop:(NSNotification*)notification{
    if ([notification.object isEqualToString:@"CLUBINFO"]) {
        [audioPlay stop];
    }
}

- (void)adopt
{
    ClubProfileEditViewController *edit = [[ClubProfileEditViewController alloc] initWithClub:club];
    edit.adoptFlag = 1;
    edit.logoFlag = _loginFlag;
    [self.navigationController pushViewController:edit animated:YES];
}

@end
