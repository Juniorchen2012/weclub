//
//  PicViewController.h
//  Chat
//
//  Created by Archer on 13-2-1.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "AsyncImageView.h"

@interface PicViewController : UIViewController<ASIHTTPRequestDelegate>
{
    NSURL *_remoteURL;
    NSString *_savePath;
    UIImageView *_imageView;
    UIProgressView *_progressView;
    
    CGSize _availableSize;
}

//初始化图片显示view，url中是服务器端的图片资源地址，path中是本地存储路径
- (id)initWithURL:(NSURL *)url andSavePath:(NSString *)path;

@end
