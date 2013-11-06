//
//  PostArticleViewController.m
//  WeClub
//
//  Created by chao_mit on 13-1-29.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "PostArticleViewController.h"
#import "amrFileCodec.h"
#import "DAKeyboardControl.h"
@interface PostArticleViewController ()

@end
@implementation PostArticleViewController
@synthesize atBodyBtn,topicBtn, emotionBtn, locationBtn, picPickBtn, musicBtn, videoBtn,club;
-(void)dealloc{

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [audioPlay stop];
    [rp cancel];
}

-(void)viewWillAppear:(BOOL)animated{
//    [myTV becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated{
    [myTV becomeFirstResponder];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    shouldResume = NO;
    myAccountUser = [AccountUser getSingleton];
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    
    audioPlay = [AudioPlay getSingleton];
    videoPlay = [VideoPlayer getSingleton];

    topView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 140)];
    topView.layer.borderColor = [[UIColor blackColor]CGColor];
    topView.layer.borderWidth = 1.0;
    [self.view addSubview:topView];
    //文本输入框
    myTV = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(0, 0, 300, topView.frame.size.height - 20)];
    myTV.delegate = self;
    myTV.placeholder = @"请输入......";
    [topView addSubview:myTV];
    //文本清空按钮
    clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    WeLog(@"height%f",myTV.frame.size.height);
    clearBtn.frame = CGRectMake(myTV.frame.size.width-20, myTV.frame.size.height-20, 20, 20);
    [clearBtn setImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearBtnSelected) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:clearBtn];
    
    //剩余字数标签
    leftWordCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(myTV.frame.size.width-60, myTV.frame.size.height-20, 40, 20)];
    leftWordCountLbl.text = @"140";
    [topView addSubview:leftWordCountLbl];

    //表情
    faceBoard = [[FaceBoard alloc]initWithIsShowSendButton:NO];
    faceBoard.frame = CGRectMake(0, myConstants.screenHeight-216-20-44, 320, 256);
    faceBoard.hidden = YES;
    [self.view addSubview:faceBoard];
    //locationLbl位置信息
    locationIcon = [[UIImageView  alloc]initWithFrame:CGRectMake(0, myTV.frame.size.height, 10, 18)];
//    locationIcon.image = [UIImage imageNamed:@"location.png"];
    locationIcon.hidden = YES;
    [topView addSubview:locationIcon];
    
    locationLbl = [[UILabel alloc]initWithFrame:CGRectMake(20, myTV.frame.size.height, 240, 20)];
    locationLbl.backgroundColor = [UIColor clearColor];
    [topView addSubview:locationLbl];
    
    //发文按钮
    [atBodyBtn addTarget:self action:@selector(showPostList:) forControlEvents:UIControlEventTouchUpInside];
    [atBodyBtn setImage:[UIImage imageNamed:@"at.png"] forState:UIControlStateNormal];
    atBodyBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    UILabel *atBodyLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 40, 12)];
    atBodyLbl.textAlignment = UITextAlignmentCenter;
    atBodyLbl.text = @"提到他";
    [Utility styleLbl:atBodyLbl withTxtColor:nil withBgColor:nil withFontSize:10];
    [atBodyBtn addSubview:atBodyLbl];
    atBodyBtn.tag = 0;
    
    //话题按钮
    [topicBtn addTarget:self action:@selector(showPostList:) forControlEvents:UIControlEventTouchUpInside];
    [topicBtn setImage:[UIImage imageNamed:@"topic.png"] forState:UIControlStateNormal];
    topicBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    UILabel *topicLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 40, 12)];
    topicLbl.textAlignment = UITextAlignmentCenter;
    topicLbl.text = @"话题";
    [Utility styleLbl:topicLbl withTxtColor:nil withBgColor:nil withFontSize:10];
    [topicBtn addSubview:topicLbl];
    topicBtn.tag = 1;
    
    //位置信息按钮
    [locationBtn addTarget:self action:@selector(shortURL) forControlEvents:UIControlEventTouchUpInside];
    [locationBtn setImage:[UIImage imageNamed:@"shortURL.png"] forState:UIControlStateNormal];
    locationBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    UILabel *locateLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 40, 12)];
    locateLbl.textAlignment = UITextAlignmentCenter;
    locateLbl.text = @"短链接";
    [Utility styleLbl:locateLbl withTxtColor:nil withBgColor:nil withFontSize:10];
    [locationBtn addSubview:locateLbl];
    
    //表情按钮
    [emotionBtn addTarget:self action:@selector(emotion) forControlEvents:UIControlEventTouchUpInside];
    [emotionBtn setImage:[UIImage imageNamed:@"emotion.png"] forState:UIControlStateNormal];
    emotionBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    emotionLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 40, 12)];
    emotionLbl.textAlignment = UITextAlignmentCenter;
    emotionLbl.text = @"表情";
    [Utility styleLbl:emotionLbl withTxtColor:nil withBgColor:nil withFontSize:10];
    [emotionBtn addSubview:emotionLbl];
    
    //图片按钮
    [picPickBtn addTarget:self action:@selector(addMedia:) forControlEvents:UIControlEventTouchUpInside];
    [picPickBtn setImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
    picPickBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    picPickBtn.tag = 1;
    UILabel *picPickLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 40, 12)];
    picPickLbl.textAlignment = UITextAlignmentCenter;
    picPickLbl.text = @"图片";
    [Utility styleLbl:picPickLbl withTxtColor:nil withBgColor:nil withFontSize:10];
    [picPickBtn addSubview:picPickLbl];
    
    mediaCount = 0;
    //音频按钮
    [musicBtn addTarget:self action:@selector(addMedia:) forControlEvents:UIControlEventTouchUpInside];
    [musicBtn setImage:[UIImage imageNamed:@"audio.png"] forState:UIControlStateNormal];
    musicBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    UILabel *musicLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 40, 12)];
    musicLbl.textAlignment = UITextAlignmentCenter;
    musicLbl.text = @"录音";
    [Utility styleLbl:musicLbl withTxtColor:nil withBgColor:nil withFontSize:10];
    [musicBtn addSubview:musicLbl];
    musicBtn.tag = 2;
    
    //视频按钮
    [videoBtn addTarget:self action:@selector(addMedia:) forControlEvents:UIControlEventTouchUpInside];
    [videoBtn setImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];
    videoBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 15, 10);
    UILabel *videoLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, 40, 12)];
    videoLbl.textAlignment = UITextAlignmentCenter;
    videoLbl.text = @"视频";
    [Utility styleLbl:videoLbl withTxtColor:nil withBgColor:nil withFontSize:10];
    [videoBtn addSubview:videoLbl];
    videoBtn.tag = 3;
    
    buttonsView = [[UIView alloc]initWithFrame:CGRectMake(2, 200, 320, 40)];
    [buttonsView addSubview:atBodyBtn];
    [buttonsView addSubview:topicBtn];
    [buttonsView addSubview:locationBtn];
    [buttonsView addSubview:emotionBtn];
    [buttonsView addSubview:picPickBtn];
    [buttonsView addSubview:musicBtn];
    [buttonsView addSubview:videoBtn];
    [self.view addSubview:buttonsView];
    
    //导航栏titleView
    UIView *title = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 140, 44)];
    UIButton *titleView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView addTarget:self action:@selector(showTitleViews) forControlEvents:UIControlEventTouchUpInside];
    titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 120, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = @"发文章";
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    CGSize titleLabelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, titleLabelsize.width, 44);
    titleViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"x.png"]];
    titleViewArrow.frame = CGRectMake(titleLabelsize.width, 13, 20, 20);
    [titleView addSubview:titleLbl];
    [titleView addSubview:titleViewArrow];
    [title addSubview:titleView];
    self.navigationItem.titleView = titleLbl;
    
    titleViews = [[UIView alloc]initWithFrame:CGRectMake(90, 60, 140, 160)];
    titleViews.backgroundColor = TINT_COLOR;
    holeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight)];
    
    for (int i = 0; i < [myConstants.postStyleNames count]; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 40*i, 140, 40);
        btn.tag = i;
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitle:[myConstants.postStyleNames  objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventTouchUpInside];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 40*(i+1), 140, 1)];
        line.backgroundColor = [UIColor blackColor];
        [titleViews addSubview:line];
        [titleViews addSubview:btn];
    }
    
    holeView.backgroundColor = [UIColor clearColor];
    [holeView addSubview:titleViews];
    [self.navigationController.view addSubview:holeView];
//    [self.tabBarController.view addSubview:holeView];
    holeView.hidden = YES;
    
    WeLog(@"%@%@",self.presentingViewController,self.presentedViewController);

    [self keyBoardChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTitleViews)
                                                 name:@"HIDE_TITLEVIEWS" object:nil];
    //在view被销毁的情况下[self.view removeKeyboardControl];
//    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
//    [ notificationCenter addObserver:self selector:@selector(done) name:MPMoviePlayerPlaybackDidFinishNotification object:nil ];
    [myTV becomeFirstResponder];
    postStyle = 0;
    mediaArray = [[NSMutableArray alloc]init];
    mediaPicArray = [[NSMutableArray alloc]init];
    locationInfo = @"0.01,0.01";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTextViewCountLbl)
                                                 name:@"FACEBOARD_NOTIFICATION" object:nil];
}

#pragma mark -
#pragma mark  切换发文方式
- (void)changeList:(id)sender{
    UIButton *btn = (UIButton *)sender;
    postStyle = btn.tag;
    titleLbl.text = [myConstants.postStyleNames objectAtIndex:btn.tag];
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, 44);
    titleViewArrow.frame = CGRectMake(labelsize.width, 13, 20, 20);
    [self hideTitleViews];
    
    switch (btn.tag) {
        case 0:
            break;
        case 1:
        case 2:
        case 3:
            [self addMedia:sender];
            break;
        default:
            break;
    }
//    [self refresh];
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
}

#pragma mark -
#pragma mark  处理由键盘尺寸变化引起的控件布局变化
- (void)keyBoardChange{
    self.view.keyboardTriggerOffset = buttonsView.bounds.size.height;
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
        CGRect buttonsViewFrame = buttonsView.frame;
        buttonsViewFrame.origin.y = keyboardFrameInView.origin.y - buttonsViewFrame.size.height;
        buttonsView.frame = buttonsViewFrame;
        
        CGRect myTVFrame = topView.frame;
        myTVFrame.size.height = buttonsViewFrame.origin.y-15;
        topView.frame = myTVFrame;
        myTV.frame = CGRectMake(0, 0, 300, topView.frame.size.height-20);
        clearBtn.frame = CGRectMake(topView.frame.size.width-22, topView.frame.size.height-22, 20, 20);
        leftWordCountLbl.frame = CGRectMake(topView.frame.size.width-22-40, topView.frame.size.height-22, 40, 20);
        locationLbl.frame = CGRectMake(20, topView.frame.size.height-22, 240, 20);
        locationIcon.frame = CGRectMake(0, myTV.frame.size.height, 18, 18);
        
        if (mediaView) {
            CGRect mediaViewFrame = mediaView.frame;
            mediaViewFrame.origin.y = buttonsViewFrame.origin.y-60-5;
            mediaView.frame = mediaViewFrame;
            
            CGRect myTVFrame = topView.frame;
            myTVFrame.size.height = buttonsViewFrame.origin.y-15-60-5;
            topView.frame = myTVFrame;
            
            myTV.frame = CGRectMake(0, 0, 300, topView.frame.size.height-20);
            clearBtn.frame = CGRectMake(topView.frame.size.width-22, topView.frame.size.height-22, 20, 20);
            leftWordCountLbl.frame = CGRectMake(topView.frame.size.width-22-40, topView.frame.size.height-22, 40, 20);

            locationLbl.frame = CGRectMake(20, topView.frame.size.height-22, 240, 20);
            locationIcon.frame = CGRectMake(0, topView.frame.size.height-22, 18, 18);
            
        }
    }];
}

-(void)changeForEmotion{
    CGRect keyboardFrameInView;
    if (iPhone5) {
        keyboardFrameInView = CGRectMake(0, 288, 320, 216);
    }else{
        keyboardFrameInView = CGRectMake(0, 200, 320, 216);
    }
    
    CGRect buttonsViewFrame = buttonsView.frame;
    buttonsViewFrame.origin.y = keyboardFrameInView.origin.y - buttonsViewFrame.size.height;
    buttonsView.frame = buttonsViewFrame;
    
    CGRect myTVFrame = topView.frame;
    myTVFrame.size.height = buttonsViewFrame.origin.y-15;
    topView.frame = myTVFrame;
    myTV.frame = CGRectMake(0, 0, 300, topView.frame.size.height-20);
    clearBtn.frame = CGRectMake(topView.frame.size.width-22, topView.frame.size.height-22, 20, 20);
    leftWordCountLbl.frame = CGRectMake(topView.frame.size.width-22-40, topView.frame.size.height-22, 40, 20);
    locationLbl.frame = CGRectMake(20, topView.frame.size.height-22, 240, 20);
    locationIcon.frame = CGRectMake(0, myTV.frame.size.height, 18, 18);
    
    
    if (mediaView) {
        CGRect mediaViewFrame = mediaView.frame;
        mediaViewFrame.origin.y = buttonsViewFrame.origin.y-60-5;
        mediaView.frame = mediaViewFrame;
        
        CGRect myTVFrame = topView.frame;
        myTVFrame.size.height = buttonsViewFrame.origin.y-15-60-5;
        topView.frame = myTVFrame;
        
        myTV.frame = CGRectMake(0, 0, 300, topView.frame.size.height-20);
        clearBtn.frame = CGRectMake(topView.frame.size.width-22, topView.frame.size.height-22, 20, 20);
        leftWordCountLbl.frame = CGRectMake(topView.frame.size.width-22-40, topView.frame.size.height-22, 40, 20);
        
        locationLbl.frame = CGRectMake(20, topView.frame.size.height-22, 240, 20);
        locationIcon.frame = CGRectMake(0, topView.frame.size.height-22, 18, 18);
    }
}

//添加附件
- (void)addMedia:(id)sender{
    if (mediaCount == 4) {
        [Utility MsgBox:@"已达到最大附件个数！"];
        return;
    }
    [self.view removeKeyboardControl];
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 0:
            break;
        case 1:
            [self takePhoto:nil];
            break;
        case 2:
            [self audioRecordStart];
            break;
        case 3:
            [self videoRecord];
            break;
    }
    [self keyBoardChange];//影响尺寸布局的获取图片／录制音频／录制视频才会放在addMedia中
}

#pragma mark -
#pragma mark  添加附件后的尺寸改变(增加了mediaview)
//添加附件后的
-(void)changViewFrame{
    if (!mediaView) {
        int value;
        if (iPhone5) {
            value = 0;
        }else{
            value = 88;
        }
//        mediaView = [[UIView alloc]initWithFrame:CGRectMake(10, 185-value, 300, 60)];
//        buttonsView.frame = CGRectMake(2, 248-value, 320, 40);
        
        mediaView = [[UIView alloc]initWithFrame:CGRectMake(10, 185-value, 300, 60)];
//        buttonsView.frame = CGRectMake(2, 248-value, 320, 40);
        [self.view addSubview:mediaView];
    }
}

#pragma mark -
#pragma mark  提到某人和话题 @ 和 #
-(void)showPostList:(id)sender{
    UIButton *btn = (UIButton*)sender;
    if (!postListView) {
        postListView = [[PostListViewController alloc]init];
    }
    postListView.listType = btn.tag;
    postListView.refreshDel = self;
    if (!nav) {
        nav = [[UINavigationController alloc]initWithRootViewController:postListView];
        nav.navigationBar.tintColor = TINT_COLOR;
    }
    [self presentModalViewController:nav animated:YES];
}

-(void)refresh:(NSDictionary *)dic{
    WeLog(@"%@",postListView.selectedString);
    NSMutableString *s = [NSMutableString stringWithString:myTV.text];
    if (postListView.listType) {
        [s appendString:postListView.selectedString];
    }else{
        [s appendFormat:@"@%@ ",postListView.selectedString];
    }
    myTV.text = s;
    [self textViewDidChange:myTV];
}

#pragma mark -
#pragma mark  表情
//专门为表情定制的frame方法
-(void)emotion{
    static BOOL on = NO;
    faceBoard.inputTextView = myTV;
    if (!emotionBtn.tag) {
        [emotionBtn setImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
        emotionBtn.tag = 1;
        emotionLbl.text = @"键盘";
        faceBoard.hidden = NO;
        faceBoard.count = [myTV.text length]-myTV.selectedRange.location;
        [self.view removeKeyboardControl];
        [self changeForEmotion];
        [myTV resignFirstResponder];
//        myTV.inputView = faceBoard;
//        [myTV becomeFirstResponder];
         [self keyBoardChange];
    }else{
        [emotionBtn setImage:[UIImage imageNamed:@"emotion.png"] forState:UIControlStateNormal];
        emotionLbl.text = @"表情";
        emotionBtn.tag = 0;
        faceBoard.inputTextView = nil;
        myTV.inputView = nil;
        [myTV resignFirstResponder];
        [myTV becomeFirstResponder];
        faceBoard.hidden = YES;
    }
    on = !on;
}

-(void)hideEmotion{
    if (faceBoard.hidden == NO) {
        faceBoard.inputTextView = nil;
        myTV.inputView = nil;
        [myTV resignFirstResponder];
        [myTV becomeFirstResponder];
        faceBoard.hidden = YES;
    }
}

#pragma mark -
#pragma mark  短链接
-(void)shortURL{
    [myTV becomeFirstResponder];
    [myTV resignFirstResponder];
    [self.view removeKeyboardControl];
    UIAlertView *linkAlert = [Utility MsgBox:@"请输入链接地址" AndTitle:@"短链接" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:2];
    linkAlert.tag = 2;
}

#pragma mark -
#pragma mark  拍照或获取图片
-(void) takePhoto:(id)sender{
    DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark -
#pragma mark  录制视频
- (void) videoRecord
{
    if (!imagePickerController) {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
    }
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraFlashMode = 0;
        imagePickerController.videoMaximumDuration = 15.0;//长度限制30s
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
        imagePickerController.showsCameraControls = YES;
        [self presentModalViewController:imagePickerController animated:YES];
	}
    return;
}

#pragma mark -imagePickerController
-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    WeLog(@"mediaType:%@",mediaType);
    if ([mediaType isEqualToString:@"public.movie"]){
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        WeLog(@"url:%@",url.path);
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(mediaCount*80, 0, 60, 60)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.layer.borderColor = [[UIColor grayColor]CGColor];
        imgView.layer.borderWidth = 1.0;
        imgView.image = [Utility getImage:url.path];
        imgView.tag = mediaCount;

        UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:VIDEO_PLAY_ICON]];
        videoIcon.frame = CGRectMake(20,20,20,20);
        [imgView addSubview:videoIcon];
        UILabel *mediaLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, imgView.frame.size.width,imgView.frame.size.height-45)];
        mediaLengthLbl.textAlignment = NSTextAlignmentCenter;
        [Utility styleLbl:mediaLengthLbl withTxtColor:ATTACHTIME_LENGTH_LBL_COLOR withBgColor:nil withFontSize:10];
        mediaLengthLbl.backgroundColor = [UIColor blackColor];
        mediaLengthLbl.alpha = 0.7;
        NSURL *sourceMovieURL = [NSURL fileURLWithPath:url.path];
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
        CMTime duration = sourceAsset.duration;
        mediaLengthLbl.text = [NSString stringWithFormat:@"%d''",(int)round(CMTimeGetSeconds(duration))];
        WeLog(@"HAHAHA%d",(int)round(CMTimeGetSeconds(duration)));
        [imgView addSubview:mediaLengthLbl];

        //保存路径
//        NSDate *now = [NSDate date];
//        NSString *fileName = [NSString stringWithFormat:@"%f.mp4",[now timeIntervalSince1970]];
//        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentDir = [arr objectAtIndex:0];
//        videoPath = [documentDir stringByAppendingPathComponent:fileName];
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [arr objectAtIndex:0];
        NSString * mp4Path = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.MOV",[[NSDate date] timeIntervalSince1970]]];

//        videoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image.png"];
//        [mp4Path retain];
        [mediaArray addObject:mp4Path];

        WeLog(@"filePath:%@",videoPath);
        UISaveVideoAtPathToSavedPhotosAlbum([url path], self, nil, NULL);
        [self refreshMediaView];

        //mov转成mp4格式
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetExportSession *aSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetPassthrough];
        aSession.outputURL = [NSURL fileURLWithPath:mp4Path];//保存视频到filePath下,真正保存到该路径下还是在下边异步执行中。
        aSession.shouldOptimizeForNetworkUse = YES;
        aSession.outputFileType = AVFileTypeMPEG4;
        [self changViewFrame];
        [mediaView addSubview:imgView];
        [self addDeleteIcon:mediaCount];
        imagePickerController.cameraFlashMode = -1;

        [SVProgressHUD showWithStatus:@"正在压缩视频..." maskType:SVProgressHUDMaskTypeClear];
        mediaCount++;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewVIDEO:)];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:tapGestureRecognizer];
        
        [aSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([aSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    WeLog(@"failed...");
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"transcoding failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                    [SVProgressHUD dismiss];
                    WeLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    [SVProgressHUD dismiss];

                    WeLog(@"Successful!");
//                    [mediaArray addObject:videoPath];
                    break;
                }
                default:
                    break;
            }
        }];
        
        
    }
    else
	{
        UIImage *image = [UIImage imageWithData:[info objectForKey:@"data"]];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(mediaCount*80, 0, 60, 60)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.layer.borderColor = [[UIColor grayColor]CGColor];
        imgView.layer.borderWidth = 1.0;
        imgView.image = image;
        [self changViewFrame];
        [mediaView addSubview:imgView];
        [self addDeleteIcon:mediaCount];

        mediaCount++;
        NSData *data = UIImageJPEGRepresentation(image, 0.05);
//      [data writeToFile:savedImagePath atomically:NO];
        [mediaPicArray addObject:data];
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [arr objectAtIndex:0];
        NSString * imagePath = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%f_p",[[NSDate date] timeIntervalSince1970]]];
        data = UIImageJPEGRepresentation(image, 0.05);
        [data writeToFile:imagePath atomically:YES];
        [mediaArray addObject:imagePath];
        
        WeLog(@"info.allKeys%@",info.allKeys);
        [self refreshMediaView];
        if (info) {
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library writeImageDataToSavedPhotosAlbum:[info objectForKey:@"data"] metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
//             {
//                 if (error) {
//                     WeLog(@"ERROR: the image failed to be written");
//                 }
//                 else {
//                     WeLog(@"PHOTO SAVED - assetURL: %@", assetURL);
//                 }
//             }];
        }
    }
    [self dismissModalViewControllerAnimated:YES];
    [imagePickerController removeFromParentViewController];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark  添加删除按钮
-(void)addDeleteIcon:(int)num{
    UIButton* deleteIcon = [[UIButton alloc]init];
    [deleteIcon setImage:[UIImage imageNamed:@"deleteIcon.png"] forState:UIControlStateNormal];
    [deleteIcon addTarget:self action:@selector(deleteMedia:) forControlEvents:UIControlEventTouchUpInside];
    deleteIcon.tag = num;
    deleteIcon.frame = CGRectMake(80*num+44, -8, 30, 30);
    [mediaView addSubview:deleteIcon];
}

#pragma mark - MWPhotoBrowserDelegate查看图片大图
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return viewPicURL;
}

#pragma mark -
#pragma mark  预览图片 预览声音 预览视频
-(void)previewPIC:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
//    ViewImage *myViewImg = [[ViewImage alloc]init];
    NSURL *url = [[NSURL alloc]initFileURLWithPath:[mediaArray objectAtIndex:tap.view.tag]];
    viewPicURL = [MWPhoto photoWithURL:url];
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    UINavigationController *mwNav = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    mwNav.navigationBar.translucent = NO;
    
    [mwBrowser setInitialPageIndex:0];
    [self presentModalViewController:mwNav animated:YES];
}

-(void)previewAUDIO:(id)sender{
    UIButton *btn = (UIButton*)sender;
    [audioPlay playAudiowithType:@"localAudio" withView:btn withFileName:[mediaArray objectAtIndex:btn.tag] withStyle:0];
}

-(void)previewVIDEO:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    WeLog(@"postArticleVideo:%d,%@",tap.view.tag,[mediaArray objectAtIndex:tap.view.tag]);
    [videoPlay playVideoWithURL:[mediaArray objectAtIndex:tap.view.tag] withType:@"localVideo" view:self];
}

#pragma mark -
#pragma mark  刷新附件窗口
-(void)refreshMediaView{
    [Utility removeSubViews:mediaView];
    if (!mediaCount) {
        [mediaView removeFromSuperview];
        mediaView = nil;
    }else{
    
    }
    
    for (int i = 0; i < [mediaArray count];i++) {
        NSString *path = [mediaArray objectAtIndex:i];
        WeLog(@"i:%drefreshMediaViewPath%@",i,path);
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i*80, 0, 60, 60)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.layer.borderColor = [[UIColor grayColor]CGColor];
        imgView.layer.borderWidth = 1.0;
        imgView.tag = i;
        imgView.userInteractionEnabled = YES;
        [mediaView addSubview:imgView];
        UILabel *mediaLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, imgView.frame.size.width,imgView.frame.size.height-45)];

        [Utility styleLbl:mediaLengthLbl withTxtColor:ATTACHTIME_LENGTH_LBL_COLOR withBgColor:nil withFontSize:10];
        mediaLengthLbl.textColor = ATTACHTIME_LENGTH_LBL_COLOR;
        mediaLengthLbl.textAlignment = NSTextAlignmentCenter;
        NSString *type = [path substringFromIndex:([path length]-1)];
        if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
            imgView.image = [UIImage imageWithContentsOfFile:path];
            [Utility addTapGestureRecognizer:imgView withTarget:self action:@selector(previewPIC:)];
        }else if ([type isEqualToString:TYPE_ATTACH_AUDIO]){
            UIButton *audioBtn = [[UIButton alloc]initWithFrame:CGRectMake(i*80, 0, 60, 60)];
            [audioBtn setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
            [audioBtn addTarget:self action:@selector(previewAUDIO:) forControlEvents:UIControlEventTouchUpInside];
            audioBtn.layer.borderColor = [[UIColor grayColor]CGColor];
            audioBtn.layer.borderWidth = 1.0;
            audioBtn.tag = i;

            NSURL *newurl = [[NSURL alloc]initFileURLWithPath:path];
            AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:newurl error:nil];
            mediaLengthLbl.text = [NSString stringWithFormat:@"%d''",(int)round(player.duration)];
            [audioBtn addSubview:mediaLengthLbl];
            [mediaView addSubview:audioBtn];
        }else if ([type isEqualToString:@"V"]){
            mediaLengthLbl.backgroundColor = [UIColor blackColor];
            mediaLengthLbl.alpha = 0.7;
            NSURL *sourceMovieURL = [NSURL fileURLWithPath:path];
            AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
            CMTime duration = sourceAsset.duration;
            mediaLengthLbl.text = [NSString stringWithFormat:@"%d''",(int)round(CMTimeGetSeconds(duration))];
            WeLog(@"HAHAHA%d",(int)round(CMTimeGetSeconds(duration)));
            [imgView addSubview:mediaLengthLbl];
            WeLog(@"videoPaht:%@",path);
            imgView.image = [Utility getImage:path];
            UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:VIDEO_PLAY_ICON]];
            videoIcon.frame = CGRectMake(20, 20, 20, 20);
            [imgView addSubview:videoIcon];
            [Utility addTapGestureRecognizer:imgView withTarget:self action:@selector(previewVIDEO:)];
        }
        [self addDeleteIcon:i];
    }
}

#pragma mark -
#pragma mark  删除附件窗口
-(void)deleteMedia:(id)sender{
    [audioPlay stop];
    UIButton *btn = (UIButton *)sender;
    WeLog(@"btn.tag:%d",btn.tag);
    [mediaArray removeObjectAtIndex:btn.tag];
    mediaCount--;
    WeLog(@"mediaCountAfterDelete%d",[mediaArray count]);
    [self refreshMediaView];
    if (!mediaCount) {
        [myTV resignFirstResponder];
        [myTV becomeFirstResponder];
    }
}

//录音倒计时
-(void)updateRecordTime{
    audioRecordAlert.message = [NSString stringWithFormat:@"正在录音...%ds",(int)round(recorder.currentTime)];
    WeLog(@"recorderTime:%d,%f",(int)round(recorder.currentTime),recorder.currentTime);
    if (recorder.currentTime - 30 > 0.1 ) {
        audioRecordAlert.message = @"录音时间达到最大限制!";
        WeLog(@"recorderTime:%f",recorder.currentTime);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [t invalidate];
            [recorder pause];
        });
    }
}

#pragma mark -
#pragma mark  录制音频
- (void)audioRecordStart{
    [[AudioPlay getSingleton]stop];
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {
        shouldResume = YES;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    audioRecordAlert = [[UIAlertView alloc] initWithTitle:@"录音" message:@"正在录音..." delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"完成", nil];
    audioRecordAlert.tag = 1;
    [t invalidate];
    t = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
    [audioRecordAlert show];
    NSString *fileName = [NSString stringWithFormat:@"%d.caf",mediaCount];
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
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;

    [recorder prepareToRecord];
//    [recorder performSelector:@selector(record) withObject:nil afterDelay:0.1];
    [recorder record];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (shouldResume) {
        [[MPMusicPlayerController iPodMusicPlayer]play];
        shouldResume = NO;
    }
    
    WeLog(@"audioRecorderDidFinishRecording...");
//    NSString *fileName = @"testrecord.caf";
    NSString *fileName = [NSString stringWithFormat:@"%d.caf",mediaCount];
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    WeLog(@"filePath:%@",filePath);
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [arr objectAtIndex:0];
    NSString * amrPath = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%f_a",[[NSDate date] timeIntervalSince1970]]];
    WeLog(@"Audiolength:%dKB",data.length/1024);
//    [mediaArray addObject:filePath];
    NSData *amrData = EncodeWAVEToAMR(data, 1, 16);
    WeLog(@"sendAmrdata:%dKB",amrData.length/1024);
//    [amrData writeToFile:filePath atomically:YES];
    WeLog(@"armPath%@",amrPath);
    [amrData writeToFile:amrPath atomically:YES];
    [mediaArray addObject:amrPath];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(mediaCount*80, 0, 60, 60)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.layer.borderColor = [[UIColor grayColor]CGColor];
    imgView.layer.borderWidth = 1.0;
    imgView.image = [UIImage imageNamed:@"yinpin.png"];
    
    [self changViewFrame];
   

    CGRect myTVFrame = topView.frame;
    CGRect buttonsViewFrame = buttonsView.frame;
    myTVFrame.size.height = buttonsViewFrame.origin.y-15-60-5;
    topView.frame = myTVFrame;
    
    myTV.frame = CGRectMake(0, 0, 300, topView.frame.size.height-20);
    clearBtn.frame = CGRectMake(topView.frame.size.width-22, topView.frame.size.height-22, 20, 20);
    leftWordCountLbl.frame = CGRectMake(topView.frame.size.width-22-40, topView.frame.size.height-22, 40, 20);
    locationLbl.frame = CGRectMake(20, topView.frame.size.height-22, 240, 20);
    locationIcon.frame = CGRectMake(0, topView.frame.size.height-22, 18, 18);
     [mediaView addSubview:imgView];
    
    [self addDeleteIcon:mediaCount];
    mediaCount++;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioPlay)];
    imgView.userInteractionEnabled = YES;
    [imgView addGestureRecognizer:tapGestureRecognizer];
    [self refreshMediaView];
    [myTV resignFirstResponder];
    [myTV becomeFirstResponder];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)audioPlay{
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL: [NSURL fileURLWithPath:audioPath] error:nil];
    audioPlayer.delegate = self;
    audioPlayer.numberOfLoops = 0;
    [audioPlayer play];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    WeLog(@"audioRecorderEncodeErrorDidOccur...");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    WeLog(@"audioPlayerDidFinishPlaying...");
}

#pragma mark -
#pragma mark  合法性检验
-(BOOL)check{
    //更改发送按钮状态为可点击状态的标准为:判断附件个数和判断myTv的text
    if (![[myTV.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]) {
        [Utility MsgBox:@"文章内容不能为空!"];
        return NO;
    }
    if ([Utility unicodeLengthOfString:myTV.text]>140) {
        [Utility MsgBox:@"文章内容不能超过140个字符!"];
        return NO;
    }
    //为空就不用判断了，用postbutton的enable状态来控制
    return YES;
}

#pragma mark -
#pragma mark Request Delegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_ARTICLE_POST]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utility showHUD:@"发文成功"];
        [mediaArray removeAllObjects];
        [self dismissModalViewControllerAnimated:YES];
        [self performSelector:@selector(postMyNotification) withObject:self afterDelay:1.0];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    if ([type isEqualToString:URL_CLUB_ARTICLE_POST]){
        postBtn.enabled = YES;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_ARTICLE_POST]){
//        [Utility showHUD:@"发文失败"];
    }
    WeLog(@"excepCode%d",excepCode);
    //发文限制
    if (2033 == excepCode) {
        UIAlertView *alert = [Utility MsgBox:@"" AndTitle:@"(发文超过限制)请输入验证码:" AndDelegate:self
           AndCancelBtn:@"取消" AndOtherBtn:@"发表" withStyle:2];
        alert.tag = 3;
        UIImageView *checkCode = [[UIImageView alloc]initWithFrame:CGRectMake(100, 38, 187/2.5, 50/2.5)];
        [Utility addTapGestureRecognizer:checkCode withTarget:self action:@selector(refreshCheckCode:)];
        [checkCode setImageWithURL:CHECKCODE_IMG_URL placeholderImage:[UIImage imageNamed:ATTACHMENT_PIC_HOLDER]];
        checkCode.userInteractionEnabled = YES;
        WeLog(@"imgURL:%@",CHECKCODE_IMG_URL);
        [alert addSubview:checkCode];
        [self.view removeKeyboardControl];
    }
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_ARTICLE_POST]){
        postBtn.enabled = YES;
    }
}

-(void)postMyNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"POST_ARTICLE_SUCCESS" object:nil userInfo:nil];
}
- (void)refreshCheckCode:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    [(UIImageView*)tap.view setImageWithURL:CHECKCODE_IMG_URL placeholderImage:[UIImage imageNamed:ATTACHMENT_PIC_HOLDER]];
}


-(void)post:(NSString *)checkCodeStr{
    if (![self check]) {
        return;
    }
    [myTV resignFirstResponder];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:myAccountUser.locationInfo forKey:KEY_LOCATION];
    [dic setValue:@"0" forKey:KEY_ARTICLE_STYLE];
    [dic setValue:myTV.text forKey:KEY_CONTENT];
    [dic setValue:club.ID forKey:KEY_ID];
    [dic setValue:@"0" forKey:KEY_TYPE];
    if (checkCodeStr&&[checkCodeStr isKindOfClass:[NSString class]]) {
        [dic setValue:checkCodeStr forKey:@"validCode"];
    }
    
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < [mediaArray count];i++) {
        NSData *data = [NSData dataWithContentsOfFile:[mediaArray objectAtIndex:i]];
        WeLog(@"%dFile%@dataLength:%dKB",i,[mediaArray objectAtIndex:i],[data length]/1024);
        [dataDic setValue:data forKey:[NSString stringWithFormat:@"attachment%d",i]];
    }
    [rp sendDictionary:dic andURL:URL_CLUB_ARTICLE_POST andData:dataDic];
    postBtn.enabled = NO;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = -100.f;
}

//返回前的判断
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //录音的alertview
    if (1 == alertView.tag) {
        if (0 == buttonIndex) {
            
        }else{
            [recorder stop];
            [t invalidate];
        }
        return;
    }
    //输入验证码的alertview
    if (3 == alertView.tag) {
        if (buttonIndex) {
            UITextField *txtField = [alertView textFieldAtIndex:0];
            [self post:txtField.text];
        }else{
            return;
        }
    }
    //短链接的alertview
    if (2 == alertView.tag) {
        if (buttonIndex) {
//            [self.view removeKeyboardControl];
            UITextField *txtField = [alertView textFieldAtIndex:0];
            if (![[txtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
                return;
            }
            NSString * regex = @"(http://)?(https://)?[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            BOOL isMatch = [pred evaluateWithObject:txtField.text];
            if (!isMatch) {
                [myTV becomeFirstResponder];
                [Utility MsgBox:@"短链接不是合法的URL"];
//                [self keyBoardChange];
                return;
            }else{
                if ([txtField.text length]) {
                    if ([txtField.text hasPrefix:@"http://"] || [txtField.text hasPrefix:@"https://"]) {
                        myTV.text = [NSString stringWithFormat:@"%@%@ ",myTV.text,txtField.text];
                    }else{
                        myTV.text = [NSString stringWithFormat:@"%@http://%@ ",myTV.text,txtField.text];
                    }
                }            }
            [myTV becomeFirstResponder];

            WeLog(@"isMatch%d",isMatch);
//            [self performSelector:@selector(keyBoardChange) withObject:nil afterDelay:0.1];
//            [self keyBoardChange];

            return;
        }else{
            [myTV becomeFirstResponder];

//            [self keyBoardChange];
            return;
        }
    }
    
    if (buttonIndex == 1) {
        return;
    }else{
        [self.view removeKeyboardControl];
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

//TextView清空按钮
-(void)clearBtnSelected{
    myTV.text=@"";
    leftWordCountLbl.text = @"140";
}

-(void)refreshTextViewCountLbl{
    [self textViewDidChange:myTV];
}

#pragma mark -
#pragma mark  TextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    leftWordCountLbl.text = [NSString stringWithFormat:@"%d",140-[Utility unicodeLengthOfString:[NSString stringWithFormat:@"%@%@",textView.text,text]]];
    if (![Utility calLines:[NSString stringWithFormat:@"%@%@",textView.text,text] withMaxCount:14]) {
        [Utility MsgBox:@"最多不能超过15行."];
        return NO;
    }
    if ([text isEqualToString:@""]) {
        WeLog(@"selectedRange forward%@and after%@",[textView.text substringToIndex:textView.selectedRange.location],[textView.text substringFromIndex:textView.selectedRange.location]);
        
        WeLog(@"growingText%@:%@",textView.text,text);
        if ([Utility emtionAanalyse:[textView.text substringToIndex:textView.selectedRange.location]] != -1) {
            NSString *str = [textView.text substringToIndex:[Utility emtionAanalyse:[textView.text substringToIndex:textView.selectedRange.location]]];
            textView.text = [NSString stringWithFormat:@"%@%@",str,[textView.text substringFromIndex:textView.selectedRange.location]];
            textView.selectedRange = NSMakeRange([str length], 0);
            leftWordCountLbl.text = [NSString stringWithFormat:@"%d",140-[Utility unicodeLengthOfString:[NSString stringWithFormat:@"%@%@",textView.text,text]]];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self keyBoardChange];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (faceBoard.hidden == NO) {
        [emotionBtn setImage:[UIImage imageNamed:@"emotion.png"] forState:UIControlStateNormal];
        emotionLbl.text = @"表情";
        emotionBtn.tag = 0;
        faceBoard.hidden = YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    leftWordCountLbl.text = [NSString stringWithFormat:@"%d",140-[Utility unicodeLengthOfString:[NSString stringWithFormat:@"%@",textView.text]]];
}

- (void)textViewDidEndEditing:(UITextView *)textView{

}

#pragma mark -
#pragma mark  返回界面
-(void)back{
    //内容不为空时要进行判断和提醒
    if ([myTV.text length]||mediaCount) {
        [Utility MsgBox:@"您已编辑是否放弃？" AndTitle:@"提醒" AndDelegate:self AndCancelBtn:@"是" AndOtherBtn:@"否" withStyle:0];
        return;
    }
    [self.view removeKeyboardControl];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(void)initNavigation{
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    postBtn.enabled = NO;
    postBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
    [postBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    [postBtn setTitle:@"发表" forState:UIControlStateNormal];
    [postBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:postBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

@end
