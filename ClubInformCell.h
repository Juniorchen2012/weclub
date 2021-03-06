//
//  ClubInformCell.h
//  WeClub
//
//  Created by mitbbs on 13-8-7.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubInformCell : UITableViewCell

@property (nonatomic,strong) UILabel *dataLabel;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *infoLabel;
@property (nonatomic,strong) UIImageView *bgView;
@property (nonatomic,strong) NSDictionary *dic;
@property (nonatomic,strong) UIImageView *imgView;

- (void)setWithDic:(NSDictionary *)dic;
- (void)resetCell;
+ (CGFloat)getCellHeight:(NSDictionary *)dic;

@end
