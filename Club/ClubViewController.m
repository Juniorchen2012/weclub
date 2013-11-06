//
//  ClubViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//


#import "ClubViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareSDKManager.h"
#import "VideoPlayer.h"

#define DISPLAY_WINDOWN_SIZE 65
@interface ClubViewController ()

@end

@implementation ClubViewController
{
    int              _adoptFlag;          //hasphoto  是否有班标
}

@synthesize club,isLoadMore,myTable,isPushFromNewClub;
static int lastPlayAudioNO = -1;
- (void)viewDidUnload{
    [super viewDidUnload];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithNumberID:(NSString *)clubRowKey
{
    self = [super init];
    if (self) {
        Club *myClub = [[Club alloc]init];
        myClub.ID = clubRowKey;
        self.club = myClub;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
//    [rp cancel];在back返回的时候取消请求
//    [request cancelRequest];在back返回的时候取消请求

    [newPlayer stop];
    lastPlayAudioNO = -1;
    [audioPlay stop];
    [[VideoPlayer getSingleton] VideoDownLoadCancel];
    [myTable setEditing:NO];
    editLbl.text = @"批量删除";
    [self stop];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [myTable deselectRowAtIndexPath:[myTable indexPathForSelectedRow] animated:YES];
    //    [myTable reloadData];
    [self refreshTopView];
    //    [self refreshData];
    [self prepareImageView];
    [self refreshDisplayView];
    [self addToolBar];
}

-(void)viewDidAppear:(BOOL)animated{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    self.title = club.name;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //infoView
    infoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 105)];
    [Utility addTapGestureRecognizer:infoView withTarget:self action:@selector(goClubInfo)];
    //myTable
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20-40)];
    myTable.dataSource = self;
    myTable.delegate = self;
    myTable.scrollsToTop = YES;
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    //tableView的headerView
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 190)];
    bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 160)];
    //  bg.image = [UIImage imageNamed:@"bg.png"];
    bg.backgroundColor = TINT_COLOR;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:bg];
    //   headerView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    listSwitchView = [[UIView alloc]initWithFrame:CGRectMake(0, 170, 320, 30)];
    listSwitchView.backgroundColor = [UIColor clearColor];
    banMianBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    banMianBtn.frame = CGRectMake(5, 0, 65, 30);
    [banMianBtn setTag:0];
    [banMianBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [banMianBtn setTitle:@"版面" forState:UIControlStateNormal];
    [banMianBtn setBackgroundImage:[UIImage imageNamed:@"banMianSelected.png"] forState:UIControlStateNormal];
    [banMianBtn addTarget:self action:@selector(switchList:) forControlEvents:UIControlEventTouchUpInside];
    goodArticleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    goodArticleBtn.frame = CGRectMake(70, 0, 65, 30);
    [goodArticleBtn setTag:1];
    [goodArticleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [goodArticleBtn setTitle:@"精华区" forState:UIControlStateNormal];
    [goodArticleBtn setBackgroundImage:[UIImage imageNamed:@"goodArticle.png"] forState:UIControlStateNormal];
    [goodArticleBtn addTarget:self action:@selector(switchList:) forControlEvents:UIControlEventTouchUpInside];
    [listSwitchView addSubview:banMianBtn];
    [listSwitchView addSubview:goodArticleBtn];
    [headerView addSubview:listSwitchView];
    
    [self.view addSubview:myTable];
    [self createView];
    imgArray = [[NSMutableArray alloc]init];
    photos = [[NSMutableArray alloc] init];
    toDeleteList = [[NSMutableArray alloc]init];
    
    listType = 0;
    NSMutableArray *banMianArticlelist;//版面文章列表
    NSMutableArray *goodArticleList;//精华区文章列表
    banMianArticlelist = [[NSMutableArray alloc]init];
    articlelist = [[NSMutableArray alloc]init];
    stickArticleList = [[NSMutableArray alloc]init];
    goodArticleList = [[NSMutableArray alloc]init];
    [articlelist addObject:banMianArticlelist];
    [articlelist addObject:goodArticleList];
    __weak __block typeof(self)bself = self;
    
    [myTable addPullToRefreshWithActionHandler:^{
        WeLog(@"触发下拉..");
        if (bself.myTable.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
            [bself refreshData];
        }
    }];
    [myTable addInfiniteScrollingWithActionHandler:^{
        if (bself.myTable.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            if (bself.myTable.isEditing) {
                [bself stop];
                return;
            }
            [bself loadData];
            
        }else{
            [bself.myTable.infiniteScrollingView stopAnimating];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:)
                                                 name:@"POST_ARTICLE_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAfterDelete:)
                                                 name:@"DELETE_ARTICLE_SUCCESS" object:nil];
    
    rp = [[RequestProxy alloc] init];
    rp.delegate = self;
    request = [[Request alloc]init];
    audioPlay = [AudioPlay getSingleton];
    
    isLoadMore = NO;
    videoPlay = [VideoPlayer getSingleton];
    [self refreshData];
}

//切换版面和精华区
- (void)switchList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    listType = btn.tag;
    myTable.tableFooterView = nil;
    //0,版面 1,精华区
    if (listType) {
        [banMianBtn setBackgroundImage:[UIImage imageNamed:@"banMian.png"] forState:UIControlStateNormal];
        [banMianBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [goodArticleBtn setBackgroundImage:[UIImage imageNamed:@"goodArticleSelected.png"] forState:UIControlStateNormal];
        [goodArticleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [banMianBtn setBackgroundImage:[UIImage imageNamed:@"banMianSelected.png"] forState:UIControlStateNormal];
        [banMianBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [goodArticleBtn setBackgroundImage:[UIImage imageNamed:@"goodArticle.png"] forState:UIControlStateNormal];
        [goodArticleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [self addToolBar];
    [self loadData];
}

- (void)createView{
    //topView descLbl bottomView
    logo = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
    logo.layer.masksToBounds = YES;
    logo.layer.cornerRadius = 5;
    [infoView addSubview:logo];
    
    _nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 155, 20)];
    [Utility styleLbl:_nameLbl withTxtColor:COLOR_BLACK withBgColor:nil withFontSize:16];
    _nameLbl.font = [UIFont boldSystemFontOfSize:16];

    starLevelView = [[UIView alloc]initWithFrame:CGRectMake(90, 0, 100, 20)];
    
    //避开滚动条
    UIImageView * distaneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location.png"]];
    distaneIcon.frame = CGRectMake(155, 4, 12, 12);
    distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(170, 0, 80, 20)];
    [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:14];
    
    UIView *TopView = [[UIView alloc]initWithFrame:CGRectMake(70, 5, 250, 14)];
    [TopView addSubview:_nameLbl];
    [TopView addSubview:starLevelView];
    [TopView addSubview:distanceLbl];
    [TopView addSubview:distaneIcon];
    [infoView addSubview:TopView];
    
    descLbl = [[UILabel alloc]initWithFrame:CGRectMake(70, 25, 245, 50)];
    descLbl.numberOfLines = 2;
    [Utility styleLbl:descLbl withTxtColor:nil withBgColor:nil withFontSize:13];
    
    [infoView addSubview:descLbl];
    
    categoryLbl = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 50, 14)];
    [Utility styleLbl:categoryLbl withTxtColor:nil withBgColor:nil withFontSize:12];
    
    UIImageView * categoryIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"type.png"]];
    [categoryIcon setFrame:CGRectMake(0, 0, 12, 12)];
    memberCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(76, 1, 50, 12)];
    [Utility styleLbl:memberCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
    
    UIImageView * memberIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"member_count.png"]];
    [memberIcon setFrame:CGRectMake(62, 0, 12, 12)];
    topicCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(200, 1, 50, 12)];
    [Utility styleLbl:topicCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
    
    UIImageView * topicIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_count.png"]];
    [topicIcon setFrame:CGRectMake(186, 0, 12, 12)];
    
    followCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(138, 1, 50, 12)];
    [Utility styleLbl:followCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
    
    UIImageView * followIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"follow_count.png"]];
    [followIcon setFrame:CGRectMake(124, 0, 12, 12)];
    
    adminLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 17, 140, 14)];
    [Utility styleLbl:adminLbl withTxtColor:nil withBgColor:nil withFontSize:14];
    
    viceAdminsLbl = [[UILabel alloc]initWithFrame:CGRectMake(140, 17, 100, 14)];
    [Utility styleLbl:viceAdminsLbl withTxtColor:nil withBgColor:nil withFontSize:14];
    viceAdminsLbl.text = @"";
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(70, 68, 200, 26)];
    [bottomView addSubview:categoryIcon];
    [bottomView addSubview:memberIcon];
    [bottomView addSubview:topicIcon];
    [bottomView addSubview:followIcon];
    [bottomView addSubview:categoryLbl];
    [bottomView addSubview:memberCountLbl];
    [bottomView addSubview:topicCountLbl];
    [bottomView addSubview:followCountLbl];
    [bottomView addSubview:adminLbl];
    [bottomView addSubview:viceAdminsLbl];
    
    [infoView addSubview:bottomView];
    [headerView addSubview:infoView];
    [self addToolBar];
}

-(void)refreshTopView{
    //    [self refreshTitleView];
    self.title = club.name;
    CLUB_LOGO(logo, club.ID,club.picTime);
    distanceLbl.text = club.distance;
    _nameLbl.text = club.name;
    descLbl.text = club.desc;
    //    [self attachString:descLbl.text toView:descLbl];
    [Utility removeSubViews:descLbl];
    [Utility emotionAttachString:descLbl.text toView:descLbl font:15 isCut:NO];
    descLbl.text = @"";
    categoryLbl.text = [myConstants.clubCategory objectAtIndex:[club.category intValue]];
    memberCountLbl.text = [Utility numberSwitch:club.memberCount];
    topicCountLbl.text = [Utility numberSwitch:club.articleCount];
    followCountLbl.text = [Utility numberSwitch:club.followCount];
    adminLbl.text = [NSString stringWithFormat:@"版主:%@",[club.admin  objectForKey:KEY_NAME]];
    if (![club.admin  objectForKey:KEY_NAME]) {
        adminLbl.text = @"";
    }
    NSMutableString *viceString = [[NSMutableString alloc] initWithString:@"版副:"];
    //从版副改为显示个数
    if ([club.viceAdmins count]) {
        viceAdminsLbl.text = [NSString stringWithFormat:@"%@%d",viceString,[club.viceAdmins count]];
    }
    [Utility initStarLevelView:club.starLevel withStarView:starLevelView];
}

//定制底边的工具栏
-(void)addToolBar{
    //toolBar 高度40
    [toolBar removeFromSuperview];
    toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, myConstants.screenHeight-20-44-40, 320, 40)];
    UIImageView *toolBarBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    [toolBar addSubview:toolBarBg];
    UIButton *joinBtn;
    UIImageView *joinImg;
    UILabel *joinLbl;
    UIButton *postBtn;
    UIImageView *postImg;
    UILabel *postLbl;
    UIButton *followBtn;
    UILabel *followLbl;
    UIImageView *followImg;
    if (club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN){
        toolBarBg.image = [UIImage imageNamed:@"toolbar_bg3.png"];
        //分享按钮
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.tag = SHARE;
        shareBtn.frame = CGRectMake(106, 0, 106, 40);
        UIImageView *shareImg = [[UIImageView alloc]initWithFrame:CGRectMake(215, 5, 14, 28)];
        //    shareImg.image = [UIImage imageNamed:@"share.png"];
        [shareBtn setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (shareBtn.frame.size.width-16)/2, 18, (shareBtn.frame.size.width-16)/2);
        
        [shareBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *shareLbl = [[UILabel alloc]initWithFrame:CGRectMake(shareBtn.frame.origin.x, 27, shareBtn.frame.size.width, 14)];
        shareLbl.textAlignment = UITextAlignmentCenter;
        [Utility styleLbl:shareLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        shareLbl.text = @"分享";
        
        UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        postBtn.tag = POST;
        postBtn.frame = CGRectMake(0, 0, 106,40);
        [postBtn setImage:[UIImage imageNamed:@"post.png"] forState:UIControlStateNormal];
        postBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (postBtn.frame.size.width-16)/2, 18, (postBtn.frame.size.width-16)/2);
        [postBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *postImg = [[UIImageView alloc]initWithFrame:CGRectMake(85, 5, 20,20)];
        //    postImg.image = [UIImage imageNamed:@"post.png"];
        UILabel *postLbl = [[UILabel alloc]initWithFrame:CGRectMake(postBtn.frame.origin.x, 27, postBtn.frame.size.width, 14)];
        postLbl.textAlignment = UITextAlignmentCenter;
        postLbl.text = @"发文";
        [Utility styleLbl:postLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        
        //精华区没有批量删除
        
        //编辑按钮
        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.tag = REPORT;
        editBtn.frame = CGRectMake(212, 0, 106, 40);
        //    reportImg.image = [UIImage imageNamed:@"report.png"];
        [editBtn setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        editBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 46, 21, 46);
        
        [editBtn addTarget:self action:@selector(deleteArticles) forControlEvents:UIControlEventTouchUpInside];
        editLbl = [[UILabel alloc]initWithFrame:CGRectMake(editBtn.frame.origin.x, 27, editBtn.frame.size.width, 14)];
        editLbl.textAlignment = UITextAlignmentCenter;
        editLbl.text = @"批量删除";
        if (listType) {
            editBtn.hidden = YES;
            editLbl.hidden = YES;
            postBtn.frame = CGRectMake(0, 0, 160,40);
            postBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (postBtn.frame.size.width-16)/2, 18, (postBtn.frame.size.width-16)/2);
            postLbl.frame = CGRectMake(postBtn.frame.origin.x, 27, postBtn.frame.size.width, 14);
            shareBtn.frame = CGRectMake(160, 0, 160, 40);
            shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (shareBtn.frame.size.width-16)/2, 18, (shareBtn.frame.size.width-16)/2);
            shareLbl.frame = CGRectMake(shareBtn.frame.origin.x, 27, shareBtn.frame.size.width, 14);
            [myTable setEditing:NO];
        }
        
        if (myTable.editing) {
            [editBtn setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
            editLbl.text = @"取消";
            UIButton *deleteArticleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteArticleBtn.frame = CGRectMake(182, 0, 106, 40);
            //    reportImg.image = [UIImage imageNamed:@"report.png"];
            [deleteArticleBtn setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
            deleteArticleBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 46, 21, 46);
            
            [deleteArticleBtn addTarget:self action:@selector(showAlertForDeleteArticle) forControlEvents:UIControlEventTouchUpInside];
            UILabel *deleteArticleBtnLbl = [[UILabel alloc]initWithFrame:CGRectMake(deleteArticleBtn.frame.origin.x, 27, deleteArticleBtn.frame.size.width, 14)];
            deleteArticleBtnLbl.textAlignment = UITextAlignmentCenter;
            deleteArticleBtnLbl.text = @"删除文章";
            [Utility styleLbl:deleteArticleBtnLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
            
            postBtn.frame = CGRectMake(0, 0, 80,40);
            postLbl.frame = CGRectMake(postBtn.frame.origin.x, 27, postBtn.frame.size.width, 14);
            shareBtn.frame = CGRectMake(80, 0, 80, 40);
            shareLbl.frame = CGRectMake(shareBtn.frame.origin.x, 27, shareBtn.frame.size.width, 14);
            deleteArticleBtn.frame = CGRectMake(160, 0, 80, 40);
            deleteArticleBtnLbl.frame = CGRectMake(deleteArticleBtn.frame.origin.x, 27, deleteArticleBtn.frame.size.width, 14);
            editBtn.frame = CGRectMake(240, 0, 80, 40);
            editLbl.frame = CGRectMake(editBtn.frame.origin.x, 27, editBtn.frame.size.width, 14);
            [toolBar addSubview:deleteArticleBtn];
            [toolBar addSubview:deleteArticleBtnLbl];
        }
        
        
        [Utility styleLbl:editLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        if ([club.isAdopted isEqualToString:@"0"]) {
            UIButton *adoptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            adoptBtn.frame = CGRectMake(0, 0, 320, 40);
            [adoptBtn setTitle:@"领    取" forState:UIControlStateNormal];
            [adoptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            adoptBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [adoptBtn addTarget:self action:@selector(adopt) forControlEvents:UIControlEventTouchUpInside];
            [toolBar addSubview:adoptBtn];
        }else{
            [toolBar addSubview:postBtn];
            [toolBar addSubview:postLbl];
            [toolBar addSubview:shareBtn];
            [toolBar addSubview:shareLbl];
            [toolBar addSubview:shareImg];
            [toolBar addSubview:postImg];
            [toolBar addSubview:editBtn];
            [toolBar addSubview:editLbl];
        }
        
    }else if (club.userType == USER_TYPE_MEMBER || club.userType == USER_TYPE_HONOR_MEMBER || club.userType == USER_TYPE_USER){
        toolBarBg.image = [UIImage imageNamed:@"toolbar_bg4.png"];
        if (club.userType == USER_TYPE_USER) {
            //申请加入/退出按钮
            joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            joinBtn.tag = JOIN;
            joinImg = [[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
            //    joinImg.image = [UIImage imageNamed:@"join.png"];
            joinBtn.frame = CGRectMake(0, 0, 80, 40);
            joinLbl = [[UILabel alloc]initWithFrame:CGRectMake(joinBtn.frame.origin.x, 27, joinBtn.frame.size.width, 14)];
            joinLbl.textAlignment = UITextAlignmentCenter;
            [Utility styleLbl:joinLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
            NSString *joinBtnImageName;
            if (club.type) {
                joinBtnImageName = @"quit.png";
                joinLbl.text = @"退出";
            }else if (club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN || club.userType == USER_TYPE_MEMBER || club.userType == USER_TYPE_HONOR_MEMBER) {
                joinBtnImageName = @"quit.png";
                joinLbl.text = @"退出";
            }else if(club.userType == USER_TYPE_USER){
                joinBtnImageName = @"join.png";
                if (!club.applyjudge) {
                    joinLbl.text = @"已申请";
                    joinBtn.enabled = NO;
                }else{
                    joinLbl.text = @"申请加入";
                }
            }
            [joinBtn setImage:[UIImage imageNamed:joinBtnImageName] forState:UIControlStateNormal];
            joinBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 30, 13, 30);
            [joinBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
            
            
            //关注按钮
            followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            followBtn.tag = FOLLOW;
            followBtn.frame = CGRectMake(80, 0, 80, 40);
            followLbl = [[UILabel alloc]initWithFrame:CGRectMake(followBtn.frame.origin.x, 27, followBtn.frame.size.width, 14)];
            followLbl.textAlignment = UITextAlignmentCenter;
            [Utility styleLbl:followLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
            followImg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
            followBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 32, 18, 32);
            
            if (club.followThisClub) {
                //        followImg.image = [UIImage imageNamed:@"follow.png"];
                
                [followBtn setImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
                followLbl.text = @"关注";
            }else{
                //        followImg.image = [UIImage imageNamed:@"unfollow.png"];
                
                [followBtn setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
                followLbl.text = @"取消关注";
            }
            [followBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            //发文按钮
            postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            postBtn.tag = POST;
            postBtn.frame = CGRectMake(0, 0, 80, 40);
            [postBtn setImage:[UIImage imageNamed:@"post.png"] forState:UIControlStateNormal];
            postBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (postBtn.frame.size.width-16)/2, 18, (postBtn.frame.size.width-16)/2);
            [postBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
            postImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
            //    postImg.image = [UIImage imageNamed:@"post.png"];
            postLbl = [[UILabel alloc]initWithFrame:CGRectMake(postBtn.frame.origin.x, 27, postBtn.frame.size.width, 14)];
            postLbl.textAlignment = UITextAlignmentCenter;
            postLbl.text = @"发文";
            
            //申请加入/退出按钮
            joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            joinBtn.tag = JOIN;
            joinImg = [[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 20, 20)];
            //    joinImg.image = [UIImage imageNamed:@"join.png"];
            joinBtn.frame = CGRectMake(80, 0, 80, 40);
            joinLbl = [[UILabel alloc]initWithFrame:CGRectMake(joinBtn.frame.origin.x, 27, joinBtn.frame.size.width, 14)];
            joinLbl.textAlignment = UITextAlignmentCenter;
            [Utility styleLbl:joinLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
            NSString *joinBtnImageName;
            if (club.type) {
                joinBtnImageName = @"quit.png";
                joinLbl.text = @"退出";
            }else if (club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN || club.userType == USER_TYPE_MEMBER || club.userType == USER_TYPE_HONOR_MEMBER) {
                joinBtnImageName = @"quit.png";
                joinLbl.text = @"退出";
            }else if(club.userType == USER_TYPE_USER){
                joinBtnImageName = @"join.png";
                joinLbl.text = @"申请加入";
            }
            [joinBtn setImage:[UIImage imageNamed:joinBtnImageName] forState:UIControlStateNormal];
            joinBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 30, 13, 30);
            [joinBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //分享按钮
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.tag = SHARE;
        shareBtn.frame = CGRectMake(160, 0, 80,40);
        UIImageView *shareImg = [[UIImageView alloc]initWithFrame:CGRectMake(85, 5, 20,20)];
        //    shareImg.image = [UIImage imageNamed:@"share.png"];
        [shareBtn setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 32, 18, 32);
        [shareBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *shareLbl = [[UILabel alloc]initWithFrame:CGRectMake(shareBtn.frame.origin.x, 27, shareBtn.frame.size.width, 14)];
        shareLbl.textAlignment = UITextAlignmentCenter;
        [Utility styleLbl:shareLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        shareLbl.text = @"分享";
        
        
        //举报按钮
        UIButton *reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        reportBtn.tag = REPORT;
        reportBtn.frame = CGRectMake(240, 0, 80, 40);
        UIImageView *reportImg = [[UIImageView alloc]initWithFrame:CGRectMake(215, 5, 14, 28)];
        //    reportImg.image = [UIImage imageNamed:@"report.png"];
        [reportBtn setImage:[UIImage imageNamed:@"report.png"] forState:UIControlStateNormal];
        reportBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 36, 21, 36);
        [reportBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *reportLbl = [[UILabel alloc]initWithFrame:CGRectMake(reportBtn.frame.origin.x, 27, reportBtn.frame.size.width, 14)];
        reportLbl.textAlignment = UITextAlignmentCenter;
        reportLbl.text = @"举报";
        [Utility styleLbl:reportLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        [Utility styleLbl:postLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        
        if ([club.isAdopted isEqualToString:@"0"]) {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0, 0, 320, 40);
            label.text = @"该俱乐部尚未领取";
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor =[UIColor clearColor];
            [toolBar addSubview:label];
            
            
        }else{
            [toolBar addSubview:joinBtn];
            [toolBar addSubview:shareBtn];
            [toolBar addSubview:followBtn];
            [toolBar addSubview:reportBtn];
            [toolBar addSubview:postBtn];
            [toolBar addSubview:postLbl];
            [toolBar addSubview:joinLbl];
            [toolBar addSubview:shareLbl];
            [toolBar addSubview:followLbl];
            [toolBar addSubview:reportLbl];
            [toolBar addSubview:joinImg];
            [toolBar addSubview:shareImg];
            [toolBar addSubview:followImg];
            [toolBar addSubview:reportImg];
            [toolBar addSubview:postImg];
        }
    }
    [self.view addSubview:toolBar];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return   UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([editLbl.text isEqualToString:@"取消"]) {
        [toDeleteList removeObject:[[[articlelist objectAtIndex:listType] objectAtIndex:(indexPath.row)] rowKey]];
    }else{
        
    }
}

//删除文章
-(void)deleteArticles{
    if ([editLbl.text isEqualToString:@"批量删除"]) {
        if (![[articlelist objectAtIndex:listType] count]) {
            return;
        }
        [editBtn setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        editLbl.text = @"取消";
        [toDeleteList removeAllObjects];
        [myTable setEditing:YES animated:YES];
    }else{
        editLbl.text = @"批量删除";
        [myTable setEditing:NO animated:YES];
    }
    [self addToolBar];
}

//alertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //加入退出俱乐部的alert
    if (0 == alertView.tag ) {
        if (buttonIndex == 1) {
            [self operate];
        }else{
            return;
        }
        return;
    }else if (1 == alertView.tag) {
        if (buttonIndex == 1) {
            [self operate];
        }else{
            return;
        }
        return;
    }else if (123 == alertView.tag){
        if (buttonIndex == 1) {
            [self deleteArticle];
        }else{
            return;
        }
        return;
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSArray *reportArray = [NSArray arrayWithObjects:@"垃圾广告",@"淫秽信息",@"不实信息",@"人身攻击",@"其他", nil];
    if ([reportArray count] == buttonIndex) {
        return;
    }
    postURLStr = URL_CLUB_REPORT;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:[reportArray objectAtIndex:buttonIndex] forKey:@"reason"];
    [dic setValue:club.ID forKey:@"oldrowkey"];
    [dic setValue:@"1" forKey:KEY_TYPE];
    [rp sendDictionary:dic andURL:URL_CLUB_REPORT andData:nil];
}

-(void)operate{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:postURLStr andData:nil];
}

//俱乐部操作:加入/分享/关注/举报/发文
-(void)clubOperation:(id)sender{
    UIButton *btn = (UIButton *)sender;
    operationType = btn.tag;
    UIActionSheet *ac;
    PostArticleViewController *postArticleView;
    switch (btn.tag) {
        case JOIN:// 发送请求，在成功后更改图标为已关注的状态，失败则报错"关注％@俱乐部失败"
            if (club.userType != USER_TYPE_USER) {
                postURLStr = URL_CLUB_QUIT;
                UIAlertView * alert = [Utility MsgBox:@"是否退出该俱乐部" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确认" withStyle:0];
                alert.tag = 0;
                //如果是私密俱乐部的话，退出后要返回俱乐部列表页
                //并且都要改变他们的userType
            }else if(club.userType == USER_TYPE_USER){
                postURLStr = URL_CLUB_JOIN;
                [Utility MsgBox:@"申请加入该俱乐部" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确认" withStyle:0];
            }
            break;
        case SHARE:{
            //[self share];
            [ShareSDKManager shareClubWithRightBarItem:self.navigationItem.rightBarButtonItem andSendShare:^(NSString *destination) {
                [self sendShare:destination];
            }];
            break;
        }
        case FOLLOW://发送请求，在成功后更改图标为已关注的状态，失败则报错"关注％@俱乐部失败"
            WeLog(@"是否关注该俱乐部%d",club.followThisClub);
            if (!club.followThisClub) {
                postURLStr = URL_CLUB_UNFOLLOW;
                UIAlertView * alert = [Utility MsgBox:@"取消关注该俱乐部" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确认" withStyle:0];
                alert.tag = 1;
                break;
            }
            postURLStr = URL_CLUB_FOLLOW;
            [self operate];
            break;
        case REPORT://发送请求，在成功后更改图标为已关注的状态，失败则报错"关注％@俱乐部失败"
            //举报俱乐部还要填写举报的理由，和原因
            postURLStr = URL_CLUB_REPORT;
            ac = [[UIActionSheet alloc] initWithTitle:@"举报该俱乐部"
                                             delegate:self
                                    cancelButtonTitle:@"取消"
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@"垃圾广告",@"淫秽信息",@"不实信息",@"人身攻击",@"其他",nil];
            ac.actionSheetStyle = UIBarStyleBlackTranslucent;
            [ac showInView:self.view];
            break;
        case POST:
            WeLog(@"club.type:%d",club.type);
            //只有公开俱乐部才会再去判断有没有权限执行这些操作
            if (!club.type) {
                if (club.userType == USER_TYPE_USER) {
                    [Utility MsgBox:@"只有该俱乐部的会员可以发文,是否申请加入该俱乐部?" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
                    postURLStr = URL_CLUB_JOIN;
                    return;
                }
            }
            UINavigationController *NAV;
            if (!postArticleView) {
                postArticleView = [[PostArticleViewController alloc]initWithNibName:@"PostArticleViewController" bundle:nil];
                postArticleView.club = self.club;
                NAV = [[UINavigationController alloc]initWithRootViewController:postArticleView];
                if ([NAV respondsToSelector:@selector(edgesForExtendedLayout)]) {
                    NAV.edgesForExtendedLayout = 0;
                }
                NAV.navigationBar.translucent = NO;
                if (iosVersion >=7 ) {
                    NAV.navigationBar.barTintColor = TINT_COLOR;
                }
                NAV.navigationBar.tintColor = TINT_COLOR;
            }
            [self presentModalViewController:NAV animated:YES];
            WeLog(@"%@%@",self.presentingViewController,self.presentedViewController);
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(dismissModal) name:@"DISMISS_MODAL" object:nil ];
            return;
    }
}

//{"destination":"www.baidu.com","type":"1","rowkey":"12321321", "content":"123213123"}
-(void)sendShare:(NSString*)destination{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"1" forKey:KEY_TYPE];
    [dic setValue:club.ID forKey:KEY_ROW_KEY];
    [dic setValue:destination forKey:@"destination"];
    [dic setValue:@"haha" forKey:KEY_CONTENT];
    [rp sendDictionary:dic andURL:URL_CLUB_SHARE andData:nil];
}

-(void)dismissModal{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark 跳转页面
//跳到俱乐部信息页
-(void)goClubInfo{
    if (![self.navigationController.topViewController isKindOfClass:[ClubViewController class]]) {
        return;
    }
    ClubInfoViewController *clubInfo = [[ClubInfoViewController alloc]init];
    clubInfo.club = self.club;
    [self.navigationController pushViewController:clubInfo animated:YES];
    [[AudioPlayer getSingleton] gotoWhenAudioPlaying];
}
//跳到主题文章页
-(void)goTopicArticle:(int)indexNum{
    Article *topicArticle = [[articlelist objectAtIndex:listType] objectAtIndex:(indexNum)];
    if (![topicArticle.content length]) {
        [Utility showHUD:@"该文章已被删除!"];
        return;
    }
    ArticleDetailViewController *articleDetailView = [[ArticleDetailViewController alloc]init];
    articleDetailView.club = self.club;
    articleDetailView.indexNum = indexNum;
    if (listType) {
        articleDetailView.isDigest = YES;
    }
    articleToGo = indexNum;
    articleDetailView.topicArticle = topicArticle;
    articleDetailView.lastViewController = self;
    [self.navigationController pushViewController:articleDetailView animated:YES];
}

//跳到个人信息页
-(void)goPersonInfo:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    int indexNum = tap.view.superview.tag;
    Article *article = [[articlelist objectAtIndex:listType] objectAtIndex:indexNum];
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:article.userName];
    [self.navigationController pushViewController:personInfoView animated:YES];
}

-(void)refreshAfterDelete:(NSNotification *)notification{
    //删除是本地先删除不会自动刷新的
    //    [[articlelist objectAtIndex:listType] removeObjectAtIndex:[[notification.userInfo objectForKey:@"index"] intValue]];
    if (notification.object == self) {
        [[articlelist objectAtIndex:listType] removeObjectAtIndex:articleToGo];
        WeLog(@"%d",[[notification.userInfo objectForKey:@"index"] intValue]);
//        [myTable reloadData];
        [myTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:articleToGo inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)refresh:(NSNotification *)topicArticle{
    [self switchList:banMianBtn];
}

#pragma mark -
#pragma mark 获取网络数据 NetWork GetData
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view  animated:YES];
    if([type isEqualToString:URL_CLUB_ARTICLE_LIST]||[type isEqualToString:URL_CLUB_GOODARTICLE_LIST]){

        
        if (listType) {
            startKey_digest = [dic objectForKey:KEY_STARTKEY];
        }else{
            startKey_ban = [dic objectForKey:KEY_STARTKEY];
        }
        NSArray *gotArray = [dic objectForKey:@"articleList"];
        NSArray *onTopArray = [dic objectForKey:@"ontopList"];
        //加载更多
        if (!isLoadMore) {
            [myTable setContentOffset:CGPointMake(0, 0)];
            [[articlelist objectAtIndex:listType] removeAllObjects];
            for (int i = 0; i < [onTopArray count];i++) {
                Article *article = [[Article alloc]initWithDictionary:[onTopArray objectAtIndex:i]];
                [[articlelist objectAtIndex:listType] addObject:article];
            }
        }
        for (int i = 0; i < [gotArray count];i++) {
            Article *article = [[Article alloc]initWithDictionary:[gotArray objectAtIndex:i]];
            [[articlelist objectAtIndex:listType] addObject:article];
        }

        [self refreshTableFooter];
        if (isLoadMore) {
            [myTable insertRowsAtIndexPaths:[self getIndexPaths] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [myTable reloadData];
        }
        
        [self addToolBar];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
        [SVProgressHUD dismissWithSuccess:@"刷新成功"];
    }else if([type isEqualToString:URL_CLUB_GET_BASICINFO]){
        //获取俱乐部基本信息
        [club clearClubData];
        [club refreshClubDataWithDic:[dic objectForKey:KEY_DATA]];
        _adoptFlag = [[[dic objectForKey:KEY_DATA] objectForKey:@"hasPhoto"] integerValue];
        [self refreshTopView];
        [self addToolBar];
    }else if ([type isEqualToString:URL_CLUB_GET_ADMINS]){
        NSDictionary *adminsDic = [dic objectForKey:KEY_DATA];
        if ([[adminsDic objectForKey:KEY_ADMIN] count]) {
            club.admin = [[adminsDic objectForKey:KEY_ADMIN] objectAtIndex:0];
        }
        club.viceAdmins = [adminsDic objectForKey:KEY_VICE_ADMINS];
        myTable.pullToRefreshView.lastUpdatedDate = [NSDate date];
        //club.admin = [[dic objectForKey:KEY_ADMIN] objectForKey:KEY_USER_ROW_KEY];
        [self refreshTopView];
    }else if([type isEqualToString:URL_CLUB_JOIN]){
        //加入俱乐部
        [Utility showHUD:@"申请成功"];
        club.applyjudge = 0;
        [self addToolBar];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else if([type isEqualToString:URL_CLUB_QUIT]){
        //退出俱乐部
        [Utility showHUD:@"退出成功"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        club.userType = USER_TYPE_USER;
        [self addToolBar];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_AFTER_QUIT_UNFOLLOW_CLUB" object:@"quit" userInfo:nil];
        if (club.type) {
            [self back];
        }
    }else if([type isEqualToString:URL_CLUB_FOLLOW]){
        //关注俱乐部
        [Utility showHUD:@"关注成功"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        club.followThisClub = 0;
        [self addToolBar];
    }else if([type isEqualToString:URL_ARTICLE_DELETE]){
        [Utility showHUD:@"删除成功"];
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (int i = 0; i < [[articlelist objectAtIndex:listType] count]; i++) {
            Article *article = [[articlelist objectAtIndex:listType] objectAtIndex:i];
            if ([toDeleteList containsObject:article.rowKey]) {
                [array addObject:[[articlelist objectAtIndex:listType] objectAtIndex:i]];
                //                [[articlelist objectAtIndex:listType] removeObjectAtIndex:i];
            }
        }
        [[articlelist objectAtIndex:listType] removeObjectsInArray:array];
        editLbl.text = @"批量删除";
        NSArray *deletedIndexPaths = [myTable indexPathsForSelectedRows];
        [myTable deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self refreshTableFooter];
        [myTable setEditing:NO];
        [self addToolBar];
//        [myTable reloadData];
    }else if([type isEqualToString:URL_CLUB_UNFOLLOW]){
        [Utility showHUD:@"取消关注成功"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_AFTER_QUIT_UNFOLLOW_CLUB" object:@"unfollow" userInfo:nil];
        //取消关注俱乐部
        club.followThisClub = 1;
        [self addToolBar];
    }else if([type isEqualToString:URL_CLUB_REPORT]){
        //举报俱乐部
        [Utility showHUD:@"举报成功"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else if ([type isEqualToString:URL_CLUB_GET_DISPLAY_WINDOW]){
        NSMutableArray *mediaArray = [[NSMutableArray alloc]init];
        [mediaArray addObjectsFromArray:[dic objectForKey:KEY_DATA]];
        club.media = mediaArray;
        club.mediaInfo = [dic objectForKey:KEY_ATTACHMENT_INFO];
        [self prepareImageView];
        [self refreshDisplayView];
        myTable.pullToRefreshView.lastUpdatedDate = [NSDate date];
        [audioPlay stop];
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]){
        club.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        club.applyjudge = [[dic objectForKey:@"applyjudge"] intValue];
        [self addToolBar];
    }
}

-(void)refreshTableFooter{
    UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    tintLbl.backgroundColor = [UIColor clearColor];
    tintLbl.textColor = [UIColor grayColor];
    tintLbl.textAlignment = NSTextAlignmentCenter;
    myTable.tableFooterView = tintLbl;
    NSString *startkey;
    if (listType) {
        startkey = startKey_digest ;
    }else{
        startkey = startKey_ban;
    }
    if ([startkey isEqualToString:KEY_END]) {
        if (![[articlelist objectAtIndex:listType] count]) {
            if (listType) {
                tintLbl.text = @"精华区暂无文章";
            }else{
                tintLbl.text = @"版面暂无文章";
            }
        }else{
            tintLbl.text = @"已显示全部";
        }
    }else{
        tintLbl.text = @"上拉加载更多";
    }
}

-(NSArray *)getIndexPaths{
    int tableCount = [myTable numberOfRowsInSection:0];
    int count = [[articlelist objectAtIndex:listType] count] - tableCount;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        [array addObject:[NSIndexPath indexPathForRow:tableCount+i inSection:0]];
    }
    return array;
}

-(void)stop{
    [myTable.infiniteScrollingView stopAnimating];
    [myTable.pullToRefreshView stopAnimating];
    myTable.pullToRefreshView.lastUpdatedDate = [NSDate date];
}

-(void)prepareImageView{
    [imgArray removeAllObjects];
    for (NSString *st in club.media) {
        NSString *displayType = [st substringFromIndex:([st length]-1)];
        if ([displayType isEqualToString:TYPE_ATTACH_PICTURE]) {
            [imgArray addObject:ClubImageURL(st, TYPE_RAW)];
        }
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self stop];
    if ([type isEqualToString:URL_CLUB_REPORT]) {
        //        [Utility showHUD:@"举报失败"];
    }else if([type isEqualToString:URL_CLUB_JOIN]){
        //加入俱乐部
        //        [Utility showHUD:@"申请加入失败"];
        //        [self addToolBar];
    }else if([type isEqualToString:URL_CLUB_QUIT]){
        //退出俱乐部
        //        [Utility showHUD:@"退出失败"];
        [self addToolBar];
        
    }else if([type isEqualToString:URL_CLUB_FOLLOW]){
        //关注俱乐部
        //        [Utility showHUD:@"关注失败"];
        [self addToolBar];
        
    }else if([type isEqualToString:URL_CLUB_UNFOLLOW]){
        //        [Utility showHUD:@"取消关注失败"];
        //取消关注俱乐部
        [self addToolBar];
    }
    //    [Utility showHUD:excepDesc];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [myTable.pullToRefreshView stopAnimating];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

//下拉刷新
-(void)refreshData{
    [request getUserType:club.ID withDelegate:self];
    [self loadData];
    [request getBaseInfo:club.ID withDelegate:self];
    [request getModerator:club.ID withDelegate:self];
    [request getDisplayWindows:club.ID withDelegate:self];
}

//加载数据
- (void)loadData{
    [myTable setEditing:NO];
    NSString *startKeystring;
    if (isLoadMore) {
        if (listType) {
            startKeystring = startKey_digest;
        }else{
            startKeystring = startKey_ban;
        }
        if (!startKeystring) {
            return;
        }
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [myTable.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            [self addToolBar];
            return;
        }
    }else{
        startKeystring = @"0";
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [indicator startAnimating];
        myTable.tableFooterView = indicator;
    }
    
    if (listType) {
        postURLStr = URL_CLUB_GOODARTICLE_LIST;//精华区
    }else{
        postURLStr = URL_CLUB_ARTICLE_LIST;//版面
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:club.ID forKey:KEY_ID];
    [dic setValue:@"0" forKey:KEY_SORT];
    [dic setValue:club.ID forKey:KEY_ID];
    [dic setValue:[NSNumber numberWithInt:listType] forKey:KEY_BOARD];
    [dic setValue:COUNT_NUM forKey:KEY_COUNT];
    [dic setValue:startKeystring forKey:KEY_STARTKEY];
    [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    [rp sendDictionary:dic andURL:postURLStr andData:nil];
}

-(void)getBaseInfo{
    [request getBaseInfo:club.ID withDelegate:self];
    //    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //    [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    //    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    //    [rp sendDictionary:dic andURL:URL_CLUB_GET_BASICINFO andData:nil];
}

//-(void)getUserType{
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
//    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
//}

-(void)audioPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    int indexNum = btn.tag;
    [audioPlay playAudiowithType:@"clubAudio" withView:sender withFileName:[club.media objectAtIndex:indexNum]withStyle:0];
}

-(void)showAlertForDeleteArticle{
    if ([toDeleteList count]) {
        UIAlertView * alert = [Utility MsgBox:@"确定删除所选文章" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
        alert.tag = 123;
    }else{
        [Utility showHUD:@"没有选中要删除的文章!"];
    }
}

-(void)deleteArticle{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:toDeleteList forKey:KEY_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_ARTICLE_DELETE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[articlelist objectAtIndex:listType] count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([editLbl.text isEqualToString:@"取消"]) {
        Article *article = [[articlelist objectAtIndex:listType] objectAtIndex:(indexPath.row)];
        [toDeleteList addObject:article.rowKey];
    }else{
        [self goTopicArticle:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        todelete = indexPath.row;
        [self deleteArticle];
        // Delete the row from the data source
    }
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
    Article *topicArticle = [[articlelist objectAtIndex:listType] objectAtIndex:(indexPath.row)];
    if (listType) {//因为精华区的附件图片不一样
        cell.isDigest = YES;
    }else{
        cell.isDigest = NO;
    }
    cell.tag = indexPath.row;
    cell.postClubLbl.hidden = YES;
    [cell initCellWithArticle:topicArticle withViewController:self];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *topicArticle = [[articlelist objectAtIndex:listType] objectAtIndex:(indexPath.row)];
    CGFloat contentHeight = [self getMixedViewHeight:topicArticle.content];
    //    CGFloat contentHeight = [Utility getSizeByContent:topicArticle.content withWidth:250 withFontSize:18];
    //    CGFloat contentHeight = [Utility getMixedViewHeight:topicArticle.content withWidth:250];
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
    }
    WeLog(@"cell%f",cellHeight);
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
//    UIColor *nameColor = [UIColor blueColor];
//    UIColor *labelColor = [UIColor redColor];
//    UIColor *linkerColor = [UIColor greenColor];
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


//返回
-(void)back{
    [rp cancel];
    [request cancelRequest];
    if (isPushFromNewClub) {
        //        TabBarController *_tabC = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
        //        ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
        //        self.navigationController.navigationBarHidden = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)goHomePage{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)refreshTitleView{
    //titleView
    UIView *title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, -10, 320, 20)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.textAlignment = UITextAlignmentLeft;
    titleLbl.text = club.name;
    CGSize labelsize = [club.name sizeWithFont:titleLbl.font constrainedToSize:CGSizeMake(900, 20) lineBreakMode:UILineBreakModeTailTruncation];
    if (labelsize.width > 240) {
        labelsize = CGSizeMake(240, labelsize.height);
    }
    WeLog(@"标题长度%f",labelsize.width);
    
    titleLbl.frame = CGRectMake(-(labelsize.width)/2, -10, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapTitle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollToTop) ];
    [titleLbl addGestureRecognizer:tapTitle];
    titleLbl.userInteractionEnabled = YES;
    [title addSubview:titleLbl];
    self.navigationItem.titleView = title;
}

-(void)initNavigation{
    //leftBarButtonItem
    
}

-(void)refreshDisplayView{
    [displayView removeFromSuperview];
    displayView = [[UIView alloc]initWithFrame:CGRectMake(0, 90, 320, 85)];
    if (![club.media count]) {
        //没有展示窗口
        listSwitchView.frame = CGRectMake(0, 115, 320, 30);
        bg.frame = CGRectMake(0, 0, 320, 110);
        headerView.frame = CGRectMake(0, 0, 320, 145);
    }else{
        //有展示窗口
        listSwitchView.frame = CGRectMake(0, 180, 320, 30);
        [headerView addSubview:displayView];
        bg.frame = CGRectMake(0, 0, 320, 175);
        headerView.frame = CGRectMake(0, 0, 320, 210);
    }
    //添加精华区下的横线
    [[headerView viewWithTag:1000] removeFromSuperview];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, 320, 1)];
    line.tag = 1000;
    line.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:0.3];
    [headerView addSubview:line];
    myTable.tableHeaderView = headerView;
    
    [diplayScroll removeFromSuperview];
    diplayScroll = [[MLScrollView alloc]initWithFrame:CGRectMake(5, 10, 310, 70)];
    int mediaCount =[club.media count];
    [diplayScroll setContentSize:CGSizeMake(mediaCount*DISPLAY_WINDOWN_SIZE+(mediaCount-1)*10, DISPLAY_WINDOWN_SIZE)];
    diplayScroll.showsHorizontalScrollIndicator = NO;
    diplayScroll.scrollsToTop = NO;
    
    for (int i = 0; i < [club.media count]; i++) {
        //附件时间长度
        UILabel *audioLengthLbl = [[UILabel alloc]init];
        [Utility styleLbl:audioLengthLbl withTxtColor:ATTACHTIME_LENGTH_LBL_COLOR withBgColor:nil withFontSize:10];
        audioLengthLbl.textAlignment = NSTextAlignmentCenter;
        EGOImageButton *imgView = [[EGOImageButton alloc]init];
        NSString * singleMedia = [club.media objectAtIndex:i];
        NSString *type = [singleMedia substringFromIndex:([singleMedia length]-1)];
        
        if ([club.mediaInfo isKindOfClass:[NSDictionary class]]) {
            if (![type isEqualToString:TYPE_ATTACH_PICTURE]) {
                audioLengthLbl.frame = CGRectMake(0, DISPLAY_WINDOWN_SIZE/2+17.5, DISPLAY_WINDOWN_SIZE, 15);
                audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[club.mediaInfo objectForKey:singleMedia] objectForKey:DURATION]];
                [imgView addSubview:audioLengthLbl];
            }
        }
        
        if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
            imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ATTACHMENT_PIC_HOLDER ofType:@"jpg"]];
            [imgView setImageURL:ClubImageURL(singleMedia, TYPE_THUMB)];
            [imgView addTarget:self action:@selector(viewDiplayPICS:) forControlEvents:UIControlEventTouchUpInside];
        }else if ([type isEqualToString:TYPE_ATTACH_VIDEO]){
            audioLengthLbl.backgroundColor = [UIColor blackColor];
            audioLengthLbl.alpha = 0.7;
            imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:VIDEO_PIC_HOLDER ofType:@"png"]];
            [imgView setImageURL:ClubImageURL(singleMedia, TYPE_THUMB)];
            [imgView addTarget:self action:@selector(videoPlay:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:VIDEO_PLAY_ICON]];
            videoIcon.frame = CGRectMake(22,22,20,20);
            [imgView addSubview:videoIcon];
        }else if ([type isEqualToString:TYPE_ATTACH_AUDIO]){
            [imgView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
            [imgView addTarget:self action:@selector(audioPlay:) forControlEvents:UIControlEventTouchUpInside];
        }
        imgView.frame = CGRectMake((DISPLAY_WINDOWN_SIZE+10)*i, 0, DISPLAY_WINDOWN_SIZE, DISPLAY_WINDOWN_SIZE);
        imgView.tag = i;
        [Utility psImageView:imgView];
        [diplayScroll addSubview:imgView];
    }
    [displayView addSubview:diplayScroll];
}

-(void)videoPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    WeLog(@"AudoURL%@",ClubImageURL([club.media objectAtIndex:btn.tag],TYPE_RAW));
    [videoPlay playVideoWithURL:[NSString stringWithFormat:@"%@/%@/club/file?name=%@&type=%@",HOST,PHP,[club.media objectAtIndex:btn.tag],TYPE_RAW] withType:@"articleVideo" view:self];
    
    //    [videoPlay playVideoWithName:[club.media objectAtIndex:btn.tag] withType:@"clubVideo"];
}

//查看展示窗口的图片
-(void)viewDiplayPICS:(id)sender{
    UIButton *btn = (UIButton*)sender;
    [photos removeAllObjects];
    for (int i = 0; i < [imgArray count]; i++) {
        if (photos) {
            [photos addObject:[MWPhoto photoWithURL:[imgArray objectAtIndex:i]]];
        }
    }
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    nav.navigationBar.translucent = NO;
    [mwBrowser setInitialPageIndex:[imgArray indexOfObject:ClubImageURL([club.media objectAtIndex:btn.tag], TYPE_RAW)]];
    [self presentModalViewController:nav animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

//跳到顶部设置在有多个scrollview的情况下只能有一个scrollview的scrollsToTop属性为真才会响应
-(void)scrollToTop{
    [myTable setContentOffset:CGPointMake(myTable.contentOffset.x, 0)
                     animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)removeToolBar
{
    [toolBar removeFromSuperview];
}

- (void)adopt
{
    ClubProfileEditViewController *edit = [[ClubProfileEditViewController alloc] initWithClub:club];
    edit.adoptFlag = 1;
    edit.logoFlag = _adoptFlag;
    edit.target = self;
    edit.method = @selector(adoptFresh);
    
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)adoptFresh
{
    club.isAdopted = @"1";
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    //send the event to MLNavigationController
    //    [self.firstAvailableNavigationController touchesBegan:touches withEvent:event];
    
}


@end
