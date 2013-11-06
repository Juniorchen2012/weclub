//
//  SettingAboutViewController.h
//  WeClub
//
//  Created by Archer on 13-4-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "StartPageViewController.h"
#import "AboutViewController.h"
#import "ClubViewController.h"

@interface SettingAboutViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
}

@end
