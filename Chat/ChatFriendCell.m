//
//  ChatFriendCell.m
//  WeClub
//
//  Created by Archer on 13-3-19.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChatFriendCell.h"

@implementation ChatFriendCell

@synthesize photoView = _photoView;
@synthesize sexView = _sexView;
@synthesize lastDateLabel = _lastDateLabel;
@synthesize lastMsgLabel = _lastMsgLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //头像按钮
        _photoView = [[UIImageView alloc] init];
        _photoView.frame = CGRectMake(10, 10, 40, 40);
        _photoView.backgroundColor = [UIColor grayColor];
        [self addSubview:_photoView];
        
        //姓名标签
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(55, 10, 60, 20);
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.text = @"小小小";
        [self addSubview:_nameLabel];
        
        //性别标示
        _sexView = [[UIImageView alloc] init];
        _sexView.frame = CGRectMake(120, 10, 20, 20);
//        _sexView.backgroundColor = [UIColor grayColor];
        [self addSubview:_sexView];
        
        //时间标签
        _lastDateLabel = [[UILabel alloc] init];
        _lastDateLabel.frame = CGRectMake(245, 10, 70, 20);
        _lastDateLabel.text = @"上午08：08";
        _lastDateLabel.textColor = [UIColor grayColor];
        _lastDateLabel.font = [UIFont boldSystemFontOfSize:16];
        _lastDateLabel.textAlignment = UITextAlignmentRight;
        _lastDateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_lastDateLabel];
        
        //消息标签
        _lastMsgLabel = [[UILabel alloc] init];
        _lastMsgLabel.frame = CGRectMake(55, 33, 230, 24);
        _lastMsgLabel.text = @"用画笔讲述人生感悟，您可以尝试改变你妹你妹你妹你妹啊";
        _lastMsgLabel.font = [UIFont boldSystemFontOfSize:16];
        _lastMsgLabel.textColor = [UIColor grayColor];
        _lastMsgLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_lastMsgLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name
{
    _nameLabel.text = name;
    CGSize textSize = [name sizeWithFont:[UIFont boldSystemFontOfSize:16]];
    CGRect rect1 = _nameLabel.frame;
    rect1.size.width = textSize.width>160?160:textSize.width;
    _nameLabel.frame = rect1;
    
    CGRect rect2 = _sexView.frame;
    rect2.origin.x = _nameLabel.frame.origin.x + _nameLabel.frame.size.width + 5;
    _sexView.frame = rect2;
}

- (void)setLastDate:(NSDate *)lastDate
{
    NSString *dateString;
    if ([lastDate isToday]) {
        NSDateFormatter *format=[[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH:mm"];
        if (lastDate.minute < 10) {
            dateString = [NSString stringWithFormat:@"%d:0%d",lastDate.hour,lastDate.minute];
        }
        else{
            dateString = [NSString stringWithFormat:@"%d:%2d",lastDate.hour,lastDate.minute];
        }
    }else if ([lastDate isYesterday]){
        dateString = @"昨天";
    }else if ([lastDate daysBeforeDate:[lastDate dateBySubtractingDays:1]]){
        dateString = [NSString stringWithFormat:@"%d.%d",lastDate.month,lastDate.day];
    }
    _lastDateLabel.text = dateString;
}

@end
