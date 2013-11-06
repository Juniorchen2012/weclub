//
//  TopicArticleListViewController.m
//  WeClub
//
//  Created by chao_mit on 13-4-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "TopicArticleListViewController.h"

@interface TopicArticleListViewController ()

@end

@implementation TopicArticleListViewController
@synthesize isLoadMore;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [[AudioPlayer getSingleton] gotoWhenAudioPlaying];
    [rp cancel];
    [self stop];

}

- (id)initWithTopic:(NSString *)topicStr withType:(NSString *)mysearchType
{
    self = [super init];
    if (self) {
        topicKey = topicStr;
        searchType = mysearchType;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    list = [[NSMutableArray alloc]init];
    [self loadData];
    __weak __block typeof(self)bself = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        WeLog(@"触发下拉..");
        if (bself.tableView.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        WeLog(@"触发上拉..");
        WeLog(@"%d",bself.tableView.infiniteScrollingView.state);
        if (bself.tableView.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            WeLog(@"执行上拉请求数据..");

        }else{
            [bself.tableView.infiniteScrollingView stopAnimating];
        }
    }];
}


- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_ARTICLE_TOPIC_SEARCH]) {
        NSArray *gotArray = [dic objectForKey:@"articleList"];
        startKey = [dic objectForKey:KEY_STARTKEY];
        WeLog(@"startKey%@",startKey);
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        for (int i = 0; i < [gotArray count];i++) {
            Article *article = [[Article alloc]initWithDictionary:[gotArray objectAtIndex:i]];
            [list addObject:article];
        }
        [self.tableView reloadData];
        WeLog(@"tableview加载完成..");
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        WeLog(@"都已停止加载完成..");
        isLoadMore = NO;
    }
}

-(void)stop{
    [self.tableView.infiniteScrollingView stopAnimating];
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self stop];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableView.pullToRefreshView stopAnimating];
    [self.tableView.infiniteScrollingView stopAnimating];
}

-(void)loadData{
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [self.tableView.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            return;
        }
    }else{
        startKeystring = @"0";
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    //type 1搜索文章 0搜索话题文章
    [dic setObject:searchType forKey:KEY_TYPE];
    [dic setObject:startKeystring forKey:KEY_STARTKEY];
    [dic setObject:topicKey forKey:@"key"];
    [dic setObject:COUNT_NUM forKey:KEY_COUNT];
    [rp sendDictionary:dic andURL:URL_ARTICLE_TOPIC_SEARCH andData:nil];
}

//跳到主题文章页
-(void)goTopicArticle:(int)indexNum{
    ArticleDetailViewController *articleDetailView = [[ArticleDetailViewController alloc]init];
    articleDetailView.title = @"文章内容";
    Article *topicArticle = [list objectAtIndex:(indexNum)];
    articleDetailView.indexNum = indexNum;
    articleDetailView.topicArticle = topicArticle;
    [self.navigationController pushViewController:articleDetailView animated:YES];
    [[AudioPlayer getSingleton] gotoWhenAudioPlaying];
}
#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self goTopicArticle:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [list count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *topicArticle = [list objectAtIndex:(indexPath.row)];
//    CGFloat contentHeight = [Utility getSizeByContent:topicArticle.content withWidth:250 withFontSize:18];
//    CGFloat contentHeight = [self getMixedViewHeight:topicArticle.content];
    CGFloat contentHeight = [Utility getMixedViewHeight:topicArticle.content withWidth:250];

    //    CGFloat contentHeight = [Utility getSizeByContent:topicArticle.content withWidth:250 withFontSize:12];
    CGFloat cellHeight = 0;
    switch ([topicArticle.articleStyle intValue]) {
        case ARTICLE_STYLE_WORDS:
            cellHeight = 5+20+contentHeight+5+60+17;//5+top_height+content_height+mediaView_height+bottom_height;
            if (![topicArticle.media count]) {
                cellHeight = 5+20+contentHeight+5+17;
            }
            break;
        case ARTICLE_STYLE_PIC:
            cellHeight = 5+110+20+contentHeight+5+17;
            break;
        case ARTICLE_STYLE_AUDIO:
            cellHeight = 5+30+20+contentHeight+5+17;
            break;
        case ARTICLE_STYLE_VIDEO:
            cellHeight = 5+110+20+contentHeight+5+17;
            break;
        default:
            break;
    }
    if (cellHeight < 80) {
        return 80;
    }
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"TopicArticleCell";
    ArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[ArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    Article *article = [list objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    [cell initCellWithArticle:article withViewController:self];    
    return cell;
}

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self cutMixedString:str];
//    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    UIColor *nameColor = [UIColor blueColor];
    UIColor *labelColor = [UIColor redColor];
    UIColor *linkerColor = [UIColor greenColor];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"@"] && [piece hasSuffix:@" "]) {
                //@username
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:nameColor forState:UIControlStateNormal];
                    
                    [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
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
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        UILabel *subLabel = [[UILabel alloc] init];
                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                        subLabel.text = subString;
                        WeLog(@"ttt:%@",subString);
                        subLabel.textColor = nameColor;
                        subLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:subLabel];
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:titleKey forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    UILabel *subLabel = [[UILabel alloc] init];
                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                    subLabel.text = piece;
                    WeLog(@"mmm:%@",piece);
                    subLabel.textColor = nameColor;
                    subLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:subLabel];
                    [btn setTitle:titleKey forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"#"] && [piece hasSuffix:@"#"] && piece.length>1){
                //#话题#
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:labelColor forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
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
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        UILabel *subLabel = [[UILabel alloc] init];
                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                        subLabel.text = subString;
                        subLabel.textColor = labelColor;
                        subLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:subLabel];
                        [btn setTitle:titleKey forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    UILabel *subLabel = [[UILabel alloc] init];
                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                    subLabel.text = piece;
                    subLabel.textColor = labelColor;
                    subLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:subLabel];
                    [btn setTitle:titleKey forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
                                y += 22;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(x, y, subSize.width, 22);
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle:subString forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                            [targetView addSubview:btn];
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                    }
                    
                }else{
                    if (x + 22 > maxWidth) {
                        x = 0;
                        y += 22;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, 22, 22);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    [targetView addSubview:imgView];
                    x += 22;
                }
                
            }else if ([piece hasPrefix:@"http://"] && [piece hasSuffix:@" "]){
                //链接
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:linkerColor forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
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
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        UILabel *subLabel = [[UILabel alloc] init];
                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                        subLabel.text = subString;
                        subLabel.textColor = linkerColor;
                        subLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:subLabel];
                        [btn setTitle:titleKey forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    UILabel *subLabel = [[UILabel alloc] init];
                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                    subLabel.text = piece;
                    subLabel.textColor = linkerColor;
                    subLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:subLabel];
                    [btn setTitle:titleKey forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 22;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:subString forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        btn.userInteractionEnabled = NO;
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
//    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

- (NSMutableArray *)cutMixedString:(NSString *)str
{
//    WeLog(@"str to be cut:%@",str);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int pStart = 0;
    int pEnd = 0;
    
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"@"]) {
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            WeLog(@"fuck substring:%@",subString);
            NSRange range = [subString rangeOfString:@" "];
            
            if (range.location != NSNotFound) {
                NSString *strPiece = [subString substringToIndex:range.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
            
        }else if ([a isEqualToString:@"#"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd+1];
            NSRange range = [subString rangeOfString:@"#"];
            if (range.location != NSNotFound) {
                NSString *strPiece = [NSString stringWithFormat:@"#%@",[subString substringToIndex:range.location+1]];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"["]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            NSRange range1 = [subString rangeOfString:@"["];
            NSRange range2 = [subString rangeOfString:@"]"];
            if (range2.location != NSNotFound && range2.location > range1.location) {
                NSString *strPiece = [subString substringToIndex:range2.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"h"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 9) {
                NSString *headStr = [subString substringToIndex:7];
//                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"http://"]) {
                    NSRange range = [subString rangeOfString:@" "];
                    if (range.location != NSNotFound) {
                        NSString *strPiece = [subString substringToIndex:range.location+1];
                        [returnArray addObject:strPiece];
                        pEnd += strPiece.length;
                        pStart = pEnd;
                        pEnd--;
                    }
                }
            }
            
        }else if ([a isEqualToString:@"\n"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 2) {
                NSString *headStr = [subString substringToIndex:1];
//                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"\n"]) {
                    
                    [returnArray addObject:headStr];
                    pEnd += headStr.length;
                    pStart = pEnd;
                    pEnd--;
                }
            }
        }
        pEnd++;
    }
    if (pStart != pEnd) {
        NSString *strPiece = [str substringFromIndex:pStart];
        [returnArray addObject:strPiece];
    }
    
    return returnArray;
}


- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(250, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    [self attachString:str toView:view];
    return view.frame.size.height;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initNavigation{
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = topicKey;
    
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLbl;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
}

@end
