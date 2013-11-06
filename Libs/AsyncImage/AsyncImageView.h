//
//  AsyncImageView.h
//  AsyncDownload
//
//  Created by yang on 13/12/12.
//  Copyright (c) 2012 yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncImageView : UIImageView {
    NSURLConnection *c;
    NSMutableData *recvData;
    int totalLen;
    UIProgressView *pv;
    UIActivityIndicatorView *aiv;
    
    NSString *_savePath;
}

@property (nonatomic,retain) NSString *savePath;

- (void) setImageWithUrl:(NSURL *)url;
@end
