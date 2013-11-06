//
//  ZDPageControll.h
//  WeClub
//
//  Created by mitbbs on 13-9-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//
#import "ZDPageControll.h"
#import <QuartzCore/QuartzCore.h>

@interface ZDPageControll:UIPageControl
{
    UIImage *_activeImage;
    UIImage *_inactiveImage;
    NSArray *_usedToRetainOriginalSubview;
    CGFloat _kSpacing;
}
@property(nonatomic,assign)CGFloat kSpacing;
- (id)initWithFrame:(CGRect)frame currentImageName:(NSString *)current commonImageName:(NSString *)common;
@end
