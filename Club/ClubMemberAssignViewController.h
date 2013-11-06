//
//  ClubMemberAssignViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-7.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "PersonInfoViewController.h"
#import "Request.h"

@interface ClubMemberAssignViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate,UITextFieldDelegate,refreshDelegate>{
    UITableView *myTable;
    Club *club;
    
    UITextField *adminTxt;
    UITextField *viceAdminTxt;
    UITextField *honorMemTxt;
    
    UIButton *adminChangeBtn;
    UIImageView *adminLogo;
    
    UIButton *viceAddBtn;
    UIButton *honorMemAddBtn;
    
    UIView *viceAdminView;
    UIView *honorMemView;
    
    NSMutableArray *honorMemberList;
    RequestProxy *rp;
    NSString *operateType;
    bool isLoadMore;
    int toDelete;
    NSString *rowKey;
    UITextField *currentTextField;
    BOOL deleteFlag;//标志是删除的标志，因为指定和删除用的是同一接口
    NSString *selectName;
    Request *request;
}
@property(nonatomic,assign)bool isLoadMore;
- (id)initWithClub:(Club *)myClub;
@end
