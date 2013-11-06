//
//  InformCenterViewController.h
//  WeClub
//
//  Created by Archer on 13-4-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClubInformView.h"
#import "ArticleInformView.h"
#import "UserInformView.h"

@interface InformCenterViewController : UIViewController<UIScrollViewDelegate,UIAlertViewDelegate>
{
    UIButton *_clubButton;
    UIButton *_articleButton;
    UIButton *_userButton;
    UIImageView *_slideView;
    ClubInformView *_clubInform;
    ArticleInformView *_articleInform;
    UserInformView *_userInform;
    int _currentIndex;
    UIButton *_cleanBtn;
    UIScrollView    *_scrollView;
}

@property (nonatomic,strong) ClubInformView *clubInform;
@property (nonatomic,copy) NSString *noticeType;

- (void)segmentChanged:(id)sender;
- (void)checkAppearTable;


@end
