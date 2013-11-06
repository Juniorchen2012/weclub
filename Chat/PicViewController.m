//
//  PicViewController.m
//  Chat
//
//  Created by Archer on 13-2-1.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "PicViewController.h"

@interface PicViewController ()

@end

@implementation PicViewController

- (id)initWithURL:(NSURL *)url andSavePath:(NSString *)path
{
    self = [super init];
    if (self) {
        _remoteURL = url;
        _savePath = path;
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        _availableSize = CGSizeMake(screenSize.width, screenSize.height-65);
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
    
    self.view.backgroundColor = [UIColor clearColor];

//    _progressView = [[UIProgressView alloc] init];
//    _progressView.frame = CGRectMake(0, 240, 320, 20);
//    [self.view addSubview:_progressView];
    /*  判断照片是否已经存在
        YES:    直接调用照片
        NO:     异步请求照片信息
     */
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:_savePath];
    if (exist) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = CGRectMake(0, 0, 320, 415);
        _imageView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_imageView];
        UIImage *img = [UIImage imageWithContentsOfFile:_savePath];
        [self calSize:img.size];
        [_imageView setImage:img];
    }else{
        NSLog(@"go to load...");
//        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:_remoteURL];
//        request.delegate = self;
//        [request setDownloadProgressDelegate:_progressView];
//        [request setDownloadDestinationPath:_savePath];
//        [request startAsynchronous];
        //声明异步请求照片对象
        AsyncImageView *asy = [[AsyncImageView alloc] init];
        asy.savePath = _savePath;
        asy.frame = CGRectMake(0, 0, 320, 415);
        NSLog(@"asy frame:%f,%f,%f,%f",asy.frame.origin.x,asy.frame.origin.y,asy.frame.size.width,asy.frame.size.height);
        asy.backgroundColor = [UIColor clearColor];
        [asy setImageWithUrl:_remoteURL];
        [self.view addSubview:asy];
    }
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"chat_header_back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    [super dealloc];
//    [_imageView release];
    _imageView = nil;
//    [_progressView release];
    _progressView = nil;
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

//计算imageView的大小
- (void)calSize:(CGSize)imgSize
{
    if (_availableSize.width == 0 || _availableSize.height == 0) {
        [self alertSomething:@"错误的屏幕尺寸"];
        return;
    }
    float wScale = imgSize.width/_availableSize.width;
    float hScale = imgSize.height/_availableSize.height;
    float maxScale = wScale>hScale?wScale:hScale;
    NSLog(@"w:%f,h:%f,m:%f",wScale,hScale,maxScale);
    if (maxScale == 0) {
      //  [self alertSomething:@"错误的图片尺寸"];
        return;
    }
    CGSize newSize = CGSizeMake(imgSize.width/maxScale, imgSize.height/maxScale);
    _imageView.frame = CGRectMake((_availableSize.width-newSize.width)/2, (_availableSize.height-newSize.height)/2, newSize.width, newSize.height);
}

- (void)alertSomething:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
//    [alert release];
}

@end
