//
//  ImportFriendCell.m
//  WeClub
//
//  Created by Archer on 13-5-10.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ImportFriendCell.h"

@implementation ImportFriendCell

@synthesize photoView = _photoView;
@synthesize nameLabel = _nameLabel;
@synthesize isRegister = _isRegister;
@synthesize followButton = _followButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _photoView = [[UIImageView alloc] init];
        _photoView.frame = CGRectMake(10, 9, 41, 41);
        _photoView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:_photoView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(55, 9, 180, 20);
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLabel];
        
        _isRegister = [[UILabel alloc] init];
        _isRegister.frame = CGRectMake(55, 29, 70, 20);
        _isRegister.textAlignment = NSTextAlignmentLeft;
        _isRegister.textColor = [UIColor grayColor];
        _isRegister.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_isRegister];
        
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.frame = CGRectMake(250, 12, 70, 35);
        [_followButton setTitleColor:[UIColor blackColor] forState:UIControlEventTouchUpInside];
        //[_followButton setImage:[UIImage imageNamed:@"user_follow.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:_followButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
