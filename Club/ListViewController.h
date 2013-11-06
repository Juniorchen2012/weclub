//
//  ListViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-28.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonInfoViewController.h"
#import "Club.h"
#import "ClubCell.h"
#import "refreshDelegate.h"
#import "MLTableView.h"

@interface ListViewController : UIViewController<RequestProxyDelegate,UISearchBarDelegate,UISearchDisplayDelegate, MMGridViewDataSource, MMGridViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    UIButton *menuBtn;
    NSMutableArray *list;
    NSMutableArray *tmpList;//缓存列表
    Club *club;
    RequestProxy *rp;
    bool isLoadMore;
    NSString *startKey;
    int listType;//0会员.1关注2加入的俱乐部3关注的俱乐部
    NSArray *postURL;
    NSIndexPath *deleteNO;
    NSString *userRowKey;
    int clubToGoNO;
    NSString *userName;
    bool usedForMemberAssign;//用来指定俱乐部成员
    
    UISearchBar *mySearchBar;
    UITableView *myTable;
    UISearchDisplayController *mySearchDisplayController;
    NSMutableArray *searchResults;
    
    MMGridView *gridView;
    UITableView *_tableView;
    BOOL flag;
    id<refreshDelegate>             refreshDel;
    
    UIScrollView *pullToScroll;
    BOOL firstAppear;
}
@property(nonatomic, retain) Club *club;
@property(nonatomic, retain)NSIndexPath *deleteNO;
@property(nonatomic, assign) int listType;
@property(nonatomic,assign)bool isLoadMore;
@property(nonatomic, retain)id<refreshDelegate>refreshDel;
@property(nonatomic,assign)bool usedForMemberAssign;
- (id)initWithUserRowKey:(NSString*)myUserRowKey withType:(int)myType withName:(NSString *)myUserName;
@property (nonatomic, retain) NSString *userName;
@end
