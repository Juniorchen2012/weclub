//
//  FeedbackViewController.h
//  WeClub
//
//  Created by chao_mit on 13-2-16.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
#import "UIPlaceHolderTextView.h"


@interface FeedbackViewController : UIViewController<ASIHTTPRequestDelegate,UITextViewDelegate>{
    UIButton *postBtn;
    UIPlaceHolderTextView *myTV;
    ASIFormDataRequest *asiRequest;
}

@end
