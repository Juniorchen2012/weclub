//
//  ShareSDKManager.m
//  WeClub
//
//  Created by mitbbs on 13-10-28.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ShareSDKManager.h"

@implementation ShareSDKManager

+ (void)shareArticleWithClubName:(NSString *)clubName andContent:(NSString *)articleContent andUserName:(NSString *)userName andRightBarItem:(UIBarButtonItem *)buttonItem andSendShare:(SendShare)sendShare
{
    NSString *content;
    NSString *url;
    UIImage *image;
    content = nil;
    url = nil;
    image = nil;
    SSPublishContentMediaType mediaType = SSPublishContentMediaTypeText;
    content = [NSString stringWithFormat:@"我在玩微俱，阅读%@的帖子,快快加入我们吧，%@",clubName,ITUNES_URL];
    image = [UIImage imageNamed:LOGO_PIC_HOLDER];//默认加版标
    mediaType = SSPublishContentMediaTypeImage;
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"male_holder" ofType:@"png"];
    //}
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                         allowCallback:NO
                                         authViewStyle:SSAuthViewStylePopup
                                          viewDelegate:nil
                               authManagerViewDelegate:nil];
    id<ISSShareOptions> shareViewOptions = [ShareSDK simpleShareOptionsWithTitle:@"内容分享" shareViewDelegate:nil];
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithBarButtonItem:buttonItem arrowDirect:UIPopoverArrowDirectionAny];

    //创建内容
    id<ISSContent> contentObj = [ShareSDK content:articleContent
                   defaultContent:@""
                            image:nil
                            title:[NSString stringWithFormat:@"分享%@的文章",userName]
                              url:@"http://www.sharesdk.com"
                      description:@"这是一条测试信息"
                        mediaType:SSPublishContentMediaTypeText];

    //显示分享选择菜单
    [ShareSDK showShareActionSheet:container
         shareList:[ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiTimeline,ShareTypeRenren ,ShareTypeWeixiSession,ShareTypeGooglePlus,ShareTypeLinkedIn,ShareTypeFacebook,ShareTypeTwitter, nil]
           content:contentObj
     statusBarTips:YES
       authOptions:authOptions
      shareOptions:shareViewOptions
            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                if (state == SSPublishContentStateSuccess)
                {
                    [Utility addShareList:type];
                    NSString *msg = nil;
                    NSString *dest;
                    switch (type)
                    {
                        case ShareTypeAirPrint:
                            msg = @"打印成功";
                            break;
                        case ShareTypeCopy:
                            msg = @"拷贝成功";
                            break;
                        case ShareTypeSinaWeibo:
                            dest = @"新浪微博";
                            break;
                        case ShareTypeTencentWeibo:
                            dest = @"腾讯微博";
                            break;
                        case ShareTypeWeixiTimeline:
                            dest = @"微信朋友圈";
                            break;
                        case ShareTypeRenren:
                            dest = @"人人网";
                            break;
                        case ShareTypeWeixiSession:
                            dest = @"微信";
                            break;
                        case ShareTypeTwitter:
                            dest = @"Twitter";
                            break;
                        case ShareTypeLinkedIn:
                            dest = @"LinkedIn";
                            break;
                        case ShareTypeGooglePlus:
                            dest = @"Google+";
                            break;
                        case ShareTypeFacebook:
                            dest = @"Facebook";
                            break;
                        default:
                            break;
                    }
    //                                    [self sendShare:dest];
                    sendShare(dest);
                  }
                }
            ];
}

+ (void)shareClubWithRightBarItem:(UIBarButtonItem *)buttonItem andSendShare:(SendShare)sendShare
{
    NSString *content;
    NSString *url;
    UIImage *image;
    content = nil;
    url = nil;
    image = nil;
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"male_holder" ofType:@"png"];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStylePopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    id<ISSShareOptions> shareViewOptions = [ShareSDK simpleShareOptionsWithTitle:@"内容分享" shareViewDelegate:nil];
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithBarButtonItem:buttonItem arrowDirect:UIPopoverArrowDirectionAny];
    
    //创建内容
    id<ISSCAttachment> imageAttach = [ShareSDK imageWithPath:imagePath];
    id<ISSContent> contentObj = [ShareSDK content:content
                                   defaultContent:@""
                                            image:[ShareSDK pngImageWithImage:[UIImage imageNamed:@"weclub@2x.png"]]
                                            title:@"微俱"
                                              url:ITUNES_URL
                                      description:@"这是一条测试信息"
                                        mediaType:SSPublishContentMediaTypeNews];
    
    //显示分享选择菜单
    [ShareSDK showShareActionSheet:container
                         shareList:[ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiTimeline,ShareTypeRenren ,ShareTypeWeixiSession,ShareTypeGooglePlus,ShareTypeLinkedIn,ShareTypeFacebook,ShareTypeTwitter, nil]
                           content:contentObj
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:shareViewOptions
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess){
                                    NSString *msg = nil;
                                    NSString *dest;
                                    [Utility addShareList:type];
                                    switch (type){
                                        case ShareTypeAirPrint:
                                            msg = @"打印成功";
                                            break;
                                        case ShareTypeCopy:
                                            msg = @"拷贝成功";
                                            break;
                                        case ShareTypeSinaWeibo:
                                            dest = @"新浪微博";
                                            break;
                                        case ShareTypeTencentWeibo:
                                            dest = @"腾讯微博";
                                            break;
                                        case ShareTypeWeixiTimeline:
                                            dest = @"微信朋友圈";
                                            break;
                                        case ShareTypeRenren:
                                            dest = @"人人网";
                                            break;
                                        case ShareTypeWeixiSession:
                                            dest = @"微信";
                                            break;
                                        case ShareTypeTwitter:
                                            dest = @"Twitter";
                                            break;
                                        case ShareTypeLinkedIn:
                                            dest = @"LinkedIn";
                                            break;
                                        case ShareTypeGooglePlus:
                                            dest = @"Google+";
                                            break;
                                        case ShareTypeFacebook:
                                            dest = @"Facebook";
                                            break;
                                        default:
                                            break;
                                    }
                                    //[self sendShare:dest];
                                    sendShare(dest);
                                }
                            }];
}

+ (void)shareTDCCardWithRightBarItem:(UIBarButtonItem *)buttonItem andTDCHeadImage:(UIImage *)headImage andTDCImage:(UIImage *)tdcImage
{
    NSString *content;
    NSString *url;
    UIImage *image;
    NSMutableArray *shareList;
    NSArray* _shareTypeArray;
    content = nil;
    url = nil;
    image = nil;
    SSPublishContentMediaType mediaType = SSPublishContentMediaTypeText;
    switch (1)
    {
        case 0:
            content = @"haha";
            break;
        case 1:
            content = @"我在玩微俱，阅读%@的帖子,快快加入我们吧，https://itunes.apple.com/cn/app/id348147113?mt=8";
            image = [self addImage:headImage toImage:tdcImage];//默认加版标
            mediaType = SSPublishContentMediaTypeImage;
            break;
        default:
            break;
    }
    
    _shareTypeArray = [NSMutableArray arrayWithObjects:
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"新浪微博",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeSinaWeibo],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"腾讯微博",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeTencentWeibo],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"QQ空间",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeQQSpace],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"人人网",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeRenren],
                        @"type",
                        nil],
                       
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"微信",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeWeixiSession],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"Google+",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeGooglePlus],
                        @"type",
                        nil],
                       
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"LinkedIn",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeLinkedIn],
                        @"type",
                        nil],
                       
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"Facebook",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeFacebook],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"Twitter",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeTwitter],
                        @"type",
                        nil],
                       
                       nil];
    shareList = [[NSMutableArray alloc]init];
    for (int i = 0; i < [_shareTypeArray count]; i++)
    {
        NSDictionary *item = [_shareTypeArray objectAtIndex:i];
        if([[item objectForKey:@"selected"] boolValue])
        {
            [shareList addObject:[NSNumber numberWithInteger:[[item objectForKey:@"type"] integerValue]]];
        }
    }
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"avatarPlaceHolder" ofType:@"png"];
    
    //}
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStylePopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    id<ISSShareOptions> shareViewOptions = [ShareSDK simpleShareOptionsWithTitle:@"内容分享" shareViewDelegate:nil];
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithBarButtonItem:buttonItem arrowDirect:UIPopoverArrowDirectionAny];
    
    //创建内容
    id<ISSContent> contentObj = [ShareSDK content:content
                                   defaultContent:@""
                                            image:[ShareSDK pngImageWithImage:[self addImage:headImage toImage:tdcImage]]
                                            title:@"微俱"
                                              url:ITUNES_URL
                                      description:@"这是一条测试信息"
                                        mediaType:SSPublishContentMediaTypeNews];
    
    //显示分享选择菜单
    [ShareSDK showShareActionSheet:container
                         shareList:[ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiTimeline,ShareTypeRenren ,ShareTypeWeixiSession,ShareTypeGooglePlus,ShareTypeLinkedIn,ShareTypeFacebook,ShareTypeTwitter, nil]
                           content:contentObj
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:shareViewOptions
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    [Utility addShareList:type];
                                    NSString *msg = nil;
                                    NSString *dest;
                                    switch (type)
                                    {
                                        case ShareTypeAirPrint:
                                            msg = @"打印成功";
                                            break;
                                        case ShareTypeCopy:
                                            msg = @"拷贝成功";
                                            break;
                                        case ShareTypeSinaWeibo:
                                            dest = @"新浪微博";
                                            break;
                                        case ShareTypeTencentWeibo:
                                            dest = @"腾讯微博";
                                            break;
                                        case ShareTypeWeixiTimeline:
                                            dest = @"微信朋友圈";
                                            break;
                                        case ShareTypeRenren:
                                            dest = @"人人网";
                                            break;
                                        case ShareTypeWeixiSession:
                                            dest = @"微信";
                                            break;
                                        case ShareTypeLinkedIn:
                                            dest = @"LinkedIn";
                                            break;
                                        default:
                                            break;
                                    }
                                }
                            }];
    
}

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image2.size);
    
    //Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    //Draw image1
    [image1 drawInRect:CGRectMake((image2.size.width-image1.size.width/2)/2, (image2.size.height-image1.size.height/2)/2, image1.size.width/2, image1.size.height/2)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
