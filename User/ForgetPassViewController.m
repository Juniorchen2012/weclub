//
//  ForgetPassViewController.m
//  WeClub
//
//  Created by chao_mit on 13-5-28.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ForgetPassViewController.h"

@interface ForgetPassViewController ()

@end

@implementation ForgetPassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    UILabel *hintLbl = [[UILabel alloc]initWithFrame:CGRectMake(100, 200, 100, 20)];
    [Utility styleLbl:hintLbl withTxtColor:nil withBgColor:nil withFontSize:16];
    hintLbl.text = @"请输入您注册微俱帐户的电子邮件，我们会给您发送关于重置密码的说明。";
    hintLbl.textAlignment = UITextAlignmentCenter;
    hintLbl.numberOfLines = 2;
    hintLbl.frame = CGRectMake(10, 50, 300, 40);
    [self.view addSubview:hintLbl];
    
    
    emailTxt = [[UITextField alloc]initWithFrame:CGRectMake(15, hintLbl.frame.origin.y+60, 290, 30)];
    emailTxt.borderStyle = 3;
    emailTxt.placeholder = @"电子邮箱";
    emailTxt.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:emailTxt];
    
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submit.frame = CGRectMake(130, 170, 60, 30);
    [submit setTitle:@"发送" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submit setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submit];
    
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
}


- (void)submit{
    if (emailTxt.text == nil) {
        [Utility MsgBox:@"请输入邮箱"];
        return;
    }
    if ([emailTxt.text isEqualToString:@""]) {
        [Utility MsgBox:@"请输入邮箱"];
        return;
    }
    if (![self check]) {
        [Utility MsgBox:@"您输入的邮箱格式不正确."];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:emailTxt.text forKey:@"email"];
    [rp sendDictionary:dic andURL:URL_USER_FORGET_PASS andData:nil];
    [emailTxt resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(BOOL)check{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailTxt.text];
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_USER_FORGET_PASS]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Utility showHUD:[NSString stringWithFormat:@"邮件已发往%@邮箱,注意查收邮件.",emailTxt.text]];
        ResetPassViewController *resetPassView = [[ResetPassViewController alloc]init];
        resetPassView.email = emailTxt.text;
        [self.navigationController pushViewController:resetPassView animated:YES];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    if ([type isEqualToString:REQUEST_URL_IFOLLOW]) {
        [Utility showHUD:@"该邮件不是有效的微俱用户注册邮箱!"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    //[self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backgroundTap{
    [emailTxt resignFirstResponder];
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"忘记密码";
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
    [emailTxt resignFirstResponder];
}

@end
