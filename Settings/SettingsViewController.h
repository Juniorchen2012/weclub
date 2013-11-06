//
//  SettingsViewController.h
//  WeClub
//
//  Created by chao_mit on 13-1-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import "PersonInfoViewController.h"
#import "TDCCardViewController.h"
#import "PersonShowWinViewController.h"
#import "DisplayWinManageViewController.h"
#import "ChatSettingViewController.h"
#import "PublicSettingViewController.h"
#import "SettingAboutViewController.h"
#import "ChangePersonInfoViewController.h"
#import "InformCenterViewController.h"
#import "ChatListSaveProxy.h"
//#import "ZBarSDK.h"


@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,DLCImagePickerDelegate,RequestProxyDelegate,UIAlertViewDelegate>
{
    RequestProxy* rp;
    NSString *qrText;
}
@property (nonatomic, retain)IBOutlet UITableView *myTable;
- (void)logout;
- (void)showInformCenter:(NSNotification *)notification;
@end
