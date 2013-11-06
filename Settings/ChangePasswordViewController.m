//
//  ChangePasswordViewController.m
//  WeClub
//
//  Created by Archer on 13-5-24.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size

@implementation ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _changePasswordTable.scrollEnabled = NO;

}

- (void)dealloc
{
    [_rp cancel];
    _rp = nil;
    _oldPassword = nil;
    _newPassword = nil;
    _newPasswordAgain = nil;
    _changePasswordTable = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    //订制导航条
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 140, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"修改密码";
    self.navigationItem.titleView = headerLabel;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(updatePassword)];
//    btn.tintColor = [UIColor orangeColor];
//    self.navigationItem.rightBarButtonItem = btn;
//    btn = nil;
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    //    [operateBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    [btn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(updatePassword) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    btn = nil;
    rightBtn = nil;
    
    _rp = [[RequestProxy alloc] init];
    _rp.delegate = self;
    
    _mainDic = [Constants getSingleton].mainDic;
    
    
    _changePasswordTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 15, SCREEN_SIZE.width-10, SCREEN_SIZE.height) style:UITableViewStyleGrouped];
    _changePasswordTable.dataSource = self;
    _changePasswordTable.delegate = self;
    _changePasswordTable.backgroundColor = [UIColor clearColor];
    _changePasswordTable.backgroundView = nil;
    [self.view addSubview:_changePasswordTable];
    
//    UILabel *oldPasswordLabel = [[UILabel alloc] init];
//    oldPasswordLabel.frame = CGRectMake(30, 5, 150, 20);
//    oldPasswordLabel.text = [_mainDic objectForKey:@"changePassword_oldPassword"];
 //   [self.view addSubview:oldPasswordLabel];
    
    _oldPassword = [[UITextField alloc] init];
    if (iosVersion >= 7) {
        _oldPassword.frame = CGRectMake(115, 10, 190, 30);
    }else{
        _oldPassword.frame = CGRectMake(110, 10, 170, 30);
    }
    _oldPassword.borderStyle = UITextBorderStyleRoundedRect;
    _oldPassword.secureTextEntry = YES;
    _oldPassword.borderStyle = UITextBorderStyleNone;
    _oldPassword.placeholder = @"请输入原来密码";
    _oldPassword.backgroundColor = [UIColor clearColor];
    _oldPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _oldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
//    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(2, 30, 203, 30)];
//    bgView.image = TXTFIELDBG;
 //   [self.view addSubview:bgView];
 //   [self.view addSubview:_oldPassword];
    
//    UILabel *newPasswordLabel = [[UILabel alloc] init];
//    newPasswordLabel.frame = CGRectMake(5, 65, 150, 20);
//    newPasswordLabel.text = [_mainDic objectForKey:@"changePassword_newPassword"];
 //   [self.view addSubview:newPasswordLabel];
    
    _newPassword = [[UITextField alloc] init];
    if (iosVersion >= 7) {
        _newPassword.frame = CGRectMake(115, 10, 190, 30);
    }else{
        _newPassword.frame = CGRectMake(110, 10, 170, 30);
    }
    _newPassword.secureTextEntry = YES;
    _newPassword.placeholder = @"请输入新密码";
    _newPassword.backgroundColor = [UIColor clearColor];
    _newPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _newPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
//    UIImageView *bg1View = [[UIImageView alloc]initWithFrame:CGRectMake(2, 90, 203, 30)];
//    bg1View.image = TXTFIELDBG;
 //   [self.view addSubview:bg1View];
 //   [self.view addSubview:_newPassword];
    
//    UILabel *newPasswordAgainLabel = [[UILabel alloc] init];
//    newPasswordAgainLabel.frame = CGRectMake(5, 125, 150, 20);
//    newPasswordAgainLabel.text = [_mainDic objectForKey:@"changePassword_newPasswordAgain"];
 //   [self.view addSubview:newPasswordAgainLabel];
    
    _newPasswordAgain = [[UITextField alloc] init];
    if (iosVersion >= 7) {
        _newPasswordAgain.frame = CGRectMake(115, 10, 190, 30);
    }else{
        _newPasswordAgain.frame = CGRectMake(110, 10, 170, 30);
    }
    _newPasswordAgain.secureTextEntry = YES;
    _newPasswordAgain.placeholder = @"请再次输入新密码";
    _newPasswordAgain.backgroundColor = [UIColor clearColor];
    _newPasswordAgain.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _newPasswordAgain.clearButtonMode = UITextFieldViewModeWhileEditing;
//    UIImageView *bg2View = [[UIImageView alloc]initWithFrame:CGRectMake(2, 150, 203, 30)];
//    bg2View.image = TXTFIELDBG;
 //   [self.view addSubview:bg2View];
 //   [self.view addSubview:_newPasswordAgain];
    
	// Do any additional setup after loading the view.
    [_oldPassword becomeFirstResponder];
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

- (void)updatePassword
{
    if ([_oldPassword.text isEqualToString:@""]) {
        [self alertStr:@"请输入旧密码"];
        [_oldPassword becomeFirstResponder];
        return;
    }
    if (_oldPassword.text == nil) {
        //[self alertStr:[_mainDic objectForKey:@"changePassword_empty"]];
        [self alertStr:@"请输入旧密码"];
        [_oldPassword becomeFirstResponder];
        return;
    }
    if ([_newPassword.text isEqualToString:@""]) {
        [self alertStr:@"请输入新密码"];
        [_newPassword becomeFirstResponder];
        return;
    }
    if (_newPassword.text == nil) {
        [self alertStr:@"请输入新密码"];
        [_newPassword becomeFirstResponder];
        return;
    }

    if (![self checkPassWord:_newPassword.text]) {
        [_newPassword becomeFirstResponder];
        return;
    }
    if ([_newPasswordAgain.text isEqualToString:@""]) {
        [self alertStr:@"请再次输入新密码"];
        [_newPasswordAgain becomeFirstResponder];
        return;
    }
    if (_newPasswordAgain.text == nil) {
        [self alertStr:@"请再次输入新密码"];
        [_newPasswordAgain becomeFirstResponder];
        return;
    }
    if ([_newPassword.text isEqualToString:_oldPassword.text]) {
        [self alertStr:@"新旧密码一样 请重新输入新密码"];
        [_newPassword becomeFirstResponder];
        return;
    }
    if (![_newPassword.text isEqualToString:_newPasswordAgain.text]) {
        [self alertStr:[_mainDic objectForKey:@"changePassword_different"]];
        [_newPasswordAgain becomeFirstResponder];
        return;
    }
    //come on
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_rp changePassOrEmail:@"pass" withID:_newPassword.text andOldPass:_oldPassword.text];
}

- (BOOL)checkPassWord:(NSString *)password
{
    NSString * regex = @"^[A-Za-z0-9_]{6,12}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:password];
    if (!isMatch) {
        [self alertStr:@"密码格式不正确，请重新输入新密码，密码由6-12位数字，字母或下划线组成"];
    }
    return isMatch;
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:REQUEST_TYPE_CHANGEPASSEMAIL]) {
        [Utility showHUD:@"密码修改成功"];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//        [ud setObject:_newPassword.text forKey:@"defaultPassword"];
        [ud setObject:_newPassword.text forKey:@"directLoginPassword"];
        [ud synchronize];
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

- (void)alertStr:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:[_mainDic objectForKey:@"sure"] otherButtonTitles:nil, nil];
    [alert show];
    alert = nil;
}

#pragma mark
#pragma mark UITableViewDelegate and UITableViewDataSouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"changePasswordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.layer needsDisplay];
    if (indexPath.row == 0) {
        cell.textLabel.text = [_mainDic objectForKey:@"changePassword_oldPassword"];
        [cell.contentView addSubview:_oldPassword];

    }else if (indexPath.row == 1) {
        cell.textLabel.text = [_mainDic objectForKey:@"changePassword_newPassword"];
        [cell.contentView addSubview:_newPassword];
    }else if (indexPath.row == 2) {
        cell.textLabel.text = [_mainDic objectForKey:@"changePassword_newPasswordAgain"];
        [cell.contentView addSubview:_newPasswordAgain];
    }
    return cell;
}

@end
