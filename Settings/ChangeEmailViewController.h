//
//  ChangeEmailViewController.h
//  WeClub
//
//  Created by Archer on 13-5-24.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProxy.h"
#import "AccountUser.h"

@interface ChangeEmailViewController : UIViewController<RequestProxyDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    RequestProxy *_rp;
    NSDictionary *_mainDic;
    
    UITextField *_password;
    UITextField *_email;
    
    UITableView *_changeEmailTable;
}

@end
