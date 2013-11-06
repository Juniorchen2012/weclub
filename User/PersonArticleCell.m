//
//  PersonArticleCell.m
//  WeClub
//
//  Created by Archer on 13-3-25.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "PersonArticleCell.h"

@implementation PersonArticleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)resetCell
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end
