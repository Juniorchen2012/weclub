//
//  LoginViewController.h
//  WeClub
//
//  Created by Archer on 13-3-11.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarController.h"
#import "BBSRegisterViewController.h"
#import "RequestProxy.h"
#import "PostListViewController.h"
#import "ZBarReaderViewController.h"
#import "ImportFriendViewController.h"
#import "ForgetPassViewController.h"
#import "ScanUserInfoView.h"
#import "ZBarManager.h"
#import <AVFoundation/AVFoundation.h>
#import "DLCImagePickerController.h"
@class TabBarController;
@interface LoginViewController : UIViewController<RequestProxyDelegate,UITextFieldDelegate,UIAlertViewDelegate,ZBarReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    UIButton *_loginButton;
    TabBarController *_tabC;
    UITextField *_userNameTextField;
    UITextField *_passwordTextField;
    RequestProxy *_rp;
    NSString *_loginType;
    UILabel *_loginTypeLabel;
    NSString *_scanNumberID;
    
    NSDictionary *_mainDic;
    NSString *_userName;
    NSString *_passWord;
}

- (void)login;
- (void)scanTwoDimensionCode;
- (BOOL)checkUserName;

@end
