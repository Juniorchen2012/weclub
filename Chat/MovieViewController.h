//
//  MovieViewController.h
//  Chat
//
//  Created by Archer on 13-2-1.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ASIHTTPRequest.h"
#import "Utility.h"
#import "VideoPlayer.h"

typedef enum _NSPlayerType
{
    PlayerTypeMine = 0,
    PlayerTypeSomeoneElse = 1
} NSPlayerType;

@interface MovieViewController : UIViewController<ASIHTTPRequestDelegate,ASIProgressDelegate>
{
    NSURL *_movieURL;
    NSString *_savePath;
    NSPlayerType _playerType;
    UIProgressView *_progressView;
    UILabel *_scheduleLabel;
    CGRect playerRect;
    ASIHTTPRequest *_request;
    MPMoviePlayerController *_theMovie;
}

@property (nonatomic,retain) NSURL *movieURL;
@property (nonatomic,retain) NSString *savePath;
@property (nonatomic,strong) MPMoviePlayerController *theMovie;

//初始化函数，用于播放本地发送的视频，url中是本地资源的url
- (id)initWithURL:(NSURL *)url;
//初始化函数，用户播放收到的视频，url中是服务器端资源的url，path是生成的本地保存路径
- (id)initWithURL:(NSURL *)url andSavePath:(NSString *)path;
//播放器的回调函数
- (void)myMovieFinishedCallback:(NSNotification *)aNotification;

@end
