//
//  BBSRegisterViewController.h
//  WeClub
//
//  Created by Archer on 13-3-12.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarController.h"
#import "CreateClubViewController.h"
#import "ClubListViewController.h"
#import "RequestProxy.h"
#import "TabBarController.h"
#import "ImportFriendViewController.h"
#import "ChangePasswordViewController.h"
#import "ChangeEmailViewController.h"
#import "AboutViewController.h"
#import "AppDelegate.h"

@interface BBSRegisterViewController : UIViewController<DLCImagePickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,RequestProxyDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UILabel                     *_headerLabel;
    UIScrollView                *_mainScrollView;
    UIImageView                 *_photoView;
    UIImage                     *_headPhoto;
    UITextField                 *_emailTextField;
    UITextField                 *_usernameTextField;
    UITextField                 *_passwordTextField;
    UITextField                 *_passwordAgainTextField;
    UISegmentedControl          *_sexSegment;
    UIView                      *bgView;
    UIView                      *categoryView;
    UIPickerView                * categoryPicker;
    UIPickerView                *_generationPicker;
    int                           selectedRow;// 分类选择

    UIButton                    *_generationButton;
    NSString                    *_generationStr;
    NSArray                     *_generationArray;
    RequestProxy                *_rp;
    int                          _viewControllerType;
    int                          _mailType;
    NSString                    *_other_numberid;
    BOOL                         _keyBoardShow;
    float                        _a;    //键盘弹出时y轴的位移量
    
    NSDictionary                *_mainDic;
    UITableView                 *_tableView;
    UIView                      *_footView;
        
}

- (id)initWithOtherNumberid:(NSString *)other_numberid;
- (void)readingAgreement;
- (void)showAgreement;
- (void)submitInfo;
- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

@end
