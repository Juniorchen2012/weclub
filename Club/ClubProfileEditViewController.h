//
//  ClubProfileEditViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "Club.h"
#import "EditInfoViewController.h"
#import "InviteViewController.h"
#import "refreshDelegate.h"


@interface ClubProfileEditViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DLCImagePickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,RequestProxyDelegate,refreshDelegate>
{
    UITableView *myTable;
    Club *club;
    NSString *name;//俱乐部名称
    NSString *category;//分类
    NSString *desc;//俱乐部描述
    
    UIImageView *logo;
    UIView *bgView;
    UIView *categoryView;
    UIPickerView * categoryPicker;
    NSData *imgData;
    RequestProxy *rp;
    int OPtype;//type为0为创建俱乐部为1为修改俱乐部资料
    int clubType;//俱乐部类型:私密 公开
    int selectedRow;// 分类选择
    BOOL selectedLogo;//是否已经选择了版标
    int registNewClub;//1为注册时创建俱乐部
    UISegmentedControl *segment;
    
}
@property (nonatomic,assign) int adoptFlag;             //是否从领取页面进入
@property (nonatomic,strong) NSString *lastAdopt;
@property (nonatomic,assign) int logoFlag;              //是否有版标
@property (nonatomic,strong) Club *lastAdoptClub;
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL method;
- (id)initWithClub:(Club *)myClub;
- (id)initWithType:(int)myType;
@end
