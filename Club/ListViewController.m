//
//  ListViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-28.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController
@synthesize club,listType,deleteNO,isLoadMore,usedForMemberAssign,refreshDel;
@synthesize userName = _userName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUserRowKey:(NSString*)myUserRowKey withType:(int)myType withName:(NSString *)myUserName
{
    self = [super init];
    if (self) {
        userRowKey = myUserRowKey;
        listType = myType;
        userName = myUserName;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];

}
-(void)viewDidAppear:(BOOL)animated{
    WeLog(@"ContentOffSet%f",myTable.contentOffset.y);
    //[myTable scrollRectToVisible:CGRectMake(0, 100, 320, 100) animated:YES];
    if (firstAppear) {
        [_tableView triggerPullToRefresh];
        firstAppear = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    flag = YES;
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    list = [[NSMutableArray alloc] init];
    tmpList = [[NSMutableArray alloc]init];
    
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-64) style:UITableViewStylePlain];
    //tableView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-64);
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    mySearchBar = [[UISearchBar alloc] init];
    myTable.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-20);
    //可以加入搜索範圍選項scope
    [mySearchBar setScopeButtonTitles:[NSArray arrayWithObjects:@"按名称",@"按ID",nil]];
    mySearchBar.delegate = self;
    mySearchBar.tintColor = TINT_COLOR;
    mySearchBar.placeholder = @"搜索";
    
    
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    
    if (!listType) {
        _tableView.tableHeaderView = mySearchBar;
    }
    //    for (UIView * view in self.view.subviews) {
    //        if ([view isKindOfClass:[UITableView class]]) {
    //            [view removeFromSuperview];
    //        }
    //    }
    //    mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    
    //  [self setMySearchDisplayController:mySearchDisplayController];
    //    [mySearchDisplayController setDelegate:self];
    //    [mySearchDisplayController setSearchResultsDataSource:self];
    //    [mySearchDisplayController setSearchResultsDelegate:self];
    [self.view addSubview:_tableView];
    //用户信息grid方式显示
    gridView = [[MMGridView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    WeLog(@"grid view frame:%f,%f,%f,%f",gridView.frame.origin.x,gridView.frame.origin.y,gridView.frame.size.width,gridView.frame.size.height);
    gridView.delegate = self;
    gridView.dataSource = self;
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.scrollView.scrollsToTop = NO;
    gridView.numberOfColumns = 4;
    gridView.numberOfRows = iPhone5?5:4;
    gridView.cellMargin = 1;
    [gridView setHidden:YES];
    
    pullToScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44)];
    pullToScroll.hidden = YES;
    [pullToScroll addSubview:gridView];
    [self.view addSubview:pullToScroll];
    
    
    __weak __block typeof(self)bself = self;
    __weak UITableView *blcokTable = _tableView;
    
    [_tableView addPullToRefreshWithActionHandler:^{
        if (blcokTable.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    
    [_tableView addInfiniteScrollingWithActionHandler:^{
        WeLog(@"%d",blcokTable.infiniteScrollingView.state);
        if (blcokTable.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            
        }else{
            [blcokTable.infiniteScrollingView stopAnimating];
        }
    }];
    
    __weak UIScrollView *blockScrollView = pullToScroll;
    [pullToScroll addPullToRefreshWithActionHandler:^{
        WeLog(@"refresh...");
        if (blockScrollView.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    
    [pullToScroll addInfiniteScrollingWithActionHandler:^{
        WeLog(@"load more data...");
        if (blockScrollView.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            
        }else{
            [blockScrollView.infiniteScrollingView stopAnimating];
        }
        
    }];
    postURL = [[NSArray alloc]initWithObjects:URL_CLUB_GET_MEMBER_LIST,URL_CLUB_GET_FOLLOWER_LIST,URL_CLUB_LIST_SOMEONE_JOINED,URL_CLUB_LIST_SOMEONE_FOLLOWED, nil];
    firstAppear = YES;
    //    [self loadData];
    //    [tableView setContentOffset:CGPointMake(0, 44)];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //加入退出俱乐部的alert
    if (0 == alertView.tag ) {
        if (buttonIndex == 1) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            Club *myclub = [list objectAtIndex:clubToGoNO];
            [dic setValue:myclub.ID forKey:KEY_CLUB_ROW_KEY];
            [rp sendDictionary:dic andURL:URL_CLUB_JOIN andData:nil];
        }else{
            return;
        }
        return;
    }
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_GET_MEMBER_LIST]||[type isEqualToString:URL_CLUB_GET_FOLLOWER_LIST]) {


        startKey = [[dic objectForKey:KEY_DATA] objectForKey:KEY_STARTKEY];
        WeLog(@"startKey%@",startKey);
        NSArray *dicList = [[dic objectForKey:KEY_DATA] objectForKey:KEY_MEMBER_LIST];
        WeLog(@"listCount%d",[dicList count]);
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        [list addObjectsFromArray:dicList];
        [self refreshTableFooter];
        int minCount;
        if (iPhone5) {
            minCount = 5;
        }else{
            minCount = 4;
        }
        if ([dicList count]%4) {
            if ([dicList count]/4+1<= minCount) {
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height* + myConstants.screenHeight * 0.75)];
            }else{
                [pullToScroll setContentSize:CGSizeMake(320, 91.75*([dicList count]/4+1)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
            }
        }else{
            if ([dicList count]/4<=minCount) {
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
            }else{
                [pullToScroll setContentSize:CGSizeMake(320, 91.75*([dicList count]/4)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
            }
            
        }
        if (isLoadMore) {
            [_tableView insertRowsAtIndexPaths:[Utility getIndexPaths:list withTable:_tableView] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [_tableView reloadData];
        }
        [gridView reloadData];
        //[myTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewRowAnimationTop animated:YES];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        
    }else if ([type isEqualToString:URL_CLUB_LIST_SOMEONE_JOINED]||[type isEqualToString:URL_CLUB_LIST_SOMEONE_FOLLOWED]) {
        startKey = [[dic objectForKey:KEY_DATA] objectForKey:KEY_STARTKEY];
        NSArray *gotArray = [NSArray arrayWithArray:[[dic objectForKey:@"data"] objectForKey:@"clublist"]];
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        //        WeLog(@"俱乐部个数:%d",[gotArray count]);
        if ([list count] == 0 && [gotArray count] == 0) {
            UILabel *allLabel = [[UILabel alloc] init];
            allLabel.frame = CGRectMake(0, 0, _tableView.infiniteScrollingView.frame.size.width, _tableView.infiniteScrollingView.frame.size.height);
            allLabel.backgroundColor = [UIColor whiteColor];
            switch (listType) {
                case 2:{    //我加入的俱乐部
                    allLabel.text = @"未加入俱乐部";
                    break;
                }
                case 3:{    //我关注的俱乐部
                    allLabel.text = @"未关注俱乐部";
                    break;
                }
                    
                default:
                    break;
            }
            allLabel.tag = 302;
            allLabel.textColor = [UIColor grayColor];
            allLabel.textAlignment = NSTextAlignmentCenter;
            allLabel.font = [UIFont systemFontOfSize:20];
            [_tableView.infiniteScrollingView addSubview:allLabel];
        }
        else if([startKey isEqualToString:@"end"]){
            UILabel *allLabel = [[UILabel alloc] init];
            allLabel.frame = CGRectMake(0, 0, _tableView.infiniteScrollingView.frame.size.width, _tableView.infiniteScrollingView.frame.size.height);
            allLabel.backgroundColor = [UIColor whiteColor];
            switch (listType) {
                case 2:{    //我加入的俱乐部
                    allLabel.text = @"已经显示全部";
                    break;
                }
                case 3:{    //我关注的俱乐部
                    allLabel.text = @"已经显示全部";
                    break;
                }
                    
                default:
                    break;
            }
            allLabel.tag = 302;
            allLabel.textColor = [UIColor grayColor];
            allLabel.textAlignment = NSTextAlignmentCenter;
            allLabel.font = [UIFont systemFontOfSize:20];
            [_tableView.infiniteScrollingView addSubview:allLabel];
        }
        for (NSDictionary *clubDic in gotArray) {
            Club *myclub = [[Club alloc]initWithDictionary:clubDic];
            [list addObject:myclub];
        }
        int minCount;
        if (iPhone5) {
            minCount = 5;
        }else{
            minCount = 4;
        }
        if ([gotArray count]%4) {
            if ([gotArray count]/4+1<= minCount) {
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height)];
            }else{
                if ([list count] == [gotArray count]) {
                    [pullToScroll setContentSize:CGSizeMake(320, pullToScroll.frame.size.height + 30)];
                }
                else{
                    [pullToScroll setContentSize:CGSizeMake(320, pullToScroll.frame.size.height + 91.75*([gotArray count]/4+1)+5)];
                }
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + 91.75*([gotArray count]/4+1))];
            }
        }else{
            if ([gotArray count]/4<=minCount) {
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height )];
            }else{
                if ([list count] == [gotArray count]) {
                    [pullToScroll setContentSize:CGSizeMake(320, pullToScroll.frame.size.height + 30)];
                }
                else{
                    [pullToScroll setContentSize:CGSizeMake(320, pullToScroll.frame.size.height + 91.75*([gotArray count]/4+1)+5)];
                }
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + 91.75*([gotArray count]/4))];
            }
            
        }
        [_tableView reloadData];
        [gridView reloadData];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]) {
        //判断如果有权限在跳入新界面
        Club *myclub = [list objectAtIndex:clubToGoNO];
        myclub.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        myclub.type = [[dic objectForKey:@"openType"] intValue];
        club.isClosed = [dic objectForKey:@"isclose"];
        if ([club.isClosed intValue]) {
            [Utility MsgBox:@"该俱乐部已关闭"];
            return;
        }
        if (myclub.type && myclub.userType == 0) {
            [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
            return;
        }
        myclub.followThisClub = [[dic objectForKey:KEY_FOLLOW_THIS_CLUB] intValue];
        WeLog(@"是否关注该俱乐部%d",myclub.followThisClub);
        ClubViewController *clubView = [[ClubViewController alloc]init];
        clubView.club = myclub;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
        WeLog(@"登陆用户在该俱乐部的身份%d",club.userType);
        clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
        [self.navigationController pushViewController:clubView animated:YES];
    }else if ([type isEqualToString:URL_CLUB_MEMBER_REMOVE]){
        WeLog(@"ROW:%d",self.deleteNO.row);
        [list removeObjectAtIndex:self.deleteNO.row];
        
        [_tableView deleteRowsAtIndexPaths:@[self.deleteNO] withRowAnimation:UITableViewRowAnimationLeft];
        [self refreshTableFooter];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else if ([type isEqualToString:URL_CLUB_JOIN]){
        [Utility showHUD:@"申请成功"];
    }else if ([type isEqualToString:URL_CLUB_SEARCH_MEMBER_LIST]){
        WeLog(@"智能提示:");
        NSArray *dicList = [dic objectForKey:KEY_MEMBER_LIST];
        if ([mySearchBar isFirstResponder]) {
            WeLog(@"现在searchbar的文字:%@",mySearchBar);
            for (int i = 0; i < [dicList count]; i++) {
                [Utility printDic:[dicList objectAtIndex:i]];
            }
            [tmpList removeAllObjects];
            [tmpList addObjectsFromArray:list];
            [list removeAllObjects];
            [list addObjectsFromArray:dicList];
            for (int i = 0; i < [list count]; i++) {
                [Utility printDic:[list objectAtIndex:i]];
            }
            [_tableView reloadData];
        }
        
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_MEMBER_REMOVE]) {
        //容错处理
        if ([menuBtn.titleLabel.text isEqualToString:@"完成"]){
            [_tableView setEditing:NO animated:NO];
            [_tableView setEditing:YES animated:NO];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
        [dic setValue:searchText forKey:KEY_PREFIX];
        [rp sendDictionary:dic andURL:URL_CLUB_SEARCH_MEMBER_LIST andData:nil];
    }else{
        isLoadMore = NO;
        [self loadData];
    }
}

-(void)refreshTableFooter{
    UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    tintLbl.backgroundColor = [UIColor clearColor];
    tintLbl.textColor = [UIColor grayColor];
    tintLbl.textAlignment = NSTextAlignmentCenter;
    _tableView.tableFooterView = tintLbl;
    if ([startKey isEqualToString:KEY_END]) {
        if ([list count]) {
            tintLbl.text = @"已显示全部";
        }else{
            tintLbl.text = [NSString stringWithFormat:@"%@暂无",self.title];
        }
    }else{
        tintLbl.text = @"上拉加载更多";
    }
}

-(void)stop{
    [_tableView.infiniteScrollingView stopAnimating];
    [_tableView.pullToRefreshView stopAnimating];
    _tableView.pullToRefreshView.lastUpdatedDate = [NSDate date];
    [pullToScroll.infiniteScrollingView stopAnimating];
    [pullToScroll.pullToRefreshView stopAnimating];
    pullToScroll.pullToRefreshView.lastUpdatedDate = [NSDate date];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(void)deleteMember{
    if ([[[list objectAtIndex:self.deleteNO.row] objectForKey:@"membertype"] integerValue] == 1)
    {
        [Utility MsgBox:@"该会员为版主,请先移交版主职务再移出"];
        [menuBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    if ([[[list objectAtIndex:self.deleteNO.row] objectForKey:@"membertype"] integerValue] == 2) {
        [Utility MsgBox:@"该会员为版副，请先撤消版副职务再移出"];
        [menuBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    if ([[[list objectAtIndex:self.deleteNO.row] objectForKey:@"membertype"] integerValue] == 13) {
        [Utility MsgBox:@"该会员为荣誉会员，请先撤消荣誉会员再移出"];
        [menuBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:[[list objectAtIndex:self.deleteNO.row] objectForKey:KEY_USER_ROW_KEY] forKey:KEY_USER_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_CLUB_MEMBER_REMOVE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)loadData{
    WeLog(@"startKey%@",startKey);
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [_tableView.infiniteScrollingView stopAnimating];
            [_tableView.pullToRefreshView stopAnimating];
            [pullToScroll.infiniteScrollingView stopAnimating];
            [pullToScroll.pullToRefreshView stopAnimating];
            isLoadMore = NO;
            return;
        }
    }else{
        startKeystring = @"0";
    }
    WeLog(@"urls:%@",[postURL objectAtIndex:listType]);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    if (0 == listType || 1== listType) {
        [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    }else if(2 == listType || 3== listType){
        [dic setValue:userRowKey forKey:KEY_USER_ROW_KEY];
        WeLog(@"userRowKey:%@",userRowKey);
    }
    
    [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    [dic setValue:startKeystring forKey:KEY_STARTKEY];
    [rp sendDictionary:dic andURL:[postURL objectAtIndex:listType] andData:nil];
}

- (void)back{
    flag = YES;
    [self.navigationController popViewControllerAnimated:YES];
    [rp cancel];
}

-(void)editMembers{
    WeLog(@"rightButtonItem%@",menuBtn.titleLabel.text);
    if ([menuBtn.titleLabel.text
         isEqualToString:@"编辑"]) {
        [_tableView setEditing:YES animated:YES];
        [menuBtn setTitle:@"完成" forState:UIControlStateNormal];
    }else{
        [_tableView setEditing:NO animated:YES];
        [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    
}
#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"移出";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (3 == listType || 2 == listType) {
        if (iPhone5) {
            return (myConstants.screenHeight-20-44-49)/6;
        }else{
            return (myConstants.screenHeight-20-44-49)/5+2;
        }
    }else if(0 == listType ||1 == listType){
        if ([[[list objectAtIndex:indexPath.row] objectForKey:@"membertype"] integerValue] == 1 || [[[list objectAtIndex:indexPath.row] objectForKey:@"membertype"] integerValue] == 2||[[[list objectAtIndex:indexPath.row] objectForKey:@"membertype"] integerValue] == 13){
            return 74;
        }
        return 70;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    if (3 == listType || 2 == listType) {
        ClubCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[ClubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.backgroundColor = [UIColor clearColor];
        }
        Club *myclub = [list objectAtIndex:indexPath.row];
        [cell initWithClub:myclub];
        return cell;
    }else if(0 == listType ||1 == listType){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [Utility removeSubViews:cell.contentView];
        
        
        UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        avatar.layer.masksToBounds = YES;
        avatar.layer.cornerRadius = 5;
        [avatar setImageWithURL:USER_HEAD_IMG_URL(@"small", [[list objectAtIndex:indexPath.row] objectForKey:@"photo"]) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 15)];
        [nameLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
        nameLabel.text = [[list objectAtIndex:indexPath.row] objectForKey:KEY_NAME];
        [cell.contentView addSubview:nameLabel];
        
        
        CGSize size = [nameLabel.text sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(900, 15) lineBreakMode:UILineBreakModeTailTruncation];
        if ([[[list objectAtIndex:indexPath.row] objectForKey:@"membertype"] integerValue] == 1)
        {
            UIImageView *adminIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 60, 32, 12)];
            adminIcon.image = [UIImage imageNamed:@"bz.png"];
            [cell.contentView addSubview:adminIcon];
        }
        
        if ([[[list objectAtIndex:indexPath.row] objectForKey:@"membertype"] integerValue] == 2) {
            UIImageView *adminIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 60, 32, 12)];
            adminIcon.image = [UIImage imageNamed:@"bf.png"];
            [cell.contentView addSubview:adminIcon];
        }
        
        if ([[[list objectAtIndex:indexPath.row] objectForKey:@"membertype"] integerValue] == 13) {
            UIImageView *adminIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 60, 50, 12)];
            adminIcon.image = [UIImage imageNamed:@"honorMember.png"];
            [cell.contentView addSubview:adminIcon];
        }
        
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 25, 200, 20)];
        descLabel.tag = 1000;
        [Utility styleLbl:descLabel withTxtColor:nil withBgColor:nil withFontSize:14];
        //        descLabel.text = [[list objectAtIndex:indexPath.row] objectForKey:KEY_DESC];
        [Utility emotionAttachString:[[list objectAtIndex:indexPath.row] objectForKey:KEY_DESC] toView:descLabel font:14 isCut:YES];
        
        
        UIImageView *sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(165, 2, 20, 20)];
        if ([[[list objectAtIndex:indexPath.row] objectForKey:KEY_SEX] isEqualToString:@"0"]) {
            sexImg.image = [UIImage imageNamed:@"user_male.png"];
        }else if ([[[list objectAtIndex:indexPath.row] objectForKey:KEY_SEX] isEqualToString:@"1"]){
            sexImg.image = [UIImage imageNamed:@"user_female.png"];
        }
        UIImageView *distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(195, 3, 20, 20)];
        distanceIcon.image = [UIImage imageNamed:@"location.png"];
        UILabel *distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(distanceIcon.frame.origin.x+distanceIcon.frame.size.height, distanceIcon.frame.origin.y, 100, 16)];
        [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:14];
        distanceLbl.text = [Utility getDistanceString:[[list objectAtIndex:indexPath.row] objectForKey:KEY_LOCATION]];
        [cell.contentView addSubview:distanceIcon];
        [cell.contentView addSubview:distanceLbl];
        [cell.contentView addSubview:sexImg];
        [cell.contentView addSubview:avatar];
        [cell.contentView addSubview:descLabel];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (0 == listType && (club.userType ==USER_TYPE_ADMIN || club.userType ==USER_TYPE_VICE_ADMIN)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
    return;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == listType&& (club.userType ==USER_TYPE_ADMIN || club.userType ==USER_TYPE_VICE_ADMIN)){
        //        [[tableView cellForRowAtIndexPath:indexPath] viewWithTag:1000].frame = CGRectMake(60, 25, 170, 20);
        [menuBtn setTitle:@"完成" forState:UIControlStateNormal];
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.deleteNO = indexPath;
        [self deleteMember];
        // Delete the row from the data source
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

//跳到俱乐部页
- (void)goClub:(int)indexNum{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    clubToGoNO = indexNum;
    Club *myclub = [list objectAtIndex:indexNum];
    [dic setValue:myclub.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (3 == listType || 2 == listType) {
        [self goClub:indexPath.row];
    }else{
        if (usedForMemberAssign) {
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECT_CLUB_MEMBER" object:[[list objectAtIndex:indexPath.row] objectForKey:KEY_NAME] userInfo:nil];
            [refreshDel refresh:[NSDictionary dictionaryWithObject:[[list objectAtIndex:indexPath.row] objectForKey:KEY_NAME] forKey:KEY_NAME]];
            [self back];
        }else{
            PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[[list objectAtIndex:indexPath.row] objectForKey:KEY_NAME]];
            [self.navigationController pushViewController:personInfoView animated:YES];
        }
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
    //    searchResults = [searchHistoryItems filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
} // called when search results button pressed

#pragma mark UISearchBar and UISearchDisplayController Delegate Methods
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    //準備搜尋前，把上面調整的TableView調整回全屏幕的狀態，如果要產生動畫效果，要另外執行animation代碼
    //    self.myTableView.frame = CGRectMake(0, 0, 320, self.myTableView.frame.size.height);
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    //搜尋結束後，恢復原狀，如果要產生動畫效果，要另外執行animation代碼
    //    self.myTableView.frame = CGRectMake(60, 40, 260, self.myTableView.frame.size.height);
    //    [list removeAllObjects];
    //    [list addObjectsFromArray:tmpList];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    //一旦SearchBar輸入內容有變化，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles]
      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    WeLog(@"searchString%@%d",searchString,[searchString length]);
    
    return YES;
}
-(void)initNavigation{
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    if (1 == listType) {
        //        titleLbl.text =[NSString stringWithFormat:@"关注者(%@)",club.followCount];
        //        titleLbl.text =@"关注者";
        self.title = @"关注者";
    }else if(0 == listType){
        //        titleLbl.text =[NSString stringWithFormat:@"会员(%@)",club.memberCount];
        //        titleLbl.text =@"会员";
        self.title = @"会员";
    }else if (2 == listType){
        //        titleLbl.text =[NSString stringWithFormat:@"%@加入的俱乐部",userName];
        self.title =[NSString stringWithFormat:@"%@加入的俱乐部",userName];
    }else if (3 == listType){
        //        titleLbl.text = [NSString stringWithFormat:@"%@关注的俱乐部",userName];
        self.title =[NSString stringWithFormat:@"%@关注的俱乐部",userName];
    }
    
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    if (labelsize.width>240) {
        labelsize.width = 240;
    }
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    //    self.navigationItem.titleView = titleLbl;
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    if ((club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN)&&listType == 0&&!usedForMemberAssign) {
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
        [menuBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
        [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(editMembers) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
        self.navigationItem.rightBarButtonItem = menuBtnItem;
    }
    else if (2 == listType || 3 == listType)
    {
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 0,30, 30);
        [menuBtn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
        self.navigationItem.rightBarButtonItem = rightbtn;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

- (void)alertString:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - GridView Methods
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView
{
    return [list count];
}

- (MMGridViewCell *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index
{
    if ((club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN)&&listType == 0&&!usedForMemberAssign) {
        return nil;
    }
    if(0 == listType ||1 == listType){return nil;}
    
    MMGridViewCell *cell = [[MMGridViewCell alloc] initWithFrame:CGRectNull];
    Club *clubInfo = [list objectAtIndex:index];
    [Utility removeSubViews:cell];
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(8, 5, 60, 60)];
    [logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/club/file?name=%@0_p&type=%@",HOST,PHP,clubInfo.ID,TYPE_THUMB]] placeholderImage:[UIImage imageNamed:LOGO_PIC_HOLDER]];
    CLUB_LOGO(logo, clubInfo.ID,clubInfo.picTime);
    logo.frame = CGRectMake(8.7, 5, 60, 60);
    logo.layer.masksToBounds = YES;
    logo.layer.cornerRadius = 5;
    
    UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(3, 63, 70, 18)];
    nameLbl.font = [UIFont fontWithName:FONT_NAME_ARIAL size:10];
    nameLbl.textAlignment = UITextAlignmentCenter;
    nameLbl.text = clubInfo.name;
    nameLbl.numberOfLines = 2;
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.textColor = [UIColor colorWithRed:230.0/255.0 green:59.0/255.0 blue:28.0/255.0 alpha:1.0];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(9, 77, 70, 12)];
    
    UIImageView *typeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
    typeIcon.image = [UIImage imageNamed:@"type.png"];
    UILabel *typeLbl = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, 30, 12)];
    typeLbl.text = [myConstants.clubCategory objectAtIndex: [clubInfo.category intValue]];
    [Utility styleLbl:typeLbl withTxtColor:nil withBgColor:nil withFontSize:8];
    
    UIImageView *distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(28, 0, 12, 12)];
    distanceIcon.image = [UIImage imageNamed:@"location.png"];
    UILabel *distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(37, 0, 40, 12)];
    if ([clubInfo.distance hasSuffix:@"以内"]) {
        distanceLbl.text = [clubInfo.distance stringByReplacingOccurrencesOfString:@"以内" withString:@""];
    }else{
        distanceLbl.text = clubInfo.distance;
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
    return cell;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [mySearchBar resignFirstResponder];
}

- (void)gridView:(MMGridView *)gridView didSelectCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index
{
    [self goClub:index];
}

#pragma mark -
#pragma mark  切换tableView和gridview
- (void)changeView:(id)sender
{
    WeLog(@"change view...");
    UIButton *btn = (UIButton *)sender;
    NSString * subtype;
    if (!flag) {
        subtype = kCATransitionFromRight;
        pullToScroll.hidden = YES;
        gridView.hidden = YES;
        _tableView.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    }else{
        subtype = kCATransitionFromLeft;
        _tableView.hidden = YES;
        pullToScroll.hidden = NO;
        gridView.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    }
    [self.view.layer addAnimation:[Utility createAnimationWithType:@"cube" withsubtype:subtype withDuration:0.3f] forKey:@"animation"];
    
    flag = !flag;
}
@end
