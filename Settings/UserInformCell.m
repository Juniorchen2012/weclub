//
//  UserInformCell.m
//  WeClub
//
//  Created by mitbbs on 13-8-7.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "UserInformCell.h"

@implementation UserInformCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bgView = [[UIImageView alloc] init];
        self.bgView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        self.bgView.layer.cornerRadius = 5;
        self.bgView.layer.borderWidth = 1;
        self.bgView.layer.borderColor = [[UIColor grayColor] CGColor];
        [self addSubview:self.bgView];

        self.headView = [[UIImageView alloc] init];
        self.headView.backgroundColor = [UIColor clearColor];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.infoLabel = [[UILabel alloc] init];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        self.dataLabel = [[UILabel alloc] init];
        self.dataLabel.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.headView];
        [self.bgView addSubview:self.nameLabel];
        [self.bgView addSubview:self.infoLabel];
        [self.bgView addSubview:self.dataLabel];
        self.imgView = [[UIImageView alloc] init];
        [self.bgView addSubview:self.imgView];
    }
    return self;
}

- (void)dealloc
{
    self.bgView = nil;
    self.headView = nil;
    self.nameLabel = nil;
    self.infoLabel = nil;
    self.dataLabel = nil;
    self.imgView = nil;
}

- (void)setWithDic:(NSDictionary *)dic
{
    [self resetCell];
    self.dic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"301"]) {
        [self cellWith301];
    }else if ([type isEqualToString:@"302"]){
        [self cellWith302];
    }else if ([type isEqualToString:@"306"]) {
        [self cellWith306];
    }
    else if ([type isEqualToString:@"307"]){
        [self cellWith307];
    }else if ([type isEqualToString:@"308"]){
        [self cellWith308];
    }else if ([type isEqualToString:@"309"]){
        [self cellWith309];
    }else if ([type isEqualToString:@"320"]){
        [self cellWith320];
    }else if ([type isEqualToString:@"321"]){
        [self cellWith321];
    }else{
        [self cellWithNormalInfo];
    }
}

- (void)resetCell
{
    self.headView.image = nil;
    self.nameLabel.text = nil;
    self.infoLabel.text = nil;
    self.dataLabel.text = nil;
    for (UIView *oneView in self.infoLabel.subviews){
        [oneView removeFromSuperview];
    }
    self.imgView.image = nil;
    self.accessoryType = UITableViewCellAccessoryNone;;
    self.bgView.frame = CGRectMake(10, 2, 300, 63);
}

- (CGFloat)getInfoHeight
{
    NSString *info = [self.dic objectForKey:@"content"];
    CGSize size = [info sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}

+ (CGFloat)getCellHeight:(NSDictionary *)dic
{
    NSString *info = [dic objectForKey:@"content"];
    if ([[dic objectForKey:@"type"] isEqualToString:@"306"]) {
        NSString *info = [dic objectForKey:@"content"];
        UserInformCell *cell = [[UserInformCell alloc] init];
        CGFloat height = [cell getMixedViewHeight:[cell cutAtricleString:info]];
        cell = nil;
        return height + 46;
    }
    CGSize size = [info sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 46;

}

/*
 type
 
 */
- (void)cellWith301
{
    [self formatWithType:@"0"];
    NSString *photoTime = [NSString stringWithFormat:@"%@",[[self.dic objectForKey:@"photoTime"] lastObject]];
    NSString *userKey = [self.dic objectForKey:@"userkey"];
    NSArray *array = [userKey componentsSeparatedByString:@","];
    NSString *photoId = [NSString stringWithFormat:@"%@1",[array lastObject]];
    [self.headView setImageWithURL:USER_HEAD_IMG_URL_TIME(@"small", photoId,photoTime) placeholderImage:[UIImage imageNamed:@"male_holder.png"]];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
    self.nameLabel.text = [self.dic objectForKey:@"username"];
    self.infoLabel.text = [self.dic objectForKey:@"content"];
    self.bgView.frame = CGRectMake(10, 2, 300, 62);
}

- (void)cellWith302
{
    [self cellWithNormalInfo];    
}

- (void)cellWith306{
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
    [self formatWithType:@"1"];
    NSString *str = [self.dic objectForKey:@"content"];
    [self.dic setObject:[self cutAtricleString:str] forKey:@"content"];
    self.infoLabel.font = [UIFont systemFontOfSize:15];
    self.infoLabel.textColor = [UIColor grayColor];
    self.infoLabel.frame = CGRectMake(10, 35, 275, [self getMixedViewHeight:[self.dic objectForKey:@"content"]]);
    self.bgView.frame = CGRectMake(10, 2, 300, [self getMixedViewHeight:[self.dic objectForKey:@"content"]]+43);
    self.nameLabel.text = @"系统消息";
    [self attachString:[self cutAtricleString:str] toView:self.infoLabel];
    
}

- (void)cellWith307
{
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
    [self cellWithNormalInfo];
}

- (void)cellWith308
{
    [self cellWithNormalInfo];
}

- (void)cellWith309
{
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
    [self cellWithNormalInfo];
}

- (void)cellWith320
{
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
    [self cellWithNormalInfo];
}

- (void)cellWith321
{
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
    [self cellWithNormalInfo];
}

- (void)addPic
{
    UIImage *img = [UIImage imageNamed:@"notice_close.png"];
    self.imgView.image = img;
    img = nil;
}

- (void)cellWithNormalInfo
{
    [self formatWithType:@"1"];
    
    self.nameLabel.text = @"系统消息";
    
    self.infoLabel.text = [self.dic objectForKey:@"content"];
}

- (void)formatWithType:(NSString *)type
{
    self.dataLabel.frame = CGRectMake(200, 7, 80, 20);
    NSString *dates = [[self.dic objectForKey:@"addtime"] substringToIndex:10];
    NSString *dateStr = [Utility getLastDate:[NSDate dateWithTimeIntervalSince1970:[dates floatValue]]];
    self.dataLabel.textColor = [UIColor grayColor];
    self.dataLabel.font = [UIFont systemFontOfSize:16];
    self.dataLabel.text = dateStr;
    self.dataLabel.textAlignment = NSTextAlignmentRight;
    
    if ([type isEqualToString:@"0"]) {
        self.headView.frame = CGRectMake(10, 8, 46, 46);
        self.nameLabel.frame = CGRectMake(70, 8, 150, 20);
        self.infoLabel.frame = CGRectMake(70, 33, 275, 20);
    }else if ([type isEqualToString:@"1"]) {
        self.nameLabel.frame = CGRectMake(10, 10, 150, 20);
        self.infoLabel.frame = CGRectMake(10, 35, 275, [self getInfoHeight]);
        self.infoLabel.numberOfLines = 0;
        self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.bgView.frame = CGRectMake(10, 2, 300, [self getInfoHeight]+43);
    }
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    self.infoLabel.font = [UIFont systemFontOfSize:15];
    self.infoLabel.textColor = [UIColor grayColor];
    self.imgView.frame = CGRectMake(283,self.bgView.frame.origin.y + self.bgView.frame.size.height/2-7, 16, 14);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (NSMutableString *)cutAtricleString:(NSString *)str
{
    NSMutableString *returnStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *array = [self mycutMixedString:str];
    if (array.count == 1) {
        returnStr = [NSMutableString stringWithString:str];
        return returnStr;
    }else{
        for (NSString *oneStr in array) {
            NSRange rangeH = NSMakeRange(NSNotFound, 0);
            rangeH = [oneStr rangeOfString:@"...,"];
            if (rangeH.location == NSNotFound) {
                rangeH = [oneStr rangeOfString:@"...】"];
            }
            if (rangeH.location != NSNotFound) {
                NSMutableString *tempStr = [NSMutableString stringWithString:oneStr];
                if (rangeH.location > 0 && rangeH.location <= 3) {
                    [tempStr deleteCharactersInRange:NSMakeRange(0, rangeH.location)];
                    [returnStr appendString:tempStr];
                    continue;
                }
            }
            [returnStr appendString:oneStr];
        }
        return returnStr;
    }
}

#pragma mark - mixed
- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self mycutMixedString:str];
    //    NSLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:15];
    
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 20);
                        btn.titleLabel.font = font;
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        
                        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                        [targetView addSubview:btn];
                        x += subSize.width;
                    }else{
                        int index = 0;
                        while (x + [piece sizeWithFont:font].width > maxWidth) {
                            NSString *subString = [piece substringToIndex:index];
                            while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                                index++;
                                subString = [piece substringToIndex:index];
                            }
                            index--;
                            if (index <= 0) {
                                x = 0;
                                y += 20;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(x, y, subSize.width, 20);
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle:subString forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                            btn.titleLabel.font = font;
                            [targetView addSubview:btn];
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 20;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 20);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        btn.titleLabel.font = font;
                        [targetView addSubview:btn];
                        x += subSize.width;
                    }
                }else{
                    if (x + 20 > maxWidth) {
                        x = 0;
                        y += 20;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, 20, 20);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    [targetView addSubview:imgView];
                    imgView = nil;
                    x += 20;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 20;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 20);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    btn.titleLabel.font = font;
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 20;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 20);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:subString forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                        btn.titleLabel.font = font;
                        btn.userInteractionEnabled = NO;
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index <= piece.length-1) {
                            x = 0;
                            y += 20;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 20);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    btn.titleLabel.font = font;
                    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
    //    NSLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 20;
    targetView.frame = rect;
}

- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, 275, size.height);
    CGFloat height = view.frame.size.height;
    view = nil;
    return height;
}

//匹配括号
- (NSRange)matching:(NSString *)str
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    int pStart = 1000;
    int pEnd = 0;
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"["]) {
            pStart = pEnd;
        }else if ([a isEqualToString:@"]"]){
            if (pStart == 1000) {
                pEnd++;
                continue;
            }else{
                range = NSMakeRange(pStart, pEnd-pStart+1);
                break;
            }
        }
        pEnd++;
    }
    return range;
}

//切割字符串
- (NSMutableArray *)mycutMixedString:(NSString *)str
{
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:0];
    NSRange range;
    while (1) {
        range = [self matching:str];
        if (range.location == NSNotFound) {
            break;
        }
        if ([[str substringToIndex:range.location] isEqualToString:@""]) {
            
        }else{
            [returnArray addObject:[str substringToIndex:range.location]];
        }
        [returnArray addObject:[str substringWithRange:range]];
        str = [str substringFromIndex:range.location + range.length];
    }
    if ([str length] > 0) {
        [returnArray addObject:str];
    }
    return returnArray;
}

@end
