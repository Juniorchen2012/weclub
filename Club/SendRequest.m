//
//  SendRequest.m
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "SendRequest.h"

@implementation SendRequest
/*
 */
//暂时只用于同步，用于异步的话，要把返回值改为ASIFormDataRequest *

/*
 ASIHttpReques错误基本是3种
 在getError中可以将asiRequest.erro打印出来
 网络超时:默认15秒
 新浪超时:

*/
+(NSString*)sendRequestWithURL:(NSString*)postURLString WithpostData:(NSDictionary*)postDic{
//    if (![Utility checkNetWork]) {
//        return nil;
//    }
//    [SVProgressHUD showWithStatus:@"稍等..." maskType:SVProgressHUDMaskTypeClear];
    ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:URL(postURLString)];
    NSString *postdata = [postDic JSONString];
    NSLog(@"postdata:%@",postdata);
    [asiRequest setPostValue:postdata forKey:@"data"];
    [asiRequest buildRequestHeaders];
    asiRequest.delegate = self;
    [asiRequest setDidFailSelector:@selector(getError:)];
    [asiRequest startSynchronous];//在这不能使用perform因为使用perform就会先执行下边的代码
    NSLog(@"requestError%@",asiRequest.error);
    NSLog(@"gotrequest error%@",[asiRequest.error.userInfo objectForKey:@"NSLocalizedDescription"]
);

    if (asiRequest.error) {
        NSLog(@"requestError%@",asiRequest.error);
        [SVProgressHUD dismissWithError:[asiRequest.error.userInfo objectForKey:@"NSLocalizedDescription"]
         ];
    }else{
        NSString *gotString = [asiRequest responseString];
        NSLog(@"got data%@",gotString);
        NSDictionary *gotDic = [gotString objectFromJSONString];
        [Utility printDic:gotDic];

//        [Utility MsgBox:gotString];
        return gotString;
    }
    return nil;
}

+(ASIFormDataRequest*)sendRequest:(NSString*)postURLString WithpostData:(NSDictionary*)postDic{
//    if (![Utility checkNetWork]) {
//        return nil;
//    }
    //    [SVProgressHUD showWithStatus:@"稍等..." maskType:SVProgressHUDMaskTypeClear];
    ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:postURLString]];
    NSString *postdata = [postDic JSONString];
    NSLog(@"postdata:%@",postdata);
    [asiRequest setPostValue:postdata forKey:@"data"];
    [asiRequest setDidFailSelector:@selector(getError:)];
//    asiRequest.delegate = self;
    return asiRequest;
}

+(void)printRequestError:(ASIFormDataRequest*)request{
    [SVProgressHUD dismiss];
    [Utility showHUD:[request.error.userInfo objectForKey:@"NSLocalizedDescription"]];
    NSLog(@"requestError%@",request.error);
}
@end
