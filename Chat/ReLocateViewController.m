//
//  ReLocateViewController.m
//  Chat
//
//  Created by Archer on 13-2-21.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "ReLocateViewController.h"

@interface ReLocateViewController ()

@end

@implementation ReLocateViewController

@synthesize locationInfo = _locationInfo;

- (id)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        _locationInfo = [dic copy];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-65)];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    //去掉google水印
    NSArray *arr = _mapView.subviews;
    UIView *google = [arr objectAtIndex:1];
    [google removeFromSuperview];
    
    //加载地图
    float latitude = [[_locationInfo objectForKey:LOC_LATITUDE] floatValue];
    float longitude = [[_locationInfo objectForKey:LOC_LONGITUDE] floatValue];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude, longitude);
    _mapView.region = MKCoordinateRegionMakeWithDistance(coor, 500.0f, 500.0f);
    
    //加指针标注
    MapAnnotation *anAnnotation = [[MapAnnotation alloc] initWithCoordinate:coor];
    anAnnotation.title = @"[我的位置]";
    anAnnotation.subtitle = [_locationInfo objectForKey:LOC_DISCRIPTION];
    [_mapView addAnnotation:anAnnotation];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"chat_header_back" ofType:@"png"];
    UIImage *backImg = [UIImage imageWithContentsOfFile:backPath];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKPinAnnotationView *mkaview in views) {
        mkaview.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"located" ofType:@"png"]];
    }
    
}

@end
