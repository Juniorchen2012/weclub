//
//  ArticleViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ArticleViewController.h"

@interface ArticleViewController ()

@end

@implementation ArticleViewController
@synthesize isLoadMore;

- (id)init
{
    self = [super init];
    if (self) {
        self.mentionMeFlag = 0;
//        myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44-49)];
//        myTable.dataSource = self;
//        myTable.delegate = self;
//        [self.view addSubview:myTable];
    }
    return self;
}

- (void)dealloc
{
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (self.mentionMeFlag) {
        [self mentionMeArticle];
    }else{
//        [myTable reloadData];
        [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:animated];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    AudioPlay *audio = [AudioPlay getSingleton];
    [audio stop];
    [[AudioPlayer getSingleton] gotoWhenAudioPlaying];
    [[VideoPlayer getSingleton] VideoDownLoadCancel];
//    [rp cancel];
//    [self stop];
}

-(void)viewDidAppear:(BOOL)animated{
    [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }    [self initNavigation];
    [self initNavigation];
    articleList = [[NSMutableArray alloc]init];
    
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44-49)];
    myTable.dataSource = self;
    myTable.delegate = self;
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:myTable];
    
    for (int i = 0; i < [myConstants.articleListNames count]; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 40*i, 160, 40);
        btn.tag = i;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitle:[myConstants.articleListNames  objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(i+1), 160, 1)];
        line.backgroundColor = [UIColor blackColor];
        [titleViews addSubview:line];
        [titleViews addSubview:btn];
    }
    
    holeView.backgroundColor = [UIColor clearColor];
    [holeView addSubview:titleViews];
    [self.tabBarController.view addSubview:holeView];
    holeView.hidden = YES;
    listType = LIST_TYPE_NEARBY;
    
    __weak __block typeof(self)bself = self;
    __weak UITableView *blockTable = myTable;
    [myTable addPullToRefreshWithActionHandler:^{
        WeLog(@"触发下拉..");
        if (blockTable.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    [myTable addInfiniteScrollingWithActionHandler:^{
        WeLog(@"%d",blockTable.infiniteScrollingView.state);
        if (blockTable.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            
        }else{
            [blockTable.infiniteScrollingView stopAnimating];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAfterDelete:)
                                                 name:@"DELETE_ARTICLE_SUCCESS" object:nil];
    [[NoticeManager sharedNoticeManager] showNotice];
    videoPlay = [VideoPlayer getSingleton];
    if (self.mentionMeFlag) {
        [self mentionMeArticle];
    }else{
        [self loadData];
    }
    
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    NSArray *gotArray = [dic objectForKey:@"articleList"];
    if ([type isEqualToString:URL_ARTICLE_LIST]||[type isEqualToString:URL_ARTICLE_FOLLOW_LIST]||[type isEqualToString:URL_ARTICLE_ATME_LIST]||[type isEqualToString:URL_ARTICLE_NEARBY_LIST]){
        startKey = [dic objectForKey:KEY_STARTKEY];
        UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        tintLbl.backgroundColor = [UIColor clearColor];
        tintLbl.textColor = [UIColor grayColor];
        tintLbl.textAlignment = NSTextAlignmentCenter;
        myTable.tableFooterView = tintLbl;
        if (!isLoadMore) {
            [articleList removeAllObjects];
            [myTable setContentOffset:CGPointMake(0, 0)];

        }
        for (int i = 0; i < [gotArray count];i++) {
            Article *article = [[Article alloc]initWithDictionary:[gotArray objectAtIndex:i]];
            [articleList addObject:article];
        }
        if ([startKey isEqualToString:KEY_END]) {
            if (![articleList count]) {
                tintLbl.text = @"暂无文章";
            }else{
                tintLbl.text = @"已显示全部";
            }
        }else{
            tintLbl.text = @"上拉加载更多";
        }
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]) {
        //判断如果有权限在跳入新界面
        Club *club = [[Club alloc]init];
        club.ID = goClubArticle.articleClubID;
        club.type = [[dic objectForKey:@"opentype"] intValue];
        club.name = goClubArticle.articleClubName;
        club.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        club.isClosed = [dic objectForKey:@"isclose"];
        if ([club.isClosed intValue]) {
            [Utility MsgBox:@"该俱乐部已关闭"];
            return;
        }
        if (!club.type && club.userType == 0) {
            UIAlertView *alert = [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
            alert.tag = 4;
            return;

        }else{
            club.followThisClub = [[dic objectForKey:KEY_FOLLOW_THIS_CLUB] intValue];
            WeLog(@"是否关注该俱乐部%d",club.followThisClub);
            ClubViewController *clubView = [[ClubViewController alloc]init];
            clubView.club = club;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
            WeLog(@"登陆用户在该俱乐部的身份%d",club.userType);
            clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
            [self.navigationController pushViewController:clubView animated:YES];
        }
    }else if ([type isEqualToString:URL_CLUB_JOIN]){
        [Utility showHUD:@"申请成功"];
    }
    if (isLoadMore) {
        [myTable insertRowsAtIndexPaths:[Utility getIndexPaths:articleList withTable:myTable] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [myTable reloadData];
    }
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    isLoadMore =  NO;
    [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(void)stop{
    [myTable.infiniteScrollingView stopAnimating];
    [myTable.pullToRefreshView stopAnimating];
}

- (void)loadData{
    [rp cancel];
    if (0 == [[[NSUserDefaults standardUserDefaults] objectForKey:LOCATABLE] boolValue]) {
        if (0 == listType) {
            UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
            tintLbl.backgroundColor = [UIColor clearColor];
            tintLbl.textColor = [UIColor grayColor];
            tintLbl.textAlignment = NSTextAlignmentCenter;
            myTable.tableFooterView = tintLbl;
            tintLbl.text = @"无法获取到您的位置信息";
            [myTable reloadData];
            [self stop];
            return;
        }
    }
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [myTable.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            return;
        }
    }else{
        startKeystring = @"0";
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:COUNT_NUM forKey:KEY_COUNT];
    [dic setValue:startKeystring forKey:KEY_STARTKEY];
    if (4 == listType) {
        //我关注的文章
        postURL = URL_ARTICLE_FOLLOW_LIST;
        [dic setValue:[NSNumber numberWithInt:2] forKey:KEY_TYPE];
    }else if(5 == listType){
        //提到我的
        postURL = URL_ARTICLE_ATME_LIST;
    }else if(6 == listType){
        //加入俱乐部的
        postURL = URL_ARTICLE_LIST;
        [dic setValue:[NSNumber numberWithInt:4] forKey:KEY_TYPE];
    }else if(7 == listType){
        //我关注俱乐部的
        postURL = URL_ARTICLE_FOLLOW_LIST;
        [dic setValue:[NSNumber numberWithInt:3] forKey:KEY_TYPE];
    }else if(8 == listType){
        //关注用户的文章
        postURL = URL_ARTICLE_FOLLOW_LIST;
        [dic setValue:[NSNumber numberWithInt:0] forKey:KEY_TYPE];}
    else if(1 == listType || 2 == listType ||3 == listType){
        //我发表的 我回复的 回复我的 
        postURL = URL_ARTICLE_LIST;
        [dic setValue:[NSNumber numberWithInt:listType] forKey:KEY_TYPE];
    }else{
        postURL = URL_ARTICLE_NEARBY_LIST;
        if ([DeviceModel isEqualToString:@"iPhone Simulator"]) {
            myAccountUser.locationInfo = @"116.332574,39.971998";
        }
        [dic setValue:@"500" forKey:@"distance"];
        [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    }
    [rp sendDictionary:dic andURL:postURL andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
}

//跳到俱乐部页
- (void)goClub:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    goClubArticle = [articleList objectAtIndex:(tap.view.tag)];
    [dic setValue:goClubArticle.articleClubID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
}

#pragma mark -
#pragma mark 切换不同类型俱乐部列表
- (void)changeList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    listType = btn.tag;
    [articleList removeAllObjects];
    myTable.tableFooterView = nil;
    [self loadData];
    titleLbl.text = [myConstants.articleListNames objectAtIndex:btn.tag];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 24);
    titleViewArrow.frame = CGRectMake(labelsize.width, 2, 20, 20);
    [self resizeTitleView];
    [self hideTitleViews];
}

- (void)notificationChangeList:(NSNotification *)notification
{
    id sender = [notification object];
    [self changeList:sender];
}

- (void)mentionMeArticle
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.tag = 5;
    [self changeList:btn];
    self.mentionMeFlag = 0;
}

//调整导航栏
-(void)resizeTitleView{
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 24);
    titleViewArrow.frame = CGRectMake(labelsize.width, 2, 20, 20);
    titleView.frame = CGRectMake((320-labelsize.width-20)/2-90, 0,labelsize.width+20, 24);
}

//标题栏弹出隐藏处理
- (void)showTitleViews{
    titleViewArrow.image = [UIImage imageNamed:@"y.png"];
    [holeView.layer addAnimation:[Utility createAnimationWithType:kCATransitionReveal withsubtype:kCATransitionFromTop withDuration:0] forKey:@"animation"];
    holeView.hidden = NO;
}
//标题栏隐藏处理
- (void)hideTitleViews{
    titleViewArrow.image = [UIImage imageNamed:@"x.png"];
    holeView.hidden = YES;
    //[[EGOCache currentCache]clearCache];
//    [myTable reloadData];
}

-(void)refreshAfterDelete:(NSNotification *)notification{
    //删除是本地先删除不会自动刷新的
    //    [[articlelist objectAtIndex:listType] removeObjectAtIndex:[[notification.userInfo objectForKey:@"index"] intValue]];
    if (notification.object == self) {
        [articleList removeObjectAtIndex:articleToGo];
        WeLog(@"%d",[[notification.userInfo objectForKey:@"index"] intValue]);
        [myTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:articleToGo inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//        [myTable reloadData];
    }
}

//跳到主题文章页
-(void)goTopicArticle:(int)indexNum{
    Article *topicArticle = [articleList objectAtIndex:(indexNum)];
    if (![topicArticle.content length]) {
        [Utility showHUD:@"该文章已被删除!"];
        return;
    }
    articleToGo = indexNum;
    ArticleDetailViewController *articleDetailView = [[ArticleDetailViewController alloc]init];
    articleDetailView.indexNum = indexNum;
    articleDetailView.topicArticle = topicArticle;
    articleDetailView.lastViewController = self;
    articleDetailView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:articleDetailView animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self goTopicArticle:indexPath.row];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [articleList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *topicArticle = [articleList objectAtIndex:(indexPath.row)];
//    CGFloat contentHeight = [Utility getSizeByContent:topicArticle.content withWidth:250 withFontSize:18];
    CGFloat contentHeight = [self getMixedViewHeight:topicArticle.content];
//    CGFloat contentHeight = [Utility getMixedViewHeight:topicArticle.content withWidth:250];
    CGFloat cellHeight;
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
    }
    if (cellHeight < 80) {
        return 80;
    }
    return cellHeight;
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
            if ([piece hasPrefix:@"@"] ) {
                //@username
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    [btn setTitle:piece forState:UIControlStateNormal];
//                    [btn setTitleColor:nameColor forState:UIControlStateNormal];
//                    
//                    [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
//                    [targetView addSubview:btn];
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
//                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                        btn.frame = CGRectMake(x, y, subSize.width, 22);
//                        UILabel *subLabel = [[UILabel alloc] init];
//                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
//                        subLabel.text = subString;
//                        WeLog(@"ttt:%@",subString);
//                        subLabel.textColor = nameColor;
//                        subLabel.backgroundColor = [UIColor clearColor];
//                        [btn addSubview:subLabel];
//                        btn.backgroundColor = [UIColor clearColor];
//                        [btn setTitle:titleKey forState:UIControlStateNormal];
//                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//                        [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
//                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    UILabel *subLabel = [[UILabel alloc] init];
//                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
//                    subLabel.text = piece;
//                    WeLog(@"mmm:%@",piece);
//                    subLabel.textColor = nameColor;
//                    subLabel.backgroundColor = [UIColor clearColor];
//                    [btn addSubview:subLabel];
//                    [btn setTitle:titleKey forState:UIControlStateNormal];
//                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//                    [btn addTarget:self action:@selector(selectName:) forControlEvents:UIControlEventTouchUpInside];
//                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"#"] && [piece hasSuffix:@"#"] && piece.length>1){
                //#话题#
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    [btn setTitle:piece forState:UIControlStateNormal];
//                    [btn setTitleColor:labelColor forState:UIControlStateNormal];
//                    [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
//                    [targetView addSubview:btn];
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
//                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                        btn.frame = CGRectMake(x, y, subSize.width, 22);
//                        btn.backgroundColor = [UIColor clearColor];
//                        UILabel *subLabel = [[UILabel alloc] init];
//                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
//                        subLabel.text = subString;
//                        subLabel.textColor = labelColor;
//                        subLabel.backgroundColor = [UIColor clearColor];
//                        [btn addSubview:subLabel];
//                        [btn setTitle:titleKey forState:UIControlStateNormal];
//                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//                        [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
//                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    UILabel *subLabel = [[UILabel alloc] init];
//                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
//                    subLabel.text = piece;
//                    subLabel.textColor = labelColor;
//                    subLabel.backgroundColor = [UIColor clearColor];
//                    [btn addSubview:subLabel];
//                    [btn setTitle:titleKey forState:UIControlStateNormal];
//                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//                    [btn addTarget:self action:@selector(selectLabel:) forControlEvents:UIControlEventTouchUpInside];
//                    [targetView addSubview:btn];
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
//                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                        btn.frame = CGRectMake(x, y, subSize.width, 22);
//                        btn.backgroundColor = [UIColor clearColor];
//                        [btn setTitle:piece forState:UIControlStateNormal];
//                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        [targetView addSubview:btn];
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
//                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                            btn.frame = CGRectMake(x, y, subSize.width, 22);
//                            btn.backgroundColor = [UIColor clearColor];
//                            [btn setTitle:subString forState:UIControlStateNormal];
//                            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                            [targetView addSubview:btn];
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
//                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                        btn.frame = CGRectMake(x, y, subSize.width, 22);
//                        btn.backgroundColor = [UIColor clearColor];
//                        [btn setTitle:piece forState:UIControlStateNormal];
//                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                    }
                    
                }else{
                    if (x + 22 > maxWidth) {
                        x = 0;
                        y += 22;
                    }
//                    UIImageView *imgView = [[UIImageView alloc] init];
//                    imgView.frame = CGRectMake(x, y, 22, 22);
//                    imgView.backgroundColor = [UIColor clearColor];
//                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
//                    [targetView addSubview:imgView];
                    x += 22;
                }
                
            }else if ([piece hasPrefix:@"http://"]){
                //链接
                NSString *titleKey = piece;
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    [btn setTitle:piece forState:UIControlStateNormal];
//                    [btn setTitleColor:linkerColor forState:UIControlStateNormal];
//                    [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
//                    [targetView addSubview:btn];
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
//                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                        btn.frame = CGRectMake(x, y, subSize.width, 22);
//                        btn.backgroundColor = [UIColor clearColor];
//                        UILabel *subLabel = [[UILabel alloc] init];
//                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
//                        subLabel.text = subString;
//                        subLabel.textColor = linkerColor;
//                        subLabel.backgroundColor = [UIColor clearColor];
//                        [btn addSubview:subLabel];
//                        [btn setTitle:titleKey forState:UIControlStateNormal];
//                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//                        [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
//                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    UILabel *subLabel = [[UILabel alloc] init];
//                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
//                    subLabel.text = piece;
//                    subLabel.textColor = linkerColor;
//                    subLabel.backgroundColor = [UIColor clearColor];
//                    [btn addSubview:subLabel];
//                    [btn setTitle:titleKey forState:UIControlStateNormal];
//                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//                    [btn addTarget:self action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
//                    [targetView addSubview:btn];
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
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    [btn setTitle:piece forState:UIControlStateNormal];
//                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    btn.userInteractionEnabled = NO;
//                    [targetView addSubview:btn];
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
//                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                        btn.frame = CGRectMake(x, y, subSize.width, 22);
//                        btn.backgroundColor = [UIColor clearColor];
//                        [btn setTitle:subString forState:UIControlStateNormal];
//                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        btn.userInteractionEnabled = NO;
//                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
//                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                    btn.frame = CGRectMake(x, y, subSize.width, 22);
//                    btn.backgroundColor = [UIColor clearColor];
//                    [btn setTitle:piece forState:UIControlStateNormal];
//                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    btn.userInteractionEnabled = NO;
//                    [targetView addSubview:btn];
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
            NSRange range1 = [subString rangeOfString:@" "];
            NSRange range2 = [subString rangeOfString:@"#"];
            NSRange range3 = [subString rangeOfString:@"http://"];
            WeLog(@"NSFound3%dNSFound2%dNSFound1%d",range3.location,range2.location,range1.location);
            WeLog(@"min%d",[Utility minNum:range1.location andNum1:range2.location andNum2:range3.location]);
            int min = [Utility minNum:range1.location andNum1:range2.location andNum2:range3.location];
            if ( min != NSNotFound) {
                NSString *strPiece = [subString substringToIndex:min];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }else{
                [returnArray addObject:subString];
                pEnd += subString.length;
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
                    NSRange range1 = [subString rangeOfString:@"\n"];
                    if (range1.location != NSNotFound) {
                        NSString *strPiece = [subString substringToIndex:range1.location];
                        [returnArray addObject:strPiece];
                        pEnd += strPiece.length;
                        pStart = pEnd;
                        pEnd--;
                    }else if (range.location != NSNotFound) {
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




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"articleViewCell";
    ArticleCell  *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[ArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    Article *topicArticle = [articleList objectAtIndex:(indexPath.row)];
    cell.tag = indexPath.row;
    cell.postClubLbl.tag = indexPath.row;
    cell.postClubLbl.userInteractionEnabled = YES;
//    [Utility addTapGestureRecognizer:cell.postClubLbl withTarget:self action:@selector(goClub:)];
    [cell initCellWithArticle:topicArticle withViewController:self];
    return cell;
}

#pragma mark -
#pragma mark GridView Methods
- (NSInteger)numberOfCellsInGridView:(MMGridView *)gridView{
    return [articleList count];
}

//搜索
-(void)goSearch{
    ClubSearchViewController *searchView = [[ClubSearchViewController alloc]initWithSearchType:1];
    searchView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:searchView animated:YES];
}

-(UITableView *)getTable{
    return myTable;
}

-(void)initNavigation{
    //leftBarButtonItem
    UIButton *searchClubBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchClubBtn.frame = CGRectMake(0, 0, 30, 30);
    [searchClubBtn setBackgroundImage:[UIImage imageNamed:ICON_SEARCH] forState:UIControlStateNormal];
    [searchClubBtn addTarget:self action:@selector(goSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithCustomView:searchClubBtn];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    //titleView
    UIView *title = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 140, 24)];
    titleView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 24)];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView addTarget:self action:@selector(showTitleViews) forControlEvents:UIControlEventTouchUpInside];
    
    titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 24)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"附近的文章";
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 24);
    titleViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"x.png"]];
    titleViewArrow.frame = CGRectMake(labelsize.width, 2, 20, 20);
    titleViewArrow.backgroundColor = [UIColor clearColor];
    [titleView addSubview:titleLbl];
    [titleView addSubview:titleViewArrow];
    [title addSubview:titleView];
    self.navigationItem.titleView = title;
    
    titleViews = [[UIView alloc]initWithFrame:CGRectMake(80, 60, 160, [myConstants.articleListNames count]*40)];
    titleViews.backgroundColor = TINT_COLOR;
    holeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight)];
    [self resizeTitleView];
}

@end
