//
//  ArticleViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "ArticleCell.h"
#import "ClubSearchViewController.h"
#import "PersonInfoViewController.h"
#import "NoticeView.h"

@interface ArticleViewController : UIViewController< UITableViewDelegate, UITableViewDataSource,RequestProxyDelegate>{
    UITableView *myTable;
    
    //处理下拉列表的view
    UILabel *titleLbl;
    UIView *holeView;
    UIView *titleViews;
    UIImageView *titleViewArrow;
    UIButton *titleView;
    
    NSInteger listType;
    NSMutableArray *articleList;//俱乐部列表
    
    NSString *locationInfo;
    
    RequestProxy *rp;
    bool isLoadMore;
    NSString *startKey;
    NSString *postURL;
    VideoPlayer *videoPlay;
    int articleToGo;
    Article *goClubArticle;

    NoticeView *_notice;
}
@property (nonatomic,assign) bool isLoadMore;
@property (nonatomic,assign) int mentionMeFlag;

- (id)init;
- (void)showNoticeView:(NSNotification *)notification;
- (UITableView *)getTable;

@end
