//
//  EditDescViewController.h
//  WeClub
//
//  Created by Archer on 13-4-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestProxy.h"
#import "FaceBoard.h"
#import "MLNavigationController.h"


@interface EditDescViewController : UIViewController<RequestProxyDelegate,UITextViewDelegate,UIAlertViewDelegate>
{
    RequestProxy *_rp;
    UITextView *_content;
    FaceBoard *faceBoard;//表情View
    UIButton *keyBoardSwitch;
    
    UILabel *label; //字数label
    UIButton *_cleanBtn;

    NSMutableString *_muStr;
    
    NSArray *array;
}

- (void)saveDesc;

@end
