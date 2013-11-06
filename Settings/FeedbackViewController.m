//
//  FeedbackViewController.m
//  WeClub
//
//  Created by chao_mit on 13-2-16.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //titleView
        UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
        [titleLbl setFont:[UIFont fontWithName:@"Arial" size:20]];
        titleLbl.text = @"意见反馈";
        CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font];
        titleLbl.frame = CGRectMake(0, 0, labelsize.width, labelsize.height);
        titleLbl.textColor = NAVIFONT_COLOR;
        titleLbl.backgroundColor = [UIColor clearColor];
        self.navigationItem.titleView = titleLbl;
        
        //leftBarButtonItem
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [btn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backbtn = [[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = backbtn;
        
        //rightBarButtonItem
        postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        postBtn.enabled = NO;
        postBtn.frame = CGRectMake(0, 0, 54, 32);
        [postBtn setTitle:@"发送" forState:UIControlStateNormal];
        [postBtn setBackgroundImage:BTNBG forState:UIControlStateNormal];
        [postBtn addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:postBtn];
        postBtn.enabled = NO;
        self.navigationItem.rightBarButtonItem = rightBtnItem;
        
        myTV = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(10, 10, 300,154)];
        if (iPhone5) {
            myTV.frame = CGRectMake(10, 10, 300,200);
        }
        myTV.placeholder = @"请留下您的宝贵的意见";
        myTV.layer.borderColor = [[UIColor blackColor]CGColor];
        myTV.layer.borderWidth = 1.0;
        myTV.delegate = self;
        [self.view addSubview:myTV];
        [myTV becomeFirstResponder];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)post{
    
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length]) {
        postBtn.enabled = YES;
    }else{
        postBtn.enabled = NO;
    }
}
    

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
