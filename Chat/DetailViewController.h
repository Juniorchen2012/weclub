//
//  DetailViewController.h
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionPublishDataDelegate.h"
#import "JSONKit.h"
#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "ChatInputView.h"
#import <AVFoundation/AVFoundation.h>
#import "ChatFriend.h"
#import "ChatListSaveProxy.h"
#import "RequestProxy.h"
#import "MBProgressHUD.h"
#import "ChatMessageProxy.h"


@interface DetailViewController : UIViewController<UIBubbleTableViewDataSource,ChatInputViewDelegate,RequestProxyDelegate,UIAlertViewDelegate>
{
    id<SessionPublishDataDelegate> _delegate;
        
    UIBubbleTableView *bubbleView;
    NSMutableArray *bubbleData;
    NSArray *bubbleSourceData;
    NSInteger indexPage;
    ChatInputView *chatInput;
    
    BOOL followKeyBoard;
    //加载在bubbleView之上用于收起键盘
    UIButton *coverButton;
    
    ChatFriend *_currentFriend;
    //网络请求代理
    RequestProxy *_rp;
    BOOL _authority;
    
    //右上角目录按钮
    UIControl *holeView;
    UIView *titleViews;
    NSMutableArray *_menuItemArray;
    UIButton *friendInfoBtn;
    UIButton *cleanChatDetailBtn;
    
    
}

@property (nonatomic,retain) id<SessionPublishDataDelegate> delegate;
@property (nonatomic,retain) ChatFriend *currentFriend;
@property (nonatomic,assign) BOOL followKeyBoard;
@property (nonatomic,retain) UIButton *coverButton;
@property (nonatomic, retain) UIBubbleTableView *bubbleView;

//自定义的初始化方法，传入的参数f是当前聊天的好友
- (id)initWithChatFriend:(ChatFriend *)f;
//单步增加聊天记录，只有文字
- (void)addChatDetailText:(NSDictionary *)chatDetail;
//单步增加聊天记录，文字和多媒体内容
- (void)addChatDetailTextAndData:(NSDictionary *)chatDetail;
//收起键盘
- (void)hideKeyBoard;
//导航帮助
- (void)pushView:(NSNotification *)notification;
//生成保存路径
- (NSString *)createSavePath:(NSString *)suffix;

-(void)showChatUserInfo:(id)user;

-(BOOL)isConnect;

@end
