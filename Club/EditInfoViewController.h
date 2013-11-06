//
//  EditInfoViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "refreshDelegate.h"
#import "FaceBoard.h"


@interface EditInfoViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{
    UITextField *txtFiled;
    UITextView *myTV;
    Club *club;
    int style;//为0只显示txtFiled，为1只显示myTV
    NSString *str;//传入的字符串
    FaceBoard *faceBoard;//表情View
    UIButton *keyBoardSwitch;
    UILabel *leftCountLbl;//剩余字数
    id<refreshDelegate>             refreshDel;
}
@property (nonatomic, assign)int style;
@property (nonatomic, copy)NSString *str;
@property(nonatomic, retain)id<refreshDelegate>refreshDel;

@end
