//
//  ImportFriendViewController.h
//  WeClub
//
//  Created by Archer on 13-5-9.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProxy.h"
#import "ImportFriendCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "TabBarController.h"
#import "PostListViewController.h"
#import "ClubListViewController.h"

@interface ImportFriendViewController : UITableViewController<RequestProxyDelegate>
{
    RequestProxy            *_rp;
    NSMutableArray          *_dataArray;
    NSString                *_nextPageFlag;
    BOOL                     _isLoading;
    
    NSMutableArray          *_importFriendList;    //关注列表
    int                      _importFriendIndex;   //第几个关注的（防止网络延迟造成的重复关注）
}

@property (nonatomic, retain) NSString *nextPageFlag;
@property (nonatomic, assign) BOOL isLoading;

@end
