//
//  CreateClubViewController.h
//  WeClub
//
//  Created by chao_mit on 13-2-25.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "AboutViewController.h"


@interface CreateClubViewController : UIViewController<ASIHTTPRequestDelegate,UITextFieldDelegate,UITextViewDelegate,DLCImagePickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate,RequestProxyDelegate>
{
    UIPlaceHolderTextView *myTV;
    UITextField *clubNameField;
    
    UIImageView *logo;
    UIButton *categoryBtn;
    UIPickerView * categoryPicker;
    UIView *categoryView;
    UIView *bgView;
        
    UIButton *privateTypeBtn;
    UIButton *publicTypeBtn;
    
    int clubType;
    NSMutableString *categoryToSend;
    int clubNumID;
    NSString *categoryName;
    RequestProxy *rp;
    NSDictionary *adoptDic;//认领俱乐部的adoptDic
    int opType;//0创建俱乐部 1认领俱乐部
}
- (id)initWithType:(int)myType andAdoptClubDic:(NSDictionary *)myAdoptDic;
@end
