//
//  NoticeManager.m
//  WeClub
//
//  Created by mitbbs on 13-8-14.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "NoticeManager.h"

static NoticeManager *_sharedNoticeManger;
#define NOTICEHEIGHT 33

@implementation NoticeManager

+ (NoticeManager *)sharedNoticeManager
{
    
    if (!_sharedNoticeManger) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedNoticeManger = [[super allocWithZone:NULL] init];
            NSLog(@"sharedNoticeManager");
        });
    }
    return _sharedNoticeManger;
}


- (id)copyWithZone:(NSZone *)zone
{
    return _sharedNoticeManger;
}

- (void)receiveNotice:(NSNotification *)notification
{
    NSLog(@"receive notice");
    NSDictionary *noticeDic = (NSDictionary *)notification.object;
    NSLog(@"%@",noticeDic);
    NSString *m = [NSString stringWithFormat:@"%@",[noticeDic objectForKey:@"m"]];
    if ([m isEqualToString:@"1"]) {
        NoticeView *notice = [[NoticeView alloc] initClubAdopt:noticeDic];
        if (_adoptClubNoticeArray.count == 0) {
            _adoptClubNoticeArray = [[NSMutableArray alloc] initWithCapacity:0];
        }
        [_adoptClubNoticeArray addObject:notice];
//        _adoptClubNoticeCount += 1;
        [self archiveSharedNoticeManager];
        notice = nil;
        [self showTabBarNotice];
        [self showNotice];
    }else{
        if ([noticeDic.allKeys containsObject:@"bbsClubFollow"] || [noticeDic.allKeys containsObject:@"bbsClubAttention"] || [noticeDic.allKeys containsObject:@"bbsUserAttention"] || [noticeDic.allKeys containsObject:@"bbsUserFollow"]) {
            _bbsFlag = 1;
        //        [self BBSNoticeInit];
            if ([[noticeDic objectForKey:@"bbsClubFollow"] isEqualToString:@"1"]) {
                _bbsClubFollowNotice = [[NoticeView alloc] initWithNumber:-100 andType:@"bbsClubFollow"];
                [self archiveSharedNoticeManager];
            }
            if ([[noticeDic objectForKey:@"bbsClubAttention"] isEqualToString:@"1"]) {
                _bbsClubAttentionNotice = [[NoticeView alloc] initWithNumber:-101 andType:@"bbsClubAttention"];
                [self archiveSharedNoticeManager];
            }
            if ([[noticeDic objectForKey:@"bbsUserAttention"] isEqualToString:@"1"]) {
                _bbsUserAttentionNotice = [[NoticeView alloc] initWithNumber:-200 andType:@"bbsUserAttention"];
                [self archiveSharedNoticeManager];
            }
            if ([[noticeDic objectForKey:@"bbsUserFollow"] isEqualToString:@"1"]) {
                _bbsUserFollowNotice = [[NoticeView alloc] initWithNumber:[AccountUser getSingleton].follow_me_count.intValue andType:@"bbsUserFollow"];
                [self archiveSharedNoticeManager];
            }
        }

        if ([noticeDic isKindOfClass:[NSDictionary class]]) {
            for (NSString *str in noticeDic.allKeys) {
                int num = [[noticeDic objectForKey:str] integerValue];
                NSArray *array = [NSArray arrayWithObjects:@"bbsClubFollow", @"bbsClubAttention",@"bbsUserAttention",@"bbsUserFollow", nil];
                if (noticeDic.allKeys.count == 1 && ![array containsObject:str]) {
                    [self resetNoticeWithType:str];
                }
                if (num > 0) {
                    if (![array containsObject:str]) {
                        [self changeNoticeWithType:str toNumber:num];
                    }else{
                        [self archiveSharedNoticeManager];
                    }
                }
            }
        }
    }
}

- (void)resetBBSLoginAllNotices
{
    [self resetAllNotices];
}

- (void)resetAllNotices
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotice:) name:NOTIFICATION_KEY_UPDATENOTICE object:nil];
        
    });
    _reconnectNotice = nil;
    if ([NoticeManager isExistUserNoticeManagerDoc]) {
        if ([NoticeManager isExistUserNoticeManager]){
            [self unArchiveSharedNoticeManager];
            return;
        }
    }
    _bbsFlag = 0;
    _chatNoticeCount = 0;
    _noticeDic = [[NSMutableDictionary alloc] init];
    _clubNotice = [[NoticeView alloc] initWithNumber:0 andType:@"club"];
    _articleNotice = [[NoticeView alloc] initWithNumber:0 andType:@"art"];
    _userNotice = [[NoticeView alloc] initWithNumber:0 andType:@"user"];
    _adoptClubNoticeArray = [[NSMutableArray alloc] initWithCapacity:0];
    _bbsClubFollowNotice = nil;
    _bbsClubAttentionNotice = nil;
    _bbsUserAttentionNotice = nil;
    _bbsUserFollowNotice = nil;
    _adoptClubNoticeCount = 0;
    [_noticeDic setObject:_clubNotice forKey:@"club"];
    [_noticeDic setObject:_articleNotice forKey:@"art"];
    [_noticeDic setObject:_userNotice forKey:@"user"];
}

- (void)resetSharedNoticeManger
{
    _sharedNoticeManger = nil;
}

- (void)resetNoticeWithType:(NSString *)type
{
    if ([type isEqualToString:@"bbsClubFollow"]) {
        if (_bbsClubFollowNotice) {
            [_bbsClubFollowNotice removeFromSuperview];
        }
        _bbsClubFollowNotice = nil;
    }
    if ([type isEqualToString:@"bbsClubAttention"]) {
        if (_bbsClubAttentionNotice) {
            [_bbsClubAttentionNotice removeFromSuperview];
        }
        _bbsClubAttentionNotice = nil;
    }
    if ([type isEqualToString:@"bbsUserAttention"]) {
        if (_bbsUserAttentionNotice) {
            [_bbsUserAttentionNotice removeFromSuperview];
        }
        _bbsUserAttentionNotice = nil;
    }
    if ([type isEqualToString:@"bbsUserFollow"]) {
        if (_bbsUserFollowNotice) {
            [_bbsUserFollowNotice removeFromSuperview];
        }
        _bbsUserFollowNotice = nil;
    }
    //[self changeNoticeWithType:type toNumber:0];
    NoticeView *oneNotice = [_noticeDic objectForKey:type];
    if (oneNotice) {
//        if ([type isEqualToString:@"club"]) {
//            oneNotice.noticeNumber = -_adoptClubNoticeCount;
//        }else{
            oneNotice.noticeNumber = 0;
//        }
        
    }
    [self archiveSharedNoticeManager];
    [self showNotice];
    [self showTabBarNotice];
}

- (void)changeNoticeWithType:(NSString *)type toNumber:(int)num
{
    
    NoticeView *oneNotice = [_noticeDic objectForKey:type];
    int oldNum = oneNotice.noticeNumber;
//    if ([type isEqualToString:@"club"]) {
        oneNotice.noticeNumber = oldNum+num;
//    }
    [oneNotice.noticeButton setTitle:[NSString stringWithFormat:@"您有%d条新消息未处理",oneNotice.noticeNumber] forState:UIControlStateNormal];
    //oneNotice.noticeNumber = num;
    [self archiveSharedNoticeManager];
    [self showNotice];
    [self showTabBarNotice];
    
}

- (NoticeView *)getNoticeWithType:(NSString *)type
{
    if ([type isEqualToString:@"art"]) {
        return [_noticeDic objectForKey:@"art"];
    }else if ([type isEqualToString:@"club"]) {
        return [_noticeDic objectForKey:@"club"];
    }else if ([type isEqualToString:@"user"]) {
        return [_noticeDic objectForKey:@"user"];
    }
    return nil;
}

- (NSInteger)getNoticesCountWithType:(NSString *)type
{
    if (!_noticeDic) {
        return 0;
    }
    NoticeView *oneView = [_noticeDic objectForKey:type];
    if (!oneView) {
        return 0;
    }
    return oneView.noticeNumber;
}

- (void)showTabBarNotice
{
    TabBarController *tab = ((AppDelegate *)[UIApplication sharedApplication].delegate).TabC;
;
    
    NSArray *tabCircleArray = [NSArray arrayWithObjects:tab.clubNoticeCircle,tab.articleNoticeCircle,tab.userNoticeCircle, nil];
    NSArray *tabName = [NSArray arrayWithObjects:@"club",@"art",@"user", nil];
    
    for (int i = 0; i < 3; i++) {
        int noticeCount = [self getNoticesCountWithType:[tabName objectAtIndex:i]];
        MKNumberBadgeView *tabCircle = [tabCircleArray objectAtIndex:i];
        if ([[tabName objectAtIndex:i] isEqualToString:@"club"]) {
            if (_bbsClubAttentionNotice) {
                noticeCount++;
            }
            if (_bbsClubFollowNotice) {
                noticeCount++;
            }
            noticeCount += _adoptClubNoticeArray.count;
        }
        if ([[tabName objectAtIndex:i] isEqualToString:@"art"]) {
            
        }
        if ([[tabName objectAtIndex:i] isEqualToString:@"user"]) {
            if (_bbsUserAttentionNotice) {
                noticeCount++;
            }if (_bbsUserFollowNotice) {
                noticeCount++;
            }
            noticeCount += _chatNoticeCount;
        }
        if (noticeCount == 0) {
            [tabCircle setHidden:YES];
        }else if (noticeCount>0 && noticeCount<100){
//            [tabCircle setHidden:NO];
//            [tabCircle changeText:[NSString stringWithFormat:@"%d",noticeCount]];
//            [tabCircle setStrFont:11];
//            [tabCircle setNeedsDisplay];
//            tabLabel.text = [NSString stringWithFormat:@"%d",noticeCount];
            [tabCircle setHidden:NO];
            tabCircle.font = [UIFont systemFontOfSize:10.5];
            tabCircle.value = 99;
            tabCircle.valueStr = [NSString stringWithFormat:@"%d",noticeCount];
            [tabCircle setNeedsDisplay];
            
        }else if (noticeCount>=100){
//            [tabCircle setHidden:NO];
//            [tabCircle changeText:@"99+"];
//            [tabCircle setStrFont:10.5];
            [tabCircle setHidden:NO];
            tabCircle.font = [UIFont systemFontOfSize:10.5];
            tabCircle.valueStr = @"99+";
            tabCircle.value = 100;
            [tabCircle setNeedsDisplay];
        }
    }

}

- (void)showNotice
{
    for (NoticeView *oneView in _noticeDic.allValues) {
        [oneView removeFromSuperview];
    }
    if (_bbsUserAttentionNotice) {
        [_bbsUserAttentionNotice removeFromSuperview];
    }
    if (_bbsUserFollowNotice) {
        [_bbsUserFollowNotice removeFromSuperview];
    }
    if (_bbsClubFollowNotice) {
        [_bbsClubFollowNotice removeFromSuperview];
    }
    if (_bbsClubAttentionNotice) {
        [_bbsClubAttentionNotice removeFromSuperview];
    }
    if (_bbsFlag) {
        [self resetBBSNoticesLoc];
    }
    if (_adoptClubNoticeArray.count > 0) {
        for (NoticeView *oneNotice in _adoptClubNoticeArray) {
            [oneNotice removeFromSuperview];
        }
        [self resetClubAdoptNoticeLoc];
    }
    NSLog(@"adoptclubnotice %d",_adoptClubNoticeArray.count);
    for (NSString *type in _noticeDic.allKeys) {
        if ([_noticeDic objectForKey:type]) {
            UITableView *table;
            NoticeView *noticeView = [_noticeDic objectForKey:type];
            if ([type isEqualToString:@"club"]) {
                ClubListViewController *oneController = ((TabBarController *)((AppDelegate *)[UIApplication sharedApplication].delegate).TabC).clublist;
                int y = 0;
                table = [oneController getTableView];
                if (_bbsClubAttentionNotice) {
                    NSLog(@"bbsClubAttentionNotice");
                    [_bbsClubAttentionNotice removeFromSuperview];
                    y += NOTICEHEIGHT;
                    [oneController.view addSubview:_bbsClubAttentionNotice];
                }
                if (_bbsClubFollowNotice) {
                    [_bbsClubFollowNotice removeFromSuperview];
                    y += NOTICEHEIGHT;
                    [oneController.view addSubview:_bbsClubFollowNotice];
                }
                if (_adoptClubNoticeArray.count > 0) {
                    for (NoticeView *oneNotice in _adoptClubNoticeArray) {
                        [oneController.view addSubview:oneNotice];
                        y += NOTICEHEIGHT;
                    }
                }
                if (noticeView.noticeNumber > 0) {
                    y += NOTICEHEIGHT;
                    [oneController.view addSubview:noticeView];
                }
                oneController.getScrollView.frame = table.frame = CGRectMake(0, y, 320, myConstants.screenHeight-20-44-49-y);
                table.frame = CGRectMake(0, y, 320, myConstants.screenHeight-20-44-49-y);
            }else if ([type isEqualToString:@"art"]) {
                ArticleViewController *artController = ((TabBarController *)((AppDelegate *)[UIApplication sharedApplication].delegate).TabC).article;
                int y = 0;
                table = [artController getTable];
                if (noticeView.noticeNumber > 0) {
                    [artController.view addSubview:noticeView];
                    y += NOTICEHEIGHT;
                }
                table.frame = CGRectMake(0, y, 320, myConstants.screenHeight-20-44-49-y);
            }else if ([type isEqualToString:@"user"]) {
                UserViewController *oneController = ((TabBarController *)((AppDelegate *)[UIApplication sharedApplication].delegate).TabC).user;
                int y = 0;
                if (_bbsUserAttentionNotice) {
                    [oneController.view addSubview:_bbsUserAttentionNotice];
                    y += NOTICEHEIGHT;
                }
                if (_bbsUserFollowNotice) {
                    [oneController.view addSubview:_bbsUserFollowNotice];
                    y += NOTICEHEIGHT;
                }
                if (noticeView.noticeNumber > 0) {
                    [oneController.view addSubview:noticeView];
                    y += NOTICEHEIGHT;
                }
                for (UIScrollView *oneView in [oneController getAllView]) {
                    if (oneView == [[oneController getAllView] objectAtIndex:0]) {
                        if (_reconnectNotice) {
                            [oneController getReconnectView].frame = CGRectMake(0, y, 320, NOTICEHEIGHT);
                            [[oneController getReconnectView] addSubview:_reconnectNotice];
                            oneView.frame = CGRectMake(0, y+NOTICEHEIGHT, 320, myConstants.screenHeight-20-44-49-y-NOTICEHEIGHT);
                        }else{
                            oneView.frame = CGRectMake(0, y, 320, myConstants.screenHeight-20-44-49-y);
                        }
                    }else{
                        oneView.frame = CGRectMake(0, y, 320, myConstants.screenHeight-20-44-49-y);
                    }
                }
            }

        }
    }
}

- (BOOL)noticeIsExistWithType:(NSString *)type
{
    if ([type isEqualToString:@"bbsClubFollow"]) {
        if (_bbsClubFollowNotice != nil){
            return YES;
        }else{
            return NO;
        }
    }
    if ([type isEqualToString:@"bbsClubAttention"]) {
        if (_bbsClubAttentionNotice != nil){
            return YES;
        }else{
            return NO;
        }
    }
    if ([type isEqualToString:@"bbsUserAttention"]) {
        if (_bbsUserAttentionNotice != nil){
            return YES;
        }else{
            return NO;
        }
        
    }
    if ([type isEqualToString:@"bbsUserFollow"]) {
        if (_bbsUserFollowNotice != nil){
            return YES;
        }else{
            return NO;
        }
        
    }
    NoticeView *oneNotice = [_noticeDic objectForKey:type];
    if (oneNotice.noticeNumber > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_noticeDic forKey:@"noticeDic"];
    [aCoder encodeBool:_bbsFlag forKey:@"bbsFlag"];
    [aCoder encodeInt:_chatNoticeCount forKey:@"chatNoticeCount"];
    [aCoder encodeObject:_clubNotice forKey:@"clubNotice"];
    [aCoder encodeObject:_articleNotice forKey:@"articleNotice"];
    [aCoder encodeObject:_userNotice forKey:@"userNotice"];
    [aCoder encodeObject:_bbsClubFollowNotice forKey:@"bbsClubFollowNotice"];
    [aCoder encodeObject:_bbsClubAttentionNotice forKey:@"bbsClubAttentionNotice"];
    [aCoder encodeObject:_bbsUserAttentionNotice forKey:@"bbsUserAttentionNotice"];
    [aCoder encodeObject:_adoptClubNoticeArray forKey:@"adoptClubNoticeArray"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _noticeDic = [[NSMutableDictionary alloc] initWithDictionary:[aDecoder decodeObjectForKey:@"noticeDic"]];
        _bbsFlag = [aDecoder decodeBoolForKey:@"bbsFlag"];
        _chatNoticeCount = [aDecoder decodeIntForKey:@"chatNoticeCount"];
        _clubNotice = [aDecoder decodeObjectForKey:@"clubNotice"];
        _articleNotice = [aDecoder decodeObjectForKey:@"articleNotice"];
        _userNotice = [aDecoder decodeObjectForKey:@"userNotice"];
        _bbsClubFollowNotice = [aDecoder decodeObjectForKey:@"bbsClubFollowNotice"];
        _bbsClubAttentionNotice = [aDecoder decodeObjectForKey:@"bbsClubAttentionNotice"];
        _bbsUserAttentionNotice = [aDecoder decodeObjectForKey:@"bbsUserAttentionNotice"];
        _adoptClubNoticeArray = [[NSMutableArray alloc] initWithArray:[aDecoder decodeObjectForKey:@"adoptClubNoticeArray"]];
    }
    return self;
}

- (void)archiveSharedNoticeManager
{
    NSString *noticeManagerDocPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"NoticeManager"];
    NSString *noticeManagerName = [NSString stringWithFormat:@"%@.dat",[AccountUser getSingleton].numberID];
    NSString *noticeManagerPath = [noticeManagerDocPath stringByAppendingPathComponent:noticeManagerName];
    NSFileManager *file = [NSFileManager defaultManager];
    if ([NoticeManager isExistUserNoticeManager]) {
        [file removeItemAtPath:noticeManagerPath error:nil];
    }
    NSMutableDictionary *mudic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mudic setObject:[NSNumber numberWithInt:_bbsFlag] forKey:@"bbsFlag"];
    [mudic setObject:[NSNumber numberWithInt:_clubNotice.noticeNumber] forKey:@"clubNoticeNumber"];
    [mudic setObject:[NSNumber numberWithInt:_articleNotice.noticeNumber] forKey:@"articleNoticeNumber"];
    [mudic setObject:[NSNumber numberWithInt:_userNotice.noticeNumber] forKey:@"userNoticeNumber"];
    [mudic setObject:[NSNumber numberWithInt:_adoptClubNoticeCount] forKey:@"adoptClubNoticeCount"];
    if (_bbsClubAttentionNotice) {
        [mudic setObject:[NSNumber numberWithInt:1] forKey:@"bbsClubAttentionNotice"];
    }else{
        [mudic setObject:[NSNumber numberWithInt:0] forKey:@"bbsClubAttentionNotice"];
    }
    if (_bbsClubFollowNotice) {
        [mudic setObject:[NSNumber numberWithInt:1] forKey:@"bbsClubFollowNotice"];
    }else{
        [mudic setObject:[NSNumber numberWithInt:0] forKey:@"bbsClubFollowNotice"];
    }
    if (_bbsUserAttentionNotice) {
        [mudic setObject:[NSNumber numberWithInt:1] forKey:@"bbsUserAttentionNotice"];
    }else{
        [mudic setObject:[NSNumber numberWithInt:0] forKey:@"bbsUserAttentionNotice"];
    }
    if (_bbsUserFollowNotice) {
        [mudic setObject:[NSNumber numberWithInt:_bbsUserFollowNotice.noticeNumber] forKey:@"bbsUserFollowNotice"];
    }else{
        [mudic setObject:[NSNumber numberWithInt:0] forKey:@"bbsUserFollowNotice"];
    }
    NSMutableArray *muArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NoticeView *oneView in _adoptClubNoticeArray) {
        NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[oneView.adoptClubId,oneView.tips] forKeys:@[@"adoptClubId",@"tips"]];
        [muArray addObject:dic];
        dic = nil;
    }
    [mudic setObject:muArray forKey:@"adoptClubNoticeArray"];
    
    NSLog(@"%@",noticeManagerPath);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mudic];
    [data writeToFile:noticeManagerPath atomically:YES];
    muArray = nil;
}

- (void)unArchiveSharedNoticeManager
{
    NSString *noticeManagerDocPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"NoticeManager"];
    NSString *noticeManagerName = [NSString stringWithFormat:@"%@.dat",[AccountUser getSingleton].numberID];
    NSString *noticeManagerPath = [noticeManagerDocPath stringByAppendingPathComponent:noticeManagerName];
    NSData *data = [NSData dataWithContentsOfFile:noticeManagerPath];
    NSDictionary *dic = [NSKeyedUnarchiver  unarchiveObjectWithData:data];
    _bbsFlag = [[dic objectForKey:@"bbsFlag"] integerValue];
    _chatNoticeCount = 0;
    _adoptClubNoticeCount = [[dic objectForKey:@"adoptClubNoticeCount"] integerValue];
    _noticeDic = [[NSMutableDictionary alloc] init];
    _clubNotice = [[NoticeView alloc] initWithNumber:[[dic objectForKey:@"clubNoticeNumber"] integerValue] andType:@"club"];
    _articleNotice = [[NoticeView alloc] initWithNumber:[[dic objectForKey:@"articleNoticeNumber"] integerValue] andType:@"art"];
    _userNotice = [[NoticeView alloc] initWithNumber:[[dic objectForKey:@"userNoticeNumber"] integerValue] andType:@"user"];
    if ([[dic objectForKey:@"bbsClubAttentionNotice"] integerValue] == 1) {
         _bbsClubAttentionNotice = [[NoticeView alloc] initWithNumber:-101 andType:@"bbsClubAttention"]; 
    }else{
        _bbsClubAttentionNotice = nil;
    }
    if ([[dic objectForKey:@"bbsClubFollowNotice"] integerValue] == 1) {
        _bbsClubFollowNotice = [[NoticeView alloc] initWithNumber:-100 andType:@"bbsClubFollow"];
    }else{
        _bbsClubFollowNotice = nil;
    }
    if ([[dic objectForKey:@"bbsUserAttentionNotice"] integerValue] == 1) {
        _bbsUserAttentionNotice = [[NoticeView alloc] initWithNumber:-200 andType:@"bbsUserAttention"];
    }else{
        _bbsUserAttentionNotice = nil;
    }
    if ([[dic objectForKey:@"bbsUserFollowNotice"] integerValue] != 0) {
        _bbsUserFollowNotice = [[NoticeView alloc] initWithNumber:[[dic objectForKey:@"bbsUserFollowNotice"] integerValue] andType:@"bbsUserFollow"];
    }else{
        _bbsUserFollowNotice = nil;
    }
    [_noticeDic setObject:_clubNotice forKey:@"club"];
    [_noticeDic setObject:_articleNotice forKey:@"art"];
    [_noticeDic setObject:_userNotice forKey:@"user"];
    
    _adoptClubNoticeArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *array = [dic objectForKey:@"adoptClubNoticeArray"];
    for (NSDictionary *oneDic in array) {
        NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[[oneDic objectForKey:@"adoptClubId"],[oneDic objectForKey:@"tips"]] forKeys:@[@"clubid",@"tips"]];
        NoticeView *notice = [[NoticeView alloc] initClubAdopt:dic];
        [_adoptClubNoticeArray addObject:notice];
        notice = nil;
    }
    [self showNotice];
    //[self showTabBarNotice];
}

+ (BOOL)isExistUserNoticeManagerDoc
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *noticeManagerPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"NoticeManager"];
    if ([fileManager fileExistsAtPath:noticeManagerPath]) {
        return YES;
    }else{
        [fileManager createDirectoryAtPath:noticeManagerPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSLog(@"%@",noticeManagerPath);
    return NO;
}

+ (BOOL)isExistUserNoticeManager
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *noticeManagerDocPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"NoticeManager"];
    NSString *noticeManagerName = [NSString stringWithFormat:@"%@.dat",[AccountUser getSingleton].numberID];
    NSString *noticeManagerPath = [noticeManagerDocPath stringByAppendingPathComponent:noticeManagerName];
    if ([fileManager fileExistsAtPath:noticeManagerPath]) {
        return YES;
    }
    return NO;
}

#pragma mark - clubAdoptNotice
- (void)resetClubAdoptNoticeLoc
{
    int y = 0;
    if ([self noticeIsExistWithType:@"club"]) {
        y += NOTICEHEIGHT;
    }
    if ([self noticeIsExistWithType:@"bbsClubFollow"]) {
        y += NOTICEHEIGHT;
    }
    if ([self noticeIsExistWithType:@"bbsClubAttention"]) {
        y += NOTICEHEIGHT;
    }
    int locY = y - NOTICEHEIGHT;
    for (NoticeView *oneNotice in _adoptClubNoticeArray) {
        oneNotice.frame = CGRectMake(0, NOTICEHEIGHT+locY, 320, NOTICEHEIGHT);
        locY = oneNotice.frame.origin.y;
    }
}

- (void)resetClubAdoptNoticeWithId:(NSString *)numberId
{
    for (NoticeView *notice in _adoptClubNoticeArray) {
        if ([notice.adoptClubId isEqualToString:numberId]) {
            [notice removeFromSuperview];
            [_adoptClubNoticeArray removeObject:notice];
            break;
        }
    }
    [self archiveSharedNoticeManager];
    [self showNotice];
    [self showTabBarNotice];
}

#pragma mark - bbsNotice
- (void)resetBBSNoticeWithType:(NSString *)type
{
    
}

- (void)BBSNoticeInit
{

}

- (void)removeBBSNotices;
{
    [_bbsUserFollowNotice removeFromSuperview];
    [_bbsUserAttentionNotice removeFromSuperview];
    [_bbsClubFollowNotice removeFromSuperview];
    [_bbsClubAttentionNotice removeFromSuperview];
}

- (void)resetBBSNoticesLoc
{
    _bbsClubFollowNotice.frame = CGRectMake(0, 0, 320, NOTICEHEIGHT);
    _bbsClubAttentionNotice.frame = CGRectMake(0, NOTICEHEIGHT, 320, NOTICEHEIGHT);
    _bbsUserAttentionNotice.frame = CGRectMake(0, 0, 320, NOTICEHEIGHT);
    _bbsUserFollowNotice.frame = CGRectMake(0, NOTICEHEIGHT, 320, NOTICEHEIGHT);

    if ([self noticeIsExistWithType:@"club"]) {
        _bbsClubFollowNotice.frame = CGRectMake(0, NOTICEHEIGHT, 320, NOTICEHEIGHT);
        _bbsClubAttentionNotice.frame = CGRectMake(0, 66, 320, NOTICEHEIGHT);
    }
    if (!_bbsClubFollowNotice) {
        CGPoint point = _bbsClubAttentionNotice.frame.origin;
        _bbsClubAttentionNotice.frame = CGRectMake(0, point.y-NOTICEHEIGHT , 320, NOTICEHEIGHT);
    }
    if ([self noticeIsExistWithType:@"user"]) {
        _bbsUserAttentionNotice.frame = CGRectMake(0, NOTICEHEIGHT, 320, NOTICEHEIGHT);
        _bbsUserFollowNotice.frame = CGRectMake(0, 66, 320, NOTICEHEIGHT);
    }
    if (!_bbsUserAttentionNotice) {
        CGPoint point = _bbsUserFollowNotice.frame.origin;
        _bbsUserFollowNotice.frame = CGRectMake(0, point.y-NOTICEHEIGHT , 320, NOTICEHEIGHT);
    }
}

#pragma mark - chatNotice

- (void)resetChatNotice:(int)count
{
    _chatNoticeCount = count;
    [self showTabBarNotice];
}

#pragma mark - reconnectNoticeResetLoc
- (void)reconnectNoticeRestLoc
{
    if (_reconnectNotice) {
        
    }
}
@end
