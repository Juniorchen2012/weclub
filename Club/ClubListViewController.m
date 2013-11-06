//
//  ViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-7.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubListViewController.h"

@implementation ClubListViewController
@synthesize isLoadMore;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithType:(BOOL)flag andType:(int)type
{
    self = [super init];
    if (self) {
        justListFlag = flag;
        listType = type;
    }
    return self;
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    //    [myTable reloadData];
    [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
//    [rp cancel];
    [self hideTitleViews];
    [self stop];
    [request cancelRequest];
}

- (void)viewDidAppear:(BOOL)animated{

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initNavigation];
    clubList = [[NSMutableArray alloc]init];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    showFlag = YES;
    request = [[Request alloc]init];
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44-49)];
    myTable.dataSource = self;
    myTable.delegate = self;
    [self.view addSubview:myTable];
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
        
    for (int i = 0; i < [myConstants.listTypeNames count]; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 40*i, 140, 40);
        btn.tag = i;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitle:[myConstants.listTypeNames  objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(i+1), 140, 1)];
        line.backgroundColor = [UIColor blackColor];
        [titleViews addSubview:line];
        [titleViews addSubview:btn];
    }
    
    holeView.backgroundColor = [UIColor clearColor];
    [holeView addSubview:titleViews];
    [self.tabBarController.view addSubview:holeView];
    holeView.hidden = YES;
    listType = LIST_TYPE_NEARBY;
    gridView = [[MMGridView alloc]initWithFrame:CGRectMake(0, -1, 320, 400)];
    gridView.dataSource = self;
    gridView.delegate = self;
    gridView.scrollView.scrollsToTop = NO;
    gridView.numberOfColumns = 4;
    gridView.numberOfRows = iPhone5 ?5:4;
    gridView.cellMargin = 1;
    gridView.hidden = YES;
    pullToScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44-49)];
    pullToScroll.hidden = YES;
    [pullToScroll addSubview:gridView];
    postURLS = [NSArray arrayWithObjects:URL_CLUB_LIST_NEARBY,URL_CLUB_LIST_JOINED,URL_CLUB_LIST_FOLLOWED,URL_CLUB_LIST_CLASSIFY,URL_CLUB_LIST_BOARD,URL_CLUB_LIST_MITBBS,nil];
    [self.view addSubview:pullToScroll];
    __weak __block typeof(self)bself = self;
    __weak UIScrollView *blockScroll = pullToScroll;
    [pullToScroll addPullToRefreshWithActionHandler:^{
        //        [bself loadData];
        //        if (gridView.scrollView.pullToRefreshView.state == SVPullToRefreshStateLoading)
        //        [gridView.scrollView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1.0];
        if (blockScroll.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    [pullToScroll addInfiniteScrollingWithActionHandler:^{
        if (blockScroll.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            
        }else{
            [gridView.scrollView.infiniteScrollingView stopAnimating];
        }
    }];
    __weak UITableView *blockTable = myTable;
    [myTable addPullToRefreshWithActionHandler:^{
        if (blockTable.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    [myTable addInfiniteScrollingWithActionHandler:^{
        if (blockTable.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            
        }else{
            [blockTable.infiniteScrollingView stopAnimating];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMitBBSClub:)
                                                 name:@"LOAD_MITBBS_CLUB" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAfterQuitOrUnfollowClub:)
                                                 name:@"REFRESH_AFTER_QUIT_UNFOLLOW_CLUB" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromMitBBS)
                                                 name:@"BACK_FROM_MITBBS_CLUBVIEW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationChangeList:) name:NOTIFICATION_KEY_JOINCLUBLIST object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPullScrollContentSize:)
                                                 name:@"REFRESH_CONTENTSIZE" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationChangeList:) name:@"attention_club_list" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNotification) name:NOTIFICATION_KEY_LOGOUT object:nil];
    //把[refresh];放到用户登陆后去刷新而在启动这个页面的viewdiddisappear中不刷新
    //[self refresh];
    [self loadData];
    isLoadMore = NO;
    if ([[AccountUser getSingleton].loginFlag isEqualToString:@"1"]) {
        AccountUser *user = [AccountUser getSingleton];
        NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithCapacity:3];
        if ([user.i_follow_count integerValue]) {
            [muDic setObject:@"1" forKey:@"bbsUserAttention"];
        }
        if ([user.inclub_count integerValue]) {
            [muDic setObject:@"1" forKey:@"bbsClubFollow"];
        }
        if ([user.follow_club_count integerValue]) {
            [muDic setObject:@"1" forKey:@"bbsClubAttention"];
        }
        NSDictionary *noticeDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"bbsClubFollow",@"1" , @"bbsClubAttention",@"1",@"bbsUserAttention", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_UPDATENOTICE object:muDic];
    }
    [[NoticeManager sharedNoticeManager] showNotice];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark -
#pragma mark 页面跳转－（注册时）创建俱乐部 搜索 跳到俱乐部页
//创建俱乐部
-(void)newClub{
    ClubProfileEditViewController *newClubView = [[ClubProfileEditViewController alloc]initWithType:0];
    newClubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:newClubView animated:YES];
}

//（注册时）创建俱乐部
- (void)registNewClub{
    ClubProfileEditViewController *newClubView = [[ClubProfileEditViewController alloc]initWithType:3];
    newClubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:newClubView animated:YES];
}

//搜索
-(void)goSearch{
    ClubSearchViewController *searchView = [[ClubSearchViewController alloc]initWithSearchType:0];
    searchView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:searchView animated:YES];
}

//跳到俱乐部页
- (void)goClub:(int)indexNum{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    clubToGoNO = indexNum;
    Club *club = [clubList objectAtIndex:indexNum];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (UITableView *)getTableView
{
    return myTable;
}

- (UIScrollView *)getScrollView
{
    return pullToScroll;
}

#pragma mark -
#pragma mark 切换不同类型俱乐部列表
- (void)changeList:(id)sender{
    [rp cancel];
    UIButton *btn = (UIButton *)sender;
    [categoryView removeFromSuperview];
    if (btn.tag == 6) {
        //创建俱乐部
        [request checkMoneyWithDelegate:self];
    }else if (3 == btn.tag || 4 == btn.tag || 5 == btn.tag){
        //跳到俱乐部分类，俱乐部版面，Mitbbs俱乐部页
        listType = btn.tag;
        MitBBSClubViewController *mitBBSClubView = [[MitBBSClubViewController alloc]initWithMitType:btn.tag-3];
        [self.navigationController pushViewController:mitBBSClubView animated:YES];
        titleLbl.text = [myConstants.listTypeNames objectAtIndex:btn.tag];
        [self resizeTitleView];
        [clubList removeAllObjects];
    }else{
        listType = btn.tag;
        if (listType == 1) {
            if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsClubFollow"]) {
                [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsClubFollow"];
            }
        }
        if (listType == 2) {
            if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsClubAttention"]) {
                [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsClubAttention"];
            }
        }
        [clubList removeAllObjects];



        [self loadData];
        
        titleLbl.text = [myConstants.listTypeNames objectAtIndex:btn.tag];
        [self resizeTitleView];
    }
//    myTable.tableFooterView = nil;
//    [myTable reloadData];
//    [gridView reloadData];
    [self hideTitleViews];
}

- (void)notificationChangeList:(NSNotification *)notification
{
    id sender = [notification object];
    [self changeList:sender];
}

-(void)loadMitBBSClub:(NSNotification *)notification{
    if (listType == 4) {
        categoryNO = [[notification.userInfo objectForKey:KEY_CATEGORY] intValue];
        titleLbl.text = [NSString stringWithFormat:@"mitbbs版面:%@",[notification.userInfo objectForKey:KEY_NAME]];
    }else if (listType == 5){
        categoryNO = [[notification.userInfo objectForKey:KEY_CATEGORY] intValue];
        titleLbl.text = [NSString stringWithFormat:@"mitbbs俱乐部:%@",[notification.userInfo objectForKey:KEY_NAME]];
    }else if (listType == 3){
        categoryNO = [[notification.userInfo objectForKey:KEY_CATEGORY] intValue]-1;
        titleLbl.text = [NSString stringWithFormat:@"俱乐部分类:%@",[notification.userInfo objectForKey:KEY_NAME]];
    }
    [self loadData];
    [self resizeTitleView];
}

-(void)refreshPullScrollContentSize:(NSNotification *)notification{
    
}

//从俱乐部页面的恢复
-(void)backFromMitBBS{
    listType = 0;
    titleLbl.text = @"附近的俱乐部";
    [self resizeTitleView];
    [self loadData];
}

-(void)press:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    [Utility showHUD:[NSString stringWithFormat:@"%@ pressed",[myConstants.clubCategory objectAtIndex:tap.view.tag]]];
}

#pragma mark -
#pragma mark  切换tableView和gridview
- (void)changeView{
    NSString * subtype;
    if (showFlag) {
        subtype = kCATransitionFromRight;
        pullToScroll.hidden = NO;
        gridView.hidden = NO;
        myTable.hidden = YES;
        [menuBtn setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    }else{
        subtype = kCATransitionFromLeft;
        pullToScroll.hidden = YES;
        gridView.hidden = YES;
        myTable.hidden = NO;
        [menuBtn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    }
    [self.view.layer addAnimation:[Utility createAnimationWithType:@"cube" withsubtype:subtype withDuration:0.3f] forKey:@"animation"];
    showFlag = !showFlag;
}

//刷新
- (void)refresh{
    //在登陆后才会自动刷新当前页，其余都是手动刷新
    [myTable setContentOffset:CGPointMake(myTable.contentOffset.x, 0)animated:YES];
    [myTable triggerPullToRefresh];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //加入退出俱乐部的alert
    if (0 == alertView.tag ) {
        if (buttonIndex == 1) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            Club *club = [clubList objectAtIndex:clubToGoNO];
            [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
            [rp sendDictionary:dic andURL:URL_CLUB_JOIN andData:nil];
        }else{
            return;
        }
        return;
    }
}


#pragma mark -
#pragma mark request delegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_USER_CHECK_USERTYPE]) {
        //判断如果有权限在跳入新界面
        Club *club = [clubList objectAtIndex:clubToGoNO];
        club.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        club.applyjudge = [[dic objectForKey:@"applyjudge"] intValue];
        club.isClosed = [dic objectForKey:@"isclose"];
        if ([club.isClosed intValue]) {
            [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:YES];
            [Utility MsgBox:@"该俱乐部已关闭"];
            return;
        }
        if (club.type && club.userType == 0) {
            [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:YES];
            [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
            return;
        }
        club.followThisClub = [[dic objectForKey:KEY_FOLLOW_THIS_CLUB] intValue];
        WeLog(@"是否关注该俱乐部%d",club.followThisClub);
        ClubViewController *clubView = [[ClubViewController alloc]init];
        clubView.club = club;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
        WeLog(@"登陆用户在该俱乐部的身份%d",club.userType);
        clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([self.navigationController.topViewController isKindOfClass:[ClubListViewController class]]) {
            [self.navigationController pushViewController:clubView animated:YES];
        }
    }else if ([postURLS containsObject:type]){
        if ([postURLS indexOfObject:type] != listType) {
            return;
        }
        if (![[dic objectForKey:KEY_DATA] isKindOfClass:[NSDictionary class]]) {
            [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
            return;
        }
        startKey = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"data"]objectForKey:KEY_STARTKEY]];
        
        UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        tintLbl.backgroundColor = [UIColor clearColor];
        tintLbl.textColor = [UIColor grayColor];
        tintLbl.textAlignment = NSTextAlignmentCenter;
        myTable.tableFooterView = tintLbl;
        if (!isLoadMore) {
            [clubList removeAllObjects];
            [myTable setContentOffset:CGPointMake(0, 0)];
        }
        NSArray *gotArray = [NSArray arrayWithArray:[[dic objectForKey:KEY_DATA] objectForKey:@"clublist"]];
        for (NSDictionary *clubDic in gotArray) {
            Club *club = [[Club alloc]initWithDictionary:clubDic];
            [clubList addObject:club];
        }
        if ([startKey isEqualToString:KEY_END]) {
            if (![clubList count]) {
                tintLbl.text = @"暂无俱乐部";
            }else{
                tintLbl.text = @"已显示全部";
            }
        }else{
            tintLbl.text = @"上拉加载更多";
        }
        
        if (isLoadMore) {
            [myTable insertRowsAtIndexPaths:[Utility getIndexPaths:clubList withTable:myTable]withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [myTable reloadData];
        }
        
        [gridView reloadData];
        int minCount;
        if (iPhone5) {
            minCount = 5;
        }else{
            minCount = 4;
        }
        if ([clubList count]%4) {
            if ([clubList count]/4+1<= minCount) {
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }else{
                [pullToScroll setContentSize:CGSizeMake(320, 91.75*([clubList count]/4+1)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }
        }else{
            if ([clubList count]/4<=minCount) {
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }else{
                [pullToScroll setContentSize:CGSizeMake(320, 91.75*([clubList count]/4)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }
            
        }
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        [gridView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        isLoadMore =  NO;
    }else if([type isEqualToString:URL_CLUB_JOIN]){
        //加入俱乐部
        [Utility showHUD:@"申请成功"];
    }if ([type isEqualToString:URL_USER_GET_MONEY]) {
        myAccountUser.money = [dic objectForKey:@"money"];
        if ([[dic objectForKey:@"money"] intValue]>=100) {
            [self newClub];
        }else{
            [Utility showHUD:@"您的伪币不足，无法创建俱乐部!"];
        }
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)stop{
    [myTable.infiniteScrollingView stopAnimating];
    [myTable.pullToRefreshView stopAnimating];
    [pullToScroll.infiniteScrollingView stopAnimating];
    [pullToScroll.pullToRefreshView stopAnimating];
}


#pragma mark -
#pragma mark 获取数据
- (void)loadData{
    [rp cancel];
    if (0 == [[[NSUserDefaults standardUserDefaults] objectForKey:LOCATABLE] integerValue]) {
        if (0 == listType) {
            [myTable reloadData];
            [gridView reloadData];
            UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
            tintLbl.backgroundColor = [UIColor clearColor];
            tintLbl.textColor = [UIColor grayColor];
            tintLbl.textAlignment = NSTextAlignmentCenter;
            myTable.tableFooterView = tintLbl;
            tintLbl.text = @"无法获取到您的位置信息";
            [self stop];
            return;
        }
    }
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [myTable.infiniteScrollingView stopAnimating];
            [pullToScroll.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            return;
        }
    }else{
        startKeystring = @"0";
    }
    postURL = [postURLS objectAtIndex:listType];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    if (3 == listType  || 5 == listType) {
        NSMutableString *categoryToSend = [[NSMutableString alloc] init];
        //组织成0002，4位数的格式
        for (int i = 0; i < (4-[[NSString stringWithFormat:@"%d",categoryNO] length]); i++) {
            [categoryToSend appendString:@"0"];
        }
        [categoryToSend appendString:[NSString stringWithFormat:@"%d",categoryNO]];
        [dic setValue:categoryToSend forKey:KEY_CATEGORY];
        [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    }else if(4 == listType){
        [dic setValue:[NSNumber numberWithInt:(categoryNO)] forKey:KEY_CATEGORY];
        [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    }else{

        if ([DeviceModel isEqualToString:@"iPhone Simulator"]) {
            myAccountUser.locationInfo = @"116.332574,39.971998";
        }
        [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
        [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    }
    [dic setValue:startKeystring forKey:KEY_STARTKEY];
    [rp sendDictionary:dic andURL:postURL andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)checkAccess:(int)clubID{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:[NSNumber numberWithInt:clubID] forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self goClub:indexPath.row];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [clubList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    if (iPhone5) {
        return (myConstants.screenHeight-20-44-49)/6;
    }else{
        return (myConstants.screenHeight-20-44-49)/5+2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"clubcell";
    ClubCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[ClubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    [[cell viewWithTag:10000] removeFromSuperview];
    [[cell viewWithTag:10001] removeFromSuperview];
    [[cell viewWithTag:10002] removeFromSuperview];
    Club *club = [clubList objectAtIndex:indexPath.row];
    [cell initWithClub:club];
    return cell;
}

#pragma mark -
#pragma mark GridView Delegate Methods
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView{
    return [clubList count];
}

- (MMGridViewCell*)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index{
    MMGridViewCell *cell = [[MMGridViewCell alloc] initWithFrame:CGRectNull];
    Club *club = [clubList objectAtIndex:index];
    [Utility removeSubViews:cell];
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(8, 5, 60, 60)];
    [logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/club/file?name=%@0_p&type=%@",HOST,PHP,club.ID,TYPE_THUMB]] placeholderImage:[UIImage imageNamed:LOGO_PIC_HOLDER]];
    CLUB_LOGO(logo, club.ID,club.picTime);
    logo.frame = CGRectMake(8.7, 5, 60, 60);
    logo.layer.masksToBounds = YES;
    logo.layer.cornerRadius = 5;
    
    UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(3, 63, 70, 18)];
    nameLbl.font = [UIFont fontWithName:FONT_NAME_ARIAL size:10];
    nameLbl.textAlignment = UITextAlignmentCenter;
    nameLbl.text = club.name;
    nameLbl.numberOfLines = 2;
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.textColor = [UIColor colorWithRed:230.0/255.0 green:59.0/255.0 blue:28.0/255.0 alpha:1.0];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(9, 77, 70, 12)];
    
    UIImageView *typeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
    typeIcon.image = [UIImage imageNamed:@"type.png"];
    UILabel *typeLbl = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, 30, 12)];
    typeLbl.text = [myConstants.clubCategory objectAtIndex: [club.category intValue]];
    [Utility styleLbl:typeLbl withTxtColor:nil withBgColor:nil withFontSize:8];
    
    UIImageView *distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(28, 0, 12, 12)];
    distanceIcon.image = [UIImage imageNamed:@"location.png"];
    UILabel *distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(37, 0, 40, 12)];
    if ([club.distance hasSuffix:@"以内"]) {
        distanceLbl.text = [club.distance stringByReplacingOccurrencesOfString:@"以内" withString:@""];
    }else{
        distanceLbl.text = club.distance;
    }
    
    [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:8];
    
    [bottomView addSubview:distanceIcon];
    [bottomView addSubview:distanceLbl];
    [bottomView addSubview:typeIcon];
    [bottomView addSubview:typeLbl];
    [cell addSubview:logo];
    [cell addSubview:nameLbl];
    [cell addSubview:bottomView];
    [Utility psImageView:cell];
    if (club.type) {
        UIImageView *OpentTypeImg;
        OpentTypeImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 50, 10, 10)];
        OpentTypeImg.image = [UIImage imageNamed:@"si.png"];
        [cell addSubview:OpentTypeImg];
    }
    if (club.userType == 1) {
        UIImageView * Identifyimg;
        Identifyimg = [[UIImageView alloc]initWithFrame:CGRectMake(56, 50, 10, 10)];
        Identifyimg.image = [UIImage imageNamed:@"ban.png"];
        [cell addSubview:Identifyimg];
    }else if (club.userType == 2) {
        UIImageView * Identifyimg;
        Identifyimg = [[UIImageView alloc]initWithFrame:CGRectMake(56, 50, 10, 10)];
        Identifyimg.image = [UIImage imageNamed:@"fu.png"];
        [cell addSubview:Identifyimg];
    }
    return cell;
}

- (void)gridView:(MMGridView *)gridView didSelectCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index{
    [self goClub:index];
}

//退出俱乐部的刷新
-(void)refreshAfterQuitOrUnfollowClub:(NSNotification *)notification{
    if ([notification.object isEqualToString:@"quit"]) {
        if (1 == listType) {
            [clubList removeObjectAtIndex:clubToGoNO];
        }
    }else if([notification.object isEqualToString:@"unfollow"]){
        if (2 == listType) {
            [clubList removeObjectAtIndex:clubToGoNO];
        }
    }
    [myTable reloadData];
    
}

//调整导航栏
-(void)resizeTitleView{
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 24);
    titleViewArrow.frame = CGRectMake(labelsize.width, 2, 20, 20);
    titleView.frame = CGRectMake((320-labelsize.width-20)/2-90, 0,labelsize.width+20, 24);
}

//标题栏弹出隐藏处理
- (void)showTitleViews{
    titleViewArrow.image = [UIImage imageNamed:@"y.png"];
    [holeView.layer addAnimation:[Utility createAnimationWithType:kCATransitionReveal withsubtype:kCATransitionFromTop withDuration:0] forKey:@"animation"];
    holeView.hidden = NO;
}

//标题栏隐藏处理
- (void)hideTitleViews{
    titleViewArrow.image = [UIImage imageNamed:@"x.png"];
    holeView.hidden = YES;
    //[[EGOCache currentCache]clearCache];
//    [myTable reloadData];
}

-(void)initNavigation{
    //leftBarButtonItem
    UIButton *searchClubBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchClubBtn.frame = CGRectMake(0, 0, 30, 30);
    [searchClubBtn setBackgroundImage:[UIImage imageNamed:ICON_SEARCH] forState:UIControlStateNormal];
    [searchClubBtn addTarget:self action:@selector(goSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithCustomView:searchClubBtn];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    //rightBarButtonItem
    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0,30, 30);
    [menuBtn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = rightbtn;
    
    //titleView
    
    UIView * title = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 140, 24)];
    titleView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 24)];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView addTarget:self action:@selector(showTitleViews) forControlEvents:UIControlEventTouchUpInside];
    
    titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 24)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"附近的俱乐部";
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 24);
    titleViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"x.png"]];
    titleViewArrow.backgroundColor =[UIColor clearColor];
    titleViewArrow.frame = CGRectMake(labelsize.width, 2, 20, 20);
    [titleView addSubview:titleLbl];
    [titleView addSubview:titleViewArrow];
    [title addSubview:titleView];
    self.navigationItem.titleView = title;
    
    titleViews = [[UIView alloc]initWithFrame:CGRectMake(90, 60, 140, 280)];
    titleViews.backgroundColor = TINT_COLOR;
    holeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
@end
