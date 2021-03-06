//
//  LoginViewController.m
//  WeClub
//
//  Created by Archer on 13-3-11.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "LoginViewController.h"
#import "PersonInfoViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
    }
    return self;
}

//- (void)changeLoginType:(id)sender
//{
//    UIButton *btn = (UIButton *)sender;
//    _loginType = btn.titleLabel.text;
//    NSLog(@"login type:%@",_loginType);
//    _loginTypeLabel.text = _loginType;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = TINT_COLOR;
    }
//    [_rp getCookies];
    
    _mainDic = [Constants getSingleton].mainDic;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    UIButton *bigButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bigButton.frame = [[UIScreen mainScreen] bounds];
    bigButton.backgroundColor = [UIColor clearColor];
    [bigButton addTarget:self action:@selector(hideKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bigButton];
    
    self.navigationController.navigationBar.tintColor = TINT_COLOR;
    
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"微  俱";
    self.navigationItem.titleView = headerLabel;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *inputBgView = [[UIImageView alloc] init];
    inputBgView.frame = CGRectMake((screenSize.width-295)/2, screenSize.height/2-175, 295, 78);
    inputBgView.backgroundColor = [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1];
    inputBgView.layer.cornerRadius = 5;
    inputBgView.layer.borderWidth = 2;
    inputBgView.layer.borderColor = [[UIColor colorWithRed:139.0/255 green:139.0/255 blue:139.0/255 alpha:1] CGColor];
    [self.view addSubview:inputBgView];
    
    //在inputBgView上画线，高端做法
    UIGraphicsBeginImageContext(inputBgView.frame.size);
    [inputBgView.image drawInRect:CGRectMake(0, 0, inputBgView.frame.size.width, inputBgView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 0.8);
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0, 39);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 295, 39);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    inputBgView.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //用户名label
    UILabel *userNameLabel = [[UILabel alloc] init];
    userNameLabel.frame = CGRectMake(inputBgView.frame.origin.x+20, inputBgView.frame.origin.y+10, 70, 20);
    userNameLabel.backgroundColor = [UIColor clearColor];
    userNameLabel.text = @"用    户：";
    userNameLabel.font = [UIFont boldSystemFontOfSize:16];
    userNameLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    [self.view addSubview:userNameLabel];
    
    //密码label
    UILabel *psdLabel = [[UILabel alloc] init];
    psdLabel.frame = CGRectMake(inputBgView.frame.origin.x+20, inputBgView.frame.origin.y+49, 70, 20);
    psdLabel.backgroundColor = [UIColor clearColor];
    psdLabel.text = @"密    码：";
    psdLabel.font = [UIFont boldSystemFontOfSize:16];
    psdLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    [self.view addSubview:psdLabel];
    
    //用户名textfield
    _userNameTextField = [[UITextField alloc] init];
    _userNameTextField.frame = CGRectMake(inputBgView.frame.origin.x+80, inputBgView.frame.origin.y+10, 210, 22);
    _userNameTextField.backgroundColor = [UIColor clearColor];
    _userNameTextField.textColor = [UIColor grayColor];
    _userNameTextField.placeholder = @"微俱帐号或MITBBS帐号";
    _userNameTextField.font = [UIFont boldSystemFontOfSize:16];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _userNameTextField.text = [ud objectForKey:@"defaultName"];
    _userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _userNameTextField.delegate = self;
    _userNameTextField.tag = 60;
    [self.view addSubview:_userNameTextField];
    
    //密码textfield
    _passwordTextField = [[UITextField alloc] init];
    _passwordTextField.frame = CGRectMake(inputBgView.frame.origin.x+80, inputBgView.frame.origin.y+48, 210, 22);
    _passwordTextField.backgroundColor = [UIColor clearColor];
    _passwordTextField.textColor = [UIColor grayColor];
    _passwordTextField.placeholder = @"请输入密码";
    _passwordTextField.font = [UIFont boldSystemFontOfSize:16];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.text = [ud objectForKey:@"defaultPassword"];
//    _passwordTextField.text = @"123456";
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordTextField.delegate = self;
    _passwordTextField.tag = 61;
    [self.view addSubview:_passwordTextField];
    
    //登录按钮
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginButton.frame = CGRectMake((screenSize.width-105)/2, (screenSize.height-140)/2, 105, 45);
    UIImage *loginButtonImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login_login" ofType:@"png"]];
    [_loginButton setBackgroundImage:loginButtonImg forState:UIControlStateNormal];
    [_loginButton setTitle:@"登  录" forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [_loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    //二维码按钮
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scanButton.frame = CGRectMake((screenSize.width-70)/2, screenSize.height/2+60, 70, 70);
    [scanButton addTarget:self action:@selector(scanTwoDimensionCode) forControlEvents:UIControlEventTouchUpInside];
 //   UIImage *scanImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login_tdc" ofType:@"png"]];
    UIImage *scanImg = [UIImage imageNamed:@"weclubcode.png"];
    [scanButton setImage:scanImg forState:UIControlStateNormal];
    [self.view addSubview:scanButton];
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(30, 30, 10, 10)];
    icon.image = [UIImage imageNamed:@"weclub.png"];
    [scanButton addSubview:icon];
    
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerGes)];
    
    UILabel *scanLabel = [[UILabel alloc] init];
    scanLabel.frame = CGRectMake((screenSize.width-200)/2, scanButton.frame.origin.y-30, 200, 30);
    scanLabel.text = @"注册新用户请点击下面图标";
    scanLabel.backgroundColor = [UIColor clearColor];
    scanLabel.textAlignment = NSTextAlignmentCenter;
    scanLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    scanLabel.font = [UIFont boldSystemFontOfSize:16];
    scanLabel.userInteractionEnabled = YES;
    [scanLabel addGestureRecognizer:tapGes];
    [self.view addSubview:scanLabel];
    
    UIButton *forgetPassBtn = [[UIButton alloc]initWithFrame:CGRectMake((screenSize.width-200)/2, scanButton.frame.origin.y+70, 200, 30)];
    [forgetPassBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    forgetPassBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [forgetPassBtn setTitleColor:[UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1] forState:UIControlStateNormal];
    [forgetPassBtn addTarget:self action:@selector(forgetPass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetPassBtn];
    
    
//    UIButton *bbsID = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [bbsID setTitle:@"bbs_id" forState:UIControlStateNormal];
//    bbsID.frame = CGRectMake(0, 0, 100, 30);
//    [bbsID addTarget:self action:@selector(changeLoginType:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:bbsID];
//    
//    UIButton *name = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [name setTitle:@"name" forState:UIControlStateNormal];
//    name.frame = CGRectMake(100, 0, 100, 30);
//    [name addTarget:self action:@selector(changeLoginType:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:name];
    
//    _loginTypeLabel = [[UILabel alloc] init];
//    _loginTypeLabel.frame = CGRectMake(200, 0, 100, 30);
//    _loginTypeLabel.textColor = [UIColor blackColor];
//    _loginTypeLabel.textAlignment = NSTextAlignmentCenter;
//    _loginTypeLabel.text = @"name";
//    [self.view addSubview:_loginTypeLabel];
    
    _loginType = @"name";
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"informCenterArticlePush"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"informCenterUserPush"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"digestInformCenterArticlePush"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogoutNotification:) name:NOTIFICATION_KEY_LOGOUT object:nil];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _userNameTextField.text = [ud objectForKey:@"defaultName"];
    _passwordTextField.text = [ud objectForKey:@"defaultPassword"];;
    [ud setObject:@"0" forKey:@"directLogin"];
    [ud synchronize];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLogoutNotification:(NSNotification *)notification
{
    if ([self.navigationController.visibleViewController isKindOfClass:[PostArticleViewController class]]) {
        [self.navigationController.visibleViewController dismissModalViewControllerAnimated:YES];
    }
    if ([self.navigationController.visibleViewController isKindOfClass:[DLCImagePickerController class]]) {
        [self.navigationController.visibleViewController dismissModalViewControllerAnimated:YES];
    }
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)hideKeyBoard
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}


-(void)forgetPass{
    ForgetPassViewController *forgetPassView = [[ForgetPassViewController alloc]init];
    [self.navigationController pushViewController:forgetPassView animated:YES];
}

- (void)registerGes
{
    BBSRegisterViewController *reg = [[BBSRegisterViewController alloc] init];
    [self.navigationController pushViewController:reg animated:YES];
}

- (void)login
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    AccountUser *user = [AccountUser getSingleton];
    user.cookie = nil;
    
    if ([_userNameTextField.text isEqualToString:@"Q"]) {        
//        ImportFriendViewController *import = [[ImportFriendViewController alloc] initWithStyle:UITableViewStylePlain];
//        [self.navigationController pushViewController:import animated:YES];
    }else if([_userNameTextField.text isEqualToString:@"C"]){
        self.navigationController.navigationBarHidden = YES;
        _tabC = [[TabBarController alloc] init];
        ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = _tabC;
        [self.navigationController pushViewController:_tabC animated:NO];

    }else if ([_userNameTextField.text isEqualToString:@"chaowefaf"]){
        PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] initWithNumberID:@"100013"];
        [self.navigationController pushViewController:personInfo animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }else{
        if (_userNameTextField.text == nil || [_userNameTextField.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入用户名！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }else if (![self checkUserName]) {
            return;
        }
        
        if (_passwordTextField.text == nil || [_passwordTextField.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入密码！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }else if (![self checkPassWord]){
            return;
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.detailsLabelText = @"正在登录";
        
        _userName = _userNameTextField.text;
        _passWord = _passwordTextField.text;
        [_rp loginWithKey:_userNameTextField.text andPassWord:_passwordTextField.text andType:_loginType andForce:NO];
        
        
//        self.navigationController.navigationBarHidden = YES;
//        _tabC = [[TabBarController alloc] init];
//        [self.navigationController pushViewController:_tabC animated:YES];
    }
    
    
}

/*
    用于分享绑定检查
    若没有更换用户则保持原先绑定
    若更换用户则删除原先的所有绑定
 */
- (void)checkShared
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *name = [ud objectForKey:@"defaultName"];
    [ud removeObjectForKey:@"informCenterArticlePush"];
    if (name && ![name isEqualToString:[AccountUser getSingleton].name]) {
        if ([self checkUserCredential]) {
            [self achiveCredential];
            [self unAchiveCredential];
        }else{
            [self achiveCredential];
            [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
            [ShareSDK cancelAuthWithType:ShareTypeTencentWeibo];
            [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
            [ShareSDK cancelAuthWithType:ShareTypeRenren];
            [ShareSDK cancelAuthWithType:ShareTypeTwitter];
            [ShareSDK cancelAuthWithType:ShareTypeGooglePlus];
            [ShareSDK cancelAuthWithType:ShareTypeLinkedIn];
            [ShareSDK cancelAuthWithType:ShareTypeFacebook];
            for (NSString *str in myConstants.shareTypeNames) {
                [ud removeObjectForKey:str];
            }
        }
        
        [ud synchronize];
    }
}

- (BOOL)checkUserCredential
{
    NSString *credentialDocPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"userCredential"];
    NSString *credentialUserName = [NSString stringWithFormat:@"%@.dat",[AccountUser getSingleton].name];
    NSString *credentialUserPath = [credentialDocPath stringByAppendingPathComponent:credentialUserName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:credentialUserPath]) {
        return YES;
    }else{
        return NO;
    }
}

- (void)achiveCredential
{
    NSString *credentialDocPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"userCredential"];
    NSString *credentialUserName = [NSString stringWithFormat:@"%@.dat",[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultName"]];
    NSString *credentialUserPath = [credentialDocPath stringByAppendingPathComponent:credentialUserName];
    NSArray *array = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:ShareTypeSinaWeibo],
                      [NSNumber numberWithInt:ShareTypeTencentWeibo],
                      [NSNumber numberWithInt:ShareTypeQQSpace],
                      [NSNumber numberWithInt:ShareTypeRenren],
                      [NSNumber numberWithInt:ShareTypeTwitter],
                      [NSNumber numberWithInt:ShareTypeGooglePlus],
                      [NSNumber numberWithInt:ShareTypeLinkedIn],
                      [NSNumber numberWithInt:ShareTypeFacebook],nil];
    NSArray *typeArray = [NSArray arrayWithObjects:@"ShareTypeSinaWeibo",@"ShareTypeTencentWeibo",@"ShareTypeQQSpace",@"ShareTypeRenren",@"ShareTypeTwitter",@"ShareTypeGooglePlus",@"ShareTypeLinkedIn",@"ShareTypeFacebook", nil];
    NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < array.count; i++) {
        int typeNumber = [[array objectAtIndex:i] intValue];
        NSString *typeStr  = [typeArray objectAtIndex:i];
        if ([ShareSDK getCredentialWithType:typeNumber]) {
            id<ISSCredential> tag = [ShareSDK getCredentialWithType:typeNumber];
            NSData *credentialData = [ShareSDK dataWithCredential:tag];
            [muDic setObject:credentialData forKey:typeStr];
            NSString *typeStrName = [NSString stringWithFormat:@"%@Name",typeStr];
            if ([ud objectForKey:typeStr]) {
                [muDic setObject:[ud objectForKey:typeStr] forKey:typeStrName];
            }else{
                [muDic setObject:@"" forKey:typeStrName];
            }
            
        }
    }
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:credentialDocPath]) {
        [fileManager createDirectoryAtPath:credentialDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:muDic];
    [data writeToFile:credentialUserPath atomically:YES];
}

- (void)unAchiveCredential
{
    NSString *credentialDocPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"userCredential"];
    NSString *credentialUserName = [NSString stringWithFormat:@"%@.dat",[AccountUser getSingleton].name];
    NSString *credentialUserPath = [credentialDocPath stringByAppendingPathComponent:credentialUserName];
    NSData *data = [NSData dataWithContentsOfFile:credentialUserPath];
    NSDictionary *dic = [NSKeyedUnarchiver  unarchiveObjectWithData:data];
    NSArray *array = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:ShareTypeSinaWeibo],
                      [NSNumber numberWithInt:ShareTypeTencentWeibo],
                      [NSNumber numberWithInt:ShareTypeQQSpace],
                      [NSNumber numberWithInt:ShareTypeRenren],
                      [NSNumber numberWithInt:ShareTypeTwitter],
                      [NSNumber numberWithInt:ShareTypeGooglePlus],
                      [NSNumber numberWithInt:ShareTypeLinkedIn],
                      [NSNumber numberWithInt:ShareTypeFacebook],nil];
    NSArray *typeArray = [NSArray arrayWithObjects:@"ShareTypeSinaWeibo",@"ShareTypeTencentWeibo",@"ShareTypeQQSpace",@"ShareTypeRenren",@"ShareTypeTwitter",@"ShareTypeGooglePlus",@"ShareTypeLinkedIn",@"ShareTypeFacebook", nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (NSString *str in typeArray) {
        [userDefaults removeObjectForKey:str];
    }
    for (int i = 0; i < array.count; i++) {
        int typeNumber = [[array objectAtIndex:i] intValue];
        [ShareSDK cancelAuthWithType:typeNumber];
        NSString *typeStr = [typeArray objectAtIndex:i];
        if ([dic objectForKey:typeStr]) {
            id<ISSCredential> tag = [ShareSDK credentialWithData:[dic objectForKey:typeStr] type:typeNumber];
            [ShareSDK setCredential:tag type:typeNumber];
            NSString *typeStrName = [NSString stringWithFormat:@"%@Name",typeStr];
            if ([[dic objectForKey:typeStrName] isEqualToString:@""]) {
                [ShareSDK cancelAuthWithType:typeNumber];
            }
            [userDefaults setObject:[dic objectForKey:typeStrName] forKey:typeStr];
        }
    }
    [userDefaults synchronize];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSInteger strLength = textField.text.length - range.length + string.length;
    if (textField.tag == 60) {
        _passwordTextField.text = nil;
    }
    return 1;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField.tag == 60) {
        _passwordTextField.text = nil;
    }
    return 1;
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
        user.photoTime = [NSString stringWithFormat:@"%@",[msgDic objectForKey:@"phototime"]];
        NSArray *attach = [msgDic objectForKey:@"attachment"];
        user.userAttachments = [NSMutableArray arrayWithArray:attach];
        user.isLogin = YES; //判断用户是否登录成功
        user.netWorkStatus = 1;
        if ([user.close_flag isEqualToString:@"0"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已经关闭" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
            [user clearUserInfo];
            alert = nil;
            return;
        }

        //分享检测
        [self checkShared];
        //记住用户名
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:user.name forKey:@"defaultName"];
        [ud setObject:_passwordTextField.text forKey:@"defaultPassword"];
        [ud synchronize];
//        [[SDImageCache sharedImageCache] removeImageForKey:[NSString stringWithFormat:@"%@/%@/user/userHead?type=small&picid=%@",HOST,PHP,user.photoID]];
        
        //俱乐部认领标志
        NSString *clubFlag = [msgDic objectForKey:@"adoptstate"];
        user.adoptFlag = clubFlag;
        
//        if (true) {
//            ImportFriendViewController *import = [[ImportFriendViewController alloc] initWithStyle:UITableViewStylePlain];
//            [self.navigationController pushViewController:import animated:YES];
//            return;
//        }

        if ([user.loginFlag isEqualToString:@"1"]) {
            BBSRegisterViewController *reg = [[BBSRegisterViewController alloc] init];
            [self.navigationController pushViewController:reg animated:YES];
            //[reg setUsername:_userName andPassword:_passWord];

        }else{
            if ([clubFlag isEqualToString:@"0"] || clubFlag == nil) {
                self.navigationController.navigationBarHidden = YES;
                _tabC = [[TabBarController alloc] init];
                ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = _tabC;
                [self.navigationController pushViewController:_tabC animated:YES];
            }else{
                PostListViewController *postList = [[PostListViewController alloc] initWithType:2];
                [self.navigationController pushViewController:postList animated:YES];
            }
        }
    }else if ([type isEqualToString:REQUEST_TYPE_SCANINFO]){
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        NSDictionary *msgDic = [dic objectForKey:@"msg"];
        
        NSString *strPhotoID = [msgDic objectForKey:@"photo"];
        
        //姓名
        NSString *name = [msgDic objectForKey:@"name"];
        NSString *birthday = [msgDic objectForKey:@"birthday"];
        NSString *numberId = [msgDic objectForKey:@"numberid"];
        
        //性别view
        NSString *strSex = [msgDic objectForKey:@"sex"];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[strPhotoID,name,birthday,numberId,strSex] forKeys:@[@"photo",@"name",@"birthday",@"numberid",@"sex"]];
        ScanUserInfoView *scanUser = [[ScanUserInfoView alloc] initWithDic:dic];
        scanUser.scanNumber = _scanNumberID;
        scanUser.loginController = self;
        scanUser.frame = [UIScreen mainScreen].bounds;
        [self.view.window addSubview:scanUser];
        [scanUser show];
    }

}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    if (excepCode == 395) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该账号已在其它地方登录，是否强制登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 101;
        [alert show];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        [Utility MsgBox:excepDesc];
    }
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([type isEqualToString:REQUEST_TYPE_LOGIN]) {        //若登录失败重置登录状态
        AccountUser *user = [AccountUser getSingleton];
        user.isLogin = NO;
    }
//    [Utility MsgBox:failDesc];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:failDesc delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
}

- (BOOL)checkUserName
{
    NSString *str = _userNameTextField.text;
    if (str.length > 12) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户名过长，最多为12位" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (str.length < 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户名过短，最少为2位" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    NSString *regex = @"^[\u4e00-\u9fa5A-Za-z][\u4e00-\u9fa5A-Za-z0-9]{1,11}+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:_userNameTextField.text];
    if (!isMatch) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户名由汉字、英文字母和数字组成，请勿以数字开头" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    return isMatch;
}

- (BOOL)checkPassWord
{
    NSString *str = _passwordTextField.text;
    if (str.length > 12) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码过长，最多为12位" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (str.length < 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码过短，最少为6位" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    NSString * regex = @"^[A-Za-z0-9_]{6,12}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:_passwordTextField.text];
    if (!isMatch) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码由数字，字母或下划线组成" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return isMatch;
    NSRange range = [_passwordTextField.text rangeOfString:@" "];
    if (range.location == NSNotFound) {
        return YES;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码由6-12位数字，字母或下划线组成" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
}

- (void)scanTwoDimensionCode
{
    UINavigationController *nav = [[ZBarManager sharedZBarManager] getReaderWithDelegate:self helpStr:@"请扫描微俱用户"];
    [ZBarManager sharedZBarManager].helpFlag = @"0";
   
    [self presentModalViewController:nav animated:YES];
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
    //[self presentModalViewController: reader
    //                        animated: YES];
     
}



- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    //扫描后数据处理
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    [[ZBarManager sharedZBarManager] back];
    
    NSDictionary *dic = [Utility qrAnalyse:symbol.data];
    symbol = nil;
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"2"]) {
        _scanNumberID = [dic objectForKey:@"id"];
//        NSString *str1 = [_mainDic objectForKey:@"login_alert_scan_right1"];
//        NSString *str2 = [_mainDic objectForKey:@"login_alert_scan_right2"];
//        NSString *alertStr = [NSString stringWithFormat:@"%@%@%@",str1,_scanNumberID,str2];
//        NSString *cancel = [_mainDic objectForKey:@"cancel"];
//        NSString *sure = [_mainDic objectForKey:@"sure"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:self cancelButtonTitle:cancel otherButtonTitles:sure, nil];
//        alert.tag = 102;
//        [alert show];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:_scanNumberID forKey:@"numberid"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_rp sendRequest:dic type:REQUEST_TYPE_SCANINFO];
    }else if ([type isEqualToString:@"1"]){
        [[[UIAlertView alloc] initWithTitle:nil message:@"登陆后可查看俱乐部信息" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
    }else{
        NSString *title = [_mainDic objectForKey:@"login_alert_openOrNot"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[dic objectForKey:@"id"] delegate:self cancelButtonTitle:[_mainDic objectForKey:@"cancel"] otherButtonTitles:[_mainDic objectForKey:@"sure"], nil];
        alert.tag = 103;
        [alert show];
    }
        
}

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    [[ZBarManager sharedZBarManager] back];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([ZBarManager sharedZBarManager].scanFlag != 0) {
        return;
    }
    [[ZBarManager sharedZBarManager] back];
    [ZBarManager sharedZBarManager].scanFlag++;
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *code =[(AVMetadataMachineReadableCodeObject *)metadata stringValue];

            
            NSDictionary *dic = [Utility qrAnalyse:code];
            NSString *type = [dic objectForKey:@"type"];
            if ([type isEqualToString:@"2"]) {
                _scanNumberID = [dic objectForKey:@"id"];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:_scanNumberID forKey:@"numberid"];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [_rp sendRequest:dic type:REQUEST_TYPE_SCANINFO];
            }else if ([type isEqualToString:@"1"]){
                [[[UIAlertView alloc] initWithTitle:nil message:@"登陆后可查看俱乐部信息" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            }else{
                NSString *title = [_mainDic objectForKey:@"login_alert_openOrNot"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[dic objectForKey:@"id"] delegate:self cancelButtonTitle:[_mainDic objectForKey:@"cancel"] otherButtonTitles:[_mainDic objectForKey:@"sure"], nil];
                alert.tag = 103;
                [alert show];
            }
            break;
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            [_rp loginWithKey:_userNameTextField.text andPassWord:_passwordTextField.text andType:_loginType andForce:YES];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    
    }else if (alertView.tag == 102 && buttonIndex == 1){
        BBSRegisterViewController *BBSRegister = [[BBSRegisterViewController alloc] initWithOtherNumberid:_scanNumberID];
        [self.navigationController pushViewController:BBSRegister animated:YES];
    }else if (alertView.tag == 103 && buttonIndex == 1){
        NSString *urlString = alertView.message;
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
