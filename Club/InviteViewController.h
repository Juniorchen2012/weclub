//
//  InviteViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonInfoViewController.h"
#import "Club.h"

@interface InviteViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate>{
    UITableView *myTable;
    NSMutableArray *list;//邀请人员列表,还要判断他是否已在这个俱乐部中
    NSMutableArray *selectedList;//选中人员列表
    RequestProxy *rp;
    NSString *startKey;
    bool isLoadMore;
    UIButton *selectBtn;
    int inviteNO;
    Club *club;
    UIButton *leftbtn;
    BOOL isPushFromNewClub;//是否是从创建俱乐部跳转来的
    BOOL firstAppear;
}
@property(nonatomic,assign)bool isLoadMore;
@property(nonatomic,assign)BOOL isPushFromNewClub;
- (id)initWithClub:(Club *)myClub;

@end
