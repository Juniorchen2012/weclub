//
//  ImportFriendCell.h
//  WeClub
//
//  Created by Archer on 13-5-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportFriendCell : UITableViewCell
{
    UIImageView *_photoView;
    UILabel *_nameLabel;
    UILabel *_isRegister;
    UIButton *_followButton;
}

@property (nonatomic, retain) UIImageView *photoView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *isRegister;
@property (nonatomic, retain) UIButton *followButton;

@end
