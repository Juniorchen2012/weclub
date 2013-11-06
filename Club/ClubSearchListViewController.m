//
//  ClubSearchListViewController.m
//  WeClub
//
//  Created by chao_mit on 13-4-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubSearchListViewController.h"

@interface ClubSearchListViewController ()

@end

@implementation ClubSearchListViewController


-(void)viewWillDisappear:(BOOL)animated{
    [rp cancel];
    [self stop];
    
}
- (id)initWithSearchName:(NSString *)searchName{
    self = [super init];
    if (self) {
        name = searchName;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    flag = YES;
    list = [[NSMutableArray alloc]init];
    gridView = [[MMGridView alloc]initWithFrame:CGRectMake(0, -1, 320, 400)];
    gridView.dataSource = self;
    gridView.delegate = self;
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.scrollView.scrollsToTop = NO;
    gridView.numberOfColumns = 4;
    gridView.numberOfRows = iPhone5 ?5:4;
    gridView.cellMargin = 1;
    gridView.hidden = YES;
    pullToScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44)];
    pullToScroll.hidden = YES;
    [pullToScroll addSubview:gridView];
    [self.view addSubview:pullToScroll];
    
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44)];
    myTable.delegate = self;
    myTable.dataSource = self;
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:myTable];
    //    [pullToScroll addPullToRefreshWithActionHandler:^{
    //        //        [bself loadData];
    //        //        if (gridView.scrollView.pullToRefreshView.state == SVPullToRefreshStateLoading)
    //        //        [gridView.scrollView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1.0];
    //        if (pullToScroll.pullToRefreshView.state == SVPullToRefreshStateLoading)
    //        {
    //            bself.isLoadMore = NO;
    //            [bself loadData];
    //        }
    //    }];
    //    [pullToScroll addInfiniteScrollingWithActionHandler:^{
    //        if (pullToScroll.pullToRefreshView.state == SVPullToRefreshStateStopped)
    //        {
    //            bself.isLoadMore = YES;
    //            [bself loadData];
    //
    //        }else{
    //            [gridView.scrollView.infiniteScrollingView stopAnimating];
    //        }
    //    }];
    
    [self loadData];
}

#pragma mark -
#pragma mark  切换tableView和gridview
- (void)changeView{
    NSString * subtype;
    if (flag) {
        subtype = kCATransitionFromRight;
        pullToScroll.hidden = NO;
        gridView.hidden = NO;
        myTable.hidden = YES;
        //        self.tableView.hidden = YES;
        //        self.tableView.scrollEnabled = NO;
        //        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [menuBtn setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    }else{
        subtype = kCATransitionFromLeft;
        pullToScroll.hidden = YES;
        gridView.hidden = YES;
        myTable.hidden = NO;
        [menuBtn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    }
    [self.view.layer addAnimation:[Utility createAnimationWithType:@"cube" withsubtype:subtype withDuration:0.3f] forKey:@"animation"];
    
    //    [gridView.scrollView addInfiniteScrollingWithActionHandler:^{
    //        WeLog(@"load more data");
    //        [self loadData];
    //    }];
    flag = !flag;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //加入退出俱乐部的alert
    if (0 == alertView.tag ) {
        if (buttonIndex == 1) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            Club *club = [list objectAtIndex:clubToGoNO];
            [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
            [rp sendDictionary:dic andURL:URL_CLUB_JOIN andData:nil];
        }else{
            return;
        }
        return;
    }
}

#pragma mark -
#pragma mark GridView Methods
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView{
    return [list count];
}

- (MMGridViewCell*)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index{
    MMGridViewCell *cell = [[MMGridViewCell alloc] initWithFrame:CGRectNull];
    Club *club = [list objectAtIndex:index];
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

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_SEARCH_BY_NAME]) {
        NSArray *gotArray = [NSArray arrayWithArray:[[dic objectForKey:@"data"] objectForKey:@"clublist"]];
        WeLog(@"俱乐部个数:%d",[gotArray count]);
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        for (NSDictionary *clubDic in gotArray) {
            Club *club = [[Club alloc]initWithDictionary:clubDic];
            [list addObject:club];
        }
        [myTable reloadData];
        [gridView reloadData];
        
        int minCount;
        if (iPhone5) {
            minCount = 5;
        }else{
            minCount = 4;
        }
        if ([list count]%4) {
            if ([list count]/4+1<= minCount) {
                //bug fixed;该页没有TabBar
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }else{
                [pullToScroll setContentSize:CGSizeMake(320, 91.75*([list count]/4+1)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }
        }else{
            if ([list count]/4<=minCount) {
                [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }else{
                [pullToScroll setContentSize:CGSizeMake(320, 91.75*([list count]/4)+5)];
                [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
                
            }
            
        }
        WeLog(@"  Height%f", gridView.scrollView.frame.size.height);
        
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]) {
        //判断如果有权限在跳入新界面
        Club *club = [list objectAtIndex:clubToGoNO];
        club.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        club.isClosed = [dic objectForKey:@"isclose"];
        if ([club.isClosed intValue]) {
            [Utility MsgBox:@"该俱乐部已关闭"];
            return;
        }
        if (club.type && club.userType == 0) {
            [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
            return;
        }
        club.followThisClub = [[dic objectForKey:KEY_FOLLOW_THIS_CLUB] intValue];
        WeLog(@"是否关注该俱乐部%d",club.followThisClub);
        ClubViewController *clubView = [[ClubViewController alloc]init];
        clubView.club = club;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
        WeLog(@"登陆用户在该俱乐部的身份%d",club.userType);
        clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
        [self.navigationController pushViewController:clubView animated:YES];
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
    [myTable.pullToRefreshView stopAnimating];
    [pullToScroll.infiniteScrollingView stopAnimating];
    [myTable.infiniteScrollingView stopAnimating];
    [pullToScroll.pullToRefreshView stopAnimating];
}

-(void)loadData{
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
    }else{
        startKeystring = @"0";
    }
    if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
        [pullToScroll.infiniteScrollingView stopAnimating];
        [myTable.infiniteScrollingView stopAnimating];
        isLoadMore = NO;
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"1" forKey:@"pagenum"];
    [dic setValue:name forKey:@"clubname"];
    [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    [rp sendDictionary:dic andURL:URL_CLUB_SEARCH_BY_NAME andData:nil];
}

//跳到俱乐部页
- (void)goClub:(int)indexNum{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    clubToGoNO = indexNum;
    Club *club = [list objectAtIndex:indexNum];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [list count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self goClub:indexPath.row];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    return 77.4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"clubcell";
    ClubCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[ClubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    Club *club = [list objectAtIndex:indexPath.row];
    [cell initWithClub:club];
    return cell;
}

-(void)initNavigation{
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = name;
    
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLbl;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0,30, 30);
    [menuBtn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = rightbtn;
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
