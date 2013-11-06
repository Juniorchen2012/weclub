//
//  ArticleDetailViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Article.h"
#import "ArticleCell.h"
#import "ReplyViewCell.h"
#import <ShareSDK/ShareSDK.h>
#import "PostArticleViewController.h"
#import "HPGrowingTextView.h"
#import "FaceBoard.h"
#import "Club.h"
#import "AudioPlay.h"
#import "PersonInfoViewController.h"
#import "MLTableView.h"

//同主题页

@interface ArticleDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,HPGrowingTextViewDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate,RequestProxyDelegate,MWPhotoBrowserDelegate>
{
    UIView *headerView;
    UIImageView *avatar;//用户头像
    UIImageView *bg;
    UILabel *nameLbl;//名称
    UIImageView *followIcon;
    UILabel *distanceLbl;//距离
    UILabel *replyCountLbl;//回复数
    UILabel *browseCountLbl;//浏览数
    UILabel *collectCountLbl;//收藏数
    UILabel *shareCountLbl;//分享数
    UIView *toolBar;
    UILabel *contentLbl;// 文章内容
    UIView *mediaView;
    UIImageView *bigImg;//大图
    UILabel *postTimeLbl;//发文时间
    UITableView *myTable;
    Article *topicArticle;
    int indexNum;
    BOOL refreshing;
    NSMutableArray *replyArticleList;
    UIButton *goClubBtn;
    
    NSMutableArray *photos;
    NSString* postURLStr;
    MPMoviePlayerController *movie;
    
    HPGrowingTextView *_textToSend;  //文字输入框
    FaceBoard *faceBoard;//表情View
    UIButton *sendButton;//发送按钮
    UIButton *emotionBtn;
    UIView *replyBgView;
    UIView *replyView;
    AVAudioRecorder *recorder;
    UIButton *voiceChatButton;
    UIButton *pressToSpeak;
    UITextField *inputField;
    UIView *volumeView;
    UIImageView *phone;
    UIImageView *volume;
    UILabel *_recordTime;//录音时间
    UIImageView *dropImgView;
    UILabel *dropLabel;
    BOOL dropVoice;
    NSTimer *volumeTimer;
    NSTimer *_recordTimeTimer;//录音时间定时器
    AVAudioPlayer *newPlayer;
    NSString *mediaPath;
    UIButton *tapCancelReplyBtn;
    UITapGestureRecognizer *tapReplyCancel;
    int toReply;
    bool readFlag;
    bool sortFlag;//回复的顺序标志
    RequestProxy *rp;
    NSMutableArray *replyArticleNum;//记录带有引用的文章的序号
    AudioPlay *audioPlay;
    bool isDigest;//标志点进来的文章是否是精华区的文章
    NSString *topicArticleRowKey;
    NSData *audioData;
    NSString *startKey;
    UIButton *menuBtn;
    UIView * bottomView;
    BOOL goToFlag;//因为需要发userType请求的不止一个，为了区分是否是跳转俱乐部用这个标志
    BOOL refreshAfterReply;//在回复后，刷新评论会跳到回复的第一条
    
    UISlider* playingSlider;
    UILabel* playingTimeLbl;
    UIButton* playingBtn;
    NSString *lastReplyContent;//保留回复文章的内容，不进行清除
    CGRect lastReplyRect;
    CGRect lastTextViewRect;
    UIViewController *lastViewController;
    UIImageView *digestIcon;//加精标志
    UIImageView *onTopIcon;//置顶标志
    BOOL shouldResume;
    NSTimer *playAudioTimer;
    CGFloat _contentHeight;
}
@property(nonatomic, assign) bool isDigest;
@property(nonatomic, retain) Article *topicArticle;
@property(nonatomic, retain) Club *club;
@property(nonatomic, retain) UIViewController *lastViewController;
@property(nonatomic, assign) int indexNum;
@property(nonatomic, assign) bool isLoadMore;
@property(nonatomic, assign) bool readFlag;
@property(nonatomic, assign) int informPushIndex;   //从通知中心进来时文章所在的行数
- (id)initWithArticleRowKey:(NSString *)myArticleRowKey;
@end

