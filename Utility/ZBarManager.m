//
//  ZBarManager.m
//  WeClub
//
//  Created by mitbbs on 13-8-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ZBarManager.h"

static ZBarManager *_sharedManager;

#define SCREENSIZE [UIScreen mainScreen].bounds.size
#define LABELFRAME CGRectMake(SCREENSIZE.width/2-100,SCREENSIZE.height/2-100-44,200,200)

@implementation ZBarManager

+ (ZBarManager *)sharedZBarManager
{
    if (!_sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedManager = [[super allocWithZone:NULL] init];
        });
    }
    return _sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedZBarManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return _sharedManager;
}

- (void)logoutPop
{
    [self back];
}

- (UINavigationController *)getReaderWithDelegate:(id)delegate helpStr:(NSString *)str
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutPop) name:NOTIFICATION_KEY_LOGOUT object:nil];
    });
    _scanFlag = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        _helpStr = str;
        if (!_reader) {
            [self reseatReader];
        }
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_reader];
        [self initNavigationController];
        _reader.readerDelegate = delegate;
        self.helpFlag = @"999";
        return nav;
    }else{
        _helpStr = str;
        if (!_qrReader) {
            [self resetQRReader];
        }
        _qrReader.delegate = delegate;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_qrReader];
        [self initNavigationController];
        self.helpFlag = @"999";
        return nav;
    }
}

- (void)reseatReader
{
    _reader = [ZBarReaderViewController new];
    _reader.videoQuality = 0;
    _reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    _reader.cameraFlashMode = -1;
    if ([_reader respondsToSelector:@selector(edgesForExtendedLayout)])
        _reader.edgesForExtendedLayout = UIRectEdgeNone;
    ZBarImageScanner *scanner = _reader.scanner;
    _reader.showsZBarControls = NO;
    UIView *view = _reader.readerView;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIImageView *scanImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"scan_pic" ofType:@"png"]]];
    scanImg.frame = CGRectMake(0,0,screenSize.width,screenSize.height);
    [view addSubview:scanImg];
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
}

- (void)resetQRReader
{
    _qrReader = [[QRZBarViewController alloc] init];
}

#pragma mark - 

- (void)showHelp
{
    NSLog(@"help");
    AboutViewController *about = [[AboutViewController alloc] initWithContentType:@"2"];
    about.zbarHelpFlag = self.helpFlag;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
        [_reader.navigationController pushViewController:about animated:YES];
    }else{
        [_qrReader.navigationController pushViewController:about animated:YES];
    }
}

- (void)back
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
        [_reader.navigationController dismissModalViewControllerAnimated:YES];
    }else{
        [_qrReader.navigationController dismissModalViewControllerAnimated:YES];
    }
    
}

- (void)initNavigationController
{
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    titleLbl.text = _helpStr;
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];

    //rightBarButtonItem
    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        helpBtn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        helpBtn.frame = CGRectMake(0, 20, 30, 30);
    }else{
        [helpBtn setTitle:@"帮助" forState:UIControlStateNormal];
        [helpBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        helpBtn.frame = CGRectMake(0, 20, 50, 30);
        [helpBtn setBackgroundColor:[UIColor clearColor]];
    }
    
    [helpBtn addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *helpBtnItem = [[UIBarButtonItem alloc]initWithCustomView:helpBtn];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
        _reader.navigationController.navigationBar.tintColor = TINT_COLOR;
        _reader.navigationItem.titleView = titleLbl;
        _reader.navigationItem.leftBarButtonItem = backbtn;
        _reader.navigationItem.rightBarButtonItem = helpBtnItem;
    }else{
        _qrReader.navigationController.navigationBar.tintColor = TINT_COLOR;
        _qrReader.navigationItem.titleView = titleLbl;
        _qrReader.navigationItem.leftBarButtonItem = backbtn;
        _qrReader.navigationItem.rightBarButtonItem = helpBtnItem;
    }
}

@end
