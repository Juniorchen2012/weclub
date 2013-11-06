//
//  EditInfoViewController.m
//  WeClub
//
//  Created by chao_mit on 13-3-6.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "EditInfoViewController.h"

@interface EditInfoViewController ()

@end

@implementation EditInfoViewController
@synthesize style,str,refreshDel;

-(void)viewWillDisappear:(BOOL)animated{
    [myTV resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated{
    if (style) {
    [myTV becomeFirstResponder];
    }else{
        [txtFiled becomeFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initNavigation];
    if (style) {
        //UITextView
        UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(10, 5, 300, 120)];
        backGroundView.layer.borderWidth = 1.0;
        backGroundView.layer.cornerRadius = 5;
        
        myTV = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
        myTV.layer.borderColor = [[UIColor grayColor]CGColor];
        myTV.delegate = self;
        myTV.text = str;
        myTV.layer.borderWidth = 0;
        myTV.layer.cornerRadius = 5;
        [backGroundView addSubview:myTV];
        [self.view addSubview:backGroundView];

        leftCountLbl = [[UILabel alloc]initWithFrame:CGRectMake(235, 105, 50, 15)];
        leftCountLbl.text = [NSString stringWithFormat:@"%d",140-[Utility unicodeLengthOfString:myTV.text]];
        leftCountLbl.textAlignment = UITextAlignmentRight;
        [self.view addSubview:leftCountLbl];
        keyBoardSwitch = [[UIButton alloc]initWithFrame:CGRectMake(270, 88, 50, 50)];
        keyBoardSwitch.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        [keyBoardSwitch setImage:[UIImage imageNamed:@"emotion1.png"] forState:UIControlStateNormal];
        [keyBoardSwitch addTarget:self action:@selector(changeKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:keyBoardSwitch];
        
        faceBoard = [[FaceBoard alloc]initWithIsShowSendButton:NO];
        faceBoard.frame = CGRectMake(0, myConstants.screenHeight-216-20-44, 320, 256);
        faceBoard.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLeftCount) name:@"textViewChange" object:nil];
        [self.view addSubview:faceBoard];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        //UITextField
        txtFiled = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 300, 30)];
        txtFiled.text = str;
        txtFiled.delegate = self;
        txtFiled.backgroundColor = [UIColor clearColor];
        txtFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        txtFiled.clearButtonMode = UITextFieldViewModeAlways;
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake(6, 10, 303, 30)];
        bgView.image = TXTFIELDBG;
        [self.view addSubview:bgView];
        [self.view addSubview:txtFiled];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    self.view.userInteractionEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:@"hideKeyboard" object:nil];
}

-(void)changeKeyboard{
    static BOOL on = NO;
    faceBoard.inputTextView = myTV;
    if (!keyBoardSwitch.tag) {
        [keyBoardSwitch setImage:[UIImage imageNamed:@"keyboard1.png"] forState:UIControlStateNormal];
        faceBoard.hidden = NO;
        keyBoardSwitch.tag = 1;
        [self.view removeKeyboardControl];
        faceBoard.count = [myTV.text length]-myTV.selectedRange.location;

        [myTV resignFirstResponder];
        //        myTV.inputView = faceBoard;
        //        [myTV becomeFirstResponder];
    }else{
        [keyBoardSwitch setImage:[UIImage imageNamed:@"emotion1.png"] forState:UIControlStateNormal];
        faceBoard.inputTextView = nil;
        keyBoardSwitch.tag = 0;
        myTV.inputView = nil;
        [myTV resignFirstResponder];
        [myTV becomeFirstResponder];
        faceBoard.hidden = YES;
    }
    on = !on;
}

-(BOOL)check{
    //名字长度暂定10
    NSString * regex = @"^[\u4e00-\u9fa5A-Za-z@][\u4e00-\u9fa5A-Za-z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:txtFiled.text];
    WeLog(@"isMatch%d",isMatch);
    WeLog(@"txtFiled%@",txtFiled.text);
    WeLog(@"ta%@",[txtFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]]);
    
    if (style) {
        //检查俱乐部描述
        if (![[myTV.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]) {
            [Utility MsgBox:@"俱乐部描述不能为空!"];
            return NO;
        }else if([Utility getByteLengthOfString:myTV.text]  < 12){
            [Utility MsgBox:@"俱乐部描述不能少于6个字符!"];
            return NO;
        }else if([Utility unicodeLengthOfString:myTV.text] >140){
            [Utility MsgBox:@"俱乐部描述不能超过140个字符!"];
            return NO;
        }
    }else{
        if(![[txtFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length]){
            [Utility MsgBox:@"俱乐部名称不能为空!"];
            return NO;
        }
        NSString *regex1 = @"^[\u4e00-\u9fa5A-Za-z@0-9（）]*$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
        BOOL isMatch1 = [pred1 evaluateWithObject:txtFiled.text];
        WeLog(@"isMatch1符合0不符合%d",isMatch1);
        if (!isMatch1) {
            [Utility MsgBox:@"俱乐部名称由英文字母、汉字、数字、括号组成."];
            return NO;
        }
        //检查俱乐部名称
        NSString * regex = @"^[\u4e00-\u9fa5A-Za-z@][\u4e00-\u9fa5A-Za-z()]*[0-9]*$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isMatch = [pred evaluateWithObject:txtFiled.text];
        WeLog(@"isMatch%d",isMatch);
        WeLog(@"英文\(的个数%d",[self countOfSubString:@"\("]);
        WeLog(@"英文)的个数%d",[self countOfSubString:@")"]);
        WeLog(@"英文Location:(%d)%d",[txtFiled.text rangeOfString:@"\("].location,[txtFiled.text rangeOfString:@")"].location);

        if ([self countOfSubString:@"\("]||[self countOfSubString:@")"]) {
            if ([self countOfSubString:@"\("] == 1&&[self countOfSubString:@")"]==1&&[txtFiled.text rangeOfString:@"\("].location+1<[txtFiled.text rangeOfString:@")"].location) {
            }else if([self countOfSubString:@"\("] == 1&&[self countOfSubString:@")"]==1&&[txtFiled.text rangeOfString:@"\("].location+1 == [txtFiled.text rangeOfString:@")"].location){
                [Utility MsgBox:@"括号内必须有内容"];
                return NO;
            }else{
                [Utility MsgBox:@"括号只能成对出现并且只能出现一次!"];
                return NO;
            }
        }
        WeLog(@"中文\(的个数%d",[self countOfSubString:@"（"]);
        WeLog(@"中文)的个数%d",[self countOfSubString:@"）"]);
        WeLog(@"中文Location:（%d）%d",[txtFiled.text rangeOfString:@"（"].location,[txtFiled.text rangeOfString:@"）"].location);

        if ([self countOfSubString:@"（"]||[self countOfSubString:@"）"]) {
            if ([self countOfSubString:@"（"] == 1&&[self countOfSubString:@"）"]==1&&[txtFiled.text rangeOfString:@"（"].location+1<[txtFiled.text rangeOfString:@"）"].location) {
            }else if([self countOfSubString:@"（"] == 1&&[self countOfSubString:@"）"]==1&&[txtFiled.text rangeOfString:@"（"].location+1 == [txtFiled.text rangeOfString:@"）"].location){
                [Utility MsgBox:@"括号内必须有内容"];
                return NO;
            }else{
                [Utility MsgBox:@"括号只能成对出现并且只能出现一次!"];
                return NO;
            }
        }
        
        for (int i = 0; i < [txtFiled.text length]; i++) {
            WeLog(@"intvalue%d",[[txtFiled.text substringWithRange:NSMakeRange(i, 1)] intValue]);
        }
        
        //检查字符规则
        if (!isMatch) {
            [Utility MsgBox:@"只能以字母汉字开头,数字只能放在最后."];
            return NO;
        }
        
        //检查字符个数
        if ([Utility unicodeLengthOfString:txtFiled.text]>10) {
            [Utility MsgBox:@"俱乐部名称不能超过10个字符!"];
            return NO;
        }else if([Utility getByteLengthOfString:txtFiled.text] < 4){
            [Utility MsgBox:@"俱乐部名称不能少于2个字符!"];
            return NO;
        }
}
    
    return YES;
}

-(int)countOfSubString:(NSString *)st{
    int count = 0;
    for (int i = 0; i < [txtFiled.text length]; i++) {
        NSString *s = [txtFiled.text substringWithRange:NSMakeRange(i, 1)];
        if ([s isEqualToString:st]) {
            count++;
        }
    }
    return count;
}

-(void)save{
    if (![self check]) {
        return;
    }
    [self back];
    sleep(0.5);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    if (style) {
        [dic setValue:@"描述" forKey:@"keyName"];
        [dic setValue:myTV.text forKey:@"value"];
        [refreshDel refresh:dic];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"CLUB_EDITINFO_REFRESH" object:myTV.text userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"描述",@"keyName", nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CLUB_CHANGE_INFO" object:myTV.text userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"描述",@"keyName", nil]];
    }else{
        [dic setValue:@"名称" forKey:@"keyName"];
        [dic setValue:txtFiled.text forKey:@"value"];
        [refreshDel refresh:dic];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"CLUB_EDITINFO_REFRESH" object:txtFiled.text userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"名称",@"keyName", nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CLUB_CHANGE_INFO" object:txtFiled.text userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"名称",@"keyName", nil]];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (faceBoard.hidden == NO) {
        [keyBoardSwitch setImage:[UIImage imageNamed:@"emotion1.png"] forState:UIControlStateNormal];
        keyBoardSwitch.tag = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNavigation{
    //leftBarButtonItem
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backbtn;
    
    //rightBarButtonItem
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, RIGHT_BAR_ITEM_WIDTH, RIGHT_BAR_ITEM_HEIGHT);
    [menuBtn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:RIGHT_BAR_ITEM_FONT_SIZE]];
    [menuBtn setTitle:@"确定" forState:UIControlStateNormal];
    [menuBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBtnItem = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = menuBtnItem;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (![Utility calLines:[NSString stringWithFormat:@"%@%@",textView.text,text] withMaxCount:4]) {
        if (![text isEqualToString:@""]) {
            [Utility MsgBox:@"最多不能超过5行."];
            return NO;
        }

    }
    if ([text isEqualToString:@""]) {
        WeLog(@"selectedRange forward%@and after%@",[textView.text substringToIndex:textView.selectedRange.location],[textView.text substringFromIndex:textView.selectedRange.location]);
        
        WeLog(@"growingText%@:%@",textView.text,text);
        if ([Utility emtionAanalyse:[textView.text substringToIndex:textView.selectedRange.location]] != -1) {
            NSString *st = [textView.text substringToIndex:[Utility emtionAanalyse:[textView.text substringToIndex:textView.selectedRange.location]]];
            textView.text = [NSString stringWithFormat:@"%@%@",st,[textView.text substringFromIndex:textView.selectedRange.location]];
            textView.selectedRange = NSMakeRange([st length], 0);
            leftCountLbl.text = [NSString stringWithFormat:@"%d",140-[Utility unicodeLengthOfString:[NSString stringWithFormat:@"%@%@",textView.text,text]]];
            return NO;
        }
    }
    return YES;
}

-(void)refreshLeftCount{
    [self textViewDidChange:myTV];
}
- (void)textViewDidChange:(UITextView *)textView{
    leftCountLbl.text = [NSString stringWithFormat:@"%d",140-[Utility unicodeLengthOfString:textView.text]];
}


-(void)hideKeyboard{
    [txtFiled resignFirstResponder];
    [myTV resignFirstResponder];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
