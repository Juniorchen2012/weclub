//
//  ZBarManager.h
//  WeClub
//
//  Created by mitbbs on 13-8-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"
#import "AboutViewController.h"
#import "QRZBarViewController.h"

@interface ZBarManager : NSObject<NSCopying>
{
    ZBarReaderViewController                *_reader;
    QRZBarViewController                    *_qrReader;
    UINavigationController                  *_nav;
    
    UILabel                                 *_helpLabel;
    NSString                                *_helpStr;
    
    NSMutableArray                          *_muArray;
    int                                      _readerFlag;
}
@property (nonatomic,strong) NSString *helpFlag;
@property (nonatomic,assign) int scanFlag;

+ (ZBarManager *)sharedZBarManager;

- (void)back;
- (UINavigationController *)getReaderWithDelegate:(id)delegate helpStr:(NSString *)str;

@end
