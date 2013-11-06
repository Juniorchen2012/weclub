//
//  ForgetPassViewController.h
//  WeClub
//
//  Created by chao_mit on 13-5-28.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResetPassViewController.h"

@interface ForgetPassViewController : UIViewController<RequestProxyDelegate>{
    RequestProxy *rp;
    UITextField *emailTxt;
    //UIButton *submit;
}
@end
