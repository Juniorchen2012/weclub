//
//  ClubInfoViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-11.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"//Club Model

#import "Article.h"//Article Model
#import "ArticleCell.h"
#import "ClubInfoViewController.h"
#import "ArticleDetailViewController.h"
#import "PostArticleViewController.h"
#import "PersonInfoViewController.h"
#import "amrFileCodec.h"
#import "AudioPlay.h"
#import "MLTableView.h"
#import "ClubProfileEditViewController.h"
#import "MLTableView.h"
#import "Request.h"
#import "PostArticleViewController.h"


//俱乐部页
@interface ClubViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate,AVAudioPlayerDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,MWPhotoBrowserDelegate,RequestProxyDelegate,EGOImageButtonDelegate,refreshDelegate>{
    Club *club;
    
    UILabel *titleLbl;
    MLScrollView *diplayScroll;
    UIView *infoView;
    UITableView *myTable;
    UIView *toolBar;//工具栏
    UIImageView *logo;//版标
    UILabel *_nameLbl;//俱乐部名字
    UILabel *descLbl;//俱乐部描述
    UIView  *starLevelView;//星级
    UILabel *distanceLbl;//距离
    UIView *displayView;//展示窗口
    UIImageView *bg;
    
    UILabel *categoryLbl;//分类
    UILabel *memberCountLbl;//会员数
    UILabel *topicCountLbl;//主题数
    UILabel *followCountLbl;//关注数
    UILabel *adminLbl;//版主
    UILabel *viceAdminsLbl;//版副
    UIButton *banMianBtn;//版面
    UIButton *goodArticleBtn;//精华
    UIView *headerView;//tableview_tableHeaderView
    NSString *postURLStr;
    UIView *listSwitchView;
    UIButton *editBtn;
    UILabel *editLbl;
    int todelete;//要删除文章的序号

    NSMutableArray *articlelist;//文章列表
    NSMutableArray *stickArticleList;//置顶文章列表
    
    MPMoviePlayerController *movie;
    AVAudioPlayer *newPlayer;
    int listType;//当前列表类型 版面／精华区
    int operationType;
    NSMutableArray *photos;
    NSString *mediaPath;
    int mediaNO;//当前播放的mediaNO
    NSString *startKey_ban;
    NSString *startKey_digest;
    bool isLoadMore;
    RequestProxy *rp;
    NSMutableArray *imgArray;
    NSMutableArray *toDeleteList;//要删除的文章数组
    int articleToGo;
    AudioPlay *audioPlay;
    VideoPlayer *videoPlay;
    UIButton *deleteBtn;
    BOOL isPushFromNewClub;//是否是从创建俱乐部跳转来的
    Request *request;
//    PostArticleViewController *postArticleView;
}
@property(nonatomic,assign)BOOL isPushFromNewClub;
@property(nonatomic,assign)bool isLoadMore;
@property(nonatomic, retain) Club *club;
@property(nonatomic, retain) UITableView *myTable;
@end