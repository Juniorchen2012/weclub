//
//  InviteProcessViewController.m
//  WeClub
//
//  Created by chao_mit on 13-5-14.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "InviteProcessViewController.h"

@interface InviteProcessViewController ()

@end

@implementation InviteProcessViewController
@synthesize isLoadMore;


-(void)viewWillDisappear:(BOOL)animated{

    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    list = [[NSMutableArray alloc] init];
    
    __weak __block typeof(self)bself = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        if (bself.tableView.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself loadData];
        }
    }];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        WeLog(@"%d",bself.tableView.infiniteScrollingView.state);
        if (bself.tableView.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
            
        }else{
            [bself.tableView.infiniteScrollingView stopAnimating];
        }
    }];
    [self loadData];
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_USER_CLUBINVITE_LIST]) {
        UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        tintLbl.backgroundColor = [UIColor clearColor];
        tintLbl.textColor = [UIColor grayColor];
        tintLbl.textAlignment = NSTextAlignmentCenter;
        self.tableView.tableFooterView = tintLbl;
        NSArray *dicList = [[dic objectForKey:KEY_DATA] objectForKey:@"clublist"];


        startKey = [[dic objectForKey:KEY_DATA] objectForKey:KEY_STARTKEY];
        WeLog(@"startKey%@",startKey);
        if (!isLoadMore) {
            [list removeAllObjects];
        }
        [list addObjectsFromArray:dicList];
        if ([[[dic objectForKey:KEY_DATA] objectForKey:KEY_STARTKEY] isEqualToString:KEY_END]) {
            if ([list count]) {
                tintLbl.text = @"已显示全部";
            }else{
                tintLbl.text = @"没有邀请要处理";
            }
        }else{
            tintLbl.text = @"上拉加载更多";
        }
        [self.tableView reloadData];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    }else if ([type isEqualToString:URL_USER_CLUBINVITE_OPERATE]){
        [list removeObjectAtIndex:operateNO];
        if (operateType==0 || operateType == 3) {
            if (operateType == 3) {
                [list removeAllObjects];
            }
            [Utility showHUD:@"接受申请成功"];
        }else{
            [Utility showHUD:@"拒绝申请成功"];
        }
        [self.tableView reloadData];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)stop{
    [self.tableView.infiniteScrollingView stopAnimating];
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}


-(void)loadData{
    WeLog(@"startKey%@",startKey);
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
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    [dic setValue:COUNT_NUM forKey:KEY_PAGESIZE];
    [dic setValue:startKeystring forKey:KEY_STARTKEY];
    [rp sendDictionary:dic andURL:URL_USER_CLUBINVITE_LIST andData:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    [Utility removeSubViews:cell.contentView];
    UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(5, 7, 50, 50)];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 5;
    CLUB_LOGO(avatar, [[list objectAtIndex:indexPath.row] objectForKey:@"rowkey"],[[list objectAtIndex:indexPath.row] objectForKey:@"picTime"]);
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 80, 15)];
    [nameLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:15]];
    nameLabel.text = [[list objectAtIndex:indexPath.row] objectForKey:KEY_NAME];
    
    UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 20, 150, 40)];
    // NSString *des = [[list objectAtIndex:indexPath.row] objectForKey:KEY_DESC];
    [Utility styleLbl:descLabel withTxtColor:nil withBgColor:nil withFontSize:14];
    descLabel.text = [[list objectAtIndex:indexPath.row] objectForKey:KEY_DESC];
    [Utility removeSubViews:descLabel];
    [Utility emotionAttachString:descLabel.text toView:descLabel font:14 isCut:NO];
    descLabel.text = nil;
    //    if (des.length > 30) {
    //        des = [NSString stringWithFormat:@"%@...",[des substringToIndex:30]];
    //    }
    //    if ([des sizeWithFont:[UIFont systemFontOfSize:14]].width > 300) {
    //        des = [NSString stringWithFormat:@"%@...",[des substringToIndex:10]];
    //    }
    //    NSMutableArray *muArray = [self mycutMixedString:des];
    //    NSString *tempStr = [muArray lastObject];
    //    NSRange rangeH = [tempStr rangeOfString:@"["];
    //    if (rangeH.location != NSNotFound) {
    //        NSRange rangeT = [tempStr rangeOfString:@"..."];
    //        if (rangeT.location - rangeH.location > 3) {
    //            [self attachString:des toView:descLabel];
    //        }else{
    //            NSMutableString *muStr = [NSMutableString stringWithString:des];
    //            NSRange rangeDel = [des rangeOfString:tempStr];
    //            [muStr deleteCharactersInRange:NSMakeRange(rangeDel.location, 3)];
    //            [self attachString:muStr toView:descLabel];
    //        }
    //    }else{
    //        [self attachString:des toView:descLabel];
    //    }
    //    //descLabel.text = des;
    
    UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    acceptBtn.tag = indexPath.row;
    acceptBtn.frame = CGRectMake(220, 15, 40, 25);
    [acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
    [acceptBtn addTarget:self action:@selector(operate:) forControlEvents:UIControlEventTouchUpInside];
    [acceptBtn setTitleColor:NAVIFONT_COLOR forState: UIControlStateHighlighted];
    [acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [cell.contentView addSubview:acceptBtn];
    
    UIButton *refuseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    refuseBtn.tag = indexPath.row;
    refuseBtn.frame = CGRectMake(270, 15, 40, 25);
    [refuseBtn setTitle:@"拒绝" forState:UIControlStateNormal];
    [refuseBtn addTarget:self action:@selector(operate:) forControlEvents:UIControlEventTouchUpInside];
    [refuseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refuseBtn setTitleColor:NAVIFONT_COLOR forState: UIControlStateHighlighted];
    [refuseBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [cell.contentView addSubview:refuseBtn];
    
    
    [cell.contentView addSubview:avatar];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:descLabel];
    // Configure the cell...
    
    return cell;
}

-(void)operate:(id)sender{
    UIButton *btn = (UIButton *)sender;
    operateNO = btn.tag;
    NSString *type;
    if ([btn.titleLabel.text isEqualToString:@"接受"]){
        operateType = 0;
        type = @"0";
    }else if ([btn.titleLabel.text isEqualToString:@"拒绝"]){
        operateType = 1;
        type = @"1";
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:[[list objectAtIndex:operateNO] objectForKey:@"rowkey"]forKey:KEY_CLUB_ROW_KEY];
    [dic setValue:type forKey:KEY_TYPE];
    [rp sendDictionary:dic andURL:URL_USER_CLUBINVITE_OPERATE andData:nil];
}

- (void)receiveAll
{
    if (list.count == 0) {
        return;
    }
    NSMutableString *muStr = [[NSMutableString alloc] init];
    for (int i = 0; i < list.count; i++) {
        [muStr appendString:[[list objectAtIndex:i] objectForKey:@"rowkey"]];
        [muStr appendString:@","];
    }
    [muStr deleteCharactersInRange:NSMakeRange(muStr.length-1, 1)];
    operateType = 3;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dic setObject:muStr forKey:KEY_CLUB_ROW_KEY];
    [dic setObject:@"0" forKey:KEY_TYPE];
    [rp sendDictionary:dic andURL:URL_USER_CLUBINVITE_OPERATE andData:nil];
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
}

-(void)back{
    [rp cancel];
    [self stop];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initNavigation{
    self.title = @"俱乐部邀请";
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    UIButton *receiveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    receiveBtn.tag = -1;
    receiveBtn.frame = CGRectMake(0, 0, 68, 30);
    [receiveBtn setTitle:@"全部接受" forState:UIControlStateNormal];
    [receiveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [receiveBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [receiveBtn addTarget:self action:@selector(receiveAll) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem1 = [[UIBarButtonItem alloc]initWithCustomView:receiveBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem1;
}

#pragma mark - mixed
- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self mycutMixedString:str];
    //    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:14];
    
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
                        
                        if (index <= piece.length-1) {
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
    //    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 20;
    targetView.frame = rect;
}

- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    [self attachString:str toView:view];
    return view.frame.size.height;
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
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSRange range;
    while (1) {
        range = [self matching:str];
        if (range.location == NSNotFound) {
            break;
        }
        if ([[str substringToIndex:range.location] isEqualToString:@""]) {
            
        }else{
            [returnArray addObject:[str substringToIndex:range.location]];
        }
        [returnArray addObject:[str substringWithRange:range]];
        str = [str substringFromIndex:range.location + range.length];
    }
    if ([str length] > 0) {
        [returnArray addObject:str];
    }
    return returnArray;
}


@end
