//
//  CircleView.h
//  WeClub
//
//  Created by mitbbs on 13-7-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleView : UIView


@property (nonatomic, assign)CGFloat _r;
@property(nonatomic, retain)NSString *_text;
@property(nonatomic, assign)CGFloat _fontSize;


-(id)initWithFrame:(CGRect)frame text:(NSString *)text radius:(CGFloat)r;
-(void)changeText:(NSString *)strText;
- (void)setStrFont:(CGFloat)font;
@end
