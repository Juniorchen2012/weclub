//
//  DirectLoginViewController.m
//  WeClub
//
//  Created by mitbbs on 13-10-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "DirectLoginViewController.h"

@interface DirectLoginViewController ()

@end

@implementation DirectLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
	// Do any additional setup after loading the view.
//    [self initNavigation];
    self.navigationController.navigationBarHidden = YES;
    _rp = [[RequestProxy alloc] init];
    _rp.delegate = self;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    UIImageView *bgImage = [[UIImageView alloc] init];
    bgImage.frame = self.view.bounds;
    if (iPhone5) {
        bgImage.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    }else{
        bgImage.image = [UIImage imageNamed:@"Default@2x.png"];
    }
    [self.view addSubview:bgImage];
    [_rp loginWithKey:[ud objectForKey:@"directLoginName"] andPassWord:[ud objectForKey:@"directLoginPassword"] andType:@"name" andForce:NO];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogoutNotification:) name:NOTIFICATION_KEY_LOGOUT object:nil];
}

- (void)handleLogoutNotification:(NSNotification *)notification
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

-(void)initNavigation{
    //leftBarButtonItem
    UIButton *searchClubBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchClubBtn.frame = CGRectMake(0, 0, 30, 30);
    [searchClubBtn setBackgroundImage:[UIImage imageNamed:ICON_SEARCH] forState:UIControlStateNormal];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithCustomView:searchClubBtn];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    //rightBarButtonItem
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0,30, 30);
    [menuBtn setImage:[UIImage imageNamed:@"gride.png"] forState:UIControlStateNormal];
    UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = rightbtn;
    
    //titleView
    
    UIView * title = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 140, 24)];
    UIButton *titleView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 24)];
    titleView.backgroundColor = [UIColor clearColor];
    
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 24)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"附近的俱乐部";
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 24);
    UIImageView *titleViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"x.png"]];
    titleViewArrow.backgroundColor =[UIColor clearColor];
    titleViewArrow.frame = CGRectMake(labelsize.width, 2, 20, 20);
    [titleView addSubview:titleLbl];
    [titleView addSubview:titleViewArrow];
    [title addSubview:titleView];
    self.navigationItem.titleView = title;
    
    UIView *titleViews = [[UIView alloc]initWithFrame:CGRectMake(90, 60, 140, 280)];
    titleViews.backgroundColor = TINT_COLOR;
    self.navigationController.navigationBar.tintColor = TINT_COLOR;
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([type isEqualToString:REQUEST_TYPE_LOGIN]) {
        NSDictionary *msgDic = [dic objectForKey:REQUEST_MSGKEY_MSG];
        AccountUser *user = [AccountUser getSingleton];
        user.loginFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"flag"]];
        user.activity = [msgDic objectForKey:@"activity"];
        user.approve_flag = [msgDic objectForKey:@"approve_flag"];
        user.article_count = [msgDic objectForKey:@"article_count"];
        user.article_today_count = [msgDic objectForKey:@"article_today_count"];
        user.birthday = [msgDic objectForKey:@"birthday"];
        user.close_flag = [NSString stringWithFormat:@"%@",[msgDic objectForKey:@"close_flag"]];
        user.email = [msgDic objectForKey:@"email"];
        user.experience = [msgDic objectForKey:@"experience"];
        user.follow_club_count = [msgDic objectForKey:@"follow_club_count"];
        user.follow_me_count = [msgDic objectForKey:@"follow_me_count"];
        user.i_follow_count = [msgDic objectForKey:@"i_follow_count"];
        user.inclub_count = [msgDic objectForKey:@"in_club_count"];
        user.money = [msgDic objectForKey:@"money"];
        user.name = [msgDic objectForKey:@"name"];
        user.numberID = [msgDic objectForKey:@"numberid"];
        user.reg_time = [msgDic objectForKey:@"reg_time"];
        user.sex = [msgDic objectForKey:@"sex"];
        user.photoID = [msgDic objectForKey:@"photo"];
        user.desc = [msgDic objectForKey:@"desc"];
        user.private_letter = [msgDic objectForKey:@"private_letter"];
        user.public_setting = [msgDic objectForKey:@"public_setting"];
        NSArray *attach = [msgDic objectForKey:@"attachment"];
        user.userAttachments = [NSMutableArray arrayWithArray:attach];
        user.isLogin = YES; //判断用户是否登录成功
        user.netWorkStatus = 1;
        user.photoTime = [NSString stringWithFormat:@"%@",[msgDic objectForKey:@"phototime"]];
        if ([user.close_flag isEqualToString:@"0"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已经关闭" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alert.tag = 201;
            [alert show];
            [user clearUserInfo];
            alert = nil;
            return;
        }
        [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/%@/user/userHead?type=small&picid=%@",HOST,PHP,user.photoID]];
        NSString *clubFlag = [msgDic objectForKey:@"adoptstate"];
        user.adoptFlag = clubFlag;
        if ([clubFlag isEqualToString:@"0"] || clubFlag == nil) {
            self.navigationController.navigationBarHidden = YES;
            TabBarController *tabC = [[TabBarController alloc] init];
            ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = tabC;
            [self.navigationController pushViewController:tabC animated:YES];
        }else{
            self.navigationController.navigationBarHidden = NO;
            self.navigationItem.hidesBackButton = YES;
            PostListViewController *postList = [[PostListViewController alloc] initWithType:2];
            [self.navigationController pushViewController:postList animated:NO];
        }
        
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (excepCode == 395) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该账号已在其它地方登录，是否强制登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 202;
        [alert show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    if ([type isEqualToString:REQUEST_TYPE_LOGIN]) {        //若登录失败重置登录状态
        AccountUser *user = [AccountUser getSingleton];
        user.isLogin = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 202) {
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_LOGOUT object:nil];
        }else if (buttonIndex == 1) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [_rp loginWithKey:[ud objectForKey:@"directLoginName"] andPassWord:[ud objectForKey:@"directLoginPassword"] andType:@"name" andForce:YES];
        }
    }else if (alertView.tag == 201){
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
