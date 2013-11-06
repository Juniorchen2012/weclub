//
//  EditDescViewController.m
//  WeClub
//
//  Created by Archer on 13-4-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "EditDescViewController.h"

@interface EditDescViewController ()

@end

@implementation EditDescViewController

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
    [_rp cancel];
    _rp = nil;
    _content = nil;
    faceBoard = nil;
    keyBoardSwitch = nil;
    label = nil;
    _muStr = nil;
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
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.text = @"编辑自我介绍";
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
    
//    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveDesc)];
//    btn.tintColor = [UIColor orangeColor];
//    self.navigationItem.rightBarButtonItem = btn;
//    btn = nil;
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    //    [operateBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:14]];
    [btn setBackgroundImage:BTNBG forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(saveDesc) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    btn = nil;
    rightBtn = nil;
    
    _rp = [[RequestProxy alloc] init];
    _rp.delegate = self;
    
    _muStr = [[NSMutableString alloc] initWithCapacity:0];
    
    _content = [[UITextView alloc] init];
    _content.frame = CGRectMake(5, 5, 310, 150-36);
    _content.layer.cornerRadius = 5;
    _content.layer.borderWidth = 1;
    _content.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    _content.font = [UIFont systemFontOfSize:14];
    
    [self.view addSubview:_content];
    
    keyBoardSwitch = [[UIButton alloc]initWithFrame:CGRectMake(275, 148-36, 50, 50)];
    keyBoardSwitch.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [keyBoardSwitch setImage:[UIImage imageNamed:@"emotion1.png"] forState:UIControlStateNormal];
    [keyBoardSwitch addTarget:self action:@selector(changeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:keyBoardSwitch];
    
    UILabel *tolLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 148-36, 50, 50)];
    tolLabel.backgroundColor = [UIColor clearColor];
    tolLabel.font = [UIFont systemFontOfSize:13];
    tolLabel.text = @"/140";
    tolLabel.textColor = [UIColor grayColor];
    [self.view addSubview:tolLabel];

    
    _cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cleanBtn setTitle:@"清除" forState:UIControlStateNormal];
    _cleanBtn.frame = CGRectMake(10, tolLabel.frame.origin.y, 50, 50);
    _cleanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cleanBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_cleanBtn setBackgroundColor:[UIColor clearColor]];
    [_cleanBtn addTarget:self action:@selector(cleanDesc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cleanBtn];
    tolLabel = nil;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(235, 148-36, 50, 50)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    label.text = [NSString stringWithFormat:@"%d",[Utility unicodeLengthOfString:[AccountUser getSingleton].desc]];
    label.textColor = [UIColor grayColor];
    [self.view addSubview:label];
    
    
    faceBoard = [[FaceBoard alloc]initWithIsShowSendButton:NO];
    faceBoard.frame = CGRectMake(0, myConstants.screenHeight-216-20-44, 320, 256);
    faceBoard.hidden = YES;
    [self.view addSubview:faceBoard];
    
    AccountUser *user = [AccountUser getSingleton];
    _content.text = user.desc;
    _content.delegate = self;
    [_content becomeFirstResponder];
    // Do any additional setup after loading the view.
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    array = [NSArray arrayWithObjects:keyBoardSwitch, nil];
}

- (void)inputKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];

    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        if (keyboardRect.size.height == 216) {
            [UIView animateWithDuration:0.3 animations:^{
                for (UIView *oneView in array){
                    oneView.frame = CGRectMake(oneView.frame.origin.x, 148, oneView.frame.size.width, oneView.frame.size.height);
                }
            }];
        }else if (keyboardRect.size.height == 252){
            [UIView animateWithDuration:0.3 animations:^{
                for (UIView *oneView in array){
                    oneView.frame = CGRectMake(oneView.frame.origin.x, 148-36, oneView.frame.size.width, oneView.frame.size.height);
                }
            }];
        }
    }
    
    
}

-(void)changeKeyboard{
    static BOOL on = NO;
    faceBoard.inputTextView = _content;
    if (!keyBoardSwitch.tag) {
        [keyBoardSwitch setImage:[UIImage imageNamed:@"keyboard1.png"] forState:UIControlStateNormal];
        faceBoard.hidden = NO;
        keyBoardSwitch.tag = 1;
        [self.view removeKeyboardControl];
        faceBoard.count = [_content.text length]-_content.selectedRange.location;
        [_content resignFirstResponder];
        //        myTV.inputView = faceBoard;
        //        [myTV becomeFirstResponder];
    }else{
        [keyBoardSwitch setImage:[UIImage imageNamed:@"emotion1.png"] forState:UIControlStateNormal];
        faceBoard.inputTextView = nil;
        keyBoardSwitch.tag = 0;
        _content.inputView = nil;
        [_content resignFirstResponder];
        [_content becomeFirstResponder];
        faceBoard.hidden = YES;
    }
    on = !on;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (faceBoard.hidden == NO) {
        [keyBoardSwitch setImage:[UIImage imageNamed:@"emotion1.png"] forState:UIControlStateNormal];
        keyBoardSwitch.tag = 0;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (![Utility calLines:[NSString stringWithFormat:@"%@%@",textView.text,text] withMaxCount:4]) {
        if ([text isEqualToString:@""]) {
            return  YES;
        }
        [Utility MsgBox:@"最多不能超过5段."];
        return NO;
        NSArray *array2 = [[[NSMutableString alloc] initWithString:_content.text] componentsSeparatedByString:@"\n"];
        if (array2.count > 5) {
            NSMutableString *mustr = [[NSMutableString alloc] initWithCapacity:0];
            int i = 0;
            for (NSString *oneStr in array2) {
                if (i == 5) {
                    break;
                }
                [mustr appendString:oneStr];
                [mustr appendString:@"\n"];
                i++;
            }
            [mustr deleteCharactersInRange:NSMakeRange(mustr.length-1, 1)];
            _content.text = mustr;
            return YES;
        }else{
            return NO;
        }
        return NO;
    }
    
    if ([Utility unicodeLengthOfString:[NSString stringWithFormat:@"%@%@",textView.text,text]]>140) {
        if ([text isEqualToString:@""]) {
            return  YES;
        }
        [Utility MsgBox:@"自我介绍不能超过140个字"];
        return NO;
    }
//    if (textView.contentSize.height > 110) {
//        [Utility MsgBox:@"最多不能超过5行."];
//        textView.contentSize.
//        textView.text = [textView.text substringToIndex:[textView.text length]-1];
//        return NO;
//    }
//    if ([text isEqualToString:@""]) {
//        NSLog(@"selectedRange forward%@and after%@",[_content.text substringToIndex:_content.selectedRange.location],[_content.text substringFromIndex:_content.selectedRange.location]);
//        
//        NSLog(@"growingText%@:%@",_content.text,text);
//        if ([Utility emtionAanalyse:[_content.text substringToIndex:_content.selectedRange.location]] != -1) {
//            _content.text = [NSString stringWithFormat:@"%@%@",[_content.text substringToIndex:[Utility emtionAanalyse:[_content.text substringToIndex:_content.selectedRange.location]]],[_content.text substringFromIndex:_content.selectedRange.location]];
//            return NO;
//        }
//    }
    if ([text isEqualToString:@""]) {
            if ([Utility emtionAanalyse:[textView.text substringToIndex:textView.selectedRange.location]] != -1) {
            NSString *str = [textView.text substringToIndex:[Utility emtionAanalyse:[textView.text substringToIndex:textView.selectedRange.location]]];
            textView.text = [NSString stringWithFormat:@"%@%@",str,[textView.text substringFromIndex:textView.selectedRange.location]];
            textView.selectedRange = NSMakeRange([str length], 0);
            return NO;
        }
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    [self textViewChange];
}

- (void)textViewChange
{
//    if (_content.contentSize.height > 150-36) {
//        _content.contentOffset = CGPointMake(_content.contentOffset.x
//                                             ,  _content.contentSize.height-(150-36));
//    }
//    if ([Utility unicodeLengthOfString:_content.text]>140) {
//        [Utility MsgBox:@"自我介绍不能超过140个字"];
//        _content.text = _muStr;
//        return;
//    }
    label.text = [NSString stringWithFormat:@"%d",[Utility unicodeLengthOfString:_content.text]];
    [_muStr deleteCharactersInRange:NSMakeRange(0, [_muStr length])];
    [_muStr appendString:_content.text];
    
}

- (void)popViewController
{
    if (![_content.text isEqualToString:[AccountUser getSingleton].desc]) {
        UIAlertView *aletr = [[UIAlertView alloc] initWithTitle:nil message:@"自我介绍已更改，是否保存" delegate:self cancelButtonTitle:nil otherButtonTitles:@"是", @"否",nil];
        [aletr show];
        aletr = nil;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 555) {
        if (buttonIndex == 0) {
            _content.text = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"textViewChange" object:nil];
        }
    }else{
        if (buttonIndex == 0) {
            [self saveDesc];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

- (void)saveDesc
{
    while (1) {
        if (_content.text.length > 0) {
            if ([_content.text characterAtIndex:_content.text.length-1] == ' ') {
                _content.text = [_content.text substringToIndex:(_content.text.length-1)];
            }else{
                break;
            }
        }else{
            break;
        }
    }
    if ([_content.text isEqualToString:@""] || _content.text == nil) {
        [Utility MsgBox:@"自我介绍不能为空"];
        return;
    }
    if ([Utility unicodeLengthOfString:_content.text]>140) {
        [Utility MsgBox:@"自我介绍不能超过140个字"];
        return;
    }
    if (![Utility calLines:_content.text withMaxCount:4]) {
        [Utility MsgBox:@"最多不能超过5段."];
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObject:_content.text forKey:@"desc"];
    [_rp changeMainInfo:dic andPhoto:nil];
    
}

#pragma mark - RequestProxyDelegate
- (void)processData:(NSDictionary *)dic requestType:(NSString *)type
{
    [_content resignFirstResponder];
    faceBoard.hidden = YES;
    [AccountUser getSingleton].desc = _content.text;
//    [Utility MsgBox:@"修改成功"];
    [Utility showHUD:@"修改成功"];
    [self performSelector:@selector(popViewController) withObject:nil afterDelay:1];
}

- (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type
{
    
}

- (void)processFailed:(NSString *)failDesc requestType:(NSString *)type
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChange) name:@"textViewChange" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cleanDesc
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否清空自我介绍" delegate:self cancelButtonTitle:nil otherButtonTitles:@"是", @"否", nil];
    alert.tag = 555;
    [alert show];
    alert = nil;
}

@end
