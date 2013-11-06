//
//  FriendModel.h
//  WeClub
//
//  Created by Archer on 13-3-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendModel : NSObject
{
    NSString *friendID;
    NSString *photo;
    NSString *name;
    NSString *lastMsg;
    NSString *sex;
    NSString *masterID;
}

@property (nonatomic, retain) NSString * friendID;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * lastMsg;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString *masterID;

@end
