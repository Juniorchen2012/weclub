//
//  FriendClubManageViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "FriendClubManageViewController.h"
#import "ZBarSDK.h"


@interface FriendClubManageViewController ()

@end

@implementation FriendClubManageViewController


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
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    myConstants = [Constants getSingleton];
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    request = [[Request alloc] init];
    
    myScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44)];
    [myScroll setContentSize:CGSizeMake(320, 780)];
    UIButton *backTapBtn = [[UIButton alloc]initWithFrame:myScroll.frame];
    [myScroll addSubview:backTapBtn];
    //    [Utility addTapGestureRecognizer:self.view withTarget:self action:@selector(backgroundTap)];
    [backTapBtn addTarget:self action:@selector(backgroundTap) forControlEvents:UIControlEventTouchUpInside];
    //    [Utility addTapGestureRecognizer:backTapBtn withTarget:self action:@selector(backgroundTap)];
    [self.view addSubview:myScroll];
    [self refreshView];
    //    [myScroll addInfiniteScrollingWithActionHandler:^{
    //        //是不是可以通过SVPullToRefreshStateLoading判断刷新是否在进行，加在更多是否在进行
    //        WeLog(@"load more data");
    //    }];
    
    
    clubField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 230, 30)];
    clubField.placeholder = @"点击输入俱乐部名称/ID";
    clubField.backgroundColor = [UIColor clearColor];
    clubField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    clubField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(6, 10, 233, 30)];
    bgView.image = TXTFIELDBG;
    [myScroll addSubview:bgView];
    [myScroll addSubview:clubField];
    
    addBtn = [[UIButton alloc]initWithFrame:CGRectMake(255, 10, 60, 30)];
    addBtn.tag = -1;
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtn) forControlEvents:UIControlEventTouchUpInside];
    [myScroll addSubview:addBtn];
}

//
-(void)refreshView{
    int i;
    [friendClubView removeFromSuperview];
    friendClubView = [[UIView alloc]initWithFrame:CGRectMake(10, 60, 320, 10)];
    for (i = 0; i < [club.friendClubs count]; i++) {
        UIButton* deleteIcon = [[UIButton alloc]init];
        UIButton *clubLogo = [[UIButton alloc]init];
        Club *friendClub = [club.friendClubs objectAtIndex:i];
        [clubLogo setImageWithURL:CLUB_LOGO_URL(friendClub.ID,TYPE_THUMB,friendClub.picTime) placeholderImage:[UIImage imageNamed:LOGO_PIC_HOLDER]];
        //      CLUB_LOGO(clubLogo, friendClub.ID);
        clubLogo.tag = i;
        [clubLogo addTarget:self action:@selector(goFriendClub:) forControlEvents:UIControlEventTouchUpInside];
        [clubLogo setFrame:CGRectMake(80*(i%4), (i/4)*80, 60, 60)];
        clubLogo.backgroundColor = [UIColor redColor];
        [deleteIcon setFrame:CGRectMake(80*(i%4)+40, (i/4)*80-10, 30, 30)];
        [deleteIcon setImage:[UIImage imageNamed:@"deleteIcon.png"] forState:UIControlStateNormal];
        deleteIcon.tag = i;
        [deleteIcon addTarget:self action:@selector(sendRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *clubNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(80*(i%4), (i/4)*80+65, 60, 14)];
        clubNameLbl.textAlignment = UITextAlignmentCenter;
        [Utility styleLbl:clubNameLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        clubNameLbl.text = friendClub.name;
        
        [friendClubView addSubview:clubNameLbl];
        [friendClubView addSubview:clubLogo];
        [friendClubView addSubview:deleteIcon];
        if (friendClub.type) {
            UIImageView * OpentTypeImg = [[UIImageView alloc]initWithFrame:CGRectMake(80*(i%4)+5, (i/4)*80+45, 10, 10)];
            OpentTypeImg.image = [UIImage imageNamed:@"si.png"];
            [friendClubView addSubview:OpentTypeImg];
        }
        if (friendClub.userType == 1) {
            UIImageView * Identifyimg;
            Identifyimg = [[UIImageView alloc]initWithFrame:CGRectMake(80*(i%4)+50, (i/4)*80+45, 10, 10)];
            Identifyimg.image = [UIImage imageNamed:@"ban.png"];
            [friendClubView addSubview:Identifyimg];
        }else if (friendClub.userType == 2) {
            UIImageView * Identifyimg;
            Identifyimg = [[UIImageView alloc]initWithFrame:CGRectMake(80*(i%4)+50, (i/4)*80+45, 10, 10)];
            Identifyimg.image = [UIImage imageNamed:@"fu.png"];
            [friendClubView addSubview:Identifyimg];
        }
        
    }
    [friendClubView setFrame:CGRectMake(10, 60, 320, (i/4+1)*80)];
    [myScroll addSubview:friendClubView];
    [myScroll setContentSize:CGSizeMake(320, 60+(i/4)*80+80)];
}
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_GET_FRIENTCLUB]) {
        
    }else if ([type isEqualToString:URL_CLUB_FRIENTCLUB_ADD]){
        Club *newFriendClub = [[Club alloc]init];
        newFriendClub.ID = [dic objectForKey:KEY_CLUB_ROW_KEY];
        newFriendClub.name = [dic objectForKey:KEY_CLUB_NAME];
        newFriendClub.type = [[dic objectForKey:@"openType"] intValue];
        newFriendClub.userType = [[dic objectForKey:@"usertype"] intValue];
        [club.friendClubs insertObject:newFriendClub atIndex:0];
        clubField.text = @"";
        //        [club.friendClubs addObject:newFriendClub];
    }else if ([type isEqualToString:URL_CLUB_FRIENTCLUB_DELETE]){
        [Utility showHUD:@"删除成功"];
        [club.friendClubs removeObjectAtIndex:deleteNO];
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]) {
        //判断如果有权限在跳入新界面
        Club *friendclub = [club.friendClubs objectAtIndex:clubToGoNO];
        friendclub.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        friendclub.type = [[dic objectForKey:@"openType"] intValue];
        if (friendclub.type && friendclub.userType == 0) {
            UIAlertView *alert = [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
            alert.tag = 2;
            return;
        }
        friendclub.followThisClub = [[dic objectForKey:KEY_FOLLOW_THIS_CLUB] intValue];
        WeLog(@"是否关注该俱乐部%d",friendclub.followThisClub);
        ClubViewController *clubView = [[ClubViewController alloc]init];
        clubView.club = friendclub;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
        WeLog(@"登陆用户在该俱乐部的身份%d",friendclub.userType);
        clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
        [self.navigationController pushViewController:clubView animated:YES];
    }else if([type isEqualToString:URL_CLUB_JOIN]){
        //加入俱乐部
        [Utility showHUD:@"申请成功"];
    }else if ([type isEqualToString:URL_CLUB_GET_BASICINFO]){
        [newScanClub refreshClubDataWithDic:[dic objectForKey:KEY_DATA]];
        [self createShowView];
        
    }else if ([type isEqualToString:URL_CLUB_SEARCH_BASEINFO_BY_NAME]){
        [newScanClub refreshClubDataWithDic:[dic objectForKey:KEY_DATA]];
        newScanClub.ID = [[dic objectForKey:KEY_DATA] objectForKey:@"numid"];
        [self createShowView];
    }
    
    [self refreshView];
}
- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_GET_FRIENTCLUB]) {
    }else if ([type isEqualToString:URL_CLUB_FRIENTCLUB_ADD]){
    }else if ([type isEqualToString:URL_CLUB_FRIENTCLUB_DELETE]){
        //        [Utility showHUD:@"删除失败"];
    }
    
}

-(void)createShowView{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加该俱乐部为友情俱乐部" message:@" " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"添加", nil];
    alert.tag = 3;
    
    _bgView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.5;
    [self.navigationController.view addSubview:_bgView];
    _showView = [[UIView alloc] initWithFrame:CGRectMake(40, ([UIScreen mainScreen].bounds.size.height-130)/2, 240, 130)];
    _showView.backgroundColor = [UIColor whiteColor];
    _showView.layer.cornerRadius = 5;
    [self.navigationController.view addSubview:_showView];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(100, 20, 60, 60)];
    CLUB_LOGO(logo, newScanClub.ID,newScanClub.picTime);
    logo.backgroundColor= [UIColor redColor];
    logo.frame = CGRectMake(20, 20, 60, 60);
    UILabel *nameLbl = [[UILabel alloc]init];
    [Utility styleLbl:nameLbl withTxtColor:nil withBgColor:nil withFontSize:18];
    nameLbl.textColor = [UIColor blackColor];
    nameLbl.text = [NSString stringWithFormat:@"%@",newScanClub.name];
    nameLbl.frame = CGRectMake(logo.frame.origin.x+65, logo.frame.origin.y+5, 160, 20);
    UILabel *idLbl = [[UILabel alloc]init];
    idLbl.frame = CGRectMake(logo.frame.origin.x+65, logo.frame.origin.y+35, 160,20);
    [Utility styleLbl:idLbl withTxtColor:nil withBgColor:nil withFontSize:18];
    idLbl.textColor = [UIColor blackColor];
    idLbl.text = [NSString stringWithFormat:@"ID:%@",newScanClub.ID];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"添加" forState:UIControlStateNormal];
    okBtn.frame = CGRectMake(30, 90, 80, 30);
    [okBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(addFriendClub:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(130, okBtn.frame.origin.y, 80, 30);
    [cancelBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hideShowView) forControlEvents:UIControlEventTouchUpInside];
    [_showView addSubview:okBtn];
    [_showView addSubview:cancelBtn];
    [_showView addSubview:logo];
    [_showView addSubview:nameLbl];
    [_showView addSubview:idLbl];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
    animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.duration = 0.5;
    [_showView.layer addAnimation:animation forKey:@"bouce"];
}

-(void)hideShowView{
    [_bgView removeFromSuperview];
    [_showView removeFromSuperview];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(BOOL)check{
    if (![clubField.text length]) {
        [Utility MsgBox:@"俱乐部ID或名称不能为空"];
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //删除的确认
    if (1 == alertView.tag) {
        if (0 == buttonIndex) {
            return;
        }else{
            NSString *postURL;
            NSString *friendClubID;
            postURL = URL_CLUB_FRIENTCLUB_DELETE;
            Club *friendClub = [club.friendClubs objectAtIndex:deleteNO];
            friendClubID = friendClub.ID;
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:friendClubID forKey:KEY_FRIEND_CLUB_ROW_KEY];
            [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
            [rp sendDictionary:dic andURL:postURL andData:nil];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
    }else if (2 == alertView.tag ) {
        //申请加入俱乐部
        if (buttonIndex == 1) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            Club *friendClub = [club.friendClubs objectAtIndex:clubToGoNO];
            [dic setValue:friendClub.ID forKey:KEY_CLUB_ROW_KEY];
            [rp sendDictionary:dic andURL:URL_CLUB_JOIN andData:nil];
        }else{
            return;
        }
        return;
    }else if (3 == alertView.tag){
        //添加扫瞄的俱乐部为友情俱乐部
        if (buttonIndex == 1) {
            [self addFriendClub:nil];
        }else{
            return;
        }
    }else if (4 == alertView.tag){
        //拷贝扫描的文本
        if (buttonIndex == 1) {
            [self copy:qrText];
        }else{
            return;
        }
    }
}

-(void)copy:(NSString*)str {
    
    NSString *copyString = [[NSString alloc] initWithFormat:@"%@",str];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyString];
}

-(void)addBtn{
    [clubField resignFirstResponder];
    newScanClub = [[Club alloc]init];
    
    if (![self check]) {
        return;
    }
    newScanClub.ID = clubField.text;
    NSString * regex = @"^[0-9]{8}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:clubField.text];
    if (isMatch) {
        [request getBaseInfo:clubField.text withDelegate:self];
    }else{
        [request getBaseInfoByName:clubField.text withDelegate:self];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //    //检查俱乐部名称
    //    NSString * regex1 = @"^[\u4e00-\u9fa5A-Za-z@][\u4e00-\u9fa5A-Za-z()]*[0-9]*$";
    //    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    //    BOOL isMatch1 = [pred1 evaluateWithObject:clubField.text];
    //    if (isMatch1) {
    //        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //        [dic setValue:clubField.text forKey:@"clubname"];
    //        [rp sendDictionary:dic andURL:URL_CLUB_SEARCH_BASEINFO_BY_NAME andData:nil];
    //    }
}

-(void)addFriendClub:(id)sender{
    [clubField resignFirstResponder];
    [self hideShowView];
    NSString *postURL;
    postURL = URL_CLUB_FRIENTCLUB_ADD;
    NSString *friendClubID;
    friendClubID = clubField.text;
    if (![self check]) {
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:friendClubID forKey:KEY_FRIEND_CLUB_ROW_KEY];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:postURL andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)sendRequest:(id)sender{
    UIImageView *img = (UIImageView *)sender;
    deleteNO = img.tag;
    UIAlertView *alert=[Utility MsgBox:@"确定删除该友情俱乐部" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
    alert.tag = 1;
}

- (void)goFriendClub:(id)sender{
    UIButton*btn = (UIButton *)sender;
    //    ClubViewController *friendClub = [[ClubViewController alloc]init] ;
    //    friendClub.club = [club.friendClubs objectAtIndex:btn.tag];
    clubToGoNO = btn.tag;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    Club *friendClub = [club.friendClubs objectAtIndex:btn.tag];
    [dic setValue:friendClub.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
}

- (void)scan{
    UINavigationController *reader = [[ZBarManager sharedZBarManager]getReaderWithDelegate:self helpStr:@"请扫描微俱俱乐部"];
    [ZBarManager sharedZBarManager].helpFlag = @"2";
    [self presentModalViewController:reader animated:YES];
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([ZBarManager sharedZBarManager].scanFlag != 0) {
        return;
    }
    [ZBarManager sharedZBarManager].scanFlag++;
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *code =[(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            
            NSString *s = [[Utility qrAnalyse:code] objectForKey:@"type"];
            if ( 2 == [s intValue]) {
                PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:code] objectForKey:@"id"]];
                personInfoView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personInfoView animated:YES];
            }else if (1 == [s intValue]){
                clubField.text = [[Utility qrAnalyse:code] objectForKey:@"id"];
                [self checkClubID];
                newScanClub = [[Club alloc]init];
                newScanClub.ID = clubField.text;
                [[ZBarManager sharedZBarManager] back];
                [request getBaseInfo:clubField.text withDelegate:self];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }else{
                UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:code] objectForKey:@"id"] AndTitle:@"扫瞄二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
                alert.tag = 4;
                qrText = [[Utility qrAnalyse:code] objectForKey:@"id"];
            }
            
            [[ZBarManager sharedZBarManager] back];
            break;
        }
    }
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
    WeLog(@"%@",symbol.data);
    NSString *s = [[Utility qrAnalyse:symbol.data] objectForKey:@"type"];
    if ( 2 == [s intValue]) {
        PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        personInfoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personInfoView animated:YES];
    }else if (1 == [s intValue]){
        clubField.text = [[Utility qrAnalyse:symbol.data] objectForKey:@"id"];
        [self checkClubID];
        newScanClub = [[Club alloc]init];
        newScanClub.ID = clubField.text;
        [[ZBarManager sharedZBarManager] back];
        [request getBaseInfo:clubField.text withDelegate:self];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else{
        UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"] AndTitle:@"扫瞄二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
        alert.tag = 4;
        qrText = [[Utility qrAnalyse:symbol.data] objectForKey:@"id"];
    }
}

-(void)checkClubID{
    //是否符合俱乐部号的规则
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    //titleView
    self.title = @"友情俱乐部管理";
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
    [menuBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    [menuBtn setTitle:@"二维码" forState:UIControlStateNormal];
    [menuBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem;
}
-(void)back{
    [rp cancel];
    [request cancelRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backgroundTap{
    [clubField resignFirstResponder];
}
@end
