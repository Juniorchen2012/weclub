//
//  ChangePersonInfoViewController.h
//  WeClub
//
//  Created by Archer on 13-4-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditDescViewController.h"
#import "RequestProxy.h"
#import "ChangePasswordViewController.h"
#import "ChangeEmailViewController.h"

@interface ChangePersonInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DLCImagePickerDelegate,RequestProxyDelegate>
{
    UITableView *_tableView;
    AccountUser *_user;
    UIImageView *_photoView;
    RequestProxy *_rp;
    
    UIImage     *_hdImage;
}

@end
