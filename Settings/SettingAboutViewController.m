//
//  SettingAboutViewController.m
//  WeClub
//
//  Created by Archer on 13-4-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "SettingAboutViewController.h"

@interface SettingAboutViewController ()

@end

@implementation SettingAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    //订制导航条
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 100, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"关于";
    self.navigationItem.titleView = headerLabel;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-64) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView.alpha = 0;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissStartPageView:)
                                                 name:@"CHANGEVIEW"
                                               object:nil];
	// Do any additional setup after loading the view.
}


-(void)dismissStartPageView:(NSNotification *)notification{
    if ([notification.object intValue]) {
        [self dismissModalViewControllerAnimated:YES];
    }
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

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 5;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 42;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0){
        cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        
        if (indexPath.row == 0) {
          //  cell.textLabel.text = @"去评分";
            cell.textLabel.text = @"版本更新";
        }else if (indexPath.row == 1){
            //cell.textLabel.text = @"最新版本";
            cell.textLabel.text = @"意见反馈";
        }else if (indexPath.row == 2){
           // cell.textLabel.text = @"引导页面";
            cell.textLabel.text = @"帮助/faq";
        }else if (indexPath.row == 3){
            //cell.textLabel.text = @"意见反馈";
            cell.textLabel.text = @"欢迎页回顾";
        }else if (indexPath.row == 4){
            //cell.textLabel.text = @"帮助/faq";
            cell.textLabel.text = @"打分";
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Weclub1.png"]];
        image.frame = CGRectMake(240/2, 20, screenSize.width - 240, screenSize.width - 240);
        [view addSubview:image];
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"版本:  v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey] ];
        label.frame = CGRectMake(0, image.frame.origin.y + image.frame.size.height + 10, screenSize.width, 30);
        label.font = [UIFont systemFontOfSize:15];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [view addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.text = @"版权所有 未名空间(mitbbs.com) since 1996";
        label2.textAlignment = NSTextAlignmentCenter;
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor grayColor];
        label2.font = [UIFont systemFontOfSize:13];
        label2.frame = CGRectMake(0, label.frame.origin.y + label.frame.size.height + 10, screenSize.width, 30);
        [view addSubview:label2];
        return view;
    }
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 190;
    }
    return 0;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=587767923"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
        }else if (indexPath.row == 0){
            [Utility checkVersion];
        }else if (indexPath.row == 3){
            StartPageViewController *startPageView = [[StartPageViewController alloc]init];
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:@"1" forKey:@"pushStartPage"];
            [ud synchronize];
            startPageView.flag = @"1";
            [self presentModalViewController:startPageView animated:YES];
        }else if (indexPath.row == 1){
            ClubViewController *clubView = [[ClubViewController alloc]init];
            Club *sysclub = [[Club alloc]init];
            clubView.club = sysclub;
            [self.navigationController pushViewController:clubView animated:YES];
            //        [self sendEMail];
        }else if (indexPath.row == 2){
            AboutViewController *about = [[AboutViewController alloc]initWithContentType:@"0"];
            [self.navigationController pushViewController:about animated:YES];
        }
        
    }
}

//点击按钮后，触发这个方法
-(void)sendEMail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}
//可以发送邮件的话
-(void)displayComposerSheet
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:@"Arial" size:20]];
    titleLbl.text = @"意见反馈";
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
    titleLbl.textColor = NAVIFONT_COLOR;
    titleLbl.backgroundColor = [UIColor clearColor];
    mailPicker.navigationItem.titleView = titleLbl;
    
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    mailPicker.navigationItem.leftBarButtonItem = backbtn;
    
    
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"意见反馈(ios)"];
    
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObject: @"weclub2013@163.com"];
    //NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com", nil];
    [mailPicker setToRecipients: toRecipients];
    //[picker setCcRecipients:ccRecipients];
    //[picker setBccRecipients:bccRecipients];
    
    // 添加图片
    UIImage *addPic = [UIImage imageNamed: @"123.jpg"];
    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
    // NSData *imageData = UIImageJPEGRepresentation(addPic, 1);    // jpeg
    // [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"123.jpg"];
    
    NSString *emailBody = @"eMail 正文";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    [self presentModalViewController: mailPicker animated:YES];
}
-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:weclub2013@163.com&subject=my email!";
    //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=my email!";
    NSString *body = @"&body=email body!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            [Utility MsgBox:msg];
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            [Utility MsgBox:msg];
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
