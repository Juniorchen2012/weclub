//
//  TDCCardViewController.m
//  WeClub
//
//  Created by Archer on 13-4-1.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "TDCCardViewController.h"

@interface TDCCardViewController ()

@end

@implementation TDCCardViewController

@synthesize _strPhotoID;
@synthesize _strSex;
@synthesize _strUserID;
@synthesize _strUserName;
@synthesize bIsCurrentUser;
@synthesize isPerson;
@synthesize club;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    if(self){
        bIsCurrentUser = true;
        isPerson = true;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"二维码名片";
    self.navigationItem.titleView = headerLabel;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIButton *operateBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [operateBtn setTitle:@"操作" forState:UIControlStateNormal];
    [operateBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    [operateBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [operateBtn addTarget:self action:@selector(operate) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:operateBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    AccountUser *user ;
    if (bIsCurrentUser) {
        user = [AccountUser getSingleton];
    }
    
    UIImageView *whiteBgView = [[UIImageView alloc] init];
    whiteBgView.frame = CGRectMake((screenSize.width-260)/2, screenSize.height/2 - 30- 170-16, 260, 340+32);
    whiteBgView.backgroundColor = [UIColor whiteColor];
    whiteBgView.layer.cornerRadius = 5;
    [self.view addSubview:whiteBgView];
    
    UIView *mainView = [[UIView alloc] init];
    mainView.frame = whiteBgView.frame;
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];
    
    UIImageView *headView = [[UIImageView alloc] init];
    headView.frame = CGRectMake(15, 15, 60, 60);
    headView.backgroundColor = [UIColor grayColor];
    NSString *photoID = [AccountUser getSingleton].photoID;
    if (isPerson) {
        if ([[AccountUser getSingleton].sex isEqualToString:@"0"]) {
            [headView setImageWithURL:USER_HEAD_IMG_URL_TIME(@"small", bIsCurrentUser ?photoID : _strPhotoID,[AccountUser getSingleton].photoTime) placeholderImage:[UIImage imageNamed:@"male_holder.png"]];
            ;
        }else{
            [headView setImageWithURL:USER_HEAD_IMG_URL_TIME(@"small", bIsCurrentUser ?photoID : _strPhotoID,[AccountUser getSingleton].photoTime) placeholderImage:[UIImage imageNamed:@"female_holder.png"]];
        }
    }else{
        [headView setImageWithURL:ClubImageURL(([NSString stringWithFormat:@"%@0_p",club.ID]),TYPE_THUMB) placeholderImage:[UIImage imageNamed:LOGO_PIC_HOLDER]];
    }
    [mainView addSubview:headView];
    [Utility addTapGestureRecognizer:mainView withTarget:self action:@selector(share)];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(82, 15, 160, 20);
    if (isPerson) {
        nameLabel.text = bIsCurrentUser ? user.name : _strUserName;
    }else{
        nameLabel.text = club.name;
    }
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = [UIColor grayColor];
    nameLabel.font = [UIFont systemFontOfSize:18. ];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.backgroundColor = [UIColor clearColor];
    [mainView addSubview:nameLabel];
    
    UILabel *birthdayLabel = [[UILabel alloc] init];
    birthdayLabel.frame = CGRectMake(82, 36, 160, 20);
    birthdayLabel.text = [[NSString alloc] initWithFormat:@"年代:%@",myAccountUser.birthday];
    birthdayLabel.font = [UIFont systemFontOfSize:15];
    birthdayLabel.textAlignment = NSTextAlignmentLeft;
    birthdayLabel.textColor = [UIColor grayColor];
    birthdayLabel.backgroundColor = [UIColor clearColor];
    if (isPerson) {
        [mainView addSubview:birthdayLabel];
    }
    
    UIImageView *sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(200, 45, 30, 30)];
    NSString *sex = bIsCurrentUser ? myAccountUser.sex : _strSex;
    if ([sex isEqualToString:@"0"]) {
        sexImg.image = [UIImage imageNamed:@"user_male.png"];
    }else if ([sex isEqualToString:@"1"]){
        sexImg.image = [UIImage imageNamed:@"user_female.png"];
    }
    if (isPerson) {
        [mainView addSubview:sexImg];
    }
    
    UILabel *IDLabel = [[UILabel alloc] init];
    if (isPerson) {
        IDLabel.frame = CGRectMake(82, 57, 100, 20);
        IDLabel.text = [NSString stringWithFormat:@"ID号:%@",bIsCurrentUser ? user.numberID : _strUserID];
    }else{
        IDLabel.frame = CGRectMake(82, 36, 160, 20);
        IDLabel.text = [NSString stringWithFormat:@"ID:%@",club.ID];
    }
    IDLabel.textAlignment = NSTextAlignmentLeft;
    IDLabel.textColor = [UIColor grayColor];
    IDLabel.font = [UIFont systemFontOfSize:15];
    IDLabel.backgroundColor = [UIColor clearColor];
    [mainView addSubview:IDLabel];
    
    tdcHeadView = [[UIImageView alloc] init];
    tdcHeadView.frame = CGRectMake(116, 116, 30, 30);
    tdcHeadView.layer.masksToBounds = YES;
    tdcHeadView.layer.cornerRadius = 5;
    if (isPerson) {
        if ([sex isEqualToString:@"0"]) {
            [tdcHeadView setImageWithURL:USER_HEAD_IMG_URL_TIME(@"small", bIsCurrentUser ?photoID : _strPhotoID,[AccountUser getSingleton].photoTime) placeholderImage:[UIImage imageNamed:@"male_holder.png"]];
        }else if ([sex isEqualToString:@"1"]){
            [tdcHeadView setImageWithURL:USER_HEAD_IMG_URL_TIME(@"small", bIsCurrentUser ?photoID : _strPhotoID,[AccountUser getSingleton].photoTime) placeholderImage:[UIImage imageNamed:@"female_holder.png.png"]];
        }
    }else{
        [tdcHeadView setImageWithURL:ClubImageURL(([NSString stringWithFormat:@"%@0_p",club.ID]),TYPE_THUMB) placeholderImage:[UIImage imageNamed:LOGO_PIC_HOLDER]];
    }
    
    tdcView = [[UIImageView alloc] init];
    tdcView.frame = CGRectMake(-1, 80, 230+32, 230+32);
    if (isPerson) {
        tdcView.image = [QRCodeGenerator qrImageForString:CREATE_TDCSTRING(@"2", bIsCurrentUser ? user.numberID : _strUserID) imageSize:tdcView.bounds.size.width*2];
    }else{
        tdcView.image = [QRCodeGenerator qrImageForString:club.qrText imageSize:tdcView.bounds.size.width*2];
    }
    [mainView addSubview:tdcView];
    [tdcView addSubview:tdcHeadView];

    
    UILabel *scanLabel = [[UILabel alloc] init];
    scanLabel.frame = CGRectMake(0 ,mainView.frame.size.height-40, mainView.frame.size.width, 20);
    scanLabel.text = @"扫描上方的二维码关注我";
    scanLabel.textColor = [UIColor grayColor];
    scanLabel.textAlignment = NSTextAlignmentCenter;
    scanLabel.font = [UIFont boldSystemFontOfSize:14];
    scanLabel.backgroundColor = [UIColor clearColor];
    if (isPerson) {
        [mainView addSubview:scanLabel];
    }
    
	// Do any additional setup after loading the view.
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1) {
        if (0 == buttonIndex) {
            //[self share];
            [ShareSDKManager shareTDCCardWithRightBarItem:self.navigationItem.rightBarButtonItem andTDCHeadImage:tdcHeadView.image andTDCImage:tdcView.image];
        }else if (1 == buttonIndex){
            NSString *photoID = [AccountUser getSingleton].photoID;
            AccountUser *user = [AccountUser getSingleton];
            UIImage *qrImg = [self addImage:tdcHeadView.image toImage:tdcView.image];
            UIImageWriteToSavedPhotosAlbum(qrImg, nil, nil, nil);
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        }else if (2 == buttonIndex){                //扫描二维码
            [self scan];
        }
    }
    return;
}

-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image2.size);
    
    //Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    //Draw image1
    [image1 drawInRect:CGRectMake((image2.size.width-image1.size.width/2)/2, (image2.size.height-image1.size.height/2)/2, image1.size.width/2, image1.size.height/2)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

-(void)share{
    NSString *content;
    NSString *url;
    UIImage *image;
    NSMutableArray *shareList;
    NSArray* _shareTypeArray;
    content = nil;
    url = nil;
    image = nil;
    SSPublishContentMediaType mediaType = SSPublishContentMediaTypeText;
    switch (1)
    {
        case 0:
            content = @"haha";
            break;
        case 1:
            content = @"我在玩微俱，阅读%@的帖子,快快加入我们吧，https://itunes.apple.com/cn/app/id348147113?mt=8";
            image = [self addImage:tdcHeadView.image toImage:tdcView.image];//默认加版标
            mediaType = SSPublishContentMediaTypeImage;
            break;
        default:
            break;
    }
    
    _shareTypeArray = [NSMutableArray arrayWithObjects:
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"新浪微博",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeSinaWeibo],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"腾讯微博",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeTencentWeibo],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"QQ空间",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeQQSpace],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"人人网",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeRenren],
                        @"type",
                        nil],
                       
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"微信",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeWeixiSession],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"Google+",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeGooglePlus],
                        @"type",
                        nil],
                       
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"LinkedIn",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeLinkedIn],
                        @"type",
                        nil],
                       
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"Facebook",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeFacebook],
                        @"type",
                        nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"Twitter",
                        @"title",
                        [NSNumber numberWithBool:YES],
                        @"selected",
                        [NSNumber numberWithInteger:ShareTypeTwitter],
                        @"type",
                        nil],
                       
                       nil];
    shareList = [[NSMutableArray alloc]init];
    for (int i = 0; i < [_shareTypeArray count]; i++)
    {
        NSDictionary *item = [_shareTypeArray objectAtIndex:i];
        if([[item objectForKey:@"selected"] boolValue])
        {
            [shareList addObject:[NSNumber numberWithInteger:[[item objectForKey:@"type"] integerValue]]];
        }
    }
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"avatarPlaceHolder" ofType:@"png"];
    
    //}
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStylePopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    id<ISSShareOptions> shareViewOptions = [ShareSDK simpleShareOptionsWithTitle:@"内容分享" shareViewDelegate:nil];
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithBarButtonItem:self.navigationItem.rightBarButtonItem arrowDirect:UIPopoverArrowDirectionAny];
    
    //创建内容
    id<ISSCAttachment> imageAttach = [ShareSDK imageWithPath:imagePath];
    id<ISSContent> contentObj = [ShareSDK content:content
                                   defaultContent:@""
                                            image:[ShareSDK pngImageWithImage:[self addImage:tdcHeadView.image toImage:tdcView.image]]
                                            title:@"微俱"
                                              url:ITUNES_URL
                                      description:@"这是一条测试信息"
                                        mediaType:SSPublishContentMediaTypeNews];
    
    //显示分享选择菜单
    [ShareSDK showShareActionSheet:container
                         shareList:[ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeTencentWeibo,ShareTypeWeixiTimeline,ShareTypeRenren ,ShareTypeWeixiSession,ShareTypeGooglePlus,ShareTypeLinkedIn,ShareTypeFacebook,ShareTypeTwitter, nil]
                           content:contentObj
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:shareViewOptions
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    [Utility addShareList:type];
                                    NSString *msg = nil;
                                    NSString *dest;
                                    switch (type)
                                    {
                                        case ShareTypeAirPrint:
                                            msg = @"打印成功";
                                            break;
                                        case ShareTypeCopy:
                                            msg = @"拷贝成功";
                                            break;
                                        case ShareTypeSinaWeibo:
                                            dest = @"新浪微博";
                                            break;
                                        case ShareTypeTencentWeibo:
                                            dest = @"腾讯微博";
                                            break;
                                        case ShareTypeWeixiTimeline:
                                            dest = @"微信朋友圈";
                                            break;
                                        case ShareTypeRenren:
                                            dest = @"人人网";
                                            break;
                                        case ShareTypeWeixiSession:
                                            dest = @"微信";
                                            break;
                                        case ShareTypeLinkedIn:
                                            dest = @"LinkedIn";
                                            break;
                                        default:
                                            break;
                                    }
                                }                                
                            }];
    
}

-(void)operate{
    UIActionSheet *ac = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享二维码",@"保存二维码",@"扫描二维码", nil];
    ac.tag = 1;
    [ac showInView:self.navigationController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark 扫描二维码实现
//执行扫描功能

- (void)scan{
    UINavigationController *reader = [[ZBarManager sharedZBarManager]getReaderWithDelegate:self helpStr:@"请扫描微俱用户"];
    [ZBarManager sharedZBarManager].helpFlag = @"1";
    [self presentModalViewController:reader animated:YES];
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
}

//扫描后数据处理
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    NSString *s = [[Utility qrAnalyse:symbol.data] objectForKey:@"type"];
    if ( 2 == [s intValue]) {
        PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        personInfoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personInfoView animated:YES];
    }else if (1 == [s intValue]){
        ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"]];
        clubInfoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:clubInfoView animated:YES];
    }else{
        UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:symbol.data] objectForKey:@"id"] AndTitle:@"扫描二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
        alert.tag = 1;
        qrText = [[Utility qrAnalyse:symbol.data] objectForKey:@"id"];
    }
    
    [[ZBarManager sharedZBarManager] back];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([ZBarManager sharedZBarManager].scanFlag != 0) {
        return;
    }
    [[ZBarManager sharedZBarManager] back];
    [ZBarManager sharedZBarManager].scanFlag++;
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *code =[(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            NSString *s = [[Utility qrAnalyse:code] objectForKey:@"type"];
            if ( 2 == [s intValue]) {
                PersonInfoViewController *personInfoView = [[PersonInfoViewController alloc]initWithNumberID:[[Utility qrAnalyse:code] objectForKey:@"id"]];
                personInfoView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:personInfoView animated:YES];
            }else if (1 == [s intValue]){
                ClubInfoViewController *clubInfoView = [[ClubInfoViewController alloc]initWithClubRowKey:[[Utility qrAnalyse:code] objectForKey:@"id"]];
                clubInfoView.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:clubInfoView animated:YES];
            }else{
                UIAlertView *alert = [Utility MsgBox:[[Utility qrAnalyse:code] objectForKey:@"id"] AndTitle:@"扫瞄二维码" AndDelegate:self AndCancelBtn:@"取消" AndOtherBtn:@"拷贝" withStyle:0];
                alert.tag = 1;
                qrText = [[Utility qrAnalyse:code] objectForKey:@"id"];
                
            }

        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == alertView.tag) {
        if (1 == buttonIndex) {
            [self copy:qrText];             //拷贝信息到粘贴板
        }else{
            return;
        }
    }
    return;
}


//拷贝函数执行
-(void)copy:(NSString*)str {
    
    NSString *copyString = [[NSString alloc] initWithFormat:@"%@",str];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:copyString];
}

@end
