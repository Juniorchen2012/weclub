//
//  FriendClubManageViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "Utility.h"
#import "ClubViewController.h"
#import "Request.h"
#import "Header.h"

@interface FriendClubManageViewController : UIViewController<ASIHTTPRequestDelegate,RequestProxyDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    Club *club;
    UIScrollView *myScroll;
    UITextField *clubField;//输入框
    UIButton *addBtn;//添加按钮
    UIView * friendClubView;//友情俱乐部view
    int deleteNO;
    RequestProxy *rp;
    int clubToGoNO;
    Request *request;
    Club *newScanClub;
    UIView * _bgView;
    UIView * _showView;
    NSString *qrText;
}
- (id)initWithClub:(Club *)myClub;
@end
