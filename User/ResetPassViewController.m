//
//  ResetPassViewController.m
//  WeClub
//
//  Created by chao_mit on 13-6-5.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ResetPassViewController.h"

@interface ResetPassViewController ()

@end

@implementation ResetPassViewController
@synthesize email;

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
    [self initNavigation];
    UIControl *ctr = [[UIControl alloc] initWithFrame:self.view.bounds];
    [ctr addTarget:self action:@selector(resignTextField) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ctr];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    
    UILabel *checkCodeLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 100, 30)];
    checkCodeLbl.text = @"验证码";
    [self.view addSubview:checkCodeLbl];
    
    checkCodeTxt = [[UITextField alloc]initWithFrame:CGRectMake(120, 50, 150, 30)];
    checkCodeTxt.placeholder = @"请输入验证码";
    checkCodeTxt.clearButtonMode = UITextFieldViewModeWhileEditing;
    checkCodeTxt.borderStyle = 3;
    [self.view addSubview:checkCodeTxt];
    
    UILabel *newPassLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, 100, 30)];
    newPassLbl.text = @"新密码";
    [self.view addSubview:newPassLbl];
    
    newPassTxt = [[UITextField alloc]initWithFrame:CGRectMake(120, 100, 150, 30)];
    newPassTxt.placeholder = @"请输入新密码";
    newPassTxt.clearButtonMode = UITextFieldViewModeWhileEditing;
    newPassTxt.secureTextEntry = YES;
    newPassTxt.borderStyle = 3;
    [self.view addSubview:newPassTxt];
    
    UILabel *confirmPassLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 150, 100, 30)];
    confirmPassLbl.text = @"确认密码";
    [self.view addSubview:confirmPassLbl];
    
    confirmPassTxt = [[UITextField alloc]initWithFrame:CGRectMake(120, 150, 150, 30)];
    confirmPassTxt.placeholder = @"请重新输入新密码";
    confirmPassTxt.clearButtonMode = UITextFieldViewModeWhileEditing;
    confirmPassTxt.secureTextEntry = YES;
    confirmPassTxt.borderStyle = 3;
    [self.view addSubview:confirmPassTxt];
    
    UIButton *submit = [[UIButton alloc]initWithFrame:CGRectMake(130, 200, 60, 30)];
    [submit setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    [self.view addSubview:submit];
	// Do any additional setup after loading the view.
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([type isEqualToString:URL_USER_RESET_PASS]) {
        [Utility showHUD:@"密码重置成功"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(BOOL)check{
    if (checkCodeTxt.text == nil) {
        [Utility MsgBox:@"请输入验证码"];
        return NO;
    }
    if ([checkCodeTxt.text isEqualToString:@""]) {
        [Utility MsgBox:@"请输入验证码"];
        return NO;
    }
    if (newPassTxt.text == nil) {
        [Utility MsgBox:@"密码为空，请输入密码"];
        return NO;
    }
    if (confirmPassTxt.text == nil) {
        [Utility MsgBox:@"请再输入一遍密码"];
        return NO;
    }
    if ([newPassTxt.text isEqualToString:@""]) {
        [Utility MsgBox:@"密码为空，请输入密码"];
        return NO;
    }
    if ([confirmPassTxt.text isEqualToString:@""]) {
        [Utility MsgBox:@"请再输入一遍密码"];
        return NO;
    }
    //非空格式正确
    if (![newPassTxt.text isEqualToString:confirmPassTxt.text]) {
        [Utility MsgBox:@"密码不一致"];
        return NO;
    }else if(![self checkPassWord:newPassTxt.text]){
        return NO;
    }
    return YES;
}

- (BOOL)checkPassWord:(NSString *)password
{
    NSString * regex = @"^[A-Za-z0-9_]{6,12}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:password];
    if (!isMatch) {
        [Utility MsgBox:@"密码由6-12位数字，字母或下划线组成"];
    }
    return isMatch;
}

-(void)submit{
    if (![self check]) {
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:email forKey:@"email"];
    [dic setValue:checkCodeTxt.text forKey:@"code"];
    [dic setValue:newPassTxt.text forKey:@"pass"];
    [rp sendDictionary:dic andURL:URL_USER_RESET_PASS andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backgroundTap{
    [checkCodeTxt resignFirstResponder];
    [newPassTxt resignFirstResponder];
    [confirmPassTxt resignFirstResponder];
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"重置密码";
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLbl;
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    //[Utility addTapGestureRecognizer:self.view withTarget:self action:@selector(backgroundTap)];
}

- (void)resignTextField
{
    [checkCodeTxt resignFirstResponder];
    [newPassTxt resignFirstResponder];
    [confirmPassTxt resignFirstResponder];
}

@end
