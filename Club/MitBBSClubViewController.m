//
//  MitBBSClubViewController.m
//  WeClub
//
//  Created by chao_mit on 13-4-17.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "MitBBSClubViewController.h"

@interface MitBBSClubViewController ()

@end

@implementation MitBBSClubViewController

- (id)initWithMitType:(int)myType
{
    self = [super init];
    if (self) {
        mitType = myType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initNavigation];
    [self createClassifyView];
	// Do any additional setup after loading the view.
    
}

-(void)createClassifyView{
    if (categoryView) {
        return;
    }
    NSArray *list;
    if (0 == mitType) {
        list = myConstants.clubCategory;
    }else if (1 == mitType){
        list = myConstants.talkArea;
    }else if (2 == mitType){
        list = myConstants.mitbbsCategory;
    }
    
    categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, myConstants.screenHeight-20-44-40)];
    categoryView.backgroundColor = [UIColor whiteColor];
    float singleViewHeight = (myConstants.screenHeight-20-44-40)/4;
    for (int i = 0; i < [list count]; i++) {
        UIView *singleView = [[UIView alloc]initWithFrame:CGRectMake(76*(i%4)+16, singleViewHeight*(i/4), 60, singleViewHeight)];
        singleView.tag = i;
        [Utility addTapGestureRecognizer:singleView withTarget:self action:@selector(selectCategory:)];
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(-8, 58, 76, singleViewHeight-60)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = [list objectAtIndex:i];
        lbl.tag = 1000;
        [singleView addSubview:lbl];
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5, 60, 60)];
        if (1 == mitType){
            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"timg%d.png",[[myConstants.mitBBSDic valueForKey:lbl.text]intValue]]];
        }else if(0 == mitType){
            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img%d.png",[[myConstants.mitBBSDic valueForKey:lbl.text]intValue]]];
        }else{
            if (i == 5) {
                imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img17.png"]];
            }else{
                imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img%d.png",[[myConstants.mitBBSDic valueForKey:lbl.text]intValue]]];
            }
        }
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 60, 60)];
        bg.image = [UIImage imageNamed:@"classifyBg.png"];
        [singleView addSubview:bg];
        [singleView addSubview:imgView];
        [categoryView addSubview:singleView];
    }
    [self.view addSubview:categoryView];
}

-(void)selectCategory:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UILabel *lbl = (UILabel *)[tap.view viewWithTag:1000];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_MITBBS_CLUB" object:[NSNumber numberWithInt:mitType] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[myConstants.mitBBSDic valueForKey:lbl.text],KEY_CATEGORY,lbl.text,KEY_NAME,nil]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BACK_FROM_MITBBS_CLUBVIEW" object:nil userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initNavigation{
    //titleView
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [titleLbl setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:20]];
    
    if (0 == mitType) {
    titleLbl.text = @"俱乐部分类";
    }else if (1 == mitType){
    titleLbl.text = @"mitbbs版面";
    }else if (2 == mitType){
    titleLbl.text = @"mitbbs俱乐部";
    }
    CGSize size = CGSizeMake(320,2000);
    CGSize labelsize = [titleLbl.text sizeWithFont:titleLbl.font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
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
}

@end
