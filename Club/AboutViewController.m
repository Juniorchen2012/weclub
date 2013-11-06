//
//  AboutViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-30.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithContentType:(NSString *)type
{
    self = [super init];
    if (self) {
        contentType = [type intValue];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavigation];

    if (0 == contentType) {
        qList = [NSArray arrayWithObjects:@"  1  用微俱能干什么？", @"  2  如何注册新用户？", @"  3  用户忘记密码怎么办？", @"  4  怎样创建俱乐部？",@"  5  公开俱乐部和私密俱乐部的区别？",@"  6  怎样发文？",@"  7  和用户私聊提示无权限？",@"  8  查看用户信息提示无权限？",@"  9  录制音频和视频的时长？",@"  10  怎样获取伪币和经验值？",@"  11  设为荣誉会员有什么好处？",@"  12  为什么有时候会取消文章置顶？", nil];
        aList = [NSArray arrayWithObjects:@"     微俱为有相同爱好的朋友提供一个实时交流和沟通的分享平台。可以在俱乐部里发表自己的文章，分享身边的事。",@"     有两种注册方式：①登录页面点击二维码图标，扫描已有用户的二维码，按照提示注册，注册成功后关注该用户；②登录页面点击“注册新用户请点击”，按照提示进行注册。",@"     打开登录页面=>“忘记密码”=>输入注册的邮箱，之后邮箱收到重设密码的邮件，点击链接，根据提示即可重设密码。",@"     注册成功之后引导创建第一个俱乐部。也可以打开俱乐部页面，打开下拉列表进行创建俱乐部。",@"     公开俱乐部：任何人可读，只有会员可写，创建需要100伪币；\r\n     私密俱乐部：只有会员可读、可写。创建需要200伪币；\r\n     公开俱乐部可以转私密，但不能逆转。",@"      只有加入俱乐部才可以发文，打开“我加入的俱乐部”页面，选择一个俱乐部，进入俱乐部信息页面即可发文。",@"     被该用户加入黑名单或不符合该用户设置的私聊权限，与该用户私聊会提示无权限。",@"     被该用户加入黑名单或不符合该用户设置的公开内容权限，查看该用户信息会提示无权限。",@"     现在支持音频和视频的录制时长为30秒。",@"     举报成功和用户升级之后会给相应的伪币。获取经验值方式如下：\r\n     俱乐部的创建、加入、分享、举报、做版主/版副相关操作；文章的发文、回文、分享、举报；用户的登录、关注、分享、举报。",@"     荣誉会员是俱乐部的优秀会员，由版主和版副指定，代表一种荣誉，不具有其他权限。",@"     俱乐部文章只能置顶三篇：置顶的第四篇文章会自动替换置顶的第一篇文章。", nil];
        [self helpLoad];
    }else if (1 == contentType){
        [self protocolLoad];
    }else if (2 == contentType){
        [self scanHelpLoad];
    }
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
}

- (void)helpLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    array_section_open = [[NSMutableArray alloc] initWithCapacity:qList.count];
    for (int i = 0; i < qList.count; i++) {
        [array_section_open addObject:@"0"];
    }
    CGRect rect = [[UIScreen mainScreen] bounds];
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height-44-20) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.backgroundView = nil;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
}

- (void)protocolLoad
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    _protocolText = [[UITextView alloc] init];
    _protocolText.frame = CGRectMake(0, 0, rect.size.width, rect.size.height-44-20);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InfoPlist" ofType:@"strings"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    _protocolText.text = [dic objectForKey:@"protocol"];
    _protocolText.editable = NO;
    [self.view addSubview:_protocolText];
}

- (void)scanHelpLoad
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSString *helpStr;
    _helpText = [[UITextView alloc] init];
    _helpText.frame = CGRectMake(0, 0, rect.size.width, rect.size.height-44-20);
    if ([self.zbarHelpFlag isEqualToString:@"0"]) {
        helpStr = @"      注册时请扫描微俱用户，注册成功后会自动关注该用户。\r\n";
    }else if ([self.zbarHelpFlag isEqualToString:@"1"]){
        helpStr = @"      扫描微俱用户可以查看该用户信息\r\n      扫描俱乐部可查看俱乐部信息。\r\n      若扫描的非微俱用户、俱乐部二维码，则会调用相应的软件或者网页。\r\n      若扫描后的信息无法识别，则不会进行任何处理。";
    }else if ([self.zbarHelpFlag isEqualToString:@"2"]){
        helpStr = @"      扫描俱乐部二维码，可以添加该俱乐部为友情俱乐部。";
    }else if ([self.zbarHelpFlag isEqualToString:@"3"]){
        helpStr = @"      扫描微俱用户二维码，可以与该微俱用户进行聊天\r\n      若对方不在线，你发的信息将会在对方下次登录时显示。";
    }else if ([self.zbarHelpFlag isEqualToString:@"999"]){
        helpStr = @"  该帮助还未编写";
    }
    
    _helpText.text = helpStr;
    _helpText.font = [UIFont systemFontOfSize:18];
    _helpText.editable = NO;
    [self.view addSubview:_helpText];
}

#pragma mark - UITableViewDelegate and UITableViewDataSouce
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *helpCell = @"helpCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:helpCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:helpCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [Utility removeSubViews:cell.contentView];
    NSString *aStr = [aList objectAtIndex:indexPath.section];
    CGSize aSize = [aStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, aSize.width, aSize.height)];
    aLabel.textColor = [UIColor blackColor];
    aLabel.text = aStr;
    aLabel.numberOfLines = 0;
    aLabel.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:aLabel];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return qList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[array_section_open objectAtIndex:section] isEqualToString:@"0"]) {
        return 0;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[array_section_open objectAtIndex:indexPath.section] isEqualToString:@"0"]) {
        return 0;
    }else{
        NSString *aStr = [aList objectAtIndex:indexPath.section];
        CGSize aSize = [aStr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 9999) lineBreakMode:NSLineBreakByWordWrapping];
        
        return aSize.height + 10;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *qStr = [qList objectAtIndex:section];
    CGSize qSize = [qStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(300, 9999) lineBreakMode:NSLineBreakByWordWrapping];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = section+100;
    btn.frame = CGRectMake(0, 0, 320, qSize.height+10);
    [btn addTarget:self action:@selector(section_open:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:[qList objectAtIndex:section] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
   // [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    if ([[array_section_open objectAtIndex:section] isEqualToString:@"0"]) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
        image.frame = CGRectMake(300, 7, 15, 15);
        [btn addSubview:image];
    }else{
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"y.png"]];
        image.frame = CGRectMake(300, 7, 15, 15);
        [btn addSubview:image];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, qSize.height + 9, 320, 1)];
    label.backgroundColor = [UIColor grayColor];
    [btn addSubview:label];
    
    return btn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *qStr = [qList objectAtIndex:section];
    CGSize qSize = [qStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(320, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    return qSize.height+10;
}

- (void)section_open:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag - 100;
    if ([[array_section_open objectAtIndex:index] isEqualToString:@"0"]) {
        [array_section_open removeObjectAtIndex:index];
        [array_section_open insertObject:@"1" atIndex:index];
    }else{
        [array_section_open removeObjectAtIndex:index];
        [array_section_open insertObject:@"0" atIndex:index];
    }
    [table reloadData];
}

- (void)aboutLoad
{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Weclub1.png"]];
    image.frame = CGRectMake(200/2, screenSize.size.height/2 - 200, screenSize.size.width - 200, screenSize.size.width - 200);
    [self.view addSubview:image];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"版本:  v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey] ];
    label.frame = CGRectMake(0, image.frame.origin.y + image.frame.size.height + 20, screenSize.size.width, 30);
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"未名空间 http://mitbbs.org";
    label1.textAlignment = NSTextAlignmentCenter;
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor grayColor];
    label1.font = [UIFont systemFontOfSize:13];
    label1.frame = CGRectMake(0, screenSize.size.height-20-44-100, screenSize.size.width, 30);
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"版权所有 未名空间(mitbbs.com) since 1996";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor grayColor];
    label2.font = [UIFont systemFontOfSize:13];
    label2.frame = CGRectMake(0, screenSize.size.height-20-44-80, screenSize.size.width, 30);
    [self.view addSubview:label2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
}

-(void)initNavigation{
    //titleView
    self.navigationController.navigationBar.tintColor = TINT_COLOR;
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    if (0 == contentType) {
        titleLbl.text = @"帮助/faq";
    }else if (1 == contentType){
        titleLbl.text = @"注册协议";
    }else if (2 == contentType){
        titleLbl.text = @"二维码扫描帮助";
    }
    
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

//俱乐部列表
//-(void)getTestData:(NSMutableArray *)array{
//    NSMutableArray *friendClubList = [[NSMutableArray alloc]init];
//    for (int i = 0; i < 20; i++) {
//        NSDictionary *myClub = [NSDictionary dictionaryWithObjectsAndKeys:@"mitbbs",KEY_CREATOR,[NSString stringWithFormat:@"%d分钟",i+1],KEY_ADMIN,[NSArray arrayWithObjects:@"mit1",@"mit2",@"mit3", nil],KEY_VICE_ADMINS,@"2013-1-13",KEY_CREATE_TIME,@"4",KEY_ACTIVE_DEGREE,@"3",KEY_ID,@"2",KEY_HARDWORK_DEGREE,@"音乐",KEY_CATEGORY,@"175",KEY_MEMBER_COUNT,@"200",KEY_TOPIC_COUNT,@"4",KEY_DISTANCE,@"18",KEY_FOLLOW_COUNT ,[myConstants.clubNames objectAtIndex:i],KEY_NAME,@"未名空间未名空间未名空间未名空间未名空间未名空间未名空间未名论坛未名空间未名空间未名空间未名论坛",KEY_DESC,[myConstants.urls objectAtIndex:i],KEY_LOGO,@"100",KEY_COLLECT_COUNT,@"125",KEY_SHARE_COUNT,@"3",KEY_STARLEVEL,nil];
//        [friendClubList addObject:myClub];
//    }
//    for (int i = 0; i < 20; i++) {
//        NSString *type = @"0";
//        if (i == 0) {
//            type = @"1";
//        }
//        NSDictionary *club = [NSDictionary dictionaryWithObjectsAndKeys:type,KEY_TYPE,@"mitbbs",KEY_CREATOR,[NSString stringWithFormat:@"%d分钟",i+1],KEY_ADMIN,[NSArray arrayWithObjects:@"mit1",@"mit2",@"mit3", nil],KEY_VICE_ADMINS,@"2013-1-13",KEY_CREATE_TIME,@"4",KEY_ACTIVE_DEGREE,@"3",KEY_ID,@"2",KEY_HARDWORK_DEGREE,@"音乐",KEY_CATEGORY,@"175",KEY_MEMBER_COUNT,@"200",KEY_TOPIC_COUNT,@"4公里",KEY_DISTANCE,@"18",KEY_FOLLOW_COUNT ,[myConstants.clubNames objectAtIndex:i],KEY_NAME,@"未名空间未名空间未名空间未名空间未名空间未名空间未名空间未名论坛未名空间未名空间未名空间未名论坛",KEY_DESC,[myConstants.urls objectAtIndex:i],KEY_LOGO,@"100",KEY_COLLECT_COUNT,@"125",KEY_SHARE_COUNT,@"3",KEY_STARLEVEL,friendClubList,KEY_FRIEND_CLUBS,nil];
//        [array addObject:club];
//    }
//}

//文章列表
//-(void)getTestData:(NSMutableArray *)array withListType:(int) Type{
//    if (!Type) {
//        for (int i = 0; i < 20; i++) {
//            NSDictionary *topicArticle = [NSDictionary dictionaryWithObjectsAndKeys:[myConstants.userNames objectAtIndex:i],KEY_NAME,@"15分钟前",KEY_POST_TIME,@"3",KEY_ID,@"175",KEY_BROWSE_COUNT,@"200",KEY_REPLY_COUNT,@"50",KEY_SHARE_COUNT,@"4公里",KEY_DISTANCE ,[myConstants.content objectAtIndex:i],KEY_CONTENT,[myConstants.urls objectAtIndex:i],KEY_AVATAR,@"100",KEY_COLLECT_COUNT,[myConstants.article_media_pics objectAtIndex:i%5],KEY_MEDIA,[[NSArray arrayWithObjects:@"0",@"0",@"1",@"2",@"3",nil] objectAtIndex:i%5],@"1",KEY_ARTICLE_STYLE,KEY_IS_REPLY_ARTICLE,nil];
//            [array addObject:topicArticle];
//        }
//    }else{
//        for (int i = 0; i < 10; i++) {
//            NSDictionary *topicArticle = [NSDictionary dictionaryWithObjectsAndKeys:[myConstants.userNames objectAtIndex:2*i+1],KEY_NAME,@"15分钟前",KEY_POST_TIME,@"3",KEY_ID,@"175",KEY_BROWSE_COUNT,@"200",KEY_REPLY_COUNT,@"50",KEY_SHARE_COUNT,@"4",KEY_DISTANCE ,[myConstants.content objectAtIndex:2*i+1],KEY_CONTENT,[myConstants.urls objectAtIndex:2*i+1],KEY_AVATAR,@"100",KEY_COLLECT_COUNT,@"30",KEY_COLLECT_COUNT,[myConstants.article_media_pics objectAtIndex:i%4],KEY_MEDIA,@"1",KEY_ARTICLE_STYLE,nil];
//            [goodArticleList addObject:topicArticle];
//        }
//    }
//}


//文章主题页
//-(void)getTestData:(NSMutableArray *)array{
//    NSArray *clubNames =[[[NSArray alloc] initWithObjects:@"google",@"资深评论人",@"影评小李",@"想太多先生",@"小百科",@"笑料",@"富二代",@"随风",@"onebyone",@"张样",@"李名",@"APK",@"小名",@"刘帅",@"王小贱",@"ios",@"果粉",@"小米",@"知春路",@"马化腾",nil] autorelease];
//    NSArray *media = [[[NSArray alloc]initWithObjects:
//                       @"http://farm3.static.flickr.com/2546/4012296861_146d4805df_s.jpg",
//                       @"http://farm3.static.flickr.com/2557/4010652749_1d0c35fabd_s.jpg",
//                       @"http://farm3.static.flickr.com/2543/4010847393_9844b1a37f_s.jpg",
//                       @"http://farm3.static.flickr.com/2724/4021388365_7c739b9b16_s.jpg"
//                       , nil] autorelease];
//    NSArray *urls = [[[NSArray alloc]initWithObjects:
//                      @"http://farm4.static.flickr.com/3484/4018164769_2e68f895dc_s.jpg",
//                      @"http://farm3.static.flickr.com/2557/4010652749_1d0c35fabd_s.jpg",
//                      @"http://farm3.static.flickr.com/2613/4019518861_5fbd679d61_s.jpg",
//                      @"http://farm4.static.flickr.com/3484/4018164769_2e68f895dc_s.jpg",
//                      @"http://farm3.static.flickr.com/2643/4020492457_84c4140077_s.jpg",
//                      @"http://farm3.static.flickr.com/2670/4013657757_12c694c4ee_s.jpg",
//                      @"http://farm3.static.flickr.com/2804/4019095448_049ef023e3_s.jpg",
//                      @"http://farm3.static.flickr.com/2197/4011866354_0948246520_s.jpg",
//                      @"http://farm3.static.flickr.com/2557/4010652749_1d0c35fabd_s.jpg",
//                      @"http://farm3.static.flickr.com/2543/4010847393_9844b1a37f_s.jpg",
//                      @"http://farm3.static.flickr.com/2724/4021388365_7c739b9b16_s.jpg",
//                      @"http://farm4.static.flickr.com/3484/4018164769_2e68f895dc_s.jpg",
//                      @"http://farm3.static.flickr.com/2643/4020492457_84c4140077_s.jpg",
//                      @"http://farm3.static.flickr.com/2670/4011966914_e1849fda91_s.jpg",
//                      @"http://farm3.static.flickr.com/2653/4015298872_d4ef36c14a_s.jpg",
//                      @"http://farm3.static.flickr.com/2710/4024844149_40dca40cd2_s.jpg",
//                      @"http://farm3.static.flickr.com/2546/4012296861_146d4805df_s.jpg",
//                      @"http://farm3.static.flickr.com/2557/4010652749_1d0c35fabd_s.jpg",
//                      @"http://farm3.static.flickr.com/2543/4010847393_9844b1a37f_s.jpg",
//                      @"http://farm3.static.flickr.com/2724/4021388365_7c739b9b16_s.jpg",
//                      nil] autorelease];
////    replyArticleList = [[NSMutableArray alloc]init];
//    for (int i = 0; i < 20; i++) {
//        NSDictionary *replyArticle = [NSDictionary dictionaryWithObjectsAndKeys:[clubNames objectAtIndex:i],KEY_NAME,[NSString stringWithFormat:@"%d分钟",i+1],KEY_POST_TIME,@"3",KEY_ID,@"175",KEY_BROWSE_COUNT,@"200",KEY_REPLY_COUNT,@"50",KEY_SHARE_COUNT,@"4公里",KEY_DISTANCE ,[myConstants.replyArticleContent objectAtIndex:i],KEY_CONTENT,[urls objectAtIndex:i],KEY_AVATAR,@"100",KEY_COLLECT_COUNT,@"30",KEY_COLLECT_COUNT,[[NSArray arrayWithObjects:@"0",@"2",nil] objectAtIndex:i%2],KEY_ARTICLE_STYLE,@"1",KEY_IS_REPLY_ARTICLE,nil];
//        [array addObject:replyArticle];
//}
//}
//-(void)getTheRepliedArticle:(NSString *)rowKey{
//    postURLStr = URL_ARTICLE_VIEW;
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//    [dic setValue:rowKey forKey:KEY_ROW_KEY];
//    [rp sendDictionary:dic andURL:postURLStr andData:nil];
//}
@end
