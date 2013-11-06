//
//  ScanUserInfoView.m
//  WeClub
//
//  Created by mitbbs on 13-8-13.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ScanUserInfoView.h"

@implementation ScanUserInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        _name = [dic objectForKey:@"name"];
        _photoID = [dic objectForKey:@"photo"];
        _sex = [dic objectForKey:@"sex"];
        _userId = [dic objectForKey:@"numberid"];
        _birthday = [dic objectForKey:@"birthday"];
    }
    return self;
}

- (id)initWithBBSUser
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)show
{
    [self infoLayout];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
    animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.duration = 0.5;
    [_showView.layer addAnimation:animation forKey:@"bouce"];
}

- (void)BBSUserShow
{
    [self BBSLayout];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
    animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.duration = 0.5;
    [_showView.layer addAnimation:animation forKey:@"bouce"];
}

- (void)infoLayout
{
    self.backgroundColor = [UIColor clearColor];
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.5;
    [self addSubview:_bgView];
    _showView = [[UIView alloc] initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height/2-100, 280, 200)];
    _showView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_showView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 20)];
    label.text = @"注册后将自动关注该用户";
    label.textAlignment = NSTextAlignmentCenter;
    [_showView addSubview:label];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 40, 80, 80)];
    [[SDImageCache sharedImageCache] removeImageForKey:[USER_HEAD_IMG_URL(@"small", _photoID) absoluteString]];
    [imageView setImageWithURL:USER_HEAD_IMG_URL(@"small", _photoID) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
    [_showView addSubview:imageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 40, 145, 20)];
    nameLabel.text = [NSString stringWithFormat:@"%@",_name];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.font = [UIFont systemFontOfSize:18];
    [_showView addSubview:nameLabel];
    
    UILabel *birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 70, 100, 20)];
    birthdayLabel.text = [[NSString alloc] initWithFormat:@"年代:%@",_birthday];
    birthdayLabel.font = [UIFont systemFontOfSize:15];
    birthdayLabel.backgroundColor = [UIColor clearColor];
    [_showView addSubview:birthdayLabel];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 100, 100, 20)];
    numberLabel.text = [[NSString alloc] initWithFormat:@"ID号:%@",_userId];
    numberLabel.font = [UIFont systemFontOfSize:15];
    numberLabel.backgroundColor = [UIColor clearColor];
    [_showView addSubview:numberLabel];
    
    UIImageView *sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(225, 85, 30, 30)];
    sexImg.backgroundColor = [UIColor clearColor];
    if ([_sex isEqualToString:@"0"]) {
        sexImg.image = [UIImage imageNamed:@"user_male.png"];
    }else if ([_sex isEqualToString:@"1"]){
        sexImg.image = [UIImage imageNamed:@"user_female.png"];
    }
    [_showView addSubview:sexImg];
    _showView.layer.cornerRadius = 5;
    _showView.layer.shadowRadius = 8;
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(35, 140, 80, 30);
    [okBtn addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTitle:@"确  定" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    okBtn.layer.cornerRadius = 5;
    [_showView addSubview:okBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(160, 140, 80, 30);
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取  消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius = 5;
    [_showView addSubview:cancelBtn];
}

- (void)regist
{
    BBSRegisterViewController *BBSRegister = [[BBSRegisterViewController alloc] initWithOtherNumberid:self.scanNumber];
    [self.loginController.navigationController pushViewController:BBSRegister animated:YES];
    [self removeFromSuperview];
}

- (void)BBSLayout
{
    AccountUser *user = [AccountUser getSingleton];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.backgroundColor = [UIColor clearColor];
    _bgView = [[UIView alloc] initWithFrame:self.bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.5;
    [self addSubview:_bgView];
    
    _showView = [[UIView alloc] init];
    _showView.frame = CGRectMake((screenSize.width-260)/2, screenSize.height/2 - 30- 140, 260, 340);
    _showView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_showView];
    
    UIImageView *headView = [[UIImageView alloc] init];
    headView.frame = CGRectMake(15, 15, 60, 60);
    headView.backgroundColor = [UIColor grayColor];
    [headView setImageWithURL:USER_HEAD_IMG_URL(@"small", user.photoID)];
    [_showView addSubview:headView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(82, 15, 140, 20);
    nameLabel.text = user.name;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = [UIColor grayColor];
    nameLabel.font = [UIFont systemFontOfSize:18];
    nameLabel.backgroundColor = [UIColor clearColor];
    [_showView addSubview:nameLabel];
    
    UIImageView *sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(200, 45, 30, 30)];
    NSString *sex = user.sex;
    if ([sex isEqualToString:@"0"]) {
        sexImg.image = [UIImage imageNamed:@"user_male.png"];
    }else if ([sex isEqualToString:@"1"]){
        sexImg.image = [UIImage imageNamed:@"user_female.png"];
    }
    [_showView addSubview:sexImg];
    
    UILabel *IDLabel = [[UILabel alloc] init];
    IDLabel.frame = CGRectMake(82, 55, 100, 20);
    IDLabel.text = [NSString stringWithFormat:@"ID号:%@",user.numberID];
    IDLabel.textAlignment = NSTextAlignmentLeft;
    IDLabel.textColor = [UIColor grayColor];
    IDLabel.font = [UIFont systemFontOfSize:16];
    IDLabel.backgroundColor = [UIColor clearColor];
    [_showView addSubview:IDLabel];
    
    
    UIImageView *tdcHeadView = [[UIImageView alloc] init];
    tdcHeadView.frame = CGRectMake(100, 100, 30, 30);
    tdcHeadView.layer.masksToBounds = YES;
    tdcHeadView.layer.cornerRadius = 5;
    [tdcHeadView setImageWithURL:USER_HEAD_IMG_URL(@"small", user.photoID)];
    
    UIImageView *tdcView = [[UIImageView alloc] init];
    tdcView.frame = CGRectMake(15, 80, 230, 230);
    tdcView.image = [QRCodeGenerator qrImageForString:CREATE_TDCSTRING(@"2", user.numberID) imageSize:tdcView.bounds.size.width*2];
    [_showView addSubview:tdcView];
    [tdcView addSubview:tdcHeadView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 300, 180, 30)];
    label.text = @"上面是您的二维码名片";
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:16];
    [_showView addSubview:label];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(200, 303, 45, 20);
    okBtn.backgroundColor = [UIColor whiteColor];
    okBtn.layer.borderColor = [UIColor blackColor].CGColor;
    okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    okBtn.layer.borderWidth = 1;
    [okBtn addTarget:self action:@selector(adoptClub) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTitle:@"确  定" forState:UIControlStateNormal];
    [okBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    okBtn.layer.cornerRadius = 5;
    [_showView addSubview:okBtn];
    
}

- (void)adoptClub
{
    if (self.adoptFlag == nil || [self.adoptFlag isEqualToString:@"0"]) {
        //            UIAlertView *alert = [Utility MsgBox:@"创建一个属于您的俱乐部" AndTitle:@"提示" AndDelegate:self AndCancelBtn:nil AndOtherBtn:@"是" withStyle:0];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"创建一个属于您的俱乐部" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 102;
        [alert show];
    }else{
        PostListViewController *postList = [[PostListViewController alloc] initWithType:2];
        [self.BBSController.navigationController pushViewController:postList animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        TabBarController *_tabC = [[TabBarController alloc] init];
        ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC = _tabC;
        self.BBSController.navigationController.navigationBarHidden = YES;
        ClubListViewController *clubList = (ClubListViewController *)_tabC.nav1.visibleViewController;
        [clubList newClub];
        [self.BBSController.navigationController pushViewController:_tabC animated:YES];
        [self removeFromSuperview];

    }
}

- (void)cancel
{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}
*/

@end
