//
//  VideoPlayer.h
//  WeClub
//
//  Created by chao_mit on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayer : NSObject<AVAudioPlayerDelegate>{
    int playNO;
    NSString *videoPath;
    UIViewController *viewController;
    UIView *superView;
    ASIHTTPRequest *request;
    MPMoviePlayerViewController * movie;
}
+(VideoPlayer*)getSingleton;
-(void)playVideoWithURL:(NSString *)urlString withType:(NSString*)type view:(UIViewController *)viewCon;
- (void)playVideoWithURL:(NSString *)urlString withType:(NSString *)type superView:(UIView *)addView;
-(void)VideoDownLoadCancel;
@end
