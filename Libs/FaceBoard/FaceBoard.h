//
//  FaceBoard.h
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import <UIKit/UIKit.h>
#import "FaceButton.h"
#import "GrayPageControl.h"
#import "ZDPageControll.h"

#define FACE_BUTTON_NUM 85

@protocol FaceBoardDelegate <NSObject>
//发送文字消息
- (void)sendText;
@end

@interface FaceBoard : UIView<UIScrollViewDelegate>{
    UIScrollView *faceView;
    ZDPageControll *facePageControl;
    NSDictionary *_faceMap;
    int count;//为了在文字中间添加表情而设定的变量，标识光标到最后一个字符的个数
    int backButtonNum;
    UIButton *sendButton;
    UILabel *sendLabel;
    UIView<FaceBoardDelegate> *_delegate;
}
@property (nonatomic,strong) UIView<FaceBoardDelegate> *delegate;
@property (nonatomic, retain) UITextField *inputTextField;
@property (nonatomic, retain) UITextView *inputTextView;
@property (nonatomic, assign) int count;

- (id)initWithIsShowSendButton:(BOOL)isShowSendButton;

@end
