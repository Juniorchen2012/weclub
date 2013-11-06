//
//  AccountConnectViewController.h
//  WeClub
//
//  Created by chao_mit on 13-2-16.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import "Utility.h"
#import <ShareSDK/ShareSDK.h>


@interface AccountConnectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
{
    IBOutlet UITableView *myTable;
    NSArray *itemNames;
    
    UIButton *_btn;
}
@end
