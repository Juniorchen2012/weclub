//
//  LocationViewController.h
//  Chat
//
//  Created by Archer on 13-2-20.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@protocol LocationViewDelegate <NSObject>

- (void)postLocationMsg:(NSDictionary *)dic;

@end

@interface LocationViewController : UIViewController<MKReverseGeocoderDelegate,MKMapViewDelegate>
{
    id<LocationViewDelegate> _delegate;
    
    CLLocationCoordinate2D _location;
    NSString *_locDiscription;
    
    MKMapView *_mapView;
    
    UIImageView *_locatedView;
    UIImageView *_located_2;
    UIImageView *_located_3;
    UILabel *_locNote;
    UIImageView *_noteBgLeft;
    UIImageView *_noteBgMiddle;
    UIImageView *_noteBgRight;
}

@property (nonatomic,retain) id<LocationViewDelegate> delegate;
@property (nonatomic,assign) CLLocationCoordinate2D location;
@property (nonatomic,retain) NSString *locDiscription;
@property (nonatomic,retain) MKMapView *mapView;
@property (nonatomic,retain) UIImageView *locatedView;

- (void)sendLocation;
- (void)animationReverse;

@end
