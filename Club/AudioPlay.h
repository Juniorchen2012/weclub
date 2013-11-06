//
//  AudioPlay.h
//  WeClub
//
//  Created by chao_mit on 13-3-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"

@interface AudioPlay : NSObject<AVAudioPlayerDelegate,ASIHTTPRequestDelegate,AVAudioPlayerDelegate>{
    UIView *playView;
    AVAudioPlayer *player;
    NSString *audioPath;
    NSString *lastURL;
    int audioStyle;
    NSString *lastAudioName;
    int lastPlayNO;
    BOOL shouldResume;//should resume the MPMusicPlayer if the music is interupted by weclubAPP.
    ASIHTTPRequest *request;
}
@property (nonatomic,assign)int lastPlayNO;
@property (nonatomic,retain)NSString *lastAudioName;
@property (nonatomic,retain)AVAudioPlayer *player;
+(AudioPlay*)getSingleton;
-(void)playAudiowithType:(NSString*)type withView:(UIView*)view withFileName:(NSString *)audioName withStyle:(int)style;
-(void)stop;
@end
