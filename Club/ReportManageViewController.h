//
//  ReportManageViewController.h
//  WeClub
//
//  Created by chao_mit on 13-4-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleDetailViewController.h"
#import "FPPopoverController.h"
#import "PersonInfoViewController.h"
#import "ListNameTableView.h"
#import "Club.h"

@interface ReportManageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate,UIActionSheetDelegate,FPPopoverControllerDelegate>
{
    NSString *clubID;
    int listType;//0已审批 1未审评 2已拒绝
    NSMutableArray * list;//举报列表
    UITableView *myTable;
    RequestProxy *rp;
    NSString *startKey;
    bool isLoadMore;
    NSMutableArray *selectedList;//选中
    FPPopoverController *_popOverMenu;
    UIImageView *titleViewArrow;
    UILabel *titleLbl;
    UIButton *menuBtn;
    NSIndexPath *deleteNO;
    Club *myclub;
    
    //处理下拉列表的view
    UIView *holeView;
    UIView *titleViews;
    BOOL firstAppear;
}
@property(nonatomic,assign)bool isLoadMore;
- (id)initWithClubID:(NSString *)myClubID;
@end
