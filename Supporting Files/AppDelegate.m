//
//  AppDelegate.m
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarController.h"
#import "Reachability.h"
#import "WXApi.h"
//#import <GoogleOpenSource/GoogleOpenSource.h>
//#import <GooglePlus/GooglePlus.h>
@implementation AppDelegate
@synthesize startPageView;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions...");
    [Utility checkDirs];
    [self checkUUID];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    Constants *myConstants = [Constants getSingleton];

    startPageView = [[StartPageViewController alloc]init];
    startPageView.flag = @"0";
    LoginViewController *login = [[LoginViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:login];
    if ([self checkDirectLogin]) {
//        self.TabC = [[[TabBarController alloc]init] autorelease];
//        ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = self.TabC;
//        UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:self.TabC];
        DirectLoginViewController *directLogin = [[DirectLoginViewController alloc] init];
        self.window.rootViewController = nav;
        [nav pushViewController:directLogin animated:NO];
    }else{
        if ([self checkFirstLogin]) {
            self.window.rootViewController = startPageView;
        }else{
            self.window.rootViewController = nav;
        }
    }
    [login release];
//    self.TabC = [[[TabBarController alloc]init] autorelease];
//    self.window.rootViewController = self.TabC;
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    reach = [[Reachability reachabilityWithHostName:@"www.baidu.com"] retain] ;
    [reach startNotifier];
//	[self updateInterfaceWithReachability: reach];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addMainView:)
                                                 name:@"CHANGEVIEW"
                                               object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    //TODO  渐隐的效果
//    [QQApi registerPluginWithId:@"QQ075BCD15"];
    [ShareSDK registerApp:@"520520test"];
    [self initializePlat];
    [ShareSDK connectWeChatWithAppId:@"wxfde599c6fa2a9b9f"
                           wechatCls:[WXApi class]];

    AccountUser *myAccountUser = [AccountUser getSingleton];
    [self goCheckVersion];
    [Utility clearCacheAuto];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"language%@",language);
    NSLog(@"Document size%@",[Utility getDirectorySize:@"/Users/mitbbs/Library/Application Support/iPhone Simulator/6.1/Applications/C70B4F41-7B12-4D7E-A0C1-12AD4C8B1B2D/Documents/"]);
    return YES;
}



-(void)goCheckVersion{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastCheckDate = [userDefaults objectForKey:@"lastCheckDate"];
    if (lastCheckDate && [userDefaults objectForKey:@"notNoticeCheck"]) {
//        NSLog(@"timerinterval%f",fabs([lastCheckDate timeIntervalSinceNow]));
        if (fabs([lastCheckDate timeIntervalSinceNow]) > 3*24*60*60) {
            
        }else{
            return;
        }
    }else{
        
    }
    [userDefaults setObject:[NSDate date] forKey:@"lastCheckDate"];
    [Utility checkVersion];
}

-(BOOL)checkFirstLogin{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:@"FirstLogin"]) {
        [userDefault setObject:@"YES" forKey:@"FirstLogin"];
        return YES;
    }
    return NO;
    //return YES;
}

- (BOOL)checkDirectLogin
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", [userDefault objectForKey:@"directLogin"]);
    if (![userDefault objectForKey:@"directLogin"] || [[userDefault objectForKey:@"directLogin"] isEqualToString:@"0"]) {
        return NO;
    }else{
        return YES;
    }
}

-(void)addMainView:(NSNotification *) notification{
    if (![notification.object intValue]) {
//        [self.window addSubview:nav.view];
        self.window.rootViewController = nav;
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5f;
        
        //	animation.fillMode = kCATransitionFade;
        animation.type = kCATransitionFade;
        //    animation.subtype = kCATransitionFromRight;
        [nav.view.layer addAnimation:animation forKey:@"animation"];
    }
}

- (void)initializePlat {
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"3201194191"
                               appSecret:@"0334252914651e8f76bad63337b3b78f" redirectUri:@"http://appgo.cn"];
    //添加腾讯微博应用
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c" redirectUri:@"http://www.sharesdk.cn"];
    //添加QQ空间应用
    [ShareSDK connectQZoneWithAppKey:@"100371282" appSecret:@"aed9b0303e3ed1e27bae87c33761161d"];
    //添加网易微博应用
    [ShareSDK connect163WeiboWithAppKey:@"T5EI7BXe13vfyDuy"
                              appSecret:@"gZxwyNOvjFYpxwwlnuizHRRtBRZ2lV1j" redirectUri:@"http://www.shareSDK.cn"];
    //添加人人网应用
    [ShareSDK connectRenRenWithAppKey:@"9dc084da6913468a874187693bb66d47" appSecret:@"69f71bd18c1442fab7fa093861976d0c"];
    //添加开心网应用
    [ShareSDK connectKaiXinWithAppKey:@"358443394194887cee81ff5890870c7c"
                            appSecret:@"da32179d859c016169f66d90b6db2a23"
                          redirectUri:@"http://www.sharesdk.cn/"]; //添加Instapaper应用
    [ShareSDK connectInstapaperWithAppKey:@"4rDJORmcOcSAZL1YpqGHRI605xUvrLbOhkJ07yO0wWrYrc 61FA"
                                appSecret:@"GNr1GespOQbrm8nvd7rlUsyRQsIo3boIbMguAl9gfpdL0aKZWe"]; //添加有道云笔记应用
    [ShareSDK connectYouDaoNoteWithConsumerKey:@"dcde25dca105bcc36884ed4534dab940"
                                consumerSecret:@"d98217b4020e7f1874263795f44838fe"
                                   redirectUri:@"http://www.sharesdk.cn/"];
    //添加Facebook应用
    [ShareSDK connectFacebookWithAppKey:@"107704292745179" appSecret:@"38053202e1a5fe26c80c753071f0b573"];
    //添加Twitter应用
    [ShareSDK connectTwitterWithConsumerKey:@"mnTGqtXk0TYMXYTN7qUxg"
                             consumerSecret:@"ROkFqr8c3m1HXqS3rm3TJ0WkAJuwBOSaWhPbZ9Ojuc" redirectUri:@"http://www.sharesdk.cn"];
    
    
//    [ShareSDK connectLinkedInWithApiKey:@"ejo5ibkye3vo" secretKey:@"cC7B2jpxITqPLZ5M" redirectUri:@"http://sharesdk.cn"];
    
//    [ShareSDK connectGooglePlusWithClientId:@"232554794995.apps.googleusercontent.com" clientSecret:@"PEdFgtrMw97aCvf0joQj7EMk"
//                                redirectUri:@"http://localhost" signInCls:[GPPSignIn class] shareCls:[GPPShare class]];

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url   wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}

- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    static int nReconnectStatus = 0;
    if (netStatus == NotReachable) {
            //网络未连接
//        if (nReconnectStatus == 2) {
//            if ([[AccountUser getSingleton].loginFlag isEqualToString:@"0"]) {
//                [Utility showTextOnly:@"正在连接中..." isWait:YES];
//                [Utility showTextOnly:@"网络已断开..." isWait:NO];
//            }
//            else{
//                [Utility showTextOnly:@"网络未连接..." isWait:NO];
//            }
//        }
        myAccountUser.netWorkStatus &= 0x06;
        NSLog(@"myAccountUser.netWorkStatus : %d", myAccountUser.netWorkStatus);
        nReconnectStatus = 1;
    }else{
        myAccountUser.netWorkStatus |= 0x01;
        if (!myAccountUser.MQTTconnected) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CONNECTMQTT object:nil];
        }
         NSLog(@"%d", myAccountUser.netWorkStatus);
        //网络已经连接
//        if (kNotReachable != myAccountUser.netWorkStatus && nReconnectStatus == 1) {
//            [Utility hideWaitHUDForView:[UIApplication sharedApplication].keyWindow];
//            [Utility showTextOnly:@"网络已恢复..." isWait:NO];
//        }
//        if (kNotReachable != myAccountUser.netWorkStatus && nReconnectStatus == 1 && ![[AccountUser getSingleton].loginFlag isEqualToString:@"0"]){
//            [Utility showTextOnly:@"网络已连接..." isWait:NO];
//        }
        nReconnectStatus = 2;
        
        NSLog(@"myAccountUser.netWorkStatus : %d", myAccountUser.netWorkStatus);
    }
    
//    myAccountUser.netWorkStatus = netStatus;

//	[self updateInterfaceWithReachability: curReach];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([myAccountUser isLogin]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_DICCONNECT_MQTT object:nil];
    }
    [[AudioPlay getSingleton] stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[AudioPlay getSingleton] stop];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [myAccountUser locate];
    if ([myAccountUser isLogin]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_CONNECTMQTT object:nil];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive...");
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (void)checkUUID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"UUID"]) {
        CFUUIDRef UUIDRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef UUIDSRef = CFUUIDCreateString(kCFAllocatorDefault, UUIDRef);
        NSString *UUID = [NSString stringWithFormat:@"%@", UUIDSRef];
        
        [defaults setObject:UUID forKey:@"UUID"];
        [defaults synchronize];
    }
}

@end
