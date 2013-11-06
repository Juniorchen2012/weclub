//
//  ClubCell.m
//  WeClub
//
//  Created by chao_mit on 13-1-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//
#import "ClubCell.h"
#define CLUB_LABEL_WIDTH 50

@implementation ClubCell
@synthesize logo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        logo = [[UIImageView alloc]initWithFrame:CGRectMake(8.7, 6.7, 60, 60)];
        logo.frame = CGRectMake(8.7, 8.7, 60, 60);
        logo.layer.masksToBounds = YES;
        logo.layer.cornerRadius = 5;
        
        //因为俱乐部名字会很长，所有只能显示部分，否则会盖住星级
        nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, -2, 150, 20)];
        [Utility styleLbl:nameLbl withTxtColor:COLOR_BLACK withBgColor:nil withFontSize:16];
        nameLbl.font = [UIFont fontWithName:FONT_NAME_ARIAL_BOLD size:16];
        
        starLevelView = [[UIView alloc]initWithFrame:CGRectMake(90, 0, 100, 20)];
        distaneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location.png"]];
        distaneIcon.frame = CGRectMake(150, 4, 12, 12);
        
        //距离
        distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(165, 0, 80, 20)];
        [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:14];
        
        UIView *TopView = [[UIView alloc]initWithFrame:CGRectMake(73.7, 3, 250, 14)];
        TopView.backgroundColor = COLOR_GRAY;
        [TopView addSubview:nameLbl];
        [TopView addSubview:starLevelView];
        [TopView addSubview:distanceLbl];
        [TopView addSubview:distaneIcon];
        
        //描述
        descLbl = [[UILabel alloc]initWithFrame:CGRectMake(73.7, 22, 240, 50)];
        descLbl.backgroundColor = COLOR_BROWN;
        descLbl.numberOfLines = 0;
        descLbl.lineBreakMode = UILineBreakModeWordWrap;
        [Utility styleLbl:descLbl withTxtColor:nil withBgColor:nil withFontSize:13];
        
        UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(73.7, 62, 200, 12)];
        bottomView.backgroundColor = COLOR_BLUE;
        
        //分类
        typeIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"type.png"]];
        [typeIcon setFrame:CGRectMake(0, 0, 12, 12)];
        typeLbl = [[UILabel alloc]initWithFrame:CGRectMake(typeIcon.frame.origin.x+typeIcon.frame.size.width+3, 0, CLUB_LABEL_WIDTH, 14)];
        [Utility styleLbl:typeLbl withTxtColor:nil withBgColor:nil withFontSize:11];
        
        //成员数
        memberIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"member_count.png"]];
        [memberIcon setFrame:CGRectMake(typeLbl.frame.origin.x+typeLbl.frame.size.width, 0, 12, 12)];
        memberCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(memberIcon.frame.origin.x+memberIcon.frame.size.width+3, 0, CLUB_LABEL_WIDTH, 14)];
        [Utility styleLbl:memberCountLbl withTxtColor:nil withBgColor:nil withFontSize:11];
        
        //关注数
        followIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"follow_count.png"]];
        [followIcon setFrame:CGRectMake(memberCountLbl.frame.origin.x+memberCountLbl.frame.size.width, 1, 12, 12)];
        followCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(followIcon.frame.origin.x+followIcon.frame.size.width+3, 0, CLUB_LABEL_WIDTH, 14)];
        [Utility styleLbl:followCountLbl withTxtColor:nil withBgColor:nil withFontSize:11];
        
        //主题文章数
        topicIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topic_count.png"]];
        [topicIcon setFrame:CGRectMake(followCountLbl.frame.origin.x+followCountLbl.frame.size.width, 1, 12, 12)];
        topicCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(topicIcon.frame.origin.x+topicIcon.frame.size.width, 0, CLUB_LABEL_WIDTH, 14)];
        [Utility styleLbl:topicCountLbl withTxtColor:nil withBgColor:nil withFontSize:11];
        
        //        UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
        //        seperatorLine.backgroundColor = [UIColor lightGrayColor];
        //        [self addSubview:seperatorLine];
        
        [self addSubview:logo];
        [self addSubview:TopView];
        [self addSubview:descLbl];
        [bottomView addSubview:typeIcon];
        [bottomView addSubview:typeLbl];
        [bottomView addSubview:memberIcon];
        [bottomView addSubview:memberCountLbl];
        [bottomView addSubview:topicIcon];
        [bottomView addSubview:topicCountLbl];
        [bottomView addSubview:followCountLbl];
        [bottomView addSubview:followIcon];
        [self addSubview:bottomView];
    }
    return self;
}

- (void)initWithClub:(Club *)club{
    CLUB_LOGO(logo,club.ID,club.picTime);
    nameLbl.text = club.name;
    descLbl.text = club.desc;
    [Utility removeSubViews:descLbl];
    [Utility emotionAttachString:descLbl.text toView:descLbl font:14 isCut:NO];
    descLbl.text = @"";
    distanceLbl.text = club.distance;
    typeLbl.text = [myConstants.clubCategory objectAtIndex: [club.category intValue]];
    memberCountLbl.text = [Utility numberSwitch:club.memberCount];
    topicCountLbl.text = [Utility numberSwitch:club.articleCount];
    followCountLbl.text = [Utility numberSwitch:club.followCount];
    if (club.type) {
        [OpentTypeImg removeFromSuperview];
        OpentTypeImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 56, 10, 10)];
        OpentTypeImg.image = [UIImage imageNamed:@"si.png"];
        OpentTypeImg.tag = 10002;
        [self addSubview:OpentTypeImg];
    }
    [Identifyimg removeFromSuperview];
    Identifyimg = [[UIImageView alloc]initWithFrame:CGRectMake(56, 56, 10, 10)];
    if (club.userType == 1) {
        Identifyimg.tag = 10000;
        Identifyimg.image = [UIImage imageNamed:@"ban.png"];
        [self addSubview:Identifyimg];
    }else if (club.userType == 2) {
        Identifyimg.image = [UIImage imageNamed:@"fu.png"];
        Identifyimg.tag = 10001;
        [self addSubview:Identifyimg];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//	[super willMoveToSuperview:newSuperview];
//
//	if(!newSuperview) {
//		[logo cancelImageLoad];
//	}
//}

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self cutMixedString:str];
    //    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
                                y += 22;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(x, y, subSize.width, 22);
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle:subString forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                            [targetView addSubview:btn];
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                    }
                    
                }else{
                    if (x + 22 > maxWidth) {
                        x = 0;
                        y += 22;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, 22, 22);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    [targetView addSubview:imgView];
                    x += 22;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 22;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:subString forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        btn.userInteractionEnabled = NO;
                        [targetView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    [targetView addSubview:btn];
                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
    //    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

- (NSMutableArray *)cutMixedString:(NSString *)str
{
    //    WeLog(@"str to be cut:%@",str);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int pStart = 0;
    int pEnd = 0;
    
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"["]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            NSRange range1 = [subString rangeOfString:@"["];
            NSRange range2 = [subString rangeOfString:@"]"];
            if (range2.location != NSNotFound && range2.location > range1.location) {
                NSString *strPiece = [subString substringToIndex:range2.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"h"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 9) {
                NSString *headStr = [subString substringToIndex:7];
                //                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"http://"]) {
                    NSRange range = [subString rangeOfString:@" "];
                    if (range.location != NSNotFound) {
                        NSString *strPiece = [subString substringToIndex:range.location+1];
                        [returnArray addObject:strPiece];
                        pEnd += strPiece.length;
                        pStart = pEnd;
                        pEnd--;
                    }
                }
            }
            
        }else if ([a isEqualToString:@"\n"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 2) {
                NSString *headStr = [subString substringToIndex:1];
                //                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"\n"]) {
                    
                    [returnArray addObject:headStr];
                    pEnd += headStr.length;
                    pStart = pEnd;
                    pEnd--;
                }
            }
        }
        pEnd++;
    }
    if (pStart != pEnd) {
        NSString *strPiece = [str substringFromIndex:pStart];
        [returnArray addObject:strPiece];
    }
    
    return returnArray;
}

@end
