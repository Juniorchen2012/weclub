//
//  UserInformView.m
//  WeClub
//
//  Created by Archer on 13-4-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "UserInformView.h"

@implementation UserInformView

@synthesize rp = _rp;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = [UIColor clearColor];
        [self addSubview:_tableView];
        
        _dataArray = [[NSMutableArray alloc] init];
        
        _rp = [[RequestProxy alloc] init];
        _rp.delegate = self;
        
        _lastFlag = @"0";
        
        __weak __block typeof(self) bself = self;
        [_tableView addInfiniteScrollingWithActionHandler:^{
            [bself requestData];
        }];
        [_tableView addPullToRefreshWithActionHandler:^{
            [bself pullRequestData];
        }];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)dealloc
{
    _tableView = nil;
    _dataArray = nil;
    _rp = nil;
}

- (void)requestData
{
    if ([_lastFlag isEqualToString:@"end"]) {
        UILabel *allLabel = [[UILabel alloc] init];
        allLabel.frame = CGRectMake(0, 10, _tableView.infiniteScrollingView.frame.size.width, _tableView.infiniteScrollingView.frame.size.height);
        allLabel.backgroundColor = [UIColor whiteColor];
        allLabel.text = @"已显示全部";
        allLabel.tag = 301;
        allLabel.textColor = [UIColor grayColor];
        allLabel.textAlignment = NSTextAlignmentCenter;
        allLabel.font = [UIFont systemFontOfSize:20];
        [_tableView.infiniteScrollingView addSubview:allLabel];
        allLabel = nil;
        return;
    }
    if (_flag == 1) {
        return;
    }
    [_rp getInformWithType:@"3" total:@"10" last:_lastFlag];
    _flag = 1;
}

- (void)pullRequestData{
    if (_flag == 1) {
        return;
    }
    _lastFlag = @"0";
    UIView *view = [_tableView.infiniteScrollingView viewWithTag:301];
    [view removeFromSuperview];
    [_rp getInformWithType:@"3" total:@"10" last:_lastFlag];
    _flag = 1;
}

- (void)start
{
    if ([_dataArray count] == 0) {
        [self requestData];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
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

    return [UserInformCell getCellHeight:[_dataArray objectAtIndex:indexPath.row]];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UserInformCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UserInformCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
    [cell setWithDic:dic];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_dataArray objectAtIndex:indexPath.row];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSString *type = [dic objectForKey:@"type"];
        if ([type isEqualToString:@"301"]) {
            //关注跳转
            TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
            [_tabC followMeUser];
        }else if ([type isEqualToString:@"304"]){
            //私信跳转
            FriendModel *friend = [[FriendModel alloc] init];
            friend.name = [dic objectForKey:@"username"];
            friend.masterID = [AccountUser getSingleton].numberID;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_ADDFRIEND object:friend];
            friend = nil;
        }else if ([type isEqualToString:@"320"]){
            TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
            [_tabC iFollowUser];
            if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsUserAttention"]) {
                [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsUserAttention"];
            }

        }else if ([type isEqualToString:@"321"]){
            TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
            [_tabC followMeUser];
            if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsUserFollow"]) {
                [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsUserFollow"];
            }
            
        }else if ([type isEqualToString:@"306"]){
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            btn.tag = 5;
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_MENTIONME object:btn];
            TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
            [_tabC mentionMeAtricle];
        }else if ([type isEqualToString:@"307"]){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.tag = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_JOINCLUBLIST object:btn];
        }else if ([type isEqualToString:@"309"]){
            InviteProcessViewController *invite = [[InviteProcessViewController alloc] init];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"informCenterUserPush"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_INFORMPUSH object:invite];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"beginScroll" object:nil];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _tableView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endScroll" object:nil];
    }
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    //    if ([type isEqualToString:REQUEST_TYPE_USERINFO]) {
    //        NSDictionary *oneDic = [dic objectForKey:@"msg"];
    //        NSString *photoId = [oneDic objectForKey:@"photo"];
    //        NSLog(@"%@",[[oneDic objectForKey:@"name"]);
    //        for (NSMutableDictionary *mudic in _dataArray) {
    //            if ([[oneDic objectForKey:@"name"] isEqualToString:[mudic objectForKey:@"username"]]) {
    //                NSLog(@"add");
    //                [mudic setObject:photoId forKey:@"photoId"];
    //                break;
    //            }
    //        }
    //        [_tableView reloadData];
    //        NSLog(@"user  %@",_dataArray);
    //
    //        return;
    //    }
    [_tableView.pullToRefreshView stopAnimating];
    _tableView.pullToRefreshView.lastUpdatedDate = [NSDate date];
    if ([type isEqualToString:REQUEST_TYPE_CLEAR_NOTICE]) {
        _lastFlag = @"0";
        [_dataArray removeAllObjects];
        [_tableView reloadData];
        return;
    }
    if ([_lastFlag isEqualToString:@"0"]) {
        [_dataArray removeAllObjects];
    }
    NSString *flag = [dic objectForKey:@"flag"];
    if ([flag isEqualToString:@"0"]) {
        _lastFlag = @"end";
    }else{
        _lastFlag = flag;
    }
    
    NSArray *msgArray = [dic objectForKey:@"msg"];
    if (msgArray.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_unclick" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_click" object:nil];
    }
    if ([msgArray isKindOfClass:[NSArray class]]) {
        for (int index = 0; index<[msgArray count]; index++) {
            // NSString *name = [[msgArray objectAtIndex:index] objectForKey:@"username"];
            // [_rp getUserInfoByKey:@"username" andValue:name];
            [_dataArray addObject:[msgArray objectAtIndex:index]];
        }
    }
    _flag = 0;

    [_tableView.infiniteScrollingView stopAnimating];
    [_tableView reloadData];
    
    NSDictionary *noticeDic = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"user", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_UPDATENOTICE object:noticeDic];
    noticeDic = nil;
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [_tableView.pullToRefreshView stopAnimating];
    [_tableView.infiniteScrollingView stopAnimating];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [_tableView.pullToRefreshView stopAnimating];
    [_tableView.infiniteScrollingView stopAnimating];
}

- (void)clearNotice
{
    [_rp clearNoticeWithType:@"3"];
}

@end
