//
//  ChangePasswordViewController.h
//  WeClub
//
//  Created by Archer on 13-5-24.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProxy.h"

@interface ChangePasswordViewController : UIViewController<RequestProxyDelegate,UITableViewDataSource,UITableViewDelegate>
{
    RequestProxy *_rp;
    UITextField *_oldPassword;
    UITextField *_newPassword;
    UITextField *_newPasswordAgain;
    NSDictionary *_mainDic;
    
    UITableView *_changePasswordTable;
}

@end
