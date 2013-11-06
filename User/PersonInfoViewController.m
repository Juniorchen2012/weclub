//
//  PersonInfoViewController.m
//  WeClub
//
//  Created by Archer on 13-3-22.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "DetailViewController.h"
#import "TDCCardViewController.h"

@interface PersonInfoViewController ()

@end

@implementation PersonInfoViewController

@synthesize articleArray = _articleArray;
@synthesize startKey = _startKey;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNumberID:(NSString *)numberID
{
    self = [super init];
    if (self) {
        _numberID = numberID;
        _initValue = numberID;
        _initKey = @"numberid";
    }
    return self;
}

- (id)initWithUserName:(NSString *)username
{
    self = [super init];
    if (self) {
        _initValue = username;
        _initKey = @"username";
    }
    return self;
}

- (id)initWithUserRowKey:(NSString *)rowkey
{
    self = [super init];
    if (self) {
        _initValue = rowkey;
        _initKey = @"userrowkey";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.detailsLabelText = @"正在加载";
    hud.removeFromSuperViewOnHide = YES;
    
    _infoHeaderOne = [[UIView alloc] init];
    _infoHeaderOne.frame = CGRectMake(0, 0, 320, 120);
    [_infoHeaderOne setHidden:YES];
    
    //=============================右上角目录按钮==========================================
    _menuItemArray = [NSMutableArray arrayWithObjects:@"加入关注", @"加入黑名单",@"二维码名片", @"举报", @"私聊", nil];
    
    titleViews = [[UIView alloc]initWithFrame:CGRectMake(320-140, 0, 140, 40*[_menuItemArray count])];
    titleViews.backgroundColor = TINT_COLOR;
    holeView = [[UIControl alloc]initWithFrame:CGRectMake(0, 60, 320, myConstants.screenHeight)];
    
    followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    followBtn.frame = CGRectMake(0, 0, 140, 40);
    followBtn.tag = 1;
    [followBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [followBtn setTitle:[_menuItemArray  objectAtIndex:0] forState:UIControlStateNormal];
    [followBtn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(1), 140, 1)];
    line.backgroundColor = [UIColor blackColor];
    [titleViews addSubview:line];
    [titleViews addSubview:followBtn];
    
    blackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    blackBtn.frame = CGRectMake(0, 40, 140, 40);
    blackBtn.tag = 2;
    [blackBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [blackBtn setTitle:[_menuItemArray  objectAtIndex:1] forState:UIControlStateNormal];
    [blackBtn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(2), 140, 1)];
    line.backgroundColor = [UIColor blackColor];
    [titleViews addSubview:line];
    [titleViews addSubview:blackBtn];
    
    for (int i = 2; i < [_menuItemArray count]; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 40*i, 140, 40);
        btn.tag = i+1;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitle:[_menuItemArray  objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
        line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(i+1), 140, 1)];
        line.backgroundColor = [UIColor blackColor];
        [titleViews addSubview:line];
        [titleViews addSubview:btn];
    }
    holeView.backgroundColor = [UIColor clearColor];
    [holeView addSubview:titleViews];
    [holeView addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBarController.view addSubview:holeView];
    holeView.hidden = YES;
    //=============================右上角目录按钮==========================================
    
    //加载背景图
    _infoHeaderOneBgView = [[UIImageView alloc] init];
    _infoHeaderOneBgView.frame = _infoHeaderOne.frame;
//    UIImage *bgImg = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bg" ofType:@"png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 27, 10)];
    _infoHeaderOneBgView.image = [UIImage imageNamed:@"bg.png"];
    _infoHeaderOneBgView.contentMode = UIViewContentModeScaleAspectFill;
//    _infoHeaderOneBgView.image = bgImg;
    [_infoHeaderOne addSubview:_infoHeaderOneBgView];
    
    //头像view
    _photoView = [[UIImageView alloc] init];
    _photoView.frame = CGRectMake(9, 7, 60, 60);
    _photoView.layer.masksToBounds = YES;
    _photoView.layer.cornerRadius = 5.0;
//    _photoView.image = [UIImage imageNamed:@"avatarPlaceHolder.png"];
    [_infoHeaderOne addSubview:_photoView];
    
    //头像button,查看头像大图
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _photoButton.frame = _photoView.frame;
    _photoButton.backgroundColor = [UIColor clearColor];
    [_photoButton addTarget:self action:@selector(playPicture:) forControlEvents:UIControlEventTouchUpInside];
    [_infoHeaderOne addSubview:_photoButton];
    
    //姓名label
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.frame = CGRectMake(74, 7, 80, 20);
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.text = @"";
    _nameLabel.font = [UIFont systemFontOfSize:16];
    [_infoHeaderOne addSubview:_nameLabel];
    
    //性别view
    _sexView = [[UIImageView alloc] init];
    _sexView.frame = CGRectMake(159, 7, 20, 20);
//    _sexView.image = [UIImage imageNamed:@"user_male.png"];
    [_infoHeaderOne addSubview:_sexView];
    
    //年代view
    UIImageView *generationView = [[UIImageView alloc] init];
    generationView.frame = CGRectMake(_photoButton.frame.origin.x + _photoButton.frame.size.width + 5, 27, 20, 20);//x值根据头像View的坐标改变
    //generationView.frame = CGRectMake(180, 7, 20, 20);
    UIImage *generationImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user_generation" ofType:@"png"]];
    generationView.image = generationImg;
    [_infoHeaderOne addSubview:generationView];
    
    //年代label
    _generationLabel = [[UILabel alloc] init];
    _generationLabel.frame = CGRectMake(generationView.frame.origin.x + generationView.frame.size.width + 10, 27, 50, 20);//x值根据年代View的坐标改变
    //_generationLabel.frame = CGRectMake(200, 7, 50, 20);
    _generationLabel.text = @"";
    _generationLabel.font = [UIFont systemFontOfSize:16];
    _generationLabel.textAlignment = NSTextAlignmentLeft;
    _generationLabel.backgroundColor = [UIColor clearColor];
    [_infoHeaderOne addSubview:_generationLabel];
    
    //距离view
    UIImageView *distanceView = [[UIImageView alloc] init];
    distanceView.frame = CGRectMake(_generationLabel.frame.origin.x + _generationLabel.frame.size.width + 20 + 10, 27, 20, 20);//x值根据年代Label的坐标改变
    UIImage *distanceImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user_location" ofType:@"png"]];
    distanceView.image = distanceImg;
    [_infoHeaderOne addSubview:distanceView];
    
    //距离label
    _distanceLabel = [[UILabel alloc] init];
    _distanceLabel.frame = CGRectMake(distanceView.frame.origin.x + distanceView.frame.size.width + 10, 27, 75, 20);//x值根据距离View的坐标改变
    //    _distanceLabel.text = @"99999km";
    _distanceLabel.font = [UIFont systemFontOfSize:16];
    _distanceLabel.backgroundColor = [UIColor clearColor];
    _distanceLabel.textAlignment = NSTextAlignmentLeft;
    _distanceLabel.textColor = [UIColor blackColor];
    [_infoHeaderOne addSubview:_distanceLabel];
    
    //numberid view
    UIImageView *numberIDView = [[UIImageView alloc] init];
    numberIDView.frame = CGRectMake(_photoButton.frame.origin.x + _photoButton.frame.size.width + 5, 47, 20, 20);//x值根据头像View的坐标改变
    UIImage *numberIDImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user_numberid" ofType:@"png"]];
    numberIDView.image = numberIDImg;
    [_infoHeaderOne addSubview:numberIDView];
    
    //numberid label
    _numberIDLabel = [[UILabel alloc] init];
    _numberIDLabel.frame = CGRectMake(numberIDView.frame.origin.x + numberIDView.frame.size.width + 10, 47, 80, 20);//x值根据numberid view的坐标改变
    _numberIDLabel.text = @"";
    _numberIDLabel.font = [UIFont systemFontOfSize:16];
    _numberIDLabel.backgroundColor = [UIColor clearColor];
    _numberIDLabel.textAlignment = NSTextAlignmentLeft;
    [_infoHeaderOne addSubview:_numberIDLabel];
    
    //用户注册时间view
    UIImageView *regTimeView = [[UIImageView alloc] init];
    regTimeView.frame = CGRectMake(distanceView.frame.origin.x, 47, 20, 20);//x值根据距离View的坐标改变
    UIImage *regTimeImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"regTime" ofType:@"png"]];
    regTimeView.image = regTimeImg;
    [_infoHeaderOne addSubview:regTimeView];
    
    //用户注册时间
    _regTime = [[UILabel alloc] init];
    _regTime.frame = CGRectMake(regTimeView.frame.origin.x + regTimeView.frame.size.width + 10, 47, 90, 20);//x值根据用户注册时间view的坐标改变
    _regTime.text = @"2013-07-03";
    _regTime.font = [UIFont systemFontOfSize:16];
    _regTime.backgroundColor = [UIColor clearColor];
    _regTime.textAlignment = NSTextAlignmentLeft;
    _regTime.textColor = [UIColor blackColor];
    [_infoHeaderOne addSubview:_regTime];
    
    //二维码view
    _TDCview = nil;
//    _TDCview = [[UIImageView alloc] init];
//    _TDCview.frame = CGRectMake(240, 2, 75, 75);
//    //[_TDCview addDetailShow];
//    _TDCview.userInteractionEnabled = YES;
//    [Utility addTapGestureRecognizer:_TDCview withTarget:self action:@selector(goTDCCardInfo)];
//    _TDCview.backgroundColor = [UIColor grayColor];
    //[_infoHeaderOne addSubview:_TDCview];
    
    //个人签名label
    _autographLabel = [[UILabel alloc] init];
    _autographLabel.frame = CGRectMake(9, 70, 300, 40);
    _autographLabel.text = @"你在人生中做过的，都渺小如微尘微尘微尘微尘微尘微尘微尘";
    _autographLabel.font = [UIFont systemFontOfSize:16];
    _autographLabel.backgroundColor = [UIColor clearColor];
    _autographLabel.numberOfLines = 0;
    [_infoHeaderOne addSubview:_autographLabel];
    
    //信息部分二
    _infoHeaderTwo = [[UIView alloc] init];
    _infoHeaderTwo.frame = CGRectMake(0, 120, 320, 250);
    [_infoHeaderTwo setHidden:YES];
    
    UIImage *followBgImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user_follow_bg" ofType:@"png"]];
    
    //我关注的人
    _personIFollow = [UIButton buttonWithType:UIButtonTypeCustom];
    _personIFollow.frame = CGRectMake(17, 6, 58, 52);
    _personIFollow.backgroundColor = [UIColor clearColor];
    [_personIFollow setBackgroundImage:followBgImg forState:UIControlStateNormal];
    _personIFollow.tag = 0;
    [_personIFollow addTarget:self action:@selector(showUserList:) forControlEvents:UIControlEventTouchUpInside];
    [_infoHeaderTwo addSubview:_personIFollow];
    
    UILabel *numberLabel1 = [[UILabel alloc] init];
    numberLabel1.frame = CGRectMake(0, 0, 58, 17);
    numberLabel1.text = @"22";
    numberLabel1.textAlignment = NSTextAlignmentCenter;
    numberLabel1.textColor = [UIColor whiteColor];
    numberLabel1.font = [UIFont systemFontOfSize:14];
    numberLabel1.backgroundColor = [UIColor clearColor];
    numberLabel1.tag = 101;
    [_personIFollow addSubview:numberLabel1];
    
    UILabel *infoLabel1 = [[UILabel alloc] init];
    infoLabel1.frame = CGRectMake(6, 17, 46, 35);
    infoLabel1.text = @"我关注的人";
    infoLabel1.textColor = [UIColor whiteColor];
    infoLabel1.textAlignment = NSTextAlignmentCenter;
    infoLabel1.font = [UIFont systemFontOfSize:14];
    infoLabel1.numberOfLines = 2;
    infoLabel1.backgroundColor = [UIColor clearColor];
    [_personIFollow addSubview:infoLabel1];
    
    //关注我的人
    _personFollowMe = [UIButton buttonWithType:UIButtonTypeCustom];
    _personFollowMe.frame = CGRectMake(93, 6, 58, 52);
    _personFollowMe.backgroundColor = [UIColor clearColor];
    [_personFollowMe setBackgroundImage:followBgImg forState:UIControlStateNormal];
    _personFollowMe.tag = 1;
    [_personFollowMe addTarget:self action:@selector(showUserList:) forControlEvents:UIControlEventTouchUpInside];
    [_infoHeaderTwo addSubview:_personFollowMe];
    
    UILabel *numberLabel2 = [[UILabel alloc] init];
    numberLabel2.frame = CGRectMake(0, 0, 58, 17);
    numberLabel2.text = @"33";
    numberLabel2.textAlignment = NSTextAlignmentCenter;
    numberLabel2.textColor = [UIColor whiteColor];
    numberLabel2.font = [UIFont systemFontOfSize:14];
    numberLabel2.backgroundColor = [UIColor clearColor];
    numberLabel2.tag = 101;
    [_personFollowMe addSubview:numberLabel2];
    
    UILabel *infoLabel2 = [[UILabel alloc] init];
    infoLabel2.frame = CGRectMake(7, 17, 44, 35);
    infoLabel2.text = @"关注我的人";
    infoLabel2.textColor = [UIColor whiteColor];
    infoLabel2.textAlignment = NSTextAlignmentCenter;
    infoLabel2.font = [UIFont systemFontOfSize:14];
    infoLabel2.numberOfLines = 2;
    infoLabel2.backgroundColor = [UIColor clearColor];
    [_personFollowMe addSubview:infoLabel2];
    
    //我加入的俱乐部
    _clubIJoined = [UIButton buttonWithType:UIButtonTypeCustom];
    _clubIJoined.frame = CGRectMake(169, 6, 58, 52);
    _clubIJoined.backgroundColor = [UIColor clearColor];
    [_clubIJoined setBackgroundImage:followBgImg forState:UIControlStateNormal];
    _clubIJoined.tag = 2;
    [_clubIJoined addTarget:self action:@selector(showClubList:) forControlEvents:UIControlEventTouchUpInside];
    [_infoHeaderTwo addSubview:_clubIJoined];
    
    UILabel *numberLabel3 = [[UILabel alloc] init];
    numberLabel3.frame = CGRectMake(0, 0, 58, 17);
    numberLabel3.text = @"5";
    numberLabel3.textAlignment = NSTextAlignmentCenter;
    numberLabel3.textColor = [UIColor whiteColor];
    numberLabel3.font = [UIFont systemFontOfSize:14];
    numberLabel3.backgroundColor = [UIColor clearColor];
    numberLabel3.tag = 101;
    [_clubIJoined addSubview:numberLabel3];
    
    UILabel *infoLabel3 = [[UILabel alloc] init];
    infoLabel3.frame = CGRectMake(0, 17, 58, 35);
    infoLabel3.text = @"我加入的俱乐部";
    infoLabel3.textColor = [UIColor whiteColor];
    infoLabel3.textAlignment = NSTextAlignmentCenter;
    infoLabel3.font = [UIFont systemFontOfSize:14];
    infoLabel3.numberOfLines = 2;
    infoLabel3.backgroundColor = [UIColor clearColor];
    [_clubIJoined addSubview:infoLabel3];
    
    //我关注的俱乐部
    _clubIFollow = [UIButton buttonWithType:UIButtonTypeCustom];
    _clubIFollow.frame = CGRectMake(245, 6, 58, 52);
    _clubIFollow.backgroundColor = [UIColor clearColor];
    [_clubIFollow setBackgroundImage:followBgImg forState:UIControlStateNormal];
    _clubIFollow.tag = 3;
    [_clubIFollow addTarget:self action:@selector(showClubList:) forControlEvents:UIControlEventTouchUpInside];
    [_infoHeaderTwo addSubview:_clubIFollow];
    
    UILabel *numberLabel4 = [[UILabel alloc] init];
    numberLabel4.frame = CGRectMake(0, 0, 58, 17);
    numberLabel4.text = @"6";
    numberLabel4.textAlignment = NSTextAlignmentCenter;
    numberLabel4.textColor = [UIColor whiteColor];
    numberLabel4.font = [UIFont systemFontOfSize:14];
    numberLabel4.backgroundColor = [UIColor clearColor];
    numberLabel4.tag = 101;
    [_clubIFollow addSubview:numberLabel4];
    
    UILabel *infoLabel4 = [[UILabel alloc] init];
    infoLabel4.frame = CGRectMake(0, 17, 58, 35);
    infoLabel4.text = @"我关注的俱乐部";
    infoLabel4.textColor = [UIColor whiteColor];
    infoLabel4.textAlignment = NSTextAlignmentCenter;
    infoLabel4.font = [UIFont systemFontOfSize:14];
    infoLabel4.numberOfLines = 2;
    infoLabel4.backgroundColor = [UIColor clearColor];
    [_clubIFollow addSubview:infoLabel4];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, screenSize.height-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor whiteColor];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [_tableView setHidden:YES];
    [self.view addSubview:_tableView];
    
    __block typeof(self) bself = self;
    
    [_tableView addPullToRefreshWithActionHandler:^{
        if (bself.tableView.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            NSLog(@"refresh...");
            bself->updateNum = 1;
            bself.startKey = @"0";
            bself->_rp = [[RequestProxy alloc] init];
            bself->_rp.delegate = bself;
            [bself->_rp testPublicSettingWithNumberID:bself->_initValue];
            
//            [bself refreshPersonInfo];
//            [bself loadArticleData];
//            [bself.tableView.infiniteScrollingView stopAnimating];
            
        }
    }];
    
    [_tableView addInfiniteScrollingWithActionHandler:^{
        if (bself.tableView.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            NSLog(@"load more...");
            bself->updateNum = 2;
            [bself cleanTableFooter:bself->_tableView];
            if (bself->_rp == nil) {
                bself->_rp = [[RequestProxy alloc] init];
                bself->_rp.delegate = bself;
            }
            [bself->_rp testPublicSettingWithNumberID:bself->_initValue];
//            [bself loadArticleData];
            [bself.tableView.pullToRefreshView stopAnimating];
        }
    }];
    
    _articleArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAudioImg:) name:@"AUDIOPLAY_CHANGE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAudio) name:NOTIFICATION_KEY_AUDIOPLAY_STOPALLAUSERINFOAUDIO object:nil];
    
    _rp = [[RequestProxy alloc] init];
    _rp.delegate = self;
    
    [_rp testPublicSettingWithNumberID:_initValue];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"个人信息";
    self.navigationItem.titleView = headerLabel;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeList:) name:NOTIFICATION_KEY_INFOMENU object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_AUDIOPLAY_STOPALLARTICLEAUDIO object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_AUDIOPLAY_STOPALLAUSERINFOAUDIO object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_INFOMENU object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_INFOMENU object:nil];
//
//}

- (void)popViewController
{
    [_rp cancel];
    [self hideTitleViews];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_AUDIOPLAY_STOPALLARTICLEAUDIO object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_AUDIOPLAY_STOPALLAUSERINFOAUDIO object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_INFOMENU object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_AUDIOPLAY_STOPALLAUSERINFOAUDIO object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkSelf
{
    //加载菜单按钮，是用户本人信息则不显示菜单
    AccountUser *user = [AccountUser getSingleton];
    NSLog(@"a:%@,b:%@",user.numberID,_numberID);
    if (_numberID != nil && ![user.numberID isEqualToString:_numberID] &&
        [userFlag isEqualToString:@"0"]) {
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(0, 0, 30, 30);
        [menuButton setImage:[UIImage imageNamed:@"rightitem.png"] forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(showTitleViews) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightbtn = [[UIBarButtonItem alloc]initWithCustomView:menuButton];
        self.navigationItem.rightBarButtonItem = rightbtn;
    }
}

- (void)showMenu:(id)sender
{
    if (_popOverMenu == nil) {
        _menu = [[MenuListTableViewController alloc] initWithStyle:UITableViewStylePlain];
        
        _popOverMenu = [[FPPopoverController alloc] initWithViewController:_menu];
        _popOverMenu.tint = FPPopoverDefaultTint;
        _popOverMenu.delegate = self;
        _popOverMenu.arrowDirection = FPPopoverArrowDirectionAny;
    }
    
    [_menu setInFollow:_inFollow andInBlack:_inBlack];
    
    [_popOverMenu presentPopoverFromView:sender];
}

//标题栏弹出隐藏处理
- (void)showTitleViews{
    if (holeView.hidden) {
        [self setInFollow:_inFollow andInBlack:_inBlack];
        [holeView.layer addAnimation:[Utility createAnimationWithType:kCATransitionReveal withsubtype:kCATransitionFromTop withDuration:0] forKey:@"animation"];
        holeView.hidden = NO;
    }
    else{
        [self hideTitleViews];
    }
    
}

//标题栏隐藏处理
- (void)hideTitleViews{
    holeView.hidden = YES;
    //[[EGOCache currentCache]clearCache];
}

- (void)changeList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [categoryView removeFromSuperview];
    switch (btn.tag) {
        case 1:
            NSLog(@"关注。。。");
            if (_inBlack) {
                [self alertString:@"该用户在您的黑名单中，请先取消黑名单"];
            }else{
                if (_inFollow) {
                    [_rp cancelFollowPerson:_numberID];
                    [btn setTitle:@"加入关注" forState:UIControlStateNormal];
                }else{
                    [_rp followPerson:_numberID];
                    [btn setTitle:@"取消关注" forState:UIControlStateNormal];
                }
            }
            break;
        case 2:
            NSLog(@"黑名单。。。");
            if (_inFollow) {
                [self alertString:@"该用户在您的关注列表中，请先取消关注"];
            }else{
                if (_inBlack) {
                    [_rp blackCancel:_numberID];
                    [btn setTitle:@"加入黑名单" forState:UIControlStateNormal];
                }else{
                    [_rp blackAdd:_numberID];
                    [btn setTitle:@"取消黑名单" forState:UIControlStateNormal];
                }
            }
            break;
        case 3:
        {
            [self hideTitleViews];
            [self goTDCCardInfo];
        }
            break;
        case 4:
        {
            NSLog(@"举报。。。");
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择举报理由" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"垃圾广告", @"淫秽信息", @"不实信息", @"人身攻击", @"其他", nil];
            [sheet showInView:self.view];
        }
            break;
        case 5:
        {
            NSLog(@"私聊。。。");
            if (_numberID == nil) {
                [self alertString:@"未取得用户信息"];
            }else{
                for (int i = 0; i < [[self.navigationController viewControllers] count]; i++) {
                    if([[[self.navigationController viewControllers] objectAtIndex:i] class] == [DetailViewController class]) {
                        [self hideTitleViews];
                        [self.navigationController popViewControllerAnimated:YES];
                        return;
                    }
                }
                [_rp testPrivateLetterWithNumberID:_numberID];
            }
            
            break;
        }
        default:
            break;
    }
    [self hideTitleViews];
}

- (void)handleMenuListNotification:(NSNotification *)notification
{
    [_popOverMenu dismissPopoverAnimated:YES];
    
    NSNumber *index = notification.object;
    switch ([index intValue]) {
        case 0:
            NSLog(@"关注。。。");
            if (_inBlack) {
                [self alertString:@"该用户在您的黑名单中，请先取消黑名单"];
            }else{
                if (_inFollow) {
                    [_rp cancelFollowPerson:_numberID];
                }else{
                    [_rp followPerson:_numberID];
                }
            }
            break;
        case 1:
            NSLog(@"黑名单。。。");
            if (_inFollow) {
                [self alertString:@"该用户在您的关注列表中，请先取消关注"];
            }else{
                if (_inBlack) {
                    [_rp blackCancel:_numberID];
                }else{
                    [_rp blackAdd:_numberID];
                }
            }
            break;
        case 2:
        {
            NSLog(@"举报。。。");
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择举报理由" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"垃圾广告", @"淫秽信息", @"不实信息", @"人身攻击", @"其他", nil];
            [sheet showInView:self.view];
        }
            break;
        case 3:
        {
            NSLog(@"私聊。。。");
            if (_numberID == nil) {
                [self alertString:@"未取得用户信息"];
            }else{
                
               int index  = [[self.navigationController viewControllers] count] - 1;
                if([[[self.navigationController viewControllers] objectAtIndex:index] class] == [DetailViewController class]) {
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
                [_rp testPrivateLetterWithNumberID:_numberID];
            }
            
            break;
        }
        default:
            break;
    }
}
- (void)setInFollow:(BOOL)inFollow andInBlack:(BOOL)inBlack
{
    if (inFollow) {
        [_menuItemArray setObject:@"取消关注" atIndexedSubscript:0];
    }else {
        [_menuItemArray setObject:@"加入关注" atIndexedSubscript:0];
    }
    
    if (inBlack) {
        [_menuItemArray setObject:@"取消黑名单" atIndexedSubscript:1];
    }else {
        [_menuItemArray setObject:@"加入黑名单" atIndexedSubscript:1];
    }
    
    //[titleViews reloadData];
}

// 创建表格底部
- (void) createTableFooter:(UITableView *) tableView
{
    if([_infoHeaderTwo isHidden]){
        tableView.tableFooterView = nil;
        return;
    }
    
    tableView.tableFooterView = nil;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 40.0f)];
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 40.0f)];
    [loadMoreText setCenter:tableFooterView.center];
    loadMoreText.textAlignment = UITextAlignmentCenter;
    [loadMoreText setFont:[UIFont boldSystemFontOfSize:13.0f]];
    //判断是否到达最低
    if ([_startKey isEqualToString:@"end"]) {
        loadMoreText.text = NSLocalizedString(@"已经显示全部", @"Is All");
    }
    else{
        loadMoreText.text = NSLocalizedString(@"上拉显示更多数据", @"Pull up to refresh status");
    }
    [tableFooterView addSubview:loadMoreText];
    
    tableView.tableFooterView = tableFooterView;
}
- (void) cleanTableFooter:(UITableView *) tableView
{
    tableView.tableFooterView = nil;
    return;
}


#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    float height = 10;
//    if (indexPath.row == 0) {
//        height +=40;
//    }
//    NSDictionary *articleDic = [_articleArray objectAtIndex:indexPath.row];
//    NSString *content = [articleDic objectForKey:@"content"];
//    CGFloat contentHeight = [Utility getMixedViewHeight:content withWidth:300];
//    height += contentHeight + 10;
//    NSArray *attachmentArr = [articleDic objectForKey:@"attachment"];
//    if ([attachmentArr isKindOfClass:[NSArray class]] && [attachmentArr count]>0) {
//        height += 72;
//    }
//    height += 35 - 15;
//    return height;
    
    Article *topicArticle = [_articleArray objectAtIndex:(indexPath.row)];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_articleArray count];
//    return 5;
}

//跳到主题文章页
-(void)goTopicArticle:(int)indexNum{
    Article *topicArticle = [_articleArray objectAtIndex:(indexNum)];
    if (![topicArticle.content length]) {
        [Utility showHUD:@"该文章已被删除!"];
        return;
    }
    ArticleDetailViewController *articleDetailView = [[ArticleDetailViewController alloc]init];
    articleDetailView.indexNum = indexNum;
    articleDetailView.topicArticle = topicArticle;
    articleDetailView.lastViewController = self;
    articleDetailView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    [self.navigationController pushViewController:articleDetailView animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_AUDIOPLAY_STOPALLAUSERINFOAUDIO object:nil];
    [self goTopicArticle:indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"articleViewCell";
    ArticleCell  *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[ArticleCell alloc] initForPersonInfo] ;
//        cell = [[ArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    Article *topicArticle = [_articleArray objectAtIndex:(indexPath.row)];
    cell.tag = indexPath.row;
    cell.postClubLbl.tag = indexPath.row;
    cell.postClubLbl.userInteractionEnabled = YES;
    //    [Utility addTapGestureRecognizer:cell.postClubLbl withTarget:self action:@selector(goClub:)];
    [cell initCellWithArticle:topicArticle withViewController:self];
    
    return cell;
}

- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(250, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    [self attachString:str toView:view];
    return view.frame.size.height;
}

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self cutMixedString:str];
    //    NSLog(@"testarr:%@",testarr);
    
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
                        NSLog(@"ttt:%@",subString);
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
                    NSLog(@"mmm:%@",piece);
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
                
            }else if ([piece hasPrefix:@"http://"]){
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
    //    NSLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([type isEqualToString:REQUEST_TYPE_USERINFO]) {
        _dataDic = dic;
        NSDictionary *msgDic = [_dataDic objectForKey:@"msg"];
        NSDictionary *infoDic = [msgDic objectForKey:@"info"];
        
        //获取用户发表文章数
        articleCount = [infoDic objectForKey:@"article_count"];
        
        //获取用户状态
        userFlag = [msgDic objectForKey:@"flag"];
        
        //follow，black状态
        NSString *followStr = [infoDic objectForKey:@"infollow"];
        if ([followStr isKindOfClass:[NSString class]]) {
            if ([followStr isEqualToString:@"0"]) {
                _inFollow = NO;
            }else if ([followStr isEqualToString:@"1"]){
                _inFollow = YES;
            }
        }
        NSString *blackStr = [infoDic objectForKey:@"inblack"];
        if ([blackStr isKindOfClass:[NSString class]]) {
            if ([blackStr isEqualToString:@"0"]) {
                _inBlack = NO;
            }else if ([blackStr isEqualToString:@"1"]){
                _inBlack = YES;
            }
        }
        
        //修改Button内容
        if(_inFollow){
            [followBtn setTitle:@"取消关注" forState:UIControlStateNormal];
        }
        if (_inBlack) {
            [blackBtn setTitle:@"取消黑名单" forState:UIControlStateNormal];
        }
        
        //数据装入
        
        //头像view
        _strPhotoID = [infoDic objectForKey:@"photo"];
        [_photoView setImageWithURL:USER_HEAD_IMG_URL(@"small", _strPhotoID) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
        
        //头像button
        NSString *bigURL = USER_HEAD_IMG_PATH(@"big", _strPhotoID);
        _photoButton.titleLabel.text = bigURL;
        NSLog(@"fuckfuck:%@",bigURL);
        _photoButton.titleLabel.textColor = [UIColor clearColor];
        
        //姓名
        NSString *name = [infoDic objectForKey:@"name"];
        CGSize nameSize = [name sizeWithFont:_nameLabel.font];
        _nameLabel.text = name;
        CGRect nameRect = _nameLabel.frame;
        nameRect.size.width = nameSize.width>120?120:nameSize.width;
        _nameLabel.frame = nameRect;
        
        //性别view
        CGRect sexRect = _sexView.frame;
        sexRect.origin.x = _nameLabel.frame.origin.x+_nameLabel.frame.size.width+5;
        _sexView.frame = sexRect;
        _strSex = [infoDic objectForKey:@"sex"];
        if ([_strSex isEqualToString:@"0"]) {
            _sexView.image = [UIImage imageNamed:@"user_male.png"];
        }else if ([_strSex isEqualToString:@"1"]){
            _sexView.image = [UIImage imageNamed:@"user_female.png"];
        }
        
        //年代label
        NSString *generation = [infoDic objectForKey:@"birthday"];
        _generationLabel.text = generation;
        
        //距离label
        NSString *location = [infoDic objectForKey:@"location"];
        NSLog(@"location:%@",location);
        NSString *distance;
        if ([location isEqualToString:@"0"]) {
            distance = [Utility getDistanceString:@"0.01,0.01"];
        }else{
            distance = [Utility getDistanceString:location];
        }
        _distanceLabel.text = distance;
        
        _regTime.text = [infoDic objectForKey:@"reg_time"];
        
        //numberid label
        _numberID = [infoDic objectForKey:@"numberid"];
        _numberIDLabel.text = _numberID;
        
        //二维码生成
//        _TDCview.image = [QRCodeGenerator qrImageForString:CREATE_TDCSTRING(@"2", _numberID) imageSize:_TDCview.bounds.size.width*2];
        
        //个人签名
        NSString *desc = [infoDic objectForKey:@"desc"];
//        CGSize descSize = [desc sizeWithFont:_autographLabel.font constrainedToSize:CGSizeMake(300, 999)];
        _autographLabel.text = desc;
        for (UIView *view in _autographLabel.subviews) {
            [view removeFromSuperview];
        }
        [self attachString:_autographLabel.text toView:_autographLabel isAllBlack:YES];
        CGRect descRect = _autographLabel.frame;
//        descRect.size.height = descSize.height;
         descRect.size.height = [Utility getMixedViewHeight:_autographLabel.text withWidth:300];
        _autographLabel.text = @"";
        _autographLabel.frame = descRect;
        
        //更新info one部分的高度
        CGRect info1Rect = _infoHeaderOne.frame;
        info1Rect.size.height = descRect.size.height + 80;
        _infoHeaderOne.frame = info1Rect;
        _infoHeaderOneBgView.frame = info1Rect;
        
        //============若无权访问用户的信息则到此处为止============
        NSString *resultStr = [_dataDic objectForKey:@"result"];
        int result = [resultStr intValue];
        if (result == 1) {
            UIView *view = [[UIView alloc] init];
            view.frame = CGRectMake(0, 0, 320, _infoHeaderOne.frame.size.height+_infoHeaderTwo.frame.size.height);
            [view addSubview:_infoHeaderOne];
            [_infoHeaderOne setHidden:NO];
            _tableView.tableHeaderView = view;
            _tableView.separatorColor = [UIColor whiteColor];
            
            [_tableView setHidden:NO];
            [_tableView.pullToRefreshView stopAnimating];
            [_tableView.infiniteScrollingView stopAnimating];
            [_tableView reloadData];
            [self checkSelf];
            return;
        }
        
        _tableView.separatorColor = [UIColor grayColor];
        
        //信息部分2
        //我关注的人
        UILabel *label1 = (UILabel *)[_personIFollow viewWithTag:101];
        label1.text = [infoDic objectForKey:@"i_follow_count"];
        
        //关注我的人
        UILabel *label2 = (UILabel *)[_personFollowMe viewWithTag:101];
        label2.text = [infoDic objectForKey:@"follow_me_count"];
        
        //我加入的俱乐部
        UILabel *label3 = (UILabel *)[_clubIJoined viewWithTag:101];
        label3.text = [infoDic objectForKey:@"in_club_count"];
        if (label3.text == nil) {
            label3.text = @"0";
        }
        
        //我关注的俱乐部
        UILabel *label4 = (UILabel *)[_clubIFollow viewWithTag:101];
        label4.text = [infoDic objectForKey:@"follow_club_count"];
        
        //加载附件
        int count = [[msgDic objectForKey:@"count"] intValue];
        if (count>0) {
            _attachmentArray = [msgDic objectForKey:@"attachment"];
            _attachmentInfoArray = [msgDic objectForKey:@"attachmentInfo"];
            if ([_attachmentArray isKindOfClass:[NSArray class]] && count == [_attachmentArray count]) {
                int nPhotoTag = 0;
                for (int index=0; index<count; index++) {
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.tag = index;
                    btn.frame = CGRectMake((15+76*index)%304, 66+(index/4)*75, 62, 62);
                    btn.backgroundColor = [UIColor clearColor];
                    NSString *attachmentStr = [_attachmentArray objectAtIndex:index];
                    NSString *type = [attachmentStr substringFromIndex:attachmentStr.length-1];
                    NSString *fileID = [attachmentStr substringToIndex:attachmentStr.length-2];
                    if ([type isEqualToString:@"p"]) {
                        if (!userInfoPhotosArray) {
                            userInfoPhotosArray = [[NSMutableArray alloc] initWithCapacity:3];
                        }
                        [userInfoPhotosArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:USER_WINDOW_PIC_PATH(fileID, TYPE_RAW)]]];
                        
                        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
                        [imgView setImageWithURL:[NSURL URLWithString:USER_WINDOW_PIC_PATH(fileID, TYPE_THUMB)]];
                        imgView.backgroundColor = [UIColor grayColor];
                        btn.titleLabel.text = USER_WINDOW_PIC_PATH(fileID, TYPE_RAW);
                        btn.tag = nPhotoTag++;
                        [btn addTarget:self action:@selector(playPicture:) forControlEvents:UIControlEventTouchUpInside];
                        [btn addSubview:imgView];
                    }else if ([type isEqualToString:@"a"]){
                        [btn setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
                        btn.titleLabel.text = fileID;
                        btn.tag = 101;
                        [btn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
                        
                        //附件时间长度
                        UILabel *audioLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 46, 62, 16)];
                        audioLengthLbl.text = [[NSString alloc] initWithFormat:@"%@''", [[_attachmentInfoArray objectForKey:attachmentStr] objectForKey:DURATION]];
                        [Utility styleLbl:audioLengthLbl withTxtColor:nil withBgColor:nil withFontSize:10];
                        audioLengthLbl.textAlignment = NSTextAlignmentCenter;
                        [btn addSubview:audioLengthLbl];
                    }else if ([type isEqualToString:@"v"]){
                        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
                        [imgView setImageWithURL:[NSURL URLWithString:USER_WINDOW_PIC_PATH(fileID, TYPE_THUMB)]];
                        imgView.backgroundColor = [UIColor grayColor];
                        [btn addSubview:imgView];
                        btn.titleLabel.text = USER_WINDOW_PIC_PATH(fileID, TYPE_RAW);
                        btn.tag = 102;
                        [btn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                        UIImageView *playTag = [[UIImageView alloc] init];
                        playTag.frame = CGRectMake(16, 16, 30, 30);
                        playTag.backgroundColor = [UIColor clearColor];
                        playTag.image = [UIImage imageNamed:@"chat_video_play.png"];
                        [btn addSubview:playTag];
                        
                        //附件时间长度
                        UILabel *audioLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 46, 62, 16)];
                        audioLengthLbl.text = [[NSString alloc] initWithFormat:@"%@''", [[_attachmentInfoArray objectForKey:attachmentStr] objectForKey:DURATION]];
                        [Utility styleLbl:audioLengthLbl withTxtColor:nil withBgColor:nil withFontSize:10];
                        audioLengthLbl.textAlignment = NSTextAlignmentCenter;
                        audioLengthLbl.backgroundColor = [UIColor blackColor];
                        audioLengthLbl.alpha = 0.7;
                        [btn addSubview:audioLengthLbl];
                    }
                    [Utility psImageView:btn];
                    [btn addTarget:self action:@selector(playAttachment:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [_infoHeaderTwo addSubview:btn];
                }
            }
        }
        
        
        _infoHeaderTwo.frame = CGRectMake(0, _infoHeaderOne.frame.size.height, 320, 66+((count+3)/4)*75 + 32);
        
        //我的文章数
        if (![articleCount isEqualToString:@"0"]) {
            UILabel *myArticleLabel = [[UILabel alloc] init];
            myArticleLabel.text = [[NSString alloc] initWithFormat:@"我的文章(%@)", articleCount];
            myArticleLabel.frame = CGRectMake(10, _infoHeaderTwo.frame.size.height - 32, 120, 30);
            myArticleLabel.textAlignment = NSTextAlignmentLeft;
            myArticleLabel.textColor = [UIColor grayColor];
            [_infoHeaderTwo addSubview:myArticleLabel];
            
            UIImageView *headline = [[UIImageView alloc] init];
            headline.frame = CGRectMake(0, _infoHeaderTwo.frame.size.height, 320, 2);
            headline.backgroundColor = [UIColor grayColor];
            [_infoHeaderTwo addSubview:headline];
        }
        
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, 320, _infoHeaderOne.frame.size.height+_infoHeaderTwo.frame.size.height);
        [view addSubview:_infoHeaderOne];
        [view addSubview:_infoHeaderTwo];
        [_infoHeaderOne setHidden:NO];
        [_infoHeaderTwo setHidden:NO];
        _tableView.tableHeaderView = view;
        
        [_tableView setHidden:NO];
        [_tableView.pullToRefreshView stopAnimating];
        [_tableView.infiniteScrollingView stopAnimating];
        [_tableView reloadData];
        
        [self checkSelf];
    }
    else if ([type isEqualToString:REQUEST_TYPE_USERARTICLE]){
        if ([_startKey isEqualToString:@"0"] || [_startKey isEqualToString:@"end"]) {
            [_articleArray removeAllObjects];
        }
        _startKey = [dic objectForKey:@"startKey"];
        NSArray *array = [dic objectForKey:@"articleList"];
        if (array != nil && [array isKindOfClass:[NSArray class]] &&([array count])) {
            for (int index=0; index<[array count]; index++) {
                Article *article = [[Article alloc]initWithDictionary:[array objectAtIndex:index]];
                [_articleArray addObject:article];
                article = nil;
            }
        }
        
        [_tableView setHidden:NO];
        [_tableView.pullToRefreshView stopAnimating];
        [_tableView.infiniteScrollingView stopAnimating];
        [_tableView reloadData];
    }
    else if ([type isEqualToString:REQUEST_TYPE_PRIVATE_LETTER]){
        NSString *pass = [dic objectForKey:@"pass"];
//        NSLog(@"result:%@,%@",result,[result class]);
//        NSString *msg = [[dic objectForKey:@"msg"] objectAtIndex:0];
//        [self alertString:msg];
        if ([pass isKindOfClass:[NSString class]] && [pass isEqualToString:@"1"]) {
            FriendModel *friend = [[FriendModel alloc] init];
            friend.friendID = _numberID;
            friend.masterID = [AccountUser getSingleton].numberID;
            NSDictionary *msgDic = [_dataDic objectForKey:@"msg"];
            NSDictionary *infoDic = [msgDic objectForKey:@"info"];
            NSLog(@"_dataDic:%@",_dataDic);
            friend.name = [infoDic objectForKey:@"name"];
            friend.sex = [infoDic objectForKey:@"sex"];
            friend.photo = [infoDic objectForKey:@"photo"];
            friend.lastMsg = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_ADDFRIEND object:friend];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_INFOMENU object:nil];
        }else{
            [self alertString:@"没有权限与该用户私聊"];
        }
    }
    else if ([type isEqualToString:REQUEST_TYPE_FOLLOWPERSON]){
        _inFollow = YES;
        [_menu setInFollow:_inFollow andInBlack:_inBlack];
        [Utility showHUD:@"已关注该用户"];
    }
    else if ([type isEqualToString:REQUEST_TYPE_CANCELFOLLOWPERSON]){
        _inFollow = NO;
        [_menu setInFollow:_inFollow andInBlack:_inBlack];
        [Utility showHUD:@"已取消关注该用户"];
    }
    else if ([type isEqualToString:REQUEST_TYPE_BLACKADD]){
        _inBlack = YES;
        [_menu setInFollow:_inFollow andInBlack:_inBlack];
        [Utility showHUD:@"已将该用户加入黑名单"];
    }
    else if ([type isEqualToString:REQUEST_TYPE_BLACKCANCEL]){
        _inBlack = NO;
        [_menu setInFollow:_inFollow andInBlack:_inBlack];
        [Utility showHUD:@"已将该用户从黑名单中移除"];
    }
    else if ([type isEqualToString:REQUEST_TYPE_REPORTPERSON]){
        [Utility showHUD:@"举报成功"];
    }
    else if ([type isEqualToString:REQUEST_TYPE_PUBLIC_SETTING]){
        
        NSString *pass = [dic objectForKey:@"pass"];
        if (![pass isKindOfClass:[NSString class]]) {
            [Utility showHUD:@"数据错误"];
            return;
        }
        if ([pass isEqualToString:@"1"]) {
            [_rp getUserInfoByKey:_initKey andValue:_initValue];
            if ((updateNum != 2 && _startKey > 0) || _startKey == nil) {
                _startKey = @"0";
            }
            [_personIFollow setHidden:NO];
            [_personFollowMe setHidden:NO];
            [_clubIFollow setHidden:NO];
            [_clubIJoined setHidden:NO];
            [_infoHeaderTwo setHidden:NO];
//            [self loadArticleData];
        }else if([pass isEqualToString:@"0"]){
            //没有权限查看用户信息的处理
            [_rp getUserInfoByKey:_initKey andValue:_initValue];
            _startKey = @"0";
            [_personIFollow setHidden:YES];
            [_personFollowMe setHidden:YES];
            [_clubIFollow setHidden:YES];
            [_clubIJoined setHidden:YES];
            [_infoHeaderTwo setHidden:YES];
            
            //follow，black状态
            NSString *followStr = [dic objectForKey:@"infollow"];
            if ([followStr isKindOfClass:[NSString class]]) {
                if ([followStr isEqualToString:@"0"]) {
                    _inFollow = NO;
                }else if ([followStr isEqualToString:@"1"]){
                    _inFollow = YES;
                }
            }
            NSString *blackStr = [dic objectForKey:@"inblack"];
            if ([blackStr isKindOfClass:[NSString class]]) {
                if ([blackStr isEqualToString:@"0"]) {
                    _inBlack = NO;
                }else if ([blackStr isEqualToString:@"1"]){
                    _inBlack = YES;
                }
            }
            
            _tableView.separatorColor = [UIColor whiteColor];
            [_articleArray removeAllObjects];
            [_tableView reloadData];
            [self checkSelf];
        }else if ([pass isEqualToString:@"-1"]){
            [self alertString:@"没有该用户的信息"];
        }
    }
    
    [self createTableFooter:_tableView];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self alertString:excepDesc andTag:101];
//    [self popViewController];
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [self popViewController];

}

- (void)playAttachment:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int index = btn.tag;
    NSLog(@"attachment index:%d",index);
}

- (void)refreshPersonInfo
{
    [_rp getUserInfoByKey:_initKey andValue:_initValue];
    
    
}

- (void)loadArticleData
{
    if ([_personIFollow isHidden]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_tableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1];
        return;
    }
    if ([_startKey isEqualToString:@"end"]) {
        NSLog(@"That's the end!");
        [_tableView.infiniteScrollingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1];
//        [self performSelector:@selector(alertString:) withObject:@"已显示全部" afterDelay:1];
        [self createTableFooter:_tableView];
        return;
    }
    [_rp getUserArticles:@"1" count:@"5" startKey:_startKey id:_initValue key:_initKey];
}

- (void)alertString:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)alertString:(NSString *)str andTag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.delegate = self;
    alert.tag = tag;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 101:
            [self popViewController];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"click index:%d",buttonIndex);
    NSArray *reasonArray = [NSArray arrayWithObjects:@"垃圾广告", @"淫秽信息", @"不实信息", @"人身攻击", @"其他", nil];
    if (buttonIndex < [reasonArray count]) {
        [_rp reportPerson:@"3" reason:[reasonArray objectAtIndex:buttonIndex] numberid:_numberID];
    }
}

#pragma mark - ShowPictures
- (void)playPicture:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"test:%@",btn.titleLabel.text);
    if (btn.titleLabel.text == nil) {
        return;
    }
    
    //初始化照片信息
    [photoArray removeAllObjects];
    if (!photoArray) {
        photoArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    if ([USER_HEAD_IMG_PATH(@"big", _strPhotoID) isEqualToString:btn.titleLabel.text]) {
        [photoArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:btn.titleLabel.text]]];
    }
    else{
        [photoArray removeAllObjects];
        photoArray = nil;
        photoArray = [[NSMutableArray alloc] initWithArray:userInfoPhotosArray];
    }
    
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    [mwBrowser setInitialPageIndex:btn.tag];
    [self presentModalViewController:nav animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return photoArray.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    if (index < photoArray.count)
        return [photoArray objectAtIndex:index];
    return nil;
}

#pragma mark - PlayAudio
- (void)playAudio:(id)sender
{
    NSLog(@"playAudio...");

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_AUDIOPLAY_STOPALLARTICLEAUDIO object:nil];
    
    UIButton *btn = (UIButton *)sender;
//    if (_lastAudioButton != nil) {
//        [self stopAudio];
//    }
    
    if (btn != nil) {
        if (_lastAudioButton == btn) {
            [_audioPlay stop];
            [_lastAudioButton setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
        }
        else{
            _lastAudioButton = btn;
            NSString *fileName = btn.titleLabel.text;
            _audioPlay = [AudioPlay getSingleton];
            
            
            if (btn.tag == 101) {
                [_audioPlay playAudiowithType:@"personAudio" withView:btn withFileName:fileName withStyle:0];
            }else if (btn.tag >= 102){
                //        [_tableView reloadData];
                [_audioPlay playAudiowithType:@"article" withView:btn withFileName:fileName withStyle:1];
            }
        }
    }
}

- (void)stopAudio{
    NSLog(@"stopAudio...");
    if (_lastAudioButton != nil) {
        [_lastAudioButton setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
        [_audioPlay stop];
        _lastAudioButton = nil;
    }
}

- (void)playVideo:(id)sender
{
    NSLog(@"playVideo...");
    UIButton *btn = (UIButton *)sender;
    NSString *urlString = btn.titleLabel.text;
    NSLog(@"urlstring:%@",urlString);
    vp = [VideoPlayer getSingleton];
    NSLog(@"urlString%@",urlString);
    if (btn.tag == 101) {
        [vp playVideoWithURL:urlString withType:@"articleVideo" view:self];
    }else if (btn.tag == 102){
        [vp playVideoWithURL:urlString withType:@"personVideo" view:self];
    }
}

- (void)attachString:(NSString *)str toView:(UIView *)targetView isAllBlack:(BOOL)allBlack
{
    NSMutableArray *testarr= [self cutMixedString:str];
//    NSLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    UIColor *nameColor = nil;
    UIColor *labelColor = nil;
    UIColor *linkerColor = nil;
    if (allBlack == YES) {
        nameColor = [UIColor blackColor];
        labelColor = [UIColor blackColor];
        linkerColor = [UIColor blackColor];
    }
    else{
        nameColor = [UIColor blueColor];
        labelColor = [UIColor redColor];
        linkerColor = [UIColor greenColor];
    }
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
                        NSLog(@"ttt:%@",subString);
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
                    NSLog(@"mmm:%@",piece);
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
//    NSLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

- (NSMutableArray *)cutMixedString:(NSString *)str
{
//    NSLog(@"str to be cut:%@",str);
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
            NSLog(@"fuck substring:%@",subString);
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
//                NSLog(@"headStr:%@",headStr);
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
//                NSLog(@"headStr:%@",headStr);
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

- (void)selectLabel:(id)sender
{
    //    NSLog(@"选择######");
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    NSLog(@"label:%@",str);
    NSString *topic = [str substringWithRange:NSMakeRange(1, str.length-2)];
    TopicArticleListViewController *topicArticleListView = [[TopicArticleListViewController alloc]initWithTopic:topic withType:@"0"];
    [self.navigationController pushViewController:topicArticleListView animated:YES];
}

- (void)selectName:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    NSString *name = [str substringWithRange:NSMakeRange(1, str.length-2)];
    if (name.length > 0) {
        PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] initWithUserName:name];
        [self.navigationController pushViewController:personInfo animated:YES];
    }
}

- (void)selectLinker:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    NSLog(@"linker:%@",str);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
}

- (void)changeAudioImg:(NSNotification *)notification
{
    NSLog(@"changeAudioImg...");
//    [_tableView reloadData];

    NSString *flag = (NSString *)notification.object;
    if ([flag isEqualToString:@"stop"]) {
        NSLog(@"flag:%@",flag);
        [_tableView reloadData];
    }else if ([flag isEqualToString:@"start"]){
        [_lastAudioButton setImage:[UIImage imageNamed:@"audio_pause.png"] forState:UIControlStateNormal];
    }else if ([flag isEqualToString:@"start_UserInfo"]){
        
    }
    else if ([flag isEqualToString:@"stop_UserInfo"]){
        
    }
    
}

//四个跳转
- (void)showUserList:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int tag = btn.tag;
    SuperUserListViewController *superUserList = [[SuperUserListViewController alloc] initWithNumberID:_numberID andType:tag];
    superUserList.userName = _nameLabel.text;
    [self.navigationController pushViewController:superUserList animated:YES];
}

- (void)showClubList:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int tag = btn.tag;
    NSLog(@"userRowKey:%@",[_dataDic objectForKey:KEY_USER_ROW_KEY]);
    ListViewController *clubList = [[ListViewController alloc]initWithUserRowKey:[[[_dataDic objectForKey:@"msg" ]objectForKey:@"info"] objectForKey:KEY_USER_ROW_KEY] withType:tag withName:_nameLabel.text];
    clubList.userName = _nameLabel.text;

    [self.navigationController pushViewController:clubList animated:YES];
}

//跳到二维码信息页
-(void)goTDCCardInfo
{
    TDCCardViewController *tdc = [[TDCCardViewController alloc] init];
    [tdc setBIsCurrentUser:FALSE];
    [tdc set_strUserID:_numberIDLabel.text];
    [tdc set_strUserName: _nameLabel.text];
    [tdc set_strSex: _strSex];
    [tdc set_strPhotoID: _strPhotoID];
    [self.navigationController pushViewController:tdc animated:YES];
}

@end
