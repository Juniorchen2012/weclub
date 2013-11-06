//
//  TopicArticleCell.h
//  WeClub
//
//  Created by chao_mit on 13-1-22.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "AudioPlayer.h"
#import "Article.h"
#import "VideoPlayer.h"
#import "AudioPlay.h"
#import "ClubViewController.h"
#import "PersonInfoViewController.h"
#import "TopicArticleListViewController.h"

@interface ArticleCell : UITableViewCell<MWPhotoBrowserDelegate>
{
    UIImageView *avatar;        //用户头像
    UILabel *nameLbl;           //用户名字
    UILabel *postTimeLbl;       //发表时间
    UILabel *distanceLbl;       //距离
    UILabel *content;           //文章内容
    UILabel *replyCountLbl;     //回复数
    UILabel *browseCountLbl;    //浏览数
    UILabel *collectCountLbl;   //收藏数
    UILabel *shareCountLbl;     //分享数
    UILabel *postClubLbl;       //发文的俱乐部
    UIView  *mediaView;         //展示窗口
    UIImageView *browseIcon;    //浏览数图标
    UIImageView *replyIcon;     //回复数图标
    UIImageView *shareIcon;     //分享数图标
    UIImageView *collectIcon;   //收藏数图标
    
    
    UIView *topView;
    UIView *bottomView;
    
    int articleStyle;//发文类型:文字为主0，图片为主1，音频为主2，视频为主3
    CGFloat meidaHeight;
    
    UILabel *currentTimeLbl;
    UIButton *playBtn;
    UISlider *progressSlider;
    Article *cellArticle;

    UIView *replyView;
    VideoPlayer *videoPlay;
    UIView *iconsView;
    AudioPlay *myAudioPlay;
    UIViewController *vc;
    UIButton *postClubBtn;//所在发文俱乐部的图标
    NSMutableArray *imgArray;
    NSMutableArray *photos;
    NSMutableArray *audioLblArray;
    
    BOOL isForPersonInfoPage;
}
//@property(nonatomic, retain) UIImageView *avatar;//用户头像
@property(nonatomic, retain) UIViewController *vc;//用户头像
@property(nonatomic, retain) UILabel *postClubLbl;//俱乐部标签
@property(nonatomic, retain) UIButton *postClubBtn;//俱乐部标签

//@property(nonatomic, retain) UIView *mediaView;//展示窗口
@property(nonatomic, assign) bool isDigest;//用于区别是否是精华区的文章
- (id)initForPersonInfo;
-(void)changeByStyle:(NSString *)articleStyle;
-(void)initCellWithArticle:(Article*)article withViewController:(UIViewController *)viewController;@end
