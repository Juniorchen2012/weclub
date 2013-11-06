//
//  ChangeEmailViewController.m
//  WeClub
//
//  Created by Archer on 13-5-24.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChangeEmailViewController.h"

@interface ChangeEmailViewController ()

@end

#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size
@implementation ChangeEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_rp cancel];
    _rp = nil;
    _password = nil;
    _email = nil;
    _changeEmailTable = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //订制导航条
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 140, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"修改邮箱";
    self.navigationItem.titleView = headerLabel;
    headerLabel = nil;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
//    UIButton *operateBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
//    [operateBtn setTitle:@"操作" forState:UIControlStateNormal];
//    [operateBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
//    [operateBtn addTarget:self action:@selector(operate) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:operateBtn];
//    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
//    [operateBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    [btn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(updateEmail) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    btn = nil;
    rightBtn = nil;
//    btn.tintColor = [UIColor orangeColor];
//    self.navigationItem.rightBarButtonItem = btn;
//    btn = nil;
    
    _mainDic = [Constants getSingleton].mainDic;
    
    _rp = [[RequestProxy alloc] init];
    _rp.delegate = self;
    
    _changeEmailTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 15, SCREEN_SIZE.width-10, SCREEN_SIZE.height) style:UITableViewStyleGrouped];
    _changeEmailTable.dataSource = self;
    _changeEmailTable.delegate = self;
    _changeEmailTable.backgroundView = nil;
    _changeEmailTable.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, SCREEN_SIZE.width, 60)];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(17, 120, SCREEN_SIZE.width, 60)];
    }
    if ([AccountUser getSingleton].email == nil||[[AccountUser getSingleton].email isEqualToString:@""]) {
        label.text = @"原邮箱:  无";
    }else{
        label.text = [NSString stringWithFormat:@"原邮箱:  %@", [AccountUser getSingleton].email];
    }
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    [_changeEmailTable addSubview:label];
    label = nil;
    [self.view addSubview:_changeEmailTable];
    
//    UILabel *passwordLabel = [[UILabel alloc] init];
//    passwordLabel.frame = CGRectMake(5, 5, 150, 20);
//    passwordLabel.text = [_mainDic objectForKey:@"changeEmail_password"];
//    [self.view addSubview:passwordLabel];
    
    _password = [[UITextField alloc] init];
    if (iosVersion >= 7) {
        _password.frame = CGRectMake(80, 10, 225, 30);
    }else{
        _password.frame = CGRectMake(75, 10, 205, 30);
    }
    _password.secureTextEntry = YES;
    _password.placeholder = @"请输入密码";
    _password.backgroundColor = [UIColor clearColor];
    _password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(2, 30, 203, 30)];
//    bgView.image = TXTFIELDBG;
//    [self.view addSubview:bgView];

    _password.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [self.view addSubview:_password];
//    _password = nil;
//    UILabel *emailLabel = [[UILabel alloc] init];
//    emailLabel.frame = CGRectMake(5, 65, 150, 20);
//    emailLabel.text = [_mainDic objectForKey:@"changeEmail_email"];
//    [self.view addSubview:emailLabel];
    
    _email = [[UITextField alloc] init];
    if (iosVersion >= 7) {
        _email.frame = CGRectMake(80, 10, 225, 30);
    }else{
        _email.frame = CGRectMake(75, 10, 205, 30);
    }
    _email.backgroundColor = [UIColor clearColor];
    _email.placeholder = @"例如:  abcdef@xxx.com";
    _email.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _email.clearButtonMode = UITextFieldViewModeWhileEditing;
//    UIImageView *bg1View = [[UIImageView alloc]initWithFrame:CGRectMake(2, 90, 203, 30)];
//    bg1View.image = TXTFIELDBG;
//    [self.view addSubview:bg1View];
//    [self.view addSubview:_email];
    
	// Do any additional setup after loading the view.
    [_password becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateEmail
{
    if ([_password.text isEqualToString:@""]) {
        [self alertStr:[_mainDic objectForKey:@"changePassword_empty"]];
        return;
    }
    if (_password.text == nil) {
        [self alertStr:[_mainDic objectForKey:@"changePassword_empty"]];
        return;
    }
    if ([_email.text isEqualToString:@""]) {
        [self alertStr:@"邮箱为空，请重新输入"];
        return;
    }
    if (_email.text == nil) {
        [self alertStr:@"邮箱为空，请重新输入"];
        return;
    }
    if ([_email.text isEqualToString:[AccountUser getSingleton].email]) {
        [self alertStr:@"新旧邮箱相同，请重新输入"];
        return;
    }
    if (![self validateEmail:_email.text]) {
        [self alertStr:[_mainDic objectForKey:@"changeEmail_invalidateEmail"]];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[_mainDic objectForKey:@"changeEmail_updateNotice"] delegate:self cancelButtonTitle:[_mainDic objectForKey:@"cancel"] otherButtonTitles:[_mainDic objectForKey:@"sure"], nil];
    alert.tag = 101;
    [alert show];
    alert = nil;
}

- (void)alertStr:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:[_mainDic objectForKey:@"sure"] otherButtonTitles:nil, nil];
    [alert show];
    alert = nil;
}

- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:REQUEST_TYPE_CHANGEPASSEMAIL]) {
        [Utility showHUD:@"邮箱修改成功"];
        myAccountUser.email = _email.text;
        [self performSelector:@selector(popViewController) withObject:nil afterDelay:1];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            [_password resignFirstResponder];
            [_email resignFirstResponder];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [_rp changePassOrEmail:@"email" withID:_email.text andOldPass:_password.text];
        }
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"changeEmailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"密   码：";
        [cell.contentView addSubview:_password];
    }else if (indexPath.row == 1) {
        cell.textLabel.text = [_mainDic objectForKey:@"changeEmail_email"];
        [cell.contentView addSubview:_email];
    }
    return cell;
}

@end
