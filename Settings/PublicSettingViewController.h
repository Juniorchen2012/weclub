//
//  PublicSettingViewController.h
//  WeClub
//
//  Created by Archer on 13-4-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProxy.h"

@interface PublicSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestProxyDelegate,UIAlertViewDelegate>
{
    UITableView *_tableView;
    NSArray *_dataArray;
    int _selectIndex;
    RequestProxy *_rp;
    NSString *_state;
}

- (void)saveSetting;

@end
