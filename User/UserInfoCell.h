//
//  UserInfoCell.h
//  WeClub
//
//  Created by Archer on 13-3-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoCell : UITableViewCell
{
    UIImageView *_photo;
    UILabel *_name;
    UIImageView *_sex;
    UILabel *_generation;
    UIImageView *_generationView;
    UILabel *_distance;
    UIImageView *_distanceView;
    UILabel *_autograph;
}

@property (nonatomic,retain) UIImageView *photo;
@property (nonatomic,retain) UIImageView *sex;
@property (nonatomic,retain) UILabel *generation;
@property (nonatomic,retain) UILabel *distance;
@property (nonatomic,retain) UILabel *autograph;

- (void)setName:(NSString *)name;
- (void)setDistanceStr:(NSString *)distance;

@end
