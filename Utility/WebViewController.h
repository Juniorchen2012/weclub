//
//  WebViewController.h
//  WeClub
//
//  Created by mitbbs on 13-10-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>{
    UIWebView *_web;
    NSString *URLStr;
    UIButton *_menuBtn;
    UIButton *_webBack;
    UIButton *_webForward;
    UIActivityIndicatorView *_indicator;
}
-(id)initWithURLStr:(NSString *)urlStr;
@end
