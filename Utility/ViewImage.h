//
//  ViewImage.h
//  WeClub
//
//  Created by chao_mit on 13-3-19.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewImage : NSObject<MWPhotoBrowserDelegate>{
    NSMutableArray *photos;
}
-(UINavigationController *)viewLargePhoto:(NSArray *)urls;
@end
