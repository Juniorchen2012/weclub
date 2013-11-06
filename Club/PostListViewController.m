//
//  PostListViewController.m
//  WeClub
//
//  Created by chao_mit on 13-2-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "PostListViewController.h"
#import "ClubProfileEditViewController.h"

@interface PostListViewController ()

@end

@implementation PostListViewController
@synthesize listType;
@synthesize selectedString;
@synthesize refreshDel;
@synthesize myTable;
@synthesize isLoadMore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithType:(int)myType
{
    self = [super init];
    if (self) {
        listType = myType;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [rp cancel];
    [self stop];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self initView];
    [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self loadData];
    if (firstAppear) {
        [myTable triggerPullToRefresh];
        firstAppear = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initNavigation];
    
    flag = NO;
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    [myTable performSelector:@selector(triggerPullToRefresh) withObject:nil afterDelay:1];
    firstAppear = YES;
}

-(void)back{
    myTable.tableFooterView = nil;
    [self dismissModalViewControllerAnimated:YES];
}

-(void)initView{
    self.title = [[NSArray arrayWithObjects:@"联系人",@"插入话题",@"领取俱乐部", nil] objectAtIndex:listType];
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = self.title;
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLbl;
    titleLbl.userInteractionEnabled = YES;
    [Utility addTapGestureRecognizer:titleLbl withTarget:self action:@selector(hideKeyBoard)];
    myTV.text = @"";
    
    inputField = [[UITextField alloc]initWithFrame:CGRectMake(20, 5, 280, 30)];
    inputField.delegate = self;
    inputField.placeholder = @"请输入...";
    inputField.borderStyle = UITextBorderStyleRoundedRect;
    //    [self.view addSubview:inputField];
    list = [[NSMutableArray alloc]init];
    nameList = [[NSMutableArray alloc]init];
    searchPersons  = [[NSMutableArray alloc]init];
    [myTable reloadData];
    
    [myTable scrollRectToVisible:CGRectMake(0, 0, 320, 10) animated:YES];
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    __weak __block typeof(self)bself = self;
    __weak UITableView *blockTable = myTable;
    [myTable addPullToRefreshWithActionHandler:^{
        if (blockTable.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    [myTable addInfiniteScrollingWithActionHandler:^{
        //        WeLog(@"%d",myTable.infiniteScrollingView.state);
        if (blockTable.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            
        }else{
            [blockTable.infiniteScrollingView stopAnimating];
        }
    }];
    firstAppear = YES;
    
    
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:REQUEST_URL_IFOLLOW]) {
        UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        tintLbl.backgroundColor = [UIColor clearColor];
        tintLbl.textColor = [UIColor grayColor];
        tintLbl.textAlignment = NSTextAlignmentCenter;
        myTable.tableFooterView = tintLbl;
        
        NSArray *dicList = [dic objectForKey:@"msg"];
        startKey = [dic objectForKey:@"flag"];
        for (NSDictionary *adic in dicList) {
            [Utility printDic:adic];
        }
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        [list addObjectsFromArray:dicList];
        for (int  i = 0; i < [list count]; i++) {
            [nameList addObject:[[list objectAtIndex:i] objectForKey:KEY_NAME]];
        }
        if ([[dic objectForKey:@"flag"] isEqualToString:KEY_END]) {
            if (![list count]) {
                if (0 == listType) {
                    tintLbl.text = @"暂无联系人";
                }else if (1 == listType){
                    tintLbl.text = @"暂无话题";
                }
            }else{
                tintLbl.text = @"已显示全部";
            }
        }else{
            tintLbl.text = @"上拉加载更多";
        }
        if (isLoadMore) {
            [myTable insertRowsAtIndexPaths:[Utility getIndexPaths:list withTable:myTable] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [myTable reloadData];
        }

        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        
    }else if ([type isEqualToString:URL_ARTICLE_TOPIC_LIST]){
        UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        tintLbl.backgroundColor = [UIColor clearColor];
        tintLbl.textColor = [UIColor grayColor];
        tintLbl.textAlignment = NSTextAlignmentCenter;
        myTable.tableFooterView = tintLbl;

        NSArray *gotArray = [dic objectForKey:@"contentList"];
        startKey = [dic objectForKey:KEY_STARTKEY];
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        for (NSString *st in gotArray) {
            [list addObject:[NSString stringWithFormat:@"#%@#",st]];
        }
        if ([[dic objectForKey:KEY_STARTKEY] isEqualToString:KEY_END]) {
            if ([list count]) {
                tintLbl.text = @"已显示全部";
            }else{
                tintLbl.text = @"暂无文章";
            }
        }else{
            tintLbl.text = @"上拉加载更多";
        }
        [myTable reloadData];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else if ([type isEqualToString:URL_CLUB_LIST_ADOPT]){
        _dicList = [dic objectForKey:@"list"];
        
        WeLog(@"adopt List :%@",_dicList);
        startKey = [dic objectForKey:KEY_STARTKEY];
        startKey = [dic objectForKey:KEY_STARTKEY];
        for (NSDictionary *adic in _dicList) {
            [Utility printDic:adic];
        }
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        [list addObjectsFromArray:_dicList];
        [myTable reloadData];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        if (_dicList.count == 0) {
            [self finishClaim];
            return;
        }
    }else if ([type isEqualToString:URL_CLUB_ADOPT]){
        [list removeObjectAtIndex:adoptNum];
        [myTable reloadData];
        //        if (flag) {
        //            [self finishClaim];
        //        }
        
    }
}

-(void)stop{
    [myTable.infiniteScrollingView stopAnimating];
    [myTable.pullToRefreshView stopAnimating];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self stop];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self stop];
}

- (void)adopt:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    adoptNum = btn.tag;
    /*
     NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
     [dic setValue:[[list objectAtIndex:adoptNum] objectForKey:@"numid"] forKey:@"clubid"];
     [rp sendDictionary:dic andURL:URL_CLUB_ADOPT andData:nil];
     */
    Club *club = [[Club alloc] initWithDictionary:[_dicList objectAtIndex:adoptNum]];
    ClubProfileEditViewController *edit = [[ClubProfileEditViewController alloc] initWithClub:club];
    edit.logoFlag = [[[_dicList objectAtIndex:adoptNum] objectForKey:@"hasPhoto"] integerValue];
    if (list.count == 1) {
        edit.lastAdopt = @"YES";
        edit.lastAdoptClub = club;
    }
    edit.adoptFlag = 1;
    [self.navigationController pushViewController:edit animated:YES];
}

-(void)loadData{
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [myTable.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            return;
        }
    }else{
        startKeystring = @"0";
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (1 == listType) {
        [dic setValue:@"0" forKey:KEY_SORT];
        [dic setValue:startKeystring forKey:KEY_STARTKEY];
        [dic setValue:COUNT_NUM forKey:KEY_COUNT];
        [rp sendDictionary:dic andURL:URL_ARTICLE_TOPIC_LIST andData:nil];
    }else if(0 == listType){
        [dic setValue:myAccountUser.numberID forKey:REQUEST_MSGKEY_NUMBERID];
        [dic setValue:COUNT_NUM forKey:REQUEST_MSGKEY_TOTAL];
        [dic setValue:@"0" forKey:REQUEST_MSGKEY_LAST];
        [rp sendDictionary:dic andURL:REQUEST_URL_IFOLLOW andData:nil];
    }else if(2 == listType){
        //        [dic setValue:@"zenny" forKey:@"userid"];
        [dic setValue:COUNT_NUM forKey:KEY_COUNT];
        [dic setValue:startKeystring forKey:KEY_STARTKEY];
        [rp sendDictionary:dic andURL:URL_CLUB_LIST_ADOPT andData:nil];
    }
}

- (void)saveDirectLogin
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([[ud objectForKey:@"directLogin"] isEqualToString:@"1"]) {
        return;
    }else{
        [ud setObject:@"1" forKey:@"directLogin"];
        [ud setObject:[ud objectForKey:@"defaultName"] forKey:@"directLoginName"];
        [ud setObject:[ud objectForKey:@"defaultPassword"] forKey:@"directLoginPassword"];
        [ud synchronize];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([myTV.text length]) {
        if (0 == listType) {
            return [searchPersons count];
        }else if(1 == listType){
            return [searchResults count];
        }
    }
    return [list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (1 == listType) {
        return 40;
    }else if (0 == listType){
        return 60;
    }else if (2 == listType){
        return 70;
    }
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    [Utility removeSubViews:cell.contentView];
    
    
    NSMutableArray *array;
    if ([myTV.text length]) {
        if (0 == listType) {
            array = searchPersons;
        }else if(1 == listType){
            array = searchResults;
        }
    }else{
        array = list;
    }
    
    if (0 == listType) {
        UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        avatar.userInteractionEnabled = YES;
        avatar.layer.masksToBounds = YES;
        avatar.layer.cornerRadius = 5;
        [avatar setImageWithURL:USER_HEAD_IMG_URL(@"small", [[array objectAtIndex:indexPath.row] objectForKey:@"photo"]) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
        //    [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goPersonInfo:) ]];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 80, 15)];
        [nameLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
        nameLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:KEY_NAME];
        
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 25, 240, 20)];
        [descLabel setTextColor:[UIColor grayColor]];
        [descLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
        WeLog(@"LIST object%@",[array objectAtIndex:indexPath.row]);
        descLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:KEY_DESC];
        [Utility emotionAttachString:descLabel.text toView:descLabel font:14 isCut:YES];
        descLabel.text = @"";
        [cell.contentView addSubview:avatar];
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:descLabel];
    }else if(1 == listType){
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 17)];
        [label setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:16]];
        label.text = [array objectAtIndex:indexPath.row];
        [cell.contentView addSubview:label];
    }else if (2 == listType){
        NSDictionary *dic = [array objectAtIndex:indexPath.row];
        UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
        avatar.layer.masksToBounds = YES;
        avatar.layer.cornerRadius = 5;
        CLUB_LOGO(avatar, [[array objectAtIndex:indexPath.row] objectForKey:@"numid"],[[array objectAtIndex:indexPath.row] objectForKey:KEY_PIC_TIME]);
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 230, 20)];
        //        [Utility styleLbl:name withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
        name.font = [UIFont fontWithName:FONT_NAME_ARIAL_BOLD size:16];
        
        name.text = [NSString stringWithFormat:@"%@",[dic objectForKey:KEY_NAME]];
        
        UILabel *admin = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 140, 20)];
        [Utility styleLbl:admin withTxtColor:nil withBgColor:nil withFontSize:14];
        admin.text = [NSString stringWithFormat:@"版主:%@",[dic objectForKey:@"create"]];
        UILabel *category = [[UILabel alloc]initWithFrame:CGRectMake(140, 40, 140, 20)];
        //        [Utility styleLbl:category withTxtColor:nil withBgColor:nil withFontSize:14];
        //        category.text = [NSString stringWithFormat:@"类型:%@",[myConstants.clubCategory objectAtIndex:[[dic objectForKey:@"category"] intValue]-1]];
        UILabel *desc = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 200, 30)];
        //[Utility styleLbl:desc withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:13];
        desc.font = [UIFont systemFontOfSize:13];
        desc.text = [NSString stringWithFormat:@"%@",[dic objectForKey:KEY_DESC]];
        WeLog(@"desc:%@",desc.text);
        if ([desc.text isEqualToString:@""]) {
            desc.text = @"俱乐部描述：无";
        }
        desc.numberOfLines = 2;
        desc.lineBreakMode = NSLineBreakByWordWrapping;
        
        UIButton *adoptbtn = [[UIButton alloc]initWithFrame:CGRectMake(205, 20, 40, 30)];
        [adoptbtn setTitle:@"领取" forState:UIControlStateNormal];
        [adoptbtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
        [adoptbtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        adoptbtn.backgroundColor = COLOR_RED;
        adoptbtn.tag = indexPath.row;
        [adoptbtn addTarget:self action:@selector(adopt:) forControlEvents:UIControlEventTouchUpInside];
        UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(70, 0, 240, 70)];
        [containerView addSubview:name];
        [containerView addSubview:admin];
        [containerView addSubview:desc];
        //        [containerView addSubview:category];
        [containerView addSubview:adoptbtn];
        [cell.contentView addSubview:avatar];
        [cell.contentView addSubview:containerView];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (1 == listType || 0 == listType) {
        NSArray *array;
        if ([myTV.text length]) {
            if (0 == listType) {
                array = searchPersons;
            }else if(1 == listType){
                array = searchResults;
            }
        }else{
            array = list;
        }
        if (1 == listType) {
            selectedString = [array objectAtIndex:indexPath.row];
        }else if(0 == listType){
            selectedString = [[array objectAtIndex:indexPath.row] objectForKey:KEY_NAME];
        }
        WeLog(@"selectedString%@",selectedString);
        [refreshDel refresh:nil];
        [self dismissModalViewControllerAnimated:YES];
    }else if (2 == listType){
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)finishSelect{
    if (1 == listType) {
        selectedString = [NSString stringWithFormat:@"#%@#",myTV.text];
    }else if (0 == listType){
        selectedString = myTV.text;
    }
    
    [refreshDel refresh:nil];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [myTV resignFirstResponder];
}

-(void)initNavigation{
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    if (listType == 2) {
        [self saveDirectLogin];
        UIBarButtonItem *finish = [[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(finishClaim)];
        finish.tintColor = [UIColor orangeColor];
        self.navigationItem.rightBarButtonItem = finish;
        self.navigationController.navigationBar.tintColor = TINT_COLOR;
        [btn setHidden:YES];
    }else if (listType == 1 || listType == 0){
        myTable.frame = CGRectMake(0, 40, 320, myConstants.screenHeight-20-40);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 54, 32);
        [btn addTarget:self action:@selector(finishSelect) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        UIBarButtonItem *finish = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = finish;
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 280, 35)];
        bgView.image = [UIImage imageNamed:@"txtFieldBg.png"];
        myTV = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(20, 5, 280, 30)];
        //        myTV.placeholder = @"请输入...";
        myTV.backgroundColor = [UIColor clearColor];
        //        myTV.placeHolderLabel.frame = CGRectMake(0, 20, 100, 18);
        myTV.delegate = self;
        myTV.font = [UIFont fontWithName:FONT_NAME_ARIAL size:16];
        //        myTV.layer.borderColor = [[UIColor blackColor]CGColor];
        //        myTV.layer.borderWidth = 1.0;
        myTV.layer.cornerRadius = 5;
        [self.view addSubview:bgView];
        [self.view addSubview:myTV];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText {
    NSPredicate *resultPredicate = [NSPredicate                                      predicateWithFormat:@"SELF contains[cd] %@",searchText];
    
    if (0 == listType) {
        searchResults = [nameList filteredArrayUsingPredicate:resultPredicate];
    }else{
        searchResults = [list filteredArrayUsingPredicate:resultPredicate];
    }
    
    if (!searchResults) {
        searchResults = [[NSMutableArray alloc]init];
    }
    [myTable reloadData];
}

-(void)filterPerson:(NSString *)searchText{
    [searchPersons removeAllObjects];
    for (int i = 0; i < [list  count]; i++) {
        if ([[[[list objectAtIndex:i] objectForKey:KEY_NAME] lowercaseString] rangeOfString:[searchText lowercaseString]].location != NSNotFound) {
            [searchPersons addObject:[list objectAtIndex:i]];
        }
    }
    [myTable reloadData];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    searchTxt = [NSString stringWithFormat:@"%@%@",textField.text,string];
    [self filterContentForSearchText:[NSString stringWithFormat:@"%@%@",textField.text,string]];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        //去除UITextView多行的属性
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (0 == listType) {
        [self filterPerson:textView.text];
    }else if(1 == listType){
        [self filterContentForSearchText:textView.text];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    WeLog(@"DidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    WeLog(@"DidEndEditing");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == alertView.tag) {
        if (0 == buttonIndex) {
            self.navigationController.navigationBarHidden = YES;
            TabBarController *_tabC = [[TabBarController alloc] init];
            [self.navigationController pushViewController:_tabC animated:YES];
        }else if (1 == buttonIndex){
            //edit by ytx
            //            TabBarController *_tabC = [[TabBarController alloc] init];
            //            ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
            //            [clubList newClub];
            //            [self.navigationController pushViewController:_tabC animated:YES];
            self.navigationController.navigationBarHidden = YES;
            TabBarController *_tabC = [[TabBarController alloc] init];
            
            ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
            [clubList registNewClub];
            [self.navigationController pushViewController:_tabC animated:YES];
            //    newClubView.hidesBottomBarWhenPushed = YES;
        }
    }
    return;
}

-(void)hideKeyBoard{
    [myTV resignFirstResponder];
}

//跳过认领页
- (void)finishClaim
{
    WeLog(@"finishClaim...");
    //    if ([loginFlag isEqualToString:@"1"]) {
    //
    ////        self.navigationController.navigationBarHidden = YES;
    //
    //        UIAlertView *alert = [Utility MsgBox:@"是否创建俱乐部" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"否" AndOtherBtn:@"是" withStyle:0];
    //        alert.tag = 1;
    //
    //    }else{
    self.navigationController.navigationBarHidden = YES;
    TabBarController *_tabC = [[TabBarController alloc] init];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = _tabC;
    WeLog(@"%@ %@",self.navigationController,_tabC);
    [self.navigationController pushViewController:_tabC animated:YES];
    //    }
}

@end
