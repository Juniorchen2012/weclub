//
//  InformCenterViewController.m
//  WeClub
//
//  Created by Archer on 13-4-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "InformCenterViewController.h"

#define SEGMENT_COUNT 3
#define SEGMENT_BUTTON_WIDTH [[UIScreen mainScreen] bounds].size.width/SEGMENT_COUNT
#define CLEAN_BUTTON_TAG 1555
@interface InformCenterViewController ()

@end

@implementation InformCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkAppearTable];
}

- (void)dealloc
{
    _slideView = nil;
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    [_clubInform removeFromSuperview];
    _clubInform = nil;
    [_articleInform removeFromSuperview];
    _articleInform = nil;
    [_userInform removeFromSuperview];
    _userInform = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_INFORMPUSH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_FOLLOWLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_ATTENTIONLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_JOINCLUBLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_MENTIONME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"attention_club_list" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"beginScroll" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"endScroll" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cleanBtn_unclick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cleanBtn_click" object:nil];
}

                                                                                                                                                                                                                      
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    //订制导航条
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"通知中心";
    self.navigationItem.titleView = headerLabel;
    headerLabel = nil;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    _cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cleanBtn.frame = CGRectMake(0, 0, 60, 30);
    [_cleanBtn setTitle:@"清空" forState:UIControlStateNormal];
    [_cleanBtn setBackgroundImage:[UIImage imageNamed:@"login_login.png"] forState:UIControlStateNormal];
    _cleanBtn.tag = CLEAN_BUTTON_TAG;
    _cleanBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cleanBtn addTarget:self action:@selector(clearCurrentNotice) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:_cleanBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    rightBtn = nil;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    UIImageView *segBgView = [[UIImageView alloc] init];
    segBgView.frame = CGRectMake(0, 0, screenSize.width, 40);
    segBgView.backgroundColor = [UIColor colorWithRed:243/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    [self.view addSubview:segBgView];
    segBgView = nil;
    
    _clubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _clubButton.frame = CGRectMake(0, 0, SEGMENT_BUTTON_WIDTH, 40);
    [_clubButton setTitle:@"俱乐部" forState:UIControlStateNormal];
    [_clubButton setTitleColor:[UIColor colorWithRed:69/255.0 green:69/255.0 blue:69/255.0 alpha:1] forState:UIControlStateNormal];
    _clubButton.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    _clubButton.tag = 1;
    [_clubButton addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_clubButton];
    
    _articleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _articleButton.frame = CGRectMake(SEGMENT_BUTTON_WIDTH, 0, SEGMENT_BUTTON_WIDTH, 40);
    [_articleButton setTitle:@"文  章" forState:UIControlStateNormal];
    [_articleButton setTitleColor:[UIColor colorWithRed:69/255.0 green:69/255.0 blue:69/255.0 alpha:1] forState:UIControlStateNormal];
    _articleButton.backgroundColor = [UIColor clearColor];
    _articleButton.tag = 2;
    [_articleButton addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_articleButton];
    
    _userButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _userButton.frame = CGRectMake(SEGMENT_BUTTON_WIDTH*2, 0, SEGMENT_BUTTON_WIDTH, 40);
    [_userButton setTitle:@"用  户" forState:UIControlStateNormal];
    [_userButton setTitleColor:[UIColor colorWithRed:69/255.0 green:69/255.0 blue:69/255.0 alpha:1] forState:UIControlStateNormal];
    _userButton.backgroundColor = [UIColor clearColor];
    _userButton.tag = 3;
    [_userButton addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_userButton];
    
    _slideView = [[UIImageView alloc] init];
    _slideView.frame = CGRectMake(0, 38, SEGMENT_BUTTON_WIDTH, 2);
    _slideView.backgroundColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    [self.view addSubview:_slideView];
    
    /*
     _clubInform = [[ClubInformView alloc] initWithFrame:CGRectMake(0, 40, screenSize.width, screenSize.height-104)];
     [_clubInform start];
     [self.view addSubview:_clubInform];
     _currentIndex = 1;
     
     _articleInform = [[ArticleInformView alloc] initWithFrame:CGRectMake(0, 40, screenSize.width, screenSize.height-104)];
     
     _userInform = [[UserInformView alloc] initWithFrame:CGRectMake(0, 40, screenSize.width, screenSize.height-104)];
     
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushViewController:) name:NOTIFICATION_KEY_INFORMPUSH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:NOTIFICATION_KEY_ADDFRIEND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:NOTIFICATION_KEY_FOLLOWLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:NOTIFICATION_KEY_USERLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:NOTIFICATION_KEY_ATTENTIONLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:NOTIFICATION_KEY_JOINCLUBLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:NOTIFICATION_KEY_MENTIONME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:@"attention_club_list" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginScroll) name:@"beginScroll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endScroll) name:@"endScroll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unclick) name:@"cleanBtn_unclick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(click) name:@"cleanBtn_click"
        object:nil];
    //edit by ytx
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, screenSize.width, screenSize.height-104)];
	_scrollView.contentSize = CGSizeMake(screenSize.width*3, screenSize.height-104);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    
    _clubInform = [[ClubInformView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-104)];
    _currentIndex = 1;
   // [_clubInform start];
    _articleInform = [[ArticleInformView alloc] initWithFrame:CGRectMake(screenSize.width, 0, screenSize.width, screenSize.height-104)];
    _userInform = [[UserInformView alloc] initWithFrame:CGRectMake(screenSize.width*2, 0, screenSize.width, screenSize.height-104)];
    
    _scrollView.showsHorizontalScrollIndicator = NO;
    [_scrollView addSubview:_clubInform];
    [_scrollView addSubview:_articleInform];
    [_scrollView addSubview:_userInform];
    [self.view addSubview:_scrollView];
    // Do any additional setup after loading the view.
}

- (void)unclick
{
    _cleanBtn.userInteractionEnabled = NO;
    _cleanBtn.alpha = 0.7;
}

- (void)click
{
    _cleanBtn.userInteractionEnabled = YES;
    _cleanBtn.alpha = 1;
}

- (void)checkAppearTable
{
    _clubButton.backgroundColor = [UIColor clearColor];
    _articleButton.backgroundColor = [UIColor clearColor];
    _userButton.backgroundColor = [UIColor clearColor];
    
    CGRect rect = _slideView.frame;
    if ([self.noticeType isEqualToString:@"art"]) {
        _articleButton.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        rect.origin.x = SEGMENT_BUTTON_WIDTH;
        _scrollView.contentOffset = CGPointMake(320, 0);
        [_articleInform start];
    }else if ([self.noticeType isEqualToString:@"user"]){
        _userButton.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        rect.origin.x = SEGMENT_BUTTON_WIDTH*2;
        _scrollView.contentOffset = CGPointMake(640, 0);
        [_userInform start];
    }else{
        _clubButton.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        rect.origin.x = 0;
        [_clubInform start];
    }
    _slideView.frame = rect;
    
}

- (BOOL)checkDigestArticlePop
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *str = [ud objectForKey:@"digestInformCenterArticlePush"];
    if (str != nil) {
        return YES;
    }
    return NO;
}

- (BOOL)checkArticlePop
{
    _clubButton.backgroundColor = [UIColor clearColor];
    _articleButton.backgroundColor = [UIColor clearColor];
    _userButton.backgroundColor = [UIColor clearColor];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *str = [ud objectForKey:@"informCenterArticlePush"];
    [ud removeObjectForKey:@"informCenterArticlePush"];
    [ud synchronize];
    if ([str isEqualToString:@"1"]) {
        CGRect rect = _slideView.frame;
        _articleButton.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        rect.origin.x = SEGMENT_BUTTON_WIDTH;
        _scrollView.contentOffset = CGPointMake(320, 0);
        [_articleInform start];
        _slideView.frame = rect;
        return YES;
    }
    return NO;
}

- (BOOL)checkUserPop
{
    _clubButton.backgroundColor = [UIColor clearColor];
    _articleButton.backgroundColor = [UIColor clearColor];
    _userButton.backgroundColor = [UIColor clearColor];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *str = [ud objectForKey:@"informCenterUserPush"];
    [ud removeObjectForKey:@"informCenterUserPush"];
    [ud synchronize];
    if ([str isEqualToString:@"1"]) {
        CGRect rect = _slideView.frame;
        _userButton.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        rect.origin.x = SEGMENT_BUTTON_WIDTH*2;
        _scrollView.contentOffset = CGPointMake(640, 0);
        [_articleInform start];
        _slideView.frame = rect;
        return YES;
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self checkArticlePop]) {
        if ([self checkDigestArticlePop]) {
            [_articleInform delPopDigest];
        }
    }else if ([self checkUserPop]){
    }else{
        [self checkAppearTable];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _clubInform = nil;
    _articleInform = nil;
    _userInform = nil;
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentChanged:(id)sender
{
    _clubButton.backgroundColor = [UIColor clearColor];
    _articleButton.backgroundColor = [UIColor clearColor];
    _userButton.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CGRect rect = _slideView.frame;
    rect.origin.x = btn.frame.origin.x;
    _slideView.frame = rect;
    [UIView commitAnimations];
    
    int index = btn.tag;
    
    //    [_clubInform removeFromSuperview];
    //    [_articleInform removeFromSuperview];
    //    [_userInform removeFromSuperview];
    switch (index) {
        case 1:
        {
            _scrollView.contentOffset = CGPointMake(0, _scrollView.contentOffset.y);
            _currentIndex = 1;
            if (_clubInform.dataArray.count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_unclick" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_click" object:nil];
            }
            break;
        }
        case 2:
        {
            _scrollView.contentOffset = CGPointMake(320, _scrollView.contentOffset.y);
            [_articleInform start];
            //            [self.view addSubview:_articleInform];
            _currentIndex = 2;
            if (_articleInform.dataArray.count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_unclick" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_click" object:nil];
            }
            break;
        }
        case 3:
        {
            _scrollView.contentOffset = CGPointMake(640, _scrollView.contentOffset.y);
            [_userInform start];
            //            [self.view addSubview:_userInform];
            _currentIndex = 3;
            if (_userInform.dataArray.count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_unclick" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_click" object:nil];
            }
            break;
        }
        default:
            break;
    }
}

- (void)pushViewController:(NSNotification *)notification
{
    UIViewController *controller = (UIViewController *)notification.object;
    if ([controller isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)popToRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)clearCurrentNotice
{
    UIAlertView *aletr = [[UIAlertView alloc] initWithTitle:nil message:@"是否清空通知" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
    [aletr show];
    aletr = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        switch (_currentIndex) {
            case 1:
                [_clubInform clearNotice];
                break;
            case 2:
                [_articleInform clearNotice];
                break;
            case 3:
                [_userInform clearNotice];
                break;
            default:
                break;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        _clubButton.backgroundColor = [UIColor clearColor];
        _articleButton.backgroundColor = [UIColor clearColor];
        _userButton.backgroundColor = [UIColor clearColor];
        if (scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width == 0) {
            if (_clubInform.dataArray.count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_unclick" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_click" object:nil];
            }
            _currentIndex = 1;
            [_clubInform start];
        }else if (scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width == 1) {
            if (_articleInform.dataArray.count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_unclick" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_click" object:nil];
            }
            _currentIndex = 2;
            [_articleInform start];
        }else if (scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width == 2){
            if (_userInform.dataArray.count == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_unclick" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cleanBtn_click" object:nil];
            }
            _currentIndex = 3;
            [_userInform start];
        }
        UIButton *btn = (UIButton *)[self.view viewWithTag:scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width + 1];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        btn.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        
        CGRect rect = _slideView.frame;
        
        rect.origin.x = scrollView.contentOffset.x/[[UIScreen mainScreen] bounds].size.width*SEGMENT_BUTTON_WIDTH;
        _slideView.frame = rect;
        [UIView commitAnimations];
        
        _clubInform.tableView.scrollEnabled = YES;
        _articleInform.tableView.scrollEnabled = YES;
        _userInform.tableView.scrollEnabled = YES;
        
    }
    
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        _clubInform.tableView.scrollEnabled = NO;
        _articleInform.tableView.scrollEnabled = NO;
        _userInform.tableView.scrollEnabled = NO;
    }
}

#pragma mark - beginScroll and endScroll
- (void)beginScroll
{
    _scrollView.scrollEnabled = NO;
}

- (void)endScroll
{
    _scrollView.scrollEnabled = YES;
}


@end
