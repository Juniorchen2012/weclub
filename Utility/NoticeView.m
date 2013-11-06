//
//  NoticeView.m
//  WeClub
//
//  Created by Archer on 13-4-9.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "NoticeView.h"

#define CLUB_FOLLOW -100
#define CLUB_ATTENTION -101
#define USER_ATTENTION -200
#define USER_FOLLOW -201
#define NOTICE_HEIGHT 33
#define BGVIEW_TAG 201

@implementation NoticeView

@synthesize noticeButton = _noticeButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_noticeType forKey:@"noticeType"];
    [aCoder encodeObject:_adoptClubId forKey:@"adoptClubId"];
    [aCoder encodeObject:_noticeButton forKey:@"noticeButton"];
    [aCoder encodeInt:_noticeNumber forKey:@"noticeNumber"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.noticeButton = (UIButton *)[aDecoder decodeObjectForKey:@"noticeButton"];
        self.adoptClubId = (NSString *)[aDecoder decodeObjectForKey:@"adoptClubId"];
        self.noticeNumber = [aDecoder decodeIntForKey:@"noticeNumber"];
        self.noticeType = (NSString *)[aDecoder decodeObjectForKey:@"noticeType"];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"noticeview dealloc");
    _noticeType = nil;
}

- (id)initWithNumber:(int)number andType:(NSString *)type
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, NOTICE_HEIGHT)];
    if (self) {
        _noticeNumber = number;
        _noticeType = type;
//        self.layer.borderColor = [UIColor grayColor].CGColor;
//        self.layer.borderWidth = 1;
//        self.layer.shadowOffset = CGSizeMake(0, 3);
//        self.layer.shadowRadius = 5.0;
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 0.8;
        self.backgroundColor = [UIColor whiteColor];
        
        //背景
        UIImageView *bgView = [[UIImageView alloc] init];
        bgView.frame = CGRectMake(0, 0, 320, NOTICE_HEIGHT);
        bgView.backgroundColor = TINT_COLOR;
        bgView.tag = BGVIEW_TAG;
        //bgView.layer.cornerRadius = 5;
        [self addSubview:bgView];
        bgView = nil;
        UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, NOTICE_HEIGHT-1, 320, 1)];
        sliderView.backgroundColor = [UIColor grayColor];
        sliderView.alpha = 0.5;
        [self addSubview:sliderView];
        sliderView = nil;
        
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(286, 8, 20, 20)];
        circleView.layer.cornerRadius = 10;
        circleView.layer.backgroundColor = [UIColor grayColor].CGColor;
        
        UILabel *label = [[UILabel alloc] init];
        if (iosVersion >= 7) {
            label.frame = CGRectMake(4, 2, 13, 13);
        }else{
            label.frame = CGRectMake(4, 3, 13, 13);
        }
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"×";
        label.font = [UIFont boldSystemFontOfSize:20];
        [circleView addSubview:label];
        label = nil;
        
        //清除按钮
        UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        removeButton.frame = CGRectMake(290, 0, NOTICE_HEIGHT, NOTICE_HEIGHT);
        removeButton.backgroundColor = [UIColor clearColor];
 //       removeButton.layer.cornerRadius = 13;
        [removeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        removeButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
//        [removeButton setTitle:@"×" forState:UIControlStateNormal];
        removeButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [removeButton addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];

        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notice_close.png"]];
        image.frame = CGRectMake(290, 5, 20, 20);
        
        
        //跳转按钮
        _noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
       
        _noticeButton.backgroundColor = [UIColor clearColor];
        [_noticeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _noticeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _noticeButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_noticeButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [_noticeButton addTarget:self action:@selector(buttonPressReset:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragOutside |UIControlEventTouchDragExit];
        [self addSubview:_noticeButton];

        if (number == CLUB_FOLLOW) {
            _noticeButton.frame = CGRectMake(10, 0, 300, NOTICE_HEIGHT);
            [_noticeButton setTitle:@"导入了mitbbs中您加入的俱乐部" forState:UIControlStateNormal];
            [_noticeButton addTarget:self action:@selector(clubFollow) forControlEvents:UIControlEventTouchUpInside];
            [_noticeButton addSubview:image];
        }else if(number == CLUB_ATTENTION) {
            _noticeButton.frame = CGRectMake(10, 0, 300, NOTICE_HEIGHT);
            [_noticeButton setTitle:@"导入了mitbbs中您收藏的版面与俱乐部" forState:UIControlStateNormal];
            [_noticeButton addTarget:self action:@selector(clubAttention) forControlEvents:UIControlEventTouchUpInside];
            [_noticeButton addSubview:image];
        }else if (number == USER_ATTENTION) {
            _noticeButton.frame = CGRectMake(10, 0, 300, NOTICE_HEIGHT);
            [_noticeButton setTitle:@"导入了mitbbs中您的好友名单" forState:UIControlStateNormal];
            [_noticeButton addTarget:self action:@selector(userAttention) forControlEvents:UIControlEventTouchUpInside];
            [_noticeButton addSubview:image];
        }else if ([type isEqualToString:@"bbsUserFollow"]) {
            _noticeButton.frame = CGRectMake(10, 0, 300, NOTICE_HEIGHT);
            [_noticeButton setTitle:[NSString stringWithFormat:@"导入了mitbbs中关注您的%d个会员",number] forState:UIControlStateNormal];
            self.noticeNumber = number;
            [_noticeButton addTarget:self action:@selector(userFollow) forControlEvents:UIControlEventTouchUpInside];
            [_noticeButton addSubview:image];
        }else{
             _noticeButton.frame = CGRectMake(10, 0, 280, NOTICE_HEIGHT);
            [_noticeButton setTitle:[NSString stringWithFormat:@"您有%d条新消息未处理",_noticeNumber] forState:UIControlStateNormal];
            [_noticeButton addTarget:self action:@selector(showInformCenter) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:circleView];
            [self addSubview:removeButton];
        }
        image = nil;
        circleView = nil;
    }
    return self;
}

- (id)initClubAdopt:(NSDictionary *)dic
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, NOTICE_HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _adoptClubId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"clubid"]];
        //背景
        UIImageView *bgView = [[UIImageView alloc] init];
        bgView.frame = CGRectMake(0, 0, 320, NOTICE_HEIGHT);
//        bgView.backgroundColor = [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1];
        bgView.backgroundColor = TINT_COLOR;
        bgView.tag = BGVIEW_TAG;
        //bgView.layer.cornerRadius = 5;
        [self addSubview:bgView];
        bgView = nil;
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notice_close.png"]];
        image.frame = CGRectMake(290, 5, 20, 20);
        
        //跳转按钮
        _noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _noticeButton.frame = CGRectMake(10, 0, 290, NOTICE_HEIGHT);
        _noticeButton.backgroundColor = [UIColor clearColor];
        [_noticeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _noticeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _noticeButton.titleLabel.font = [UIFont systemFontOfSize:17];
        NSString *clubName = [[[dic objectForKey:@"tips"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]] objectAtIndex:1];
//        _tips = [dic objectForKey:@"tips"];
        if (clubName.length > 9) {
            clubName = [clubName substringToIndex:8];
            clubName = [NSString stringWithFormat:@"%@...",clubName];
        }
        _tips = [NSString stringWithFormat:@"俱乐部[%@]已被领取",clubName];
        [_noticeButton setTitle:_tips forState:UIControlStateNormal];
        [_noticeButton addTarget:self action:@selector(inputClub) forControlEvents:UIControlEventTouchUpInside];
        [_noticeButton addSubview:image];
        [_noticeButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [_noticeButton addTarget:self action:@selector(buttonPressReset:) forControlEvents: UIControlEventTouchUpOutside | UIControlEventTouchDragOutside |UIControlEventTouchDragExit];
        [self addSubview:_noticeButton];
        image = nil;
        
        UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, NOTICE_HEIGHT-1, 320, 1)];
        sliderView.backgroundColor = [UIColor grayColor];
        sliderView.alpha = 0.5;
        [self addSubview:sliderView];
        sliderView = nil;
    }
    return self;
}

- (id)initReconnectedWithDic:(NSDictionary *)dic
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, NOTICE_HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        //背景
        UIImageView *bgView = [[UIImageView alloc] init];
        bgView.frame = CGRectMake(0, 0, 320, NOTICE_HEIGHT);
        //        bgView.backgroundColor = [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1];
        bgView.backgroundColor = TINT_COLOR;
        bgView.tag = BGVIEW_TAG;
        //bgView.layer.cornerRadius = 5;
        [self addSubview:bgView];
        bgView = nil;
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notice_close.png"]];
        image.frame = CGRectMake(290, 5, 20, 20);
        
        //跳转按钮
        _noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _noticeButton.frame = CGRectMake(10, 0, 290, NOTICE_HEIGHT);
        _noticeButton.backgroundColor = [UIColor clearColor];
        [_noticeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _noticeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _noticeButton.titleLabel.font = [UIFont systemFontOfSize:17];

        [_noticeButton setTitle:@"重连接" forState:UIControlStateNormal];
        [_noticeButton addSubview:image];
        [_noticeButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [_noticeButton addTarget:self action:@selector(buttonPressReset:) forControlEvents: UIControlEventTouchUpOutside | UIControlEventTouchDragOutside |UIControlEventTouchDragExit];
        [self addSubview:_noticeButton];
        image = nil;
        
        UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, NOTICE_HEIGHT-1, 320, 1)];
        sliderView.backgroundColor = [UIColor grayColor];
        sliderView.alpha = 0.5;
        [self addSubview:sliderView];
        sliderView = nil;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)userAttention
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_ATTENTIONLIST object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_USERLIST object:[NSNumber numberWithInt:0]];
    if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsUserAttention"]) {
        [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsUserAttention"];
    }
}

- (void)userFollow
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_USERLIST object:[NSNumber numberWithInt:1]];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_FOLLOWLIST object:nil];
    if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsUserFollow"]) {
        [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsUserFollow"];
    }
}

- (void)clubAttention
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.tag = 2;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"attention_club_list" object:btn];
    if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsClubAttention"]) {
        [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsClubAttention"];
    }
}

- (void)clubFollow
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.tag = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_JOINCLUBLIST object:btn];
    if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsClubFollow"]) {
        [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsClubFollow"];
    }
}

- (void)inputClub
{
    Club *newClub = [[Club alloc] init];
    newClub.ID = _adoptClubId;
    ClubViewController *clubView = [[ClubViewController alloc]init];
    clubView.club = newClub;//此时这个变量已经有因为已经执行了init函数所有变量都声明了，还没有实例化
    newClub = nil;
    clubView.hidesBottomBarWhenPushed = YES;//一定在跳转之前，设置才管用
    clubView.isPushFromNewClub = YES;
    ClubListViewController *oneController = ((TabBarController *)((AppDelegate *)[UIApplication sharedApplication].delegate).TabC).clublist;
    [oneController.navigationController pushViewController:clubView animated:YES];
    oneController = nil;
    [self removeAdoptNotice];
}

- (void)remove
{
    [self removeFromSuperview];
    [[NoticeManager sharedNoticeManager] resetNoticeWithType:_noticeType];
}

- (void)removeAdoptNotice
{
    //[self removeFromSuperview];
    [[NoticeManager sharedNoticeManager] resetClubAdoptNoticeWithId:_adoptClubId];
}

- (void)showInformCenter
{
    [self remove];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_NOTICECENTER object:[_noticeType copy]];
    
}

-(void)buttonPress:(id)sender{
    UIImageView *view = (UIImageView *)[self viewWithTag:BGVIEW_TAG];
    view.backgroundColor = [UIColor whiteColor];
    view = nil;
}

-(void)buttonPressReset:(id)sender{
    UIImageView *view = (UIImageView *)[self viewWithTag:BGVIEW_TAG];
    view.backgroundColor = TINT_COLOR;
    view = nil;
}

@end
