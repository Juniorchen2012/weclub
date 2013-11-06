//
//  ShareSDKManager.h
//  WeClub
//
//  Created by mitbbs on 13-10-28.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

typedef void (^SendShare)(NSString *destination);
typedef UIImage (^ShareHeadImage)(UIImage *headImage,UIImage *tdcImage);

@interface ShareSDKManager : NSObject

+ (void)shareArticleWithClubName:(NSString *)clubName andContent:(NSString *)articleContent andUserName:(NSString *)userName andRightBarItem:(UIBarButtonItem *)buttonItem andSendShare:(SendShare)sendShare;

+ (void)shareClubWithRightBarItem:(UIBarButtonItem *)buttonItem andSendShare:(SendShare)sendShare;

+ (void)shareTDCCardWithRightBarItem:(UIBarButtonItem *)buttonItem andTDCHeadImage:(UIImage *)headImage andTDCImage:(UIImage *)tdcImage;

@end
