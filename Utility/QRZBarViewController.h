//
//  QRZBarViewController.h
//  WeClub
//
//  Created by mitbbs on 13-9-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QRZBarViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong,) AVCaptureVideoPreviewLayer *anewCaptureVideoPreviewLayer;
@property (nonatomic,assign) id<AVCaptureMetadataOutputObjectsDelegate> delegate;


@end
