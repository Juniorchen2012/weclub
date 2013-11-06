//
//  UserInfoCell.m
//  WeClub
//
//  Created by Archer on 13-3-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "UserInfoCell.h"

@implementation UserInfoCell

@synthesize photo = _photo;
@synthesize sex = _sex;
@synthesize generation = _generation;
@synthesize distance = _distance;
@synthesize autograph = _autograph;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, 320, 80);
        
        //添加头像
        _photo = [[UIImageView alloc] init];
        _photo.frame = CGRectMake(9, 10, 60, 60);
        _photo.backgroundColor = [UIColor grayColor];
        _photo.layer.masksToBounds = YES;
        _photo.layer.cornerRadius = 5.0;
        [self addSubview:_photo];
        
        //姓名标签
        _name = [[UILabel alloc] init];
        _name.frame = CGRectMake(75, 10, 50, 20);
        _name.text = @"小小小";
        _name.font = [UIFont systemFontOfSize:16];
        [self addSubview:_name];
        
        //性别标识
        _sex = [[UIImageView alloc] init];
        _sex.frame = CGRectMake(135, 10, 20, 20);
        [self addSubview:_sex];
        
        //距离图标
        _distanceView = [[UIImageView alloc] init];
        _distanceView.frame = CGRectMake(225, 10, 17, 20);
        UIImage *distanceImg = [UIImage imageNamed:@"user_location.png"];
        _distanceView.image = distanceImg;
        [self addSubview:_distanceView];
        
        //距离标签
        _distance = [[UILabel alloc] init];
        _distance.frame = CGRectMake(245, 10, 70, 20);
        _distance.text = @"99999km";
        _distance.font = [UIFont systemFontOfSize:16];
        _distance.textColor = [UIColor grayColor];
        [self addSubview:_distance];
        
//        //年代图标
//        _generationView = [[UIImageView alloc] init];
//        _generationView.frame = CGRectMake(75, 30, 20, 20);
//        UIImage *generationImg = [UIImage imageNamed:@"user_generation.png"];
//        _generationView.image = generationImg;
//        [self addSubview:_generationView];
//        
//        //年代标签
//        _generation = [[UILabel alloc] init];
//        _generation.frame = CGRectMake(100, 30, 40, 20);
//        _generation.font = [UIFont systemFontOfSize:16];
//        _generation.textColor = [UIColor grayColor];
//        [self addSubview:_generation];
        
        //签名标签
        _autograph = [[UILabel alloc] init];
        _autograph.frame = CGRectMake(75, 30, 230, 40);
//        _autograph.backgroundColor = [UIColor grayColor];
//        _autograph.text = @"今天天气不错。。。";
        _autograph.font = [UIFont systemFontOfSize:16];
        _autograph.numberOfLines = 2;
        _autograph.textColor = [UIColor grayColor];
        [self addSubview:_autograph];
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
    CGSize nameSize = [name sizeWithFont:_name.font];
    _name.text = name;
    CGRect n = _name.frame;
    n.size.width = nameSize.width>110?110:nameSize.width;
    _name.frame = n;
    
    CGRect s = _sex.frame;
    s.origin.x = _name.frame.origin.x+_name.frame.size.width+10;
    _sex.frame = s;
}

- (void)setDistanceStr:(NSString *)distance
{
    CGSize distanceSize = [distance sizeWithFont:_distance.font];
    _distance.text = distance;
    _distance.frame = CGRectMake(315-distanceSize.width, 10, distanceSize.width, 20);
    
    CGRect d = _distanceView.frame;
    d.origin.x = _distance.frame.origin.x-20;
    _distanceView.frame = d;
}

@end
