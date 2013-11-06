//
//  ClubProfileEditViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubProfileEditViewController.h"

@interface ClubProfileEditViewController ()

@end

@implementation ClubProfileEditViewController

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
        OPtype = 1;
        _adoptFlag = 0;
        registNewClub = 0;
    }
    return self;
}

- (id)initWithType:(int)myType
{
    self = [super init];
    if (self) {
        registNewClub = 0;
        OPtype = myType;
        _adoptFlag = 0;
        if (myType == 3) {
            registNewClub = 1;
            OPtype = 0;
        }
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [rp cancel];
    [SVProgressHUD dismiss];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CLUB_EDITINFO_REFRESH" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAfterEditInfo:)
    //                                                 name:@"CLUB_EDITINFO_REFRESH" object:nil];
}

-(void)dealloc{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CLUB_EDITINFO_REFRESH" object:nil];
}

-(void)viewWillUnload{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (iPhone5) {
        myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 568-44-20) style:UITableViewStyleGrouped];
    }else{
        myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 480-44-20) style:UITableViewStyleGrouped];
    }
    myTable.backgroundView = nil;
    myTable.backgroundColor = [UIColor whiteColor];
    myTable.delegate = self;
    myTable.dataSource = self;
    [self.view addSubview:myTable];
    
    //头像
    logo = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
    logo.layer.borderColor = [[UIColor grayColor]CGColor];
    logo.layer.borderWidth = 0.5;
    CLUB_LOGO(logo, club.ID,club.picTime);
    
    name = club.name;
    segment = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"公开",@"私密", nil]];
    
    if (club) {
        WeLog(@"category%@",club.category);
        category = [Utility switchCategory:club.category];
    }else{
        category = nil;
        clubType = 0;
    }
    
    selectedLogo = NO;
    desc = club.desc;
    if (self.adoptFlag == 1) {
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-40-216-64, 320, 256)];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeClub:) name:@"CLUB_CHANGE_INFO" object:nil];
}

//请求代理
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    WeLog(@"type %@",type);
    [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
    if ([type isEqualToString:URL_CLUB_UPDATE_INFO]) {
        club.name = name;
        club.desc = desc;
        club.category = category;
        if (self.adoptFlag == 1) {
            [self updateAdopteClubLogo];
        }else{
            [SVProgressHUD dismissWithSuccess:@"修改成功"];
        }
        //            [self.navigationController popViewControllerAnimated:YES];
    }else if ([type isEqualToString:URL_CLUB_ADOPT]){
        [UIView animateWithDuration:2 animations:^{
            [SVProgressHUD dismissWithSuccess:@"修改成功"];
            if (self.target) {
                if ([self.target respondsToSelector:@selector(adoptFresh)]) {
                    [self.target performSelector:self.method];
                }
            }
        }completion:^(BOOL finished) {
            if ([self.lastAdopt isEqualToString:@"YES"]) {
                self.navigationController.navigationBarHidden = YES;
                TabBarController *_tabC = [[TabBarController alloc] init];
                _tabC.lastAdoptClub = self.lastAdoptClub;
                ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = _tabC;
                WeLog(@"%@ %@",self.navigationController,_tabC);
                [self.navigationController pushViewController:_tabC animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        
    }else if ([type isEqualToString:URL_CLUB_CREATE]){
        Club *newClub = [[Club alloc]init];
        newClub.ID = [dic objectForKey:@"clubrowkey"];
        [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
        [SVProgressHUD dismissWithSuccess:@"创建成功"];
        int money = [[AccountUser getSingleton].money integerValue];
        if (clubType) {
            money -= 200;           //创建私密俱乐部减去200伪币
        }else{
            money -= 100;           //创建公开俱乐部减去100伪币
        }
        if ([myAccountUser.i_follow_count intValue]) {
            [AccountUser getSingleton].money = [NSString stringWithFormat:@"%d",money];  //未必修改后重新赋值
            InviteViewController *inviteView =  [[InviteViewController alloc]initWithClub:newClub];
            inviteView.isPushFromNewClub = YES;
            [self.navigationController pushViewController:inviteView animated:YES];
        }else{
            ClubViewController *clubView = [[ClubViewController alloc]init];
            clubView.club = newClub;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
            clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
            clubView.isPushFromNewClub = YES;
            [self.navigationController pushViewController:clubView animated:YES];
        }
        
    }else if ( [type isEqualToString:URL_CLUB_UPDATE_LOGO]){
        if (self.adoptFlag == 1) {
            NSMutableDictionary *dic1 = [[NSMutableDictionary alloc] initWithCapacity:1];
            [dic1 setObject:club.ID forKey:@"clubid"];
            [rp sendDictionary:dic1 andURL:URL_CLUB_ADOPT andData:nil];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [Utility showHUD:@"版标更新成功"];
        }
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [SVProgressHUD dismiss];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [SVProgressHUD dismiss];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_CREATE]) {
        [Utility showHUD:@"创建失败"];
    }else if ([type isEqualToString:URL_CLUB_UPDATE_INFO]){
        [Utility showHUD:@"更新失败"];
    }
}


-(int)countOfSubString:(NSString *)st{
    int count = 0;
    for (int i = 0; i < [name length]; i++) {
        NSString *s = [name substringWithRange:NSMakeRange(i, 1)];
        if ([s isEqualToString:st]) {
            count++;
        }
    }
    return count;
}

-(BOOL)check{
    //    if (!logo.image) {
    //        [Utility MsgBox:@"您还没有选择俱乐部版标."];
    //        return NO;
    //    }
    UIImage *image = logo.image;
    if (![name length]) {
        [Utility MsgBox:@"俱乐部名称不能为空!"];
        return NO;
    }
    if (self.adoptFlag) {
        if (OPtype && !selectedLogo && !self.logoFlag) {
            [Utility MsgBox:@"请先选择版标!"];
            return NO;
        }
        
    }
    //名字长度暂定10
    if (!OPtype && !selectedLogo) {
        [Utility MsgBox:@"请先选择版标!"];
        return NO;
    }
    
    if ([Utility unicodeLengthOfString:name]>10) {
        [Utility MsgBox:@"俱乐部名称不能超过10个字符!"];
        return NO;
    }else if([Utility getByteLengthOfString:name] < 4){
        [Utility MsgBox:@"俱乐部名称不能少于2个字符!"];
        return NO;
    }
    NSString * regex = @"^[\u4e00-\u9fa5A-Za-z@][\u4e00-\u9fa5A-Za-z()]*[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:name];
    if (!isMatch) {
        [Utility MsgBox:@"俱乐部名称由英文字母、中文、数字、括号组成，且只能以字母汉字开头,数字只能放在最后."];
        return NO;
    }
    if (!category) {
        [Utility MsgBox:@"俱乐部分类不能为空!"];
        return NO;
    }
    
    //<<<<<<< ClubProfileEditViewController.m
    //    if (![[desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]) {
    //        [Utility MsgBox:@"俱乐部描述不能为空!"];
    //        return NO;
    //    }else if([Utility unicodeLengthOfString:desc] < 6){
    //        [Utility MsgBox:@"俱乐部描述不能少于6个汉字!"];
    //        return NO;
    //    }else if([Utility unicodeLengthOfString:desc]>256){
    //        [Utility MsgBox:@"俱乐部描述不能超过256个汉字!"];
    //        return NO;
    //    }
    //=======
    if (![[desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]) {
        [Utility MsgBox:@"俱乐部描述不能为空!"];
        return NO;
    }else if([Utility unicodeLengthOfString:desc] < 6){
        [Utility MsgBox:@"俱乐部描述不能少于6个汉字!"];
        return NO;
    }else if([Utility unicodeLengthOfString:desc]>140){
        [Utility MsgBox:@"俱乐部描述不能超过140个汉字!"];
        return NO;
    }
    if (!OPtype) {
        if (-1 == segment.selectedSegmentIndex) {
            [Utility MsgBox:@"俱乐部类型不能为空!"];
            return NO;
        }
    }
    
    
    
    //>>>>>>> 1.35
    
    return YES;
    //检测俱乐部名称非空
    //检测俱乐部名称最大长度
    //检测俱乐部分类非空
    //保证所有字段都不能为空，才能正确的发出去
}

//创建俱乐部
-(void)createClub{
    UIAlertView *alert = [Utility MsgBox:[NSString stringWithFormat:@"您现在用%@伪币，创建俱乐部需要花费100伪币是否继续?",myAccountUser.money] AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"继续" withStyle:0];
    alert.tag = 1;
}

//保存请求
-(void)save{
    if (![self check]) {
        return;
    }
    //更新资料说明:传送的类别是类似0001的代码
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:desc forKey:KEY_DESC];
    [dic setValue:category forKey:KEY_CATEGORY];
    [dic setValue:name forKey:KEY_CLUB_NAME];
    
    
    if (OPtype) {
        [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
        NSDictionary *imgDic;
        //原来是因为图片太大的原因
        if (imgData) {
            imgDic = [NSDictionary dictionaryWithObjectsAndKeys:imgData,@"attachment", nil];
            [[SDImageCache sharedImageCache] removeImageForKey:CLUB_LOGO_URL_STRING(club.ID,TYPE_THUMB,club.picTime)];
            [[SDImageCache sharedImageCache] removeImageForKey:CLUB_LOGO_URL_STRING(club.ID,TYPE_RAW,club.picTime)];
        }
        [rp sendDictionary:dic andURL:URL_CLUB_UPDATE_INFO andData:imgDic];
    }else{
        NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]init];
        imgData = UIImageJPEGRepresentation(logo.image,0.5);
        [dataDic setObject:imgData forKey:@"attachment"];
        [dic setValue:[NSString stringWithFormat:@"%d",clubType] forKey:@"openType"];
        [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
        [rp sendDictionary:dic andURL:URL_CLUB_CREATE andData:dataDic];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)changeClub:(NSNotification *)notifacation
{
    if ([[notifacation.userInfo objectForKey:@"keyName"] isEqualToString:@"名称"]) {
        name = (NSString *)notifacation.object;
    }else{
        desc = (NSString *)notifacation.object;
    }
    [myTable reloadData];
}

#pragma mark -
#pragma mark  修改版标拍照或获取图片
-(void) changeLogo{
    DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark -imagePickerController
-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    WeLog(@"mediaType:%@",mediaType);
    UIImage *image = [UIImage imageWithData:[info objectForKey:@"data"]];
    selectedLogo = YES;
    logo.image = image;
    imgData = UIImageJPEGRepresentation(logo.image,0.5);
    [myTable reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self dismissModalViewControllerAnimated:YES];
    if (OPtype && !self.adoptFlag) {
        [self updateClubLogo];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)updateClubLogo{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    NSDictionary *imgDic;
    //原来是因为图片太大的原因
    if (imgData) {
        imgDic = [NSDictionary dictionaryWithObjectsAndKeys:imgData,@"attachment", nil];
        [[SDImageCache sharedImageCache] removeImageForKey:CLUB_LOGO_URL_STRING(club.ID,TYPE_THUMB,club.picTime)];
        [[SDImageCache sharedImageCache] removeImageForKey:CLUB_LOGO_URL_STRING(club.ID,TYPE_RAW,club.picTime)];
    }
    [rp sendDictionary:dic andURL:URL_CLUB_UPDATE_LOGO andData:imgDic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)updateAdopteClubLogo{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    NSDictionary *imgDic;
    //原来是因为图片太大的原因
    if (imgData) {
        imgDic = [NSDictionary dictionaryWithObjectsAndKeys:imgData,@"attachment", nil];
        [[SDImageCache sharedImageCache] removeImageForKey:CLUB_LOGO_URL_STRING(club.ID,TYPE_THUMB,club.picTime)];
        [[SDImageCache sharedImageCache] removeImageForKey:CLUB_LOGO_URL_STRING(club.ID,TYPE_RAW,club.picTime)];
    }
    [rp sendDictionary:dic andURL:URL_CLUB_UPDATE_LOGO andData:imgDic];
}

//修改分类
-(void)selectCategory{
    bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height-44-20-216)];
    //  [Utility addTapGestureRecognizer:bgView withTarget:self action:@selector(finishPickCategory)];
    categoryView.hidden = NO;
    [categoryView.layer addAnimation:[Utility createAnimationWithType:kCATransitionMoveIn withsubtype:kCATransitionFromTop withDuration:0] forKey:@"animation"];
    //  [categoryPicker selectRow:[category intValue] inComponent:0 animated:NO];
    if (![category length]) {
        //[categoryPicker selectRow:0 inComponent:0 animated:NO];
    }else{
        [categoryPicker selectRow:[category intValue] inComponent:0 animated:NO];
    }
    [self.view addSubview:bgView];
    [self.view addSubview:categoryView];
}

//完成(取消)分类选择
-(void)finishPickCategory:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag) {
        //完成按钮
        NSMutableString *categoryToSend = [[NSMutableString alloc] init];
        for (int i = 0; i < (4-[[NSString stringWithFormat:@"%d",selectedRow] length]); i++) {
            [categoryToSend appendString:@"0"];
        }
        [categoryToSend appendString:[NSString stringWithFormat:@"%d",selectedRow]];
        category = categoryToSend;
        //组织成0002，4位数的格式
        [myTable reloadData];
        if (OPtype && !self.adoptFlag) {
            [self save];
        }
    }else{
        selectedRow = [category intValue];
        //取消按钮
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [categoryView removeFromSuperview];
    [bgView removeFromSuperview];
    categoryView.hidden = YES;
}

//修改名称 修改描述
-(void)refreshAfterEditInfo:(NSNotification *)notification{
    if (self.adoptFlag == 1) {
        
    }else{
        if ([[notification.userInfo objectForKey:@"keyName"] isEqualToString:@"名称"]) {
            name = (NSString *)notification.object;
        }else{
            desc = (NSString *)notification.object;
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [myTable reloadData];
        if (OPtype) {
            [self save];
        }
    }
}

#pragma mark -
#pragma mark refreshDelegate
-(void)refresh:(NSDictionary *)dic{
    if (self.adoptFlag == 1) {
        
    }else{
        if ([[dic objectForKey:@"keyName"] isEqualToString:@"名称"]) {
            name = [dic objectForKey:@"value"];
        }else{
            desc = [dic objectForKey:@"value"];
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [myTable reloadData];
        if (OPtype) {
            [self save];
        }
        return;
    }
    //    [self save];
}


#pragma mark -
#pragma mark  UITableView DataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (0 == section) {
        return 1;
    }
    if (OPtype) {
        return 3;
    }else{
        return 4;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *string;
    if (0 == indexPath.section) {
        string = @"上传版标";
        return 70;
    }else{
        if (0 == indexPath.row) {
            string = name;
            if (![name length]) {
                return 46;
            }
        }else if(1 == indexPath.row){
            NSArray *array = [NSArray arrayWithObjects:@"爱好",@"情感",@"体育",@"娱乐",@"女性",@"购物",@"生活",@"旅游",@"科技",@"财经",@"音乐",@"文学",@"艺术",@"校友",@"同乡",@"其它",nil];
            string = [array objectAtIndex:[category intValue]];
        }else if(2 == indexPath.row){
            //            string = desc;
            //            if (![desc length]) {
            //                return 46;
            //            }
            
            string = desc;
            
            //if ([Utility getMixedViewHeight:string withWidth:160]+15+20 < 46) {
            if (![[desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
                return 46;
            }
            WeLog(@"描述栏的高度%f",([self getMixedViewHeight:string] + 35));
            return [self getMixedViewHeight:string] + 35;
            //            if (![desc length]) {
            //                return 46;
            //            }
        }else{
            return 46;
        }
    }
    CGFloat contentHeight = [Utility getSizeByContent:string withWidth:160 withFontSize:17];
    return contentHeight+25;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (!OPtype) {
        if (section == 1) {
            return [NSString stringWithFormat:@"您现在拥有%@伪币，创建公开俱乐部需要100伪币，私密俱乐部需要200伪币。",myAccountUser.money];
        }
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * Identifier = @"ClubProfileEditCell";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    [Utility removeSubViews:cell.contentView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, 160, 13)];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:FONT_NAME_ARIAL size:17];
    UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 20)];
    tLabel.font = [UIFont fontWithName:FONT_NAME_ARIAL_BOLD size:18];
    tLabel.backgroundColor = [UIColor clearColor];
    if (0 == indexPath.section) {
        [cell.contentView addSubview:logo];
        label.text = @"上传版标";
        label.frame = CGRectMake(110, 25, 160, 20);
    }else{
        if (0 == indexPath.row) {
            tLabel.text = @"名   称:";
            label.text = name;
            [cell.contentView addSubview:tLabel];
            CGFloat contentHeight = [Utility getSizeByContent:label.text withWidth:160 withFontSize:17];
            label.frame = CGRectMake(90, 9, 160, contentHeight);
        }else if(1 == indexPath.row){
            tLabel.text = @"分   类:";
            if (!category) {
                //label.text = [myConstants.clubCategory objectAtIndex:[category intValue]];
                label.text = nil;
            }else{
                NSArray *array = [NSArray arrayWithObjects:@"爱好",@"情感",@"体育",@"娱乐",@"女性",@"购物",@"生活",@"旅游",@"科技",@"财经",@"音乐",@"文学",@"艺术",@"校友",@"同乡",@"其它",nil];
                label.text = [array objectAtIndex:[category intValue]];
                //label.text = nil;
            }
            CGFloat contentHeight = [Utility getSizeByContent:label.text withWidth:160 withFontSize:17];
            label.frame = CGRectMake(90, 9, 160, contentHeight);
            [cell.contentView addSubview:tLabel];
        }else if(2 == indexPath.row){
            tLabel.text = @"描   述:";
            label.text = desc;
            [cell.contentView addSubview:tLabel];
            //            CGFloat contentHeight = [Utility getSizeByContent:label.text withWidth:160 withFontSize:17];
            //            label.frame = CGRectMake(110, 9, 160, contentHeight);
            //            [Utility emotionAttachString:desc toView:label];
            //CGFloat contentHeight = [Utility getMixedViewHeight:desc withWidth:230];
            CGFloat contentHeight = [self getMixedViewHeight:desc];
            label.frame = CGRectMake(20, 30, 230, contentHeight);
            [self attachString:desc toView:label];
            label.text = @"";
        }else{
            tLabel.text = @"类   型:";
            //            segment.selectedSegmentIndex = 0;
            segment.segmentedControlStyle = UISegmentedControlStylePlain;
            segment.frame = CGRectMake(120, 5, 100, 30);
            [segment addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:segment];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.contentView addSubview:tLabel];
            CGFloat contentHeight = [Utility getSizeByContent:label.text withWidth:160 withFontSize:17];
            label.frame = CGRectMake(110, 9, 160, contentHeight);
        }
    }
    
    [cell.contentView addSubview:label];
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        [self changeLogo];
    }else{
        if (0 == indexPath.row) {
            EditInfoViewController *editInfoView = [[EditInfoViewController alloc]init];
            editInfoView.style = 0;
            editInfoView.title = @"编辑名称";
            editInfoView.str = name;
            editInfoView.refreshDel = self;
            [self.navigationController pushViewController:editInfoView animated:YES];
        }else if(1 == indexPath.row){
            [self selectCategory];
        }else if(2 == indexPath.row){
            EditInfoViewController *editInfoView = [[EditInfoViewController alloc]init];
            editInfoView.style = 1;
            editInfoView.title = @"编辑描述";
            editInfoView.str = desc;
            editInfoView.refreshDel = self;
            [self.navigationController pushViewController:editInfoView animated:YES];
        }else{
            return;
        }
    }
}

//俱乐部类型选择
-(void)segmentDidChange:(id)sender{
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *mySegment = sender;
        clubType = mySegment.selectedSegmentIndex;
        if (clubType) {
            if ([myAccountUser.money intValue] < 200) {
                [Utility MsgBox:@"创建私密俱乐部需要200伪币，您的伪币不足!"];
                mySegment.selectedSegmentIndex = 0;
                clubType = 0;
            }
        }
    }
}

#pragma mark -
#pragma mark  UIPicker DataSource & Delegate
//返回每个组件上的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray *array = [NSArray arrayWithObjects:@"爱好",@"情感",@"体育",@"娱乐",@"女性",@"购物",@"生活",@"旅游",@"科技",@"财经",@"音乐",@"文学",@"艺术",@"校友",@"同乡",@"其它",nil];
    return [array count];
}
//返回组件数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//每一列中每一行的具体内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *array = [NSArray arrayWithObjects:@"爱好",@"情感",@"体育",@"娱乐",@"女性",@"购物",@"生活",@"旅游",@"科技",@"财经",@"音乐",@"文学",@"艺术",@"校友",@"同乡",@"其它",nil];
    return [array objectAtIndex:row];
}
//选中哪一列哪一行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedRow = row;
}

-(void)initNavigation{
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    if (OPtype) {
        titleLbl.text = @"俱乐部信息修改";
    }else{
        titleLbl.text = @"创建俱乐部";
    }
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLbl;
    
    //leftBarButtonItem
    if (registNewClub == 0) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = backbtn;
    }else if (registNewClub == 1) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
        btn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
        [btn setTitle:@"跳过" forState:UIControlStateNormal];
        [btn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = backbtn;
    }
    
    
    //rightBarButtonItem
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
    [saveBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    if (self.adoptFlag) {
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    }else if (OPtype) {
        saveBtn.hidden = YES;
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [saveBtn setTitle:@"创建" forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        UILabel *hintLbl = [[UILabel alloc]initWithFrame:CGRectMake(200, 300, 300, 40)];
        [Utility styleLbl:hintLbl withTxtColor:nil withBgColor:[UIColor redColor] withFontSize:16];
        hintLbl.text = [NSString stringWithFormat:@"您现在拥有%@伪币，创建私密俱乐部需要花费100伪币是否继续?",myAccountUser.money];
        [myTable addSubview:hintLbl];
    }
    [saveBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem;
}


#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        if (0 == buttonIndex) {
        }else if(1 == buttonIndex){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.tag ==1){
        if (0 == buttonIndex) {
        }else if(1 == buttonIndex){
            [self save];
        }
    }
    return;
}

-(void)back{
    NSString *hint;
    if (OPtype) {
        hint = @"是否放弃保存?";
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.navigationItem.rightBarButtonItem.enabled) {
        if (!OPtype) {
            hint = @"是否放弃创建?";
            UIAlertView *alert = [Utility MsgBox:hint AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
            alert.tag = 0;
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self mycutMixedString:str];
    //    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [targetView addSubview:btn];
                        x += subSize.width;
                    }else{
                        int index = 0;
                        while (x + [piece sizeWithFont:font].width > maxWidth) {
                            NSString *subString = [piece substringToIndex:index];
                            while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                                index++;
                                subString = [piece substringToIndex:index];
                            }
                            index--;
                            if (index <= 0) {
                                x = 0;
                                y += 22;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(x, y, subSize.width, 22);
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle:subString forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                            [targetView addSubview:btn];
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                    }
                    
                }else{
                    if (x + 22 > maxWidth) {
                        x = 0;
                        y += 22;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, 22, 22);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    [targetView addSubview:imgView];
                    x += 22;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                WeLog(@"huanhang");
                //换行
                x = 0;
                y += 22;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:subString forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        btn.userInteractionEnabled = NO;
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
    //    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(230, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    [self attachString:str toView:view];
    WeLog(@"%f",view.frame.size.height);
    return view.frame.size.height;
}

//匹配括号
- (NSRange)matching:(NSString *)str
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    int pStart = 1000;
    int pEnd = 0;
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"["]) {
            pStart = pEnd;
        }else if ([a isEqualToString:@"]"]){
            if (pStart == 1000) {
                pEnd++;
                continue;
            }else{
                range = NSMakeRange(pStart, pEnd-pStart+1);
                break;
            }
        }else if ([a isEqualToString:@"\n"]){
            if (pEnd == 0) {
                range = NSMakeRange(0, 1);
                break;
            }else{
                range = NSMakeRange(0, pEnd);
                break;
            }
        }
        pEnd++;
    }
    return range;
}

//切割字符串
- (NSMutableArray *)mycutMixedString:(NSString *)str
{
    //    WeLog(@"str to be cut:%@",str);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSRange range;
    while (1) {
        range = [self matching:str];
        if (range.location == NSNotFound) {
            break;
        }
        if (range.location != 0) {
            [returnArray addObject:[str substringToIndex:range.location]];
        }
        [returnArray addObject:[str substringWithRange:range]];
        str = [str substringFromIndex:range.location + range.length];
    }
    if ([str length] > 0) {
        [returnArray addObject:str];
    }
    while (1) {
        if ([[returnArray lastObject] isEqualToString:@"\n"]) {
            [returnArray removeObjectAtIndex:(returnArray.count - 1)];
        }else{
            break;
        }
    }
    return returnArray;
}

@end
