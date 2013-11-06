//
//  UserListViewController.m
//  WeClub
//
//  Created by Archer on 13-3-16.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()

@end

@implementation UserListViewController

@synthesize userTableView = _userTableView;
@synthesize nextPageFlag = _nextPageFlag;
@synthesize currentType = _currentType;
@synthesize dataArray = _dataArray;
@synthesize loading = _loading;
@synthesize coverLoadingView = _coverLoadingView;
@synthesize pullToScroll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        _dataArray = [[NSMutableArray alloc] init];
        _nextPageFlag = @"0";
        _numberID = [AccountUser getSingleton].numberID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-20);
    NSLog(@"height:%f",self.view.frame.size.height);
    //加载用户列表
    CGRect tableFrame = self.view.frame;
    tableFrame.size.height = tableFrame.size.height - 49 - 44;
    tableFrame.origin.y = 0;
    _userTableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _userTableView.delegate = self;
    _userTableView.dataSource = self;
    [_userTableView setHidden:NO];
    if ([_userTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_userTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:_userTableView];
    
    myConstants = [Constants getSingleton];
    
    _gridView = [[MMGridView alloc] initWithFrame:CGRectMake(0, -1, 320, 400)];
    NSLog(@"grid view frame:%f,%f,%f,%f",_gridView.frame.origin.x,_gridView.frame.origin.y,_gridView.frame.size.width,_gridView.frame.size.height);
    _gridView.delegate = self;
    _gridView.dataSource = self;
    _gridView.backgroundColor = [UIColor whiteColor];
    _gridView.scrollView.scrollsToTop = NO;
    _gridView.numberOfColumns = 4;
    _gridView.numberOfRows = iPhone5?5:4;
    _gridView.cellMargin = 1;
    [_gridView setHidden:YES];
    pullToScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44-49)];
    pullToScroll.hidden = YES;
    [pullToScroll addSubview:_gridView];
    [self.view addSubview:pullToScroll];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserListNotification:) name:NOTIFICATION_KEY_USERLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout) name:NOTIFICATION_KEY_LOGOUT object:nil];
    
    _loading = NO;
    
    //为了处理在block中使用self的问题，不懂是什么意思
    __block typeof(self) bself = self;
    
    [pullToScroll addPullToRefreshWithActionHandler:^{
        //        [bself loadData];
        //        if (gridView.scrollView.pullToRefreshView.state == SVPullToRefreshStateLoading)
        //        [gridView.scrollView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1.0];
        if (pullToScroll.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.loading = NO;
            [bself loadData];
        }
    }];
    [pullToScroll addInfiniteScrollingWithActionHandler:^{
        NSLog(@"%d",_userTableView.infiniteScrollingView.state);
        if (pullToScroll.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.loading = YES;
            [bself loadData];
            
        }else{
            [_gridView.scrollView.infiniteScrollingView stopAnimating];
        }
    }];
    
    [_userTableView addPullToRefreshWithActionHandler:^{
        NSLog(@"refresh...");
        if (bself.loading) {
            [bself.userTableView.pullToRefreshView stopAnimating];
            return;
        }
        bself.nextPageFlag = @"0";
        [bself loadData];
    }];
    
    [_userTableView addInfiniteScrollingWithActionHandler:^{
        NSLog(@"load more data...");
        if ([bself.nextPageFlag isEqualToString:@"end"]) {
            bself.coverLoadingView.alpha = 1;
            return;
        }
        if (bself.loading) {
            [bself.userTableView.infiniteScrollingView stopAnimating];
            return;
        }
        [bself loadData];
    }];
    
    _coverLoadingView = [[UIView alloc] init];
    _coverLoadingView.frame = CGRectMake(0, 0, 320, 60);
    _coverLoadingView.backgroundColor = [UIColor whiteColor];
    _coverLoadingView.alpha = 0;
    [_userTableView.infiniteScrollingView addSubview:_coverLoadingView];
    
    UILabel *allShowLabel = [[UILabel alloc] init];
    allShowLabel.frame = _coverLoadingView.frame;
    allShowLabel.text = @"已显示全部";
    allShowLabel.textAlignment = NSTextAlignmentCenter;
    allShowLabel.textColor = [UIColor grayColor];
    [_coverLoadingView addSubview:allShowLabel];
    
//    [_gridView.scrollView addPullToRefreshWithActionHandler:^{
//        bself.nextPageFlag = @"0";
//        [bself loadData];
//    }];
//    
//    [_gridView.scrollView addInfiniteScrollingWithActionHandler:^{
//        [bself loadData];
//    }];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_loading) {
        _nextPageFlag = @"0";
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLogout
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_USERLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_LOGOUT object:nil];
}

- (void)loadData
{
    _loading = YES;
    NSLog(@"next:%@",_nextPageFlag);
    if ([_nextPageFlag isEqualToString:@"end"]) {
        [_userTableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1];
        [pullToScroll.infiniteScrollingView stopAnimating];
//        [self performSelector:@selector(alertString:) withObject:@"已显示全部" afterDelay:1];
        _loading = NO;
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        return;
    }
    if (_currentType == 0) {
        [_rp getUsersIFollow:_numberID total:@"10" last:_nextPageFlag];
    }else if (_currentType == 1) {
        [_rp getUsersFollowMe:_numberID total:@"10" last:_nextPageFlag];
    }else if (_currentType == 3) {
        [_rp getUsersBlackList:_numberID total:@"10" last:_nextPageFlag];
    }else if (_currentType == 2) {
        [_rp getUsersInfoByLocation:myAccountUser.locationInfo PageSize:@"10" StartKey:_nextPageFlag];
    }else{
        [self alertString:@"error current type..."];
    }
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(void)stop{
    [_userTableView.infiniteScrollingView stopAnimating];
    [_userTableView.pullToRefreshView stopAnimating];
    [pullToScroll.infiniteScrollingView stopAnimating];
    [pullToScroll.pullToRefreshView stopAnimating];
    _userTableView.pullToRefreshView.lastUpdatedDate = [NSDate date];
    pullToScroll.pullToRefreshView.lastUpdatedDate = [NSDate date];
}

- (void)handleUserListNotification:(NSNotification *)notification
{
    int index = [notification.object intValue];
    
    if (index == 4) {
        return;
    }else{
        _currentType = index;
    }
    _nextPageFlag = @"0";
    [self loadData];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count:%d",[_dataArray count]);
    return [_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"userListCell";
    
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UserInfoCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
    NSString *photo = [dic objectForKey:@"photo"];
    [cell.photo setImageWithURL:USER_HEAD_IMG_URL(@"small", photo) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    [cell setName:[dic objectForKey:@"name"]];
//    cell.generation.text = [dic objectForKey:@"birthday"];
    NSString *sex = [dic objectForKey:@"sex"];
    if ([sex isEqualToString:@"0"]) {
        UIImage *male = [UIImage imageNamed:@"user_male.png"];
        cell.sex.image = male;
    }else if ([sex isEqualToString:@"1"]){
        UIImage *female = [UIImage imageNamed:@"user_female.png"];
        cell.sex.image = female;
    }
    NSString *location = [dic objectForKey:@"location"];
    if ([location isEqualToString:@"0"]) {
        [cell setDistanceStr:[Utility getDistanceString:@"0.01,0.01"]];
    }else{
        [cell setDistanceStr:[Utility getDistanceString:location]];
    }
//    cell.autograph.text = [dic objectForKey:@"desc"];
    [Utility emotionAttachString:[dic objectForKey:@"desc"] toView:cell.autograph font:12 isCut:NO];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];

    
    NSString *numberID = [dic objectForKey:@"numberid"];
    if (numberID == nil) {
        [self alertString:@"没有numberid"];
        return;
    }
    PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] initWithNumberID:numberID];
    personInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personInfo animated:YES];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_IFOLLOW] || [type isEqualToString:REQUEST_TYPE_FOLLOWME] || [type isEqualToString:REQUEST_TYPE_BLACKLIST] || [type isEqualToString:REQUEST_TYPE_GETUSERINFOBYLOCATION]) {
        NSLog(@"_nextPageFlag %@",_nextPageFlag);
        if ([_nextPageFlag isEqualToString:@"end"]) {
            [_userTableView.pullToRefreshView stopAnimating];
            [_userTableView.infiniteScrollingView stopAnimating];
            _coverLoadingView.alpha = 0;
            [_userTableView reloadData];
            [_gridView reloadData];
            _loading = NO;
            [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
            return;
        }
        if ([_nextPageFlag isEqualToString:@"0"]) {
            NSLog(@"remove all");
            [_dataArray removeAllObjects];
            _userTableView.contentOffset = CGPointZero;
        }
        NSArray *newData = [dic objectForKey:REQUEST_MSGKEY_MSG];
        NSLog(@"length:%d",[newData count]);
        for (NSDictionary *dic in newData) {
            [_dataArray addObject:dic];
        }
    }
    NSString *flag = [NSString stringWithFormat:@"%@",[dic objectForKey:REQUEST_MSGKEY_FLAG]];
    if ([type isEqualToString:REQUEST_TYPE_GETUSERINFOBYLOCATION]) {
        flag = [[NSString alloc] initWithFormat:@"%@",[dic objectForKey:REQUEST_MSGKEY_STARTKEY]];
    }
    if ([flag isEqualToString:@"0"]) {
        _nextPageFlag = @"end";
    }else{
        _nextPageFlag = flag;
    }
    if (_nextPageFlag == nil) {
        [self alertString:@"error flag..."];
    }
    [_userTableView.pullToRefreshView stopAnimating];
    [_userTableView.infiniteScrollingView stopAnimating];
    _coverLoadingView.alpha = 0;
    int minCount;
    if (iPhone5) {
        minCount = 5;
    }else{
        minCount = 4;
    }
    if ([_dataArray count]%4) {
        if ([_dataArray count]/4+1<= minCount) {
            [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
            [_gridView setFrame:CGRectMake(0, -1, 320, _gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }else{
            [pullToScroll setContentSize:CGSizeMake(320, 91.75*([_dataArray count]/4+1)+5)];
            [_gridView setFrame:CGRectMake(0, -1, 320, _gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }
    }else{
        if ([_dataArray count]/4<=minCount) {
            [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
            [_gridView setFrame:CGRectMake(0, -1, 320, _gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }else{
            [pullToScroll setContentSize:CGSizeMake(320, 91.75*([_dataArray count]/4)+5)];
            [_gridView setFrame:CGRectMake(0, -1, 320, _gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }
        
    }
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
//    CGPoint loc = _userTableView.contentOffset;
//    NSLog(@"loc:%f",loc.y);
    [_userTableView reloadData];
    [_gridView reloadData];
    int static pageType = 0;
    if (_currentType != pageType) {
        [pullToScroll setContentOffset:CGPointMake(0, 0)];
        
        pageType = _currentType;
    }
    _loading = NO;
//    _userTableView.contentOffset = loc;
//    _userTableView.scrollEnabled = NO;
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [self alertString:excepDesc];
    _loading = NO;
    [_userTableView.pullToRefreshView stopAnimating];
    [_userTableView.infiniteScrollingView stopAnimating];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    _loading = NO;
    [_userTableView.pullToRefreshView stopAnimating];
    [_userTableView.infiniteScrollingView stopAnimating];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

#pragma mark - GridView Methods
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView
{
    return [_dataArray count];
}

- (MMGridViewCell *)gridView:(MMGridView *)gridView cellAtIndex:(NSUInteger)index
{
    NSDictionary *dic = [_dataArray objectAtIndex:index];
    
    MMGridViewCell *cell = [[MMGridViewCell alloc] initWithFrame:CGRectNull];
//    cell.backgroundColor = [UIColor redColor];
    
    UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(8.7, 5, 60, 60)];
    NSString *photoStr = [dic objectForKey:@"photo"];
    [photo setImageWithURL:USER_HEAD_IMG_URL(@"small", photoStr)];
    photo.layer.masksToBounds = YES;
    photo.layer.cornerRadius = 5;
    [cell addSubview:photo];
    
    UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(9, 65, 60, 12)];
    nameLbl.font = [UIFont fontWithName:FONT_NAME_ARIAL size:10];
    nameLbl.textAlignment = UITextAlignmentCenter;
    nameLbl.text = [dic objectForKey:@"name"];
    nameLbl.numberOfLines = 2;
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.textColor = [UIColor colorWithRed:230.0/255.0 green:59.0/255.0 blue:28.0/255.0 alpha:1.0];
    
    UIImageView *sexView = [[UIImageView alloc] initWithFrame:CGRectMake(65, 66, 12, 12)];
    NSString *sex = [dic objectForKey:@"sex"];
    if ([sex isEqualToString:@"0"]) {
        sexView.image = [UIImage imageNamed:@"user_male.png"];
    }else if ([sex isEqualToString:@"1"]){
        sexView.image = [UIImage imageNamed:@"user_female.png"];
    }
    [cell addSubview:sexView];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(9, 77, 70, 12)];
    
    UIImageView *generationView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 1, 11, 11)];
    generationView.image = [UIImage imageNamed:@"user_generation.png"];
    UILabel *generationLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, 30, 12)];
    generationLabel.text = [dic objectForKey:@"birthday"];
    generationLabel.font = [UIFont systemFontOfSize:8];
    generationLabel.backgroundColor = [UIColor clearColor];
    generationLabel.textColor = [UIColor grayColor];
    [Utility styleLbl:generationLabel withTxtColor:nil withBgColor:nil withFontSize:8];
    
    UIImageView *distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(28, 0, 12, 12)];
    distanceIcon.image = [UIImage imageNamed:@"location.png"];
    UILabel *distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(37, 0, 40, 12)];
    NSString *location = [dic objectForKey:@"location"];
    if ([location isEqualToString:@"0"]) {
        distanceLbl.text = [Utility getDistanceString:@"0.01,0.01"];
    }else{
        distanceLbl.text = [Utility getDistanceString:location];
    }
    
    if ([distanceLbl.text hasSuffix:@"以内"]) {
        distanceLbl.text = [distanceLbl.text stringByReplacingOccurrencesOfString:@"以内" withString:@""];
    }else{
        distanceLbl.text = distanceLbl.text;
    }
    [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:8];
    
    [bottomView addSubview:distanceIcon];
    [bottomView addSubview:distanceLbl];
    [bottomView addSubview:generationView];
    [bottomView addSubview:generationLabel];
    [cell addSubview:nameLbl];
    [cell addSubview:bottomView];
    [Utility psImageView:cell];
//    cell.backgroundColor = [UIColor lightGrayColor];
    
    return cell;
}

- (void)gridView:(MMGridView *)gridView didSelectCell:(MMGridViewCell *)cell atIndex:(NSUInteger)index
{
    NSLog(@"select grid cell:%d",index);
    NSDictionary *dic = [_dataArray objectAtIndex:index];
    NSString *numberID = [dic objectForKey:@"numberid"];
    if (numberID == nil) {
        [self alertString:@"没有numberid"];
        return;
    }
    PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] initWithNumberID:numberID];
    personInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personInfo animated:YES];
}

- (void)alertString:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -
#pragma mark  切换tableView和gridview
- (void)changeView:(id)sender
{
    NSLog(@"change view...");
    UIButton *btn = (UIButton *)sender;
    NSString * subtype;
    static BOOL flag = YES;
    if (!flag) {
        subtype = kCATransitionFromRight;
        pullToScroll.hidden = YES;
        _gridView.hidden = YES;
        _userTableView.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    }else{
        subtype = kCATransitionFromLeft;
        _userTableView.hidden = YES;
        pullToScroll.hidden = NO;
        _gridView.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    }
    [self.view.layer addAnimation:[Utility createAnimationWithType:@"cube" withsubtype:subtype withDuration:0.3f] forKey:@"animation"];
    
    flag = !flag;
}

@end
