//
//  TopicArticleCell.m
//  WeClub
//
//  Created by chao_mit on 13-1-22.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ArticleCell.h"
#import "VideoPlayer.h"
#import "WebViewController.h"
#define LABEL_WIDTH 40

@implementation ArticleCell
@synthesize  isDigest,vc,postClubLbl,postClubBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        isForPersonInfoPage = NO;
        [self.imageView removeFromSuperview];
        [self.detailTextLabel removeFromSuperview];
        [self.textLabel removeFromSuperview];
        self.detailTextLabel.text = @"HAHAHAA";
        
        imgArray = [[NSMutableArray alloc]init];
        photos = [[NSMutableArray alloc] init] ;
        audioLblArray = [[NSMutableArray alloc] init];
        
        //用户头像
        avatar = [[UIImageView alloc]init];
        avatar.frame = CGRectMake(5, 5, 50, 50);
        avatar.layer.masksToBounds = YES;
        avatar.layer.cornerRadius = 5;
        avatar.userInteractionEnabled = YES;
        [self.contentView addSubview:avatar];
        
        //=======
        topView = [[UIView alloc]initWithFrame:CGRectMake(60, 5, 320, 14)];
        topView.backgroundColor = COLOR_GRAY;
        
        //用户名
        nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 100, 14)];
        nameLbl.text = @"音乐俱乐部";
        [Utility styleLbl:nameLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:nameLbl];
        
        //发文时间
        postTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(120, 2, 80, 14)];
        postTimeLbl.text = @"5小时前";
        [Utility styleLbl:postTimeLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:postTimeLbl];
        
        //发文距离
        UIImageView *distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(170, 0, 12, 14)];
        distanceIcon.image = [UIImage imageNamed:@"location.png"];
        distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(185, 2, 70, 13)];
        [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:distanceIcon];
        [topView addSubview:distanceLbl];
        [self.contentView addSubview:topView];
        
        //发文内容
        content = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 250, 60)];
        content.numberOfLines = 0;
        [Utility styleLbl:content withTxtColor:nil withBgColor:nil withFontSize:18];
        [self.contentView addSubview:content];
        
        //附件视图
        mediaView = [[UIView alloc]initWithFrame:CGRectMake(60, 5, 260, 20)];
        mediaView.backgroundColor = COLOR_BROWN;
        [self.contentView addSubview:mediaView];
        //=====
        bottomView = [[UIView alloc]initWithFrame:CGRectMake(60, 60, 32, 12)];
        bottomView.backgroundColor = COLOR_BLUE;
        
        //回复数
        replyIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 12, 12)];
        replyIcon.image = [UIImage imageNamed:@"reply_count.png"];
        replyCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(replyIcon.frame.origin.x+replyIcon.frame.size.width+3, 0, LABEL_WIDTH, 12)];
        [Utility styleLbl:replyCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];

        //收藏数
        collectIcon = [[UIImageView alloc]initWithFrame:CGRectMake(replyCountLbl.frame.origin.x+LABEL_WIDTH, 0, 12, 12)];
        collectIcon.image = [UIImage imageNamed:@"follow_count.png"];
        collectCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(collectIcon.frame.origin.x+collectIcon.frame.size.width+3, 0, LABEL_WIDTH, 12)];
        [Utility styleLbl:collectCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        //浏览数
        browseIcon = [[UIImageView alloc]initWithFrame:CGRectMake(collectCountLbl.frame.origin.x+LABEL_WIDTH, 0, 12, 12)];
        browseIcon.image = [UIImage imageNamed:@"browse_count.png"];
        browseCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(browseIcon.frame.origin.x+browseIcon.frame.size.width+3, 0, LABEL_WIDTH, 12)];
        [Utility styleLbl:browseCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        postClubLbl = [[UILabel alloc]initWithFrame:CGRectMake(150, 0, 40, 14)];
        [Utility styleLbl:postClubLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        postClubBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 0, 40, 14)];
        [postClubBtn setTitle:@"iphone俱乐部" forState:UIControlStateNormal];

        //分享数
        shareIcon = [[UIImageView alloc]initWithFrame:CGRectMake(45, 0, 12, 12)];
        shareIcon.image = [UIImage imageNamed:@"share_count.png"];
        shareCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 40, 12)];
        [Utility styleLbl:shareCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        [bottomView addSubview:browseIcon];
        [bottomView addSubview:replyIcon];
        [bottomView addSubview:collectIcon];
        [bottomView addSubview:replyCountLbl];
        [bottomView addSubview:browseCountLbl];
        [bottomView addSubview:collectCountLbl];
        [bottomView addSubview:postClubLbl];

        
        playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.frame = CGRectMake(10, 5, 20, 20);
        playBtn.tag = 1;
        [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];

        progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(50,0,150, 30)];
        progressSlider.tag = 2;
        progressSlider.minimumValue = 0.0;
        progressSlider.userInteractionEnabled = NO;
        
        currentTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(200, 5, 60, 20)];
        [Utility styleLbl:currentTimeLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        currentTimeLbl.tag = 3;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeState:)
                                                     name:@"AUDIO_CHANGE"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeAudioIMG)
                                                     name:@"AUDIOPLAY_CHANGE"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewLargePhoto:)
                                                     name:@"ViewLargePhoto"
                                                   object:nil];
    }
    videoPlay = [VideoPlayer getSingleton];
    myAudioPlay = [AudioPlay getSingleton];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
    return self;
}

- (id)initForPersonInfo
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"articleViewCell"];
    if (self) {
        //用户头像
        //        avatar = [[UIImageView alloc]init];
        //        avatar.frame = CGRectMake(5, 5, 50, 50);
        //        avatar.layer.masksToBounds = YES;
        //        avatar.layer.cornerRadius = 5;
        //        avatar.userInteractionEnabled = YES;
        //        [self.contentView addSubview:avatar];
        isForPersonInfoPage = YES;
        
        [self.imageView removeFromSuperview];
        [self.detailTextLabel removeFromSuperview];
        [self.textLabel removeFromSuperview];
        self.detailTextLabel.text = @"HAHAHAA";
        
        imgArray = [[NSMutableArray alloc]init];
        photos = [[NSMutableArray alloc] init] ;
        audioLblArray = [[NSMutableArray alloc] init];
        
        //=======
        topView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, 315, 14)];
        topView.backgroundColor = COLOR_GRAY;
        
        //用户名
        nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 100, 14)];
        nameLbl.text = @"音乐俱乐部";
        [Utility styleLbl:nameLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        //        [topView addSubview:nameLbl];
        //发文时间
        postTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(topView.frame.size.width - 150, 2, 80, 14)];
        postTimeLbl.text = @"5小时前";
        [Utility styleLbl:postTimeLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:postTimeLbl];
        
        //发文距离
        UIImageView *distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(postTimeLbl.frame.origin.x + postTimeLbl.frame.size.width, 0, 12, 14)];
        distanceIcon.image = [UIImage imageNamed:@"location.png"];
        distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(distanceIcon.frame.origin.x + distanceIcon.frame.size.width, 2, 70, 13)];
        distanceLbl.text = @"500米";
        [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:distanceIcon];
        [topView addSubview:distanceLbl];
        
        
        [self.contentView addSubview:topView];
        
        //发文内容
        content = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 305, 60)];
        content.text = @"用有组织的乐音来表达人们思想情感、反映现实生活的一种艺术。它最基本的要素是节奏和旋律，分为声乐和器乐两大门类音乐是人类表达爱情，感情，伤感的事情的一种方式";
        content.numberOfLines = 0;
        //原来12
        //        [Utility styleLbl:content withTxtColor:nil withBgColor:nil withFontSize:12];
        [Utility styleLbl:content withTxtColor:nil withBgColor:nil withFontSize:18];
        [self.contentView addSubview:content];
        
        //附件视图
        mediaView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, 260, 20)];
        mediaView.backgroundColor = COLOR_BROWN;
        [self.contentView addSubview:mediaView];
        //=====
        bottomView = [[UIView alloc]initWithFrame:CGRectMake(5, 60, 32, 12)];
        bottomView.backgroundColor = COLOR_BLUE;
        
        //回复数
        replyIcon = [[UIImageView alloc]initWithFrame:CGRectMake(25, 0, 12, 12)];
        replyIcon.image = [UIImage imageNamed:@"reply_count.png"];//15
        replyCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(replyIcon.frame.origin.x + replyIcon.frame.size.width + 3, 0, 40, 12)];
        replyCountLbl.text = @"4";
        [Utility styleLbl:replyCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        //浏览数
        browseIcon = [[UIImageView alloc]initWithFrame:CGRectMake(replyCountLbl.frame.origin.x + replyCountLbl.frame.size.width + 25, 0, 12, 12)];
        browseIcon.image = [UIImage imageNamed:@"browse_count.png"];
        browseCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(browseIcon.frame.origin.x + browseIcon.frame.size.width + 3, 0, 40, 12)];
        browseCountLbl.text = @"8";
        [Utility styleLbl:browseCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        postClubLbl = [[UILabel alloc]initWithFrame:CGRectMake(bottomView.frame.size.width - 70, 0, 70, 14)];
        postClubLbl.text = @"iphone俱乐部";
        [Utility styleLbl:postClubLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        postClubBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 0, 40, 14)];
        [postClubBtn setTitle:@"iphone俱乐部" forState:UIControlStateNormal];
        
        //收藏数
        
        collectIcon = [[UIImageView alloc]initWithFrame:CGRectMake(replyCountLbl.frame.origin.x + replyCountLbl.frame.size.width - 15, 0, 12, 12)];
        collectIcon.image = [UIImage imageNamed:@"follow_count.png"];
        collectCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(collectIcon.frame.origin.x + collectIcon.frame.size.width + 3, 0, 40, 12)];
        collectCountLbl.text = @"5";
        [Utility styleLbl:collectCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        //分享数
        shareIcon = [[UIImageView alloc]initWithFrame:CGRectMake(45, 0, 12, 12)];
        shareIcon.image = [UIImage imageNamed:@"share_count.png"];
        shareCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 40, 12)];
        shareCountLbl.text = @"12";
        [Utility styleLbl:shareCountLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        
        [bottomView addSubview:browseIcon];
        [bottomView addSubview:replyIcon];
        [bottomView addSubview:collectIcon];
        [bottomView addSubview:replyCountLbl];
        [bottomView addSubview:browseCountLbl];
        [bottomView addSubview:collectCountLbl];
        [bottomView addSubview:postClubLbl];
        
        
        playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.frame = CGRectMake(10, 5, 20, 20);
        playBtn.tag = 1;
        [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        
        
        progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(50,0,150, 30)];
        progressSlider.tag = 2;
        progressSlider.minimumValue = 0.0;
        progressSlider.userInteractionEnabled = NO;
        
        currentTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(200, 5, 60, 20)];
        [Utility styleLbl:currentTimeLbl withTxtColor:[UIColor whiteColor] withBgColor:nil withFontSize:12];
        currentTimeLbl.tag = 3;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeState:)
                                                     name:@"AUDIO_CHANGE"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeAudioIMG)
                                                     name:@"AUDIOPLAY_CHANGE"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewLargePhoto:)
                                                     name:@"ViewLargePhoto"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAllAudio)
                                                     name:NOTIFICATION_KEY_AUDIOPLAY_STOPALLARTICLEAUDIO
                                                   object:nil];
    }
    videoPlay = [VideoPlayer getSingleton];
    myAudioPlay = [AudioPlay getSingleton];
    return self;
}

-(void)changeAudioIMG{
    [self initMediaView:cellArticle.media WithStyle:cellArticle.articleStyle];
}

-(void)stopAllAudio{
    if (myAudioPlay.player.isPlaying) {
        if (isDigest) {
            [myAudioPlay playAudiowithType:@"articleAudio_isdigest" withView:nil withFileName:nil withStyle:1];
        }else{
            [myAudioPlay playAudiowithType:@"articleAudio" withView:nil withFileName:nil withStyle:1];
        }
    }
}

-(void)initCellWithArticle:(Article*)article withViewController:(UIViewController *)viewController{
//    [article print];
    cellArticle = article;
    [self prepareImageView];
    nameLbl.text = article.userName;
    postTimeLbl.text = article.postTime;
    distanceLbl.text = article.distance;
    content.text = article.content;
    content.textColor = [UIColor clearColor];
    content.userInteractionEnabled = YES;
    postClubLbl.text = [NSString stringWithFormat:@"发于<%@>",[Utility processClubName:article.articleClubName withWidth:100 withHeight:15 withFontSize:12]
];
    CGSize size = [postClubLbl.text sizeWithFont:[UIFont fontWithName:FONT_NAME_ARIAL size:12] constrainedToSize:CGSizeMake(900, 15) lineBreakMode:UILineBreakModeTailTruncation];
    [postClubBtn setTitle:[NSString stringWithFormat:@"发于%@",article.articleClubName] forState:UIControlStateNormal];
    [postClubBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [postClubBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:12]];
    postClubLbl.frame = CGRectMake(150, 0, 100, 14);
    postClubBtn.frame = CGRectMake(150, 0, size.width, 14);
    if (isForPersonInfoPage) {
        postClubLbl.frame = CGRectMake(200, 0, 100, 14);
        postClubBtn.frame = CGRectMake(200, 0, size.width, 14);
    }
    
    NSString *str = [article.content copy];
    [Utility removeSubViews:content];
    content.backgroundColor = [UIColor grayColor];
    [self attachString:str toView:content];
    vc = viewController;
    
    replyCountLbl.text = [Utility numberSwitch:article.replyCount];
    browseCountLbl.text = [Utility numberSwitch:article.browseCount];
    collectCountLbl.text = [Utility numberSwitch:article.followCount];
    shareCountLbl.text = [Utility numberSwitch:article.shareCount];
    
    [replyView removeFromSuperview];
    [avatar setImageWithURL:USER_HEAD_IMG_URL(@"small", cellArticle.avatarURL) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    [Utility addTapGestureRecognizer:avatar withTarget:self action:@selector(goPersonInfo)];
    if ([cellArticle.replyRowkey length]) {
        if (![cellArticle.replyRowkey isEqualToString:cellArticle.subjectRowKey]) {
            [self addReplyView];
        }
    }
    [self initMediaView:article.media WithStyle:article.articleStyle];
    [iconsView removeFromSuperview];
    if (isDigest) {
        replyCountLbl.hidden = YES;
        browseCountLbl.hidden = YES;
        shareCountLbl.hidden = YES;
        collectCountLbl.hidden = YES;
        replyIcon.hidden = YES;
        browseIcon.hidden = YES;
        shareIcon.hidden = YES;
        collectIcon.hidden = YES;
    }else{
        [self addIcons];
        replyCountLbl.hidden = NO;
        browseCountLbl.hidden = NO;
        shareCountLbl.hidden = NO;
        collectCountLbl.hidden = NO;
        replyIcon.hidden = NO;
        browseIcon.hidden = NO;
        shareIcon.hidden = NO;
        collectIcon.hidden = NO;
    }
//    content.text = @"";
}

-(void)addIcons{
    [iconsView removeFromSuperview];
    int iconCount = 0;
    if (isForPersonInfoPage) {
        iconsView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, 55, 12)];
    }
    else{
        iconsView = [[UIView alloc]initWithFrame:CGRectMake(5, 60, 55, 12)];
    }
    
    if (cellArticle.isOnTop) {
        UIImageView *onTopIcon = [[UIImageView alloc]initWithFrame:CGRectMake(iconCount*15, 0, 12, 12)];
        onTopIcon.image = [UIImage imageNamed:@"onTop.png"];
        [iconsView addSubview:onTopIcon];
        iconCount++;
    }
    
    if (cellArticle.isDigest) {
        UIImageView *digestIcon = [[UIImageView alloc]initWithFrame:CGRectMake(iconCount*15, 0, 12, 12)];
        digestIcon.image = [UIImage imageNamed:@"digest.png"];
        [iconsView addSubview:digestIcon];
    }
    [self.contentView addSubview:iconsView];
    return;
}

-(void)addReplyView{
    [replyView removeFromSuperview];
    if (0 == [cellArticle.articleStyle intValue]) {
        replyView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 200, 100)];
        replyView.backgroundColor = COLOR_RED;
        CGFloat replyContentHeight = [Utility getSizeByContent:[NSString stringWithFormat:@"%@:%@",cellArticle.repliedArticle.userName,cellArticle.repliedArticle.content]withWidth:250 withFontSize:12];
        UILabel *replyContent = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 250, replyContentHeight)];
        replyContent.numberOfLines = 0;
        replyContent.font = [UIFont fontWithName:FONT_NAME_ARIAL size:12];
        replyContent.backgroundColor = COLOR_RED;
        replyContent.text = [NSString stringWithFormat:@"%@:%@",cellArticle.repliedArticle.userName,cellArticle.repliedArticle.content];
        WeLog(@"原文:%@回复的内容:%@",cellArticle.content,cellArticle.repliedArticle.content);
        UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(-2, -6, 260, replyContentHeight+15)];
        if ([cellArticle.media count]) {
            bg.frame = CGRectMake(-2, -6, 260, 30+15);
        }
        bg.backgroundColor = [UIColor blueColor];
        bg.image = [[UIImage imageNamed:@"refrence.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:20];
        //    bg.image = [[UIImage imageNamed:@"refrence.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 58, 3, 0)];
        [replyView addSubview:bg];
        [replyView addSubview:replyContent];
    }
    [self.contentView addSubview:replyView];
}

//
-(void)initComArticleMedia:(NSArray *)mediaArray{
    [Utility removeSubViews:mediaView];
    if ([mediaArray count]) {
        meidaHeight = 30;
    }else{
        meidaHeight = 0;
    }
}

//创建附件视图:包括4种样式
-(void)initMediaView:(NSArray *)mediaArray WithStyle:(NSString *)style{
    [Utility removeSubViews:mediaView];
    [audioLblArray removeAllObjects];
    if (![cellArticle.replyRowkey length] ) {
        //isReplyArticle 为1表示是回复文章,为0不是回复文章
        [self.contentView addSubview:bottomView];
    }
    mediaView.backgroundColor = COLOR_BLUE;
    CGFloat width = 55;
    CGFloat height = 55;
    switch ([style intValue]) {
        case ARTICLE_STYLE_WORDS:
        {
            if ([mediaArray count] == 0) {
                height = 0;
                meidaHeight = 0;
                break;
            }
            width = 55;
            height = 55;
            meidaHeight = 60;
            mediaView.frame = CGRectMake(60, 5, 260, 60);
            for (int i = 0; i < [mediaArray count]; i++) {
                NSString *media = [mediaArray objectAtIndex:i];
                
                UIImageView *mediaImg = [[UIImageView alloc]initWithFrame:CGRectMake(65*i, 0, width, height)];
                mediaImg.layer.borderColor = [[UIColor grayColor]CGColor];
                mediaImg.layer.borderWidth = 0.5;
                mediaImg.userInteractionEnabled = YES;
                mediaImg.tag = i;
                mediaImg.contentMode = UIViewContentModeScaleAspectFit;
                NSString *type = [media substringFromIndex:([media length]-1)];
                
                //附件时间长度
                UILabel *audioLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, mediaImg.frame.size.width,mediaImg.frame.size.height-45)];
                NSString *path = [[NSBundle mainBundle] pathForResource:ATTACHMENT_PIC_HOLDER ofType:@"jpg"];
                [Utility styleLbl:audioLengthLbl withTxtColor:ATTACHTIME_LENGTH_LBL_COLOR withBgColor:nil withFontSize:10];
                audioLengthLbl.textAlignment = NSTextAlignmentCenter;
                if ([cellArticle.mediaInfo isKindOfClass:[NSDictionary class]]) {
                    audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[cellArticle.mediaInfo objectForKey:media] objectForKey:DURATION]];
                    if (![type isEqualToString:TYPE_ATTACH_PICTURE]) {
                        [mediaImg addSubview:audioLengthLbl];
                        [audioLblArray addObject:audioLengthLbl];
                    }
                }
                if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
                    //图片
                    if (isDigest) {
                        [mediaImg setImageWithURL:DigestImageURL(media, TYPE_THUMB) placeholderImage:[UIImage imageWithContentsOfFile:path]];
                    }else{
                        [mediaImg setImageWithURL:ArticleImageURL(media, TYPE_THUMB) placeholderImage:[UIImage imageWithContentsOfFile:path]];
                    }
                    [Utility addTapGestureRecognizer:mediaImg withTarget:self action:@selector(viewDiplayPICS:)];
//                    [mediaImg addDetailShow];
                }else if ([type isEqualToString:TYPE_ATTACH_AUDIO]){
                    //音频
                    [Utility addTapGestureRecognizer:mediaImg withTarget:self action:@selector(audioPlay:)];
                    mediaImg.userInteractionEnabled = YES;
                    WeLog(@"last%@:media%@",myAudioPlay.lastAudioName,media);
                    if ([myAudioPlay.lastAudioName isEqualToString:media]) {
                        if (myAudioPlay.player.isPlaying) {
                            [mediaImg setImage:[UIImage imageNamed:@"audio_pause.png"]];
                        }else{
                            [mediaImg setImage:[UIImage imageNamed:@"yinpin.png"]];
                        }
                    }else{
                        [mediaImg setImage:[UIImage imageNamed:@"yinpin.png"]];
                    }
                }else if([type isEqualToString:TYPE_ATTACH_VIDEO]){
                    //视频
                    audioLengthLbl.backgroundColor = [UIColor blackColor];
                    audioLengthLbl.alpha = 0.7;
                    UITapGestureRecognizer *tapPlayVideo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoPlay:) ];
                    mediaImg.userInteractionEnabled = YES;
                    [mediaImg addGestureRecognizer:tapPlayVideo];
                    if (isDigest) {
                        [mediaImg setImageWithURL:DigestImageURL(media,TYPE_THUMB) placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:VIDEO_PIC_HOLDER ofType:@"png"]]];
                    }else{
                    [mediaImg setImageWithURL:ArticleImageURL(media,TYPE_THUMB) placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:VIDEO_PIC_HOLDER ofType:@"png"]]];
                    }
                    UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:VIDEO_PLAY_ICON]];
                    videoIcon.frame = CGRectMake(17, 20, 20, 20);
                    [mediaImg addSubview:videoIcon];
                }
                [mediaView addSubview:mediaImg];
            }
        }
        break;
        case ARTICLE_STYLE_PIC:
        {
            width = 110;
            height = 110;
            meidaHeight = 110;
            mediaView.frame = CGRectMake(60, 5, 260, 110);
            UIImageView *mediaImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
            mediaImg.backgroundColor = [UIColor whiteColor];
            mediaImg.contentMode = UIViewContentModeScaleAspectFit;
            [mediaImg setImageWithURL:URL([mediaArray objectAtIndex:0]) placeholderImage:[UIImage imageNamed:@"scene.jpg"]];
            [mediaImg addDetailShow];
            [mediaView addSubview:mediaImg];
            mediaView.frame = CGRectMake(60, 5, 260, 110);
            //还要分两种模式:图配音频和图配文
        }
            break;
        case ARTICLE_STYLE_AUDIO:
        {   width = 110;
            height = 110;
            meidaHeight = 30;
            mediaView.frame = CGRectMake(60, 5, 253, 30);
            mediaView.backgroundColor = [UIColor blackColor];
            [mediaView addSubview:playBtn];
            [mediaView addSubview:progressSlider];
            [mediaView addSubview:currentTimeLbl];
            [self initAudioView];
        }
            break;
        case ARTICLE_STYLE_VIDEO:
        {
            width = 110;
            height = 110;
            meidaHeight = 110;
            UIImageView *mediaImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
            mediaImg.backgroundColor = [UIColor whiteColor];
            mediaImg.contentMode = UIViewContentModeScaleAspectFit;
            UITapGestureRecognizer *tapPlay = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoImgPress) ];
            mediaImg.image = [UIImage imageNamed:@"shipin.png"];
            [mediaImg addGestureRecognizer:tapPlay];
            mediaImg.userInteractionEnabled = YES;
            [mediaView addSubview:mediaImg];
            mediaView.frame = CGRectMake(60, 5, 110, 110);
        }
            break;
    }
    [self changeByStyle:style];
}

-(void)audioPlay:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_AUDIOPLAY_STOPALLAUSERINFOAUDIO object:nil];
    
    UITapGestureRecognizer * tap = (UITapGestureRecognizer *)sender;
    if (isDigest) {
        [myAudioPlay playAudiowithType:@"articleAudio_isdigest" withView:tap.view withFileName:[cellArticle.media objectAtIndex:tap.view.tag] withStyle:1];
    }else{
        [myAudioPlay playAudiowithType:@"articleAudio" withView:tap.view withFileName:[cellArticle.media objectAtIndex:tap.view.tag] withStyle:1];
    }
}

//根据style确定并调整位置frame
-(void)changeByStyle:(NSString *)style{
    if (![style intValue]) {
        //文字为主
        int nViewX = 0;     //显示View的起始X值
        int nWidth = 0;     //显示View的宽度
        if (isForPersonInfoPage) {
            nViewX = 10;
            nWidth = 315;
        }
        else{
            nViewX = 60;
            nWidth = 260;
        }
        //文字为主
        topView.frame = CGRectMake(nViewX, 5, nWidth, 20);
        //        CGFloat contentHeight = [Utility getSizeByContent:content.text withWidth:250 withFontSize:18];
        CGFloat contentHeight = [self getMixedViewHeight:content.text];
//        CGFloat contentHeight = [Utility getMixedViewHeight:content.text withWidth:250];
        //      CGFloat contentHeight = [Utility getSizeByContent:content.text withWidth:250 withFontSize:12];
        //        WeLog(@"size height:%f",contentHeight);
        WeLog(@"contentHeight : %f" , contentHeight);
        content.frame = CGRectMake(nViewX, topView.frame.size.height+topView.frame.origin.y, nWidth - 10, contentHeight+5);
        content.backgroundColor = COLOR_RED;
        mediaView.frame = CGRectMake(nViewX, content.frame.size.height+content.frame.origin.y, nWidth, meidaHeight);
        bottomView.frame = CGRectMake(nViewX, mediaView.frame.size.height+mediaView.frame.origin.y,nWidth,17);
        if ([cellArticle.replyRowkey length]) {
            //      CGFloat replyContentHeight = [Utility getSizeByContent:cellArticle.repliedArticle.content withWidth:250 withFontSize:12];
            //      replyView.frame = CGRectMake(60, content.frame.size.height+content.frame.origin.y, 260, replyContentHeight);
            replyView.frame = CGRectMake(nViewX, content.frame.size.height+content.frame.origin.y, nWidth, 30);
        }
    }else{
        //图片/音频/视频为主
        topView.frame = CGRectMake(60, mediaView.frame.size.height+mediaView.frame.origin.y, 260, 20);
        CGFloat contentHeight = [Utility getSizeByContent:content.text withWidth:250 withFontSize:12];
//        WeLog(@"size height:%f",contentHeight);
        [content setFrame:CGRectMake(60, 19, 250, contentHeight)];
        content.frame = CGRectMake(60, topView.frame.size.height+topView.frame.origin.y,260,content.frame.size.height+5);
        bottomView.frame = CGRectMake(60, content.frame.size.height+content.frame.origin.y,260,17);
    }
}

-(void)videoPlay:(id)sender{
    
    if ([vc isKindOfClass:[ClubViewController class]]) {
        ClubViewController * myVC = (ClubViewController *)vc;
        if (myVC.myTable.editing) {
            return;
        }
    }
    UITapGestureRecognizer*gesture = (UITapGestureRecognizer*)sender;
    int indexNum = gesture.view.tag;
    WeLog(@"AudoURL%@",ArticleImageURL([cellArticle.media objectAtIndex:indexNum],TYPE_RAW));
    if (isDigest) {
        [videoPlay playVideoWithURL:[NSString stringWithFormat:@"%@/%@/article/file?name=%@&type=%@&isdigest=1",HOST,PHP,[cellArticle.media objectAtIndex:indexNum],TYPE_RAW] withType:@"articleVideo" view:vc];
    }else{
        [videoPlay playVideoWithURL:[NSString stringWithFormat:@"%@/%@/article/file?name=%@&type=%@",HOST,PHP,[cellArticle.media objectAtIndex:indexNum],TYPE_RAW] withType:@"articleVideo" view:vc];
    }
}

-(void)changeState:(NSNotification *)notification{
    //主要是针对这个还在显示的状态
    //将当前audioplayer存储的playNO的cell的播放信息清空
    if ([[notification.userInfo objectForKey:@"playNO"] intValue] == self.tag) {
        progressSlider.value = 0;
        currentTimeLbl.text = @"";
        [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        playBtn.tag = 0;
    }
}

//先判断articleStyle
-(void)initAudioView{
    currentTimeLbl.text = @"";
    [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    playBtn.tag = 0;
    if ([AudioPlayer getSingleton].playNO == self.tag && [AudioPlayer getSingleton].player.isPlaying) {
        [playBtn setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
        playBtn.tag = 1;//暂停
    }else{
        progressSlider.value = 0;
    }
}

-(void)play{
    if (playBtn.tag) {
        [playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        playBtn.tag = 0;
    }else{
        [playBtn setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
        playBtn.tag = 1;
    }
    [[AudioPlayer getSingleton]play:self.tag];
    progressSlider.maximumValue = [AudioPlayer getSingleton].player.duration;
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.01
                                             target:self
                                           selector:@selector(updateCurrentTime)
                                           userInfo:nil repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)updateCurrentTime{
    if ([AudioPlayer getSingleton].playNO == self.tag) {
        NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)[AudioPlayer getSingleton].player.currentTime / 60, (int)[AudioPlayer getSingleton].player.currentTime % 60, nil];
        NSString *allTime = [NSString stringWithFormat:@"%d:%02d", (int)((int)([AudioPlayer getSingleton].player.duration)) / 60, (int)((int)([AudioPlayer getSingleton].player.duration)) % 60, nil];
        currentTimeLbl.text = [NSString stringWithFormat:@"%@/%@",current,allTime];
        progressSlider.value = [AudioPlayer getSingleton].player.currentTime;
    }
}


//查看图片:这是以前有小图的时候查看大图的方式
-(void)viewLargePhoto:(NSNotification *)notification{
    WeLog(@"已跳开始查看图片的页面");
    int articleNO = [[notification.userInfo objectForKey:@"articleNO"] intValue];
    int mediaNO = [[notification.userInfo objectForKey:@"mediaNO"] intValue];
    if (notification.object != self) {
        return;
    }
    //通过object判断就行，没有必要用mediaNO判断因为tag有可能相同，cell
    if (articleNO == self.tag) {
        ViewImage *myViewImg = [[ViewImage alloc]init];
        NSURL *url;
        if (isDigest) {
            url = DigestImageURL([cellArticle.media objectAtIndex:mediaNO], TYPE_RAW);
        }else{
            url = ArticleImageURL([cellArticle.media objectAtIndex:mediaNO], TYPE_RAW);
        }
        UINavigationController *nav = [myViewImg viewLargePhoto:[NSArray arrayWithObjects:url, nil]];
        [vc presentModalViewController:nav animated:YES];
        WeLog(@"已跳到查看图片的页面");
    }
}

-(void)prepareImageView{
    [imgArray removeAllObjects];
    for (NSString *st in cellArticle.media) {
        NSString *displayType = [st substringFromIndex:([st length]-1)];
        if ([displayType isEqualToString:TYPE_ATTACH_PICTURE]) {
            [imgArray addObject:ArticleImageURL(st, TYPE_RAW)];
        }
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

-(void)viewDiplayPICS:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSURL *url;
    [photos removeAllObjects];
    for (int i = 0; i < [imgArray count]; i++) {
        if (photos) {
            [photos addObject:[MWPhoto photoWithURL:[imgArray objectAtIndex:i]]];
        }
    }
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    nav.navigationBar.translucent = NO;

    if (isDigest) {
        url = DigestImageURL([cellArticle.media objectAtIndex:tap.view.tag], TYPE_RAW);
    }else{
        url = ArticleImageURL([cellArticle.media objectAtIndex:tap.view.tag], TYPE_RAW);
    }
    [mwBrowser setInitialPageIndex:[imgArray indexOfObject:url]];
    [vc presentModalViewController:nav animated:YES];
}

-(void)viewPhoto:(id)sender{
    if ([vc isKindOfClass:[ClubViewController class]]) {
        ClubViewController * myVC = (ClubViewController *)vc;
        if (myVC.myTable.editing) {
            return;
        }
    }

    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    ViewImage *myViewImg = [[ViewImage alloc]init];
    NSURL *url;
    if (isDigest) {
        url = DigestImageURL([cellArticle.media objectAtIndex:tap.view.tag], TYPE_RAW);
    }else{
        url = ArticleImageURL([cellArticle.media objectAtIndex:tap.view.tag], TYPE_RAW);
    }
    
    UINavigationController *nav = [myViewImg viewLargePhoto:[NSArray arrayWithObjects:url, nil]];
    [vc presentModalViewController:nav animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    for (UIView *view in audioLblArray) {
//        view.backgroundColor = [UIColor clearColor];
    }
    
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
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(250, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    [self heightAttachString:str toView:view];
    return view.frame.size.height;
}

- (void)selectLabel:(id)sender
{
    //    WeLog(@"选择######");
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    WeLog(@"%@",str);
    TopicArticleListViewController *topicArticleListView = [[TopicArticleListViewController alloc]initWithTopic:[str substringWithRange:NSMakeRange(1, [str length]-2)] withType:@"0"];
    topicArticleListView.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:topicArticleListView animated:YES];   
}

- (void)selectName:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    WeLog(@"%@",str);
    NSString *s = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:[s substringFromIndex:1]];
    personInfoView.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:personInfoView animated:YES];
}

- (void)selectLinker:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
//    WebViewController *webView = [[WebViewController alloc]initWithURLStr:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
//    [vc.navigationController pushViewController:webView animated:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
}

//跳到个人信息页
-(void)goPersonInfo{
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:cellArticle.userName];
    personInfoView.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:personInfoView animated:YES];
}

//-(void)videoImgPress:(id)sender{
//    UITapGestureRecognizer * tap = (UITapGestureRecognizer *)sender;
//    int attachIndexNum = tap.view.tag;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"MEDIA_PLAY" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.tag],@"articleIndexNum",@"video",@"mediaType",[NSString stringWithFormat:@"%d",attachIndexNum],@"attachIndexNum", nil]];
//    //    [[VideoPlayer getSingleton] play];
//    
//}
//
//-(void)audioImgPress:(id)sender{
//    UITapGestureRecognizer * tap = (UITapGestureRecognizer *)sender;
//    int attachIndexNum = tap.view.tag;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"MEDIA_PLAY" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.tag],@"articleIndexNum",@"audio",@"mediaType",[NSString stringWithFormat:@"%d",attachIndexNum],@"attachIndexNum", nil]];
//}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copyContent));
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)longPress:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        ArticleCell *view = (ArticleCell *)recognizer.view;
        [view becomeFirstResponder];
        UIMenuItem *copyMneu = [[UIMenuItem alloc]initWithTitle:@"拷贝文章内容" action:@selector(copyContent)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:copyMneu, nil]];
        [menu setTargetRect:view.frame inView:view.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

-(void)copyContent{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];//黏贴板
    pasteBoard.string = cellArticle.content;
    [Utility showHUD:@"复制成功"];
}
@end
