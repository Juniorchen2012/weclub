//
//  ChangePersonInfoViewController.m
//  WeClub
//
//  Created by Archer on 13-4-2.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChangePersonInfoViewController.h"

@interface ChangePersonInfoViewController ()

@end

@implementation ChangePersonInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    _tableView = nil;
    _photoView = nil;
    [_rp cancel];
    _rp = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    //订制导航条
    UILabel *headerLabel = [[UILabel alloc ] init];
    headerLabel.frame = CGRectMake(0, 0, 140, 30);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:230/255.0 green:60/255.0 blue:0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"修改个人信息";
    self.navigationItem.titleView = headerLabel;
    headerLabel = nil;
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _rp = [[RequestProxy alloc] init];
    _rp.delegate = self;
    
    _photoView = [[UIImageView alloc] init];
    _photoView.frame = CGRectMake(15, 12, 60, 60);
    _photoView.backgroundColor = [UIColor grayColor];
    _photoView.tag = 101;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-44-20) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView.alpha = 0;
    [self.view addSubview:_tableView];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _user = [AccountUser getSingleton];
    [_tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewController
{
    [_rp cancel];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 6;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            return 85;
            break;
        }
        case 1:
        {
            if (indexPath.row == 0) {
                NSString *desc = _user.desc;
                if (desc == nil) {
                    desc = @" ";
                }
//                CGSize descSize = [desc sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(270, 9999) lineBreakMode:NSLineBreakByWordWrapping];
//                return descSize.height + 50;
                return [self getMixedViewHeight:desc]+50;
            }else if(indexPath.row == 2){
                return 70;
            }else{
                return 50;
            }
            break;
        }
        case 2:
        {
            return 40;
            break;
        }
        default:
            return 0;
            break;
    }
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return [NSString stringWithFormat:@"用户金币数为:%@.",myAccountUser.money];
//    }
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *view in cell.contentView.subviews) {
//        if (view.tag > 100) {
            [view removeFromSuperview];
//        }
    }
    
    if (indexPath.section == 0) {
        
        [cell.contentView addSubview:_photoView];
        NSString *photoID = [AccountUser getSingleton].photoID;
//        if (_hdImage) {
//            _photoView.image = _hdImage;
 //       }else{
        if ([[AccountUser getSingleton].sex isEqualToString:@"0"]) {
            [_photoView setImageWithURL:USER_HEAD_IMG_URL_TIME(@"small", photoID,[AccountUser getSingleton].photoTime) placeholderImage:[UIImage imageNamed:@"male_holder.png"]];
            ;
        }else{
            [_photoView setImageWithURL:USER_HEAD_IMG_URL_TIME(@"small", photoID,[AccountUser getSingleton].photoTime) placeholderImage:[UIImage imageNamed:@"female_holder.png"]];
        }
        
//        }
        UILabel *photoLabel = [[UILabel alloc] init];
        photoLabel.frame = CGRectMake(120, 30, 70, 25);
        photoLabel.backgroundColor = [UIColor clearColor];
        photoLabel.text = @"上传头像";
        photoLabel.tag = 102;
        [cell.contentView addSubview:photoLabel];
        photoLabel = nil;
    }else if (indexPath.section == 1){
        
        switch (indexPath.row) {
            case 0:
            {
                //自我介绍
                UILabel *label1 = [[UILabel alloc] init];
                label1.frame = CGRectMake(15, 12, 80, 20);
                label1.text = @"自我介绍";
                label1.textAlignment = NSTextAlignmentLeft;
                label1.backgroundColor = [UIColor clearColor];
                label1.tag = 103;
                [cell.contentView addSubview:label1];
                label1 = nil;
                //内容
                NSString *desc = _user.desc;
                if (desc == nil) {
                    desc = @" ";
                }
                CGSize descSize = [desc sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(260, 9999) lineBreakMode:NSLineBreakByWordWrapping];
                UILabel *label2 = [[UILabel alloc] init];
                label2.frame = CGRectMake(15, 40, 260, descSize.height);
                //label2.text = desc;
                label2.numberOfLines = 0;
                label2.textColor = [UIColor grayColor];
                label2.backgroundColor = [UIColor clearColor];
                label2.tag = 104;
//                [Utility emotionAttachString:desc toView:label2];
                [self attachString:desc toView:label2];
                [cell.contentView addSubview:label2];
                label2 = nil;
            }
                break;
            case 1:
            {
                UILabel *label1 = [[UILabel alloc] init];
                label1.frame = CGRectMake(15, 15, 120, 20);
                label1.textAlignment = NSTextAlignmentLeft;
                label1.backgroundColor = [UIColor clearColor];
                label1.tag = 105;
                label1.text = @"修改密码";
                [cell.contentView addSubview:label1];
                label1 = nil;
                break;
            }
            case 2:
            {
                UILabel *label1 = [[UILabel alloc] init];
                label1.frame = CGRectMake(15, 15, 120, 20);
                label1.textAlignment = NSTextAlignmentLeft;
                label1.backgroundColor = [UIColor clearColor];
                label1.tag = 105;
                label1.text = @"修改邮箱地址";
                UILabel *label2 = [[UILabel alloc] init];
                if (_user.email == nil || [_user.email isEqualToString:@""]) {
                    
                    label2.text = @"您还未绑定邮箱，无法找回密码。";
                    label2.font = [UIFont systemFontOfSize:16];
                    label2.tag = 200;
                    label2.frame = CGRectMake(15, 40, 270, 20);
                    label2.textColor = [UIColor redColor];
                    label2.backgroundColor = [UIColor clearColor];
                    [cell.contentView addSubview:label2];
                    [cell.contentView addSubview:label1];
                    label1 = nil;
                    label2 = nil;
                    break;
                }
                CGSize descSize = [_user.email sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(320, 9999) lineBreakMode:NSLineBreakByWordWrapping];
                label2.frame = CGRectMake(15, 40, 300, descSize.height);
                label2.text = _user.email;
                label2.numberOfLines = 0;
                label2.textColor = [UIColor grayColor];
                label2.backgroundColor = [UIColor clearColor];
                label2.tag = 200;
                [cell.contentView addSubview:label2];
                [cell.contentView addSubview:label1];
                label2 = nil;
                label1 = nil;
                break;
            }
            default:
                break;
        }
                        
    }else if (indexPath.section == 2){
        UILabel *label1 = [[UILabel alloc] init];
        label1.frame = CGRectMake(15, 10, 80, 20);
        label1.textAlignment = NSTextAlignmentLeft;
        label1.backgroundColor = [UIColor clearColor];
        label1.tag = 105;
        [cell.contentView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(105, 10, 180, 20);
        label2.textColor = [UIColor grayColor];
        label2.textAlignment = NSTextAlignmentLeft;
        label2.backgroundColor = [UIColor clearColor];
        label2.tag = 106;
        [cell.contentView addSubview:label2];
        
        switch (indexPath.row) {
            case 0:
            {
                label1.text = @"用  户  名:";
                label2.text = _user.name;
                label2.adjustsFontSizeToFitWidth = YES;
                break;
            }
            case 1:
            {
                label1.text = @"性       别:";
                NSString *sex = _user.sex;
                if ([sex isEqualToString:@"0"]) {
                    label2.text = @"男";
                }else if ([sex isEqualToString:@"1"]){
                    label2.text = @"女";
                }
                break;
            }
            case 4:
            {
                label1.text = @"伪       币:";
                label2.text = [NSString stringWithFormat:@"%@",myAccountUser.money];
                break;
            }
            case 2:
            {
                label1.text = @"年       代:";
                label2.text = _user.birthday;
                break;
            }
            case 3:
            {
                label1.text = @"编       号:";
                label2.text = _user.numberID;
                break;
            }
            case 5:
            {
                label1.text = @"注册时间:";
                label2.text = _user.reg_time;
                break;
            }
            default:
                break;
        }
        label1 = nil;
        label2 = nil;
    }
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                EditDescViewController *editDesc = [[EditDescViewController alloc] init];
                [self.navigationController pushViewController:editDesc animated:YES];
                editDesc = nil;
                break;
            }
            case 1:
            {
                ChangePasswordViewController *changePassword = [[ChangePasswordViewController alloc] init];
                [self.navigationController pushViewController:changePassword animated:YES];
                changePassword = nil;
                break;
            }
            case 2:
            {
                ChangeEmailViewController *changeEmail = [[ChangeEmailViewController alloc] init];
                [self.navigationController pushViewController:changeEmail animated:YES];
                break;
                changeEmail = nil;
            }
            default:
                break;
        }
        
    }else if (indexPath.section == 0){
        [self takePhoto];
    }
}

#pragma mark -
#pragma mark  拍照或获取图片
-(void) takePhoto{
    DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    picker = nil;
    
}

#pragma mark -imagePickerController
-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    _hdImage = [UIImage imageWithData:[info objectForKey:@"data"]];
    _photoView.image = _hdImage;
    [self dismissModalViewControllerAnimated:YES];
    [_rp upUserPhoto:[info objectForKey:@"data"]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [AccountUser getSingleton].photoTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"phototime"]];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [[SDImageCache sharedImageCache] removeImageForKey:[USER_HEAD_IMG_URL(@"small", [AccountUser getSingleton].photoID) absoluteString]];
//    [_photoView setImageWithURL:USER_HEAD_IMG_URL(@"small", [AccountUser getSingleton].photoID)];
    _photoView.image = _hdImage;
    NSArray *array = [dic objectForKey:@"msg"];
    [Utility showHUD:[array lastObject]];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self mycutMixedString:str];
    
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
                    imgView = nil;
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
    rect.size.height = y + 22;
    targetView.frame = rect;
}

- (CGFloat)getMixedViewHeight:(NSString *)str
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(260, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
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
        }else if ([a isEqualToString:@"\n"]){
            if (pEnd == 0) {
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
        if (range.location != 0) {
            [returnArray addObject:[str substringToIndex:range.location]];
        }
        [returnArray addObject:[str substringWithRange:range]];
        str = [str substringFromIndex:range.location + range.length];
    }
    if ([str length] > 0) {
        [returnArray addObject:str];
    }
    while (1) {
        if ([[returnArray lastObject] isEqualToString:@"\n"]) {
            [returnArray removeObjectAtIndex:(returnArray.count - 1)];
        }else{
            break;
        }
    }
    return returnArray;
}



@end
