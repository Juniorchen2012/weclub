//
//  ArticleInformView.m
//  WeClub
//
//  Created by Archer on 13-4-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ArticleInformView.h"

@implementation ArticleInformView

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
        _flag = 0;
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
    [_rp cancel];
    _rp = nil;
    _dataArray = nil;
    _lastFlag = nil;
}

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
    [_rp getInformWithType:@"2" total:@"10" last:_lastFlag];
    _flag = 1;
}

- (void)pullRequestData{
    if (_flag == 1) {
        return;
    }
    _lastFlag = @"0";
    UIView *view = [_tableView.infiniteScrollingView viewWithTag:301];
    [view removeFromSuperview];
    [_rp getInformWithType:@"2" total:@"10" last:_lastFlag];
    _flag = 1;
}

- (void)start
{
    if ([_dataArray count] == 0) {
        [self requestData];
    }
}

- (void)delPopDigest
{
    [_tableView reloadData];
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
    return [AtricleInformCell getCellHeight:[_dataArray objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    AtricleInformCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[AtricleInformCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
        if ([type isEqualToString:@"201"] || [type isEqualToString:@"204"]||[type isEqualToString:@"202"]) {
            if ([[dic objectForKey:@"isdel"] integerValue] == 1) {
                [Utility MsgBox:@"该文章已被删除"];
                return;
            }else{
                if ([type isEqualToString:@"202"] && [[dic objectForKey:@"nottop"] integerValue] == 1) {
                    [Utility MsgBox:@"该文章已被取消置顶"];
                    return;
                }
            }
            NSString *articleKey = [dic objectForKey:@"artkey"];
            ArticleDetailViewController *articleDetail = [[ArticleDetailViewController alloc] initWithArticleRowKey:articleKey];
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:@"1" forKey:@"informCenterArticlePush"];
            [ud synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_INFORMPUSH object:articleDetail];
        }else if ([type isEqualToString:@"203"]) {
            if ([[dic objectForKey:@"isdel"] integerValue] == 1) {
                [Utility MsgBox:@"该文章已被删除"];
                return;
            }else{
                if ([[dic objectForKey:@"notdig"] integerValue] == 1) {
                    [Utility MsgBox:@"该文章已被取消精华"];
                    return;
                }
            }
            NSString *articleKey = [dic objectForKey:@"artkey"];
            ArticleDetailViewController *articleDetail = [[ArticleDetailViewController alloc] initWithArticleRowKey:articleKey];
            articleDetail.isDigest = YES;
            articleDetail.informPushIndex = indexPath.row;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:@"1" forKey:@"informCenterArticlePush"];
            [ud synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_INFORMPUSH object:articleDetail];
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
    NSLog(@"article %@",msgArray);
    
    _flag = 0;
    [_tableView.infiniteScrollingView stopAnimating];
    [_tableView reloadData];
    
    NSDictionary *noticeDic = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"art", nil];
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
    [_rp clearNoticeWithType:@"2"];
}

#pragma mark - mixed
- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self mycutMixedString:str];
    
    float maxWidth = targetView.frame.size.width;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:15];
    
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 20);
                        btn.titleLabel.font = font;
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        
                        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
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
                                y += 20;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(x, y, subSize.width, 20);
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle:subString forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                            btn.titleLabel.font = font;
                            [targetView addSubview:btn];
                            x += subSize.width;

                            if (index < piece.length-1) {
                                x = 0;
                                y += 20;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 20);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        btn.titleLabel.font = font;
                        [targetView addSubview:btn];
                        x += subSize.width;
                    }                    
                }else{
                    if (x + 20 > maxWidth) {
                        x = 0;
                        y += 20;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, 20, 20);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    [targetView addSubview:imgView];
                    x += 20;
                    imgView = nil;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 20;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 20);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    btn.titleLabel.font = font;
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
                            y += 20;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 20);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:subString forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                        btn.titleLabel.font = font;
                        btn.userInteractionEnabled = NO;
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 20;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 20);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    btn.titleLabel.font = font;
                    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
    rect.size.height = y + 20;
    targetView.frame = rect;
}

- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    CGFloat height = view.frame.size.height;
    view = nil;
    return height;
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
        }
        pEnd++;
    }
    return range;
}

//切割字符串
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
    return returnArray;
}

@end
