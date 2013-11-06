//
//  BBSRegisterViewController.m
//  WeClub
//
//  Created by Archer on 13-3-12.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "BBSRegisterViewController.h"

@interface BBSRegisterViewController ()

@end

@implementation BBSRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        
        _viewControllerType = 0;
        _keyBoardShow = NO;
    }
    return self;
}

- (id)initWithOtherNumberid:(NSString *)other_numberid
{
    self = [super init];
    if (self) {
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        
        _viewControllerType = 0;
        
        _other_numberid = other_numberid;
        _keyBoardShow = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //[_tableView reloadData];
}

- (void)dealloc
{
    _headerLabel = nil;
    _mainScrollView = nil;;
    _photoView = nil;
    _headPhoto = nil;
    _emailTextField = nil;
    _usernameTextField = nil;
    _passwordTextField = nil;
    _passwordAgainTextField = nil;
    _sexSegment = nil;
    bgView = nil;
    categoryView = nil;
    categoryPicker = nil;
    _generationPicker = nil;
    _generationStr = nil;
    [_rp cancel];
    _rp = nil;
    _other_numberid = nil;
    _mainDic = nil;
    _tableView = nil;
    _footView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    _mainDic = [Constants getSingleton].mainDic;
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    _headerLabel = [[UILabel alloc ] init];
    _headerLabel.frame = CGRectMake(0, 0, 200, 30);
    _headerLabel.backgroundColor = [UIColor clearColor];
    _headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    _headerLabel.textAlignment = NSTextAlignmentCenter;
    _headerLabel.font = [UIFont boldSystemFontOfSize:20];
    _headerLabel.text = @"注    册";
    self.navigationItem.titleView = _headerLabel;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    //添加头像
    _photoView = [[UIImageView alloc] init];
    _photoView.frame = CGRectMake(20, 12, 60, 60);
//    _photoView.backgroundColor = [UIColor grayColor];
    _photoView.layer.borderWidth = 1;
    _photoView.layer.borderColor = [[UIColor grayColor] CGColor];
    _photoView.tag = 101;
    
    //用户名TextField
    _usernameTextField = [[UITextField alloc] init];
    _usernameTextField.frame = CGRectMake(110, 14, 190, 20);
    _usernameTextField.textAlignment = NSTextAlignmentLeft;
    _usernameTextField.textColor = [UIColor grayColor];
    _usernameTextField.placeholder = @"2-12位汉字、字母或数字";
    _usernameTextField.tag = 101;
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //性别segment
    _sexSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"男",@"女", nil]];
    _sexSegment.frame = CGRectMake(110, 14, 180, 20);
    _sexSegment.selectedSegmentIndex = 2;
    _sexSegment.tag = 101;
    
    //年代按钮，显示用户选择的年代
    _generationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _generationButton.frame = CGRectMake(110, 14, 180, 20);
    [_generationButton setTitle:@"请选择年代" forState:UIControlStateNormal];
    [_generationButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _generationButton.titleLabel.font = [UIFont systemFontOfSize:18];
    _generationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_generationButton addTarget:self action:@selector(selectCategory) forControlEvents:UIControlEventTouchUpInside];
    _generationButton.tag = 101;
    
    //加入大量空格使pickerview中的文字显示居中
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
        _generationArray = [NSArray arrayWithObjects:@"                      00后",@"                      90后",@"                      80后",@"                      70后",@"                      60后",@"                      50后",@"                      40后",@"                      40前",nil];
    }else{
        _generationArray = [NSArray arrayWithObjects:@"00后",@"90后",@"80后",@"70后",@"60后",@"50后",@"40后",@"40前",nil];
    }
    //年代picker
    _generationPicker = [[UIPickerView alloc] init];
    _generationPicker.frame = CGRectMake(0, screenSize.height-216-64, 320, 216);
    _generationPicker.dataSource = self;
    _generationPicker.delegate = self;
    _generationPicker.showsSelectionIndicator = YES;
    [_generationPicker setHidden:YES];
    [self.view addSubview:_generationPicker];
    
    myConstants = [Constants getSingleton];
    categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, myConstants.screenHeight-20-216-60, 320, 256)];
    categoryView.backgroundColor = TINT_COLOR;
    categoryPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, 320, 216)];
    categoryPicker.tag = 1;
    categoryPicker.dataSource = self;
    categoryPicker.delegate = self;
    categoryPicker.showsSelectionIndicator = YES;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.tag = 0;
    cancelBtn.frame = CGRectMake(10, categoryPicker.frame.origin.y-35, 60, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"button_big_grey.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(finishPickCategory:) forControlEvents:UIControlEventTouchUpInside];
    [categoryView addSubview:cancelBtn];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    finishBtn.tag = 1;
    finishBtn.frame = CGRectMake(250, categoryPicker.frame.origin.y-35, 60, 30);
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setBackgroundImage:[UIImage imageNamed:@"button_big_grey.png"] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishPickCategory:) forControlEvents:UIControlEventTouchUpInside];
    [categoryView addSubview:finishBtn];
    [categoryView addSubview:categoryPicker];

    
    //邮箱TextField
    _emailTextField = [[UITextField alloc] init];
    _emailTextField.frame = CGRectMake(110, 14, 180, 20);
    _emailTextField.font = [UIFont boldSystemFontOfSize:18];
    _emailTextField.textAlignment = NSTextAlignmentLeft;
    _emailTextField.textColor = [UIColor grayColor];
    _emailTextField.placeholder = @"请输入邮箱";
    _emailTextField.tag = 101;
    _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //密码TextField
    _passwordTextField = [[UITextField alloc] init];
    _passwordTextField.frame = CGRectMake(110, 14, 180, 20);
    _passwordTextField.textAlignment = NSTextAlignmentLeft;
    _passwordTextField.textColor = [UIColor grayColor];
    _passwordTextField.placeholder = @"6-12位";
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.tag = 101;
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //确认密码TextField
    _passwordAgainTextField = [[UITextField alloc] init];
    _passwordAgainTextField.frame = CGRectMake(110, 14, 180, 20);
    _passwordAgainTextField.textAlignment = NSTextAlignmentLeft;
    _passwordAgainTextField.textColor = [UIColor grayColor];
    _passwordAgainTextField.placeholder = @"请再次输入密码";
    _passwordAgainTextField.secureTextEntry = YES;
    _passwordAgainTextField.tag = 101;
    _passwordAgainTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //footView
    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    
    //bigButton
    UIButton *bigButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bigButton.frame = _footView.frame;
    [bigButton addTarget:self action:@selector(handleBigButton) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:bigButton];
    
    //语音按钮
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.frame = CGRectMake(30, 30, 40, 40);
    UIImage *voiceImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_voice_someone2" ofType:@"png"]];
    [voiceButton setImage:voiceImg forState:UIControlStateNormal];
    voiceButton.userInteractionEnabled = NO;
    [_footView addSubview:voiceButton];
//    [voiceButton addTarget:self action:@selector(readingAgreement) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[AccountUser getSingleton].loginFlag isEqualToString:@"1"]) {
        UILabel *warmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 320, 20)];
        warmLabel.text = @"登陆后可修改邮箱、密码";
        warmLabel.textAlignment = UITextAlignmentCenter;
        warmLabel.textColor = [UIColor grayColor];
        warmLabel.font = [UIFont systemFontOfSize:16];
        [_footView addSubview:warmLabel];
    }
    
    //我已阅读并同意
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(70, 30, 130, 40);
    label1.text = @"我已阅读并同意";
    label1.font = [UIFont boldSystemFontOfSize:18];
    [_footView addSubview:label1];
    
    //注册协议
    UIButton *agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    agreementButton.frame = CGRectMake(195, 30, 80, 40);
    [agreementButton setTitle:@"注册协议" forState:UIControlStateNormal];
    [agreementButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    agreementButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [agreementButton addTarget:self action:@selector(showAgreement) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:agreementButton];
    
    //提交按钮
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake((screenSize.width-105)/2, 80, 105, 45);
    UIImage *loginButtonImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login_login" ofType:@"png"]];
    [submitButton setBackgroundImage:loginButtonImg forState:UIControlStateNormal];
    [submitButton setTitle:@"提  交" forState:UIControlStateNormal];
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [submitButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [submitButton addTarget:self action:@selector(submitInfo) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:submitButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-64) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundView.alpha = 0;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:_generationPicker];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide) name:UIKeyboardWillHideNotification object:nil];
    if ([[AccountUser getSingleton].loginFlag isEqualToString:@"1"]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [self setUsername:[ud objectForKey:@"defaultName"] andPassword:@""];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)keyBoardShow
{
//    if (!_keyBoardShow) {
//        CGPoint point = _tableView.contentOffset;
//        _a = 215-point.y;
//        point.y += _a;
//        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height - point.y);
//        _keyBoardShow = YES;
//        if ([_usernameTextField isFirstResponder]) {
//            return;
//        }
//        [self hidePickerView];
//        [UIView animateWithDuration:0.3 animations:^{
//            _tableView.contentOffset = point;
//
//        }];
//        
//        //_tableView.frame = rect;
//
//    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGPoint point = _tableView.contentOffset;

    if ([_usernameTextField isFirstResponder]) {
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, screenSize.height-44 - 200);
        return;
    }
    point.y = 200;
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.contentOffset = point;
    } completion:^(BOOL finished) {
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, screenSize.height-44 - 200);
    }];
    
}

- (void)keyBoardHide
{
//    if (_keyBoardShow) {
//        CGSize screenSize = [UIScreen mainScreen].bounds.size;
//        _tableView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-64);
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.3];
////        CGRect rect = _tableView.frame;
////        rect.size.height += 215;
////        _tableView.frame = rect;
//        CGPoint point = _tableView.contentOffset;
//        point.y -= _a;
//        _tableView.contentOffset = point;
//        [UIView commitAnimations];
//        
//        _keyBoardShow = NO;
//    }
    CGPoint point = _tableView.contentOffset;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _tableView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-64);
    _tableView.contentOffset = point;

    [UIView animateWithDuration:0.3 animations:^{
        _tableView.contentOffset = CGPointZero;
    }];
}


//修改分类
-(void)selectCategory{
    [_emailTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_passwordAgainTextField resignFirstResponder];
    bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20-216)];
    //    [Utility addTapGestureRecognizer:bgView withTarget:self action:@selector(finishPickCategory)];
    
    categoryView.hidden = NO;
    [categoryView.layer addAnimation:[Utility createAnimationWithType:kCATransitionMoveIn withsubtype:kCATransitionFromTop withDuration:0] forKey:@"animation"];
    //    [categoryPicker selectRow:[category intValue] inComponent:0 animated:NO];
    [self.view addSubview:bgView];
    [self.view addSubview:categoryView];
}

-(void)finishPickCategory:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag) {
        //完成按钮
//        NSMutableString *categoryToSend = [[NSMutableString alloc] init];
//        for (int i = 0; i < (4-[[NSString stringWithFormat:@"%d",selectedRow] length]); i++) {
//            [categoryToSend appendString:@"0"];
//        }
//        [categoryToSend appendString:[NSString stringWithFormat:@"%d",selectedRow]];
//        category = categoryToSend;
//        //组织成0002，4位数的格式
//        [myTable reloadData];
        NSString *gene = [[_generationArray objectAtIndex:selectedRow] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [_generationButton setTitle:gene forState:UIControlStateNormal];
        _generationStr = gene;
    }else{
        //取消按钮
    }
    
    [categoryView removeFromSuperview];
    [bgView removeFromSuperview];
    categoryView.hidden = YES;
}



- (void)readingAgreement
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"语音播报注册协议，还没做" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showAgreement
{
    AboutViewController *about = [[AboutViewController alloc] initWithContentType:@"1"];
    [self.navigationController pushViewController:about animated:YES];
}

- (void)submitInfo
{
    if ([AccountUser getSingleton].photoID == nil && _headPhoto == nil) {
        [self alertStr:@"请选择头像！"];
        return;
    }
    
    
    
    
    if (_usernameTextField.text == nil||[_usernameTextField.text isEqualToString:@""]) {
        [self alertStr:@"请输入用户名！"];
        return;
    }else if (![self checkUserName:_usernameTextField.text]) {
        return;
    }
    if (_sexSegment.selectedSegmentIndex == -1) {
        [self alertStr:@"请选择性别！"];
        return;
    }
    if (_generationStr == nil) {
        [self alertStr:@"请选择年代！"];
        return;
    }
//    if (![[AccountUser getSingleton].loginFlag isEqualToString:@"1"]) {
//        if ([_emailTextField.text isEqualToString:@""]) {
//            [self alertStr:@"请输入邮箱！"];
//            return;
//        }else if ([self validateEmail:_emailTextField.text]){
//            _mailType = 1;
//        }else if ([self isValidateMobile:_emailTextField.text]){
//            _mailType = 2;
//        }else{
//            if ([AccountUser getSingleton].email == nil || [[AccountUser getSingleton].email isEqualToString:@""]) {
//                [self alertStr:@"邮箱格式不合法！"];
//                return;
//            }
//            
//        }
//    }

    AccountUser *user = [AccountUser getSingleton];
    if ([user.loginFlag isEqualToString:@"1"]) {
    }else{
        if (_passwordTextField.text == nil || [_passwordTextField.text isEqualToString:@""]) {
            [self alertStr:@"请输入密码！"];
            return;
        }else if (![self checkPassWord:_passwordTextField.text]){
            return;
        }
        if (_passwordAgainTextField.text == nil || [_passwordAgainTextField.text isEqualToString:@""]) {
            [self alertStr:@"请再次输入密码！"];
            return;
        }else if (![_passwordTextField.text isEqualToString:_passwordAgainTextField.text]){
            [self alertStr:@"两次输入密码不一致"];
            return;
        }
    }
    
    
    
//    self.navigationController.navigationBarHidden = YES;
//    TabBarController *_tabC = [[TabBarController alloc] init];
//    
//    ClubListViewController *list = (ClubListViewController *)_tabC.nav1.visibleViewController;
//    [list newClub];
//    [self.navigationController pushViewController:_tabC animated:YES];
    
//    NSString *registerOrNot = [_mainDic objectForKey:@"register_registerOrNot"];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:registerOrNot delegate:self cancelButtonTitle:[_mainDic objectForKey:@"cancel"] otherButtonTitles:[_mainDic objectForKey:@"sure"], nil]

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否继续注册？注册后用户名、性别、出生年代不可修改" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 101;
    [alert show];
}

- (void)popViewController
{
    if ([[AccountUser getSingleton].loginFlag isEqualToString:@"1"]) {
//        [_rp logout];
//        _rp.delegate = nil;
        [[AccountUser getSingleton] clearUserInfo];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPickerView
{
    [_emailTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_passwordAgainTextField resignFirstResponder];
    
    if (_generationPicker.hidden) {
        _generationPicker.alpha = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [_generationPicker setHidden:NO];
        _generationPicker.alpha = 1;
        [UIView commitAnimations];
        
        CGRect rect = _tableView.frame;
        rect.size.height -= 216;
        _tableView.frame = rect;
    }
}

- (void)hidePickerView
{
//    [_emailTextField resignFirstResponder];
//    [_usernameTextField resignFirstResponder];
//    [_passwordTextField resignFirstResponder];
//    [_passwordAgainTextField resignFirstResponder];
    
    if (!_generationPicker.hidden) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDidStopSelector:@selector(hidePickerAnimationStop)];
        [UIView setAnimationDelegate:self];
        _generationPicker.alpha = 0;
        [UIView commitAnimations];
        
        CGRect rect = _tableView.frame;
        rect.size.height += 216;
        _tableView.frame = rect;
    }
}

- (void)hidePickerAnimationStop
{
    [_generationPicker setHidden:YES];
    _generationPicker.alpha = 1;
}

#pragma mark -
#pragma mark  拍照或获取图片
-(void) takePhoto{
    DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    picker = nil;
}

#pragma mark -imagePickerController
-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _headPhoto = [UIImage imageWithData:[info objectForKey:@"data"]];
    [self setHeadPhoto];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setHeadPhoto
{
    _photoView.image = _headPhoto;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark  UIPicker DataSource & Delegate
//返回每个组件上的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_generationArray count];
}

//返回组件数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//每一列中每一行的具体内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_generationArray objectAtIndex:row];
}

//选中哪一列哪一行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedRow = row;
//    NSString *gene = [[_generationArray objectAtIndex:row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    [_generationButton setTitle:gene forState:UIControlStateNormal];
//    _generationStr = gene;
}

- (void)alertStr:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if ([type isEqualToString:REQUEST_TYPE_REGISTER]) {
        NSDictionary *msgDic = [dic objectForKey:REQUEST_MSGKEY_MSG];
        AccountUser *user = [AccountUser getSingleton];
        user.loginFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"flag"]];
        user.activity = [msgDic objectForKey:@"activity"];
        user.approve_flag = [msgDic objectForKey:@"approve_flag"];
        user.article_count = [msgDic objectForKey:@"article_count"];
        user.article_today_count = [msgDic objectForKey:@"article_today_count"];
        user.birthday = [msgDic objectForKey:@"birthday"];
        user.close_flag = [msgDic objectForKey:@"close_flag"];
        user.email = [msgDic objectForKey:@"email"];
        user.experience = [msgDic objectForKey:@"experience"];
        user.follow_club_count = [msgDic objectForKey:@"follow_club_count"];
        user.follow_me_count = [msgDic objectForKey:@"follow_me_count"];
        user.i_follow_count = [msgDic objectForKey:@"i_follow_count"];
        user.inclub_count = [msgDic objectForKey:@"in_club_count"];
        user.money = [msgDic objectForKey:@"money"];
        user.name = [msgDic objectForKey:@"name"];
        user.numberID = [[NSString alloc] initWithFormat:@"%@", [msgDic objectForKey:@"numberid"]];
        user.reg_time = [msgDic objectForKey:@"reg_time"];
        user.sex = [msgDic objectForKey:@"sex"];
        user.photoID = [msgDic objectForKey:@"photo"];
        user.desc = [msgDic objectForKey:@"desc"];
        user.private_letter = [NSString stringWithFormat:@"%@",[msgDic objectForKey:@"private_letter"]];
        user.public_setting = [NSString stringWithFormat:@"%@",[msgDic objectForKey:@"public_setting"]];
        NSArray *attach = [msgDic objectForKey:@"attachment"];
        user.userAttachments = [NSMutableArray arrayWithArray:attach];
        user.photoTime = [NSString stringWithFormat:@"%@",[msgDic objectForKey:@"phototime"]];
        
        [self checkShare];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:user.name forKey:@"defaultName"];
        [ud setObject:_passwordTextField.text forKey:@"defaultPassword"];
        [ud synchronize];
        if (_other_numberid) {
//            [_rp followPerson:_other_numberid];
            int i = [user.i_follow_count integerValue];
            i++;
            user.i_follow_count = [NSString stringWithFormat:@"%d",i];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[_mainDic objectForKey:@"register_success"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [SVProgressHUD dismiss];
    }else if ([type isEqualToString:REQUEST_TYPE_CHANGEMAININFO]){
        [[NoticeManager sharedNoticeManager] resetBBSLoginAllNotices];
        if ([[AccountUser getSingleton].loginFlag isEqualToString:@"1"]) {
            AccountUser *user = [AccountUser getSingleton];
            NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithCapacity:4];
            if ([user.i_follow_count integerValue]) {
                [muDic setObject:@"1" forKey:@"bbsUserAttention"];
            }
            if ([user.inclub_count integerValue]) {
                [muDic setObject:@"1" forKey:@"bbsClubFollow"];
            }
            if ([user.follow_club_count integerValue]) {
                [muDic setObject:@"1" forKey:@"bbsClubAttention"];
            }
            if ([user.follow_me_count intValue]) {
                [muDic setObject:@"1" forKey:@"bbsUserFollow"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_UPDATENOTICE object:muDic];
        }
        AccountUser *user = [AccountUser getSingleton];
        user.sex = [NSString stringWithFormat:@"%d",_sexSegment.selectedSegmentIndex];
        user.photoID = [dic objectForKey:@"photo"];
        user.birthday = _generationStr;
//        ScanUserInfoView *userInfoView = [[ScanUserInfoView alloc] initWithBBSUser];
//        userInfoView.frame = [UIScreen mainScreen].bounds;
//        userInfoView.BBSController = self;
//        userInfoView.adoptFlag = user.adoptFlag;
//        [self.view.window addSubview:userInfoView];
//        [userInfoView BBSUserShow];
        if (user.adoptFlag == nil || [user.adoptFlag isEqualToString:@"0"]) {
            //            UIAlertView *alert = [Utility MsgBox:@"创建一个属于您的俱乐部" AndTitle:@"提示" AndDelegate:self AndCancelBtn:nil AndOtherBtn:@"是" withStyle:0];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"创建一个属于您的俱乐部" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 102;
            [alert show];
            [SVProgressHUD dismiss];
        }else{
            PostListViewController *postList = [[PostListViewController alloc] initWithType:2];
            [SVProgressHUD dismiss];
            [self.navigationController pushViewController:postList animated:YES];
        }
        
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD dismiss];
}
- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD dismiss];
}

- (void)setUsername:(NSString *)username andPassword:(NSString *)password
{
    _viewControllerType = 1;
    AccountUser *user = [AccountUser getSingleton];
    _usernameTextField.text = user.name;
    _usernameTextField.userInteractionEnabled = NO;
    _passwordTextField.text = password;
    _passwordTextField.userInteractionEnabled = NO;
    //_emailTextField.text = user.email;
    //_emailTextField.userInteractionEnabled = NO;
    
    _headerLabel.text = @"完善个人信息";
}

- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13，15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

- (BOOL)checkUserName:(NSString *)name
{
    NSString *str = _usernameTextField.text;
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
    NSString * regex = @"^[\u4e00-\u9fa5A-Za-z][\u4e00-\u9fa5A-Za-z0-9]{1,11}+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:name];
    if (!isMatch) {
        [self alertStr:@"用户名由2-12位汉字、英文字母和数字组成，请勿以数字开头"];
    }
    return isMatch;
}

- (BOOL)checkPassWord:(NSString *)password
{
    NSString *str = _passwordTextField.text;
    if (str.length == 0) {
        [self alertStr:@"请输入密码！"];
        return NO;
    }
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
    BOOL isMatch = [pred evaluateWithObject:password];
    if (!isMatch) {
        [self alertStr:@"密码由6-12位数字，字母或下划线组成"];
    }
    return isMatch;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            if (_viewControllerType == 0) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                if (_mailType == 1) {
                    [dic setObject:_emailTextField.text forKey:@"email"];
                    [dic setObject:@"email" forKey:@"type"];
                }else if (_mailType == 2){
                    [dic setObject:_emailTextField.text forKey:@"telephone"];
                    [dic setObject:@"telephone" forKey:@"type"];
                }
                [dic setObject:_usernameTextField.text forKey:@"name"];
                [dic setObject:[NSString stringWithFormat:@"%d",_sexSegment.selectedSegmentIndex] forKey:@"sex"];
                [dic setObject:_generationStr forKey:@"birthday"];
                [dic setObject:_passwordTextField.text forKey:@"pass"];
                if (_other_numberid) {
                    [dic setObject:_other_numberid forKey:@"friendid"];
                }
                [_rp registerWithPhoto:UIImageJPEGRepresentation(_headPhoto, 1) andDictionary:dic];
            }else if (_viewControllerType == 1){
                NSData *photoData = UIImageJPEGRepresentation(_headPhoto, 1);
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//                if (_mailType == 1) {
//                    [dic setObject:_emailTextField.text forKey:@"email"];
//                }else if (_mailType == 2){
//                    [dic setObject:_emailTextField.text forKey:@"telephone"];
//                }
//                if ([AccountUser getSingleton].email == nil || [[AccountUser getSingleton].email isEqualToString:@""]) {
//                    [dic setObject:_emailTextField.text forKey:@"email"];
//                }
                [dic setObject:[NSString stringWithFormat:@"%d",_sexSegment.selectedSegmentIndex] forKey:@"sex"];
                [dic setObject:_generationStr forKey:@"birthday"];
                [dic setObject:@"0" forKey:@"first_join"];
                [_rp changeMainInfo:[dic copy] andPhoto:photoData];
            }

        }
    }else{
        if (buttonIndex == 0) {
            self.navigationController.navigationBarHidden = YES;
            TabBarController *_tabC = [[TabBarController alloc] init];
            ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = _tabC;
            ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
                [self.navigationController pushViewController:_tabC animated:YES];
                [clubList registNewClub];
            }else{
                [clubList registNewClub];
                [self.navigationController pushViewController:_tabC animated:YES];
            }
            

        }
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AccountUser *user = [AccountUser getSingleton];
    if ([user.loginFlag isEqualToString:@"1"]) {
        return 4;
    }else{
        return 6;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 85;
    }else if (indexPath.row == 4){
        CGSize size;
        AccountUser *user = [AccountUser getSingleton];
        if ([user.email isEqualToString:@""] || user.email == nil) {
            size = CGSizeMake(0, 20);
            return size.height + 30;
        }else{
            size = [user.email sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 50;
        }
        
    }else{
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountUser *user = [AccountUser getSingleton];
    if ([user.loginFlag isEqualToString:@"1"]) {
        static NSString *cellIdentifier = @"BBSRegisterCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *label1 = [[UILabel alloc] init];
        label1.frame = CGRectMake(20, 15, 100, 20);
        label1.textAlignment = NSTextAlignmentLeft;
        label1.backgroundColor = [UIColor clearColor];
        label1.tag = 105;
        
        switch (indexPath.row) {
            case 0:
            {
                [cell.contentView addSubview:_photoView];
                NSString *photoID = [AccountUser getSingleton].photoID;
                AccountUser *user = [AccountUser getSingleton];
                if (user.photoID) {
                    [_photoView setImageWithURL:USER_HEAD_IMG_URL(@"small", photoID)];
                }else{
                    if ([user.sex isEqualToString:@"0"] || user.sex == nil) {
                        [_photoView setImage:[UIImage imageNamed:@"male_holder.png"]];
                    }else{
                        [_photoView setImage:[UIImage imageNamed:@"female_holder.png"]];
                    }
                }
                if (_headPhoto) {
                    [self setHeadPhoto];
                }
                UILabel *photoLabel = [[UILabel alloc] init];
                photoLabel.frame = CGRectMake(120, 30, 70, 25);
                photoLabel.backgroundColor = [UIColor clearColor];
                photoLabel.text = @"上传头像";
                photoLabel.tag = 102;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                [cell.contentView addSubview:photoLabel];
            }
                break;
            case 1:
            {
                label1.text = [_mainDic objectForKey:@"register_username"];
                [cell.contentView addSubview:label1];
                [cell.contentView addSubview:_usernameTextField];
                break;
            }
            case 2:
            {
                label1.text = [_mainDic objectForKey:@"register_sex"];
                [cell.contentView addSubview:label1];
                AccountUser *user = [AccountUser getSingleton];
                NSString *sex = user.sex;
                if ([sex isEqualToString:@"1"]) {
                    _sexSegment.selectedSegmentIndex = 1;
                }else{
                    _sexSegment.selectedSegmentIndex = 0;
                }
                [cell.contentView addSubview:_sexSegment];
                break;
            }
            case 3:
            {
                label1.text = [_mainDic objectForKey:@"register_generation"];
                NSString *str = [AccountUser getSingleton].birthday;
                if ([str isEqualToString:@"00后"]) {
                    [_generationPicker selectRow:0 inComponent:0 animated:YES];
                    _generationStr = @"00后";
                    [_generationButton setTitle:@"00后" forState:UIControlStateNormal];
                }else if ([str isEqualToString:@"90后"]){
                    [_generationPicker selectRow:1 inComponent:0 animated:YES];
                    _generationStr = @"90后";
                    [_generationButton setTitle:@"90后" forState:UIControlStateNormal];
                }else if ([str isEqualToString:@"80后"]){
                    [_generationPicker selectRow:2 inComponent:0 animated:YES];
                    _generationStr = @"80后";
                    [_generationButton setTitle:@"80后" forState:UIControlStateNormal];
                }else if ([str isEqualToString:@"70后"]){
                    [_generationPicker selectRow:3 inComponent:0 animated:YES];
                    _generationStr = @"70后";
                    [_generationButton setTitle:@"70后" forState:UIControlStateNormal];
                }else if ([str isEqualToString:@"60后"]){
                    [_generationPicker selectRow:4 inComponent:0 animated:YES];
                    _generationStr = @"60后";
                    [_generationButton setTitle:@"60后" forState:UIControlStateNormal];
                }else if ([str isEqualToString:@"50后"]){
                    [_generationPicker selectRow:5 inComponent:0 animated:YES];
                    _generationStr = @"50后";
                    [_generationButton setTitle:@"50后" forState:UIControlStateNormal];
                }else if ([str isEqualToString:@"40后"]){
                    [_generationPicker selectRow:6 inComponent:0 animated:YES];
                    _generationStr = @"40后";
                    [_generationButton setTitle:@"40后" forState:UIControlStateNormal];
                }else if ([str isEqualToString:@"40前"]){
                    [_generationPicker selectRow:7 inComponent:0 animated:YES];
                    _generationStr = @"40前";
                    [_generationButton setTitle:@"40前" forState:UIControlStateNormal];
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.contentView addSubview:label1];
                [cell.contentView addSubview:_generationButton];
                break;
            }
            default:
                break;
        }
        return cell;
    }else{
        static NSString *cellIdentifier = @"cellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews) {
            //if (view.tag > 100) {
                [view removeFromSuperview];
           //}
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *label1 = [[UILabel alloc] init];
        label1.frame = CGRectMake(20, 15, 100, 20);
        label1.textAlignment = NSTextAlignmentLeft;
        label1.backgroundColor = [UIColor clearColor];
        label1.tag = 105;
        
        switch (indexPath.row) {
            case 0:
            {
                [cell addSubview:_photoView];
                UILabel *photoLabel = [[UILabel alloc] init];
                photoLabel.frame = CGRectMake(120, 30, 70, 25);
                photoLabel.backgroundColor = [UIColor clearColor];
                photoLabel.text = @"上传头像";
                photoLabel.tag = 102;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [_photoView setImage:[UIImage imageNamed:@"male_holder.png"]];
                if (_headPhoto) {
                    [self setHeadPhoto];
                }
                [cell.contentView addSubview:photoLabel];
            }
                break;
            case 1:
            {
                label1.text = [_mainDic objectForKey:@"register_username"];
                [cell.contentView addSubview:label1];
                [cell.contentView addSubview:_usernameTextField];
                break;
            }
            case 2:
            {
                label1.text = [_mainDic objectForKey:@"register_sex"];
                [cell.contentView addSubview:label1];
                _sexSegment.selectedSegmentIndex = 2;
                [cell.contentView addSubview:_sexSegment];
                break;
            }
            case 3:
            {
                label1.text = [_mainDic objectForKey:@"register_generation"];
                [cell.contentView addSubview:label1];
                [cell.contentView addSubview:_generationButton];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
            case 4:
            {
                label1.text = [_mainDic objectForKey:@"register_password"];
                [cell.contentView addSubview:label1];
                [cell.contentView addSubview:_passwordTextField];
                break;
            }
            case 5:
            {
                label1.text = [_mainDic objectForKey:@"register_passwordAgain"];
                [cell.contentView addSubview:label1];
                [cell.contentView addSubview:_passwordAgainTextField];
                break;
            }
            default:
                break;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self takePhoto];
    }else{
        [self handleBigButton];
    }
    if ([[AccountUser getSingleton].loginFlag isEqualToString:@"1"]){

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 150;
}

//点击空白处收起键盘和pickerView
- (void)handleBigButton
{
    [_usernameTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_passwordAgainTextField resignFirstResponder];
    
    [self hidePickerView];
}

- (void)checkShare
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"informCenterArticlePush"];
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
    [ud synchronize];
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

@end
