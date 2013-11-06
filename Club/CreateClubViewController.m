//
//  CreateClubViewController.m
//  WeClub
//
//  Created by chao_mit on 13-2-25.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "CreateClubViewController.h"

@interface CreateClubViewController ()

@end

@implementation CreateClubViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithType:(int)myType andAdoptClubDic:(NSDictionary *)myAdoptDic{
    self = [super init];
    opType = myType;
    if (myType) {
        adoptDic = myAdoptDic;
        //初始化,俱乐部名称,分类
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [rp cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myConstants = [Constants getSingleton];
    [self initNavigation];
    UILabel *tipLbl = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
    tipLbl.text = @"点击上传版标";
    tipLbl.textColor = [UIColor grayColor];
    tipLbl.numberOfLines = 2;
    [self.view addSubview:tipLbl];
    logo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
    logo.layer.borderColor = [[UIColor grayColor]CGColor];
    logo.layer.borderWidth = 1.0;
    logo.layer.masksToBounds = YES;
    logo.layer.cornerRadius = 5;
    [self.view addSubview:logo];
    logo.userInteractionEnabled = YES;
    [Utility addTapGestureRecognizer:logo withTarget:self action:@selector(takePhoto)];
    
    clubNameField = [[UITextField alloc]initWithFrame:CGRectMake(200, 9, 90, 20)];
    clubNameField.placeholder = @"请输入名字";
    clubNameField.delegate =self;
    [self.view addSubview:clubNameField];

    
    categoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    categoryBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    categoryBtn.frame = CGRectMake(200, 30, 90, 40);
    [categoryBtn setTitle:@"请选择分类" forState:UIControlStateNormal];
    [categoryBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [categoryBtn addTarget:self action:@selector(selectCategory) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:categoryBtn];
    
    categoryToSend = [[NSMutableString alloc] init];
    categoryToSend = @"0000";
    
    if (opType) {
        clubNameField.text = [adoptDic objectForKey:KEY_NAME];
        clubNameField.userInteractionEnabled = NO;
        categoryBtn.userInteractionEnabled = NO;
        [categoryBtn setTitle:[myConstants.clubCategory objectAtIndex:[[adoptDic objectForKey:@"category"] intValue]] forState:UIControlStateNormal];
    }
    
    categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, myConstants.screenHeight-20-216-44, 320, 216)];
    categoryView.backgroundColor = TINT_COLOR;
    categoryPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
    categoryPicker.dataSource = self;
    categoryPicker.delegate = self;
    categoryPicker.showsSelectionIndicator = YES;
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    finishBtn.frame = CGRectMake(240, categoryPicker.frame.origin.y-40, 80, 40);
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishPickCategory) forControlEvents:UIControlEventTouchDown];
    [categoryView addSubview:finishBtn];
    [categoryView addSubview:categoryPicker];
    //    categoryView.hidden = YES;
    
    myTV = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(104, 125, 205, 100)];
    myTV.placeholder = @"请填写俱乐部描述";
    myTV.delegate = self;
    myTV.layer.borderColor = [[UIColor blackColor]CGColor];
    myTV.layer.borderWidth = 1.0;
    myTV.layer.cornerRadius = 5;
    [self.view addSubview:myTV];
    
    UIImageView* tintImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 258, 20, 20)];
    [tintImage setImage:[UIImage imageNamed:@"chat_voice_someone3.png"]];
    [self.view addSubview:tintImage];

    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"公开",@"私密", nil]];
    segment.selectedSegmentIndex = 0;
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.frame = CGRectMake(205, 70, 80, 20);
    [segment addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];
    
//    privateTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    privateTypeBtn.backgroundColor = [UIColor redColor];
//    privateTypeBtn.tag = CLUB_TYPE_PUBLIC;
//    privateTypeBtn.frame = CGRectMake(235, 70, 15, 15);
//    [privateTypeBtn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:privateTypeBtn];
//    
//    publicTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    publicTypeBtn.backgroundColor = [UIColor redColor];
//    publicTypeBtn.tag = CLUB_TYPE_PRIVATE;
//    publicTypeBtn.frame = CGRectMake(295, 70, 15, 15);
//    [publicTypeBtn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:privateTypeBtn];
//    [self.view addSubview:publicTypeBtn];
    
    UIButton *submit = [[UIButton alloc]initWithFrame:CGRectMake(130, 290, 60, 30)];
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchDown];
    [submit setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [self.view addSubview:submit];
    
    UIButton *xieyi = [UIButton buttonWithType:UIButtonTypeCustom];
    xieyi.frame = CGRectMake(170, 258, 80, 14);
    [xieyi setTitle:@"注册协议" forState:UIControlStateNormal];
    [xieyi setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [xieyi addTarget:self action:@selector(goXieYi) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:xieyi];
    
    [Utility addTapGestureRecognizer:self.view withTarget:self action:@selector(backgroundTap)];
    clubType = 0;//俱乐部默认为公开
    
    rp = [[RequestProxy alloc] init];
    rp.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


-(void)segmentDidChange:(id)sender{
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segment = sender;
        clubType = segment.selectedSegmentIndex;
    }
}

-(void)finishPickCategory{
    [categoryView removeFromSuperview];
    [bgView removeFromSuperview];
    categoryView.hidden = YES;
}

//查看协议
-(void)goXieYi{
    AboutViewController *about = [[AboutViewController alloc]initWithContentType:@"0"];
    [self.navigationController pushViewController:about animated:YES];
}


#pragma mark -
#pragma mark  拍照或获取图片
-(void) takePhoto{
    DLCImagePickerController*  picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    WeLog(@"%@",picker);
    [self presentModalViewController:picker animated:YES];
}

#pragma mark -imagePickerController
-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    WeLog(@"mediaType:%@",mediaType);
    UIImage *image = [UIImage imageWithData:[info objectForKey:@"data"]];
    logo.image = image;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark  分类选择
-(void)selectCategory{
//    [self backgroundTap];
//    if (!bgView) {
    
        bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20-216)];
//    }
    [Utility addTapGestureRecognizer:bgView withTarget:self action:@selector(finishPickCategory)];
    if([categoryBtn.titleLabel.text isEqualToString:@"请选择分类"]){
    [categoryBtn setTitle:@"爱好" forState:UIControlStateNormal];
    }
    [clubNameField resignFirstResponder];
    [myTV resignFirstResponder];
    categoryView.backgroundColor = [UIColor clearColor];
    [categoryView.layer addAnimation:[Utility createAnimationWithType:kCATransitionMoveIn withsubtype:kCATransitionFromTop withDuration:0] forKey:@"animation"];
    categoryView.hidden = NO;

    [self.view addSubview:bgView];
    [self.view addSubview:categoryView];
}

- (void) GetResult:(ASIHTTPRequest *)request{
    WeLog(@"CreateClubViewgot data:%@",request.responseString);
    NSDictionary *gotDic = [request.responseString objectFromJSONString];
    WeLog(@"CreateClubView:%@",gotDic);
    int statusValue = [[gotDic objectForKey:KEY_STATUS] intValue];
    WeLog(@"status%d",statusValue);
    if (statusValue) {
        switch ([[[gotDic objectForKey:KEY_FAILURES] objectForKey:@"code"] intValue]) {
            case FAILURE_TYPE_EXISTS:
                [SVProgressHUD dismissWithError:@"该俱乐部已存在"];
                break;
            default:
                break;
        }
    }else{
        clubNumID = [[gotDic objectForKey:@"numid"] intValue];
        [SVProgressHUD dismissWithSuccess:@"俱乐部创建成功"];
    }
}
#pragma mark -
#pragma mark  UIPicker DataSource & Delegate
//返回每个组件上的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [myConstants.clubCategory count];
}
//返回组件数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//每一列中每一行的具体内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [myConstants.clubCategory objectAtIndex:row];
}
//选中哪一列哪一行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    categoryName = [myConstants.clubCategory objectAtIndex:row];
    categoryToSend = [[NSMutableString alloc] init];
    //组织成0002，4位数的格式
    for (int i = 0; i < (4-[[NSString stringWithFormat:@"%d",row] length]); i++) {
        [categoryToSend appendString:@"0"];
    }
    [categoryToSend appendString:[NSString stringWithFormat:@"%d",row]];
    [categoryBtn setTitle:categoryName forState:UIControlStateNormal];
}
- (void) GetErr:(ASIHTTPRequest *)request{
    
}

-(BOOL)check{
    if (!logo.image) {
        [Utility MsgBox:@"您还没有选择俱乐部版标."];
        return NO;
    }
    //名字长度暂定10
    NSString * regex = @"^[\u4e00-\u9fa5A-Za-z@][\u4e00-\u9fa5A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:clubNameField.text];
    WeLog(@"isMatch%d",isMatch);

    if (!isMatch) {
        [Utility MsgBox:@"俱乐部名称不能输入特殊字符，并且只能以字母汉字开头."];
        return NO;
    }
    if ([clubNameField.text length]>10) {
        [Utility MsgBox:@"俱乐部名称不能超过10个字符!"];
        return NO;
    }else if(![[clubNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]){
        [Utility MsgBox:@"俱乐部名称不能为空!"];
        return NO;
    }else if([clubNameField.text length] < 2){
        [Utility MsgBox:@"俱乐部名称不能少于2个字符!"];
        return NO;
    }
    if ([categoryBtn.titleLabel.text isEqualToString:@"请选择分类"]) {
        [Utility MsgBox:@"俱乐部分类不能为空!"];
        return NO;
    }
    if (![[myTV.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]) {
        [Utility MsgBox:@"俱乐部描述不能为空!"];
        return NO;
    }else if([myTV.text length] < 6){
        [Utility MsgBox:@"俱乐部描述不能少于6个字符!"];
        return NO;
    }else if([myTV.text length]>256){
        [Utility MsgBox:@"俱乐部描述不能超过256个字符!"];
        return NO;
    }

    return YES;
    //检测俱乐部名称非空
    //检测俱乐部名称最大长度
    //检测俱乐部分类非空
    //保证所有字段都不能为空，才能正确的发出去
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_CREATE]) {
        [Utility showHUD:@"俱乐部创建成功"];
        [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
        [self back];
    }
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_CREATE]) {
//        [Utility showHUD:@"俱乐部创建失败"];
        [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
    }
}
- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_CREATE]) {
//        [Utility showHUD:@"俱乐部创建失败"];
        [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
    }
}

//提交注册俱乐部
-(void)submit{
    if (![self check]) {
        return;
    }
    WeLog(@"字符个数%d",[clubNameField.text length]);
    NSData* aData = [clubNameField.text dataUsingEncoding: NSASCIIStringEncoding];
    WeLog(@"字节数aDatalength%d",[aData length]);

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:myTV.text forKey:KEY_DESC];
    
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]init];
    if (logo.image) {
        //头像非空时，发送头像
        [dataDic setObject:UIImageJPEGRepresentation(logo.image, 0.5) forKey:@"attachment"];
    }
    if (opType) {
        [dic setValue:myTV.text forKey:KEY_DESC];
        [dic setValue:[adoptDic objectForKey:KEY_NAME] forKey:KEY_CLUB_NAME];
        [dic setValue:[adoptDic objectForKey:@"category"] forKey:KEY_CATEGORY];
        [dic setValue:[adoptDic objectForKey:@"clubRowkey"] forKey:KEY_CLUB_ROW_KEY];
        [rp sendDictionary:dic andURL:URL_CLUB_ADOPT andData:dataDic];
    }else{
        [dic setValue:categoryToSend forKey:KEY_CATEGORY];
        [dic setValue:[NSString stringWithFormat:@"%d",clubType] forKey:@"openType"];
        [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
        [dic setValue:clubNameField.text forKey:KEY_CLUB_NAME];
        [rp sendDictionary:dic andURL:URL_CLUB_CREATE andData:dataDic];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    [SVProgressHUD showWithStatus:@"稍等..." maskType:SVProgressHUDMaskTypeClear];
    //    使用延迟执行是因为SVProgressHUD未显示出来就已经执行到getresult了
    //同步请求是不能取消的
}

-(void)backgroundTap{
    [myTV resignFirstResponder];
    [clubNameField resignFirstResponder];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    WeLog(@"%d",[textField.text length]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initNavigation{
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"创建俱乐部";
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
}


//俱乐部类型选择
-(void)selectType:(id)sender{
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case CLUB_TYPE_PUBLIC:
            privateTypeBtn.backgroundColor = [UIColor blackColor];
            publicTypeBtn.backgroundColor = [UIColor redColor];
            //            [privateTypeBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            //            [publicTypeBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            clubType = CLUB_TYPE_PUBLIC;
            break;
        case CLUB_TYPE_PRIVATE:
            privateTypeBtn.backgroundColor = [UIColor redColor];
            publicTypeBtn.backgroundColor = [UIColor blackColor];
            //            [privateTypeBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            //            [publicTypeBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            clubType = CLUB_TYPE_PRIVATE;
            break;
        default:
            break;
    }
}
@end
