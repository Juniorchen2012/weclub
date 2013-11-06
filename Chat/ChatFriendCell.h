//
//  ChatFriendCell.h
//  WeClub
//
//  Created by Archer on 13-3-19.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate-Utilities.h"

@interface ChatFriendCell : UITableViewCell
{
//    UIButton *_photoButton;
    UIImageView *_photoView;
    UILabel *_nameLabel;
    UIImageView *_sexView;
    UILabel *_lastDateLabel;
    UILabel *_lastMsgLabel;
}

//@property (nonatomic, retain) UIButton *photoButton;
@property (nonatomic, retain) UIImageView *photoView;
@property (nonatomic, retain) UIImageView *sexView;
@property (nonatomic, retain) UILabel *lastDateLabel;
@property (nonatomic, retain) UILabel *lastMsgLabel;

- (void)setName:(NSString *)name;
- (void)setLastDate:(NSDate *)lastDate;

@end
