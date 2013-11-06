//
//  UIBubbleTableView.h
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>

#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableViewCell.h"
#import "Utility.h"

@interface UIBubbleTableView : UITableView <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    IBOutlet UIBubbleTableViewCell *bubbleCell;
    NSString *_photoID;
    ChatFriend *_chatFriend;
    UIViewController * viewController;
    //记录当前窗口显示的音频中未播放的新音频数
    NSMutableDictionary *_unreadVoiceDic;
    int _numUnreadVoice;
    NSMutableDictionary *_tableViewHideCell;
}

@property (nonatomic, assign) id<UIBubbleTableViewDataSource> bubbleDataSource;
@property (nonatomic) NSTimeInterval snapInterval;
@property(nonatomic, assign)id navDelegate;
@property (nonatomic, assign) NSMutableDictionary *unreadVoiceDic;
@property (nonatomic, assign) int numUnreadVoice;
@property (nonatomic, retain) NSString *strOpenURL;
@property (nonatomic, strong) NSMutableDictionary *tableViewHideCell;

- (id)initWithFrame:(CGRect)frame andSomeOnePhoto:(NSString *)photo viewController:(UIViewController *) controller;
- (id)initWithFrame:(CGRect)frame andSomeOne:(ChatFriend *)chatFriend viewController:(UIViewController *) controller;
- (void) refreshMove:(BOOL)flag cleanData:(BOOL)clean;
- (void)cleanData;

- (void)voideHavePalyed;
@end
