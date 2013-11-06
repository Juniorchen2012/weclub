//
//  PostListViewController.h
//  WeClub
//
//  Created by chao_mit on 13-2-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "refreshDelegate.h"
#import "CreateClubViewController.h"
#import "Header.h"
#import "TabBarController.h"
#import "Club.h"
#import "ClubListViewController.h"

@interface PostListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    NSString *selectedStrng;
    NSMutableArray *list;
    bool isLoadMore;
    NSString *startKey;
    RequestProxy *rp;
    int adoptNum;
    UITextField *inputField;
    NSMutableArray *searchResults;
    NSString *searchTxt;
    UIPlaceHolderTextView *myTV;
    NSMutableArray *nameList;
    NSMutableArray *searchPersons;//筛选除出来的我关注的人
    id<refreshDelegate>             refreshDel;
    int                             listType;//@0 #1 领取俱乐部2    
    BOOL                            flag;//俱乐部是否领取完了
    
    NSArray                         *_dicList;  //领取俱乐部列表
    BOOL firstAppear;
}
@property (nonatomic,retain) IBOutlet UITableView *myTable;
@property(nonatomic, assign)int listType;
@property(nonatomic, retain)NSString *selectedString;
@property(nonatomic, retain)id<refreshDelegate>refreshDel;
@property(nonatomic,assign)bool isLoadMore;
- (id)initWithType:(int)myType;
-(void)initView;
@end
