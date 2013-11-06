//
//  ReplyViewCell.m
//  WeClub
//
//  Created by chao_mit on 13-4-20.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ReplyViewCell.h"

@implementation ReplyViewCell
@synthesize vc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //用户头像
        avatar = [[UIImageView alloc]init];
        avatar.frame = CGRectMake(5, 5, 50, 50);
        avatar.layer.masksToBounds = YES;
        avatar.layer.cornerRadius = 5;
        avatar.userInteractionEnabled = YES;
        [self addSubview:avatar];
        
        //=======
        UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(60, 5, 320, 14)];
        topView.backgroundColor = COLOR_GRAY;
        //用户名
        nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 100, 14)];
        nameLbl.text = @"音乐俱乐部";
        [Utility styleLbl:nameLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:nameLbl];
        //发文时间
        postTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(100, 2, 80, 13)];
        postTimeLbl.text = @"5小时前";
        [Utility styleLbl:postTimeLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:postTimeLbl];
        
        //发文距离
        UIImageView *distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(150, 2, 12, 14)];
        distanceIcon.image = [UIImage imageNamed:@"location.png"];
        distanceLbl = [[UILabel alloc]initWithFrame:CGRectMake(160, 2, 100, 13)];
        distanceLbl.text = @"500米";
        [Utility styleLbl:distanceLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:distanceIcon];
      [topView addSubview:distanceLbl];
        
        replyNOLbl = [[UILabel alloc]initWithFrame:CGRectMake(230, 2, 50, 13)];
        [Utility styleLbl:replyNOLbl withTxtColor:nil withBgColor:nil withFontSize:12];
        [topView addSubview:replyNOLbl];
        
        [self addSubview:topView];
    }
    myAudioPlay = [AudioPlay getSingleton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeAudioIMG)
                                                 name:@"AUDIOPLAY_CHANGE"
                                               object:nil];
    return self;
}

-(void)changeAudioIMG{
    [self refreshAudio];
}

-(void)audioPlay:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUDIO_STOP object:nil];
    UITapGestureRecognizer * tap = (UITapGestureRecognizer *)sender;
    if (!tap.view.tag) {
        //回复的语音
        WeLog(@"点击播放第%d个音频",self.tag);
        WeLog(@"AudioName:%@",[cellArticle.media objectAtIndex:0]);
        tap.view.tag = self.tag;
        WeLog(@"tag%d",tap.view.superview.superview.tag);
        [myAudioPlay playAudiowithType:@"articleAudio" withView:tap.view withFileName:[cellArticle.media objectAtIndex:0] withStyle:1];
    }else{
        //引用的语音
        WeLog(@"点击播放第%d个引用音频",self.tag);
        WeLog(@"tag%d",tap.view.superview.superview.tag);
        tap.view.tag = self.tag;
        [myAudioPlay playAudiowithType:@"articleAudio" withView:tap.view withFileName:[cellArticle.repliedArticle.media objectAtIndex:0] withStyle:1];
        WeLog(@"ReplyAudioName%@",[cellArticle.repliedArticle.media objectAtIndex:0]);
    }
}

-(void)initCellWithArticle:(Article*)article withViewController:(UIViewController *)viewController{
    cellArticle = article;
    vc = viewController;
    replyNOLbl.text = [NSString stringWithFormat:@"%@楼",article.replyNO];
    [avatar setImageWithURL:USER_HEAD_IMG_URL(@"small", cellArticle.avatarURL) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    [Utility addTapGestureRecognizer:avatar withTarget:self action:@selector(goPersonInfo)];
    nameLbl.text = article.userName;
    postTimeLbl.text = article.postTime;
    distanceLbl.text = article.distance;
    [self refreshAudio];
}

-(void)refreshAudio{
    [refrenceView removeFromSuperview];
    [contentView removeFromSuperview];
    [refrenceView removeFromSuperview];
    refrenceView = [[UIView alloc]initWithFrame:CGRectMake(60, 20, 250, 60)];
//    refrenceView.tag = 100;
//    refrenceView.backgroundColor = [UIColor redColor];
    contentView = [[UIView alloc]initWithFrame:CGRectMake(60, 20, 250, 30)];
//    contentView.tag = 101;
    WeLog(@"cell tag:%d myAudioPlay.lastPlayNO%d",self.tag,myAudioPlay.lastPlayNO);
//    //    contentView.backgroundColor = [UIColor redColor];
    if ([cellArticle.media count]) {
        //音频
        UIImageView *mediaImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 35)];
//        mediaImg.contentMode = UIViewContentModeScaleAspectFit;
//        mediaImg.backgroundColor = [UIColor redColor];
        mediaImg.tag = 0;
        
        UILabel *audioLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(55, 0, 40,35)];
        audioLengthLbl.tag = 2;
        [Utility styleLbl:audioLengthLbl withTxtColor:nil withBgColor:nil withFontSize:15];
        audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[cellArticle.mediaInfo objectForKey:[cellArticle.media objectAtIndex:0]] objectForKey:DURATION]];
        CGFloat width;
        if ([[[cellArticle.mediaInfo objectForKey:[cellArticle.media objectAtIndex:0]] objectForKey:DURATION] intValue] < 10) {
            width = 80;
        }else{
            width = [[[cellArticle.mediaInfo objectForKey:[cellArticle.media objectAtIndex:0]] objectForKey:DURATION] intValue]*8;
        }
        mediaImg.frame = CGRectMake(0, 0, width, 35);
        audioLengthLbl.frame = CGRectMake(mediaImg.frame.size.width-30, 0, 40, 35);
        WeLog(@"self.tag%d",self.tag);
        [Utility addTapGestureRecognizer:mediaImg withTarget:self action:@selector(audioPlay:)];
        mediaImg.userInteractionEnabled = YES;
        WeLog(@"正在播放第%d个音频，音频名字%@",myAudioPlay.lastPlayNO,myAudioPlay.lastAudioName);
        WeLog(@"这是第%d个音频,音频名字是%@",self.tag,[cellArticle.media objectAtIndex:0]);
        if ([myAudioPlay.lastAudioName isEqualToString:[cellArticle.media objectAtIndex:0]]&&myAudioPlay.lastPlayNO == self.tag) {
            if (myAudioPlay.player.isPlaying) {
                playingAudioView = mediaImg;
                [self handleVoiceAnimation];
//                [mediaImg setImage:[UIImage imageNamed:@"audio_pause.png"]];
            }else{
                [self reset:mediaImg];
//                [mediaImg setImage:[UIImage imageNamed:@"yinpin.png"]];
            }
        }else{
            [self reset:mediaImg];
//            [mediaImg setImage:[UIImage imageNamed:@"yinpin.png"]];
        }
        [contentView addSubview:mediaImg];
        [mediaImg addSubview:audioLengthLbl];
        refrenceView.frame = CGRectMake(60, 20+30, 250, 60);
    }else{
        //文字
        UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 250, 60)];
        content.text = cellArticle.content;
        content.numberOfLines = 0;
        [Utility styleLbl:content withTxtColor:nil withBgColor:nil withFontSize:18];
        [contentView addSubview:content];
//        CGFloat contentHeight = [Utility getSizeByContent:content.text withWidth:250 withFontSize:16];
        CGFloat contentHeight = [Utility getMixedViewHeight:content.text withWidth:250];
        [self attachString:cellArticle.content toView:content];
        content.text = @"";
        content.frame = CGRectMake(0, 5, 250, contentHeight);
        CGRect cgr = contentView.frame;
        cgr.size.height = contentHeight;
        contentView.frame = cgr;
        refrenceView.frame = CGRectMake(60, 20+contentHeight, 250, 60);
    }
    
    //构建是否有引用
    if (cellArticle.repliedArticle.replyRowkey) {
        if ([cellArticle.repliedArticle.media count]) {
            UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2, 250, 0+15)];
            bg.frame = CGRectMake(-2, 0, 260, 35+15+25);
            //            bg.backgroundColor = [UIColor blueColor];
            bg.image = [[UIImage imageNamed:@"refrence.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:20];
            [refrenceView addSubview:bg];
            UILabel *refrenceUserLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 7, 65, 30)];
            [refrenceUserLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:18]];
            refrenceUserLbl.text = [NSString stringWithFormat:@"回复%@楼%@:",cellArticle.repliedArticle.replyNO,cellArticle.repliedArticle.userName];
            refrenceUserLbl.frame = CGRectMake(5, 13, [Utility getWidthByContent:refrenceUserLbl.text withHeight:30 withFontSize:18], 30);
            [Utility styleLbl:refrenceUserLbl withTxtColor:nil withBgColor:nil withFontSize:18];
            [refrenceView addSubview:refrenceUserLbl];
//            UIImageView *mediaImg = [[UIImageView alloc]initWithFrame:CGRectMake([Utility getWidthByContent:refrenceUserLbl.text withHeight:30 withFontSize:18]+5, 13, 80, 35)];
            UIImageView *mediaImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 13+25, 80, 35)];

//            mediaImg.contentMode = UIViewContentModeScaleAspectFit;
            mediaImg.tag = 1;
            [Utility addTapGestureRecognizer:mediaImg withTarget:self action:@selector(audioPlay:)];
            mediaImg.userInteractionEnabled = YES;
            
            UILabel *audioLengthLbl = [[UILabel alloc]initWithFrame:CGRectMake(55, 0, 40,35)];
            audioLengthLbl.tag = 2;
            [Utility styleLbl:audioLengthLbl withTxtColor:nil withBgColor:nil withFontSize:15];
            audioLengthLbl.text = [NSString stringWithFormat:@"%@''",[[cellArticle.repliedArticle.mediaInfo objectForKey:[cellArticle.repliedArticle.media objectAtIndex:0]] objectForKey:DURATION]];
            [mediaImg addSubview:audioLengthLbl];
            
            CGFloat width;
            if ([audioLengthLbl.text intValue] < 10) {
                width = 80;
            }else{
                width = [audioLengthLbl.text intValue]*8;
            }
            mediaImg.frame = CGRectMake(0, 13+25, width, 35);
            audioLengthLbl.frame = CGRectMake(mediaImg.frame.size.width-30, 0, 40, 35);

            if ([myAudioPlay.lastAudioName isEqualToString:[cellArticle.repliedArticle.media objectAtIndex:0]] &&myAudioPlay.lastPlayNO == self.tag) {
                if (myAudioPlay.player.isPlaying) {
                    playingAudioView = mediaImg;
                    [self handleVoiceAnimation];
//                  [mediaImg setImage:[UIImage imageNamed:@"audio_pause.png"]];
                }else{
                    [self reset:mediaImg];
//                  [mediaImg setImage:[UIImage imageNamed:@"yinpin.png"]];
                }
            }else{
                [self reset:mediaImg];
//              [mediaImg setImage:[UIImage imageNamed:@"yinpin.png"]];
            }
            [refrenceView addSubview:mediaImg];
        }else{
            //文字
            UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 250, 60)];
            content.text = [NSString stringWithFormat:@"回复%@楼%@:%@",cellArticle.repliedArticle.replyNO ,cellArticle.repliedArticle.userName,cellArticle.repliedArticle.content];
            content.numberOfLines = 0;
            [Utility styleLbl:content withTxtColor:nil withBgColor:nil withFontSize:18];
//          CGFloat contentHeight = [Utility getSizeByContent:content.text withWidth:250 withFontSize:18];
            CGFloat contentHeight = [Utility getMixedViewHeight:content.text withWidth:250];
            content.frame = CGRectMake(0, 16, 250, contentHeight);
            CGRect cgr = refrenceView.frame;
            cgr.size.height = contentHeight;
            refrenceView.frame = cgr;
            [self attachString:content.text toView:content];
            content.text = @"";
            
            UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2, 250, contentHeight+15)];
            bg.image = [[UIImage imageNamed:@"refrence.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:20];
            [refrenceView addSubview:bg];
            [refrenceView addSubview:content];
        }
    }
    //播放动画
    [timer invalidate];
    timer = nil;
//    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(handleVoiceAnimation) userInfo:nil repeats:YES];
    timer = [NSTimer timerWithTimeInterval:0.3
                              target:self
                            selector:@selector(handleVoiceAnimation)
                            userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    _voicePicTag = 1;
    
    [self addSubview:refrenceView];
    [self addSubview:contentView];
}


- (void)handleVoiceAnimation
{
    NSString *fileName;
    fileName = [NSString stringWithFormat:@"chat_voice_someone%d",_voicePicTag];
    
    UIImage *voicePic = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"png"]];
//    UIImage * img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"audioBg" ofType:@"png"]];
    playingAudioView.image = [[UIImage imageNamed:@"audioBg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    [self removeSubViews:playingAudioView];
    UIImageView *adImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 3, 30, 30)];
    adImage.image = voicePic;
    adImage.userInteractionEnabled = YES;
    [playingAudioView addSubview:adImage];
    if (_voicePicTag == 4) {
        _voicePicTag = 1;
    }else{
        _voicePicTag++;
    }
}
-(void)reset:(UIImageView *)view{
    [self removeSubViews:view];
//    view.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"audioBg" ofType:@"png"]];
    view.image = [[UIImage imageNamed:@"audioBg.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:20];

    UIImageView *adImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 3, 30, 30)];
    UIImage *voicePic = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_voice_someone4" ofType:@"png"]];
    adImage.image = voicePic;
    adImage.userInteractionEnabled = YES;
    [view addSubview:adImage];
}

-(void)removeSubViews:(UIView *)parentView{
    for (UIView *view in [parentView subviews]) {
        if (view.tag != 2) {
            [view removeFromSuperview];
        }
    }
}

//单独定制的方法，因为它不使用@＃链接
- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self cutMixedString:str];
//    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    UIColor *nameColor = [UIColor blueColor];
    UIColor *labelColor = [UIColor redColor];
    UIColor *linkerColor = [UIColor greenColor];
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
//单独定制的方法，因为它不使用@＃链接
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

//跳到个人信息页
-(void)goPersonInfo{
    PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithUserName:cellArticle.userName];
    [vc.navigationController pushViewController:personInfoView animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
