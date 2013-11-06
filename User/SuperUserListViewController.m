//
//  SuperUserListViewController.m
//  WeClub
//
//  Created by Archer on 13-4-18.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "SuperUserListViewController.h"

@interface SuperUserListViewController ()

@end

@implementation SuperUserListViewController

@synthesize nextPageFlag = _nextPageFlag;
@synthesize loading = _loading;
@synthesize userName = _userName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNumberID:(NSString *)numberID andType:(int)type
{
    self = [super init];
    if (self) {
        _numberID = numberID;
        _currentType = type;
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        _nextPageFlag = @"0";
        _dataArray = [[NSMutableArray alloc] init];
        
        [self loadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    flag = YES;
    
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 240, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont systemFontOfSize:18];
    if (_currentType == 0) {
        headerLabel.text = [NSString stringWithFormat:@"%@关注的人",_userName];
    }else if (_currentType == 1) {
        headerLabel.text = [NSString stringWithFormat:@"关注%@的人",_userName];
    }else if (_currentType == 3) {
        headerLabel.text = _numberID;
    }
    self.navigationItem.titleView = headerLabel;
    
    //rightBarButtonItem
    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0,30, 30);
    [menuBtn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = rightbtn;
    
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-64) style:UITableViewStylePlain];
    tableView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-64);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.hidden = NO;
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:tableView];
    
    myConstants = [Constants getSingleton];
    
    gridView= [[MMGridView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    NSLog(@"grid view frame:%f,%f,%f,%f",gridView.frame.origin.x,gridView.frame.origin.y,gridView.frame.size.width,gridView.frame.size.height);
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
    [pullToScroll setBackgroundColor:[UIColor whiteColor]];
    [pullToScroll addSubview:gridView];
    [self.view addSubview:pullToScroll];
    
    _loading = NO;
    
    //为了处理在block中使用self的问题，不懂是什么意思
    __block typeof(self) bself = self;
    
    [tableView addPullToRefreshWithActionHandler:^{
        NSLog(@"refresh...");
        if (bself.loading) {
            [tableView.pullToRefreshView stopAnimating];
            return;
        }
        bself.nextPageFlag = @"0";
        [bself loadData];
    }];
    
    [tableView addInfiniteScrollingWithActionHandler:^{
        NSLog(@"load more data...");
        if (bself.loading) {
            [tableView.infiniteScrollingView stopAnimating];
            return;
        }
        [bself loadData];
    }];
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
        NSLog(@"%d",tableView.infiniteScrollingView.state);
        if (pullToScroll.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.loading = YES;
            [bself loadData];
            
        }else{
            [gridView.scrollView.infiniteScrollingView stopAnimating];
        }
    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewController
{
    flag = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData
{
    _loading = YES;
    NSLog(@"next:%@",_nextPageFlag);
    if ([_nextPageFlag isEqualToString:@"end"]) {
        [tableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1];
//        [self performSelector:@selector(alertString:) withObject:@"已显示全部" afterDelay:1];
        _loading = NO;
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        return;
    }
    if (_currentType == 0) {
        [_rp getUsersIFollow:_numberID total:@"10" last:_nextPageFlag];
    }else if (_currentType == 1) {
        [_rp getUsersFollowMe:_numberID total:@"10" last:_nextPageFlag];
    }else if (_currentType == 2) {
        [_rp getUsersBlackList:_numberID total:@"10" last:_nextPageFlag];
    }else if (_currentType == 3){
        [_rp searchUserWithID:_numberID total:@"10" andStartKey:_nextPageFlag];
    }else{
        [self alertString:@"error current type..."];
    }
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(void)stop{
    [tableView.infiniteScrollingView stopAnimating];
    [tableView.pullToRefreshView stopAnimating];
    [pullToScroll.infiniteScrollingView stopAnimating];
    [pullToScroll.pullToRefreshView stopAnimating];
    tableView.pullToRefreshView.lastUpdatedDate = [NSDate date];
    pullToScroll.pullToRefreshView.lastUpdatedDate = [NSDate date];
}

#pragma mark - Table view data source

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
    
//    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
//    NSString *photo = [dic objectForKey:@"photo"];
//    [cell.photo setImageWithURL:USER_HEAD_IMG_URL(@"small", photo)];
//    [cell setName:[dic objectForKey:@"name"]];
//    cell.generation.text = [dic objectForKey:@"birthday"];
//    NSString *sex = [dic objectForKey:@"sex"];
//    if ([sex isEqualToString:@"0"]) {
//        UIImage *male = [UIImage imageNamed:@"user_male.png"];
//        cell.sex.image = male;
//    }else if ([sex isEqualToString:@"1"]){
//        UIImage *female = [UIImage imageNamed:@"user_female.png"];
//        cell.sex.image = female;
//    }
//    NSString *location = [dic objectForKey:@"location"];
//    if ([location isEqualToString:@"0"]) {
//        cell.distance.text = [Utility getDistanceString:@"0.01,0.01"];
//    }else{
//        cell.distance.text = [Utility getDistanceString:location];
//    }
//    cell.autograph.text = [dic objectForKey:@"desc"];
//    [self attachString:cell.autograph.text toView:cell.autograph];
//    CGRect descRect = cell.autograph.frame;
//    descRect.size.height = 43;
//    cell.autograph.text = @"";
//    cell.autograph.frame = descRect;
    
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
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        return;
    }
    PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] initWithNumberID:numberID];
    personInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personInfo animated:YES];
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_IFOLLOW] || [type isEqualToString:REQUEST_TYPE_FOLLOWME] || [type isEqualToString:REQUEST_TYPE_BLACKLIST] || [type isEqualToString:REQUEST_TYPE_SEARCH_USER]) {
        if ([_nextPageFlag isEqualToString:@"0"]) {
            [_dataArray removeAllObjects];
            tableView.contentOffset = CGPointZero;
        }
        NSArray *newData = [dic objectForKey:REQUEST_MSGKEY_MSG];
        NSLog(@"length:%d",[newData count]);
        if ([_nextPageFlag isEqualToString:@"0"] && 0 == [newData count]) {
            UILabel *allLabel = [[UILabel alloc] init];
            allLabel.frame = CGRectMake(0, 0, tableView.infiniteScrollingView.frame.size.width, tableView.infiniteScrollingView.frame.size.height);
            allLabel.backgroundColor = [UIColor whiteColor];
            switch (_currentType) {
                case 0:{
                    allLabel.text = @"未关注用户";
                    break;
                }
                case 1:{
                    allLabel.text = @"未被用户关注";
                    break;
                }
                case 3:{
                    allLabel.text = @"未搜索到相关用户";
                    break;
                }
                    
                default:
                    break;
            }
            
            allLabel.tag = 302;
            allLabel.textColor = [UIColor grayColor];
            allLabel.textAlignment = NSTextAlignmentCenter;
            allLabel.font = [UIFont systemFontOfSize:20];
            [tableView.infiniteScrollingView addSubview:allLabel];
            
        }
        for (NSDictionary *dic in newData) {
            [_dataArray addObject:dic];
        }
    }
    NSString *flag = [NSString stringWithFormat:@"%@", [dic objectForKey:REQUEST_MSGKEY_FLAG]];
    
    
    if ([flag isEqualToString:@"0"]) {
        _nextPageFlag = @"end";
        return;
    }else if([flag isEqualToString:@"end"]){
        if (!([_nextPageFlag isEqualToString:@"0"] &&
              [[dic objectForKey:REQUEST_MSGKEY_MSG] count] == 0)) {
            UILabel *allLabel = [[UILabel alloc] init];
            allLabel.frame = CGRectMake(0, 0, tableView.infiniteScrollingView.frame.size.width, tableView.infiniteScrollingView.frame.size.height);
            allLabel.backgroundColor = [UIColor whiteColor];
            allLabel.text = @"已显示全部";
            allLabel.tag = 301;
            allLabel.textColor = [UIColor grayColor];
            allLabel.textAlignment = NSTextAlignmentCenter;
            allLabel.font = [UIFont systemFontOfSize:20];
            [tableView.infiniteScrollingView addSubview:allLabel];
        }
        _nextPageFlag = @"end";
    }else{
        _nextPageFlag = flag;
    }
    if (_nextPageFlag == nil) {
        [self alertString:@"error flag..."];
    }
    int minCount;
    if (iPhone5) {
        minCount = 5;
    }else{
        minCount = 4;
    }
    
    NSLog(@"gridView.frame : %f,%f,%f,%f", gridView.frame.origin.x, gridView.frame.origin.y, gridView.frame.size.height, gridView.frame.size.width);
    
    if ([_dataArray count]%4) {
        if ([_dataArray count]/4+1<= minCount) {
            [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
            [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }else{
            [pullToScroll setContentSize:CGSizeMake(320, 91.75*([_dataArray count]/4+1)+5)];
            [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }
    }else{
        if ([_dataArray count]/4<=minCount) {
            [pullToScroll setContentSize:CGSizeMake(320, (myConstants.screenHeight-20-44-49)+5)];
            [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }else{
            [pullToScroll setContentSize:CGSizeMake(320, 91.75*([_dataArray count]/4)+5)];
            [gridView setFrame:CGRectMake(0, -1, 320, gridView.frame.size.height + myConstants.screenHeight * 0.75)];
        }
        
    }

    [tableView.pullToRefreshView stopAnimating];
    [tableView.infiniteScrollingView stopAnimating];
    //    CGPoint loc = _userTableView.contentOffset;
    //    NSLog(@"loc:%f",loc.y);
    [tableView reloadData];
    [gridView reloadData];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
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
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

- (void)alertString:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 字符串解析函数

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self cutMixedString:str];
    //    NSLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    UIColor *nameColor = [UIColor blueColor];
    UIColor *labelColor = [UIColor redColor];
    UIColor *linkerColor = [UIColor greenColor];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"@"] && [piece hasSuffix:@" "]) {
                //@username
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:nameColor forState:UIControlStateNormal];
                    
                    [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
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
                        UILabel *subLabel = [[UILabel alloc] init];
                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                        subLabel.text = subString;
                        NSLog(@"ttt:%@",subString);
                        subLabel.textColor = nameColor;
                        subLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:subLabel];
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:titleKey forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    UILabel *subLabel = [[UILabel alloc] init];
                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                    subLabel.text = piece;
                    NSLog(@"mmm:%@",piece);
                    subLabel.textColor = nameColor;
                    subLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:subLabel];
                    [btn setTitle:titleKey forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"#"] && [piece hasSuffix:@"#"] && piece.length>1){
                //#话题#
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:labelColor forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
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
                        UILabel *subLabel = [[UILabel alloc] init];
                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                        subLabel.text = subString;
                        subLabel.textColor = labelColor;
                        subLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:subLabel];
                        [btn setTitle:titleKey forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    UILabel *subLabel = [[UILabel alloc] init];
                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                    subLabel.text = piece;
                    subLabel.textColor = labelColor;
                    subLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:subLabel];
                    [btn setTitle:titleKey forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
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
                
            }else if ([piece hasPrefix:@"http://"] && [piece hasSuffix:@" "]){
                //链接
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:linkerColor forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
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
                        UILabel *subLabel = [[UILabel alloc] init];
                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                        subLabel.text = subString;
                        subLabel.textColor = linkerColor;
                        subLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:subLabel];
                        [btn setTitle:titleKey forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    UILabel *subLabel = [[UILabel alloc] init];
                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                    subLabel.text = piece;
                    subLabel.textColor = linkerColor;
                    subLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:subLabel];
                    [btn setTitle:titleKey forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 22;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
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
                        btn.userInteractionEnabled = NO;
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
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
    //    NSLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

- (NSMutableArray *)cutMixedString:(NSString *)str
{
    //    NSLog(@"str to be cut:%@",str);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int pStart = 0;
    int pEnd = 0;
    
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"@"]) {
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            NSLog(@"fuck substring:%@",subString);
            NSRange range = [subString rangeOfString:@" "];
            
            if (range.location != NSNotFound) {
                NSString *strPiece = [subString substringToIndex:range.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
            
        }else if ([a isEqualToString:@"#"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd+1];
            NSRange range = [subString rangeOfString:@"#"];
            if (range.location != NSNotFound) {
                NSString *strPiece = [NSString stringWithFormat:@"#%@",[subString substringToIndex:range.location+1]];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"["]){
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
                //                NSLog(@"headStr:%@",headStr);
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
                //                NSLog(@"headStr:%@",headStr);
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
    
    UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(9, 66, 55, 10)];
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

#pragma mark -
#pragma mark  切换tableView和gridview
- (void)changeView:(id)sender
{
    NSLog(@"change view...");
    UIButton *btn = (UIButton *)sender;
    NSString * subtype;
    if (!flag) {
        subtype = kCATransitionFromRight;
        gridView.hidden = YES;
        pullToScroll.hidden = YES;
        tableView.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    }else{
        subtype = kCATransitionFromLeft;
        tableView.hidden = YES;
        gridView.hidden = NO;
        pullToScroll.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    }
    [self.view.layer addAnimation:[Utility createAnimationWithType:@"cube" withsubtype:subtype withDuration:0.3f] forKey:@"animation"];
    
    flag = !flag;
}


@end
