//
//  TDCCardViewController.h
//  WeClub
//
//  Created by Archer on 13-4-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeGenerator.h"
#import "ZBarSDK.h"
#import <ShareSDK/ShareSDK.h>
#import "PersonInfoViewController.h"
#import "ClubInfoViewController.h"
#import "ZBarManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ShareSDKManager.h"


@interface TDCCardViewController : UIViewController<UIActionSheetDelegate,AVCaptureMetadataOutputObjectsDelegate>{
    UIImageView *tdcView;
    UIImageView *tdcHeadView;
    
    BOOL bIsCurrentUser;
    NSString *_strUserName;
    NSString *_strUserID;
    NSString *_strPhotoID;
    NSString *_strSex;
    
    NSString *qrText;
    BOOL isPerson;//isPerson1 or isClub0
    Club *club;
}

@property (nonatomic, retain) IBOutlet NSString *_strUserName;
@property (nonatomic, retain) IBOutlet NSString *_strUserID;
@property (nonatomic, retain) IBOutlet NSString *_strPhotoID;
@property (nonatomic, retain) IBOutlet NSString *_strSex;
@property (nonatomic) BOOL bIsCurrentUser;
@property (nonatomic)BOOL isPerson;
@property (nonatomic, retain)Club *club;



@end
