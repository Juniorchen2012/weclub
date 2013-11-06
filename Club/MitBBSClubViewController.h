//
//  MitBBSClubViewController.h
//  WeClub
//
//  Created by chao_mit on 13-4-17.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MitBBSClubViewController : UIViewController
{
    int mitType;// 俱乐部分类0 讨论区1 未名俱乐部2
    UIView *categoryView;
}
- (id)initWithMitType:(int)myType;
@end
