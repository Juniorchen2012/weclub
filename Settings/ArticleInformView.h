//
//  ArticleInformView.h
//  WeClub
//
//  Created by Archer on 13-4-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProxy.h"
#import "Utility.h"
#import "ArticleDetailViewController.h"
#import "SVPullToRefresh.h"
#import "AtricleInformCell.h"

@interface ArticleInformView : UIView<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate>
{
    UITableView *_tableView;
    RequestProxy *_rp;
    NSMutableArray *_dataArray;
    NSString *_lastFlag;
    
    int                  _flag;    //限制不能同时上拉和下滑
}

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) RequestProxy *rp;
@property (nonatomic,strong) UITableView *tableView;

- (void)requestData;
- (void)start;
- (void)clearNotice;
- (void)delPopDigest;

@end
