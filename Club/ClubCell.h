//
//  ClubCell.h
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"

@interface ClubCell : UITableViewCell
{
    UIImageView *logo;//版标
    UILabel *nameLbl;//俱乐部名字
    UILabel *descLbl;//俱乐部描述
    UIView  *starLevelView;//星级
    UILabel *distanceLbl;//距离
    
    UILabel *typeLbl;//类型
    UILabel *memberCountLbl;//会员数
    UILabel *followCountLbl;//关注数
    UILabel *topicCountLbl;//主题数
    
    UIImageView *typeIcon;//类型图标
    UIImageView *memberIcon;//会员图标
    UIImageView *followIcon;//会员图标
    UIImageView *topicIcon;//主题图标
    UIImageView *distaneIcon;//距离图标
    UIImageView *OpentTypeImg;//公开，私密的标志
    UIImageView *Identifyimg;//标志是否版主版副
}
@property(nonatomic, retain) UIImageView *logo;
- (void)initWithClub:(Club *)club;
@end
