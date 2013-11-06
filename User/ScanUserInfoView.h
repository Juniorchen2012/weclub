//
//  ScanUserInfoView.h
//  WeClub
//
//  Created by mitbbs on 13-8-13.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSRegisterViewController.h"
#import "LoginViewController.h"
#import "BBSRegisterViewController.h"

@class LoginViewController;
@class BBSRegisterViewController;
@interface ScanUserInfoView : UIView<UIAlertViewDelegate>
{
    NSString                    *_photoID;
    NSString                    *_name;
    NSString                    *_sex;
    NSString                    *_birthday;
    NSString                    *_userId;
    
    UIView                      *_bgView;
    UIView                      *_showView;
}

@property (nonatomic,copy) NSString *scanNumber;
@property (nonatomic,strong) LoginViewController *loginController;
@property (nonatomic,copy) NSString *adoptFlag;
@property (nonatomic,strong) BBSRegisterViewController *BBSController;

- (id)initWithDic:(NSDictionary *)dic;
- (id)initWithBBSUser;

- (void)show;
- (void)BBSUserShow;

@end
