//
//  ClubUpgradeViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-5.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "Club.h"
#import "Request.h"

@interface ClubUpgradeViewController : UIViewController<UITextFieldDelegate,ASIHTTPRequestDelegate,RequestProxyDelegate>
{
    Club *club;
    RequestProxy *rp;
    UILabel * infoLbl;
    UIView *borderView;
    Request *request;
}
@property (nonatomic, retain) Club *club;
- (id)initWithClub:(Club *)myClub;
@end
