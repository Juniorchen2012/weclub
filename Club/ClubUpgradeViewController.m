//
//  ClubUpgradeViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-5.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubUpgradeViewController.h"

@interface ClubUpgradeViewController ()

@end

@implementation ClubUpgradeViewController
@synthesize club;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

-(void)viewWillAppear:(BOOL)animated{
    [request checkMoneyWithDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [rp cancel];
    [request cancelRequest];
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
    [self refreshView];
}

-(void)refreshView{
    [infoLbl removeFromSuperview];
    [borderView removeFromSuperview];
    infoLbl = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 290, 40)];
    [infoLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    infoLbl.numberOfLines = 2;
    infoLbl.text = [NSString stringWithFormat:@"本俱乐部目前会员容量为%@个，为%@，您目前拥有%@个伪币。",club.maxMemberCount,[myConstants.clubTypeNames objectAtIndex:club.type],myAccountUser.money];
    [self.view addSubview:infoLbl];
    
    borderView = [[UIView alloc]init];
    borderView.layer.cornerRadius = 5;
    borderView.layer.borderColor = [[UIColor grayColor]CGColor];
    borderView.layer.masksToBounds = YES;
    borderView.layer.borderWidth = 1.0;
    
    
    UIButton *memberUpgradeBtn = [[UIButton alloc]initWithFrame:CGRectMake(220, 40, 60, 25)];
    memberUpgradeBtn.tag = 0;
    [memberUpgradeBtn setTitle:@"升级" forState:UIControlStateNormal];
    [memberUpgradeBtn addTarget:self action:@selector(toUpgrade:) forControlEvents:UIControlEventTouchUpInside];
    [memberUpgradeBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [borderView addSubview:memberUpgradeBtn];
    
    UILabel *memberChangeLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 180, 15)];
    memberChangeLbl.text = @"俱乐部会员容量升级20人";
    [memberChangeLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    [borderView addSubview:memberChangeLbl];
    
    UILabel *numberCoinLbl = [[UILabel alloc]initWithFrame:CGRectMake(240, 10, 60, 15)];
    [numberCoinLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    if (club.type) {
        numberCoinLbl.text = @"$40";
    }else{
        numberCoinLbl.text = @"$20";
    }
    [borderView addSubview:numberCoinLbl];
    
    WeLog(@"ClubType%d",club.type);
    //根据俱乐部类型布局
    if (club.type) {
        borderView.frame = CGRectMake(15, 60, 290, 70);
    }else{
        borderView.frame = CGRectMake(15, 60, 290, 140);
        UILabel *typeChangeLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 240, 20)];
        typeChangeLbl.text = @"俱乐部类型从公开升级为私密";
        [typeChangeLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
        [borderView addSubview:typeChangeLbl];
        
        UIButton *memberUpgradeBtn = [[UIButton alloc]initWithFrame:CGRectMake(220, 110, 60, 25)];
        memberUpgradeBtn.tag = 1;
        [memberUpgradeBtn setTitle:@"升级" forState:UIControlStateNormal];
        [memberUpgradeBtn addTarget:self action:@selector(toUpgrade:) forControlEvents:UIControlEventTouchUpInside];
        [memberUpgradeBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        [borderView addSubview:memberUpgradeBtn];
        
        UILabel *coinLbl = [[UILabel alloc]initWithFrame:CGRectMake(240, 70, 60, 20)];
        [coinLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
        coinLbl.text = [NSString stringWithFormat:@"$100"];
        [borderView addSubview:coinLbl];
    }
    [self.view addSubview:borderView];
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_CHANGE_TO_PRIVATE]) {
        club.type = 1;
        [SVProgressHUD dismiss];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utility showHUD:@"升级成功"];
        [request checkMoneyWithDelegate:self];
    }else if ([type isEqualToString:URL_CLUB_CHANGE_NUMBER]){
        club.maxMemberCount = [NSString stringWithFormat:@"%d",[club.maxMemberCount intValue]+20];
        [SVProgressHUD dismiss];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utility showHUD:@"升级成功"];
        [request checkMoneyWithDelegate:self];
    }else if ([type isEqualToString:URL_USER_GET_MONEY]) {
        myAccountUser.money = [dic objectForKey:@"money"];
        infoLbl.text = [NSString stringWithFormat:@"本俱乐部目前会员容量为%@个，为%@，您目前拥有%@个伪币。",club.maxMemberCount,[myConstants.clubTypeNames objectAtIndex:club.type],myAccountUser.money];
    }
    [self refreshView];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_CHANGE_TO_PRIVATE]) {
        
    }else if ([type isEqualToString:URL_CLUB_CHANGE_NUMBER]){
        
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        [self upgrade:alertView.tag];
    }else{
        return;
    }
}

-(void)toUpgrade:(id)sender{
    UIButton *btn = (UIButton*)sender;
    UIAlertView *alert;
    if (btn.tag) {
        alert = [Utility MsgBox:@"确定将俱乐部转为私密俱乐部，该过程不可逆转" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
    }else{
        alert = [Utility MsgBox:@"确定对俱乐部进行扩容" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
    }
    alert.tag = btn.tag;
}

-(void)upgrade:(int)tag{
    NSString *postURL;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];

    if (tag) {
        postURL = URL_CLUB_CHANGE_TO_PRIVATE;
        if ([myAccountUser.money intValue]<100) {
            [Utility MsgBox:@"伪币不足，无法升级"];
            return;
        }
        //公开转私密
    }else{
        postURL = URL_CLUB_CHANGE_NUMBER;
        [dic setValue:@"20" forKey:@"addnumber"];
        //会员人数升级
        if ([myAccountUser.money intValue]<20) {
            [Utility MsgBox:@"伪币不足，无法升级"];
            return;
        }
    }
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:postURL andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title =  @"俱乐部升级";
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    WeLog(@"%@",[NSString stringWithFormat:@"%@%@",textField.text,string]);
//    if ([[NSString stringWithFormat:@"%@%@",textField.text,string] intValue]>[club.memberCount intValue]) {
//            numberCoinLbl.text = [NSString stringWithFormat:@"$%d",([textField.text intValue]-[club.memberCount intValue])*1];
//    }
//    
//    return YES;
//}

@end
