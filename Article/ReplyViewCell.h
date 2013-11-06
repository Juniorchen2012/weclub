//
//  ReplyViewCell.h
//  WeClub
//
//  Created by chao_mit on 13-4-20.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "AudioPlay.h"
#import "PersonInfoViewController.h"


@interface ReplyViewCell : UITableViewCell
{
    UIImageView *avatar;
    UILabel *nameLbl;
    UILabel *postTimeLbl;
    UILabel *distanceLbl;
    
    UIView  *contentView;
    UIView  *refrenceView;
    AudioPlay *myAudioPlay;
    Article *cellArticle;
    UIViewController *vc;
    int _voicePicTag;
    UILabel * replyNOLbl;       //回复数
    UIImageView *playingAudioView;
    NSTimer* timer;
}
@property(nonatomic, retain) UIViewController *vc;//用户头像
-(void)initCellWithArticle:(Article*)article withViewController:(UIViewController *)viewController;
@end
