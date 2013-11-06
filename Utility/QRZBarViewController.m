//
//  QRZBarViewController.m
//  WeClub
//
//  Created by mitbbs on 13-9-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "QRZBarViewController.h"

@interface QRZBarViewController ()

@end

@implementation QRZBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    self.session = [[AVCaptureSession alloc] init];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device
                                                       error:&error];
    if (!self.input)
    {
        NSLog(@"Error: %@", error);
        return;
    }
    
    [self.session addInput:self.input];
    
    //Turn on point autofocus for middle of view
    [self.device lockForConfiguration:&error];
    CGPoint point = CGPointMake(0.5,0.5);
    [self.device setFocusPointOfInterest:point];
    [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    [self.device unlockForConfiguration];
    
    //Add the metadata output device
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self.delegate queue:dispatch_get_main_queue()];
    [self.session addOutput:self.output];
    for (NSString *s in self.output.availableMetadataObjectTypes)
        NSLog(@"%@",s);
    
    //You should check here to see if the session supports these types, if they aren't support you'll get an exception
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeQRCode];
    
    
    self.anewCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.anewCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.anewCaptureVideoPreviewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.anewCaptureVideoPreviewLayer above:self.view.layer];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIImageView *scanImg = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"scan_pic" ofType:@"png"]]];
    scanImg.frame = CGRectMake(0,0,screenSize.width,screenSize.height);
    [self.view addSubview:scanImg];
    scanImg = nil;
    
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
    NSLog(@"disappear");
    [self.session removeInput:self.input];
    [self.session removeOutput:self.output];
    self.input = nil;
    self.output = nil;
    self.session = nil;
    [self.anewCaptureVideoPreviewLayer removeFromSuperlayer];
    self.anewCaptureVideoPreviewLayer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
	// Do any additional setup after loading the view.
//    self.session = [[AVCaptureSession alloc] init];
//    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//
//    NSError *error = nil;
//    
//    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device
//                                                                        error:&error];
//    if (!self.input)
//    {
//        NSLog(@"Error: %@", error);
//        return;
//    }
//    
//    [self.session addInput:self.input];
//    
//    //Turn on point autofocus for middle of view
//    [self.device lockForConfiguration:&error];
//    CGPoint point = CGPointMake(0.5,0.5);
//    [self.device setFocusPointOfInterest:point];
//    [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
//    [self.device unlockForConfiguration];
//    
//    //Add the metadata output device
//    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
//    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    [self.session addOutput:output];
//    for (NSString *s in output.availableMetadataObjectTypes)
//        NSLog(@"%@",s);
//    
//    //You should check here to see if the session supports these types, if they aren't support you'll get an exception
//    output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeQRCode];
//    
//    
//    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//    newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    newCaptureVideoPreviewLayer.frame = self.view.bounds;
//    [self.view.layer insertSublayer:newCaptureVideoPreviewLayer above:self.view.layer];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {

        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
