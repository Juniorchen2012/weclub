//
//  AudioPlay.m
//  WeClub
//
//  Created by chao_mit on 13-3-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "AudioPlay.h"

@implementation AudioPlay
static AudioPlay *sharedAudioPlayer = nil;
@synthesize lastAudioName,player,lastPlayNO;
+(AudioPlay *)getSingleton{
    @synchronized (self){//为了确保多线程情况下，仍然确保实体的唯一性
        
        if (!sharedAudioPlayer) {
            
            [[self alloc] init];//非ARC模式下,该方法会调用 allocWithZone
            
        }
        return sharedAudioPlayer;
    }
}



+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        
        if (!sharedAudioPlayer) {
            
            sharedAudioPlayer = [super allocWithZone:zone]; //确保使用同一块内存地址
            
            return sharedAudioPlayer;
            
        }
        
        return nil;
    }
}

- (id)init;
{
    @synchronized(self) {
        
        if (self = [super init]){
            shouldResume = NO;
            return self;
        }
        
        return nil;
    }
}

//音频播放入口
-(void)playAudiowithType:(NSString*)type withView:(UIView*)view withFileName:(NSString *)audioName withStyle:(int)style{
    audioStyle = style;
    if (request) {
        //播放新的时候，先把上一个取消了
        [request cancel];
    }
    //style:0播放非tableview中的音频
    if (!audioStyle && view != nil) {
        if (playView == view) {
            if (player.isPlaying) {
                [(EGOImageButton *)playView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
                [player stop];
                [self resumeOtherAudio];
            }else{
                [(EGOImageButton *)playView setImage:[UIImage imageNamed:@"audio_pause.png"] forState:UIControlStateNormal];
                [self interruptOtherAudio];
                [player play];
            }
        }else{
            //防止从播放文章音频切换到展示窗口音频时，文章音频播放状态没有切换
            lastAudioName = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIOPLAY_CHANGE" object:@"stop"];
            [(EGOImageButton *)playView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
            playView = (UIImageView *)view;
            [(EGOImageButton *)playView setImage:[UIImage imageNamed:@"audio_pause.png"] forState:UIControlStateNormal];
            [self getAudioWithType:type withAudioName:audioName];
        }
    }else if(audioStyle && view != nil){
        //播放文章中的音频
        //防止从播放展示窗口音频切换到文章音频时，展示窗口播放状态没有切换
        [(EGOImageButton *)playView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
        playView = nil;
        
        if ([lastAudioName isEqualToString:audioName]&&view.tag == lastPlayNO) {
            if (player.isPlaying) {
                [player stop];
                [self resumeOtherAudio];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIOPLAY_CHANGE" object:@"stop"];
            }else{
                [self interruptOtherAudio];
                [player play];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIOPLAY_CHANGE" object:@"start"];
            }
        }else{
//            [self getAudioWithType:@"articleAudio" withAudioName:audioName];
            lastPlayNO = view.tag;
            [self getAudioWithType:type withAudioName:audioName];
            NSLog(@"audioName:%@  lastPlayNO %d %d",audioName,lastPlayNO,view.tag);
        }
    }
    else{
        if (player.isPlaying) {
            [player stop];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIOPLAY_CHANGE" object:@"stop"];
        }
    }
}

//从网络下载音频
-(void)getAudioWithType:(NSString*)type withAudioName:(NSString *)audioName{
    lastAudioName = audioName;
    NSString * path=[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask , YES ) objectAtIndex:0 ];
    //判断如果存在就不去下载
    
    NSURL *audiourl;
    if ([type isEqualToString:@"clubAudio"]) {
        audioPath=[path stringByAppendingPathComponent:audioName];
        audiourl = ClubImageURL(audioName, TYPE_RAW);
    }else if([type isEqualToString:@"personAudio"]){
        audioPath=[path stringByAppendingPathComponent:audioName];
        audiourl = USER_WINDOW_PIC_URL(audioName, TYPE_RAW);
    }else if([type isEqualToString:@"articleAudio"]){
        audioPath=[path stringByAppendingPathComponent:audioName];
        audiourl = ArticleImageURL(audioName, TYPE_RAW);
    }else if([type isEqualToString:@"articleAudio_isdigest"]){
        audioPath=[path stringByAppendingPathComponent:audioName];
        audiourl = DigestImageURL(audioName, TYPE_RAW);
    }else if([type isEqualToString:@"localAudio"]){
        audioPath = audioName;
        [self finishDownload];
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) {
        [self finishDownload];
        return;
    }
    
    NSLog(@"音频地址:%@",audiourl);
    request = [ASIHTTPRequest requestWithURL:audiourl];
    request.delegate = self;
    NSLog(@"Audiourl:%@",audiourl.path);
    
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:YES];
    [request setSecondsToCache:60*60*24*1];
    [request setDownloadDestinationPath :audioPath];
    [request buildRequestHeaders];
    
    [request setDidFinishSelector:@selector(finishDownload)];
    [request setDidFailSelector:@selector(failDownload)];
    [request startAsynchronous ];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]init];
    indicator.tag = 10;
    indicator.center = playView.center;
    [playView addSubview:indicator];
    [indicator startAnimating];
}

//下载音频成功播放
-(void)finishDownload{
    NSData *armData = [NSData dataWithContentsOfFile:audioPath];
    NSData *audioData = DecodeAMRToWAVE(armData);
    NSLog(@"下载完成audioPath%@",audioPath);
    NSLog(@"audioLength%dKB",[audioData length]/1024);
    [self interruptOtherAudio];
//    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [[playView viewWithTag:10] removeFromSuperview];
    player = [[AVAudioPlayer alloc]initWithData:audioData error:nil];
    player.delegate = self;
    player.numberOfLoops = 0;
    [player prepareToPlay];//初始化调用
    [player play];
    if (audioStyle) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIOPLAY_CHANGE" object:@"start"];
    }
}

//下载失败
-(void)failDownload{
    [(EGOImageButton *)playView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
    [Utility showHUD:@"获取音频失败"];
}

//播放音频完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self resumeOtherAudio];
    if (!audioStyle) {
        [(EGOImageButton *)playView setImage:[UIImage imageNamed:@"yinpin.png"] forState:UIControlStateNormal];
    }else{
        lastAudioName = @"";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIOPLAY_CHANGE" object:@"stop"];
    }
}

//停止音频的播放
-(void)stop{
    [player stop];
    [self audioPlayerDidFinishPlaying:nil successfully:YES];
    playView = nil;
}

-(void)interruptOtherAudio{
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying) {
        shouldResume = YES;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
}

-(void)resumeOtherAudio{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:NO error:nil];
    if (shouldResume) {
        [[MPMusicPlayerController iPodMusicPlayer]play];
        shouldResume = NO;
    }
}
@end
