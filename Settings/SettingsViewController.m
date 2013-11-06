//
//  SettingsViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "SettingsViewController.h"
#import "AccountConnectViewController.h"
#import "FeedbackViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
{
    BOOL            flag;   //判断是否清除缓存
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInformCenter:) name:NOTIFICATION_KEY_NOTICECENTER object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogoutNotification:) name:NOTIFICATION_KEY_LOGOUT object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_myTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myConstants = [Constants getSingleton];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:@"Arial" size:20]];
    titleLbl.text = @"设置";
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLbl;
    flag = NO;
    rp = [[RequestProxy alloc] init];
    rp.delegate = self;
    
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    AccountUser *user = [AccountUser getSingleton];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                ChangePersonInfoViewController *personInfo = [[ChangePersonInfoViewController alloc] init];
                personInfo.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personInfo animated:YES];
                personInfo = nil;
                break;
            }
            case 1:
            {
                TDCCardViewController *tdc = [[TDCCardViewController alloc] init];
                tdc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:tdc animated:YES];
                tdc = nil;
                break;
            }
            case 2:
            {
//                PersonShowWinViewController *personShow = [[PersonShowWinViewController alloc] init];
//                personShow.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:personShow animated:YES];
//                personShow = nil;
                
                DisplayWinManageViewController *displayView = [[DisplayWinManageViewController alloc]init];
                displayView.isClub = NO;
                displayView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:displayView animated:YES];
                break;
            }
            case 3:
            {
                InformCenterViewController *informCenter = [[InformCenterViewController alloc] init];
                informCenter.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:informCenter animated:YES];
                informCenter = nil;
                break;
            }
//            case 4:
//            {
//                [self scan];
//                break;
//            }
            default:
                break;
        }
    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
            {
                ChatSettingViewController *chatSetting = [[ChatSettingViewController alloc] init];
                chatSetting.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:chatSetting animated:YES];
                chatSetting = nil;
                break;
            }
            case 1:
            {
                PublicSettingViewController *publicSetting = [[PublicSettingViewController alloc] init];
                publicSetting.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:publicSetting animated:YES];
                publicSetting = nil;
                break;
            }
            case 2:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确认清除缓存及聊天记录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
                alert.tag = 103;
                [alert show];
                alert = nil;
                [self.myTable performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
                break;
            }
            default:
                break;
        }
    }else if (indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
            {
                AccountConnectViewController *accountCon = [[AccountConnectViewController alloc]initWithNibName:@"AccountConnectViewController" bundle:nil];
                accountCon.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:accountCon animated:YES];
                accountCon = nil;
                break;
            }
            
            default:
                break;
        }
    }else if (indexPath.section == 3){
        switch (indexPath.row) {
            case 0:
            {
                SettingAboutViewController *settingAbout = [[SettingAboutViewController alloc] init];
                settingAbout.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:settingAbout animated:YES];
                settingAbout = nil;
                break;
            }
            default:
                break;
        }
    }
    
//    AccountConnectViewController *accountCon;
//    FeedbackViewController *feedBack;
//    switch (indexPath.row) {
//        case 0:
//            [self.tabBarController.navigationController popViewControllerAnimated:YES];
//            self.tabBarController.navigationController.navigationBarHidden = NO;
//            break;
//        case 1:
//            accountCon = [[AccountConnectViewController alloc]initWithNibName:@"AccountConnectViewController" bundle:nil];
//            accountCon.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:accountCon animated:YES];
//            break;
//        case 2:
//        {
//            PersonInfoViewController *person = [[PersonInfoViewController alloc] initWithNumberID:@"100013"];
//            break;
//        }
//        case 3:
//            [self takePhoto];
//            break;
//        case 4:
//            break;
//        case 5:
//            feedBack = [[FeedbackViewController alloc]initWithNibName:@"FeedbackViewController" bundle:nil];
//            feedBack.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:feedBack animated:YES];
//            break;
//    }
//    if (indexPath.row == 1) {
//
//    }
    //帮助与反馈也是通过发送json的形式
}

/*
- (void)scan{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.videoQuality = 0;
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.cameraFlashMode = -1;
    ZBarImageScanner *scanner = reader.scanner;
    
    
    UIView *view = [[UIView alloc]initWithFrame:reader.view.frame];
    view.backgroundColor = [UIColor blackColor];
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    [self presentModalViewController: reader
                            animated: YES];
}
 */

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == alertView.tag) {
        if (1 == buttonIndex) {
            [self copy:qrText];
        }else{
            return;
        }
    }else if (101 == alertView.tag){
        if (1 == buttonIndex) {
            [[AccountUser getSingleton] clearUserInfo];
            [AccountUser getSingleton].isLogin = NO;
            //[[NoticeManager sharedNoticeManager] resetAllNotices];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [rp logout];
            
        }
        
    }else if (103 == alertView.tag){
        if (buttonIndex == 0) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[ChatListSaveProxy sharedChatListSaveProxy] removeAllFriend];
                [Utility clearCache];
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [hud removeFromSuperview];
                    
                    //[Utility showHUD:@"清除缓存成功"];
                });
            });
        }
    }
    return;
}

/*
-(void)copy:(NSString*)str {
    
    NSString *copyString = [[NSString alloc] initWithFormat:@"%@",str];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyString];
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
    NSLog(@"%@",symbol.data);
    NSString *s = [[Utility qrAnalyse:symbol.data] objectForKey:@"type"];
    if ( 2 == [s intValue]) {
        PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        personInfoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personInfoView animated:YES];
    }else if (1 == [s intValue]){
        ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        clubInfoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:clubInfoView animated:YES];
    }else{
        UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"] AndTitle:@"扫瞄二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
        alert.tag = 1;
        qrText = [[Utility qrAnalyse:symbol.data] objectForKey:@"id"];
    }
    
    [reader dismissModalViewControllerAnimated: YES];
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows = 0;
    switch (section) {
        case 0:
            rows = [myConstants.settingArr1 count];
            break;
        case 1:
            rows = [myConstants.settingArr2 count];
            break;
        case 2:
            rows = [myConstants.settingArr3 count];
            break;
        case 3:
            rows = [myConstants.settingArr4 count];
            break;
        default:
            break;
    }
    return rows;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"settingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier]  ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    }
    if (!(indexPath.section == 1 && indexPath.row == 2)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
    }
    NSString *cellStr = nil;
    switch (indexPath.section) {
        case 0:
            cellStr = [myConstants.settingArr1 objectAtIndex:indexPath.row];
            if (indexPath.row == 0) {
                if ([[AccountUser getSingleton].email isEqualToString:@""]||[AccountUser getSingleton].email == nil) {
                    UILabel *cirLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 14, 16, 16)];
                    cirLabel.layer.cornerRadius = 9;
                    cirLabel.backgroundColor = [UIColor redColor];
                    cirLabel.tag = 201;
                    [cell.contentView addSubview:cirLabel];
                    cirLabel = nil;
                }
            }
            break;
        case 1:
            cellStr = [myConstants.settingArr2 objectAtIndex:indexPath.row];
            break;
        case 2:
            cellStr = [myConstants.settingArr3 objectAtIndex:indexPath.row];
            break;
        case 3:
            cellStr = [myConstants.settingArr4 objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    cell.textLabel.text = cellStr;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        UIView *footView = [[UIView alloc] init];
        footView.frame = CGRectMake(0, 0, 320, 60);
        footView.backgroundColor = [UIColor clearColor];
        
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        logoutButton.frame = CGRectMake((320-105)/2, 12, 103, 36);
        UIImage *loginButtonImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login_login" ofType:@"png"]];
        [logoutButton setBackgroundImage:loginButtonImg forState:UIControlStateNormal];
        [logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
        logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [logoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:logoutButton];
        
        return footView;

    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 60;
    }else{
        return 0;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
//    if ([self isViewLoaded] && ![[self view] window])// 是否是正在使用的视图
//    {
//        [rp cancel];
//        rp = nil;
//        qrText = nil;
//        self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
//    }
}

#pragma mark -
#pragma mark  拍照或获取图片
-(void) takePhoto{
    DLCImagePickerController*  picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    picker = nil;
}

//#pragma mark -imagePickerController
//-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
//    NSLog(@"mediaType:%@",mediaType);
//    UIImage *image = [UIImage imageWithData:[info objectForKey:@"data"]];
//    [self dismissModalViewControllerAnimated:YES];
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)logout
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 101;
    alert.delegate = self;
    [alert show];
    alert = nil;
}

- (void)handleLogoutNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_LOGOUT object:nil];
    
//    self.tabBarController.navigationController.navigationBarHidden = NO;
//    [self.tabBarController.navigationController popToRootViewControllerAnimated:YES];
    
    AccountUser *user = [AccountUser getSingleton];
    [user clearUserInfo];
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    [ud removeObjectForKey:@"defaultPassword"];
    //[[NoticeManager sharedNoticeManager] resetAllNotices];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_LOGOUT]) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_LOGOUT object:nil];
        
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

- (void)showInformCenter:(NSNotification *)notification
{
    InformCenterViewController *informCenter = [[InformCenterViewController alloc] init];
    informCenter.noticeType = [[notification object] copy];
    //[informCenter checkAppearTable];
    informCenter.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:informCenter animated:YES];
    informCenter = nil;
}

@end
