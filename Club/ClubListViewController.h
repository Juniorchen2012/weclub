//
//  ClubListViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.

#import <UIKit/UIKit.h>
#import "Club.h"
#import "ClubViewController.h"
#import "ClubCell.h"
#import "CreateClubViewController.h"
#import "ClubSearchViewController.h"
#import "MitBBSClubViewController.h"
#import "ClubProfileEditViewController.h"
#import "NoticeView.h"
#import "Request.h"

extern NSString *s;
//俱乐部列表页
@class NoticeView;
@interface ClubListViewController : UIViewController< UITableViewDelegate, UITableViewDataSource, MMGridViewDataSource, MMGridViewDelegate,RequestProxyDelegate>{
    UITableView *myTable;
    MMGridView *gridView;
    
    //处理下拉列表的view
    UILabel *titleLbl;
    UIView *holeView;
    UIView *titleViews;
    UIImageView *titleViewArrow;
    
    NSInteger listType;
    NSMutableArray *clubList;//俱乐部列表
    
    UIScrollView *pullToScroll;
    int userTypeTogo;
    RequestProxy *rp;
    bool isLoadMore;
    NSString *startKey;
    NSString *postURL;
    int clubToGoNO;
    UIView *categoryView;
    BOOL showFlag;//标识是列表还是表格的呈现方式
    int categoryNO;
    NSArray *postURLS;
    BOOL justListFlag;//仅是列表的标志
    BOOL canPressable;//按钮是否可按，当点击后，在验证权限没回来前不能再点击了。
    UIScrollView *myScroll;
    UIButton *menuBtn;
    NoticeView *_notice;
    UIButton *titleView;//标题栏
    Request *request;
}
@property(nonatomic,assign)bool isLoadMore;
- (id)init;
-(void)refresh;
-(void)hideTitleViews;
-(void)newClub;
- (void)registNewClub;
- (void)showNoticeView:(NSNotification *)notification;
- (id)initWithType:(BOOL)flag andType:(int)type;
- (UITableView *)getTableView;                  //得到tableView
- (UIScrollView *)getScrollView;
@end
