//
//  SuperUserListViewController.h
//  WeClub
//
//  Created by Archer on 13-4-18.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProxy.h"
#import "UserInfoCell.h"
#import "PersonInfoViewController.h"

@interface SuperUserListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate, MMGridViewDataSource,MMGridViewDelegate>
{
    NSMutableArray *_dataArray;
    UITableView *tableView;
    MMGridView *gridView;
    UIButton *menuBtn;
    RequestProxy *_rp;
    int _currentType;
    NSString *_nextPageFlag;
    NSString *_numberID;
    BOOL _loading;
    NSString *_userName;
    BOOL flag;
    UIScrollView *pullToScroll;
}

@property (nonatomic,retain) NSString *nextPageFlag;
@property (nonatomic,assign) BOOL loading;
@property (nonatomic,retain) NSString *userName;

- (id)initWithNumberID:(NSString *)numberID andType:(int)type;
- (void)loadData;

@end
