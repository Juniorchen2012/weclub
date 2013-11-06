//
//  AccountUser.m
//  WeClub
//
//  Created by chao_mit on 13-2-20.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "AccountUser.h"

@implementation AccountUser
@synthesize locationInfo,userLatitude,userLongitude,loginFlag,adoptFlag,private_letter,public_setting,userAttachments,MQTTconnected,netWorkStatus;
static AccountUser *myaccountUser = nil;

@synthesize cookie = _cookie;

+(AccountUser *)getSingleton{

    @synchronized (self){//为了确保多线程情况下，仍然确保实体的唯一性
        
        if (!myAccountUser) {
            
            myAccountUser = [[self alloc] init];//非ARC模式下,该方法会调用 allocWithZone
        }
        return myAccountUser;
    }
}



+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        
        if (!myAccountUser) {
            
            myAccountUser = [super allocWithZone:zone]; //确保使用同一块内存地址
            
            return myAccountUser;
            
        }
        
        return nil;
    }
}

- (id)init;
{
    @synchronized(self) {
        
        if (self = [super init]){
            name = @"chao";
            userID = @"1";
            locationInfo = @"0.01,0.01";
            netWorkStatus = 0;
            isLogin = NO;
            return self;
        }
        
        return nil;
    }
}

- (id)copyWithZone:(NSZone *)zone;{
    
    return self; //确保copy对象也是唯一
    
}

- (void)clearUserInfo
{
    [super clearUserInfo];
    _cookie = nil;
    loginFlag = nil;
    adoptFlag = nil;
    private_letter = nil;
    public_setting = nil;
    userAttachments = nil;
}

-(void)locate{
    locManager = [[CLLocationManager alloc]init];
    locManager.delegate =self;
    locManager.desiredAccuracy = kCLLocationAccuracyBest;
    locManager.distanceFilter = 5.0;
    [locManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    AccountUser *myAccountUser = [AccountUser getSingleton];
    myAccountUser.userLatitude = newLocation.coordinate.latitude;
    myAccountUser.userLongitude = newLocation.coordinate.longitude;
    myAccountUser.locationInfo = [[NSString stringWithFormat:@"%f,%f",newLocation.coordinate.longitude, newLocation.coordinate.latitude] copy];
    [[NSUserDefaults standardUserDefaults]setObject:@"1"forKey:LOCATABLE];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"Locationerror%@",error.description);
    if (1 == error.code) {
            [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:LOCATABLE];
    }
}
- (BOOL)userLogin
{
    if (isLogin == NO) {
        isLogin = YES;
        return YES;
    }
    return NO;
}

- (BOOL)userLogout
{
    if (isLogin == YES) {
        isLogin = NO;
        return YES;
    }
    return NO;
}

@end

