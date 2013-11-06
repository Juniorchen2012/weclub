//
//  ChatInputView.h
//  Chat
//
//  Created by Archer on 13-1-19.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HPGrowingTextView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LocationViewController.h"
#import "Utility.h"
#import "FaceBoard.h"

@protocol ChatInputViewDelegate <NSObject>

//发送文字消息
- (void)sendText:(NSString *)string;
//发送数据消息，带数据类型，保存路径
- (void)sendData:(NSData *)data withType:(NSInteger)type andFilePath:(NSString *)filePath andTimeLength:(float)timeLegnth;
//发送位置信息
- (void)sendLocation:(NSDictionary *)dic;
//该方法用于处理是否遮蔽DAKeyboard对界面的控制，主要是当键盘收起而输入框不下滑的时候
- (void)showExtra:(BOOL)extra;
//改变bubbleview的尺寸
- (void)changeBubbleView:(CGFloat)y;
//当用户录制音频时改变界面上的按钮是否可用的状态
- (void)changeButtonEnable:(BOOL)isEnable;

@end


@interface ChatInputView : UIView<HPGrowingTextViewDelegate,
                            UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate,
                            AVAudioRecorderDelegate,
                            AVAudioPlayerDelegate,
                            UIAlertViewDelegate,
                            LocationViewDelegate,
                            FaceBoardDelegate>
{
    UIViewController<ChatInputViewDelegate> *_delegate;
    
    UIView *_normalInput;      //文字输入的一行
    UIView *_extraInput;       //扩展栏，图片，音频，视频等
    
    UIButton *_voiceChatButton;      //语音切换键
    UIButton *_extraButton;          //多媒体调出
    HPGrowingTextView *_textToSend;  //文字输入框
    UIButton *_pressToSpeak;         //按住说话
    UIButton *_sendButton;           //发送键
    FaceBoard *_faceBoard;           //表情键盘

    BOOL isKeyBoardShow;
    
    UIImagePickerController *ipc;
    
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    BOOL recording;
    float recordingTimeLength;
    UIView *volumeView;
    UIImageView *phone;
    UIImageView *volume;
    UIImageView *dropImgView;
    UILabel *dropLabel;
    UILabel *voiceTimeLabel;
    BOOL dropVoice;
    NSTimer *volumeTimer;
    
    NSString *_movPath;     //未转化之前的视频文件路径，mov格式
    NSString *_filePath;    //生成的视频文件的转化后的保存路径
    
}

@property (nonatomic,strong) UIViewController<ChatInputViewDelegate> *delegate;
@property (nonatomic,strong) UIView *normalInput;
@property (nonatomic,strong) UIView *extraInput;
@property (nonatomic,strong) HPGrowingTextView *textToSend;
@property (nonatomic,assign) BOOL isKeyBoardShow;
@property (nonatomic,strong) UIButton *voiceChatButton;      //语音切换键
@property (nonatomic,strong) UIButton *extraButton;          //多媒体调出
@property (nonatomic) UIImagePickerController *ipc;
@property (nonatomic, assign) BOOL recording;   //判断当前是否录音

//切换文字输入或发送语音
- (void)switchTextOrVoice;
//显示多媒体输入
- (void)showExtraInput;
//发送文字消息
- (void)sendText;
//处理多媒体输入
- (void)handleExtraInput:(id)sender;
//开始录音
- (void)recordBegin;
//结束录音
- (void)recordEnd;
//用于处理语音键丢弃按钮的显示
- (void)moveOut:(id)sender;
- (void)moveIn:(id)sender;
- (void)dropRecord:(id)sender;
- (void)handleVolumeChange;
//用于处理movie转成MP4之后的发送工作
- (void)convertToMP4AndSend:(NSString *)filePath;
//alert something
- (void)alertString:(NSString *)msg;
- (void)stopRecord;

@end
