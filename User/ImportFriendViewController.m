//
//  ImportFriendViewController.m
//  WeClub
//
//  Created by Archer on 13-5-9.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ImportFriendViewController.h"

@interface ImportFriendViewController ()

@end

@implementation ImportFriendViewController

@synthesize nextPageFlag = _nextPageFlag;
@synthesize isLoading = _isLoading;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _dataArray = [[NSMutableArray alloc] init];
        
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"关注好友";
    self.navigationItem.titleView = headerLabel;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 30);
    //[btn setTitle:@"全部关注" forState:UIControlStateNormal];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"login_login.png"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    //[btn addTarget:self action:@selector(followAllPerson) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(pushNextPage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 60, 30);
    [leftBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"login_login.png"] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [leftBtn addTarget:self action:@selector(pushNextPage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [leftBtn setHidden:YES];
    
    _importFriendList = [[NSMutableArray alloc] initWithCapacity:0];
    _importFriendIndex = 0;
    _nextPageFlag = @"0";
    
    
    __block typeof(self) bself = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        if (!bself.isLoading) {
            NSLog(@"pull to refresh...");
            bself.isLoading = YES;
            bself.nextPageFlag = @"0";
            [bself loadData];
        }
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (!bself.isLoading) {
            NSLog(@"load more...");
            if ([bself.nextPageFlag isEqualToString:@"end"]) {
                [bself.tableView.infiniteScrollingView stopAnimating];
                return;
            }
            bself.isLoading = YES;
            [bself loadData];
        }
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"我们将自动关注您在bbs上所关注的好友" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.tag = 101;
    [alert show];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
//    if ([_nextPageFlag isEqualToString:@"end"]) {
//        [self.tableView.infiniteScrollingView stopAnimating];
//        return;
//    }
    [_rp getImportFriendsWithPage:@"10" andStartKey:_nextPageFlag];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ImportFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ImportFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
    NSString *photo = [dic objectForKey:@"photo"];
    [cell.photoView setImageWithURL:USER_HEAD_IMG_URL(@"small", photo)];
    
    cell.nameLabel.text = [dic objectForKey:@"name"];
    
    NSNumber *flag = [dic objectForKey:@"flag"];
    cell.followButton.tag = indexPath.row;
    [cell.followButton addTarget:self action:@selector(followPerson:) forControlEvents:UIControlEventTouchUpInside];
    for (int i = 0; i < _importFriendList.count; i++) {
        if (indexPath.row == [(NSNumber *)[_importFriendList objectAtIndex:i] integerValue]) {
            if ([flag isKindOfClass:[NSNumber class]]) {
                if ([flag intValue] == 1) {
                    NSLog(@"已邀请");
                    [cell.followButton setTitle:@"已关注" forState:UIControlStateNormal];
                }else{
                    NSLog(@"已关注");
                    [cell.followButton setTitle:@"已关注" forState:UIControlStateNormal];
                }
                [cell.followButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            return cell;
        }
    }
    if ([flag isKindOfClass:[NSNumber class]]) {
        if ([flag intValue] == 1) {
            cell.isRegister.text = @"未注册";
            [cell.followButton setTitle:@"关注" forState:UIControlStateNormal];
        }else{
            cell.isRegister.text = @"已注册";
            [cell.followButton setTitle:@"关注" forState:UIControlStateNormal];
        }
    }
    [cell.followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
    PersonInfoViewController *person = [[PersonInfoViewController alloc] initWithUserName:[dic objectForKey:@"name"]];
    [self.navigationController pushViewController:person animated:YES];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_IMPORT_FRIEND]) {
        NSDictionary *dataDic = [dic objectForKey:@"data"];
        if ([dataDic isKindOfClass:[NSDictionary class]]) {
            NSArray *userListArray = [dataDic objectForKey:@"userlist"];
            if ([_nextPageFlag isEqualToString:@"end"]) {
                [self.tableView.pullToRefreshView stopAnimating];
                [self.tableView.infiniteScrollingView stopAnimating];
                [self.tableView reloadData];
                [self followAllPerson];
                _isLoading = NO;
                return;
            }
            if ([_nextPageFlag isEqualToString:@"0"]) {
                [_dataArray removeAllObjects];
                [self.tableView reloadData];
            }
            for (NSDictionary *dic in userListArray) {
                AccountUser *user = [AccountUser getSingleton];
                if ([[dic objectForKey:@"name"] isEqualToString:user.name]) {
                    NSLog(@"importFriend equal");
                    continue;
                }
                [_dataArray addObject:dic];
            }
            _nextPageFlag = [dataDic objectForKey:@"startKey"];
            [_rp getImportFriendsWithPage:@"10" andStartKey:_nextPageFlag];
        }
    }else if ([type isEqualToString:REQUEST_TYPE_FOLLOWPERSON]){
        [self.tableView reloadData];
        [Utility showHUD:@"关注成功"];
    }else if ([type isEqualToString:REQUEST_TYPE_FOLLOWPERSONS]){
        [self.tableView reloadData];
        [Utility showHUD:@"关注成功"];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    
}

- (void)followPerson:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag;
    for (int i = 0;i < _importFriendList.count;i++) {
        if (index == [(NSNumber *)[_importFriendList objectAtIndex:i] integerValue]) {
            return;
        }
    }
    [_importFriendList addObject:[NSNumber numberWithInt:index]];
    _importFriendIndex = index;
    if (index < [_dataArray count]) {
        NSDictionary *dic = [_dataArray objectAtIndex:index];
        NSString *numberid = [dic objectForKey:@"numberid"];
        if (numberid != nil) {
            [_rp followPerson:numberid];
            NSLog(@"follow numberid:%@",numberid);
        }
    }
}

//关注全部好友
- (void)followAllPerson
{
    NSLog(@"followAllPerson...");
    [_importFriendList removeAllObjects];
    for (int i = 0; i < _dataArray.count; i++) {
 //       [_importFriendIndexList addObject:[NSNumber numberWithInt:i]];
        [_importFriendList addObject:[NSNumber numberWithInt:i]];
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in _dataArray) {
        NSString *numberid = [dic objectForKey:@"numberid"];
        if ([numberid isKindOfClass:[NSString class]] && numberid != nil) {
            [array addObject:numberid];
        }
    }
    [_rp followPersons:array];
}

//跳过本页
- (void)pushNextPage
{
    NSLog(@"pushNextPage...");
    AccountUser *user = [AccountUser getSingleton];
    NSString *adoptFlag = user.adoptFlag;
    if (adoptFlag == nil || [adoptFlag isEqualToString:@"0"]) {
        UIAlertView *alert = [Utility MsgBox:@"是否创建俱乐部" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"否" AndOtherBtn:@"是" withStyle:0];
        alert.tag = 102;
        [alert show];
//        self.navigationController.navigationBarHidden = YES;
//        TabBarController *_tabC = [[TabBarController alloc] init];
//        
//        ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
//        [clubList newClub];
//        [self.navigationController pushViewController:_tabC animated:YES];
    }else{
        PostListViewController *postList = [[PostListViewController alloc] initWithType:2];
        [self.navigationController pushViewController:postList animated:YES];
    }

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            [self loadData];
        }
    }else if (alertView.tag == 102){
        
        if (0 == buttonIndex) {
            self.navigationController.navigationBarHidden = YES;
            TabBarController *_tabC = [[TabBarController alloc] init];
            [self.navigationController pushViewController:_tabC animated:YES];
        }else if (1 == buttonIndex){
            self.navigationController.navigationBarHidden = YES;
            TabBarController *_tabC = [[TabBarController alloc] init];
            
            ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
            [clubList newClub];
            [self.navigationController pushViewController:_tabC animated:YES];
        }
    }

}

@end
