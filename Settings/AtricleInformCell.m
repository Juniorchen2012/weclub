//
//  AtricleInformCell.m
//  WeClub
//
//  Created by mitbbs on 13-8-7.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "AtricleInformCell.h"

@implementation AtricleInformCell

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
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.infoLabel = [[UILabel alloc] init];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        self.dataLabel = [[UILabel alloc] init];
        self.dataLabel.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.nameLabel];
        [self.bgView addSubview:self.infoLabel];
        [self.bgView addSubview:self.dataLabel];
        self.imgView = [[UIImageView alloc] init];
        [self.bgView addSubview:self.imgView];
    }
    return self;
}

+ (CGFloat)getCellHeight:(NSDictionary *)dic
{
    NSString *info = [dic objectForKey:@"content"];
    AtricleInformCell *cell = [[AtricleInformCell alloc] init];
    CGFloat height = [cell getMixedViewHeight:[cell cutAtricleString:info]];
    cell = nil;
    return height + 46;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    self.nameLabel = nil;
    self.dataLabel = nil;
    self.infoLabel = nil;
    self.bgView = nil;
    self.dic = nil;
    self.imgView = nil;
}

- (void)resetCell
{
    NSString *str = [self.dic objectForKey:@"content"];
    [self.dic setObject:[self cutAtricleString:str] forKey:@"content"];
    self.nameLabel.text = nil;
    self.dataLabel.text = nil;
    self.infoLabel.text = nil;
    self.bgView.frame = CGRectMake(10, 2, 300, 63);
    self.accessoryType = UITableViewCellAccessoryNone;
    self.imgView.image = nil;
    for (UIView *oneView in self.infoLabel.subviews){
        [oneView removeFromSuperview];
    }
    [self cellWithFormat];
}

- (void)setWithDic:(NSDictionary *)dic
{
    self.dic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [self resetCell];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"201"]) {
        [self cellWith201];
    }else if ([type isEqualToString:@"202"]) {
        [self cellWith202];
    }else if ([type isEqualToString:@"203"]) {
        [self cellWith203];
    }else if ([type isEqualToString:@"204"]) {
        [self cellWith204];
    }else if ([type isEqualToString:@"205"]) {
        [self cellWith205];
    }else if ([type isEqualToString:@"210"]) {
        [self cellWith210];
    }
}

- (void)cellWith201{
    self.nameLabel.text = [self.dic objectForKey:@"username"];
    self.infoLabel.text = [self.dic objectForKey:@"content"];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([[self.dic objectForKey:@"isdel"] integerValue] == 1) {
        
    }else{
        [self addPic];
    }
}

- (void)cellWith202{
    self.nameLabel.text = @"系统消息";
    NSString *content = [self.dic objectForKey:@"content"];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([[self.dic objectForKey:@"isdel"] integerValue] == 1 || [self.dic objectForKey:@"nottop"]) {
        
    }else{
        [self addPic];
    }
    [self attachString:content toView:self.infoLabel];
}

- (void)cellWith203{
    self.nameLabel.text = @"系统消息";
    NSString *content = [self.dic objectForKey:@"content"];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([[self.dic objectForKey:@"isdel"] integerValue] == 1 || [self.dic objectForKey:@"notdig"]) {
        
    }else{
        [self addPic];
    }
//    self.infoLabel.text = content;
//    self.infoLabel.numberOfLines = 0;
//    self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self attachString:content toView:self.infoLabel];
}

- (void)cellWith204{
    self.nameLabel.text = @"系统消息";
    NSString *content = [self.dic objectForKey:@"content"];
    [self attachString:content toView:self.infoLabel];

}

- (void)cellWith205{
    self.nameLabel.text = @"系统消息";
    NSString *content = [self.dic objectForKey:@"content"];
    [self attachString:content toView:self.infoLabel];

}

- (void)cellWith210{
    self.nameLabel.text = @"系统消息";
    NSString *content = [self.dic objectForKey:@"content"];
    [self attachString:content toView:self.infoLabel];
}

- (void)cellWithNormalInfo
{

}

- (void)addPic
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"notice_close" ofType:@"png"];
//    UIImage *img = [UIImage imageWithContentsOfFile:path];
    UIImage *img = [UIImage imageNamed:@"notice_close.png"];
    self.imgView.image = img;
    img = nil;
    
}

- (void)cellWithFormat
{
    self.dataLabel.frame = CGRectMake(200, 7, 80, 20);
    NSString *dates = [[self.dic objectForKey:@"addtime"] substringToIndex:10];
    NSString *dateStr = [Utility getLastDate:[NSDate dateWithTimeIntervalSince1970:[dates floatValue]]];
    self.dataLabel.textColor = [UIColor grayColor];
    self.dataLabel.font = [UIFont systemFontOfSize:16];
    self.dataLabel.text = dateStr;
    self.dataLabel.textAlignment = NSTextAlignmentRight;
    
    self.nameLabel.frame = CGRectMake(10, 10, 150, 20);
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    self.infoLabel.font = [UIFont systemFontOfSize:15];
    self.infoLabel.textColor = [UIColor grayColor];
    self.infoLabel.frame = CGRectMake(10, 35, 275, [self getMixedViewHeight:[self.dic objectForKey:@"content"]]);
    self.bgView.frame = CGRectMake(10, 2, 300, [self getMixedViewHeight:[self.dic objectForKey:@"content"]]+43);
    self.imgView.frame = CGRectMake(283,self.bgView.frame.origin.y + self.bgView.frame.size.height/2-7, 16, 14);
}

#pragma mark - cut
- (NSMutableString *)cutAtricleString:(NSString *)str
{
    NSMutableString *returnStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *array = [self mycutMixedString:str];
    if (array.count == 1) {
        return [NSMutableString stringWithString:str];
    }else{
        for (NSString *oneStr in array) {
            NSRange rangeH = NSMakeRange(NSNotFound, 0);
            rangeH = [oneStr rangeOfString:@"...,"];
            if (rangeH.location == NSNotFound) {
                rangeH = [oneStr rangeOfString:@"...】"];
            }
            if (rangeH.location != NSNotFound) {
                NSMutableString *tempStr = [NSMutableString stringWithString:oneStr];
                if (rangeH.location > 0 && rangeH.location < 4) {
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
    rect.size.height = y + 20;
    targetView.frame = rect;
}

- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, 275, size.height);
    [self attachString:str toView:view];
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
