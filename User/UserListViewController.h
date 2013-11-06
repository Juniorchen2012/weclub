//
//  UserListViewController.h
//  WeClub
//
//  Created by Archer on 13-3-16.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoCell.h"
#import "RequestProxy.h"
#import "Header.h"
#import "FriendModel.h"
#import "MMGridView.h"
#import "MMGridViewCell.h"
#import "PersonInfoViewController.h"

@interface UserListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate,MMGridViewDataSource,MMGridViewDelegate>
{
    UITableView *_userTableView;
    MMGridView *_gridView;
    RequestProxy *_rp;
    int _currentType;
    NSString *_nextPageFlag;
    NSMutableArray *_dataArray;
    NSString *_numberID;
    BOOL _loading;
    UIView *_coverLoadingView;
    UIScrollView *pullToScroll;
}

@property (nonatomic,retain) UITableView *userTableView;
@property (nonatomic,retain) UIScrollView *pullToScroll;
@property (nonatomic,assign) int currentType;
@property (nonatomic,retain) NSString *nextPageFlag;
@property (nonatomic,retain) NSMutableArray *dataArray;
@property (nonatomic,assign) BOOL loading;
@property (nonatomic,retain) UIView *coverLoadingView;

- (void)handleUserListNotification:(NSNotification *)notification;
- (void)loadData;
- (void)changeView:(id)sender;

@end
