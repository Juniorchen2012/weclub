//
//  MapAnnotation.h
//  Chat
//
//  Created by Archer on 13-2-20.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
