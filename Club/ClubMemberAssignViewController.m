//
//  ClubMemberAssignViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-7.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubMemberAssignViewController.h"

@interface ClubMemberAssignViewController ()

@end

@implementation ClubMemberAssignViewController
@synthesize isLoadMore;

- (id)initWithClub:(Club *)myClub
{
    self = [super init];
    if (self) {
        club = myClub;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
//    [rp cancel];
//    [request cancelRequest];
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
    request = [[Request alloc]init];
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20) style:UITableViewStyleGrouped];
    myTable.backgroundView = nil;
    myTable.backgroundColor = [UIColor whiteColor];
    myTable.delegate = self;
    myTable.dataSource = self;
    deleteFlag = NO;
    
    //荣誉会员
    honorMemAddBtn =[[UIButton alloc]initWithFrame:CGRectMake(235, 10, 60, 30)];
    honorMemAddBtn.tag = 2;
    [honorMemAddBtn setTitle:@"添加" forState:UIControlStateNormal];
    [honorMemAddBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [honorMemAddBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchDown];

    honorMemTxt = [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 100, 30)];
    honorMemTxt.delegate = self;
    honorMemTxt.backgroundColor = [UIColor clearColor];
    honorMemTxt.placeholder = @"名称/ID";
    honorMemTxt.background = TXTFIELDBG;
    honorMemTxt.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    honorMemTxt.clearButtonMode = UITextFieldViewModeWhileEditing;
    honorMemberList = [[NSMutableArray alloc]init];

    [self refreshView];
    [self.view addSubview:myTable];
    [self loadHonorMember];
}


-(void)refresh:(NSDictionary *)dic{
    selectName = [dic objectForKey:KEY_NAME];
    currentTextField.text = [dic objectForKey:KEY_NAME];
    UIAlertView *alert;
    if ([operateType isEqualToString:@"01"]) {
        alert = [Utility MsgBox:[NSString stringWithFormat:@"确定将版主移交给%@,将会失去对俱乐部的管理权限",selectName] AndTitle:@"慎重提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
    }else if ([operateType isEqualToString:@"02"]){
        alert = [Utility MsgBox:[NSString stringWithFormat:@"确定将%@指定为版副",selectName] AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
    }else if ([operateType isEqualToString:@"13"]){
        
        alert = [Utility MsgBox:[NSString stringWithFormat:@"确定将%@指定为荣誉会员",selectName] AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
    }
    alert.tag = 1;
}

-(void)selectClubMember:(NSNotification *)notification{
    selectName = notification.object;
    currentTextField.text = notification.object;
    [self add];
}

-(void)refreshView{
    [viceAdminView removeFromSuperview];
    [honorMemView removeFromSuperview];
    honorMemView = [[UIView alloc]initWithFrame:CGRectMake(20, 35, 200, 40)];
    honorMemView.tag = 1;
  [self addViews:honorMemberList withView:honorMemView withImageSize:40 withSpace:10 ];
    if (USER_TYPE_ADMIN == club.userType) {
        viceAdminView = [[UIView alloc]initWithFrame:CGRectMake(20, 35, 200, 40)];
        viceAdminView.tag = 0;
        [self addViews:club.viceAdmins withView:viceAdminView withImageSize:40 withSpace:10];
    }
}

-(void)goPersonInfoView:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSString *name;
    if (1 == tap.view.superview.tag) {//为1是删除的荣誉会员
        name = [[honorMemberList objectAtIndex:tap.view.tag] objectForKey:KEY_NAME];
    }else if(0 == tap.view.superview.tag){//删除的版副
        name = [[club.viceAdmins objectAtIndex:tap.view.tag] objectForKey:KEY_NAME];
    }
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:name];
    [self.navigationController pushViewController:personInfoView animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //删除的确认
    if (0 == alertView.tag) {
        if (0 == buttonIndex) {
            return;
        }else{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
            [dic setValue:@"14" forKey:KEY_TYPE];
            [dic setValue:rowKey forKey:KEY_USER_ROW_KEY];
            [rp sendDictionary:dic andURL:URL_CLUB_MEMBER_UPDATE_TYPE andData:nil];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            return;
        }
    }else if (1 == alertView.tag){
        //指定版主版副
        if (0 == buttonIndex) {
            return;
        }else{
            [self add];
        }
    }
}

-(void)delete:(id)sender{
    UIButton *btn = (UIButton*)sender;
    UIAlertView *alert;
    toDelete = btn.tag;
    deleteFlag = YES;
    if (btn.superview.superview.tag) {//为1是删除的荣誉会员
        operateType = @"13";
        rowKey = [[honorMemberList objectAtIndex:btn.tag] objectForKey:@"numberid"];
        alert = [Utility MsgBox:[NSString stringWithFormat:@"确认取消%@荣誉会员",[[honorMemberList objectAtIndex:btn.tag] objectForKey:KEY_NAME]] AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确认" withStyle:0];
        alert.tag = 0;
    }else{//删除的版副
        operateType = @"02";
        alert = [Utility MsgBox:[NSString stringWithFormat:@"确认取消%@版副",[[club.viceAdmins objectAtIndex:btn.tag] objectForKey:KEY_NAME]] AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确认" withStyle:0];
        alert.tag = 0;
        rowKey = [[club.viceAdmins objectAtIndex:btn.tag] objectForKey:@"numberid"];
    }
}

-(void)goAdmin{
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[club.admin objectForKey:KEY_NAME]];
    [self.navigationController pushViewController:personInfoView animated:YES];
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_MEMBER_UPDATE_TYPE]){
        adminTxt.text = @"";
        viceAdminTxt.text = @"";
        honorMemTxt.text = @"";
        
        if ([operateType isEqualToString:@"01"]) {
            if (!deleteFlag) {
//                [Utility showHUD:@"版主指定成功"];
                [Utility showHUD:@"操作成功"];
            }
            [request getModerator:club.ID withDelegate:self];

            [request getUserType:club.ID withDelegate:self];
        }else if ([operateType isEqualToString:@"02"]){
            if (!deleteFlag) {
//                [Utility showHUD:@"版副指定成功"];
                [Utility showHUD:@"操作成功"];

            }else{
//                [Utility showHUD:@"删除版副成功"];
                [Utility showHUD:@"操作成功"];

            }
            [request getModerator:club.ID withDelegate:self];

        }else{
            if (!deleteFlag) {
//                [Utility showHUD:@"荣誉会员指定成功"];
                [Utility showHUD:@"操作成功"];

            }else{
//                [Utility showHUD:@"删除荣誉会员成功"];
                [Utility showHUD:@"操作成功"];

            }
            [self loadHonorMember];
        }
//        if ([operateType isEqualToString:@"13"]) {
//            [self loadHonorMember];
//        }else{
//            NSMutableDictionary *postDic = [[NSMutableDictionary alloc]init];
//            [postDic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
//            [rp sendDictionary:postDic andURL:URL_CLUB_GET_ADMINS andData:nil];
//        }
    
    }else if ([type isEqualToString:URL_CLUB_GET_ADMINS]){
            NSDictionary *adminsDic = [dic objectForKey:KEY_DATA];
            club.admin = [[adminsDic objectForKey:KEY_ADMIN] objectAtIndex:0];
            club.viceAdmins = [adminsDic objectForKey:KEY_VICE_ADMINS];
        [self loadHonorMember];
    }else if([type isEqualToString:URL_CLUB_HONOR_MEMBER_LIST]){
            honorMemberList = [dic objectForKey:KEY_DATA];
            WeLog(@"荣誉会员");
            for (NSDictionary *dic in honorMemberList) {
                [Utility printDic:dic];
            }
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]){
        club.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        [self back];
    }
    [self refreshView];
    [myTable reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)loadHonorMember{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_CLUB_HONOR_MEMBER_LIST andData:nil];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#define SINGLE_VIEW_SIZE 65
- (void)addViews:(NSArray *)list withView:(UIView *)containerView withImageSize:(CGFloat)size withSpace:(CGFloat)space{
    int i;
    for (i = 0; i < [list count]; i++) {
        //头像
        UIImageView *Logo = [[UIImageView alloc]init];
        Logo.tag = i;
        Logo.userInteractionEnabled = YES;
        [Logo setImageWithURL:USER_HEAD_IMG_URL(@"small", [[list objectAtIndex:i] objectForKey:@"photo"]) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
//        [Logo setFrame:CGRectMake((size+space)*(i%5), (i/5)*(size+space)+10, size, size)];
        [Logo setFrame:CGRectMake(0, 10, 40, 40)];
        [Utility addTapGestureRecognizer:Logo withTarget:self action:@selector(goPersonInfoView:)];
        
        //删除按钮
        UIButton* deleteIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteIcon setImage:[UIImage imageNamed:@"deleteIcon.png"] forState:UIControlStateNormal];
//        [deleteIcon setFrame:CGRectMake((size+space)*(i%5)+(size)-15, (i/5)*(size+space), 20, 20)];
        [deleteIcon setFrame:CGRectMake(30, 0, 20, 20)];
        deleteIcon.tag = i;
        [deleteIcon addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        
        //用户名
        UILabel *idLabel = [[UILabel alloc] init];
//        [idLabel setFrame:CGRectMake(Logo.frame.origin.x, Logo.frame.origin.y+Logo.frame.size.height, Logo.frame.size.width, 14)];
        [idLabel setFrame:CGRectMake(0, 50, 40, 15)];
        [Utility styleLbl:idLabel withTxtColor:nil withBgColor:nil withFontSize:12];
        idLabel.textAlignment = NSTextAlignmentCenter;
        idLabel.text = [[list objectAtIndex:i] objectForKey:KEY_NAME];
        
        UIView *singleView = [[UIView alloc]initWithFrame:CGRectMake(60*(i%4), 65*(i/4), 60, 65)];
        [singleView addSubview:Logo];
        [singleView addSubview:deleteIcon];
        [singleView addSubview:idLabel];
        [containerView addSubview:singleView];
//        [containerView addSubview:idLabel];
//        [containerView addSubview:Logo];
//        [containerView addSubview:deleteIcon];
    }
    [containerView setFrame:CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, 4*60, ((i-1)/4+1)*65)];
}

-(void)add{
//    UIButton *btn = (UIButton*)sender;
//    NSString *name;
//    deleteFlag = NO;
//    switch (btn.tag) {
//        case 0:
//            operateType = @"01";
//            name = adminTxt.text;
//            if(![[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]){
//                [Utility MsgBox:@"版主名称/ID不能为空!"];
//                return;
//            }
//            break;
//        case 1:
//            operateType = @"02";
//            name = viceAdminTxt.text;
//            if(![[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]){
//                [Utility MsgBox:@"版副名称/ID不能为空!"];
//                return;
//            }
//            break;
//        case 2:
//            operateType = @"13";
//            name = honorMemTxt.text;
//            if(![[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]){
//                [Utility MsgBox:@"荣誉会员名称/ID不能为空!"];
//                return;
//            }
//            break;
//    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:selectName forKey:KEY_USER_ROW_KEY];
    [dic setValue:operateType forKey:KEY_TYPE];
    [rp sendDictionary:dic andURL:URL_CLUB_MEMBER_UPDATE_TYPE andData:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    if (1 == club.userType) {
        //版主
        if (0 == indexPath.row) {
            return 100;
        }else if(1 == indexPath.row){
            if (![club.viceAdmins count]) {
                return 50;
            }
            return viceAdminView.frame.origin.y+viceAdminView.frame.size.height;
        }else if(2 == indexPath.row){
            if (![honorMemberList count]) {
                return 50;
            }
            return honorMemView.frame.origin.y+honorMemView.frame.size.height;
        }else{
            return 50;
        }
    }else if(2 == club.userType){
        //版副
        if (0 == indexPath.row){
            if (![honorMemberList count]) {
                return 50;
            }
            return honorMemView.frame.origin.y+honorMemView.frame.size.height;
        }else{
            return 50;
        }

    }
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (1 == club.userType) {
        //版主
        return 4;
    }
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ListViewController *listView = [[ListViewController alloc]init] ;
    listView.refreshDel = self;
    listView.club = club;
    listView.listType = 0;
    if (1 == club.userType) {
        //版主
        if (indexPath.row == 3) {
            
        }else if(indexPath.row == 0){
            listView.usedForMemberAssign = YES;
            operateType = @"01";
            listView.title = @"指定版主";

        }else if (indexPath.row == 1){
            if ([club.viceAdmins count] == 5) {
                [Utility showHUD:@"版副不能超过5个!"];
                return;
            }
            listView.usedForMemberAssign = YES;
            operateType = @"02";
            listView.title = @"指定版副";

        }else if(indexPath.row == 2){
            listView.usedForMemberAssign = YES;
            operateType = @"13";
            listView.title = @"指定荣誉会员";

        }
    }else{
        //版副
        if (indexPath.row == 1) {
            
        }else if(indexPath.row == 0){
            listView.usedForMemberAssign = YES;
            operateType = @"13";
            listView.title = @"指定荣誉会员";
        }
    }

    [self.navigationController pushViewController:listView animated:YES];
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
    UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 80, 18)];
    nameLbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:nameLbl];
    if (1 == club.userType) {
        if (0 == indexPath.row) {
            nameLbl.text = @"版       主:";
            adminLogo = [[UIImageView alloc]initWithFrame:CGRectMake(20, 35, 40, 40)];
            adminLogo.userInteractionEnabled = YES;
            UILabel *idLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 75, 60, 20)];
            [Utility styleLbl:idLabel withTxtColor:nil withBgColor:nil withFontSize:12];
            idLabel.text = [club.admin objectForKey:KEY_NAME];
            idLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:idLabel];
            [adminLogo setImageWithURL:USER_HEAD_IMG_URL(@"small", [club.admin objectForKey:@"photo"]) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
            [Utility addTapGestureRecognizer:adminLogo withTarget:self action:@selector(goAdmin)];
            [cell.contentView addSubview:adminLogo];
        }else if(1 == indexPath.row){
            nameLbl.text = @"版       副:";
            [cell.contentView addSubview:viceAdminView];
        }else if(2 == indexPath.row){
            nameLbl.text = @"荣誉会员:";
            [cell.contentView addSubview:honorMemView];
        }else{
            nameLbl.text = @"删除会员:";
            nameLbl.frame = CGRectMake(20, 15, 80, 18);
        }
    }else if(2 == club.userType){
        if(0 == indexPath.row){
            nameLbl.text = @"荣誉会员:";
            [cell.contentView addSubview:honorMemView];
        }else if(1 == indexPath.row){
            nameLbl.text = @"删除会员:";
            nameLbl.frame = CGRectMake(20, 15, 80, 18);
        }
    }
    return cell;
}

-(void)goMemberListView{
    ListViewController *listView = [[ListViewController alloc]init] ;
    listView.club = club;
    listView.listType = 0;
    listView.usedForMemberAssign = YES;
    [self.navigationController pushViewController:listView animated:YES];
    listView.title = @"俱乐部会员列表";
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"俱乐部成员指定";
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
}

#pragma mark -
#pragma mark not used
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    [self goMemberListView];
//    currentTextField = textField;
//    return NO;
//}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    if (iPhone5) {
//        return;
//    }
//    if (textField == honorMemTxt) {
//        myTable.frame = CGRectMake(0, -88, 320, 600);
//        [myTable setContentSize:CGSizeMake(320, 600)];
//        [myTable scrollRectToVisible:honorMemTxt.frame animated:YES];
//    }
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    if (iPhone5) {
//        return;
//    }
//    if (textField == honorMemTxt) {
//        myTable.frame = CGRectMake(0, 0, 320, myConstants.screenHeight-44-20);
//        [myTable scrollRectToVisible:honorMemTxt.frame animated:YES];
//    }
//}

-(void)back{
    [rp cancel];
    [request cancelRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
