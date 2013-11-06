//
//  AccountConnectViewController.m
//  WeClub
//
//  Created by chao_mit on 13-2-16.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "AccountConnectViewController.h"

@interface AccountConnectViewController ()

@end

@implementation AccountConnectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //titleView
        
        UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
        [titleLbl setFont:[UIFont fontWithName:@"Arial" size:20]];
        titleLbl.text = @"账号绑定";
        CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
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
        
        //手势操作
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
//        [self.view addGestureRecognizer:swipe];
        
        itemNames = [NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"QQ空间",@"人人网",@"Twitter",@"Google+",@"LinkedIn",@"Facebook", nil];
    }
    myTable.backgroundView = nil;
    myTable.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    myTable.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc
{
    myTable = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)accountCon:(id)sender{
    if (![Utility checkNetWork]) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([btn.titleLabel.text isEqualToString:@"绑定"]){
        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStylePopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
        [ShareSDK getUserInfoWithType:btn.tag
                     authOptions:authOptions
                          result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                              if (result){
                                  [userDefaults setObject:[userInfo nickname] forKey:[myConstants.shareTypeNames objectAtIndex:btn.superview.tag]];
                                  [myTable reloadData];
                             }
                             NSLog(@"%d:%@",[error errorCode], [error errorDescription]);
                            }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否取消绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 201;
        _btn = btn;
        [alert show];
        alert = nil;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 201) {
        if (buttonIndex == 1) {
            [ShareSDK cancelAuthWithType:_btn.tag];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:[myConstants.shareTypeNames objectAtIndex:_btn.superview.tag]];
            [myTable reloadData];
            [userDefaults synchronize];
        }
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [itemNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"accountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    UILabel *accountTypeName = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 20)];
    accountTypeName.backgroundColor = [UIColor clearColor];
    accountTypeName.text = [NSString stringWithFormat:@"%@:",[itemNames objectAtIndex:indexPath.row]];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.frame = CGRectMake(230, 5, 64, 32);
    UILabel *accountName = [[UILabel alloc]initWithFrame:CGRectMake(90, 10, 140, 20)];
    accountName.textColor = [UIColor grayColor];
    

    accountName.backgroundColor = [UIColor clearColor];
    switch (indexPath.row) {
        case 0:
            btn.tag = ShareTypeSinaWeibo;
            break;
        case 1:
            btn.tag = ShareTypeTencentWeibo;
            break;
        case 2:
            btn.tag = ShareTypeQQSpace;
            break;
        case 3:
            btn.tag = ShareTypeRenren;
            break;
        case 4:
            btn.tag = ShareTypeTwitter;
            break;
            //微信不需要绑定
//            btn.tag = ShareTypeWeixiSession;
        case 5:
            btn.tag = ShareTypeGooglePlus;
            break;
        case 6:
            btn.tag = ShareTypeLinkedIn;
            break;
        case 7:
            btn.tag = ShareTypeFacebook;
            break;
    }
    if ([userDefaults objectForKey:[myConstants.shareTypeNames objectAtIndex:indexPath.row]]) {
        accountName.text = [userDefaults objectForKey:[myConstants.shareTypeNames objectAtIndex:indexPath.row]];
    }else{
        accountName.text = @"尚未绑定";
    }

    [btn addTarget:self action:@selector(accountCon:) forControlEvents:UIControlEventTouchUpInside];
    if ([ShareSDK hasAuthorizedWithType:btn.tag]) {
        [btn setTitle:@"取消绑定" forState:UIControlStateNormal];
    }else{
        [btn setTitle:@"绑定" forState:UIControlStateNormal];
    }
    cell.contentView.tag = indexPath.row;
    [cell.contentView addSubview:accountTypeName];
    [cell.contentView addSubview:accountName];
    [cell.contentView addSubview:btn];
    accountTypeName = nil;
    accountName = nil;
    return cell;
}



- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
