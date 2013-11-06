//
//  ArticleDetailViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//
/*
 请求:
 获取文章信息(版面文章，精华文章)
 获取评论回复(版面文章，精华文章)
 
 回复文章
 设为(取消)精华文章
 设为(取消)置顶文章
 收藏文章
 分享
 举报
 
俱乐部权限判断
申请加入俱乐部
 */
#import "ArticleDetailViewController.h"
#import "amrFileCodec.h"
#import "ShareSDKManager.h"

@interface ArticleDetailViewController ()

@end

@implementation ArticleDetailViewController
@synthesize topicArticle,indexNum,club,isDigest,isLoadMore,readFlag,lastViewController;

- (id)initWithArticleRowKey:(NSString *)myArticleRowKey
{
    self = [super init];
    if (self) {
        topicArticleRowKey = myArticleRowKey;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
//    [self getTopicArticle];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_REFRESH_PIC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_AUDIO_STOP object:nil];
    
//    [rp cancel];在back返回的时候取消请求
    [[AudioPlayer getSingleton] gotoWhenAudioPlaying];
    [[VideoPlayer getSingleton] VideoDownLoadCancel];
    [newPlayer stop];
    [audioPlay stop];
    [self stop];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    shouldResume = NO;
    //在从网络加载的情况下，发送NOTIFICATION_REFRESH_PIC通知，重新加载图片
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initView)
                                                 name:NOTIFICATION_REFRESH_PIC
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioStop)
                                                 name:NOTIFICATION_AUDIO_STOP
                                               object:nil];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //titleView
    if (club) {
        self.title = club.name;
    }else{
        self.title = @"文章内容";
    }
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    myTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20)];
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320,240)];
    myTable.delegate = self;
    myTable.dataSource = self;
    
    //rightBarButtonItem
    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 30, 30);
//    [menuBtn setImage:[UIImage imageNamed:IMAGE_SORT] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(sort) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem;
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    //    [self.view addGestureRecognizer:swipe];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    
    //background
    bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 160)];
    bg.backgroundColor = TINT_COLOR;
    [headerView addSubview:bg];
    sortFlag = NO;
    audioPlay = [AudioPlay getSingleton];
    photos = [[NSMutableArray alloc]init];

    //myTable
    __weak __block typeof(self)bself = self;
    __weak UITableView *table = myTable;
    [myTable addPullToRefreshWithActionHandler:^{
        if (table.pullToRefreshView.state == SVPullToRefreshStateLoading)
        {
            bself.isLoadMore = NO;
//          [bself loadData];
            [bself getTopicArticle];
//            [bself audioStop];
        }
    }];
    [myTable addInfiniteScrollingWithActionHandler:^{
        WeLog(@"%d",table.infiniteScrollingView.state);
        if (table.pullToRefreshView.state == SVPullToRefreshStateStopped)
        {
            bself.isLoadMore = YES;
            [bself loadData];
        }else{
            [table.infiniteScrollingView stopAnimating];
        }
    }];
    
    if ([myTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [myTable setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self createView];
    if (topicArticleRowKey) {
        [self getTopicArticle];
    }else{
        topicArticleRowKey = topicArticle.rowKey;
        [self initView];
        [self loadData];
    }

    //DATA
    replyArticleList = [[NSMutableArray alloc]init];
    replyArticleNum = [[NSMutableArray alloc]init];
    toReply = -1;
}

-(void)createView{
    avatar = [[UIImageView alloc]init];
    avatar.frame = CGRectMake(5, 5, 50, 50);
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 5;
    avatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAuthorInfo) ];
    [avatar addGestureRecognizer:tapGestureRecognizer];
    [headerView addSubview:avatar];
    
    UIView *TopView = [[UIView alloc]initWithFrame:CGRectMake(70, 5, 250, 14)];
    TopView.backgroundColor = COLOR_GRAY;
    nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
    [Utility styleLbl:nameLbl withTxtColor:[UIColor blackColor] withBgColor:nil withFontSize:14];
    nameLbl.text = topicArticle.userName;

    followIcon = [[UIImageView alloc]initWithFrame:CGRectMake(80, 4, 12, 12)];
    if (topicArticle.followtheArticleFlag) {
        [followIcon setImage:[UIImage imageNamed:@"follow_count.png"]];
    }else{
        [followIcon setImage:nil];
    }
    UIImageView * distaneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location.png"]];
    distaneIcon.frame = CGRectMake(155, 4, 12, 12);
    [TopView addSubview:followIcon];
    
    distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(170, 0, 80, 20)];
    [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:14];
    distanceLbl.text = topicArticle.distance;

    [TopView addSubview:nameLbl];
    [TopView addSubview:distaneIcon];
    [TopView addSubview:distanceLbl];
    [headerView addSubview:TopView];
    
    contentLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 70, 310, 40)];
    contentLbl.backgroundColor = COLOR_RED;
    contentLbl.userInteractionEnabled = YES;
    contentLbl.numberOfLines = 0;
    [Utility styleLbl:contentLbl withTxtColor:[UIColor clearColor] withBgColor:nil withFontSize:18];
    [headerView addSubview:contentLbl];
    
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(68, 30, 200, 10)];
    bottomView.backgroundColor = COLOR_BROWN;
    
    UIImageView *replyIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 12, 12)];
    replyIcon.image = [UIImage imageNamed:@"reply_count.png"];
    replyCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 60, 12)];
    replyCountLbl.text = topicArticle.replyCount;
    [Utility styleLbl:replyCountLbl  withTxtColor:nil withBgColor:nil withFontSize:12];
    UIImageView *browseIcon = [[UIImageView alloc]initWithFrame:CGRectMake(125, 0, 12, 12)];
    browseIcon.image = [UIImage imageNamed:@"browse_count.png"];
    browseCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(140, 0, 60, 12)];
    browseCountLbl.text = topicArticle.browseCount;
    [Utility styleLbl:browseCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
    
    UIImageView *collectIcon = [[UIImageView alloc]initWithFrame:CGRectMake(65, 0, 12, 12)];
    collectIcon.image = [UIImage imageNamed:@"follow_count.png"];
    collectCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(85, 0, 60, 12)];
    collectCountLbl.text = topicArticle.followCount;
    [Utility styleLbl:collectCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];

    UIImageView *shareIcon = [[UIImageView alloc]initWithFrame:CGRectMake(85, 0, 12, 12)];
    shareIcon.image = [UIImage imageNamed:@"share_count.png"];
    shareCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 40, 12)];
    shareCountLbl.text = topicArticle.shareCount;
    [Utility styleLbl:shareCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
    
    digestIcon = [[UIImageView alloc]initWithFrame:CGRectMake(68, 30, 12, 12)];
    digestIcon.image = [UIImage imageNamed:@"digest.png"];
    digestIcon.hidden = YES;
    onTopIcon = [[UIImageView alloc]initWithFrame:CGRectMake(88, 30, 12, 12)];
    onTopIcon.image = [UIImage imageNamed:@"onTop.png"];
    onTopIcon.hidden = YES;
    [headerView addSubview:digestIcon];
    [headerView addSubview:onTopIcon];
    [self refreshDigestAndOntopIcon];

    
    faceBoard = [[FaceBoard alloc] initWithIsShowSendButton:NO];
//
    faceBoard.frame = CGRectMake(0, myConstants.screenHeight-20-44-216, 320, 216);
    faceBoard.hidden = YES;
    faceBoard.inputTextView = (UITextView *)_textToSend;

    if (!isDigest) {
        [headerView addSubview:bottomView];
    }
//    [self.view addSubview:faceBoard];
    [bottomView addSubview:browseIcon];
    [bottomView addSubview:browseCountLbl];
    [bottomView addSubview:replyIcon];
    [bottomView addSubview:collectIcon];
    [bottomView addSubview:replyCountLbl];
    [bottomView addSubview:collectCountLbl];
    myTable.tableHeaderView = headerView;
    //TODO 改变发文时间的位置
    postTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(260, 225, 60, 14)];
    [Utility styleLbl:postTimeLbl withTxtColor:NAVIFONT_COLOR withBgColor:nil withFontSize:12];
    [headerView addSubview:postTimeLbl];
    if (club) {
        [self createToolbar];
    }else{
        //一种是先通过文章rowkey获取文章，一种是已知topicarticle
        if (topicArticle) {
            [self checkUserTypeForCreateToolBar];
        }
    }
//    }
    [self createReplyView];
}

//更新'精''顶'字图标
-(void)refreshDigestAndOntopIcon{
    if (topicArticle.isDigest) {
        digestIcon.hidden = NO;
    }else{
        digestIcon.hidden = YES;
    }
    if (topicArticle.isOnTop) {
        onTopIcon.hidden = NO;
    }else{
        onTopIcon.hidden = YES;
    }
    if (topicArticle.isDigest||isDigest) {
        if (topicArticle.isOnTop) {
            bottomView.frame = CGRectMake(100, 30, 200, 10);
            onTopIcon.hidden = NO;
            onTopIcon.frame = CGRectMake(88, 30, 12, 12);
        }else{
            bottomView.frame = CGRectMake(88, 30, 200, 10);
        }
        digestIcon.hidden = NO;
    }else if (topicArticle.isOnTop){
        onTopIcon.hidden = NO;
        onTopIcon.frame = CGRectMake(70, 30, 12, 12);
        bottomView.frame = CGRectMake(88, 30, 200, 10);
    }else{
        bottomView.frame = CGRectMake(70, 30, 200, 10);
    }
}

-(void)createReplyView{
    replyView = [[UIView alloc]initWithFrame:CGRectMake(0, myConstants.screenHeight-20-44-44, 320, 44)];
    sendButton = [[UIButton alloc]initWithFrame:CGRectMake(265, 7, 50, 30)];
    sendButton.layer.cornerRadius = 5;
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sendButton setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
    [sendButton addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:sendButton];
    replyView.backgroundColor = [UIColor grayColor];
    
    voiceChatButton = [[UIButton alloc]init];
    voiceChatButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    voiceChatButton.frame = CGRectMake(0, 0, 44, 44);
    UIImage *voiceChatImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_input_voice" ofType:@"png"]];
    [voiceChatButton setImage:voiceChatImg forState:UIControlStateNormal];
    [voiceChatButton addTarget:self action:@selector(switchTextOrVoice) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:voiceChatButton];
    
    pressToSpeak = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    pressToSpeak.frame = CGRectMake(50, 7, 250, 35);
    [pressToSpeak setTitle:@"按住录音" forState:UIControlStateNormal];
    [pressToSpeak setBackgroundImage:[[UIImage imageNamed:@"VoiceBtn_Black.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
    [pressToSpeak setTitleColor:[UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1] forState:UIControlStateNormal];
    [pressToSpeak addTarget:self action:@selector(audioRecordStart) forControlEvents:UIControlEventTouchDown];
    [pressToSpeak addTarget:self action:@selector(dropRecord:) forControlEvents:UIControlEventTouchUpOutside];
    [pressToSpeak addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    [pressToSpeak addTarget:self action:@selector(moveOut:) forControlEvents:UIControlEventTouchDragExit];
    [pressToSpeak addTarget:self action:@selector(moveIn:) forControlEvents:UIControlEventTouchDragEnter];
    pressToSpeak.hidden = YES;
    [replyView addSubview:pressToSpeak];
    
    inputField.delegate = self;
    
    emotionBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, 10, 25, 25)];//CGRectMake(275, 10, 25, 25)
    emotionBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;

    [emotionBtn setImage:[UIImage imageNamed:@"emotion.png"] forState:UIControlStateNormal];
    [emotionBtn addTarget:self action:@selector(changeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [replyView addSubview:emotionBtn];
    
    _textToSend = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(70, 5, 190, 30)];
    _textToSend.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _textToSend.layer.cornerRadius = 5;
    _textToSend.backgroundColor = [UIColor yellowColor];
    _textToSend.minNumberOfLines = 1;
    _textToSend.maxNumberOfLines = 3;
//    _textToSend.returnKeyType = UIReturnKeyGo; //just as an example
    _textToSend.font = [UIFont systemFontOfSize:15.0f];
    _textToSend.delegate = self;
    _textToSend.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textToSend.hidden = NO;
    _textToSend.backgroundColor = [UIColor whiteColor];
//    _textToSend.returnKeyType = UIReturnKeySend;
    [replyView addSubview:_textToSend];
    
    //录音view
    volumeView = [[UIView alloc] initWithFrame:CGRectMake(60, 200, 200, 200)];
    volumeView.center = self.view.center;
    volumeView.backgroundColor = [UIColor clearColor];
    [volumeView setHidden:YES];
    
    UIImageView *volumeViewBg = [[UIImageView alloc] init];
    volumeViewBg.frame = CGRectMake(0, 0, 200, 200);
    volumeViewBg.backgroundColor = [UIColor blackColor];
    volumeViewBg.alpha = 0.5;
    volumeViewBg.layer.cornerRadius = 10;
    [volumeView addSubview:volumeViewBg];
    
    phone = [[UIImageView alloc] init];
    phone.frame = CGRectMake(50, 21, 58, 157);
    NSString *phonePath = [[NSBundle mainBundle] pathForResource:@"voice_rcd_hint" ofType:@"png"];
    UIImage *phoneImage = [UIImage imageWithContentsOfFile:phonePath];
    [phone setImage:phoneImage];
    [volumeView addSubview:phone];
    
    volume = [[UIImageView alloc] init];
    NSString *volumePath = [[NSBundle mainBundle] pathForResource:@"amp1" ofType:@"png"];
    UIImage *volumeImage = [UIImage imageWithContentsOfFile:volumePath];
    [volume setImage:volumeImage];
    volume.frame = CGRectMake(108, 21+157-volumeImage.size.height, volumeImage.size.width, volumeImage.size.height);
    [volumeView addSubview:volume];
    
    _recordTime = [[UILabel alloc]initWithFrame:CGRectMake(phone.center.x-70, phone.center.y+20, 40, 20)];
    _recordTime.backgroundColor = [UIColor clearColor];
    _recordTime.textAlignment = NSTextAlignmentCenter;
    _recordTime.text = @"55'";
    [phone addSubview:_recordTime];
    
    //丢弃录音
    dropLabel = [[UILabel alloc] init];
    dropLabel.frame = CGRectMake(0, 160, 200, 40);
    dropLabel.text = @"松开手指，放弃语音";
    dropLabel.backgroundColor = [UIColor clearColor];
    dropLabel.textColor = [UIColor whiteColor];
    dropLabel.textAlignment = NSTextAlignmentCenter;
    [dropLabel setHidden:YES];
    [volumeView addSubview:dropLabel];
    
    UIImage *dropImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_voice_drop" ofType:@"png"]];
    dropImgView = [[UIImageView alloc] init];
    dropImgView.image = dropImg;
    dropImgView.frame = CGRectMake(43, 37, 114, 126);
    [dropImgView setHidden:YES];
    [volumeView addSubview:dropImgView];
    
    tapCancelReplyBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight)];
    [tapCancelReplyBtn addTarget:self action:@selector(replyCancel) forControlEvents:UIControlEventTouchUpInside];
    tapReplyCancel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replyCancel) ];
    [self addKey];
    [_textToSend becomeFirstResponder];
}

-(void)changeKeyboard{
    static BOOL on = NO;
    faceBoard.inputTextView = (UITextView *)_textToSend;
    if (!emotionBtn.tag) {
        [self.view removeKeyboardControl];
        replyView.frame = CGRectMake(0, myConstants.screenHeight-20-44-216-replyView.frame.size.height, 320, replyView.frame.size.height);
        [emotionBtn setImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
        emotionBtn.tag = 1;
//        faceBoard.frame = CGRectMake(0,myConstants.screenHeight-20-44-216, 320, 216);
        faceBoard.hidden = NO;
        faceBoard.count = [_textToSend.text length]-_textToSend.selectedRange.location;
        WeLog(@"Leftcount%d",faceBoard.count);
        [self.view addSubview:faceBoard];
        [_textToSend resignFirstResponder];

//        myTV.inputView = faceBoard;
//        [myTV becomeFirstResponder];
    }else{
        [self addKey];
//        replyView.frame = CGRectMake(0, myConstants.screenHeight-20-44-44, 320, 44);
        [emotionBtn setImage:[UIImage imageNamed:@"emotion.png"] forState:UIControlStateNormal];
        emotionBtn.tag = 0;

        faceBoard.inputTextView = nil;
        //        [_textToSend resignFirstResponder];

        [_textToSend becomeFirstResponder];
        faceBoard.hidden = YES;
    }
    on = !on;
}

-(BOOL)check{
    if (_textToSend.hidden == NO) {
        if (![[_textToSend.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]) {
            [Utility MsgBox:@"文章内容不能为空!"];
            return NO;
        }
        if ([Utility unicodeLengthOfString:_textToSend.text]>140) {
            [Utility MsgBox:@"文章内容不能超过140个字符!"];
            return NO;
        }
    }
    return YES;
}

-(void)reply{
    sortFlag = NO;
//    [menuBtn setImage:[UIImage imageNamed:IMAGE_SORT] forState:UIControlStateNormal];
    if (![self check]) {
        return;
    }
    faceBoard.hidden = YES;
    [replyView removeFromSuperview];

    postURLStr = URL_CLUB_ARTICLE_POST;
    NSString *replyRowkeyString;
    NSDictionary *audioDic;
    NSString *content = _textToSend.text;
    if (-1==toReply) {
        replyRowkeyString = topicArticle.rowKey;

    }else{
        WeLog(@"TOReply%d",toReply);
        Article *replyArticle = [replyArticleList objectAtIndex:toReply];
        replyRowkeyString = replyArticle.rowKey;
    }
    if (audioData&&_textToSend.hidden) {
        WeLog(@"回复音频的大小%d",[audioData length]);
        audioDic = [NSDictionary dictionaryWithObjectsAndKeys:audioData,@"attachment", nil];
        content = myAccountUser.name;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:topicArticle.articleClubID forKey:KEY_ID];
    [dic setValue:replyRowkeyString forKey:KEY_ARTICLE_REPLY_ROW_KEY];
    [dic setValue:topicArticle.rowKey forKey:KEY_ARTICLE_ROW_KEY];
    [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    [dic setValue:content forKey:KEY_CONTENT];
    [dic setValue:@"1" forKey:KEY_TYPE];
    [dic setValue:@"0" forKey:KEY_ARTICLE_STYLE];

    [rp sendDictionary:dic andURL:postURLStr andData:audioDic];
    [myTable reloadData];
    _textToSend.text = @"";
    lastReplyContent = @"";
}

-(void)addKey{
    CGRect cgr;
    if ([lastReplyContent length]&&!_textToSend.hidden) {
        cgr = lastReplyRect;
    }else{
        cgr = CGRectMake(0, myConstants.screenHeight-20-44-44, 320, 44);
    }
    self.view.keyboardTriggerOffset = 44;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        //CGRect toolBarFrame = toolBar.frame;
        //toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        //toolBar.frame = toolBarFrame;
        CGRect photoBarViewFrame = cgr;
        photoBarViewFrame.origin.y = keyboardFrameInView.origin.y - replyView.frame.size.height;
        replyView.frame = photoBarViewFrame;
        tapCancelReplyBtn.frame = CGRectMake(0, 0, 320, replyView.frame.origin.y);
    }];
}

- (void)moveOut:(id)sender
{
    WeLog(@"moveOut...");
    
    [phone setHidden:YES];
    [volume setHidden:YES];
    [dropLabel setHidden:NO];
    [dropImgView setHidden:NO];
}

- (void)moveIn:(id)sender
{
    WeLog(@"moveIn...");
    [phone setHidden:NO];
    [volume setHidden:NO];
    [dropLabel setHidden:YES];
    [dropImgView setHidden:YES];
}

- (void)dropRecord:(id)sender
{
    [pressToSpeak setTitle:@"按住录音" forState:UIControlStateNormal];
    WeLog(@"drop record...");
    [volumeView setHidden:YES];
    [self performSelector:@selector(moveIn:) withObject:nil];
    dropVoice = YES;
    [recorder performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(void)handleRecordTime{
    _recordTime.text = [NSString stringWithFormat:@"%d''",(int)round(recorder.currentTime)];
}

- (void)handleVolumeChange
{
    [recorder updateMeters];
    CGFloat peakPower = [recorder peakPowerForChannel:0];
    //    WeLog(@"peakPower:%f",peakPower);
    int v = (int)((35+peakPower)/5)+1;
    if (v>0 && v<=7) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"amp%d.png",v]];
        volume.frame = CGRectMake(108, 21+157-img.size.height, img.size.width, img.size.height);
        volume.image = img;
    }else{
        UIImage *img = [UIImage imageNamed:@"amp1.png"];
        volume.frame = CGRectMake(108, 21+157-img.size.height, img.size.width, img.size.height);
        volume.image = img;
    }
    
    if (recorder.currentTime>30) {
        [volumeTimer invalidate];
        [self recordEnd];
        [Utility showHUD:@"录音达到最大长度30秒"];
    }
}

- (void)recordEnd
{
    [pressToSpeak setTitle:@"按住录音" forState:UIControlStateNormal];
    WeLog(@"recordEnd...");
    [volumeView setHidden:YES];
    [self performSelector:@selector(moveIn:) withObject:nil];
    if (recorder.currentTime < 1) {
        [Utility showHUD:@"语音时间太短!"];
        dropVoice = YES;
    }else{
        dropVoice = NO;
    }
    [recorder performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

-(void)switchTextOrVoice{
    static BOOL flag = YES;
    [self addKey];
    if (flag) {
        lastReplyRect = replyView.frame;
        lastTextViewRect = _textToSend.frame;
        lastReplyContent = _textToSend.text;
        [_textToSend becomeFirstResponder];
        _textToSend.hidden = YES;
        replyView.frame = CGRectMake(0, myConstants.screenHeight-20-44-44, 320, 44);
        [voiceChatButton setImage:[UIImage imageNamed:@"text.png"] forState:UIControlStateNormal];
        inputField.hidden = YES;
        emotionBtn.hidden = YES;
        sendButton.hidden = YES;
        pressToSpeak.hidden = NO;
        [self addKey];
        [inputField resignFirstResponder];
        [_textToSend resignFirstResponder];
//        [self.view removeKeyboardControl];
    }else{
        _textToSend.hidden = NO;
        emotionBtn.hidden = NO;
        sendButton.hidden = NO;
        if ([lastReplyContent length]) {
            _textToSend.frame = lastTextViewRect;
        }else{
            _textToSend.frame = CGRectMake(70, 5, 190, 30);
        }
        [voiceChatButton setImage:[UIImage imageNamed:@"chat_input_voice.png"] forState:UIControlStateNormal];
        inputField.hidden = NO;
        pressToSpeak.hidden = YES;
        [self addKey];
        [inputField becomeFirstResponder];
        [_textToSend becomeFirstResponder];
    }
    flag = !flag;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (faceBoard.hidden == NO) {
        [emotionBtn setImage:[UIImage imageNamed:@"emotion.png"] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark  录制音频
- (void)audioRecordStart{
    [[AudioPlay getSingleton]stop];
    [self audioStop];
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {
        shouldResume = YES;
    }
    [_recordTimeTimer invalidate];
    [volumeTimer invalidate];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setActive:NO error:nil];
    [audioSession setActive:YES error:nil];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    _recordTime.text = @"0''";
    _recordTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(handleRecordTime) userInfo:nil repeats:YES];

    
    [pressToSpeak setBackgroundImage:[[UIImage imageNamed:@"VoiceBtn_BlackHL.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] forState:UIControlStateNormal];
    [pressToSpeak setTitle:@"松开结束" forState:UIControlStateNormal];
    [audioPlay stop];
    [volumeView setHidden:NO];
    [self.view addSubview:volumeView];
    
    NSString *fileName = @"testrecord.caf";
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    WeLog(@"filePath:%@",filePath);
    
    NSURL *url = [NSURL URLWithString:filePath];
    NSError *error;
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    if (!recorder) {
        recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
    }
    [recorder prepareToRecord];
    [recorder performSelector:@selector(record) withObject:nil afterDelay:0.1];
    dropVoice = NO;
    
    volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(handleVolumeChange) userInfo:nil repeats:YES];
}

- (void)audioRecordStop{
    [recorder performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (dropVoice) {
        return;
    }
    WeLog(@"audioRecorderDidFinishRecording...");
    NSString *fileName = @"testrecord.caf";
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    WeLog(@"length:%d",data.length);
    NSData *amrData = EncodeWAVEToAMR(data, 1, 16);
    WeLog(@"amrdata:%d",amrData.length);
    audioData = amrData;
    [self reply];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
}

-(void)createToolbar{
    [toolBar removeFromSuperview];
    toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, myConstants.screenHeight-20-44-40, 320, 40)];
    UIImageView *toolBarBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    toolBarBg.image = [UIImage imageNamed:@"toolbar_bg.png"];
    toolBarBg.backgroundColor = [UIColor clearColor];
    [toolBar addSubview:toolBarBg];
    //回复按钮
    UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replyBtn.tag = JOIN;
    [replyBtn setImage:[UIImage imageNamed:@"reply.png"] forState:UIControlStateNormal];
    [replyBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *replyLbl = [[UILabel alloc]init];
    replyLbl.textAlignment = UITextAlignmentCenter;
    [Utility styleLbl:replyLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
    replyLbl.text = @"回复";

    //收藏按钮
    UIButton *followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    followBtn.tag = FOLLOW;
    [followBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *followLbl = [[UILabel alloc]init];
    followLbl.textAlignment = UITextAlignmentCenter;
    [Utility styleLbl:followLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
    if (topicArticle.followtheArticleFlag) {
        followLbl.text = @"取消收藏";
        [followBtn setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    }else{
        followLbl.text = @"收藏";
        [followBtn setImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
    }
    
    //分享按钮
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.tag = SHARE;
    [shareBtn setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *shareLbl = [[UILabel alloc]init];
    shareLbl.textAlignment = UITextAlignmentCenter;
    [Utility styleLbl:shareLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
    shareLbl.text = @"分享";
    
    //举报按钮
    UIButton *reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reportBtn.tag = REPORT;
    [reportBtn setImage:[UIImage imageNamed:@"report.png"] forState:UIControlStateNormal];
    [reportBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *reportLbl = [[UILabel alloc]init];
    [Utility styleLbl:reportLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
    reportLbl.text = @"举报";
    reportLbl.textAlignment = UITextAlignmentCenter;
    
    //更多按钮
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.tag = POST;
    [moreBtn setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(clubOperation:) forControlEvents:UIControlEventTouchUpInside];
    UILabel * moreLbl = [[UILabel alloc]init];
    moreLbl.textAlignment = UITextAlignmentCenter;
    [Utility styleLbl:moreLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
    moreLbl.text = @"更多";

    //以上初始化所有按钮
    //============================================================
    //精华文章，
    if (isDigest) {
        if ((club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN)) {
            UIButton *cancelDigestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelDigestBtn.tag = REPORT;
            cancelDigestBtn.frame = CGRectMake(0, 0, 320, 40);
            
            [cancelDigestBtn setImage:[UIImage imageNamed:@"report.png"] forState:UIControlStateNormal];
            cancelDigestBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320-8)/2, 21, (320-8)/2);
            [cancelDigestBtn addTarget:self action:@selector(cancelDigest) forControlEvents:UIControlEventTouchUpInside];
            UILabel *cancelDigestLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 320, 14)];
            cancelDigestLbl.textAlignment = UITextAlignmentCenter;
            [Utility styleLbl:cancelDigestLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
            cancelDigestLbl.text = @"取消精华文章";
            [toolBar addSubview:cancelDigestBtn];
            [toolBar addSubview:cancelDigestLbl];
            [self.view addSubview:toolBar];
            [self performSelector:@selector(changeTableViewFrame) withObject:nil afterDelay:1.0];
        }
        return;
    }
    int menuCount = 5;

//    if (!(club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN || [topicArticle.userName isEqualToString:myAccountUser.name]))
    
//    //版主版副文章作者
//    if (!(club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN)){
//        menuCount = 4;
//        toolBarBg.image = [UIImage imageNamed:@"toolbar_bg4.png"];
//        
//    }else{
//        moreBtn.frame = CGRectMake(4*320/menuCount, 0, 320/menuCount, 40);
//        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
//        moreLbl.frame = CGRectMake(4*320/menuCount, 27, 320/menuCount, 14);
//        [toolBar addSubview:moreBtn];
//        [toolBar addSubview:moreLbl];
//    }
    //toolBar 高度30,因为字数个数的原因，不能再设置buttontitle了，edgeinsets不好调
    replyBtn.frame = CGRectMake(0, 0, 320/menuCount, 40);
    replyBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
    replyLbl.frame = CGRectMake(0, 27, 320/menuCount, 14);

    shareBtn.frame = CGRectMake(2*320/menuCount, 0, 320/menuCount, 40);
    shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
    shareLbl.frame = CGRectMake(2*320/menuCount, 27, 320/menuCount, 14);

    followBtn.frame = CGRectMake(320/menuCount, 0, 320/menuCount,40);
    followBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
    followLbl.frame = CGRectMake(320/menuCount, 27, 320/menuCount, 14);

    reportBtn.frame = CGRectMake(3*320/menuCount, 0, 320/menuCount, 40);
    reportBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-8)/2, 21, (320/menuCount-8)/2);
    reportLbl.frame = CGRectMake(3*320/menuCount, 27, 320/menuCount, 14);
    
    moreBtn.frame = CGRectMake(4*320/menuCount, 0, 320/menuCount, 40);
    moreBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
    moreLbl.frame = CGRectMake(4*320/menuCount, 27, 320/menuCount, 14);

    //作者(会员+版主):回复 分享 更多
    if ([topicArticle.userName isEqualToString:myAccountUser.name]&&club.userType != USER_TYPE_USER) {
        menuCount = 3;
        toolBarBg.image = [UIImage imageNamed:@"toolbar_bg3.png"];
        replyBtn.frame = CGRectMake(0, 0, 320/menuCount, 40);
        replyBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        replyLbl.frame = CGRectMake(0, 27, 320/menuCount, 14);
        shareBtn.frame = CGRectMake(1*320/menuCount, 0, 320/menuCount, 40);
        shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        shareLbl.frame = CGRectMake(1*320/menuCount, 27, 320/menuCount, 14);
        moreBtn.frame = CGRectMake(2*320/menuCount, 0, 320/menuCount, 40);
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        moreLbl.frame = CGRectMake(2*320/menuCount, 27, 320/menuCount, 14);
        [toolBar addSubview:replyBtn];
        [toolBar addSubview:replyLbl];
        [toolBar addSubview:moreBtn];
        [toolBar addSubview:moreLbl];
    }
    
    //非作者(版主):回复 收藏 分享 举报 更多
    if (![topicArticle.userName isEqualToString:myAccountUser.name]&&((club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN))){
        [toolBar addSubview:replyBtn];
        [toolBar addSubview:replyLbl];
        [toolBar addSubview:followBtn];
        [toolBar addSubview:followLbl];
        [toolBar addSubview:reportBtn];
        [toolBar addSubview:reportLbl];
        [toolBar addSubview:moreBtn];
        [toolBar addSubview:moreLbl];
    }
    
    //非作者(会员):回复 收藏 分享 举报
    if (![topicArticle.userName isEqualToString:myAccountUser.name]&&((club.userType == USER_TYPE_MEMBER ||club.userType == USER_TYPE_HONOR_MEMBER))){
        menuCount = 4;
        toolBarBg.image = [UIImage imageNamed:@"toolbar_bg4.png"];
        replyBtn.frame = CGRectMake(0, 0, 320/menuCount, 40);
        replyBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        replyLbl.frame = CGRectMake(0, 27, 320/menuCount, 14);
        
        followBtn.frame = CGRectMake(320/menuCount, 0, 320/menuCount,40);
        followBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        followLbl.frame = CGRectMake(320/menuCount, 27, 320/menuCount, 14);
        
        shareBtn.frame = CGRectMake(2*320/menuCount, 0, 320/menuCount, 40);
        shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        shareLbl.frame = CGRectMake(2*320/menuCount, 27, 320/menuCount, 14);
        
        reportBtn.frame = CGRectMake(3*320/menuCount, 0, 320/menuCount, 40);
        reportBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-8)/2, 21, (320/menuCount-8)/2);
        reportLbl.frame = CGRectMake(3*320/menuCount, 27, 320/menuCount, 14);
        [toolBar addSubview:replyBtn];
        [toolBar addSubview:replyLbl];
        [toolBar addSubview:followBtn];
        [toolBar addSubview:followLbl];
        [toolBar addSubview:replyBtn];
        [toolBar addSubview:replyLbl];
        [toolBar addSubview:reportBtn];
        [toolBar addSubview:reportLbl];
    }

    //非会员:收藏 分享 举报
    if (club.userType == USER_TYPE_USER) {
        menuCount = 3;
        toolBarBg.image = [UIImage imageNamed:@"toolbar_bg3.png"];
        followBtn.frame = CGRectMake(0, 0, 320/menuCount,40);
        followBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        followLbl.frame = CGRectMake(0, 27, 320/menuCount, 14);
        
        shareBtn.frame = CGRectMake(1*320/menuCount, 0, 320/menuCount, 40);
        shareBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-16)/2, 18, (320/menuCount-16)/2);
        shareLbl.frame = CGRectMake(1*320/menuCount, 27, 320/menuCount, 14);
        
        reportBtn.frame = CGRectMake(2*320/menuCount, 0, 320/menuCount, 40);
        reportBtn.imageEdgeInsets = UIEdgeInsetsMake(5, (320/menuCount-8)/2, 21, (320/menuCount-8)/2);
        reportLbl.frame = CGRectMake(2*320/menuCount, 27, 320/menuCount, 14);
        [toolBar addSubview:followBtn];
        [toolBar addSubview:followLbl];
        [toolBar addSubview:reportBtn];
        [toolBar addSubview:reportLbl];
    }

//    if (club.userType != 0) {
//        [toolBar addSubview:replyBtn];
//        [toolBar addSubview:replyLbl];
//    }

    [toolBar addSubview:shareBtn];
    [toolBar addSubview:shareLbl];
    [self.view addSubview:toolBar];
    [self changeTableViewFrame];
//    [toolBar.layer addAnimation:[Utility createAnimationWithType:kCATransitionMoveIn withsubtype:kCATransitionFromTop withDuration:0.5]forKey:@"animation"];
//    [self performSelector:@selector(changeTableViewFrame) withObject:nil afterDelay:0.5];
}

-(void)changeTableViewFrame{
    myTable.frame = CGRectMake(0, 0, 320, myConstants.screenHeight-44-20-40);
}

-(void)refreshArticleInfo{
    distanceLbl.text = topicArticle.distance;
    replyCountLbl.text = topicArticle.replyCount;
    browseCountLbl.text = topicArticle.browseCount;
    shareCountLbl.text = topicArticle.shareCount;
}

//只能执行一次，创建附件窗口
-(void)initView{
    _contentHeight = [self getMixedViewHeight:topicArticle.content];
//  CGFloat contentHeight = [Utility getSizeByContent:topicArticle.content withWidth:310 withFontSize:18];
//  CGFloat contentHeight = [Utility getMixedViewHeight:topicArticle.content withWidth:310];
    NSString *str = [topicArticle.content copy];
    [self attachString:str toView:contentLbl];
    nameLbl.text = topicArticle.userName;
    distanceLbl.text = topicArticle.distance;
    replyCountLbl.text = topicArticle.replyCount;
    browseCountLbl.text = topicArticle.browseCount;
    shareCountLbl.text = topicArticle.shareCount;
    contentLbl.backgroundColor = COLOR_RED;
    [contentLbl setFrame:CGRectMake(5, 70, 310, _contentHeight)];
    CGFloat lastHeight = 0;
    if (mediaView) {
        return;
    }
    mediaView = [[UIView alloc]initWithFrame:CGRectMake(5, 70, 310, 55)];
    [Utility removeSubViews:mediaView];
    switch ([topicArticle.articleStyle intValue]) {
        case 0:
            for (int i = 0; i < [topicArticle.media count]; i++) {
                UIImageView *mediaImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 310, 100)];
                mediaImg.layer.borderColor = [[UIColor grayColor]CGColor];
                mediaImg.layer.borderWidth = 0.5;
                NSString *media = [topicArticle.media objectAtIndex:i];
                mediaImg.tag = i+1;
                mediaImg.userInteractionEnabled = YES;
                mediaImg.contentMode = UIViewContentModeScaleAspectFit;
                NSString *type = [media substringFromIndex:([media length]-1)];
                mediaImg.frame = CGRectMake(0,lastHeight+10, 310, 310);

                if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
                    //new
                    if (isDigest) {
                        __weak __block UIImageView *img = mediaImg;
                        if ([[SDImageCache sharedImageCache] imageFromKey:[ArticleImageURL(media, TYPE_THUMB) absoluteString] fromDisk:YES]) {
                            [mediaImg setImageWithURL:DigestImageURL(media, TYPE_RAW) placeholderImage:[[SDImageCache sharedImageCache] imageFromKey:[DigestImageURL(media, TYPE_THUMB) absoluteString] fromDisk:YES] success:^(UIImage *image) {
                                [self refreshImageView:img];
                                [self refreshMediaView];
                            } failure:^(NSError *error) {
                                
                            }];
                        }else{
                            [mediaImg setImageWithURL:DigestImageURL(media, TYPE_RAW) placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ATTACHMENT_PIC_HOLDER_BIG ofType:@"png"]]success:^(UIImage *image) {
                                [self refreshImageView:img];
                                [self refreshMediaView];
                            } failure:^(NSError *error) {
                                
                            }];
                        }
                       
                    }else{
                        __weak __block UIImageView *img = mediaImg;
                        if ([[SDImageCache sharedImageCache] imageFromKey:[ArticleImageURL(media, TYPE_THUMB) absoluteString] fromDisk:YES]) {
                            [mediaImg setImageWithURL:ArticleImageURL(media, TYPE_RAW) placeholderImage:[[SDImageCache sharedImageCache] imageFromKey:[ArticleImageURL(media, TYPE_THUMB) absoluteString] fromDisk:YES] success:^(UIImage *image) {
                                [self refreshImageView:img];
                                [self refreshMediaView];
                            } failure:^(NSError *error) {
                                
                            }];
                        }else{
                            [mediaImg setImageWithURL:ArticleImageURL(media, TYPE_RAW) placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ATTACHMENT_PIC_HOLDER_BIG ofType:@"png"]]success:^(UIImage *image) {
                                [self refreshImageView:img];
                                [self refreshMediaView];
                            } failure:^(NSError *error) {
                                
                            }];
                        }
                        
                    }

                CGFloat width = mediaImg.image.size.width;
                    CGFloat height = mediaImg.image.size.height;
                    WeLog(@"width%fheight%f",width,height);
                    if (width > height) {
                        mediaImg.frame = CGRectMake(0,lastHeight+10, 310, 310*height/width);
                        lastHeight = lastHeight + 310*height/width+10;
                        WeLog(@"width > height");
                    }else if (width < height){
                        if (310*height/width > 310*2) {
                            mediaImg.frame = CGRectMake(0, lastHeight+10, 310, 620);
                            lastHeight = lastHeight + 620+10;
                            WeLog(@"width > 2height");
                        }else{
                            mediaImg.frame = CGRectMake(0, lastHeight+10, 310, 310*height/width);
                            lastHeight = lastHeight + 310*height/width+10;
                            WeLog(@"width > height");
                        }
                    }else{
                        WeLog(@"width == height");
                        //width == height不用改变
                        lastHeight = lastHeight + 310+10;
                    }
                    [mediaView addSubview:mediaImg];
                    [Utility addTapGestureRecognizer:mediaImg withTarget:self action:@selector(viewLargePhoto:)];

                }else if ([type isEqualToString:TYPE_ATTACH_AUDIO]){
                    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 32)];
                    bgView.backgroundColor = [UIColor blackColor];
                    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    playBtn.frame = CGRectMake(0, 0, 50, 30);
                    playBtn.tag = i;
                    [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
                    playBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 15, 5, 15);;
                    [playBtn addTarget:self action:@selector(audioPlay:) forControlEvents:UIControlEventTouchUpInside];
                    
                    UISlider *progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(50,2,185, 30)];
                    progressSlider.tag = 5;
                    progressSlider.minimumValue = 0.0;
                    progressSlider.userInteractionEnabled = NO;
                    
                    UILabel *currentTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(235, 5, 65, 20)];
                    currentTimeLbl.tag = 6;

                    currentTimeLbl.text = [NSString stringWithFormat:@"00:00/00:%@",[NSString stringWithFormat:@"%02d",[[[topicArticle.mediaInfo objectForKey:media] objectForKey:DURATION] intValue]]];
                    [Utility styleLbl:currentTimeLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
                    mediaImg.frame = CGRectMake(0, lastHeight+10, 310, 32);
                    [mediaImg addSubview:bgView];
                    [bgView addSubview:playBtn];
                    [bgView addSubview:progressSlider];
                    [bgView addSubview:currentTimeLbl];
//                  [mediaView addSubview:audioImg];
                    [mediaView addSubview:mediaImg];

                    lastHeight = lastHeight + 32+10;
                }else if([type isEqualToString:TYPE_ATTACH_VIDEO]){
                    if (isDigest) {
                        [mediaImg setImageWithURL:DigestImageURL(media,TYPE_THUMB) placeholderImage:[UIImage imageNamed:VIDEO_PIC_HOLDER]];
                    }else{
                        [mediaImg setImageWithURL:ArticleImageURL(media,TYPE_THUMB) placeholderImage:[UIImage imageNamed:VIDEO_PIC_HOLDER]];
                    }
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
                    [tap addTarget:self action:@selector(videoPlay:)];
                    [mediaImg addGestureRecognizer:tap];
                    UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:VIDEO_PLAY_ICON]];
                    videoIcon.frame = CGRectMake(135,140,50,50);
                    
                    //附件时间长度
                    UILabel *audioLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(135, 190, 50,20)];
                    [Utility styleLbl:audioLengthLbl withTxtColor:nil withBgColor:nil withFontSize:10];
                    
                    audioLengthLbl.textColor = ATTACHTIME_LENGTH_LBL_COLOR;
                    audioLengthLbl.textAlignment = NSTextAlignmentCenter;
                    if ([topicArticle.mediaInfo isKindOfClass:[NSDictionary class]]) {
                        audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[topicArticle.mediaInfo objectForKey:media] objectForKey:DURATION]];
                    }
//                    videoIcon.center = mediaImg.center;
                    [mediaImg addSubview:audioLengthLbl];
                    [mediaImg addSubview:videoIcon];
                    [mediaView addSubview:mediaImg];
                    lastHeight = lastHeight + 310+10;
                }
                //        lastHeight = lastHeight + mediaImg.image.size.height+10;
            }
            break;
        case 1:{
            break;}
        case 2:{
            break;}
        case 3:
            break;
    }

    mediaView.frame = CGRectMake(5, 70+_contentHeight+5, 310, lastHeight);
    [headerView addSubview:mediaView];

    headerView.backgroundColor = [UIColor redColor];
    [headerView setFrame:CGRectMake(0, 0, 320, 70+_contentHeight+5+lastHeight+14+5)];
    [self.view addSubview:myTable];
    bg.frame = headerView.frame;
    myTable.tableHeaderView = headerView;
    myTable.delegate = self;
    UIFont *font = [UIFont fontWithName:FONT_NAME_ARIAL size:12];
    postTimeLbl.font = font;
    if ([club.ID isEqualToString:topicArticle.articleClubID]) {
        postTimeLbl.text = [NSString stringWithFormat:@"发于%@",topicArticle.postTime];
        CGSize size = [postTimeLbl.text sizeWithFont:font constrainedToSize:CGSizeMake(900, 15) lineBreakMode:UILineBreakModeTailTruncation];
        [postTimeLbl setFrame:CGRectMake(70,45, size.width, 14)];
    }else{
        postTimeLbl.text = [NSString stringWithFormat:@"%@发于",topicArticle.postTime];
        postTimeLbl.userInteractionEnabled = YES;
        CGSize size1 = [[NSString stringWithFormat:@"<%@>",topicArticle.articleClubName] sizeWithFont:font constrainedToSize:CGSizeMake(900, 15) lineBreakMode:UILineBreakModeTailTruncation];
        CGSize size2 = [[NSString stringWithFormat:@"%@发于",topicArticle.postTime] sizeWithFont:font constrainedToSize:CGSizeMake(900, 15) lineBreakMode:UILineBreakModeTailTruncation];
//        [postTimeLbl setFrame:CGRectMake(320-size1.width-size2.width-5, mediaView.frame.origin.y+lastHeight+2, size2.width, 14)];
        [postTimeLbl setFrame:CGRectMake(70, 45, size2.width, 14)];
         goClubBtn = [[UIButton alloc]initWithFrame:CGRectMake(70+size2.width, 45, size1.width, 14)];
        [goClubBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:12]];
        [goClubBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [goClubBtn setTitle:[NSString stringWithFormat:@"<%@>",topicArticle.articleClubName] forState:UIControlStateNormal];
        [goClubBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [headerView addSubview:goClubBtn];
        [goClubBtn addTarget:self action:@selector(goClub:) forControlEvents:UIControlEventTouchUpInside];
    }
    [avatar setImageWithURL:USER_HEAD_IMG_URL(@"small", topicArticle.avatarURL) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
}


-(void)refreshImageView:(UIImageView *)mediaImg{
    CGFloat width = mediaImg.image.size.width;
    CGFloat height = mediaImg.image.size.height;
    WeLog(@"width%fheight%f",width,height);
    if (width > height) {
        mediaImg.frame = CGRectMake(0,0, 310, 310*height/width);
//        lastHeight = lastHeight + 310*height/width+10;
        WeLog(@"width > height");
    }else if (width < height){
        if (310*height/width > 310*2) {
            mediaImg.frame = CGRectMake(0, 0, 310, 620);
//            lastHeight = lastHeight + 620+10;
            WeLog(@"width > 2height");
        }else{
            mediaImg.frame = CGRectMake(0, 0, 310, 310*height/width);
//            lastHeight = lastHeight + 310*height/width+10;
            WeLog(@"width > height");
        }
    }else{
        mediaImg.frame = CGRectMake(0, 0, 310, 310);
        WeLog(@"width == height");
        //width == height不用改变
//        lastHeight = lastHeight + 310+10;
    }
}

//图片下载引起viewframe变化
-(void)refreshMediaView{
    int i;
    for (i = 1; i <= [topicArticle.media count]; i++) {
        if (i == 1) {
            [mediaView viewWithTag:i].frame = CGRectMake(0, 10, [mediaView viewWithTag:i].frame.size.width, [mediaView viewWithTag:i].frame.size.height);
        }else{
            [mediaView viewWithTag:i].frame = CGRectMake(0, [mediaView viewWithTag:i-1].frame.origin.y+[mediaView viewWithTag:i-1].frame.size.height+10, [mediaView viewWithTag:i].frame.size.width, [mediaView viewWithTag:i].frame.size.height);
        }
    }
    float mediaHeight = [[mediaView viewWithTag:i-1] frame].origin.y+[[mediaView viewWithTag:i-1] frame].size.height+10;
    mediaView.frame = CGRectMake(5, 70+_contentHeight+5, 310, mediaHeight);
    [headerView addSubview:mediaView];
    
    headerView.backgroundColor = [UIColor redColor];
    [headerView setFrame:CGRectMake(0, 0, 320, 70+_contentHeight+5+mediaHeight+14+5)];
    [self.view addSubview:myTable];
    bg.frame = headerView.frame;
    myTable.tableHeaderView = headerView;
}

-(void)videoPlay:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    int mediaNum = tap.view.tag;
    WeLog(@"AudoURL%@",ClubImageURL([topicArticle.media objectAtIndex:mediaNum],TYPE_RAW));
    VideoPlayer *videoPlay = [VideoPlayer getSingleton];
//    [videoPlay playVideoWithName:[topicArticle.media objectAtIndex:mediaNum] withType:@"articleVideo"];
    [videoPlay playVideoWithURL:[NSString stringWithFormat:@"%@/%@/article/file?name=%@&type=%@",HOST,PHP,[topicArticle.media objectAtIndex:mediaNum],TYPE_RAW] withType:@"articleVideo" view:self];
}

-(void)interruptOtherAudio{
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {
        shouldResume = YES;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
}

-(void)resumeOtherAudio{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:NO error:nil];
    if (shouldResume) {
        [[MPMusicPlayerController iPodMusicPlayer]play];
        shouldResume = NO;
    }
}

-(void)finishLoadAudio{
    NSData *armData = [NSData dataWithContentsOfFile:mediaPath];
    NSData *downLoadAudioData = DecodeAMRToWAVE(armData);
    WeLog(@"gotAudioLength%dKB",[armData length]/1024);

    [self interruptOtherAudio];
    newPlayer = [[AVAudioPlayer alloc] initWithData:downLoadAudioData error:nil];
    newPlayer.delegate = self;
    newPlayer.numberOfLoops = 0;
    [newPlayer prepareToPlay];//初始化调用
    [newPlayer play];
    playingSlider.maximumValue = newPlayer.duration;
    playAudioTimer = [NSTimer timerWithTimeInterval:0.01
                                             target:self
                                           selector:@selector(updateCurrentTime)
                                           userInfo:nil repeats:YES];
//    playAudioTimer =[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:playAudioTimer forMode:NSRunLoopCommonModes];
//    }
//    [playingBtn setImage:[UIImage imageNamed:@"audio_pause.png"] forState:UIControlStateNormal];
//    lastPlayAudioNO = mediaNO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [playAudioTimer invalidate];
    playAudioTimer = nil;
    [playingBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    playingBtn = nil;
    playingSlider.value = 0;
    playingSlider = nil;
    playingTimeLbl.text = [NSString stringWithFormat:@"00:00%@",[playingTimeLbl.text substringFromIndex:5]];
    playingTimeLbl = nil;
    [self resumeOtherAudio];
}

-(void)updateCurrentTime{
        NSString *current = [NSString stringWithFormat:@"%02d:%02d", (int)newPlayer.currentTime / 60, (int)newPlayer.currentTime % 60, nil];
        NSString *allTime = [NSString stringWithFormat:@"%02d:%02d", (int)((int)round(newPlayer.duration)) / 60, (int)((int)round(newPlayer.duration)) % 60, nil];
        playingTimeLbl.text = [NSString stringWithFormat:@"%@/%@",current,allTime];
        playingSlider.value = newPlayer.currentTime;
}

-(void)audioStop{
    [newPlayer stop];
    [self audioPlayerDidFinishPlaying:nil successfully:YES];
}

-(void)audioPlay:(id)sender{
    //防止评论中的回复音频和主题文章中的音频同时播放
    [[AudioPlay getSingleton] stop];
    UIButton *btn = (UIButton *)sender;
    if (btn == playingBtn){
        if ([newPlayer isPlaying]) {
            [playingBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            [newPlayer stop];
            [self resumeOtherAudio];
        }else{
            [self interruptOtherAudio];
            [playingBtn setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
            [newPlayer play];
            playAudioTimer = [NSTimer timerWithTimeInterval:0.01
                                                     target:self
                                                   selector:@selector(updateCurrentTime)
                                                   userInfo:nil repeats:YES];
//            playAudioTimer =[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];

            
            [[NSRunLoop mainRunLoop] addTimer:playAudioTimer forMode:NSRunLoopCommonModes];
        }
    }else{
        [playingBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        playingSlider.value = 0;
        playingTimeLbl.text = [NSString stringWithFormat:@"00:00%@",[playingTimeLbl.text substringFromIndex:5]];;
        playingBtn = btn;
        playingSlider = (UISlider*)[playingBtn.superview  viewWithTag:5];
        playingTimeLbl = (UILabel*)[playingBtn.superview  viewWithTag:6];
        [playingBtn setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [arr objectAtIndex:0];
        mediaPath = [documentDir stringByAppendingPathComponent:[topicArticle.media objectAtIndex:playingBtn.tag]];
        NSURL*webUrl = ArticleImageURL([topicArticle.media objectAtIndex:playingBtn.tag], TYPE_RAW);
        WeLog(@"VideowebUrl:%@",webUrl);
        if ([[NSFileManager defaultManager] fileExistsAtPath:mediaPath]) {
            [self finishLoadAudio];
            return;
        }
        ASIHTTPRequest *videoRequest = [[ASIHTTPRequest alloc] initWithURL:webUrl];
        videoRequest.delegate = self;
        [videoRequest setDidFinishSelector:@selector(finishLoadAudio)];
        [videoRequest setDidFailSelector:@selector(LoadVideoError:)];
        [videoRequest setDownloadDestinationPath:mediaPath];
        [videoRequest startAsynchronous];
    }
}

#pragma mark AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (3 == alertView.tag) {
        //删除是本地先删除不会自动刷新的
        if (buttonIndex == 1) {
            [self operate];
        }else{
            return;
        }
        return;
    }else if ([alertView.message isEqualToString:@"举报该文章"]) {
            if (buttonIndex == 1) {
                [self doOperate:0];
            }else{
                return;
            }
            return;
    }else if (4 == alertView.tag ) {
                  //加入退出俱乐部的alert
                  if (buttonIndex == 1) {
                      NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                      [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
                      [rp sendDictionary:dic andURL:URL_CLUB_JOIN andData:nil];
                  }else{
                      return;
                  }
                  return;
    }
}
-(void)addReplyView{
    [self addKey];
    if (-1==toReply) {
        _textToSend.text = lastReplyContent;
        
    }else{
        _textToSend.text = @"";
        lastReplyContent = @"";
    }
    
    if (_textToSend.hidden) {
        [self switchTextOrVoice];
    }
    
    [_textToSend becomeFirstResponder];
//    [audioPlay stop];
    [replyView removeFromSuperview];
    WeLog(@"lastRect%f%f",lastReplyRect.origin.y,lastReplyRect.size.height);
    replyView.frame = CGRectMake(0, myConstants.screenHeight-20-44-44, 320, 44);
    postURLStr = URL_CLUB_ARTICLE_POST;
    [self.view addSubview:tapCancelReplyBtn];
//    [self.view addGestureRecognizer:tapReplyCancel];
    [self.view addSubview:replyView];
}

-(void)clubOperation:(id)sender{
    UIButton *btn = (UIButton *)sender;
    PostArticleViewController *postArticleView;
    UIActionSheet *ac;

    WeLog(@"ArticleDetailView:userType%d",club.userType);
    switch (btn.tag) {
        case JOIN:{
            WeLog(@"club.type:%d",club.type);
            if (!club.type &&club.userType == USER_TYPE_USER){
//                [self checkAccess];
                if (club.userType == 2) {
                    [Utility MsgBox:@"只有该俱乐部的会员可以发文!"];
                    //后续会做加入该俱乐部的实现
                    return;
                }
            }
            _textToSend.text = @"";
            toReply = -1;
            [self addReplyView];
            return;
            postArticleView = [[PostArticleViewController alloc]initWithNibName:@"PostArticleViewController" bundle:nil];
            UINavigationController *NAV = [[UINavigationController alloc]initWithRootViewController:postArticleView];
            NAV.navigationBar.tintColor = TINT_COLOR;
            
            //[self.navigationController.view.layer addAnimation:animation forKey:nil];
            //[self.navigationController pushViewController:postArticleView animated:NO];
            [self presentModalViewController:NAV animated:YES];
            WeLog(@"%@%@",self.presentingViewController,self.presentedViewController);
            
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(dismissModal) name:@"DISMISS_MODAL" object:nil ];
            return;
            //发送请求，在成功后更改图标为已加入的状态，失败则报错"加入％@俱乐部失败"
            break;}
        case SHARE:{
            //[self share];
            [ShareSDKManager shareArticleWithClubName:club.name andContent:topicArticle.content andUserName:topicArticle.userName andRightBarItem:self.navigationItem.rightBarButtonItem andSendShare:^(NSString *destination) {
                [self sendShare:destination];
            }];
            break;
        }
        case FOLLOW:{
            postURLStr = URL_ARTICLE_FOLLOW;
            [self operate];
            break;}
        case REPORT:{
                postURLStr = URL_ARTICLE_REPORT;
                ac = [[UIActionSheet alloc] initWithTitle:@"举报该文章"
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:@"垃圾广告",@"淫秽信息",@"不实信息",@"人身攻击",@"其他",nil];
                ac.tag = 0;
                ac.actionSheetStyle = UIBarStyleBlackTranslucent;
                [ac showInView:self.view];
            break;}
        case POST:{
            WeLog(@"name::%@%@",topicArticle.userName,myAccountUser.name);
            NSString *goodArticleOpertae;
            NSString *stickArticleOpertae;
            if (topicArticle.isDigest) {
                goodArticleOpertae = @"取消精华文章";
            }else{
                goodArticleOpertae = @"设为精华文章";
            }
            if (topicArticle.isOnTop) {
                stickArticleOpertae = @"取消置顶文章";
            }else{
                stickArticleOpertae = @"设为置顶文章";
            }
            
            if (club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN) {
                ac = [[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:goodArticleOpertae,stickArticleOpertae,@"删除", nil];
                ac.actionSheetStyle = UIBarStyleBlackTranslucent;

                [ac showInView:self.view];
            }else if([topicArticle.userName isEqualToString:myAccountUser.name]){
                ac = [[UIActionSheet alloc]initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除",nil];
                ac.actionSheetStyle = UIBarStyleBlackTranslucent;

                [ac showInView:self.view];
            }
            ac.tag = -1;
            break;
        }
    }
}


-(void)sendShare:(NSString *)destination{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"2" forKey:KEY_TYPE];
    [dic setValue:topicArticle.rowKey forKey:KEY_ROW_KEY];
    [dic setValue:destination forKey:@"destination"];
    [dic setValue:@"haha" forKey:KEY_CONTENT];
    [rp sendDictionary:dic andURL:URL_CLUB_SHARE andData:nil];
}

- (void)doOperate:(int)indexNum{
    ASIFormDataRequest *asiRequest = [[ASIFormDataRequest alloc] initWithURL:URL(postURLStr)];
    [asiRequest setPostValue:topicArticle.articleID forKey:KEY_CLUB_ROW_KEY];
    [asiRequest setDidFinishSelector:@selector(getResult:)];
    [asiRequest setDidFailSelector:@selector(getError:)];
    [asiRequest buildRequestHeaders];
    asiRequest.delegate = self;
    [asiRequest startAsynchronous];
    [SVProgressHUD showWithStatus:@"稍等.." maskType:SVProgressHUDMaskTypeClear];
}

#pragma mark 排序
-(void)sort{
    sortFlag = !sortFlag;
    if (!sortFlag) {
//        [menuBtn setImage:[UIImage imageNamed:IMAGE_SORT] forState:UIControlStateNormal];
    }else{
        [menuBtn setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    }
    [self loadData];
}

-(void)stop{
    [myTable.infiniteScrollingView stopAnimating];
    [myTable.pullToRefreshView stopAnimating];
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_REPLYARTICLE_LIST]||[type isEqualToString:URL_CLUB_DIGEST_REPLYARTICLE_LIST]) {

        startKey = [NSString stringWithFormat:@"%@",[dic objectForKey:KEY_STARTKEY]];
        
        NSArray *gotArray = [dic objectForKey:@"articleList"];
        if (!isLoadMore) {
            [replyArticleList removeAllObjects];
        }
        for (int i = 0; i < [gotArray count];i++) {
            Article *article = [[Article alloc]initWithDictionary:[gotArray objectAtIndex:i]];
            [replyArticleList addObject:article];

            article.repliedArticle = [[Article alloc]initWithDictionary:[[gotArray objectAtIndex:i] objectForKey:@"replyArticle"]];
//            WeLog(@"MY replyArticle");
//            [article.repliedArticle print];
        }

        [self refreshTableFooter];
        if (isLoadMore) {
            [myTable insertRowsAtIndexPaths:[Utility getIndexPaths:replyArticleList withTable:myTable] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [myTable reloadData];
        }
        readFlag = YES;
//        [myTable scrollRectToVisible:CGRectMake(0, headerView.frame.size.height, 320, 10) animated:YES];
//        [myTable scrollRectToVisible:CGRectMake(0, myTable.frame.size.height, 320, 10) animated:YES];
        [self performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    }else if ([type isEqualToString:URL_ARTICLE_VIEW]){
        NSDictionary *articleDic = [dic objectForKey:KEY_ARTICLE];
        Article *article = [[Article alloc]initWithDictionary:[articleDic objectForKey:topicArticleRowKey]];
        article.rowKey = topicArticleRowKey;
        [article print];
        topicArticle = article;
        [self initView];
        [self loadData];
        [self refreshDigestAndOntopIcon];
        [self checkUserTypeForCreateToolBar];
    }else if ([type isEqualToString:URL_CLUB_ARTICLE_POST]){
        _textToSend.text = @"";
        refreshAfterReply = YES;
        if (sortFlag) {
            [myTable scrollRectToVisible:CGRectMake(0, myTable.contentSize.height, 320, 10) animated:YES];
        }else{
            [myTable scrollRectToVisible:CGRectMake(0, headerView.frame.size.height, 320, 10) animated:YES];
        }
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.5];
    }else if ([type isEqualToString:URL_ARTICLE_DELETE]||[type isEqualToString:URL_ARTICLE_FIX_DELETE]){
        if (-1 != toReply){
            [replyArticleList removeObjectAtIndex:toReply];
            [myTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:toReply inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self refreshTableFooter];
//            [myTable reloadData];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DELETE_ARTICLE_SUCCESS" object:lastViewController userInfo:nil];
            [Utility showHUD:@"删除成功"];
            [self back];
        }
    }else if ([type isEqualToString:URL_ARTICLE_GOOD]){
        if (isDigest) {
            //从精华区点进来的,回去将它删除
            [Utility showHUD:@"取消精华成功"];
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *str = [ud objectForKey:@"informCenterArticlePush"];
            if ([str isEqualToString:@"1"]) {
                WeLog(@"%d",self.informPushIndex);
                [ud setObject:[NSString stringWithFormat:@"%d",self.informPushIndex] forKey:@"digestInformCenterArticlePush"];
                [ud synchronize];
            }
            [self back];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DELETE_ARTICLE_SUCCESS" object:lastViewController userInfo:nil];
        }else{
            [Utility showHUD:@"操作成功"];
            topicArticle.isDigest = !topicArticle.isDigest;
            if (topicArticle.isDigest) {
                digestIcon.hidden = NO;
            }else{
                digestIcon.hidden = YES;
            }
            [self refreshDigestAndOntopIcon];
            [self createToolbar];
        }
    }else if ([type isEqualToString:URL_ARTICLE_ONTOP]){
        [Utility showHUD:@"操作成功"];
        topicArticle.isOnTop = !topicArticle.isOnTop;
        if (topicArticle.isOnTop) {
            onTopIcon.hidden = NO;
        }else{
            onTopIcon.hidden = YES;
        }
        [self refreshDigestAndOntopIcon];
        [self createToolbar];
    }else if ([type isEqualToString:URL_ARTICLE_FOLLOW]){
        [Utility showHUD:@"操作成功"];
        topicArticle.followtheArticleFlag = !topicArticle.followtheArticleFlag;
        if (topicArticle.followtheArticleFlag) {
            [followIcon setImage:[UIImage imageNamed:@"follow_count.png"]];
        }else{
            [followIcon setImage:nil];
        }
        [self createToolbar];
    }else if ([type isEqualToString:URL_CLUB_REPORT]){
        [Utility showHUD:@"举报成功"];
        [self createToolbar];
    }else if ([type isEqualToString:URL_USER_CHECK_USERTYPE]) {
        //判断如果有权限在跳入新界面
        club = [[Club alloc]init];
        club.ID = topicArticle.articleClubID;
        club.type = [[dic objectForKey:@"openType"] intValue];
        club.name = topicArticle.articleClubName;
        club.userType = [[dic objectForKey:KEY_USER_TYPE] intValue];
        club.isClosed = [dic objectForKey:@"isclose"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (goToFlag) {
            if ([club.isClosed intValue]) {
                [Utility MsgBox:@"该俱乐部已关闭"];
                return;
            }
            if (club.type && club.userType == 0) {
                UIAlertView *alert = [Utility MsgBox:@"该俱乐部为私密俱乐部,只有该俱乐部会员可以查看!" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"申请加入" withStyle:0];
                alert.tag = 4;
                return;
            }
            club.followThisClub = [[dic objectForKey:KEY_FOLLOW_THIS_CLUB] intValue];
            WeLog(@"是否关注该俱乐部%d",club.followThisClub);
            ClubViewController *clubView = [[ClubViewController alloc]init];
            clubView.club = club;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
            WeLog(@"登陆用户在该俱乐部的身份%d",club.userType);
            clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
            [self.navigationController pushViewController:clubView animated:YES];
        }else{
            [self createToolbar];
        }
    }else if ([type isEqualToString:URL_CLUB_JOIN]){
        [Utility showHUD:@"申请成功"];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [self stop];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [self stop];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)refreshTableFooter{
    UILabel *tintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    tintLbl.backgroundColor = [UIColor clearColor];
    tintLbl.textColor = [UIColor grayColor];
    tintLbl.textAlignment = NSTextAlignmentCenter;
    myTable.tableFooterView = tintLbl;
    if ([startKey isEqualToString:KEY_END]) {
        if (![replyArticleList count]) {
            tintLbl.text = @"还没有人评论";
        }else{
            tintLbl.text = @"已显示全部";
        }
    }else{
        tintLbl.text = @"上拉加载更多";
    }
}


#pragma mark 加载数据
- (void)loadData{
    NSString *startKeystring;
    WeLog(@"startKey%@",startKey);
    if (isLoadMore) {
        startKeystring = startKey;
        if ([startKeystring isEqualToString:@"end"]||![startKeystring length]) {
            [myTable.infiniteScrollingView stopAnimating];
            isLoadMore = NO;
            return;
        }
    }else{
        startKeystring = @"0";
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [indicator startAnimating];
        myTable.tableFooterView = indicator;
    }
    if (!startKeystring) {
        return;
    }

    postURLStr = URL_CLUB_REPLYARTICLE_LIST;
    if (isDigest) {
        postURLStr = URL_CLUB_DIGEST_REPLYARTICLE_LIST;
    }
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:topicArticle.articleClubID forKey:KEY_ID];
    [dic setValue:[NSString stringWithFormat:@"%d",sortFlag] forKey:KEY_SORT];
    if (isDigest) {
        [dic setValue:@"1" forKey:KEY_BOARD];
    }else{
        [dic setValue:@"0" forKey:KEY_BOARD];
    }
    [dic setValue:COUNT_NUM forKey:KEY_COUNT];
    [dic setValue:startKeystring forKey:KEY_STARTKEY];
    if (isDigest) {
        [dic setValue:topicArticle.rowKey forKey:KEY_ROW_KEY];
    }else{
        [dic setValue:topicArticle.rowKey forKey:KEY_ARTICLE_ROW_KEY];
    }
    [dic setValue:[NSString stringWithFormat:@"%d",readFlag] forKey:KEY_READFLAG];
    //ReadFlag 0 first getarticle affect browse count, 1 refresh Article
    [rp sendDictionary:dic andURL:postURLStr andData:nil];
}

- (void)getTopicArticle{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setValue:topicArticleRowKey forKey:KEY_ROW_KEY];
    if (isDigest) {
        [dic setValue:@"1" forKey:@"isDigest"];
    }else{
        [dic setValue:@"0" forKey:@"isDigest"];
    }
    [rp sendDictionary:dic andURL:URL_ARTICLE_VIEW andData:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    WeLog(@"index%d",buttonIndex);
    if (1 == actionSheet.tag) {
        //点击单个回复回复，删除等操作
//        if(club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN||[myAccountUser.name isEqualToString:topicArticle.userName])
        Article *replyArticle = [replyArticleList objectAtIndex:toReply];
        if(club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN||[replyArticle.userName isEqualToString:myAccountUser.name]){
            if (1 == buttonIndex) {
                postURLStr = URL_ARTICLE_DELETE;
                UIAlertView *alert = [Utility MsgBox:@"确定删除该条回复" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"删除" withStyle:0];
                alert.tag = 3;
                return;
            }else if (0 == buttonIndex){
                [self addReplyView];
            }
        }else{
            if (0 == buttonIndex){
                [self addReplyView];
            }
        }
    }else if (0 == actionSheet.tag){
        //举报
        NSArray *reportArray = [NSArray arrayWithObjects:@"垃圾广告",@"淫秽信息",@"不实信息",@"人身攻击",@"其他", nil];
        if ([reportArray count] == buttonIndex) {
            return;
        }
        postURLStr = URL_CLUB_REPORT;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:[reportArray objectAtIndex:buttonIndex] forKey:@"reason"];
        [dic setValue:topicArticle.rowKey forKey:@"oldrowkey"];
        [dic setValue:@"2" forKey:KEY_TYPE];
        [rp sendDictionary:dic andURL:URL_CLUB_REPORT andData:nil];
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else if (-1 == actionSheet.tag){
        //设为精华，置顶等操作
        if(club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN){
            if (2 == buttonIndex) {
                postURLStr = URL_ARTICLE_DELETE;
                toReply = -1;
                UIAlertView *alert = [Utility MsgBox:@"确定删除该文章" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"删除" withStyle:0];
                alert.tag = 3;
                return;
            }else if (0 == buttonIndex){
                postURLStr = URL_ARTICLE_GOOD;
                [self operate];
            }else if (1 == buttonIndex){
                postURLStr = URL_ARTICLE_ONTOP;
                [self operate];
            }
//            else if (3 == buttonIndex){
//                postURLStr = URL_ARTICLE_FIX_DELETE;
//                [self operate];
//            }
        }else if([myAccountUser.name isEqualToString:topicArticle.userName]){
            if (0 == buttonIndex) {
                postURLStr = URL_ARTICLE_DELETE;
                UIAlertView *alert = [Utility MsgBox:@"确定删除该文章" AndTitle:nil AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"删除" withStyle:0];
                alert.tag = 3;
                return;
            }
        }
    }
}

-(void)cancelDigest{
    postURLStr = URL_ARTICLE_GOOD;
    topicArticle.isDigest = YES;
    [self operate];
}

#pragma mark 各种操作
-(void)operate{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSString *articleRowKey = topicArticle.rowKey;
    if ([postURLStr isEqualToString:URL_ARTICLE_GOOD]) {
        if (topicArticle.isDigest) {
            [dic setValue:@"delete" forKey:KEY_TYPE];
        }else{
            [dic setValue:@"add" forKey:KEY_TYPE];
        }
    }
    if ([postURLStr isEqualToString:URL_ARTICLE_ONTOP]) {
        if (topicArticle.isOnTop) {
            [dic setValue:@"delete" forKey:KEY_TYPE];
        }else{
            [dic setValue:@"add" forKey:KEY_TYPE];
        }
    }
    if ([postURLStr isEqualToString:URL_ARTICLE_FOLLOW]) {
        if (topicArticle.followtheArticleFlag) {
            [dic setValue:@"delete" forKey:KEY_TYPE];
        }else{
            [dic setValue:@"add" forKey:KEY_TYPE];
        }
    }
    
    if ([postURLStr isEqualToString:URL_ARTICLE_DELETE] ||[postURLStr isEqualToString: URL_ARTICLE_FIX_DELETE]) {
        if (-1 != toReply) {
            Article *replyArticle = [replyArticleList objectAtIndex:toReply];
            articleRowKey = replyArticle.rowKey;
        }
    }
    [dic setValue:articleRowKey forKey:KEY_ROW_KEY];
    [dic setValue:club.ID forKey:KEY_ID];
    [rp sendDictionary:dic andURL:postURLStr andData:nil];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [replyArticleList count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isDigest) {
        return;
    }
    toReply = indexPath.row;
    if (!replyView.hidden) {
        [self replyCancel];
    }
    Article *replyArticle = [replyArticleList objectAtIndex:indexPath.row];
    UIActionSheet *ac;
    WeLog(@"AccountUser%@AuthorName%@",myAccountUser.name,replyArticle.userName);
    if ([myAccountUser.name isEqualToString:replyArticle.userName]||club.userType == USER_TYPE_ADMIN || club.userType == USER_TYPE_VICE_ADMIN ) {
        ac = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作"
										 delegate:self
								cancelButtonTitle:@"取消"
						   destructiveButtonTitle:nil
								otherButtonTitles:@"回复",@"删除",nil];
    }else{
        ac = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作"
										 delegate:self
								cancelButtonTitle:@"取消"
						   destructiveButtonTitle:nil
								otherButtonTitles:@"回复",nil];
    }
    ac.tag = 1;
	ac.actionSheetStyle = UIBarStyleBlackTranslucent;
	[ac showInView:self.view];
}

-(void)replyCancel{
    if (-1==toReply) {
        lastReplyContent = _textToSend.text;
        lastReplyRect = replyView.frame;
        lastTextViewRect = _textToSend.frame;
    }
    if (pressToSpeak.state != UIControlStateNormal) {
        return;
    }
//    [self switchTextOrVoice];
    faceBoard.hidden = YES;
    [replyView removeFromSuperview];
    [tapCancelReplyBtn removeFromSuperview];
    [self.view removeGestureRecognizer:tapReplyCancel];
}

-(void)checkUserTypeForCreateToolBar{
    goToFlag = NO;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:topicArticle.articleClubID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
}

//跳到俱乐部页
- (void)goClub:(NSString *)clubID{
    goToFlag = YES;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:topicArticle.articleClubID forKey:KEY_CLUB_ROW_KEY];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_USERTYPE andData:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

//跳到个人信息
-(void)goAuthorInfo{
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:topicArticle.userName];
    [self.navigationController pushViewController:personInfoView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Article *replyArticle = [replyArticleList objectAtIndex:indexPath.row];
//    CGFloat contentHeight = [Utility getSizeByContent:replyArticle.content withWidth:250 withFontSize:18];
    
//    if (![replyArticle.replyRowkey isEqualToString:replyArticle.subjectRowKey]&&!replyArticle.repliedArticle) {
//        WeLog(@"replyArticle.replyRowkey%@replyArticle.subjectRowKey%@",replyArticle.replyRowkey,replyArticle.subjectRowKey);
//        [replyArticleNum addObject:[NSNumber numberWithInt:indexPath.row]];
//        [self getTheRepliedArticle:replyArticle.replyRowkey];
//            NSDictionary *testArticle = [NSDictionary dictionaryWithObjectsAndKeys:@"哈哈哈哈哈哈哈哈哈哈哈哈哈哈",KEY_CONTENT,nil];
//        Article *repliedArticle = [[Article alloc]initWithDictionary:testArticle];
//        replyArticle.repliedArticle = repliedArticle;
//    }
//    CGFloat cellHeight;
//    switch ([replyArticle.articleStyle intValue]) {
//        case ARTICLE_STYLE_WORDS:
//            if ([replyArticle.media count]) {
//                replyArticle.content = @"";
//            }
//            cellHeight = 5+20+contentHeight+5+60+17;//5+top_height+content_height+mediaView_height+bottom_height;
//            if (![replyArticle.media count]) {
//                cellHeight = 5+20+contentHeight+5+17;
//            }
//            WeLog(@"replyArticle.replyRowkey%@replyArticle.subjectRowKey%@",replyArticle.replyRowkey,replyArticle.subjectRowKey);
//            if ([replyArticle.replyRowkey length]&&replyArticle.repliedArticle) {
//                WeLog(@"Height:repliedArticle content%@",replyArticle.repliedArticle.content);
//                CGFloat repliedArticleContentHeight = [Utility getSizeByContent:[NSString stringWithFormat:@"%@:%@",replyArticle.repliedArticle.userName,replyArticle.repliedArticle.content]withWidth:250 withFontSize:12];;
//                cellHeight+=repliedArticleContentHeight;
//                return cellHeight;
//            }
//            break;
//        case ARTICLE_STYLE_PIC:
//            cellHeight = 5+110+20+contentHeight+5+17;
//            break;
//        case ARTICLE_STYLE_AUDIO:
//            cellHeight = 5+30+20+contentHeight+5+17;
//            break;
//        case ARTICLE_STYLE_VIDEO:
//            cellHeight = 5+110+20+contentHeight+5+17;
//            break;
//        default:
//            break;
//    }
//    if (cellHeight < 70) {
//        return 70;
//    }
    if ([replyArticle.media count]) {
        //构建是否有引用
        if (replyArticle.repliedArticle.replyRowkey) {
            if ([replyArticle.repliedArticle.media count]) {
                //音音
                return 105+25;
            }else{
                //音文
//                if (30+[Utility getSizeByContent:[NSString stringWithFormat:@"%@:%@",replyArticle.userName,replyArticle.repliedArticle.content] withWidth:250 withFontSize:18]+35<70) {
//                    return 70;
//                }
                //70是保证头像的一个标准
                if (35+[Utility getMixedViewHeight:[NSString stringWithFormat:@"回复%@楼%@:%@",replyArticle.repliedArticle.replyNO,replyArticle.userName,replyArticle.repliedArticle.content] withWidth:250]+38<70) {
                    return 70;
                }
//                return 30+[Utility getSizeByContent:[NSString stringWithFormat:@"%@:%@",replyArticle.userName,replyArticle.repliedArticle.content] withWidth:250 withFontSize:18]+35;
                return 35+[Utility getMixedViewHeight:[NSString stringWithFormat:@"回复%@楼%@:%@",replyArticle.repliedArticle.replyNO,replyArticle.userName,replyArticle.repliedArticle.content] withWidth:250]+38;
            }
        }else{
            //只有音
            return 70;
        }
    }else{
        //文字
        //构建是否有引用
        if (replyArticle.repliedArticle.replyRowkey) {
            if ([replyArticle.repliedArticle.media count]) {
                //文音
                if (35+[Utility getMixedViewHeight:replyArticle.content withWidth:250]+38+25 < 70) {
                    return 70;
                }
                return 35+[Utility getMixedViewHeight:replyArticle.content withWidth:250]+38+25;
            }else{
                //文文
                if ([Utility getMixedViewHeight:replyArticle.content withWidth:250]+[Utility getMixedViewHeight:[NSString stringWithFormat:@"回复%@楼%@:%@",replyArticle.repliedArticle.replyNO,replyArticle.userName,replyArticle.repliedArticle.content] withWidth:250]+38<70) {
                    return 70;
                }
                WeLog(@"文文height:%f",[Utility getSizeByContent:replyArticle.content withWidth:250 withFontSize:18]+[Utility getSizeByContent:[NSString stringWithFormat:@"%@:%@",replyArticle.userName,replyArticle.repliedArticle.content] withWidth:250 withFontSize:18]+25);
                return [Utility getMixedViewHeight:replyArticle.content withWidth:250]+[Utility getMixedViewHeight:[NSString stringWithFormat:@"回复%@楼%@:%@",replyArticle.repliedArticle.replyNO,replyArticle.userName,replyArticle.repliedArticle.content] withWidth:250]+38;
            }
        }else{
            //只有文
//            if ([Utility getSizeByContent:replyArticle.content withWidth:250 withFontSize:18]+20 < 70 ) {
//                return 70;
//            }
//            return [Utility getSizeByContent:replyArticle.content withWidth:250 withFontSize:18]+25;
            if ([Utility getMixedViewHeight:replyArticle.content withWidth:250]+20 < 70 ) {
                return 70;
            }
            return [Utility getMixedViewHeight:replyArticle.content withWidth:250]+28;
        }
    }
    
    return 100;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ReplyArticleCell";
    ReplyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[ReplyViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]  ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    Article *replyArticle = [replyArticleList objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    [cell initCellWithArticle:replyArticle withViewController:self];
    return cell;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    //diff为负数
    CGRect r = replyView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	replyView.frame = r;
//    [replyView viewWithTag:1].frame = replyView.frame;
//    tapCancelReplyBtn.frame = CGRectMake(0, 0, 320, replyView.frame.origin.y);
//    WeLog(@"replyview x%d",replyBgView.frame.origin.x);

//    faceBoard.frame = CGRectMake(0, myConstants.screenHeight-20-44-216, 320, 216);
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
    [emotionBtn setImage:[UIImage imageNamed:@"emotion.png"] forState:UIControlStateNormal];
    emotionBtn.tag = 0;
    faceBoard.hidden = YES;
    [self addKey];
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    if ([Utility unicodeLengthOfString:growingTextView.text]>140) {
        [Utility MsgBox:@"文章内容不能超过140个字符!"];
        return NO;
    }else if(![Utility unicodeLengthOfString:growingTextView.text]){
        [Utility MsgBox:@"文章内容不能为空!"];
        growingTextView.text = @"";
        return NO;
    }
    [self reply];
    return YES;
}


//实现了shouldChangeTextInRange这个代理就不用,上边这个代理就不调用了，所以连回车都在这个代理中判断的
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if (![[text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] length]&&![text isEqualToString:@"\u200B"]) {
//        if ([text isEqualToString:@"\n"]) {
//            if ([growingTextView.text length]) {
//                if ([Utility unicodeLengthOfString:growingTextView.text]>140) {
//                    [Utility MsgBox:@"文章内容不能超过140个字符!"];
//                    return NO;
//                }else{
//                    [self reply];
//                    [self replyCancel];
//                }
//            }else{
//                [Utility MsgBox:@"文章内容不能为空!"];
//                return NO;
//            }
//        }
//    }
    

    if (![Utility calLines:[NSString stringWithFormat:@"%@%@",growingTextView.text,text] withMaxCount:4]) {
        [Utility MsgBox:@"最多不能超过5行."];
        return NO;
    }
    if ([text isEqualToString:@""]) {
        WeLog(@"selectedRange forward%@and after%@",[growingTextView.text substringToIndex:growingTextView.selectedRange.location],[growingTextView.text substringFromIndex:growingTextView.selectedRange.location]);

        WeLog(@"growingText%@:%@",growingTextView.text,text);
        if ([Utility emtionAanalyse:[growingTextView.text substringToIndex:growingTextView.selectedRange.location]] != -1) {
            NSString *st = [growingTextView.text substringToIndex:[Utility emtionAanalyse:[growingTextView.text substringToIndex:growingTextView.selectedRange.location]]];
            growingTextView.text = [NSString stringWithFormat:@"%@%@",st,[growingTextView.text substringFromIndex:growingTextView.selectedRange.location]];
            growingTextView.selectedRange = NSMakeRange([st length], 0);
            return NO;
        }
    }

    
    return YES;
}

-(void)back{
    [rp cancel];
    [self.navigationController popViewControllerAnimated:YES];
}

//跳到顶部
-(void)scrollToTop{
    [myTable setContentOffset:CGPointMake(myTable.contentOffset.x, 0)animated:YES];
}

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    
    for (UIView * view in targetView.subviews) {
        [view removeFromSuperview];
    }
    NSMutableArray *testarr= [self cutMixedString:str];
    //    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    UIColor *nameColor = [UIColor blueColor];
    UIColor *labelColor = [UIColor redColor];
    UIColor *linkerColor = [UIColor brownColor];
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
//
//- (CGFloat)getMixedViewHeight:(NSString *)str
//{
//    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(250, 9999) lineBreakMode:NSLineBreakByCharWrapping];
//    UIView *view = [[UIView alloc] init];
//    view.frame = CGRectMake(0, 0, size.width, size.height);
//    [self attachString:str toView:view];
//    return view.frame.size.height;
//}

- (void)heightAttachString:(NSString *)str toView:(UIView *)targetView
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


- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(310, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    [self heightAttachString:str toView:view];
    return view.frame.size.height;
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
    NSString *s = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[s substringFromIndex:1]];    [self.navigationController pushViewController:personInfoView animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate查看图片大图
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

//查看大图
-(void)viewLargePhoto:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    [photos removeAllObjects];
    if (photos) {
        if (isDigest) {
            [photos addObject:[MWPhoto photoWithURL:DigestImageURL([topicArticle.media objectAtIndex:tap.view.tag-1], TYPE_RAW)]];
        }else{
            [photos addObject:[MWPhoto photoWithURL:ArticleImageURL([topicArticle.media objectAtIndex:tap.view.tag-1], TYPE_RAW)]];
        }
    }
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    nav.navigationBar.translucent = NO;

    [mwBrowser setInitialPageIndex:0];
    [self presentModalViewController:nav animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end