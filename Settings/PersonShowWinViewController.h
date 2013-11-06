//
//  PersonShowWinViewController.h
//  WeClub
//
//  Created by Archer on 13-4-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "amrFileCodec.h"
#import "AudioPlay.h"
#import "VideoPlayer.h"

@interface PersonShowWinViewController : UIViewController<UIActionSheetDelegate,DLCImagePickerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RequestProxyDelegate,UIAlertViewDelegate,EGOImageButtonDelegate>
{
    Club *club;
    UIView *displayView;
    UIActionSheet *ac;
    UIImage *image;//要上传的图片
    UIImagePickerController *imagePickerController;
    UIAlertView * audioRecordAlert;
    int     leftTime;
    AVAudioRecorder *recorder;
    RequestProxy *rp;
    int deleteNO;
    NSTimer* t;//录音定时器
    NSMutableArray *_personInfo;
    UILabel * hintLbl;
    AudioPlay *audioPlay;
    VideoPlayer *videoPlay;
    
    int              _recordFlag;    //判断是否取消录音
}


@end
