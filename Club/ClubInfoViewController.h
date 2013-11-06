//
//  ClubInfoViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-11.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "QRCodeGenerator.h"
#import "Header.h"
#import "Club.h"
#import "ClubViewController.h"
#import "ListViewController.h"
#import "ClubUpgradeViewController.h"
#import "FriendClubManageViewController.h"
#import "ClubProfileEditViewController.h"
#import "ClubMemberAssignViewController.h"
#import "DisplayWinManageViewController.h"
#import "TDCCardViewController.h"
#import "ReportManageViewController.h"
#import "InviteViewController.h"
#import "ApplyProcessViewController.h"
#import "AudioPlay.h"
#import "VideoPlayer.h"
#import "MLTableView.h"
#import "Request.h"

@class Club;
@interface ClubInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,EGOImageButtonDelegate,AVAudioPlayerDelegate,MWPhotoBrowserDelegate,UIActionSheetDelegate,RequestProxyDelegate>
{
    UIScrollView *myScroll;
    UIView *_displayView;
    UIImageView *bg;
    
    UIImageView *_logo;
    UILabel *_nameLbl;
    UILabel *_descLbl;
    UILabel *_distanceLbl;
    UILabel *memberCountLbl;
    UILabel *topicCountLbl;
    UILabel *shareCountLbl;
    UILabel *followCountLbl;
    UILabel *clubIDLbl;
    UISegmentedControl *_segment;
    
    MLTableView *myTable;
    Club *club;
    MPMoviePlayerController *movie;
    UINavigationController *NAV;
    
    UIView *_friendClubHint;
    UIView * friendClubView;//友情俱乐部view
    UILabel *friendClubLbl;
    NSMutableArray *photos;
    NSString *startKey;
    NSMutableArray *friendList;
    RequestProxy *rp;
    bool isLoadMore;
    NSMutableArray *imgArray;
    AudioPlay *audioPlay;
    VideoPlayer *videoPlay;
    int friendclubToGoNO;
    NSString *clubRowKey;
    Request *request;
    NSInteger actionsheetBtnIndex;
    BOOL isFromScan;
    
}
- (id)initWithClubRowKey:(NSString *)myClubRowKey;
@property (nonatomic,assign)bool isLoadMore;
@property (nonatomic,assign)BOOL isFromScan;
@property (nonatomic, retain) Club *club;
@end