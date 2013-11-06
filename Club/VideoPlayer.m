//
//  VideoPlayer.m
//  WeClub
//
//  Created by chao_mit on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "VideoPlayer.h"

@implementation VideoPlayer
static VideoPlayer *sharedVideoPlayer = nil;
+(VideoPlayer *)getSingleton{
    @synchronized (self){//为了确保多线程情况下，仍然确保实体的唯一性
        
        if (!sharedVideoPlayer) {
            
            [[self alloc] init];//非ARC模式下,该方法会调用 allocWithZone
            
        }
        return sharedVideoPlayer;
    }
}



+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        
        if (!sharedVideoPlayer) {
            
            sharedVideoPlayer = [super allocWithZone:zone]; //确保使用同一块内存地址
            
            return sharedVideoPlayer;
            
        }
        
        return nil;
    }
}

- (id)init;
{
    @synchronized(self) {
    
        if (self = [super init]){
            playNO = -1;
            viewController = nil;
            superView = nil;
            return self;
        }
        
        return nil;
    }
}

-(void)finishDownload{
    if (viewController == nil) {
        [MBProgressHUD hideAllHUDsForView:superView animated:YES];
    }
    else{
        [MBProgressHUD hideAllHUDsForView:viewController.view animated:YES];
    }
    [[[[UIApplication sharedApplication].windows objectAtIndex:0] viewWithTag:5555555] removeFromSuperview];
    [SVProgressHUD dismiss];
    NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
//    UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, nil, nil);
    NSLog(@"videoPath%@",videoPath);
    NSLog(@"videoLength%d",[videoData length]);
    if (![videoPath hasSuffix:@".mp4"]) {
        videoPath = [NSString stringWithFormat:@"%@.mp4",videoPath];
    }
    NSLog(@"VideoPath%@",videoPath);
    movie = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
//    movie.moviePlayer.fullscreen = YES;
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(donea:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

    if (viewController != nil) {
        [viewController presentMoviePlayerViewControllerAnimated:movie];
    }
    request = nil;
}

-(void)failDownload{
    [SVProgressHUD dismissWithError:@"加载视频失败..."];
    NSLog(@"视频加载失败...");
    [MBProgressHUD hideAllHUDsForView:viewController.view animated:YES];
        [[[[UIApplication sharedApplication].windows objectAtIndex:0] viewWithTag:5555555] removeFromSuperview];
    request = nil;
}

- (void)playVideoWithURL:(NSString *)urlString withType:(NSString *)type view:(UIViewController *)viewCon
{
    viewController = viewCon;
    [self playVideoWithURL:urlString withType:type superView:viewCon.view];
}

- (void)playVideoWithURL:(NSString *)urlString withType:(NSString *)type superView:(UIView *)addView
{
    NSString * path=[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask , YES ) objectAtIndex:0 ];
    NSURL *videourl;
    superView = addView;
    NSLog(@"videoPlayerURLString%@",urlString);
    if ([type isEqualToString:@"personVideo"]) {
        videoPath=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[[[[urlString componentsSeparatedByString:@"fileid="] objectAtIndex:1] componentsSeparatedByString:@"&"] objectAtIndex:0]]];
    }else if([type isEqualToString:@"articleVideo"]){
        videoPath=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[[[[urlString componentsSeparatedByString:@"name="] objectAtIndex:1] componentsSeparatedByString:@"&"] objectAtIndex:0]]];
    }else if([type isEqualToString:@"localVideo"]){
        videoPath = urlString;
        NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
        NSLog(@"videoPath%@",videoPath);
        NSLog(@"videoLength%d",[videoData length]);
        [videoData writeToFile:[NSString stringWithFormat:@"%@.mp4",videoPath] atomically:nil];
        [self finishDownload];
        return;
    }else if([type isEqualToString:@"urlVideo"])
    {
        videoPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[[urlString componentsSeparatedByString:@"php/"] objectAtIndex:1]]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        [self finishDownload];
        return;
    }
    //    if ([type isEqualToString:@"clubVideo"]) {
    //        videourl = ClubImageURL(videoName, TYPE_RAW);
    //        videourl = [NSURL URLWithString:videoName];
    //    }else{
    //        videourl = ArticleImageURL(videoName, TYPE_RAW);
    //    }
    videourl = [NSURL URLWithString:urlString];
    NSLog(@"VideoURL%@",videourl);
    request = [ASIHTTPRequest requestWithURL:videourl];
    request.delegate = self;
    NSLog(@"Audiourl:%@",videourl.path);
    
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
    [request setSecondsToCache:60*60*24*1];
    [request setDownloadDestinationPath:videoPath];
    [request buildRequestHeaders];
    
    [request setDidFinishSelector:@selector(finishDownload)];
    [request setDidFailSelector:@selector(failDownload)];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows objectAtIndex:0] animated:YES];
    hud.tag = 5555555;
    hud.margin = 40.0f;
    hud.detailsLabelText = @"正在加载视频...";
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    cancelBtn.frame = CGRectMake(hud.center.x-40, hud.center.y+36, 80, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[[UIImage imageNamed:@"btn_alertdiaglog.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[[UIImage imageNamed:@"btn_alertdiaglog_click.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(VideoDownLoadCancel) forControlEvents:UIControlEventTouchUpInside];
    hud.customView = cancelBtn;
    [hud addSubview:cancelBtn];

    [request performSelector:@selector(startAsynchronous) withObject:nil afterDelay:0.1];
    
}

//-(void)playVideoWithName:(NSString *)videoName withType:(NSString*)type{
//    NSString * path=[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask , YES ) objectAtIndex:0 ];
//    videoPath=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",videoName]];
//    NSURL *videourl;
//    if ([type isEqualToString:@"clubVideo"]) {
//        videourl = ClubImageURL(videoName, TYPE_RAW);
//    }else{
//        videourl = ArticleImageURL(videoName, TYPE_RAW);
//    }
//    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:videourl];
//    request.delegate = self;
//    NSLog(@"Audiourl:%@",ClubImageURL(videoName,TYPE_RAW));
//    
//    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
//    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
//    [request setSecondsToCache:60*60*24*1];
//    [request setDownloadDestinationPath :videoPath]; 
//    [request buildRequestHeaders];
//    
//    [request setDidFinishSelector:@selector(finishDownload)];
//    [request setDidFailSelector:@selector(failDownload)];
//    [SVProgressHUD showWithStatus:@"正在加载视频..."];
//    [request performSelector:@selector(startSynchronous) withObject:nil afterDelay:0.1];
//}

-(void)donea:(NSNotification*)aNotification{
    NSLog(@"asfafawegawfaw");
//    [movie dismissMoviePlayerViewControllerAnimated];
//    [movie removeFromParentViewController];
//    [movie release];
//    MPMoviePlayerController *themovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [movie release];
//    viewController = nil;
}

-(void)VideoDownLoadCancel{                                                                                                                  
    NSLog(@"Request%@",request);
    if (request) {
        [request cancel];
        request = nil;                                                                                                                                                                                                                                                                                                                                                                  
    }
}

- (id)copyWithZone:(NSZone *)zone;{
    return self; //确保copy对象也是唯一
}
@end
