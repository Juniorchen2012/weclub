//
//  ApplyProcessViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ApplyProcessViewController.h"

@interface ApplyProcessViewController ()

@end

@implementation ApplyProcessViewController
@synthesize isLoadMore;

- (id)initWithClub:(Club *)myClub
{
    self = [super init];
    if (self) {
        club = myClub;
        clubID = club.ID;
    }
    return self;
}

- (id)initWithClubID:(NSString *)myclubID
{
    self = [super init];
    if (self) {
        clubID = myclubID;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [rp cancel];
    [self stop];
}
-(void)viewDidAppear:(BOOL)animated{
    if (firstAppear) {
        [myTable triggerPullToRefresh];
        firstAppear = NO;
    }
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
    
    array = [[NSMutableArray alloc]init];
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20) style:UITableViewStylePlain];
    myTable.backgroundView = nil;
    myTable.delegate = self;
    myTable.dataSource = self;
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:myTable];
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
//    [self loadData];
    isLoadMore = NO;
    firstAppear = YES;
	// Do any additional setup after loading the view.
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_APPLY_MEMBER_LIST]) {
        
        startKey = [[dic objectForKey:KEY_DATA] objectForKey:KEY_STARTKEY];
        NSArray *dicList = [[dic objectForKey:KEY_DATA] objectForKey:KEY_MEMBER_LIST];

        if (!isLoadMore) {
            [array removeAllObjects];
        }
        [array addObjectsFromArray:dicList];
        [myTable reloadData];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        isLoadMore = NO;
    }else if ([type isEqualToString:URL_CLUB_APPLY_PROCESS]){
        [array removeObjectAtIndex:operateNO];
        if (!operateType) {
            [Utility showHUD:@"接受申请成功"];
        }else{
            [Utility showHUD:@"拒绝申请成功"];
        }
        [myTable reloadData];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
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
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:startKeystring forKey:KEY_STARTKEY];
    [dic setValue:clubID forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    [rp sendDictionary:dic andURL:URL_CLUB_APPLY_MEMBER_LIST andData:nil];
}

-(void)operate:(id)sender{
    UIButton *btn = (UIButton *)sender;
    operateNO = btn.tag;
    NSString *type;
    if ([btn.titleLabel.text isEqualToString:@"接受"]){
        operateType = 0;
        type = @"0";
    }else if ([btn.titleLabel.text isEqualToString:@"拒绝"]){
        operateType = 1;
        type = @"1";
    }
    NSString *userRowKey = [[array objectAtIndex:btn.tag] objectForKey:KEY_USER_ROW_KEY];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:clubID forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:type forKey:KEY_TYPE];
    [dic setValue:userRowKey forKey:KEY_USER_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_CLUB_APPLY_PROCESS andData:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[[array objectAtIndex:indexPath.row] objectForKey:KEY_NAME]];
    [self.navigationController pushViewController:personInfoView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [array count];
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
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 5;
    [avatar setImageWithURL:USER_HEAD_IMG_URL(@"small", [[array objectAtIndex:indexPath.row] objectForKey:@"photo"]) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 80, 15)];
    [nameLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    nameLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:KEY_NAME];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 25, 170, 20)];
    [Utility styleLbl:descLabel withTxtColor:nil withBgColor:nil withFontSize:14];
//    descLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:KEY_DESC];
    [Utility emotionAttachString:[[array objectAtIndex:indexPath.row] objectForKey:KEY_DESC] toView:descLabel font:14 isCut:YES];
    
    UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    acceptBtn.tag = indexPath.row;
    acceptBtn.frame = CGRectMake(230, 15, 40, 25);
    [acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
    [acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [acceptBtn addTarget:self action:@selector(operate:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:acceptBtn];
    
    UIButton *refuseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    refuseBtn.tag = indexPath.row;
    refuseBtn.frame = CGRectMake(275, 15, 40, 25);
    [refuseBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    [refuseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refuseBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [refuseBtn addTarget:self action:@selector(operate:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:refuseBtn];
    
    UIImageView *sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(155, 2, 20, 20)];
    if ([[[array objectAtIndex:indexPath.row] objectForKey:KEY_SEX] isEqualToString:@"0"]) {
        sexImg.image = [UIImage imageNamed:@"user_male.png"];
    }else if ([[[array objectAtIndex:indexPath.row] objectForKey:KEY_SEX] isEqualToString:@"1"]){
        sexImg.image = [UIImage imageNamed:@"user_female.png"];
    }
    [cell.contentView addSubview:sexImg];
    [cell.contentView addSubview:avatar];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:descLabel];
    return cell;
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"会员申请管理";
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
