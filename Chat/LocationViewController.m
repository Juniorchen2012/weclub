//
//  LocationViewController.m
//  Chat
//
//  Created by Archer on 13-2-20.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()

@end

@implementation LocationViewController

@synthesize delegate = _delegate;
@synthesize location = _location;
@synthesize locDiscription = _locDiscription;
@synthesize mapView = _mapView;
@synthesize locatedView = _locatedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-65)];
        _mapView.showsUserLocation = YES;
        [_mapView removeAnnotations:_mapView.annotations];
        _mapView.delegate = self;
        [_mapView setHidden:YES];
        [self.view addSubview:_mapView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
    btn.tintColor = [UIColor orangeColor];
    btn.enabled = NO;
    self.navigationItem.rightBarButtonItem = btn;
    
    //添加位置指针
    _locatedView = [[UIImageView alloc] init];
    UIImage *locatedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"located_1" ofType:@"png"]];
    _locatedView.frame = CGRectMake(_mapView.center.x-13, _mapView.center.y-locatedImage.size.height, locatedImage.size.width, locatedImage.size.height);
    _locatedView.image = locatedImage;
    [_mapView addSubview:_locatedView];
    
    _located_2 = [[UIImageView alloc] init];
    UIImage *located_2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"located_2" ofType:@"png"]];
    _located_2.frame = _locatedView.frame;
    _located_2.image = located_2;
    [_mapView addSubview:_located_2];
    
    _located_3 = [[UIImageView alloc] init];
    UIImage *located_3 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"located_3" ofType:@"png"]];
    _located_3.frame = _locatedView.frame;
    _located_3.image = located_3;
    [_mapView addSubview:_located_3];
    
    //添加标注背景图，分左中右三部分
    _noteBgLeft = [[UIImageView alloc] init];
    UIImage *bgLeft = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"located_dialogue_1" ofType:@"png"]] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    _noteBgLeft.frame = CGRectMake(_mapView.center.x-21, _mapView.center.y-33-bgLeft.size.height, bgLeft.size.width, bgLeft.size.height);
    _noteBgLeft.image = bgLeft;
    [_noteBgLeft setHidden:YES];
    [_mapView addSubview:_noteBgLeft];
    
    _noteBgMiddle = [[UIImageView alloc] init];
    UIImage *bgMiddle = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"located_dialogue_2" ofType:@"png"]];
    _noteBgMiddle.frame = CGRectMake(_mapView.center.x-9, _mapView.center.y-33-bgMiddle.size.height, bgMiddle.size.width, bgMiddle.size.height);
    _noteBgMiddle.image = bgMiddle;
    [_noteBgMiddle setHidden:YES];
    [_mapView addSubview:_noteBgMiddle];
    
    _noteBgRight = [[UIImageView alloc] init];
    UIImage *bgRight = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"located_dialogue_3" ofType:@"png"]] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    _noteBgRight.frame = CGRectMake(_mapView.center.x+9, _mapView.center.y-33-bgRight.size.height, bgRight.size.width, bgRight.size.height);
    _noteBgRight.image = bgRight;
    [_noteBgRight setHidden:YES];
    [_mapView addSubview:_noteBgRight];
    
    //添加标注label
    _locNote = [[UILabel alloc] init];
    _locNote.frame = CGRectMake(_mapView.center.x-21, _mapView.center.y-33-60, 42, 45);
    _locNote.backgroundColor = [UIColor clearColor];
    _locNote.textColor = [UIColor whiteColor];
    _locNote.font = [UIFont systemFontOfSize:12];
    [_locNote setHidden:YES];
    [_mapView addSubview:_locNote];
    
    //去掉google的水印
    NSArray *arr = _mapView.subviews;
    UIView *google = [arr objectAtIndex:1];
//    [google removeFromSuperview];
    
//    //设定当前位置
//    AccountUser *myAccountUser = [AccountUser getSingleton];
//    [myAccountUser locate];
//    _location.latitude = myAccountUser.userLatitude;
//    _location.longitude = myAccountUser.userLongitude;
//    NSLog(@"latitude : %f, longitude : %f", _location.latitude, _location.longitude);
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"定位失败，请确定系统设置中微俱的定位服务是否打开" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 102;
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //    [super dealloc];
    //    [_mapView release];
    _mapView = nil;
    //    [_locatedView release];
    _locatedView = nil;
    //    [_locNote release];
    _locNote = nil;
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendLocation
{
    NSLog(@"sendLocation...");
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithFloat:_location.latitude] forKey:LOC_LATITUDE];
    [dic setObject:[NSNumber numberWithFloat:_location.longitude] forKey:LOC_LONGITUDE];
    [dic setObject:_locNote.text forKey:LOC_DISCRIPTION];
    NSLog(@"dic%@", dic);
    [self.delegate postLocationMsg:dic];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//MKReverseGeocoderDelegate实现
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"reverseGeocoder error:%@",[error description]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"地址获取失败" message:@"无法获取您当前的位置请检查网络或稍后再试" delegate:self cancelButtonTitle:nil otherButtonTitles:@"是", nil];
    [alert show];
    _locDiscription = @"";
}

//无法获取位置时的回调函数
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self popViewController];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSArray *arr = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
    
    //根据逆向地理信息编码返回的信息生成位置描述
    _locDiscription = @"";
    for (int i = 0; i<[arr count]-1; i++) {
        _locDiscription = [_locDiscription stringByAppendingString:[arr objectAtIndex:i]];
    }
    _locDiscription = [_locDiscription stringByAppendingFormat:@" %@",[arr objectAtIndex:[arr count]-1]];
    NSLog(@"loc:%@",_locDiscription);
    
    //    if ([geocoder retainCount]) {
    //        [geocoder release];
    //    }
    
    [self calFrame];
    _locNote.text = _locDiscription;
    [_locNote setHidden:NO];
    [_noteBgLeft setHidden:NO];
    [_noteBgMiddle setHidden:NO];
    [_noteBgRight setHidden:NO];
    
    if ([self checkLocationInfo] && [[AccountUser getSingleton] MQTTconnected]) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    [_mapView removeAnnotations:_mapView.annotations];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [_locNote setHidden:YES];
    [_noteBgLeft setHidden:YES];
    [_noteBgMiddle setHidden:YES];
    [_noteBgRight setHidden:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //判断变化距离，距离较小则不变化
    if (fabsf(_location.latitude-userLocation.coordinate.latitude)<0.01 && fabsf(_location.longitude-userLocation.coordinate.longitude)<0.01) {
        NSLog(@"return...");
        return;
    }
    
    //判断收到的经纬度数据是否合法
    if (userLocation.coordinate.latitude>-180&&userLocation.coordinate.latitude<=180&&userLocation.coordinate.longitude>-180&&userLocation.coordinate.longitude<=180) {
        _location = userLocation.coordinate;
    }else{
        return;
    }
    
    _mapView.region = MKCoordinateRegionMakeWithDistance(_location, 500.0f, 500.0f);
    [_mapView setHidden:NO];
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //    NSLog(@"kkk...");
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationReverse)];
    CGRect frame = _locatedView.frame;
    frame.origin.y = frame.origin.y - 10;
    _locatedView.frame = frame;
    _located_2.alpha = 0;
    [UIView commitAnimations];
    
}

- (void)animationReverse
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(makeGeocoder)];
    CGRect frame = _locatedView.frame;
    frame.origin.y = frame.origin.y + 10;
    _locatedView.frame = frame;
    _located_2.alpha = 1;
    [UIView commitAnimations];
    
    
}

- (void)makeGeocoder
{
    _location = [_mapView convertPoint:_mapView.center toCoordinateFromView:_mapView];
    
    MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:_location];
    geocoder.delegate = self;
    [geocoder start];
}

- (void)calFrame
{
    CGSize noteSize = [_locDiscription sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(9999, 9999) lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"noteSize:%f,%f",noteSize.width,noteSize.height);
    
    if (noteSize.width > 280) {
        noteSize.width = 280;
    }
    
    CGRect rect = _noteBgLeft.frame;
    rect.origin.x = _noteBgMiddle.frame.origin.x - (noteSize.width-18)/2-4;
    rect.size.width = (noteSize.width-18)/2+4;
    _noteBgLeft.frame = rect;
    
    rect = _noteBgRight.frame;
    rect.size.width = (noteSize.width-18)/2+4;
    _noteBgRight.frame = rect;
    
    rect = _locNote.frame;
    rect.origin.x = _mapView.center.x-noteSize.width/2;
    rect.size.width = noteSize.width;
    _locNote.frame = rect;
}

- (BOOL)checkLocationInfo{
    if (_location.latitude>-180 && _location.latitude<=180 &&
        _location.longitude>-180 && _location.longitude<=180 &&
        _locNote.text != nil && ![_locNote.text isEqualToString:@""]) {
        return true;
    }
    else{
        return false;
    }
}

@end
