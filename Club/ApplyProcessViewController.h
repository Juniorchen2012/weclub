//
//  ApplyProcessViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "PersonInfoViewController.h"

@interface ApplyProcessViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate>
{
    UITableView *myTable;
    NSMutableArray *array;
    RequestProxy *rp;
    NSString *startKey;
    bool isLoadMore;
    int operateNO;
    Club *club;
    NSString *clubID;
    int operateType;
    BOOL firstAppear;
}
@property(nonatomic,assign)bool isLoadMore;
- (id)initWithClubID:(NSString *)myclubID;
- (id)initWithClub:(Club *)myClub;
@end
