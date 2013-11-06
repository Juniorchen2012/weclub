//
//  AsyncImageView.m
//  AsyncDownload
//  异步显示图片
//  Created by yang on 13/12/12.
//  Copyright (c) 2012 yang. All rights reserved.
//

#import "AsyncImageView.h"



@implementation AsyncImageView

@synthesize savePath = _savePath;

//创建读取界面（进度条和大圈圈）
- (void) createProgressView {
    pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    CGSize s = self.bounds.size;
    pv.frame  =  CGRectMake(10, s.height-20, s.width-20, 5);
    [self addSubview:pv];
//    [pv release];
    aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.center = CGPointMake(s.width/2, s.height/2);
    [self addSubview:aiv];
    [aiv startAnimating];
//    [aiv release];
}

//根据URL创建一个NSURLConnection链接
- (void) setImageWithUrl:(NSURL *)url {
    
    [self createProgressView];
    
    NSURLRequest *r =[ NSURLRequest requestWithURL:url
                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:60];
    // 启动一个网络连接
    c = [[NSURLConnection alloc] initWithRequest:r delegate:self];
    // 让网络连接处于一个高优先级 让c连接处于一个高有线NSRunLoopCommonModes
    [c scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    /*
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:<#(NSTimeInterval)#> target:<#(id)#> selector:<#(SEL)#> userInfo:<#(id)#> repeats:<#(BOOL)#>];
    [[NSRunLoop currentRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
     */

}

//当请求已经成功时调用回调函数（为照片预留内存空间并获取照片的数据总长度）
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"receive response");
    recvData = [[NSMutableData alloc] init];
    UIImage *img = [[UIImage alloc] initWithData:recvData];
    NSLog(@"img size:%f,%f",img.size.width,img.size.height);
    // 提前就知道图片的总长度
    totalLen = [response expectedContentLength];
}

//当正在获取图片信息时调用此函数（获取当前数据读取进度）
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [recvData appendData:data];
    int len = [recvData length];
    float r = len*1.0f/totalLen;
    pv.progress = r;
    
    // recvData数据是不全的
    UIImage *img = [[UIImage alloc] initWithData:recvData];
//    NSLog(@"img size:%f,%f",img.size.width,img.size.height);
    [self calSize:img.size];
    self.image = img;
//    [img release];
}

//当照片数据请求完毕后调用此函数（显示照片并隐藏进度条和大圈圈）
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"receive finish");
    UIImage *img = [[UIImage alloc] initWithData:recvData];
//    img.imageOrientation
    self.image = img;
//    [img release];
    [pv removeFromSuperview];
    [aiv removeFromSuperview];
    
    [recvData writeToFile:_savePath atomically:YES];
//    NSLog(@"save path:%@",_savePath);
//    if ([[NSFileManager defaultManager] fileExistsAtPath:_savePath]) {
//        NSLog(@"nidaye...");
//    }
}

//计算当前已经获取到的照片数据的大小
- (void)calSize:(CGSize)imgSize;
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize _availableSize = CGSizeMake(screenSize.width, screenSize.height-65);
    
    if (_availableSize.width == 0 || _availableSize.height == 0) {
        [self alertSomething:@"错误的屏幕尺寸"];
        return;
    }
    float wScale = imgSize.width/_availableSize.width;
    float hScale = imgSize.height/_availableSize.height;
    float maxScale = wScale>hScale?wScale:hScale;
//    NSLog(@"w:%f,h:%f,m:%f",wScale,hScale,maxScale);
    if (maxScale == 0) {
        //[self alertSomething:@"错误的图片尺寸"];
        return;
    }
    CGSize newSize = CGSizeMake(imgSize.width/maxScale, imgSize.height/maxScale);
    self.frame = CGRectMake((_availableSize.width-newSize.width)/2, (_availableSize.height-newSize.height)/2, newSize.width, newSize.height);
    CGSize s = self.bounds.size;
    pv.frame  =  CGRectMake(10, s.height-20, s.width-20, 5);
    aiv.center = CGPointMake(s.width/2, s.height/2);

}

- (void)alertSomething:(NSString *)str
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
//    [alert release];
}

@end
