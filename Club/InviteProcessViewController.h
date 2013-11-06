//
//  InviteProcessViewController.h
//  WeClub
//
//  Created by chao_mit on 13-5-14.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteProcessViewController : UITableViewController<RequestProxyDelegate>
{
    NSMutableArray *list;
    RequestProxy *rp;
    bool isLoadMore;
    NSString *startKey;
    NSArray *postURL;
    int operateNO;
    int operateType;

}
@property(nonatomic,assign)bool isLoadMore;
@end
