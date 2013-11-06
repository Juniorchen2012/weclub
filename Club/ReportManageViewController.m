//
//  ReportManageViewController.m
//  WeClub
//
//  Created by chao_mit on 13-4-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ReportManageViewController.h"

@implementation ReportManageViewController
@synthesize isLoadMore;


-(void)viewWillDisappear:(BOOL)animated{
    [rp cancel];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_SHOW_LIST object:nil];
    [self stop];

}

-(id)initWithClubID:(NSString *)myClubID{
    self = [super init];
    if (self) {
        clubID = myClubID;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    if (firstAppear) {
        [myTable triggerPullToRefresh];
        firstAppear = NO;
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    list = [[NSMutableArray alloc]init];
    selectedList = [[NSMutableArray alloc]init];
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20) style:UITableViewStylePlain];
    myTable.delegate = self;
    myTable.dataSource = self;
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:myTable];
    __weak __block typeof(self)bself = self;
    __weak UITableView *blockTable = myTable;
    listType = 1;

    [myTable addPullToRefreshWithActionHandler:^{
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
    isLoadMore = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuListNotification:) name:NOTIFICATION_KEY_SHOW_LIST object:nil];
    firstAppear = YES;
}

#pragma mark - 请求代理
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_REPORT_LIST]) {
        startKey = [dic objectForKey:@"flag"];
        NSArray *dicList = [dic objectForKey:@"msg"];
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        [list addObjectsFromArray:dicList];
        [myTable reloadData];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];

        isLoadMore = NO;
    }else if ([type isEqualToString:URL_CLUB_REPORT_HANDLE]){
        [Utility showHUD:@"操作成功"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self loadData];
    }else if([type isEqualToString:URL_REPORT_DEL]){
        [Utility showHUD:@"记录移除成功"];
        [list removeObjectAtIndex:deleteNO.row];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [myTable deleteRowsAtIndexPaths:@[deleteNO] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_REPORT_HANDLE]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self loadData];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];

}
- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}
- (void)stop{
    [myTable.infiniteScrollingView stopAnimating];
    [myTable.pullToRefreshView stopAnimating];
}
#pragma mark - actionsheet代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *status;
    NSString *opType;
    if (0 == buttonIndex) {
        //拒绝
        status = @"2";
        opType = @"3";
    }else if (1 == buttonIndex){
        //删除文章
        status = @"2";
        opType = @"1";
    }else if (2 == buttonIndex){
            //删除文章并移除用户
            status = @"3";
            opType = @"2";
    }else if (3 == buttonIndex){
        return;
    }
    if (![selectedList count]) {
        [Utility MsgBox:@"您还没有选择要处理的举报信息！"];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:clubID forKey:KEY_ID];
    [dic setValue:status forKey:KEY_STATUS];
    [dic setValue:selectedList forKey:@"reportKey"];
    [dic setValue:opType forKey:@"opType"];
    [rp sendDictionary:dic andURL:URL_CLUB_REPORT_HANDLE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)operate{
    if (1 == listType) {
        UIActionSheet* ac;
             ac = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作"
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:@"忽略"
                                                   otherButtonTitles:@"删除文章",@"删除文章并移除该用户",nil];

        [ac showInView:self.view];
    }else{
        if ([menuBtn.titleLabel.text
             isEqualToString:@"编辑"]) {
            [myTable setEditing:YES animated:YES];
            [menuBtn setTitle:@"完成" forState:UIControlStateNormal];
        }else{
            [myTable setEditing:NO animated:YES];
            [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
        }
    }
}

-(void)loadData{
    NSString *startKeystring;
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]) {
            [myTable.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            return;
        }
    }else{
        startKeystring = @"0";
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:clubID forKey:KEY_ID];
    [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    [dic setValue:@"5" forKey:KEY_TOTAL];
    [dic setValue:[NSString stringWithFormat:@"%d",listType] forKey:KEY_STATUS];
    [dic setValue:startKeystring forKey:@"last"];
    [rp sendDictionary:dic andURL:URL_CLUB_REPORT_LIST andData:nil];
}

-(void)changeList:(int)indexNum{
//    UIButton *btn = (UIButton *)sender;
    if ([selectedList containsObject:[[list objectAtIndex:indexNum] objectForKey:@"reportKey"]]) {
        [selectedList removeObject:[[list objectAtIndex:indexNum] objectForKey:@"reportKey"]];
//        [btn setImage:[UIImage imageNamed:@"setting_chatSetting_unselect.png"] forState:UIControlStateNormal];
    }else{
        [selectedList addObject:[[list objectAtIndex:indexNum] objectForKey:@"reportKey"]];
//        [btn setImage:[UIImage imageNamed:@"setting_chatSetting_select.png"] forState:UIControlStateNormal];
    }
}

-(void)goPerson:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    PersonInfoViewController *reportedAuthor = [[PersonInfoViewController alloc]initWithUserName:[[list objectAtIndex:tap.view.tag] objectForKey:@"artPersonName"]];
    [self.navigationController pushViewController:reportedAuthor animated:YES];
}

-(void)goPerson2:(id)sender{
    UIButton *btn = (UIButton*)sender;
    PersonInfoViewController *reportedAuthor = [[PersonInfoViewController alloc]initWithUserName:btn.titleLabel.text];
    [self.navigationController pushViewController:reportedAuthor animated:YES];
}

-(void)goArticle:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    if ([[[list objectAtIndex:tap.view.tag] objectForKey:@"content"] isEqualToString:@"文章信息不存在"]) {
        [Utility showHUD:@"文章不存在"];
        return;
    }
    ArticleDetailViewController *article = [[ArticleDetailViewController alloc]initWithArticleRowKey:[[list objectAtIndex:tap.view.tag] objectForKey:@"articleKey"]];
    [self.navigationController pushViewController:article animated:YES];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"移除记录";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (1 ==listType) {
        return NO;
    }
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![list count]) {
        menuBtn.enabled = NO;
    }else{
        menuBtn.enabled = YES;
    }
    return [list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (listType == 2) {
//        return 115;
//    }
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    [Utility removeSubViews:cell.contentView];

    NSDictionary *dic = [list objectAtIndex:indexPath.row];
    //头像
    UIImageView *reportedAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    reportedAvatar.tag = indexPath.row;
    [Utility addTapGestureRecognizer:reportedAvatar withTarget:self action:@selector(goPerson:)];
    reportedAvatar.userInteractionEnabled = YES;
    [reportedAvatar setImageWithURL:USER_HEAD_IMG_URL(@"small", [dic objectForKey:@"artPersonPhoto"]) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    //被举报用户名
    UILabel *reportedAuthor = [[UILabel alloc]initWithFrame:CGRectMake(55, 0, 100, 20)];
    [Utility styleLbl:reportedAuthor withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
    reportedAuthor.text = [dic objectForKey:@"artPersonName"];
    UILabel *reportedArticle = [[UILabel alloc]initWithFrame:CGRectMake(55, 20, 200, 22)];
    [Utility styleLbl:reportedArticle withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
    NSString *str = [[dic objectForKey:@"content"] copy];
    [self attachString:str toView:reportedArticle];
    UILabel *reportedReason = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 140, 20)];
    [Utility styleLbl:reportedReason withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
    reportedReason.text = [NSString stringWithFormat:@"举报理由:%@",[dic objectForKey:@"reason"]];
    
    UILabel *reporteUserHint = [[UILabel alloc]initWithFrame:CGRectMake(120, 50, 70, 20)];
    [Utility styleLbl:reporteUserHint withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
    reporteUserHint.text = @"举报用户:";
    UILabel *reporteUser = [[UILabel alloc]initWithFrame:CGRectMake(200, 50, 150, 20)];
    [Utility styleLbl:reporteUser withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
    reporteUser.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"report_person"]];
    reporteUser.textColor = [UIColor blueColor];
    UILabel *reportedTM = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 200, 20)];
    
    UIButton *reportUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reportUserBtn.frame = CGRectMake(180, 50, 90, 20);
    reportUserBtn.contentHorizontalAlignment = UIControlContentVerticalAlignmentFill;
    [Utility styleLbl:reportUserBtn.titleLabel withTxtColor:nil withBgColor:nil withFontSize:14];
    [reportUserBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    reportUserBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"report_person"]];
    [reportUserBtn setTitle:[NSString stringWithFormat:@"%@",[dic objectForKey:@"report_person"]] forState:UIControlStateNormal];
    [reportUserBtn addTarget:self action:@selector(goPerson2:) forControlEvents:UIControlEventTouchUpInside];
    
    [Utility styleLbl:reportedTM withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
    reportedTM.text = [NSString stringWithFormat:@"举报时间:%@",[dic objectForKey:@"report_time"]];
    UILabel *processType = [[UILabel alloc]initWithFrame:CGRectMake(0, 90, 200, 20)];
    [Utility styleLbl:processType withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
//    if (listType == 2) {
//        if ([[dic objectForKey:@"opType"] intValue] == 1) {
//            processType.text = [NSString stringWithFormat:@"处理类型:删除文章"];
//        }else if ([[dic objectForKey:@"opType"] intValue] == 2){
//            processType.text = [NSString stringWithFormat:@"处理类型:删除文章并移除会员"];
//        }
//    }


    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(40, 5, 270, 90)];
    UIView *articleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    articleView.tag = indexPath.row;
    [articleView addSubview:reportedArticle];
    [articleView addSubview:reportedAuthor];
    [Utility addTapGestureRecognizer:articleView withTarget:self action:@selector(goArticle:)];
    [containerView addSubview:articleView];
    [containerView addSubview:reportedAvatar];
    [containerView addSubview:reportedReason];
    [containerView addSubview:reporteUserHint];
    [containerView addSubview:reportUserBtn];
    [containerView addSubview:reportedTM];
    [containerView addSubview:processType];

    if (1 == listType) {
        UIImageView *flagImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
        if ([selectedList containsObject:[[list objectAtIndex:indexPath.row] objectForKey:@"reportKey"]]) {
            [flagImg setImage:[UIImage imageNamed:@"setting_chatSetting_select.png"]];
        }else{
            [flagImg setImage:[UIImage imageNamed:@"setting_chatSetting_unselect.png"]];
        }
            [cell.contentView addSubview:flagImg];
    }
//    UIButton *flagbtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
//    flagbtn.backgroundColor = COLOR_RED;
//    flagbtn.tag = indexPath.row;
//    [flagbtn setImage:[UIImage imageNamed:@"setting_chatSetting_unselect.png"] forState:UIControlStateNormal];
//    [flagbtn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];

    [cell.contentView addSubview:containerView];
    return cell;
}

-(void)delReport{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:clubID forKey:@"clubId"];
    [dic setValue:[[list objectAtIndex:deleteNO.row] objectForKey:@"reportKey"] forKey:@"reportKey"];
    [rp sendDictionary:dic andURL:URL_REPORT_DEL andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (listType != 1) {
        [menuBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        deleteNO = indexPath;
        [self delReport];
        // Delete the row from the data source
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self changeList:indexPath.row];
    [myTable reloadData];
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
                        if (index < 0) {
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
                        if (index < 0) {
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
                            if (index < 0) {
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
                            [targetView addSubview:btn];
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
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
                        if (index < 0) {
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
                        if (index < 0) {
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
            NSRange range = [subString rangeOfString:@"]"];
            if (range.location != NSNotFound) {
                NSString *strPiece = [subString substringToIndex:range.location+1];
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
            
        }
        pEnd++;
    }
    if (pStart != pEnd) {
        NSString *strPiece = [str substringFromIndex:pStart];
        [returnArray addObject:strPiece];
    }
    
    return returnArray;
}


- (void)selectLinker:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    WeLog(@"linker:%@",str);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
}

- (void)selectLabel:(id)sender
{
    //    WeLog(@"选择######");
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    WeLog(@"%@",str);
    TopicArticleListViewController *topicArticleListView = [[TopicArticleListViewController alloc]initWithTopic:[str substringWithRange:NSMakeRange(1, [str length]-2)] withType:@"0"];
    [self.navigationController pushViewController:topicArticleListView animated:YES];
}

- (void)selectName:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    WeLog(@"%@",str);
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[str substringWithRange:NSMakeRange(1, [str length]-2)]];
    [self.navigationController pushViewController:personInfoView animated:YES];
}

- (void)showMenu:(id)sender
{
    if (_popOverMenu == nil) {
        ListNameTableView *menu = [[ListNameTableView alloc] initWithStyle:UITableViewStylePlain];
        _popOverMenu = [[FPPopoverController alloc] initWithViewController:menu];
        _popOverMenu.tint = FPPopoverDefaultTint;
        _popOverMenu.delegate = self;
        _popOverMenu.arrowDirection = FPPopoverArrowDirectionAny;
        
    }
    titleViewArrow.image = [UIImage imageNamed:@"title_down_arrow.png"];
    [_popOverMenu presentPopoverFromView:sender];
}

- (void)handleMenuListNotification:(NSNotification *)notification
{
    [_popOverMenu dismissPopoverAnimated:YES];
    
    NSNumber *index = notification.object;
    if (0 == [index intValue]) {
        [menuBtn setTitle:@"操作" forState:UIControlStateNormal];
//        menuBtn.hidden = NO;
    }else{
//        menuBtn.hidden = YES;
        [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    titleLbl.text = [[NSArray arrayWithObjects:@"未审批",@"已审批",@"已拒绝", nil] objectAtIndex:[index intValue]];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 44);
    titleViewArrow.frame = CGRectMake(labelsize.width, 13, 20, 20);
    titleViewArrow.image = [UIImage imageNamed:@"title_right_arrow.png.png"];
    listType = [index intValue]+1;
    [myTable setEditing:NO animated:YES];
    [self loadData];
}


#pragma mark -
#pragma mark 切换不同类型俱乐部列表
- (void)changeMYList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 0) {
        listType = 1;
    }else{
        listType = 3;
    }
    if (1 == listType) {
        [menuBtn setTitle:@"操作" forState:UIControlStateNormal];
        [myTable setEditing:NO];
        //        menuBtn.hidden = NO;
    }else{
        //        menuBtn.hidden = YES;
        [menuBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    [self loadData];
    titleLbl.text = [myConstants.reportTypeNames objectAtIndex:btn.tag];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 44);
    titleViewArrow.frame = CGRectMake(labelsize.width, 13, 20, 20);
    [self hideTitleViews];
    [myTable setEditing:NO animated:YES];
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

-(void)initNavigation{
    //titleView
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTitleViews)
                                                 name:@"HIDE_TITLEVIEWS" object:nil];
    UIView *title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 140, 44)];
    UIButton *titleView = [[UIButton alloc]initWithFrame:CGRectMake(25, 0, 150, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView addTarget:self action:@selector(showTitleViews) forControlEvents:UIControlEventTouchUpInside];
    
    titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 120, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"未审批";
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 44);
    titleViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"x.png"]];
    titleViewArrow.frame = CGRectMake(labelsize.width, 13, 20, 20);
    [titleView addSubview:titleLbl];
    [titleView addSubview:titleViewArrow];
    [title addSubview:titleView];
    self.navigationItem.titleView = title;
    
    titleViews = [[UIView alloc]initWithFrame:CGRectMake(80, 60, 160, [myConstants.reportTypeNames count]*40)];
    titleViews.backgroundColor = TINT_COLOR;
    holeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight)];

    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
    [menuBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    [menuBtn setTitle:@"操作" forState:UIControlStateNormal];
    [menuBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(operate) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem;
    
    for (int i = 0; i < [myConstants.reportTypeNames count]; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 40*i, 160, 40);
        btn.tag = i;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitle:[myConstants.reportTypeNames  objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeMYList:) forControlEvents:UIControlEventTouchUpInside];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(i+1), 160, 1)];
        line.backgroundColor = [UIColor blackColor];
        [titleViews addSubview:line];
        [titleViews addSubview:btn];
    }
    
    holeView.backgroundColor = [UIColor clearColor];
    [holeView addSubview:titleViews];
    [self.tabBarController.view addSubview:holeView];
    holeView.hidden = YES;
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
