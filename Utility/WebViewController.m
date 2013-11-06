//
//  WebViewController.m
//  WeClub
//
//  Created by mitbbs on 13-10-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithURLStr:(NSString *)urlStr{
    self = [super init];
    if (self) {
        URLStr = urlStr;
    }
    return self;
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
    
    _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _menuBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
    [_menuBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    [_menuBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [_menuBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [_menuBtn addTarget:self action:@selector(refreshWeb) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_menuBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem;
    
    _webBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _webBack.frame = CGRectMake(0, 0, 60, 30);
    [_webBack setTitle:@"后退" forState:UIControlStateNormal];
    [_webBack setTintColor:NAVIFONT_COLOR];
    [_webBack addTarget:self action:@selector(webBack) forControlEvents:UIControlEventTouchUpInside];
    _webForward = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _webForward.frame = CGRectMake(60, 0, 60, 30);
    [_webForward setTitle:@"前进" forState:UIControlStateNormal];
    [_webForward setTintColor:NAVIFONT_COLOR];
    [_webForward addTarget:self action:@selector(webForward) forControlEvents:UIControlEventTouchUpInside];
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 30)];
    [containerView addSubview:_webBack];
    [containerView addSubview:_webForward];
    self.navigationItem.titleView = containerView;
    _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    _web = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _web.delegate = self;
    [self.view addSubview:_web];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://weixin.qq.com/r/go-C2pvEtMbLrd_599qQ"]];
    [_web loadRequest:request];
	// Do any additional setup after loading the view.
}

-(void)refreshWeb{
    [_web reload];
}

-(void)webBack{
    [_web goBack];
}

-(void)webForward{
    [_web goForward];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self refreshView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self refreshView];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self refreshView];
}


-(void)refreshView{
    if (_web.loading) {
        [_indicator startAnimating];
        UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_indicator];
        self.navigationItem.rightBarButtonItem = menuBtnItem;
    }else{
        [_indicator stopAnimating];
        UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:_menuBtn];
        self.navigationItem.rightBarButtonItem = menuBtnItem;
    }
    _webBack.enabled = _web.canGoBack?YES:NO;
    _webForward.enabled = _web.canGoForward?YES:NO;
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
