//
//  ResetPassViewController.h
//  WeClub
//
//  Created by chao_mit on 13-6-5.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPassViewController : UIViewController<RequestProxyDelegate>{
    RequestProxy *rp;
    UITextField *checkCodeTxt;
    UITextField *newPassTxt;
    UITextField *confirmPassTxt;
}
@property (nonatomic, retain)NSString *email;
@end
