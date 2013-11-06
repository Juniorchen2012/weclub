//
//  PersonInfoViewController.h
//  WeClub
//
//  Created by Archer on 13-3-22.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "PersonArticleCell.h"
#import "FPPopoverController.h"
#import "MenuListTableViewController.h"
#import "FriendModel.h"
#import "ViewImage.h"
#import "Club.h"
#import "VideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"
#import "AudioPlay.h"
#import "QRCodeGenerator.h"
#import "TopicArticleListViewController.h"
#import "ArticleDetailViewController.h"
#import "SuperUserListViewController.h"
#import "ListViewController.h"

@interface PersonInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate,FPPopoverControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate,
    MWPhotoBrowserDelegate>
{
    NSString *_initValue;
    NSString *_initKey;
    UITableView *_tableView;
    NSString *_numberID;
    NSDictionary *_dataDic;
    NSArray *_attachmentArray;
    NSDictionary *_attachmentInfoArray;
    UIView *_infoHeaderOne;
    UIView *_infoHeaderTwo;
    //信息部分一
    UIImageView *_infoHeaderOneBgView;
    NSString *_strPhotoID;          //用户头像ID
    UIImageView *_photoView;
    UIButton *_photoButton;
    UILabel *_nameLabel;
    NSString *_strSex;              //用户性别标示
    UIImageView *_sexView;
    UILabel *_generationLabel;
    UILabel *_numberIDLabel;
    UILabel *_distanceLabel;
    UILabel *_regTime;              //用户注册时间信息
    UIImageView *_TDCview;
    UILabel *_autographLabel;
    //信息部分二
    UIButton *_personIFollow;
    UIButton *_personFollowMe;
    UIButton *_clubIJoined;
    UIButton *_clubIFollow;
    //网络请求代理
    RequestProxy *_rp;
    NSMutableArray *_articleArray;
    NSString *_startKey;
    FPPopoverController *_popOverMenu;
    VideoPlayer *vp;
    UIButton *_lastVoiceButton;
    AVAudioPlayer *_audioPlayer;
    ASIFormDataRequest *_audioRequest;
    NSString *_mediaPath;
    AudioPlay *_audioPlay;
    UIButton *_lastAudioButton;
    MenuListTableViewController *_menu;
    BOOL _inFollow;
    BOOL _inBlack;
    
    UIControl *holeView;
    UIView *titleViews;
    UIView *categoryView;
    NSMutableArray *_menuItemArray;
    UIButton *followBtn;
    UIButton *blackBtn;
    UIButton *clubNameBtn;
    BOOL goToFlag;//因为需要发userType请求的不止一个，为了区分是否是跳转俱乐部用这个标志
    NSString *articleCount;
    NSString *userFlag;     //用户状态 1：用户信息不全 0：用户信息齐全
    
    //展示图片
    NSMutableArray *photoArray;
    NSMutableArray *userInfoPhotosArray;
    
    NSInteger updateNum;
}

@property (nonatomic,retain) NSMutableArray *articleArray;
@property (nonatomic,retain) NSString *startKey;
@property (nonatomic, retain) Club *club;
@property (nonatomic, retain) UITableView *tableView;

- (id)initWithNumberID:(NSString *)numberID;
- (id)initWithUserName:(NSString *)username;
- (id)initWithUserRowKey:(NSString *)rowkey;
- (void)playAttachment:(id)sender;
- (void)refreshPersonInfo;
- (void)loadArticleData;
- (void)showMenu:(id)sender;
- (void)handleMenuListNotification:(NSNotification *)notification;
- (void)playPicture:(id)sender;
- (void)playAudio:(id)sender;
- (void)playVideo:(id)sender;
- (void)attachString:(NSString *)str toView:(UIView *)targetView;
- (NSMutableArray *)cutMixedString:(NSString *)str;
- (void)changeAudioImg:(NSNotification *)notification;

@end
