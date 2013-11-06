//
//  ChatSettingViewController.m
//  WeClub
//
//  Created by Archer on 13-4-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChatSettingViewController.h"

@interface ChatSettingViewController ()

@end

@implementation ChatSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_rp cancel];
    _rp = nil;
    _tableView = nil;
    _state = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    //订制导航条
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"私聊权限";
    self.navigationItem.titleView = headerLabel;
    headerLabel = nil;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"btnbg.png"] forState:UIControlStateNormal];
    [saveBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    [saveBtn addTarget:self action:@selector(saveSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = btn;
    saveBtn = nil;
    btn = nil;

    self.view.backgroundColor = [UIColor whiteColor];
    
    _rp = [[RequestProxy alloc] init];
    _rp.delegate = self;
    
    _dataArray = [Constants getSingleton].chatSettingArr;

    NSString *private_letter = [AccountUser getSingleton].private_letter;
    if ([private_letter isEqualToString:@"1"]) {
        _selectIndex = 0;
    }else if ([private_letter isEqualToString:@"2"]){
        _selectIndex = 3;
    }else if ([private_letter isEqualToString:@"3"]){
        _selectIndex = 1;
    }else if ([private_letter isEqualToString:@"4"]){
        _selectIndex = 2;
    }else if ([private_letter isEqualToString:@"5"]){
        _selectIndex = 4;
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height) style:UITableViewStyleGrouped];
    _tableView.backgroundView.alpha = 0;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveSetting
{
    switch (_selectIndex) {
        case 0:
            _state = @"1";
            break;
        case 1:
            _state = @"3";
            break;
        case 2:
            _state = @"4";
            break;
        case 3:
            _state = @"2";
            break;
        case 4:
            _state = @"5";
            break;
        default:
            _state = @"1";
            break;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObject:_state forKey:@"private_letter"];
    [_rp changePrivacySetting:dic];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [AccountUser getSingleton].private_letter = _state;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"设置成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    alert = nil;
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self popViewController];
}

#pragma mark - UITableViewDateSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UILabel *info = [[UILabel alloc] init];
        info.frame = CGRectMake(15, 12, 110, 20);
        info.text = @"接受站内私聊:";
        info.tag = 101;
        info.backgroundColor = [UIColor clearColor];
        [cell addSubview:info];
        info = nil;
        
        UIImageView *selectView = [[UIImageView alloc] init];
        selectView.frame = CGRectMake(129, 15, 14, 14);
        selectView.tag = 102;
        selectView.backgroundColor = [UIColor clearColor];
        [cell addSubview:selectView];
        selectView = nil;

        UILabel *selectLabel = [[UILabel alloc] init];
        selectLabel.frame = CGRectMake(150, 12, 150, 20);
        selectLabel.textAlignment = NSTextAlignmentLeft;
        selectLabel.textColor = [UIColor grayColor];
        selectLabel.backgroundColor = [UIColor clearColor];
        selectLabel.tag = 103;
        [cell addSubview:selectLabel];
        selectLabel = nil;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0) {
        UIView *info = [cell viewWithTag:101];
        [info setHidden:NO];
    }else{
        UIView *info = [cell viewWithTag:101];
        [info setHidden:YES];
    }
    
    if (_selectIndex == 4) {
        if (indexPath.row == 1 || indexPath.row == 2) {
            UIImageView *selectView = (UIImageView *)[cell viewWithTag:102];
            selectView.image = [UIImage imageNamed:@"setting_chatSetting_select.png"];
        }else{
            UIImageView *selectView = (UIImageView *)[cell viewWithTag:102];
            selectView.image = [UIImage imageNamed:@"setting_chatSetting_unselect.png"];
        }
    }else{
        if (indexPath.row == _selectIndex) {
            UIImageView *selectView = (UIImageView *)[cell viewWithTag:102];
            selectView.image = [UIImage imageNamed:@"setting_chatSetting_select.png"];
        }else{
            UIImageView *selectView = (UIImageView *)[cell viewWithTag:102];
            selectView.image = [UIImage imageNamed:@"setting_chatSetting_unselect.png"];
        }

    }
    
    UILabel *selectLabel = (UILabel *)[cell viewWithTag:103];
    selectLabel.text = [_dataArray objectAtIndex:indexPath.row];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            _selectIndex = indexPath.row;
            break;
        }
        case 1:
        {
            if (_selectIndex == 2) {
                _selectIndex = 4;
            }else{
                _selectIndex = 1;
            }
            break;
        }
        case 2:
        {
            if (_selectIndex == 1) {
                _selectIndex = 4;
            }else{
                _selectIndex = 2;
            }
            break;
        }
        case 3:
        {
            _selectIndex = indexPath.row;
            break;
        }
        default:
            break;
    }
    [_tableView reloadData];
}

@end
