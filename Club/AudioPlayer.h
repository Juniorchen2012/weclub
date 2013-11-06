//
//  SharedAudioPlayer.h
//  Test4AudioPlay
//
//  Created by chao_mit on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer : NSObject<AVAudioPlayerDelegate>{
    int playNO;
    AVAudioPlayer *player;
}
@property(nonatomic, assign)int playNO;
@property(nonatomic, retain)AVAudioPlayer *player;
+(AudioPlayer*)getSingleton;
-(void)play:(int)i;
-(void)stop;
-(void)gotoWhenAudioPlaying;
@end
