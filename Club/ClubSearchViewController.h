//
//  ClubSearchViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-4.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "ClubViewController.h"
#import "ClubSearchListViewController.h"
#import "SuperUserListViewController.h"
#import "RequestProxy.h"
#import <AVFoundation/AVFoundation.h>

@interface ClubSearchViewController : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,RequestProxyDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    UISearchBar *mySearchBar;
    UITableView *myTable;
    UISearchDisplayController *mySearchDisplayController;
    NSMutableArray *searchResults;
    NSMutableArray *searchHistoryItems;
    NSString *startKey;
    bool isLoadMore;
    NSMutableArray *list;
    int searchType;//0 club 1 article 2 user
    NSString *qrText;
    RequestProxy *rp;
    UIView *_bgView;
}
- (id)initWithSearchType:(int)myType;
@end
