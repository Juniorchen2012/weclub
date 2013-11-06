//
//  PersonShowWinViewController.m
//  WeClub
//
//  Created by Archer on 13-4-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "PersonShowWinViewController.h"

@interface PersonShowWinViewController ()

@end

@implementation PersonShowWinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
//    [rp cancel];
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshView];
    
    //    NSString *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/image.png"];
    //    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    //    UIImageView *imgView = [[UIImageView alloc]initWithImage:image];
    //    imgView.frame = CGRectMake(50, 200, 50, 50);
    //    imgView.backgroundColor = [UIColor redColor];
    //    [self.view addSubview:imgView];
}

- (void)dealloc
{
    displayView = nil;
    ac = nil;
    image = nil;
    imagePickerController = nil;
    audioRecordAlert = nil;
    [rp cancel];
    rp = nil;
    hintLbl = nil;
    recorder = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initNavigation];
    rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    AccountUser *user = [AccountUser getSingleton];
//    [rp getUserInfoByKey:@"numberid" andValue:user.numberID];
    _personInfo = user.userAttachments;
 //   NSLog(@"%@",[_personInfo objectAtIndex:0]);
    ac = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作"
                                     delegate:self
                            cancelButtonTitle:@"取消"
                       destructiveButtonTitle:nil
                            otherButtonTitles:@"上传图片",@"上传音频",@"上传视频",nil];
    ac.delegate = self;
    ac.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    hintLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, screenSize.width, 30)];
    hintLbl.textColor = [UIColor grayColor];
    hintLbl.text = @"展示窗口附件最多上传8个";
    hintLbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:hintLbl];
    audioPlay = [AudioPlay getSingleton];
    videoPlay = [VideoPlayer getSingleton];
}

-(void)refreshView{
    [displayView removeFromSuperview];
    displayView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 320, 200)];
    [self.view addSubview:displayView];
    [self addViews:_personInfo withView:displayView withImageSize:60 withSpace:20];
    hintLbl.frame = CGRectMake(0, displayView.frame.origin.y+displayView.frame.size.height+10, 320, 30);
}

- (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([type isEqualToString:URL_CLUB_GET_DISPLAY_WINDOW]) {
        NSMutableArray *mediaArray = [[NSMutableArray alloc]init];
        [mediaArray addObjectsFromArray:[dic objectForKey:KEY_DATA]];
        club.media = mediaArray;
        [self refreshView];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else if ([type isEqualToString:REQUEST_URL_ADDWINDOW]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [SVProgressHUD show];
        [SVProgressHUD showSuccessWithStatus:@"上传成功"];
//        [Utility showHUD:@"上传成功"];
        [self getDisplayWindows];
    }else if ([type isEqualToString:REQUEST_URL_DELWINDOW]){
        [_personInfo removeObjectAtIndex:deleteNO];
//        AccountUser *user = [AccountUser getSingleton];
//        user.userAttachments = _personInfo;
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        [Utility showHUD:@"删除成功"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [SVProgressHUD show];
        [SVProgressHUD showSuccessWithStatus:@"删除成功"];
        [self refreshView];
    }else if ([type isEqualToString:REQUEST_TYPE_USERINFO]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"tototototo:%@",dic);
        NSDictionary *msgDic = [dic objectForKey:@"msg"];
        AccountUser *user = [AccountUser getSingleton];
        user.userAttachments = [[msgDic objectForKey:@"attachment"] mutableCopy];
        _personInfo = user.userAttachments;
        NSLog(@"gogogogogo:%@",_personInfo);
        [self refreshView];
    }
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD dismiss];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD dismiss];
}

-(void)uploadFile:(NSData *)data{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"0" forKey:@"fileid"];
    NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:data,@"attachment", nil];
    [rp sendDictionary:dic andURL:REQUEST_URL_ADDWINDOW andData:fileDic];
//    [Utility showWaitHUD:@"正在上传..." withView:self.view];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
}

-(void)getDisplayWindows{
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//    [dic setValue:club.ID forKey:KEY_CLUB_ROW_KEY];
//    [rp sendDictionary:dic andURL:URL_CLUB_GET_DISPLAY_WINDOW andData:nil];
    AccountUser *user = [AccountUser getSingleton];
    [rp getUserInfoByKey:@"numberid" andValue:user.numberID];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)delete:(id)sender{
    //点击删除
    UIButton *btn = (UIButton*)sender;
    deleteNO = btn.tag;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定要删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

-(void)add{
    //点击上传
    [ac showInView:self.view];
}

-(void)addCoin{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"300" forKey:@"money"];
    [rp sendDictionary:dic andURL:REQUEST_URL_CHANGEMAININFO andData:nil];
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
    picker = nil;
}

#pragma mark -imagePickerController
-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSData *data;
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]){
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"url:%@",url.path);
        
        //保存路径
        NSDate *now = [NSDate date];
        NSString *fileName = [NSString stringWithFormat:@"%f.mp4",[now timeIntervalSince1970]];
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [arr objectAtIndex:0];
        NSString *videoPath = [documentDir stringByAppendingPathComponent:fileName];
        NSLog(@"filePath:%@",videoPath);
        //        UISaveVideoAtPathToSavedPhotosAlbum([url path], self, nil, NULL);
        //mov转成mp4格式
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetExportSession *aSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetPassthrough];
        aSession.outputURL = [NSURL fileURLWithPath:videoPath];//保存视频到filePath下,真正保存到该路径下还是在下边异步执行中。
        aSession.shouldOptimizeForNetworkUse = YES;
        aSession.outputFileType = AVFileTypeMPEG4;
        
        //[SVProgressHUD showWithStatus:@"正在压缩视频..." maskType:SVProgressHUDMaskTypeClear];
        
        [aSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([aSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"failed...");
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"transcoding failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                    [SVProgressHUD dismiss];
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    [SVProgressHUD dismiss];
                    NSData *data = [NSData dataWithContentsOfURL:aSession.outputURL];
                    [self uploadFile:data];
                    NSLog(@"Successful!");
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
//    [self uploadFile:(NSData *)data];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}


-(void)updateRecordTime{
    if (leftTime <= 30) {
        audioRecordAlert.message = [NSString stringWithFormat:@"正在录音...%ds",leftTime];
    }
    if (leftTime == 30) {
//        [recorder stop];
        audioRecordAlert.message = @"";
        [self audioRecordStop];
        [audioRecordAlert dismissWithClickedButtonIndex:audioRecordAlert.cancelButtonIndex
                                               animated:YES];
    }
    leftTime++;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"录音"]) {
        if (buttonIndex == 0) {
            if (0 == leftTime) {
                _recordFlag = 0;
                [recorder stop];
                [Utility MsgBox:@"录音时间过短，已取消"];
                return;
            }
            [self audioRecordStop];
            leftTime = 30;
            return;
        }else{
            _recordFlag = 0;
            [recorder stop];
            leftTime = 30;
            return;
        }
        
    }
    
    if ([alertView.message isEqualToString:@"确定要删除吗？"]) {
        if (1 == buttonIndex) {
            [audioPlay stop];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            NSString *str = [_personInfo objectAtIndex:deleteNO];
            NSString *fileid = [str substringToIndex:str.length-2];
            [dic setValue:fileid forKey:@"fileid"];
            [rp sendDictionary:dic andURL:REQUEST_URL_DELWINDOW andData:nil];
            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

        }
    }
}

#pragma mark -
#pragma mark  录制音频
- (void)audioRecordStart{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    audioRecordAlert = [[UIAlertView alloc] initWithTitle:@"录音" message:@"正在录音..." delegate:self cancelButtonTitle:@"结束并上传" otherButtonTitles:@"取消", nil];
    leftTime = 0;
    [t invalidate];
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
    [audioRecordAlert show];
    NSString *fileName = @"testrecord.caf";
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    NSLog(@"filePath:%@",filePath);
    
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

- (void)audioRecordStop{
    [recorder performSelector:@selector(stop) withObject:nil afterDelay:0.1];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (_recordFlag == 0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [SVProgressHUD dismiss];
        return;
    }
    NSLog(@"audioRecorderDidFinishRecording...");
    NSString *fileName = @"testrecord.caf";
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"Audiolength:%dKB",data.length/1024);
    //    [mediaArray addObject:filePath];
    NSData *amrData = EncodeWAVEToAMR(data, 1, 16);
    [self uploadFile:amrData];
    NSLog(@"sendAmrdata:%dKB",amrData.length/1024);
    [amrData writeToFile:filePath atomically:YES];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ((3 != buttonIndex)&&(8 == [_personInfo count])) {
        [Utility MsgBox:@"已达到附件最大个数"];
        return;
    }
    if (0 == buttonIndex) {
        [self takePhoto];
    }else if(1 == buttonIndex){
        [self audioRecordStart];
        [audioPlay stop];
    }else if(2 == buttonIndex){
        if (!imagePickerController) {
            imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.videoMaximumDuration = 15.0;//长度限制15s
            imagePickerController.showsCameraControls = YES;
            [self presentModalViewController:imagePickerController animated:YES];
        }
        return;
    }
}

- (void)addViews:(NSArray *)list withView:(UIView *)containerView withImageSize:(CGFloat)size withSpace:(CGFloat)space{
    int i;
    CGFloat bindingHeight = 10;
    for (i = 0; (i < [list count]+1)&&(i < 8); i++) {
        if (i < [list count]) {
//            EGOImageButton* deleteIcon = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"deleteIcon.png"] delegate:nil];
            UIButton* deleteIcon = [[UIButton alloc] init];
            //            deleteIcon.backgroundColor = [UIColor redColor];
            [deleteIcon setImage:[UIImage imageNamed:@"deleteIcon.png"] forState:UIControlStateNormal];
            EGOImageButton* imgView = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"mediaImgPlaceHolder.jpg"] delegate:nil];
            imgView.tag = i;
            NSString * singleMedia = [list objectAtIndex:i];
            NSString *type = [singleMedia substringFromIndex:([singleMedia length]-1)];
            if ([type isEqualToString:TYPE_ATTACH_PICTURE]||[type isEqualToString:TYPE_ATTACH_VIDEO]) {
                NSString *str = [list objectAtIndex:i];
                NSString *fileID = [str substringToIndex:str.length-2];
                [imgView setImageURL:USER_WINDOW_PIC_URL(fileID, TYPE_THUMB)];
                if ([type isEqualToString:TYPE_ATTACH_PICTURE]) {
                    [imgView addTarget:self action:@selector(viewPhoto:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
                NSLog(@"VideoThumbIMG:%@",USER_WINDOW_PIC_URL(fileID, TYPE_THUMB));
                if ([type isEqualToString:TYPE_ATTACH_VIDEO]) {
                    UIImageView *videoIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_video_play.png"]];
                    videoIcon.frame = CGRectMake(20,20,20,20);
                    [imgView addSubview:videoIcon];
                    [imgView addTarget:self action:@selector(videoPlay:) forControlEvents:UIControlEventTouchUpInside];
                }
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
            EGOImageButton* placeHolder = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"media_add.png"] delegate:self];
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
    //    containerView.backgroundColor = [UIColor redColor];
    [containerView setFrame:CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, 4*(size+space), ((i-1)/4+1)*(size+space))];
}

-(void)audioPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    int indexNum = btn.tag;
    NSLog(@"fileName %@",[_personInfo objectAtIndex:indexNum]);
    [audioPlay playAudiowithType:@"personAudio" withView:sender withFileName:[_personInfo objectAtIndex:indexNum] withStyle:0];
}

-(void)videoPlay:(id)sender{
    UIImageView *btn = (UIImageView*)sender;
    NSLog(@"VideoURL%@",ClubImageURL([_personInfo objectAtIndex:btn.tag],TYPE_RAW));
    //    [videoPlay playVideoWithName:[club.media objectAtIndex:btn.tag] withType:@"clubVideo"];
    [videoPlay playVideoWithURL:USER_WINDOW_PIC_PATH([[_personInfo objectAtIndex:btn.tag] substringToIndex:[[_personInfo objectAtIndex:btn.tag] length]-2], TYPE_RAW) withType:@"personVideo" view:self];
}

-(void)viewPhoto:(id)sender{
    UIButton *btn = (UIButton *)sender;
    ViewImage *myViewImg = [[ViewImage alloc]init];
    NSString *str = [_personInfo objectAtIndex:btn.tag];
    NSString *fileID = [str substringToIndex:str.length-2];
    
    UINavigationController *nav = [myViewImg viewLargePhoto:[NSArray arrayWithObjects:USER_WINDOW_PIC_URL(fileID, TYPE_RAW), nil]];
    [self.navigationController presentModalViewController:nav animated:YES];
}

-(void)initNavigation{
    self.view.backgroundColor = [UIColor whiteColor];
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:@"Arial" size:20]];
    titleLbl.text = @"个人展示窗口修改";
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
    
    //手势操作
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(addCoin)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipe];
}

-(void)back{
    [audioPlay stop];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
