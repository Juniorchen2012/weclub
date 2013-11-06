//
//  AccountUser.h
//  WeClub
//
//  Created by chao_mit on 13-2-20.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "User.h"

@interface AccountUser:User<CLLocationManagerDelegate>
{
    NSHTTPCookie *_cookie;
    NSString *locationInfo;
    double userLongitude;
    double userLatitude;
    NSString *loginFlag;
    NSString *adoptFlag;
    NSString *private_letter;
    NSString *public_setting;
    NSMutableArray *userAttachments;
    BOOL MQTTconnected;
    CLLocationManager *locManager;
    int netWorkStatus;
    BOOL isLogin;
}

@property (nonatomic, retain) NSHTTPCookie *cookie;
@property (nonatomic, retain)NSString *locationInfo;
@property (nonatomic, assign)double userLongitude;
@property (nonatomic, assign)double userLatitude;
@property (nonatomic, retain)NSString *loginFlag;
@property (nonatomic, retain)NSString *adoptFlag;
@property (nonatomic, retain)NSString *private_letter;
@property (nonatomic, retain)NSString *public_setting;
@property (nonatomic, retain)NSMutableArray *userAttachments;
@property (nonatomic, assign)BOOL MQTTconnected;
@property (nonatomic, assign)int netWorkStatus;
@property (nonatomic, assign)BOOL isLogin;
+(AccountUser*)getSingleton;
- (void)clearUserInfo;
-(void)locate;
- (BOOL)userLogin;
- (BOOL)userLogout;

@end
