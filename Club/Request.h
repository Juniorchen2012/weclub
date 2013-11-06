//
//  Request.h
//  WeClub
//
//  Created by mitbbs on 13-8-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject{
        RequestProxy *rp;
}
-(void)getUserType:(NSString *)clubID withDelegate:(id)delegate;
-(void)getBaseInfo:(NSString *)clubID withDelegate:(id)delegate;
-(void)getBaseInfoByName:(NSString *)clubName withDelegate:(id)delegate;
-(void)getModerator:(NSString *)clubID withDelegate:(id)delegate;
-(void)getDisplayWindows:(NSString *)clubID withDelegate:(id)delegate;
-(void)getFriendClub:(NSString *)clubID withStartKeystring:(NSString *)startkey withDelegate:(id)delegate;
-(void)addCoin;
-(void)cancelRequest;
-(void)checkMoneyWithDelegate:(id)delegate;
@end
