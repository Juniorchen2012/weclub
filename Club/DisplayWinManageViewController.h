//
//  DisplayWinManageViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "amrFileCodec.h"
#import "AudioPlay.h"
#import "VideoPlayer.h"
#import "Request.h"


@interface DisplayWinManageViewController : UIViewController<UIActionSheetDelegate,DLCImagePickerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,UIImagePickerControllerDelegate,RequestProxyDelegate,UIAlertViewDelegate>{
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
    UILabel *hintLbl;
    AudioPlay *audioPlay;
    VideoPlayer *videoPlay;
    Request *request;
    BOOL _isClub;//俱乐部1个人0
    NSMutableArray *imgArray;

    NSMutableArray *_personInfo;
    
    NSDictionary *_attInfoDic;

    int              _recordFlag;    //判断是否取消录音
    NSMutableArray *photos;
    ViewImage       *_viewImage;
    BOOL shouldResume;
}
@property (nonatomic, assign)BOOL isClub;
- (id)initWithClub:(Club *)myClub;
@end
