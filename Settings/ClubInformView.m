//
//  ClubInformView.m
//  WeClub
//
//  Created by Archer on 13-4-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubInformView.h"

@implementation ClubInformView

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

- (void)requestData
{
    if ([_lastFlag isEqualToString:@"end"]) {
        UILabel *allLabel = [[UILabel alloc] init];
        allLabel.frame = CGRectMake(0, 0, _tableView.infiniteScrollingView.frame.size.width, _tableView.infiniteScrollingView.frame.size.height);
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
    [_rp getInformWithType:@"1" total:@"10" last:_lastFlag];
    _flag = 1;
}

- (void)pullRequestData{
    if (_flag == 1) {
        return;
    }
    _lastFlag = @"0";
    UIView *view = [_tableView.infiniteScrollingView viewWithTag:301];
    [view removeFromSuperview];
    [_rp getInformWithType:@"1" total:@"10" last:_lastFlag];
    _flag = 1;
}

- (void)start
{
    if ([_dataArray count] == 0) {
        [self requestData];
    }
}

- (void)dealloc
{
    _tableView = nil;
    [_rp cancel];
    _rp = nil;
    _dataArray = nil;
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
    return [ClubInformCell getCellHeight:[_dataArray objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    ClubInformCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ClubInformCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
        if ([type isEqualToString:@"101"]) {
            NSString *clubKey = [dic objectForKey:@"clubrowkey"];
            ApplyProcessViewController *applyProcess = [[ApplyProcessViewController alloc] initWithClubID:clubKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_INFORMPUSH object:applyProcess];
        }else if ([type isEqualToString:@"110"]){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.tag = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_JOINCLUBLIST object:btn];
            if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsClubFollow"]) {
                [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsClubFollow"];
            }
        }else if ([type isEqualToString:@"111"]){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.tag = 2;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"attention_club_list" object:btn];
            if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsClubAttention"]) {
                [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsClubAttention"];
            }
        }else if ([type isEqualToString:@"113"]){
            NSString *clubKey = [dic objectForKey:@"clubkey"];
            ClubViewController *clubView = [[ClubViewController alloc] init];
            Club *club1 = [[Club alloc] init];
            club1.ID = clubKey;
            clubView.club = club1;
            [[NoticeManager sharedNoticeManager] resetClubAdoptNoticeWithId:clubKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_INFORMPUSH object:clubView];
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
            [_dataArray addObject:[msgArray objectAtIndex:index]];
        }
    }
    
    NSLog(@"club   %@",msgArray);
    _flag = 0;

    [_tableView.infiniteScrollingView stopAnimating];
    [_tableView reloadData];
    
    NSDictionary *noticeDic = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"club", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_UPDATENOTICE object:noticeDic];
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
    [_rp clearNoticeWithType:@"1"];
    
}

- (NSRange)matching:(NSString *)str
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    int pStart = 1000;
    int pEnd = 0;
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"［"]) {
            pStart = pEnd;
        }else if ([a isEqualToString:@"］"]){
            if (pStart == 1000) {
                pEnd++;
                continue;
            }else{
                range = NSMakeRange(pStart, pEnd-pStart+1);
                break;
            }
        }else if ([a isEqualToString:@"\n"]){
            if (pStart == 1000) {
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

- (NSMutableArray *)mycutMixedString:(NSString *)str
{
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:0];
    NSRange range;
    while (1) {
        range = [self matching:str];
        if (range.location == NSNotFound) {
            break;
        }
        [returnArray addObject:[str substringToIndex:range.location]];
        [returnArray addObject:[str substringWithRange:range]];
        str = [str substringFromIndex:range.location + range.length];
    }
    if ([str length] > 0) {
        [returnArray addObject:str];
    }
    while (1) {
        if ([[returnArray lastObject] isEqualToString:@"/n"]) {
            [returnArray removeObjectAtIndex:(returnArray.count - 1)];
        }else{
            break;
        }
    }
    return returnArray;
}

@end
