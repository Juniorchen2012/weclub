//
//  Constants.m
//  WeClub
//
//  Created by chao_mit on 13-1-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer
@synthesize playNO,player;
static AudioPlayer *sharedAudioPlayer = nil;
+(AudioPlayer *)getSingleton{
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
            playNO = -1;
            return self;
        }
        
        return nil;
    }
}

-(void)play:(int)i{
    NSLog(@"这个播放器即将播放第%d个音频",i);
    if (playNO == i) {
        if (player.isPlaying) {
            NSLog(@"isPlaying");
            [player stop];
        }else{
            [player play];
        }
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIO_CHANGE" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",playNO] forKey:@"playNO"]];
    NSString * audioPathNew = [[NSBundle mainBundle] pathForResource:[[NSArray arrayWithObjects:nil ]objectAtIndex:i%2] ofType:@"mp3"];
    NSURL *newurl = [[NSURL alloc]initFileURLWithPath:audioPathNew ];
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:newurl error:nil];
    player.delegate = self;
    player.numberOfLoops = 0;
    [player stop];
    [player prepareToPlay];//初始化调用
    [player play];
    playNO = i;
}

-(void)stop{
    [player stop];
}


//-(void)finishDownload{
//    NSData *armData = [NSData dataWithContentsOfFile:audioPath];
//    NSData *audioData = DecodeAMRToWAVE(armData);
//    NSLog(@"audioLength%dKB",[audioData length]/1024);
//    player = [[AVAudioPlayer alloc]initWithData:audioData error:nil];
//    player.delegate = self;
//    player.numberOfLoops = 0;
//    //    [player stop];
//    [player prepareToPlay];//初始化调用
//    [player play];
//}

-(void)failDownload{
    [Utility showHUD:@"获取音频失败"];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

}

//-(void)getAudioWithType:(NSString*)type withAudioName:(NSString *)audioName{
//    NSString * path=[ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask , YES ) objectAtIndex:0 ];
//    audioPath=[path stringByAppendingPathComponent:audioName];
//    NSString *audiourl;
//    if ([type isEqualToString:@"clubAudio"]) {
//        audiourl = ClubImageURL(audioName, TYPE_RAW);
//    }else{
//        audiourl = ArticleImageURL(audioName, TYPE_RAW);
//    }
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:audiourl];
//    request.delegate = self;
//    NSLog(@"Audiourl:%@",ClubImageURL(audioName,TYPE_RAW));
//    
//    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
//    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:YES];
//    [request setSecondsToCache:60*60*24*1];
//    [request setDownloadDestinationPath :audioPath];
//    [request buildRequestHeaders];
//    
//    [request setDidFinishSelector:@selector(finishDownload)];
//    [request setDidFailSelector:@selector(failDownload)];
//    [request startSynchronous ];
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]init];
//    indicator.tag = 4;
//    [indicator startAnimating];
//}

- (id)copyWithZone:(NSZone *)zone;{
    return self; //确保copy对象也是唯一
}

-(void)gotoWhenAudioPlaying{
    //考虑的问题:播放时跳入到其他页面,播放一段又暂停播放,等两种情况
    [self stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AUDIO_CHANGE" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",self.playNO] forKey:@"playNO"]];
    self.playNO = -1;
}


//-(id)retain{
//
//    return self; //确保计数唯一
//
//}
//
//
//
//- (unsigned)retainCount
//
//{
//
//    return UINT_MAX;  //装逼用的，这样打印出来的计数永远为-1
//
//}
//
//
//
//- (id)autorelease
//
//{
//
//    return self;//确保计数唯一
//
//}
//
//
//
//- (oneway void)release
//
//{
//
//    //重写计数释放方法
//
//}

//+(Constants*)getSingleton{
//    static Constants *constants = nil;
//
//    @synchronized(self)
//    {
//        if (!constants)
//            constants = [[Constants alloc] init];
//        return constants;
//    }
//}

@end
