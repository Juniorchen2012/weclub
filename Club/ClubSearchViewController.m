//
//  ClubSearchViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-4.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubSearchViewController.h"

@interface ClubSearchViewController ()

@end

@implementation ClubSearchViewController

- (id)initWithSearchType:(int)myType
{
    self = [super init];
    if (self) {
        searchType = myType;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewDidAppear:(BOOL)animated{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initNavigation];
    mySearchBar = [[UISearchBar alloc] init];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    searchHistoryItems = [NSMutableArray arrayWithArray:[Utility getSearchHistory]];
    //可以加入搜索範圍選項scope
//    [mySearchBar setScopeButtonTitles:[NSArray arrayWithObjects:@"按名称",@"按ID",nil]];
    mySearchBar.delegate = self;
    mySearchBar.placeholder = @"输入俱乐部名或ID";
    if (searchType == 2) {
        mySearchBar.placeholder = @"输入用户名、ID或者Email";
    }
    
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 548) style:UITableViewStylePlain];
    [self.view addSubview:myTable];
    myTable.tableHeaderView = mySearchBar;
    
    mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    
//    [self setMySearchDisplayController:mySearchDisplayController];
    [mySearchDisplayController setDelegate:self];
    [mySearchDisplayController setSearchResultsDataSource:self];
    [mySearchDisplayController setSearchResultsDelegate:self];
    isLoadMore = NO;
    list = [[NSMutableArray alloc]init];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *topicArticle = [list objectAtIndex:(indexPath.row)];
    CGFloat contentHeight = [Utility getSizeByContent:topicArticle.content withWidth:250 withFontSize:18];
    
    //    CGFloat contentHeight = [Utility getSizeByContent:topicArticle.content withWidth:250 withFontSize:12];
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
        default:
            break;
    }
    if (cellHeight < 80) {
        return 80;
    }
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView   numberOfRowsInSection:(NSInteger)section {
//    NSInteger rows = 0;
    //如果当前列表只有一个的话就不用区分是不是searchResultsTableView了
//    if ([tableView    isEqual:self.searchDisplayController.searchResultsTableView]){
//        rows = [searchResults count];
//    }else{
//        rows = [searchHistoryItems count];
//    }
//    return rows;
    return [list count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]){
        WeLog(@"Press the %d result",indexPath.row);
        [self search:[myTable cellForRowAtIndexPath:indexPath].textLabel.text];
    }
}
// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /* Configure the cell. */
    if (!searchType) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView   dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault                   reuseIdentifier:CellIdentifier] ;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]){
            cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
        }else{
            
        }
        return cell;

    }else{
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
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate                                      predicateWithFormat:@"SELF contains[cd] %@",searchText];
    searchResults = [searchHistoryItems filteredArrayUsingPredicate:resultPredicate];
}

-(void)check{

}

-(void)search:(NSString *)name{
    if (0 == searchType) {
        //空格不进行搜索
        NSString *st = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![st length]) {
            return;
        }
        [self check];
        ClubSearchListViewController *clubSearchListView = [[ClubSearchListViewController alloc]initWithSearchName:st];
        [self.navigationController pushViewController:clubSearchListView animated:YES];
    }else if(1 == searchType){
        TopicArticleListViewController *topicArticleListView = [[TopicArticleListViewController alloc]initWithTopic:name withType:@"1"];
        [self.navigationController pushViewController:topicArticleListView animated:YES];
    }else if (2 == searchType){
        //只包含空格或者换行或空字符串不跳转
        NSString *st = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![st length]) {
            [mySearchBar setText:@""];
            return;
        }
        SuperUserListViewController *superUserList = [[SuperUserListViewController alloc] initWithNumberID:name andType:3];
        [self.navigationController pushViewController:superUserList animated:YES];
    }
}


-(BOOL)checkData:(NSString*)text{
    //名字长度暂定10
///^[a-zA-Z0-9\x{4e00}-\x{9fa5}\-\_\[\]]+$/u
    NSString * regex = @"^[a-zA-Z0-9\u4e00-\u9fa5-_]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:text];
    WeLog(@"isMatch%d",isMatch);
    return isMatch;
}
//点击搜索按钮
// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];//如果是在当前页显示就要在这个调用时，手动调用取消的方法
    NSString *searchKey = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [searchHistoryItems addObject:searchKey];
//    if (![[searchKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]]length]) {
//        [Utility MsgBox:@"搜索关键字不能为空!"];
//        return;
//    }
    
//    if (![self checkData:searchKey]) {
//        [Utility MsgBox:@"请不要包含除汉字.字母.数字.下划线以外的字符"];
//        return;
//    }
    


    if (![self checkExist:searchKey]) {
        [Utility storeSearchHistory:searchHistoryItems];
    }
    [self search:searchKey];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    
} // called when search results button pressed

#pragma mark UISearchBar and UISearchDisplayController Delegate Methods
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    //準備搜尋前，把上面調整的TableView調整回全屏幕的狀態，如果要產生動畫效果，要另外執行animation代碼
    //    self.myTableView.frame = CGRectMake(0, 0, 320, self.myTableView.frame.size.height);
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    //搜尋結束後，恢復原狀，如果要產生動畫效果，要另外執行animation代碼
    //    self.myTableView.frame = CGRectMake(60, 40, 260, self.myTableView.frame.size.height);
    return YES;
}

-(NSUInteger) unicodeLengthOfString: (NSString *) text {
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    NSUInteger unicodeLength = asciiLength / 2;
    if(asciiLength % 2) {
        unicodeLength++;
    }
    return unicodeLength;
}

//检查搜索的条目是否重复,重复返回1否则0
-(BOOL)checkExist:(NSString *)searchString{
    for (NSString * str in searchHistoryItems) {
        if ([str isEqualToString:searchString]) {
            return YES;
        }
    }
    return NO;
}

-(void)goClub:(int)indexNum{
    Club *club = [[Club alloc]initWithDictionary:[searchResults objectAtIndex:indexNum]];
//    [self checkAccess:indexNum];
    int userTypeTogo = indexNum % 5;//暂时为了测试放在这，然后，应该放在getresult中
    
    if (!club.type && userTypeTogo == 0) {
        [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!"];
        return;
    }
    srandom(time(0));
    ClubViewController *clubView = [[ClubViewController alloc]init];
    clubView.club = club;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
    club.userType = userTypeTogo;
    WeLog(@"当前登陆用户的身份是%@",[myConstants.userTypeNames objectAtIndex:club.userType]);
    WeLog(@"登陆用户在该俱乐部的身份%d",club.userType);
    clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:clubView animated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    //一旦SearchBar輸入內容有變化，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles]
      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    WeLog(@"searchString%@%d",searchString,[searchString length]);
//    NSData* aData = [searchString dataUsingEncoding: NSASCIIStringEncoding];
    WeLog(@"searchString length%d",[self unicodeLengthOfString:searchString]);
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //一旦Scope Button有變化，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles]
      objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([ZBarManager sharedZBarManager].scanFlag != 0) {
        return;
    }
    [ZBarManager sharedZBarManager].scanFlag++;
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *code =[(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            
            NSString *s = [[Utility qrAnalyse:code] objectForKey:@"type"];
            if ( 2 == [s intValue]) {
                PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:code] objectForKey:@"id"]];
                personInfoView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personInfoView animated:YES];
            }else if (1 == [s intValue]){
                ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:code] objectForKey:@"id"]];
                clubInfoView.isFromScan = YES;
                clubInfoView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:clubInfoView animated:YES];
            }else{
                UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:code] objectForKey:@"id"] AndTitle:@"扫瞄二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
                alert.tag = 1;
                qrText = [[Utility qrAnalyse:code] objectForKey:@"id"];
            }
            
            [[ZBarManager sharedZBarManager] back];
            break;
        }
    }
}


//执行扫瞄功能

- (void)scan{
    UINavigationController *reader = [[ZBarManager sharedZBarManager]getReaderWithDelegate:self helpStr:@"请扫描微俱二维码"];
    [ZBarManager sharedZBarManager].helpFlag = @"1";
    [self presentModalViewController:reader animated:YES];
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
}

//扫描后数据处理
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    WeLog(@"%@",symbol.data);
    NSString *s = [[Utility qrAnalyse:symbol.data] objectForKey:@"type"];
    if ( 2 == [s intValue]) {
        PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        personInfoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personInfoView animated:YES];
    }else if (1 == [s intValue]){
        ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        clubInfoView.isFromScan = YES;
        clubInfoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:clubInfoView animated:YES];
    }else{
        UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"] AndTitle:@"扫瞄二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
        alert.tag = 1;
        qrText = [[Utility qrAnalyse:symbol.data] objectForKey:@"id"];
    }
    
    [[ZBarManager sharedZBarManager] back];
}

//跳转到友情俱乐部页面
- (void)checkGoClub:(NSString *)clubID{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    Club *club = [[Club alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == alertView.tag) {
        if (1 == buttonIndex) {
            [self copy:qrText];             //拷贝信息到粘贴板
        }else{
            return;
        }
    }
    return;
}

-(void)initNavigation{
    //titleView
    if (0 == searchType) {
        self.title= @"俱乐部搜索";
        UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        scanBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
        [scanBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
        [scanBtn setImage:[UIImage imageNamed:@"scan_tdc.png"] forState:UIControlStateNormal];
        [scanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *menuItem = [[UIBarButtonItem alloc]initWithCustomView:scanBtn];
        self.navigationItem.rightBarButtonItem = menuItem;
    }else if(1 == searchType){
        self.title = @"文章搜索";
    }else if (2 == searchType){
        self.title = @"用户搜索";
    }
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = self.title;

    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
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
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
