//
//  ClubSearchListViewController.h
//  WeClub
//
//  Created by chao_mit on 13-4-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClubCell.h"
#import "ClubViewController.h"

@interface ClubSearchListViewController : UIViewController<MMGridViewDataSource, MMGridViewDelegate,RequestProxyDelegate,UITableViewDataSource,UITableViewDelegate>
{
    RequestProxy * rp;
    UITableView *myTable;
    MMGridView *gridView;
    UIScrollView *pullToScroll;
    NSMutableArray *list;
    int isLoadMore;
    NSString *name;
    NSString *startKey;
    int clubToGoNO;
    BOOL flag;
    UIButton *menuBtn;
}
@property(nonatomic,assign)bool isLoadMore;

- (id)initWithSearchName:(NSString *)searchName;

@end
