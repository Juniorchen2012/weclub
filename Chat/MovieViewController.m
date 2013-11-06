//
//  MovieViewController.m
//  Chat
//
//  Created by Archer on 13-2-1.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "MovieViewController.h"

@interface MovieViewController ()

@end

@implementation MovieViewController

@synthesize movieURL = _movieURL;
@synthesize savePath = _savePath;
@synthesize theMovie = _theMovie;

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _movieURL = url;
        _playerType = PlayerTypeMine;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url andSavePath:(NSString *)path
{
    self = [super init];
    if (self) {
        _movieURL = url;
        _savePath = path;
        _playerType = PlayerTypeSomeoneElse;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    playerRect = CGRectMake(0, 0, 320, screenSize.height-65);
    
    NSLog(@"1");
    //播放本人录制的视频
    if (_playerType == PlayerTypeMine) {
        NSLog(@"2");
        NSLog(@"mine movie path:%@",[_movieURL path]);
        //获取本地视频路径
        if ([[NSFileManager defaultManager] fileExistsAtPath:[_movieURL path]]) {
            NSLog(@"nnnnn");
//            _theMovie = [[MPMoviePlayerController alloc] initWithContentURL:_movieURL];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_theMovie];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:_theMovie];
//            [self.view addSubview:_theMovie.view];
//            [_theMovie setFullscreen:YES animated:YES];
//            _theMovie.shouldAutoplay = YES;
//            [_theMovie.view setFrame:playerRect];
//            [_theMovie prepareToPlay];
//            [_theMovie play];
            [[VideoPlayer getSingleton] playVideoWithURL:[_movieURL path] withType:@"localVideo" view:self];

            NSLog(@"fuck...");
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"local resource error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    //播放他人录制的视频
    }else if (_playerType == PlayerTypeSomeoneElse){
        NSLog(@"3");
        NSLog(@"someone save path:%@",_savePath);
        //获取本地视频路径
        if ([[NSFileManager defaultManager] fileExistsAtPath:_savePath]) {
            NSLog(@"have downloaded,play it");
//            _theMovie = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:_savePath]];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_theMovie];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:_theMovie];
//            [self.view addSubview:_theMovie.view];
//            [_theMovie setFullscreen:YES animated:YES];
//            _theMovie.shouldAutoplay = YES;
//            [_theMovie.view setFrame:playerRect];
//            [_theMovie prepareToPlay];
//            [_theMovie play];
            [[VideoPlayer getSingleton] playVideoWithURL:_savePath withType:@"localVideo" view:self];
        }else{
            //从服务器获取视频信息，并播放
            NSLog(@"nothing,go to download it");
            _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 240, 260, 20)];
            [self.view addSubview:_progressView];
            _scheduleLabel = [[UILabel alloc] init];
            _scheduleLabel.frame = CGRectMake(30, 270, 260, 40);
            _scheduleLabel.backgroundColor = [UIColor clearColor];
            _scheduleLabel.textColor = [UIColor whiteColor];
            _scheduleLabel.textAlignment = NSTextAlignmentCenter;
            _scheduleLabel.text = @"0%(0k/--k)";
            [self.view addSubview:_scheduleLabel];
            NSLog(@"movie url:%@",_movieURL);
            //发送读取视频的请求
            _request = [[ASIHTTPRequest alloc] initWithURL:_movieURL];
            _request.delegate = self;
            _request.downloadProgressDelegate = self;
            [_request setDownloadProgressDelegate:_progressView];
            [_request setDownloadDestinationPath:_savePath];
            [_request startAsynchronous];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"play type error!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
//        [alert release];
    }
    
    
//    [[NSFileManager defaultManager] remo]
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
//    //显示返回按钮
//    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"chat_header_back" ofType:@"png"];
//    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(0, 0, 30, 30);
//    [backBtn setImage:backImg forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)didReceiveMemoryWarning
{
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回按钮回调函数（取消请求，取消播放视频）
- (void)popViewController
{
    [_request cancel];
    [_theMovie stop];
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)requestReceivedResponseHeaders:(ASIHTTPRequest *)request
//{
//    NSLog(@"content length:%lld",request.contentLength);
//    
//}

//- (void)setProgress:(float)newProgress
//{
//    NSLog(@"new progress:%f",newProgress);
//}
//
//- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
//{
//    int rate = (int)(request.totalBytesRead*100.0/request.contentLength*1.0);
//    NSString *scheduleStr = [NSString stringWithFormat:@"%d%%(%@/%@)",rate,[Utility calFileSize:request.totalBytesRead],[Utility calFileSize:request.contentLength]];
//    NSLog(@"schedule:%@",scheduleStr);
//    _scheduleLabel.text = scheduleStr;
//}

#pragma mark - MovieDataRequest
//视频数据请求时调用的回调函数
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
 
    if(request.contentLength > 0) {
            int rate = (int)(request.totalBytesRead*100.0/request.contentLength*1.0);
            NSString *scheduleStr = [NSString stringWithFormat:@"%d%%(%@/%@)",rate,[Utility calFileSize:request.totalBytesRead],[Utility calFileSize:request.contentLength]];
            NSLog(@"schedule:%@",scheduleStr);
            _scheduleLabel.text = scheduleStr;
    }else {
            _scheduleLabel.text = @"";
    }
}

//视频数据请求完毕时调用的回调函数
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished...");
    NSData *data = [NSData dataWithContentsOfFile:_savePath];
    NSLog(@"path:%@,length:%d",_savePath,data.length);
    
    //调用MPMoviePlayerController播放视频
//    _theMovie = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:_savePath]];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_theMovie];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:_theMovie];
//
//    [self.view addSubview:_theMovie.view];
//    [_theMovie setFullscreen:YES animated:YES];
//    _theMovie.shouldAutoplay = YES;
//    [_theMovie.view setFrame:playerRect];
//    [_theMovie prepareToPlay];    
//    [_theMovie play];
    [[VideoPlayer getSingleton] playVideoWithURL:_savePath withType:@"localVideo" view:self];
}

#pragma mark - MoviePlay
//视频播放完毕时的回调函数
- (void)myMovieFinishedCallback:(NSNotification *)aNotification
{
    NSLog(@"movie finished...");
    MPMoviePlayerController *theMovie = [aNotification object];
//    NSLog(@"aaaa:%f,%f",theMovie.naturalSize.width,theMovie.naturalSize.height);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:theMovie];
//    [theMovie.view removeFromSuperview];
//    [theMovie release];
//    [self.navigationController popViewControllerAnimated:YES];
}

@end
