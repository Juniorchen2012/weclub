//
//  ClubInformCell.m
//  WeClub
//
//  Created by mitbbs on 13-8-7.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ClubInformCell.h"

@implementation ClubInformCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bgView = [[UIImageView alloc] init];
        self.bgView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        self.bgView.layer.cornerRadius = 5;
        self.bgView.layer.borderWidth = 1;
        self.bgView.frame = CGRectMake(10, 2, 300, 63);
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
    CGSize size = [info sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 48;
    
}

- (void)dealloc
{
    self.dataLabel = nil;
    self.nameLabel = nil;
    self.infoLabel = nil;
    self.bgView = nil;
    self.dic = nil;
    self.imgView = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setWithDic:(NSDictionary *)dic
{
    self.dic = dic;
    [self resetCell];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"101"]) {
        [self cellWtih101];
    }else if ([type isEqualToString:@"102"]){
        [self cellWith102];
    }else if ([type isEqualToString:@"103"]) {
        [self cellWith103];
    }
    else if ([type isEqualToString:@"104"]){
        [self cellWith104];
    }else if ([type isEqualToString:@"105"]||[type isEqualToString:@"106"]){
        [self cellWith105];
    }else if ([type isEqualToString:@"110"]){
        [self cellWith110];
    }else if ([type isEqualToString:@"111"]){
        [self cellWith111];
    }else if ([type isEqualToString:@"112"]) {
        [self cellWith112];
    }else if ([type isEqualToString:@"113"]) {
        [self cellWith113];
    }
}

- (void)cellWtih101
{
    self.nameLabel.text = [self.dic objectForKey:@"username"];
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
}

- (void)cellWith102
{
    self.nameLabel.text = @"系统消息";
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
    
}

- (void)cellWith103
{
    self.nameLabel.text = [self.dic objectForKey:@"username"];
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
}

- (void)cellWith104
{
    self.nameLabel.text = [self.dic objectForKey:@"username"];
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
}
- (void)cellWith105
{
    self.nameLabel.text = @"系统消息";
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
}

- (void)cellWith110{
    self.nameLabel.text = @"系统消息";
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
}

- (void)cellWith111{
    self.nameLabel.text = @"系统消息";
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
}

- (void)cellWith112
{
    self.nameLabel.text = @"系统消息";
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //[self addPic];
}

- (void)cellWith113
{
    self.nameLabel.text = @"系统消息";
    [self attachString:[self.dic objectForKey:@"content"] toView:self.infoLabel];
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addPic];
}

- (void)cellWithFormat
{
    self.dataLabel.frame = CGRectMake(200, 7, 80, 20);
    NSString *dates = [[self.dic objectForKey:@"addtime"] substringToIndex:10];
    NSString *dateStr = [Utility getLastDate:[NSDate dateWithTimeIntervalSince1970:[dates floatValue]]];
    //NSString *dateStr = [NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSince1970:[dates floatValue]]];
    self.dataLabel.textColor = [UIColor grayColor];
    self.dataLabel.font = [UIFont systemFontOfSize:16];
    self.dataLabel.text = dateStr;
    self.dataLabel.textAlignment = NSTextAlignmentRight;
    
    self.nameLabel.frame = CGRectMake(10, 10, 150, 20);
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    self.infoLabel.font = [UIFont systemFontOfSize:15];
    self.infoLabel.textColor = [UIColor grayColor];
    CGSize size = [[self.dic objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(275, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.frame = CGRectMake(10, 35, 275, size.height);
    self.bgView.frame = CGRectMake(10, 2, 300, size.height+45);
    self.imgView.frame = CGRectMake(283,self.bgView.frame.origin.y + self.bgView.frame.size.height/2-7, 16, 14);
}

- (void)resetCell
{
    self.nameLabel.text = @"";
    self.dataLabel.text = @"";
    self.infoLabel.text = @"";
    self.imgView.image = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
    for (UIView *oneView in self.infoLabel.subviews){
        [oneView removeFromSuperview];
    }
    [self cellWithFormat];
}

- (void)addPic
{
    UIImage *img = [UIImage imageNamed:@"notice_close.png"];
    self.imgView.image = img;
    img = nil;}

- (NSRange)matching:(NSString *)str
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    int pStart = 1000;
    int pEnd = 0;
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"［"]) {
            pStart = pEnd;
        }else if ([a isEqualToString:@"］"]){
            if (pStart == 1000) {
                pEnd++;
                continue;
            }else{
                range = NSMakeRange(pStart, pEnd-pStart+1);
                break;
            }
        }else if ([a isEqualToString:@"\n"]){
            if (pStart == 1000) {
                range = NSMakeRange(0, 1);
                break;
            }else{
                range = NSMakeRange(0, pEnd);
                break;
            }
        }
        pEnd++;
    }
    return range;
}

- (NSMutableArray *)mycutMixedString:(NSString *)str
{
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:0];
    NSRange range;
    while (1) {
        range = [self matching:str];
        if (range.location == NSNotFound) {
            break;
        }
        [returnArray addObject:[str substringToIndex:range.location]];
        [returnArray addObject:[str substringWithRange:range]];
        str = [str substringFromIndex:range.location + range.length];
    }
    if ([str length] > 0) {
        [returnArray addObject:str];
    }
    while (1) {
        if ([[returnArray lastObject] isEqualToString:@"/n"]) {
            [returnArray removeObjectAtIndex:(returnArray.count - 1)];
        }else{
            break;
        }
    }
    return returnArray;
}
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

@end
