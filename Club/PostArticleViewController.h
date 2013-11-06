//
//  PostArticleViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-29.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "FaceBoard.h"
#import "PostListViewController.h"
#import "refreshDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "DLCImagePickerController.h"
#import "CALayer+WiggleAnimationAdditions.h"
#import "Club.h"
#import "AudioPlay.h"
#import "VideoPlayer.h"
@class PostListViewController;

@interface PostArticleViewController : UIViewController  <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,refreshDelegate,DLCImagePickerDelegate,RequestProxyDelegate,UITextViewDelegate>{
    //处理下拉列表的view
    UILabel *titleLbl;
    UIView *holeView;
    UIView *titleViews;
    UIImageView *titleViewArrow;
    
    UIButton *postBtn;//发表按钮
    
    UIButton *atBodyBtn;//@
    UIButton *topicBtn;//#
    UIButton *emotionBtn;//表情
    UILabel *emotionLbl;
    UIButton *locationBtn;//位置
    UIButton *picPickBtn;//图片
    UIButton *musicBtn;//音频
    UIButton *videoBtn;//视频
    
    UIView *mediaView;//附件view
    UIView *buttonsView;//@ # 表情 位置 图片 音频 视频等按钮
    
    int postStyle;//发文方式,文字为主，图片为主，音频为主，视频为主
    
    UIPlaceHolderTextView *myTV;
    
    UIView *topView;
    UIButton *clearBtn;//UITextView后的清空按钮
    UILabel *leftWordCountLbl;//剩余字数
    int mediaCount;//统计附件个数
    FaceBoard *faceBoard;//表情View
    PostListViewController *postListView;//@#的列表
    UILabel *locationLbl;//显示地点定位
    UIImageView *locationIcon;//位置图标
    UINavigationController *nav;
    UIImagePickerController *imagePickerController;//图片
    
    NSString *videoPath;//视频路径
    
//    DLCImagePickerController *picker;
    AVAudioRecorder *recorder;
    AVAudioPlayer *audioPlayer;
    NSString *audioPath;//音频路径
    NSString *locationInfo;//位置信息
    NSMutableArray *mediaArray;//保存附件路径
    NSMutableArray *mediaPicArray;//图片文件
    UIAlertView *audioRecordAlert;
    AudioPlay *audioPlay;//音频播放
    NSTimer* t;//录音定时器
    UIImageView *img;//验证码图片
    RequestProxy * rp;
    VideoPlayer *videoPlay;
    MWPhoto *viewPicURL;
    BOOL shouldResume;
}
@property (nonatomic,retain) IBOutlet UIButton *atBodyBtn;
@property (nonatomic,retain) IBOutlet UIButton *topicBtn;
@property (nonatomic,retain) IBOutlet UIButton *emotionBtn;
@property (nonatomic,retain) IBOutlet UIButton *locationBtn;
@property (nonatomic,retain) IBOutlet UIButton *picPickBtn;
@property (nonatomic,retain) IBOutlet UIButton *musicBtn;
@property (nonatomic,retain) IBOutlet UIButton *videoBtn;
@property(nonatomic, retain) Club *club;
-(void)hideTitleViews;

@end
