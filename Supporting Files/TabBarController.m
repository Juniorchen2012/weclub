//
//  TabBarController.m
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013Âπ?mitbbs. All rights reserved.
//

#import "TabBarController.h"
#import "ClubListViewController.h"
#import "ArticleViewController.h"
#import "UserViewController.h"
#import "SettingsViewController.h"
#import "Header.h"
#import "ChatViewController.h"
#import "CircleView.h"

@interface TabBarController ()

@end


@implementation TabBarController
@synthesize selectedbtn_bg;
@synthesize clubNoticeLabel = _clubNoticeLabel;
@synthesize articleNoticeLabel = _articleNoticeLabel;
@synthesize userNoticeLabel = _userNoticeLabel;

-(void)dealloc{
    NSLog(@"TabBarController dealloc");
    [super dealloc];
    [selectedbtn_bg release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_FOLLOWLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_UPDATENOTICE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_CHECKUNREAD object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    _tabSelf = self;
    return self;
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    [self checkUnRead];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (self.lastAdoptClub) {
        ClubViewController *clubView = [[ClubViewController alloc]init];
        clubView.club = self.lastAdoptClub;
        clubView.hidesBottomBarWhenPushed = YES;
        [self.nav1 pushViewController:clubView animated:YES];
    }
}

- (TabBarController *)getTabBar
{
    return _tabSelf;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.clublist = [[[ClubListViewController alloc] initWithNibName:@"ClubListViewController" bundle:nil] autorelease];
    
    [self saveDirectLogin];

    [AccountUser getSingleton].isLogin = YES;
    self.clublist = [[[ClubListViewController alloc] init] autorelease];
    self.nav1 = [[[UINavigationController alloc]initWithRootViewController:self.clublist]autorelease];

    self.nav1.navigationBar.translucent = NO;
    self.nav1.navigationBar.tintColor = TINT_COLOR;

    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      NAVIFONT_COLOR,
      UITextAttributeTextColor,
      [UIColor clearColor],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Arial" size:0.0],
      UITextAttributeFont,
      nil]];
//    self.article = [[[ArticleViewController alloc]initWithNibName:@"ArticleViewController" bundle:nil] autorelease];
    self.article = [[[ArticleViewController alloc] init] autorelease];
    self.nav2 = [[[UINavigationController alloc]initWithRootViewController:self.article]autorelease];
    self.nav2.navigationBar.tintColor = TINT_COLOR;
    self.nav2.navigationBar.translucent = NO;

//    self.nav2.navigationBar.clipsToBounds = YES;
    
    
    self.user = [[[UserViewController alloc]initWithNibName:@"UserViewController" bundle:nil] autorelease];
    self.nav3 = [[[UINavigationController alloc]initWithRootViewController:self.user]autorelease];
    self.nav3.navigationBar.tintColor = TINT_COLOR;
    self.nav3.navigationBar.translucent = NO;

//    self.nav3.navigationBar.clipsToBounds = YES;

//    self.chatView = [[[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil] autorelease];
//    self.nav3 = [[[UINavigationController alloc]initWithRootViewController:self.chatView]autorelease];
//    self.nav3.navigationBar.tintColor = TINT_COLOR;
    
    self.settings = [[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil] autorelease];
    self.nav4 = [[[UINavigationController alloc]initWithRootViewController:self.settings]autorelease];
    self.nav4.navigationBar.tintColor = TINT_COLOR;
    self.nav4.navigationBar.translucent = NO;

//    self.nav4.navigationBar.clipsToBounds = YES;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        self.nav1.navigationBar.clipsToBounds = YES;
        self.nav2.navigationBar.clipsToBounds = YES;
        self.nav3.navigationBar.clipsToBounds = YES;
        self.nav4.navigationBar.clipsToBounds = YES;
    }else{
        self.nav1.navigationBar.barTintColor = TINT_COLOR;
        self.nav2.navigationBar.barTintColor = TINT_COLOR;
        self.nav3.navigationBar.barTintColor = TINT_COLOR;
        self.nav4.navigationBar.barTintColor = TINT_COLOR;
    }
    
    NSArray *vcarrary = [NSArray arrayWithObjects:self.nav1, self.nav2, self.nav3, self.nav4, nil];
    self.viewControllers = vcarrary;
    
    UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 49)];
    bg.image = [UIImage imageNamed:@"tabbarbg.png"];
    [self.tabBar addSubview:bg];
    [bg release];
    
    selectedbtn_bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 49)];
    selectedbtn_bg.image = [UIImage imageNamed:@"tab_selected.png"];
    [self.tabBar addSubview:selectedbtn_bg];
    
    UIButton *clubbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 80, 49)];
    UIImageView *clubicon = [[UIImageView alloc]initWithFrame:CGRectMake(27, 3, 26, 26)];
    clubicon.image = [UIImage imageNamed:@"tab_club.png"];
    [clubbtn addSubview:clubicon];
    [clubicon release];
    //    [clubbtn setImage:[UIImage imageNamed:@"tab_club.png"] forState:UIControlStateNormal];
    [clubbtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [clubbtn setTag:0];
    clubbtn.showsTouchWhenHighlighted = YES;
    UILabel *clubLbl = [[UILabel alloc]initWithFrame:CGRectMake(25, 35, 40, 10)];
    clubLbl.text = @"俱乐部";
    [clubLbl setTextColor:[UIColor whiteColor]];
    [clubLbl setFont:[UIFont systemFontOfSize:10]];
    clubLbl.backgroundColor = [UIColor clearColor];
    [self.tabBar addSubview:clubbtn];
    [clubbtn release];
    [self.tabBar addSubview:clubLbl];
    [clubLbl release];
    
    UIButton *articlebtn = [[UIButton alloc]initWithFrame:CGRectMake(80, 5, 80, 49)];
    //    [articlebtn setImage:[UIImage imageNamed:@"tab_article.png"] forState:UIControlStateNormal];
    UIImageView *articleicon = [[UIImageView alloc]initWithFrame:CGRectMake(27, 3, 26, 26)];
    articleicon.image = [UIImage imageNamed:@"tab_article.png"];
    [articlebtn addSubview:articleicon];
    [articleicon release];
    [articlebtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [articlebtn setTag:1];
    articlebtn.showsTouchWhenHighlighted = YES;
    UILabel *articleLbl = [[UILabel alloc]initWithFrame:CGRectMake(110, 35, 40, 10)];
    articleLbl.text = @"文章";
    [articleLbl setTextColor:[UIColor whiteColor]];
    [articleLbl setFont:[UIFont systemFontOfSize:10]];
    articleLbl.backgroundColor = [UIColor clearColor];
    [self.tabBar addSubview:articlebtn];
    [articlebtn release];
    [self.tabBar addSubview:articleLbl];
    [articleLbl release];
    
    UIButton *userbtn = [[UIButton alloc]initWithFrame:CGRectMake(160, 5, 80, 49)];
    //    [userbtn setImage:[UIImage imageNamed:@"tab_user.png"] forState:UIControlStateNormal];
    UIImageView *usericon = [[UIImageView alloc]initWithFrame:CGRectMake(27, 3, 26, 26)];
    usericon.image = [UIImage imageNamed:@"tab_user.png"];
    [userbtn addSubview:usericon];
    [usericon release];
    [userbtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [userbtn setTag:2];
    userbtn.showsTouchWhenHighlighted = YES;
    UILabel *userLbl = [[UILabel alloc]initWithFrame:CGRectMake(190, 35, 40, 10)];
    userLbl.text = @"用户";
    [userLbl setTextColor:[UIColor whiteColor]];
    [userLbl setFont:[UIFont systemFontOfSize:10]];
    userLbl.backgroundColor = [UIColor clearColor];
    [self.tabBar addSubview:userbtn];
    [userbtn release];
    [self.tabBar addSubview:userLbl];
    [userLbl release];
    
    UIButton *settingsbtn = [[UIButton alloc]initWithFrame:CGRectMake(240, 5, 80, 49)];
    //    [settingsbtn setImage:[UIImage imageNamed:@"tab_settings.png"] forState:UIControlStateNormal];
    UIImageView *settingsicon = [[UIImageView alloc]initWithFrame:CGRectMake(27, 3, 26, 26)];
    settingsicon.image = [UIImage imageNamed:@"tab_settings.png"];
    [settingsbtn addSubview:settingsicon];
    [settingsicon release];
    [settingsbtn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [settingsbtn setTag:3];
    settingsbtn.showsTouchWhenHighlighted = YES;
    UILabel *settingsLbl = [[UILabel alloc]initWithFrame:CGRectMake(270, 35, 40, 10)];
    settingsLbl.text = @"设置";
    [settingsLbl setTextColor:[UIColor whiteColor]];
    [settingsLbl setFont:[UIFont systemFontOfSize:10]];
    settingsLbl.backgroundColor = [UIColor clearColor];
    [self.tabBar addSubview:settingsbtn];
    [settingsbtn release];
    [self.tabBar addSubview:settingsLbl];
    [settingsLbl release];
    
    _clubNoticeLabel = [[UILabel alloc] init];
    _clubNoticeLabel.frame = CGRectMake(53, 2, 25, 20);
    _clubNoticeLabel.backgroundColor = [UIColor colorWithRed:221/255.0 green:156/255.0 blue:0 alpha:1];
    _clubNoticeLabel.layer.cornerRadius = 5;
    _clubNoticeLabel.textAlignment = NSTextAlignmentCenter;
    _clubNoticeLabel.textColor = [UIColor whiteColor];
    _clubNoticeLabel.font = [UIFont systemFontOfSize:14];
    [_clubNoticeLabel setHidden:YES];
    [self.tabBar addSubview:_clubNoticeLabel];
    
//    _clubNoticeCircle = [[CircleView alloc] initWithFrame:CGRectMake(57, 2, 22, 22) text:_clubNoticeLabel.text radius:10];
//    [_clubNoticeCircle setTag:1001];
//    [_clubNoticeCircle setHidden:YES];
//    [self.tabBar addSubview:_clubNoticeCircle];
    _clubNoticeCircle = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(53, 2, 30, 22)];
    [_clubNoticeCircle setHidden:YES];
    _clubNoticeCircle.shadow = NO;
    _clubNoticeCircle.shine = NO;
    [self.tabBar addSubview:_clubNoticeCircle];
    
    _articleNoticeLabel = [[UILabel alloc] init];
    _articleNoticeLabel.frame = CGRectMake(133, 2, 25, 20);
    _articleNoticeLabel.backgroundColor = [UIColor colorWithRed:221/255.0 green:156/255.0 blue:0 alpha:1];
    _articleNoticeLabel.layer.cornerRadius = 5;
    _articleNoticeLabel.textAlignment = NSTextAlignmentCenter;
    _articleNoticeLabel.textColor = [UIColor whiteColor];
    _articleNoticeLabel.font = [UIFont systemFontOfSize:14];
    [_articleNoticeLabel setHidden:YES];
    [self.tabBar addSubview:_articleNoticeLabel];
    
//    _articleNoticeCircle = [[CircleView alloc] initWithFrame:CGRectMake(137, 2, 22, 22) text:_articleNoticeLabel.text radius:10];
//    [_articleNoticeCircle setTag:1002];
//    [_articleNoticeCircle setHidden:YES];
    _articleNoticeCircle = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(133, 2, 30, 22)];
    _articleNoticeCircle.shine = NO;
    _articleNoticeCircle.shadow = NO;
    [_articleNoticeCircle setHidden:YES];
    [self.tabBar addSubview:_articleNoticeCircle];
    
    _userNoticeLabel = [[UILabel alloc] init];
    _userNoticeLabel.frame = CGRectMake(213, 2, 25, 20);
    _userNoticeLabel.backgroundColor = [UIColor colorWithRed:221/255.0 green:156/255.0 blue:0 alpha:1];
    _userNoticeLabel.layer.cornerRadius = 5;
    _userNoticeLabel.textAlignment = NSTextAlignmentCenter;
    _userNoticeLabel.textColor = [UIColor whiteColor];
    _userNoticeLabel.font = [UIFont systemFontOfSize:14];
    [_userNoticeLabel setHidden:YES];
    [self.tabBar addSubview:_userNoticeLabel];
    
//    _userNoticeCircle = [[CircleView alloc] initWithFrame:CGRectMake(218, 2, 22, 22) text:_userNoticeLabel.text radius:10];
//    [_userNoticeCircle setTag:1003];
//    [_userNoticeCircle setHidden:YES];
    _userNoticeCircle = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(214, 2, 30, 22)];
    _userNoticeCircle.shadow = NO;
    _userNoticeCircle.shine = NO;
    [_userNoticeCircle setHidden:YES];
    [self.tabBar addSubview:_userNoticeCircle];
    
//    [[NoticeManager sharedNoticeManager] resetSharedNoticeManger];
    [[NoticeManager sharedNoticeManager] resetAllNotices];
    //???Ê∂?????
    _tabtag_unread = [[UIImageView alloc] init];
    _tabtag_unread.frame = CGRectMake(165, 0, 20, 20);
    NSString *tabtag_unreadPath = [[NSBundle mainBundle] pathForResource:@"tabtag_unread" ofType:@"png"];
    _tabtag_unread.image = [UIImage imageWithContentsOfFile:tabtag_unreadPath];
    _tabtag_unread.hidden = YES;
    [self.tabBar addSubview:_tabtag_unread];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToUserTab) name:NOTIFICATION_KEY_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToUserTab) name:NOTIFICATION_KEY_FOLLOWLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToUserTab) name:NOTIFICATION_KEY_USERLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToClubTab) name:NOTIFICATION_KEY_JOINCLUBLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToClubTab) name:@"attention_club_list" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToUserTab) name:NOTIFICATION_KEY_ATTENTIONLIST object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToAtricleTab) name:NOTIFICATION_KEY_MENTIONME object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotice:) name:NOTIFICATION_KEY_UPDATENOTICE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToInformCenter:) name:NOTIFICATION_KEY_NOTICECENTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUnRead) name:NOTIFICATION_KEY_CHECKUNREAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCurrentController:) name:@"checkCurrentController" object:nil];

	// Do any additional setup after loading the view.
    
    

}

-(void)checkCurrentController:(NSNotification *)notification{
    NSLog(@"selectedController%@",self.selectedViewController);
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]] &&
        [((UINavigationController*)self.selectedViewController).topViewController isKindOfClass:[ClubInfoViewController class]]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"forceRefreshClubInfo" object:notification.object];
    }
    
    for(UIViewController *vc in ((UINavigationController*)self.selectedViewController).viewControllers) {
        if ([vc isKindOfClass:[ClubInfoViewController class]]) {
            if ([((ClubInfoViewController *)vc).club.ID isEqualToString:[notification.object objectForKey:@"clubrowkey"]]&&((UINavigationController*)self.selectedViewController).topViewController != vc) {
                UIAlertView *alert = [Utility MsgBox:@"您在该俱乐部的权限发生了变化需要返回俱乐部信息页面" AndTitle:nil AndDelegate:self AndCancelBtn:@"确定" AndOtherBtn:nil withStyle:0];
                goController = vc;
                alert.tag = 1;
            }
        }
    }
    return;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == alertView.tag) {
        if (0 == buttonIndex) {
            [((UINavigationController*)self.selectedViewController) popToViewController:goController animated
                                                                                       :YES];
        }
    }
    return;
}

- (void)saveDirectLogin
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([[ud objectForKey:@"directLogin"] isEqualToString:@"1"]) {
        return;
    }else{
        [ud setObject:@"1" forKey:@"directLogin"];
        [ud setObject:[ud objectForKey:@"defaultName"] forKey:@"directLoginName"];
        [ud setObject:[ud objectForKey:@"defaultPassword"] forKey:@"directLoginPassword"];
//        [ud setObject:@"111" forKey:@"directLoginPassword"];
        [ud synchronize];
    }
}


//?¥Ê?????∂Ê?
- (void)updateNotice:(NSNotification *)notification
{
    NSDictionary *noticeDic = (NSDictionary *)notification.object;
    if ([noticeDic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"noticeDic:%@",noticeDic);
        NSString *clubNotice = [noticeDic objectForKey:@"club"];
        int clubNoticeNumber = [clubNotice intValue];
        if (clubNoticeNumber == 0) {
            _clubNoticeLabel.text = @"";
            [_clubNoticeLabel setHidden:YES];
            [_clubNoticeCircle setHidden:YES];
        }else if (clubNoticeNumber>0 && clubNoticeNumber<100){
            _clubNoticeLabel.text = clubNotice;
            [_clubNoticeLabel setHidden:NO];
        }else if (clubNoticeNumber>=100){
            _clubNoticeLabel.text = @"99+";
            [_clubNoticeLabel setHidden:NO];
        }
        
        NSString *clubAttention = [noticeDic objectForKey:@"bbsClubAttention"];
        int clubAttentionNumber = [clubAttention intValue];
        NSString *clubFollow = [noticeDic objectForKey:@"bbsClubFollow"];
        int clubFollowNumber = [clubFollow intValue];
        if (clubAttentionNumber == 1 && clubFollowNumber ==1) {
            _clubNoticeLabel.text = @"2";
            [_clubNoticeLabel setHidden:NO];
        }else if (clubFollowNumber == 0 && clubAttentionNumber == 0) {
            _clubNoticeLabel.text = @"";
            [_clubNoticeLabel setHidden:YES];
        }else{
            _clubNoticeLabel.text = @"1";
            [_clubNoticeLabel setHidden:NO];
        }
        
        
        NSString *articleNotice = [noticeDic objectForKey:@"art"];
        int articleNoticeNumber = [articleNotice intValue];
        if (articleNoticeNumber == 0) {
            _articleNoticeLabel.text = @"";
            [_articleNoticeLabel setHidden:YES];
        }else if (articleNoticeNumber>0 && articleNoticeNumber<100){
            _articleNoticeLabel.text = articleNotice;
            [_articleNoticeLabel setHidden:NO];
        }else if (articleNoticeNumber>=100){
            _articleNoticeLabel.text = @"99+";
            [_articleNoticeLabel setHidden:NO];
        }
        
        NSString *userNotice = [noticeDic objectForKey:@"user"];
        int userNoticeNumber = [userNotice intValue];
        if (userNoticeNumber == 0) {
            _userNoticeLabel.text = @"";
            [_userNoticeLabel setHidden:YES];
        }else if (userNoticeNumber>0 && userNoticeNumber<100){
            _userNoticeLabel.text = userNotice;
            [_userNoticeLabel setHidden:NO];
        }else if (userNoticeNumber>=100){
            _userNoticeLabel.text = @"99+";
            [_userNoticeLabel setHidden:NO];
        }
        
        NSString *userAttention = [noticeDic objectForKey:@"bbsUserAttention"];
        int userAttentionNumber = [userAttention intValue];
        if (userAttentionNumber == 1) {
            _userNoticeLabel.text = @"1";
            [_userNoticeLabel setHidden:NO];
        }
    }
}

-(void)selectTab:(id)sender{
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case CLUB_TAB:
//            DLog(@"Tabbar SelectedController:%@",self.selectedViewController);
            if ([self.selectedViewController isKindOfClass:[self.nav1 class]]) {
//                [self.clublist refresh];
            }
            break;
        case ARTICLE_TAB:
            break;
        case USER_TAB:
            if ([self checkUnRead] > 0) {
                self.user.selectedIndex = 1;
                [self.user switchToChatTab:nil];
            }
            break;
        case SETTINGS_TAB:
            break;
    }
    //?πÂ???∏≠???????æÁ????ÁΩ?
    selectedbtn_bg.frame = CGRectMake(80*btn.tag, 0, 80, 49);
    self.selectedIndex = btn.tag;
}

- (void)mentionMeAtricle
{
    TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
    _tabC.article.mentionMeFlag = 1;
    [self switchToAtricleTab];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_MENTIONME object:nil];
}

- (void)followMeUser
{
    TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
    ((UserViewController *)_tabC.user).isFollowMeUser = 1;
    [self switchToUserTab];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_USERLIST object:[NSNumber numberWithInt:1]];
}

- (void)iFollowUser
{
    TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
    ((UserViewController *)_tabC.user).isIFollowUser = 1;
    [self switchToUserTab];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_USERLIST object:[NSNumber numberWithInt:0]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch * touch = [touches anyObject];
//	CGPoint position = [touch locationInView:self.view];
    if (([self.selectedViewController isKindOfClass:[self.nav1 class]])&&[self.nav1.topViewController isKindOfClass:[ClubListViewController class]]){
        [self.clublist hideTitleViews];
    }

    if (([self.selectedViewController isKindOfClass:[self.nav1 class]])&&[self.nav1.topViewController isKindOfClass:[ClubViewController class]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TITLEVIEWS" object:nil userInfo:nil];
    }
    
    if (([self.selectedViewController isKindOfClass:[self.nav2 class]])&&[self.nav2.topViewController isKindOfClass:[ArticleViewController class]]){
        [self.article hideTitleViews];
    }
    
    if (([self.selectedViewController isKindOfClass:[self.nav2 class]])&&[self.nav2.topViewController isKindOfClass:[ArticleViewController class]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TITLEVIEWS" object:nil userInfo:nil];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;

}

- (void)switchToClubTab
{
    self.selectedIndex = 0;
    selectedbtn_bg.frame = CGRectMake(0, 0, 80, 49);
}

- (void)switchToAtricleTab
{
    self.selectedIndex = 1;
    selectedbtn_bg.frame = CGRectMake(80, 0, 80, 49);
}

- (void)switchToUserTab
{
    self.selectedIndex = 2;
    selectedbtn_bg.frame = CGRectMake(80*2, 0, 80, 49);
}

- (void)switchToInformCenter:(NSNotification *)notification
{
    self.selectedIndex = 3;
    selectedbtn_bg.frame = CGRectMake(80*3, 0, 80, 49);
}

- (int)checkUnRead
{
    NSArray *friends = [[ChatListSaveProxy sharedChatListSaveProxy] getFriends];
    int total = 0;
    NSString *totalStr=nil;
    
    for (ChatFriend *friend in friends) {
        int unread = friend.unread;
        total += unread;
        }
    
    if (total > 0) {
        if(total > 99) {
            totalStr = [NSString stringWithFormat:@"99+"];
        }else {
            totalStr = [NSString stringWithFormat:@"%d", total];
        }
//        UIView *hint = [[CircleView alloc] initWithFrame:_tabtag_unread.frame text:totalStr radius:8];
//        [hint setTag:11];
//        [self.tabBar addSubview:hint];
        _tabtag_unread.hidden = YES;
        [[NoticeManager sharedNoticeManager] resetChatNotice:total];
        return total;
    }else {
//        for (UIView *v in [self.tabBar subviews]) {
//            if(v.tag == 11) {
//                [v removeFromSuperview];
//            }
//        }
        [[NoticeManager sharedNoticeManager] resetChatNotice:0];
    }

    _tabtag_unread.hidden = YES;
    return 0;
}

- (void)cleanAllNotice{
    for (UIView *v in [self.tabBar subviews]) {
        if(v.tag == 1001 || v.tag == 1002 || v.tag == 1003) {
            [v removeFromSuperview];
        }
    }
}

@end
