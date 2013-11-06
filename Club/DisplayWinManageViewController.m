//
//  DisplayWinManageViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "DisplayWinManageViewController.h"

@interface DisplayWinManageViewController ()

@end

@implementation DisplayWinManageViewController
@synthesize isClub = _isClub;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithClub:(Club *)myClub
{
    self = [super init];
    if (self) {
        club = myClub;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [audioPlay stop];
    [[VideoPlayer getSingleton] VideoDownLoadCancel];


}

-(void)viewWillAppear:(BOOL)animated{
    if (_isClub) {
        [self refreshView];
    }else{
        
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self initNavigation];
    shouldResume = NO;
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    request = [[Request alloc] init];
    photos = [[NSMutableArray alloc] init] ;
    imgArray = [[NSMutableArray alloc]init];

    ac = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作"
                                         delegate:self
                                cancelButtonTitle:@"取消"
                           destructiveButtonTitle:nil
                                otherButtonTitles:@"上传图片",@"上传音频",@"上传视频",nil];
    ac.delegate = self;
    ac.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    hintLbl = [[UILabel alloc]initWithFrame:CGRectMake(30, 100, 200, 30)];
    hintLbl.textColor = [UIColor grayColor];
    hintLbl.text = @"展示窗口附件最多上传8个";
    [self.view addSubview:hintLbl];
    audioPlay = [AudioPlay getSingleton];
    videoPlay = [VideoPlayer getSingleton];
//    _personInfo = myAccountUser.userAttachments;
    _personInfo = [[NSMutableArray alloc] init];
    
    if (!_isClub) {
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self refreshView];
        [self getDisplayWindows];
    }
}

-(void)refreshView{
    [displayView removeFromSuperview];
    displayView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 320, 200)];
    [self.view addSubview:displayView];
    if (_isClub) {
        [self addViews:club.media withView:displayView withImageSize:60 withSpace:20];
    }else{
        [self addViews:_personInfo withView:displayView withImageSize:60 withSpace:20];
    }
    hintLbl.frame = CGRectMake(60, displayView.frame.origin.y+displayView.frame.size.height+10, 200, 30);
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_GET_DISPLAY_WINDOW]) {
        NSMutableArray *mediaArray = [[NSMutableArray alloc]init];
        [mediaArray addObjectsFromArray:[dic objectForKey:KEY_DATA]];
        club.media = mediaArray;
        club.mediaInfo = [dic objectForKey:KEY_ATTACHMENT_INFO];
        [self refreshView];
    }else if ([type isEqualToString:URL_CLUB_ADD_DISPLAY_WINDOW]){
        [Utility showHUD:@"上传成功"];
        [request getDisplayWindows:club.ID withDelegate:self];
    }else if ([type isEqualToString:URL_CLUB_ATTACHMENT_DELETE]){
        if (_isClub) {
            [club.media removeObjectAtIndex:deleteNO];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [Utility showHUD:@"删除成功"];
            [self refreshView];
        }else{
            [_personInfo removeObjectAtIndex:deleteNO];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [Utility showHUD:@"删除成功"];
            [self refreshView];
        }
    }else if ([type isEqualToString:URL_CLUB_GET_DISPLAY_WINDOW]) {
        NSMutableArray *mediaArray = [[NSMutableArray alloc]init];
        [mediaArray addObjectsFromArray:[dic objectForKey:KEY_DATA]];
        club.media = mediaArray;
        [self refreshView];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else if ([type isEqualToString:REQUEST_URL_ADDWINDOW]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [SVProgressHUD dismiss];
        [Utility showHUD:@"上传成功"];
        [self getDisplayWindows];
    }else if ([type isEqualToString:REQUEST_URL_DELWINDOW]){
        [SVProgressHUD dismiss];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_personInfo removeObjectAtIndex:deleteNO];
        [Utility showHUD:@"删除成功"];
        [self refreshView];
    }else if ([type isEqualToString:REQUEST_TYPE_USERINFO]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        WeLog(@"tototototo:%@",dic);
        NSDictionary *msgDic = [dic objectForKey:@"msg"];
        AccountUser *user = [AccountUser getSingleton];
        user.userAttachments = [[msgDic objectForKey:@"attachment"] mutableCopy];
        _personInfo = user.userAttachments;
        WeLog(@"gogogogogo:%@",_personInfo);
        [self refreshView];
    }else if ([type isEqualToString:REQUEST_TYPE_USERATTINFO]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        WeLog(@"dic::%@",dic);
        NSDictionary *oneDic = [dic objectForKey:@"msg"];
        _attInfoDic = nil;
        _attInfoDic = [oneDic objectForKey:KEY_ATTACHMENT_INFO];
        _personInfo = nil;
        _personInfo = [[NSMutableArray alloc] initWithArray:[oneDic objectForKey:@"attachment"]];
        [self refreshView];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD dismiss];
    [Utility MsgBox:excepDesc];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD dismiss];
}

-(void)getDisplayWindows{
    //    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
    //    [rp sendDictionary:dic andURL:URL_CLUB_GET_DISPLAY_WINDOW andData:nil];
    AccountUser *user = [AccountUser getSingleton];
    if (!_isClub) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:user.numberID,@"numberid", nil];
        [rp sendRequest:dic type:REQUEST_TYPE_USERATTINFO];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else{
        [rp getUserInfoByKey:@"numberid" andValue:user.numberID];
    }
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


-(void)uploadFile:(NSData *)data{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:data,@"attachment", nil];
    if (_isClub) {
        [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
        [rp sendDictionary:dic andURL:URL_CLUB_ADD_DISPLAY_WINDOW andData:fileDic];
        [Utility showWaitHUD:@"正在上传..." withView:self.view];
    }else{
        [dic setValue:@"0" forKey:@"fileid"];
        [rp sendDictionary:dic andURL:REQUEST_URL_ADDWINDOW andData:fileDic];
//        [SVProgressHUD showWithStatus:@"正在上传..." maskType:SVProgressHUDMaskTypeClear];
        [Utility showWaitHUD:@"正在上传..." withView:self.view];
    }
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

-(void)delete:(id)sender{
    //点击删除
    UIButton *btn = (UIButton*)sender;
    deleteNO = btn.tag;
    UIAlertView *alert=[Utility MsgBox:@"确定删除该附件" AndTitle:@"提示" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"确定" withStyle:0];
    alert.tag = 1;
}

-(void)add{
    //点击上传
    [ac showInView:self.view];
}

-(void)change{
    //点击更改
    [ac showInView:self.view];
}


#pragma mark -
#pragma mark  拍照或获取图片或视频
-(void) takePhoto{
    DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}

#pragma mark -imagePickerController
-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSData *data;
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]){
        [Utility showWaitHUD:@"正在上传..." withView:self.view];
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        WeLog(@"url:%@",url.path);
        
        //保存路径
        NSDate *now = [NSDate date];
        NSString *fileName = [NSString stringWithFormat:@"%f.mp4",[now timeIntervalSince1970]];
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [arr objectAtIndex:0];
        NSString *videoPath = [documentDir stringByAppendingPathComponent:fileName];        
        WeLog(@"filePath:%@",videoPath);
//        UISaveVideoAtPathToSavedPhotosAlbum([url path], self, nil, NULL);
        //mov转成mp4格式
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetExportSession *aSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetPassthrough];
        aSession.outputURL = [NSURL fileURLWithPath:videoPath];//保存视频到filePath下,真正保存到该路径下还是在下边异步执行中。
        aSession.shouldOptimizeForNetworkUse = YES;
        aSession.outputFileType = AVFileTypeMPEG4;
        
//        [SVProgressHUD showWithStatus:@"正在压缩视频..." maskType:SVProgressHUDMaskTypeClear];
        
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
                    NSData *data = [NSData dataWithContentsOfURL:aSession.outputURL];
                    WeLog(@"VideoLength%d",[data length]);
                    [self uploadFile:data];
                    WeLog(@"Successful!");
                    break;
                }
                default:
                    break;
            }
        }];
    }else{
        image = [UIImage imageWithData:[info objectForKey:@"data"]];
        NSString * imagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image.png"];
        data = UIImageJPEGRepresentation(image, 0.05);
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
            [self uploadFile:(NSData *)data];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}


//-(void)updateRecordTime{
//    if (leftTime >= 0) {
//        audioRecordAlert.message = [NSString stringWithFormat:@"正在录音...-%ds",leftTime];
//    }
//    if (!leftTime) {
//        [recorder stop];
//        [audioRecordAlert dismissWithClickedButtonIndex:0 animated:YES];
//        audioRecordAlert.message = @"";
//    }
//    leftTime--;
//}

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"录音"]) {
            if (0 == buttonIndex) {
                _recordFlag = 0;
                [recorder stop];
                [t invalidate];
                return;
            }else{
                if ((int)round(recorder.currentTime) == 0) {
                    _recordFlag = 0;
                    [recorder stop];
                    [t invalidate];
                    [Utility MsgBox:@"录音时间过短，已取消"];
                    return;
                }
                [recorder stop];
                [t invalidate];
            }
            return;
    }
    
    //删除的确认
    if (1 == alertView.tag) {
        if (0 == buttonIndex) {
            return;
        }else{
            //删除时要停止音频的播放
            if (_isClub) {
                [audioPlay stop];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setValue:[club.media objectAtIndex:deleteNO] forKey:KEY_ROW_KEY];
                [rp sendDictionary:dic andURL:URL_CLUB_ATTACHMENT_DELETE andData:nil];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                return;
            }else{
                [audioPlay stop];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                NSString *str = [_personInfo objectAtIndex:deleteNO];
                NSString *fileid = [str substringToIndex:str.length-2];
                [dic setValue:fileid forKey:@"fileid"];
                [rp sendDictionary:dic andURL:REQUEST_URL_DELWINDOW andData:nil];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            }
            
        }

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
    audioRecordAlert = [[UIAlertView alloc] initWithTitle:@"录音" message:@"正在录音..." delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"结束并上传", nil];
    leftTime = 30;
    [t invalidate];
    t = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
    [audioRecordAlert show];
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
    _recordFlag = 1;
    if (!recorder) {
        recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
    }
    [recorder prepareToRecord];
    [recorder performSelector:@selector(record) withObject:nil afterDelay:0.1];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (shouldResume) {
        [[MPMusicPlayerController iPodMusicPlayer]play];
        shouldResume = NO;
    }
    if (_recordFlag == 0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [SVProgressHUD dismiss];
        return;
    }
    WeLog(@"audioRecorderDidFinishRecording...");
    NSString *fileName = @"testrecord.caf";
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    WeLog(@"Audiolength:%dKB",data.length/1024);
//    [mediaArray addObject:filePath];
    NSData *amrData = EncodeWAVEToAMR(data, 1, 16);
    [self uploadFile:amrData];
    WeLog(@"sendAmrdata:%dKB",amrData.length/1024);
    [amrData writeToFile:filePath atomically:YES];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ((3 != buttonIndex)&&(8 == [club.media count])) {
        [Utility MsgBox:@"已达到附件最大个数"];
        return;
    }
    [audioPlay stop];
    if (0 == buttonIndex) {
        [self takePhoto];
    }else if(1 == buttonIndex){
        [self audioRecordStart];
    }else if(2 == buttonIndex){
        if (!imagePickerController) {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.videoMaximumDuration = 15.0;//长度限制30s
            imagePickerController.cameraFlashMode = 0;
            imagePickerController.showsCameraControls = YES;
            [self presentModalViewController:imagePickerController animated:YES];
        }
        return;
    }
}

- (void)addViews:(NSArray *)list withView:(UIView *)containerView withImageSize:(CGFloat)size withSpace:(CGFloat)space{
    int i;
    CGFloat bindingHeight = 10;
    if (_isClub) {
    for (i = 0; (i < [list count]+1)&&(i < 8); i++) {
        if (i < [list count]) {
            UIButton* deleteIcon = [[UIButton alloc] init];
            [deleteIcon setImage:[UIImage imageNamed:@"deleteIcon.png"] forState:UIControlStateNormal];
            EGOImageButton* imgView = [[EGOImageButton alloc]init];
            imgView.tag = i;
            imgView.layer.borderColor = [[UIColor grayColor]CGColor];
            imgView.layer.borderWidth = 0.5;
            NSString * singleMedia = [club.media objectAtIndex:i];
            NSString *type = [singleMedia substringFromIndex:([singleMedia length]-1)];
            
            //附件时间长度
            UILabel *audioLengthLbl = [[UILabel alloc]init];
            [Utility styleLbl:audioLengthLbl withTxtColor:ATTACHTIME_LENGTH_LBL_COLOR withBgColor:nil withFontSize:10];
            audioLengthLbl.textAlignment = NSTextAlignmentCenter;
            if ([club.mediaInfo isKindOfClass:[NSDictionary class]]) {
                if (![type isEqualToString:TYPE_ATTACH_PICTURE]) {
                    audioLengthLbl.frame = CGRectMake(0, 45, 60, 15);
                    audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[club.mediaInfo objectForKey:singleMedia] objectForKey:DURATION]];
                    [imgView addSubview:audioLengthLbl];
                }
            }

            if ([type isEqualToString:TYPE_ATTACH_PICTURE]||[type isEqualToString:TYPE_ATTACH_VIDEO]) {
                if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
                    imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ATTACHMENT_PIC_HOLDER ofType:@"jpg"]];
                    [imgView addTarget:self action:@selector(viewPhoto:) forControlEvents:UIControlEventTouchUpInside];
                }
                WeLog(@"VideoThumbIMG:%@",ClubImageURL([list objectAtIndex:i], TYPE_THUMB));
                if ([type isEqualToString:TYPE_ATTACH_VIDEO]) {
                    audioLengthLbl.backgroundColor = [UIColor blackColor];
                    audioLengthLbl.alpha = 0.7;
                    imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:VIDEO_PIC_HOLDER ofType:@"png"]];
                    UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:VIDEO_PLAY_ICON]];
                    videoIcon.frame = CGRectMake(20,20,20,20);
                    [imgView addSubview:videoIcon];
                    [imgView addTarget:self action:@selector(videoPlay:) forControlEvents:UIControlEventTouchUpInside];
                }
                [imgView setImageURL:ClubImageURL([list objectAtIndex:i], TYPE_THUMB)];

            }else if ([type isEqualToString:TYPE_ATTACH_AUDIO]){
                [imgView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
                [imgView addTarget:self action:@selector(audioPlay:) forControlEvents:UIControlEventTouchUpInside];
            }
            //                [imgView setPlaceholderImage:[UIImage imageNamed:@"yinpin.png"]];
            [imgView setFrame:CGRectMake((size+space)*(i%4), (i/4)*(size+space)+bindingHeight, size, size)];
            [deleteIcon setFrame:CGRectMake((size+space)*(i%4)+(size)-10-10-2, (i/4)*(size+space)-10+bindingHeight-10, 40, 40)];
            deleteIcon.tag = i;
            [deleteIcon addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
//            containerView.backgroundColor = [UIColor redColor];
            [containerView addSubview:imgView];
            [containerView addSubview:deleteIcon];
//            [containerView addSubview:infoLbl];
        }else{
            EGOImageButton* placeHolder = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"media_add.png"] delegate:nil];
            [placeHolder setFrame:CGRectMake((size+space)*(i%4), (i/4)*(size+space)+bindingHeight, size, size)];
            [placeHolder addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *infoLbl = [[UILabel alloc]initWithFrame:CGRectMake(placeHolder.frame.origin.x+5, placeHolder.frame.origin.y+3+size, 50, 20)];
            infoLbl.text = @"点击上传";
            infoLbl.backgroundColor = [UIColor clearColor];
            [infoLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:12]];

            [containerView addSubview:placeHolder];
            [containerView addSubview:infoLbl];
        }
    }}else{
        for (i = 0; (i < [list count]+1)&&(i < 8); i++) {
//            NSDictionary *subDic = [list objectAtIndex:i];
//            NSString *mediaName = subDic.allKeys.lastObject;
//            NSString *mediaTime = [subDic.allValues.lastObject objectForKey:@"duration"];
            if (i < [list count]) {
                //            EGOImageButton* deleteIcon = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"deleteIcon.png"] delegate:nil];
                UIButton* deleteIcon = [[UIButton alloc] init];
                //            deleteIcon.backgroundColor = [UIColor redColor];
                [deleteIcon setImage:[UIImage imageNamed:@"deleteIcon.png"] forState:UIControlStateNormal];
                EGOImageButton* imgView = [[EGOImageButton alloc]init];
                imgView.tag = i;
                NSString * singleMedia = [list objectAtIndex:i];
//                NSString *singleMedia = mediaName;
                
                UILabel *audioLengthLbl = [[UILabel alloc]init];
                [Utility styleLbl:audioLengthLbl withTxtColor:ATTACHTIME_LENGTH_LBL_COLOR withBgColor:nil withFontSize:10];
                audioLengthLbl.textAlignment = NSTextAlignmentCenter;
                if ([[[_attInfoDic objectForKey:singleMedia] objectForKey:DURATION] integerValue]) {
                    audioLengthLbl.frame = CGRectMake(0, 45, 60, 15);
                    audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[_attInfoDic objectForKey:singleMedia] objectForKey:DURATION]];
                    [imgView addSubview:audioLengthLbl];
                }else{
                    if ([singleMedia characterAtIndex:singleMedia.length-1] == 'p') {
                    }else{
                        audioLengthLbl.frame = CGRectMake(0, 45, 60, 15);
                        audioLengthLbl.text = @"1''";
                        [imgView addSubview:audioLengthLbl];
                    }
                }
                
                NSString *type = [singleMedia substringFromIndex:([singleMedia length]-1)];
                if ([type isEqualToString:TYPE_ATTACH_PICTURE]||[type isEqualToString:TYPE_ATTACH_VIDEO]) {
                    NSString *str = [list objectAtIndex:i];
//                    NSString *str = mediaName;
                    NSString *fileID = [str substringToIndex:str.length-2];
                    if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
                        imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:ATTACHMENT_PIC_HOLDER ofType:@"jpg"]];
                        [imgView addTarget:self action:@selector(viewPhoto:) forControlEvents:UIControlEventTouchUpInside];
                        
                    }
                    WeLog(@"VideoThumbIMG:%@",USER_WINDOW_PIC_URL(fileID, TYPE_THUMB));
                    if ([type isEqualToString:TYPE_ATTACH_VIDEO]) {
                        audioLengthLbl.backgroundColor = [UIColor blackColor];
                        audioLengthLbl.alpha = 0.7;
                        imgView.placeholderImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:VIDEO_PIC_HOLDER ofType:@"png"]];
                        UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_video_play.png"]];
                        videoIcon.frame = CGRectMake(20,20,20,20);
                        [imgView addSubview:videoIcon];
                        [imgView addTarget:self action:@selector(videoPlay:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    [imgView setImageURL:USER_WINDOW_PIC_URL(fileID, TYPE_THUMB)];
                }else if ([type isEqualToString:TYPE_ATTACH_AUDIO]){
                    [imgView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
                    [imgView addTarget:self action:@selector(audioPlay:) forControlEvents:UIControlEventTouchUpInside];
                }
                [imgView setFrame:CGRectMake((size+space)*(i%4), (i/4)*(size+space)+bindingHeight, size, size)];
                //            imgView.backgroundColor = [UIColor redColor];
                //            [imgView addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
                
                [deleteIcon setFrame:CGRectMake((size+space)*(i%4)+(size)-10-10, (i/4)*(size+space)-10+bindingHeight-10, 40, 40)];
                deleteIcon.tag = i;
                [deleteIcon addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
                
                //            UILabel *infoLbl = [[UILabel alloc]initWithFrame:CGRectMake(imgView.frame.origin.x+5, imgView.frame.origin.y+3+size, 50, 20)];
                //            infoLbl.text = @"点击更改";
                //            infoLbl.backgroundColor = [UIColor clearColor];
                //            [infoLbl setFont:[UIFont fontWithName:@"Arial" size:12]];
                
                [containerView addSubview:imgView];
                [containerView addSubview:deleteIcon];
                //            [containerView addSubview:infoLbl];
            }else{
                EGOImageButton* placeHolder = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"media_add.png"] delegate:nil];
                [placeHolder setFrame:CGRectMake((size+space)*(i%4), (i/4)*(size+space)+bindingHeight, size, size)];
                placeHolder.backgroundColor = [UIColor redColor];
                [placeHolder addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
                
                UILabel *infoLbl = [[UILabel alloc]initWithFrame:CGRectMake(placeHolder.frame.origin.x+5, placeHolder.frame.origin.y+3+size, 50, 20)];
                infoLbl.text = @"点击上传";
                infoLbl.backgroundColor = [UIColor clearColor];
                [infoLbl setFont:[UIFont fontWithName:@"Arial" size:12]];
                
                [containerView addSubview:placeHolder];
                [containerView addSubview:infoLbl];
            }
        }
    }
    [containerView setFrame:CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, 4*(size+space), ((i-1)/4+1)*(size+space))];
}

-(void)audioPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    int indexNum = btn.tag;
    WeLog(@"AudoURL%@",ClubImageURL([club.media objectAtIndex:btn.tag],TYPE_RAW));
    if (_isClub) {
        [audioPlay playAudiowithType:@"clubAudio" withView:sender withFileName:[club.media objectAtIndex:indexNum] withStyle:0];
    }else{
        [audioPlay playAudiowithType:@"personAudio" withView:sender withFileName:[_personInfo objectAtIndex:indexNum] withStyle:0];
    }
}

-(void)videoPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    WeLog(@"VideoURL%@",ClubImageURL([club.media objectAtIndex:btn.tag],TYPE_RAW));
    if (_isClub) {
            [videoPlay playVideoWithURL:[NSString stringWithFormat:@"%@/%@/club/file?name=%@&type=%@",HOST,PHP,[club.media objectAtIndex:btn.tag] ,TYPE_RAW] withType:@"articleVideo" view:self];
    }else{
        [videoPlay playVideoWithURL:USER_WINDOW_PIC_PATH([[_personInfo objectAtIndex:btn.tag] substringToIndex:[[_personInfo objectAtIndex:btn.tag] length]-2], TYPE_RAW) withType:@"personVideo" view:self];

    }

}

-(void)viewPhoto:(id)sender{
    UIButton *btn = (UIButton *)sender;
    _viewImage = [[ViewImage alloc]init];
    UINavigationController *nav;
    NSString *fileID;
    if (!_isClub) {
        NSString *str = [_personInfo objectAtIndex:btn.tag];
        fileID = [str substringToIndex:str.length-2];
    }
    WeLog(@"%d",club.media.count);
    if (_isClub) {
        nav = [_viewImage viewLargePhoto:[NSArray arrayWithObjects:ClubImageURL([club.media objectAtIndex:btn.tag], TYPE_RAW), nil]];
    }else{
        nav = [_viewImage viewLargePhoto:[NSArray arrayWithObjects:USER_WINDOW_PIC_URL(fileID, TYPE_RAW), nil]];
    }
    nav.navigationBar.translucent = NO;
    [self.navigationController presentModalViewController:nav animated:YES];
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

-(void)prepareImageView{
    [imgArray removeAllObjects];
    for (NSString *st in club.media) {
        NSString *displayType = [st substringFromIndex:([st length]-1)];
        if ([displayType isEqualToString:TYPE_ATTACH_PICTURE]) {
            [imgArray addObject:ClubImageURL(st, TYPE_RAW)];
        }
    }
}

//查看图片
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

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    if (_isClub) {
        self.title = @"展示窗口管理";
    }else{
        self.title = @"个人展示窗口管理";
    }
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];

    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
}

-(void)back{
    [rp cancel];
    [request cancelRequest];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
