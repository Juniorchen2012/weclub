//
//  ViewImage.m
//  WeClub
//
//  Created by chao_mit on 13-3-19.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ViewImage.h"

@implementation ViewImage

-(UINavigationController *)viewLargePhoto:(NSArray *)urls{
    photos = [[NSMutableArray alloc] init];
    for (int i = 0; i < [urls count]; i++) {
        [photos addObject:[MWPhoto photoWithURL:[urls objectAtIndex:i]]];
    }
    MWPhotoBrowser *mwBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];

    [mwBrowser setInitialPageIndex:0];
    UINavigationController * NAV = [[UINavigationController alloc]initWithRootViewController:mwBrowser];
    return NAV;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    WeLog(@"PhotosObject%@",photos);
    WeLog(@"Potos%d",[photos count]);
    NSUInteger t = [photos count];
    return t;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}
@end
