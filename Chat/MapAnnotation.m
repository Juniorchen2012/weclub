//
//  MapAnnotation.m
//  Chat
//
//  Created by Archer on 13-2-20.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    if (self = [super init]) {
        coordinate = aCoordinate;
    }
    return self;
}

- (void)dealloc
{
    self.title = nil;
    self.subtitle = nil;
//    [super dealloc];
}

@end
