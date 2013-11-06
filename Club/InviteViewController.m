//
//  InviteViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "InviteViewController.h"

@interface InviteViewController ()

@end

@implementation InviteViewController
@synthesize isLoadMore,isPushFromNewClub;

-(void)viewWillDisappear:(BOOL)animated{


}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithClub:(Club *)myClub
{
    self = [super init];
    if (self) {
        club = myClub;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
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
    myAccountUser = [AccountUser getSingleton];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20) style:UITableViewStylePlain];
    myTable.backgroundView = nil;
    myTable.delegate = self;
    myTable.dataSource = self;
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:myTable];
    
    list = [[NSMutableArray alloc]init];
    selectedList = [[NSMutableArray alloc]init];

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
        WeLog(@"%d",blockTable.infiniteScrollingView.state);
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

-(void)refreshRightItem{
    if ([selectedList count]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:REQUEST_URL_IFOLLOW]) {
        UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        tintLbl.backgroundColor = [UIColor clearColor];
        tintLbl.textColor = [UIColor grayColor];
        tintLbl.textAlignment = NSTextAlignmentCenter;
        myTable.tableFooterView = tintLbl;

           startKey = [dic objectForKey:@"flag"];
            NSArray *dicList = [dic objectForKey:@"msg"];
        if (![dicList count]&&isPushFromNewClub) {
            [self performSelector:@selector(back) withObject:nil afterDelay:0.5];
        }

        for (NSDictionary *adic in dicList) {
            [Utility printDic:adic];
        }
            if (!isLoadMore) {
                [list removeAllObjects];
            }
            [list addObjectsFromArray:dicList];
        for (int i = 0; i < [list count]; i++) {
            [selectedList addObject:[NSNumber numberWithBool:NO]];
        }
        if ([[dic objectForKey:@"flag"] isEqualToString:KEY_END]) {
            if ([list count]) {
                tintLbl.text = @"已显示全部";
            }else{
                tintLbl.text = @"没有可以邀请的人";
            }
        }else{
            tintLbl.text = @"上拉加载更多";
        }
        [myTable reloadData];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    }else if ([type isEqualToString:URL_CLUB_MEMBER_INVITE]) {
        UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        tintLbl.backgroundColor = [UIColor clearColor];
        tintLbl.textColor = [UIColor grayColor];
        tintLbl.textAlignment = NSTextAlignmentCenter;
        myTable.tableFooterView = tintLbl;
        [Utility showHUD:@"邀请成功"];
        if (inviteNO == -1) {
            [list removeAllObjects];
        }else{
            [list removeObjectAtIndex:inviteNO];
        }
        if ([[dic objectForKey:@"flag"] isEqualToString:KEY_END]) {
            if ([list count]) {
                tintLbl.text = @"已显示全部";
            }else{
                tintLbl.text = @"没有可以邀请的人";
            }
        }else{
            tintLbl.text = @"上拉加载更多";
        }
//        [self refreshRightItem];
        [myTable reloadData];
        [leftbtn setTitle:@"完成" forState:UIControlStateNormal];
        if (![list count]) {
            [self performSelector:@selector(back) withObject:nil afterDelay:1];
        }
    }
}



- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if ([type isEqualToString:REQUEST_URL_IFOLLOW]) {
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    }
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(void)stop{
    [myTable.infiniteScrollingView stopAnimating];
    [myTable.pullToRefreshView stopAnimating];
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
    [dic setValue:myAccountUser.numberID forKey:REQUEST_MSGKEY_NUMBERID];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:COUNT_NUM forKey:REQUEST_MSGKEY_TOTAL];
    [dic setValue:startKeystring forKey:REQUEST_MSGKEY_LAST];
    [rp sendDictionary:dic andURL:REQUEST_URL_IFOLLOW andData:nil];
}

-(void)selectAll{
    static BOOL flag = YES;
    if (flag) {
        [selectBtn setImage:[UIImage imageNamed:@"setting_chatSetting_select.png"] forState:UIControlStateNormal];
    }else{
        [selectBtn setImage:[UIImage imageNamed:@"setting_chatSetting_unselect.png"] forState:UIControlStateNormal];
    }
    [selectedList removeAllObjects];
    for (int i = 0; i < [list count]; i++) {
        [selectedList addObject:[NSNumber numberWithBool:flag]];
    }
    
    [myTable reloadData];
    flag = !flag;
}

-(void)invite:(id)sender{
    UIButton *btn = (UIButton *)sender;
    inviteNO = btn.tag;
    NSMutableString *inviteString = [[NSMutableString alloc]init];

    if (-1 == btn.tag) {
        NSMutableArray *inviteList = [[NSMutableArray alloc]init];
        if (![list count]) {
            [Utility showHUD:@"没有需要邀请的用户"];
            return;
        }
        for (int i = 0; i < [list count]; i++) {
            if (i) {
                [inviteString appendString:@","];
            }
            [inviteString appendString:[[list objectAtIndex:i] objectForKey:KEY_USER_ROW_KEY]];

//            if ([[selectedList objectAtIndex:i] boolValue]) {
//                [inviteList addObject:[[list objectAtIndex:i] objectForKey:KEY_USER_ROW_KEY]];
//            }
        }
//        if (![inviteList count]) {
//            [Utility MsgBox:@"您未选择任何用户!"];
//            return;
//        }
    }else{
        inviteString = [[list objectAtIndex:btn.tag] objectForKey:KEY_USER_ROW_KEY];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:inviteString forKey:@"inviterowkeylist"];
    [rp sendDictionary:dic andURL:URL_CLUB_MEMBER_INVITE andData:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int indexNum = indexPath.row;
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[[list objectAtIndex:indexPath.row] objectForKey:KEY_NAME]];
    [self.navigationController pushViewController:personInfoView animated:YES];
    
    return;
    if ([[selectedList objectAtIndex:indexNum] boolValue]) {
        [selectedList removeObjectAtIndex:indexNum]; 
        [selectedList insertObject:[NSNumber numberWithBool:NO] atIndex:indexNum];
    }else{
        [selectedList removeObjectAtIndex:indexNum];
        [selectedList insertObject:[NSNumber numberWithBool:YES] atIndex:indexNum];
    }
    
    [myTable reloadData];
}

//跳到个人信息页
-(void)goPersonInfo:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    int indexNum = tap.view.superview.tag;
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[[list objectAtIndex:indexNum] objectForKey:KEY_NAME]];
    [self.navigationController pushViewController:personInfoView animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [list count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * Identifier = @"ClubProfileEditCell";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
	}
    [Utility removeSubViews:cell.contentView];

    UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
    avatar.userInteractionEnabled = YES;
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 5;
    [avatar setImageWithURL:USER_HEAD_IMG_URL(@"small", [[list objectAtIndex:indexPath.row] objectForKey:@"photo"]) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goPersonInfo:) ]];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 120, 15)];
    [Utility styleLbl:nameLabel withTxtColor:nil withBgColor:nil withFontSize:14];
    [nameLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    nameLabel.text = [[list objectAtIndex:indexPath.row] objectForKey:KEY_NAME];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 25, 180, 20)];
    [Utility styleLbl:descLabel withTxtColor:nil withBgColor:nil withFontSize:14];
    WeLog(@"LIST object%@",[list objectAtIndex:indexPath.row]);
//    descLabel.text = [[list objectAtIndex:indexPath.row] objectForKey:KEY_DESC];
    [Utility emotionAttachString:[[list objectAtIndex:indexPath.row] objectForKey:KEY_DESC] toView:descLabel font:14 isCut:YES];
    
    UIImageView *checkIcon = [[UIImageView alloc]initWithFrame:CGRectMake(295, 20, 20, 20)];
    checkIcon.image = [UIImage imageNamed:@"setting_chatSetting_unselect"];
//    [cell.contentView addSubview:checkIcon];
    
    UIImageView *sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(180, 3, 20, 20)];
    if ([[[list objectAtIndex:indexPath.row] objectForKey:@"sex"] intValue]) {
        sexImg.image = [UIImage imageNamed:@"user_female"];
    }else{
        sexImg.image = [UIImage imageNamed:@"user_male.png"];
    }

    [cell.contentView addSubview:avatar];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:descLabel];
    [cell.contentView addSubview:sexImg];
    
    UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    inviteBtn.frame = CGRectMake(251, 15, 63, 25);
    inviteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    inviteBtn.tag = indexPath.row;
    [inviteBtn setTitle:@"邀请" forState:UIControlStateNormal];
    [inviteBtn.titleLabel setFont:[UIFont systemFontOfSize:RIGHT_BAR_ITEM_FONT_SIZE]];
//    inviteBtn.titleLabel.text = @"邀请";
    [inviteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [inviteBtn addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:inviteBtn];
    WeLog(@"CELL%@",[selectedList objectAtIndex:indexPath.row]);
    if ([[selectedList objectAtIndex:indexPath.row] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"邀请我关注的用户";
    
    //leftBarButtonItem
    leftbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (isPushFromNewClub) {
        leftbtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
        [leftbtn setTitle:@"跳过" forState:UIControlStateNormal];
        [leftbtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        [leftbtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    }else{
        leftbtn.frame = CGRectMake(0, 0, 30, 30);
        [leftbtn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    }

    [leftbtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:leftbtn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.tag = -1;
    selectBtn.frame = CGRectMake(5, 0, 20, 20);

    [selectBtn setBackgroundImage:[UIImage imageNamed:@"setting_chatSetting_unselect.png"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectAll) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem;
    
    UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteBtn.tag = -1;
    inviteBtn.frame = CGRectMake(0, 0, 63, 30);
    [inviteBtn setTitle:@"全部邀请" forState:UIControlStateNormal];
    [inviteBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    [inviteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [inviteBtn addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem1 = [[UIBarButtonItem alloc]initWithCustomView:inviteBtn];
//    self.navigationItem.rightBarButtonItem = menuBtnItem1;
//    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:menuBtnItem,menuBtnItem1, nil];
    self.navigationItem.rightBarButtonItem = menuBtnItem1;
}

-(void)back{
    [rp cancel];
    [self stop];
    if (isPushFromNewClub) {
        ClubViewController *clubView = [[ClubViewController alloc]init];
        clubView.club = club;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
        clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
        clubView.isPushFromNewClub = YES;
        [self.navigationController pushViewController:clubView animated:YES];
//        TabBarController *_tabC = [[TabBarController alloc] init];
//        
//        ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:_tabC animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];

    }
}

@end
