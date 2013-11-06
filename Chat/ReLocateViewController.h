//
//  ReLocateViewController.h
//  Chat
//
//  Created by Archer on 13-2-21.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@interface ReLocateViewController : UIViewController<MKMapViewDelegate>
{
    NSDictionary *_locationInfo;
    
    MKMapView *_mapView;
}

@property (nonatomic,retain) NSDictionary *locationInfo;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
