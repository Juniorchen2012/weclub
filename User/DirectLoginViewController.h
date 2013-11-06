//
//  DirectLoginViewController.h
//  WeClub
//
//  Created by mitbbs on 13-10-8.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarController.h"
#import "RequestProxy.h"


@interface DirectLoginViewController : UIViewController<RequestProxyDelegate,UIAlertViewDelegate>
{
    RequestProxy            *_rp;
}

@end
