//
//  UIBubbleTableView.m
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "UIBubbleTableView.h"
#import "NSBubbleData.h"
#import "NSBubbleDataInternal.h"
#import "Header.h"


#define CHAT_FRIEND 1
#define CHAT_SELF 0

@interface UIBubbleTableView ()
@property (nonatomic, retain) NSMutableDictionary *bubbleDictionary;

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleDictionary = _bubbleDictionary;
@synthesize numUnreadVoice = _numUnreadVoice;
@synthesize unreadVoiceDic = _unreadVoiceDic;
@synthesize strOpenURL;
@synthesize tableViewHideCell = _tableViewHideCell;

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    self.navDelegate = self;
    _unreadVoiceDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    _tableViewHideCell = [[NSMutableDictionary alloc] initWithCapacity:5];
    // UIBubbleTableView default properties
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVoicePlayed:) name:NOTIFICATION_KEY_PLAYEDVOICE object:nil];
    
    self.snapInterval = 120;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static BOOL reload = YES;
    
//    if (self.contentOffset.y > 0) {
//        reload = NO;
//    }
//    
////    if (self.contentOffset.y < -40) {
//    if (self.contentOffset.y == 0) {
//        if (reload) {
//            if([self.navDelegate respondsToSelector:@selector(loadRecord)]) {
//                [MBProgressHUD showHUDAddedTo:self animated:YES];
//                [self.navDelegate performSelector:@selector(loadRecord)];
//            }
//        }
//        else{
//            reload = YES;
//        }
//    }
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame andSomeOnePhoto:(NSString *)photo viewController:(UIViewController *) controller
{
    self = [super initWithFrame:frame];
    if (self){
        _photoID = photo;
        _numUnreadVoice = 0;
        viewController = controller;
        
        [self initializator];
    } 
    return self;
}

- (id)initWithFrame:(CGRect)frame andSomeOne:(ChatFriend *)chatFriend viewController:(UIViewController *) controller
{
   self = [self initWithFrame:frame andSomeOnePhoto:chatFriend.photo viewController:controller];
    if(self) {
        _chatFriend = chatFriend;
    }
    return self;
}

- (void)dealloc
{
    [_bubbleDictionary release];
	_bubbleDictionary = nil;
	_bubbleDataSource = nil;
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_PLAYEDVOICE object:nil];
}


#pragma mark - Override

- (void)reloadData
{
    [self refreshMove:YES cleanData:NO];
    [Utility hideWaitHUDForView];
}

- (void)cleanData
{
    [self refreshMove:NO cleanData:YES];
}

- (void) refreshMove:(BOOL)flag cleanData:(BOOL)clean{
    // Cleaning up
    NSMutableDictionary *oldBubbleDictionary = nil;
    NSMutableArray *FirstBubbleDataArray = nil;
    NSBubbleDataInternal *FirstBubbleData = nil;
    if ([self.bubbleDictionary count] > 0) {
        oldBubbleDictionary = [[NSMutableDictionary alloc] initWithDictionary:self.bubbleDictionary];
        FirstBubbleDataArray = [oldBubbleDictionary objectForKey:@"0"];
        FirstBubbleData = [FirstBubbleDataArray objectAtIndex:0];
    }
    self.bubbleDictionary = nil;
    
    // Loading new data
    int count = 0;
    if (self.bubbleDataSource && (count = [self.bubbleDataSource rowsForBubbleTable:self]) > 0)
    {
        self.bubbleDictionary = [[[NSMutableDictionary alloc] init] autorelease];
        NSMutableArray *bubbleData = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
        if (clean) { count = 0;}
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSBubbleData class]]);
            [bubbleData addObject:object];
        }
        
        [bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
             NSBubbleData *bubbleData1 = (NSBubbleData *)obj1;
             NSBubbleData *bubbleData2 = (NSBubbleData *)obj2;
             
             return [bubbleData1.date compare:bubbleData2.date];
        }];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        
        for (int i = 0; i < count; i++)
        {
            NSBubbleDataInternal *dataInternal = [[[NSBubbleDataInternal alloc] init] autorelease];
            dataInternal.data = (NSBubbleData *)[bubbleData objectAtIndex:i];
            
            NSMutableArray *keysArray = [[NSMutableArray alloc] initWithArray: [oldBubbleDictionary allKeys]];
            NSArray *sortedKeysArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *strData1 = (NSString *)obj1;
                NSString *strData2 = (NSString *)obj2;
                
                if ([strData1 integerValue] > [strData2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([strData1 integerValue] < [strData2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            NSLog(@"%@", sortedKeysArray);
            
            if ([self isEqualWithBubbleData:FirstBubbleData.data and:dataInternal.data] && oldBubbleDictionary != nil) {
                for (int j=0; j<(sortedKeysArray.count - 1); j++) {
                    NSArray *bubbleDataArray = nil;
                    if ((bubbleDataArray =[oldBubbleDictionary objectForKey:[sortedKeysArray objectAtIndex:j]])) {
                        [self.bubbleDictionary setObject:bubbleDataArray forKey:[NSString stringWithFormat:@"%d",i]];
                        i += [bubbleDataArray count];

                        NSBubbleDataInternal *endBubbleData = [bubbleDataArray objectAtIndex:[bubbleDataArray count] - 1];
                        last = endBubbleData.data.date;
                    }
                }
                i --;
                oldBubbleDictionary = nil;
                NSLog(@"增量补充数据");
                continue;
            }
            
            switch (dataInternal.data.dataType) {
                case TYPE_TEXT:
                {
                    //                    NSLog(@"type_text...");
                    // Calculating cell height
                    //                    dataInternal.labelSize = [(dataInternal.data.text ? dataInternal.data.text : @"") sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:UILineBreakModeWordWrap];
                    if (dataInternal.data.textView == nil) {
                        dataInternal.data.textView = [Utility getFaceView:(dataInternal.data.text ? dataInternal.data.text : @"") delegateView:self];
                    }
                    dataInternal.labelSize = dataInternal.data.textView.frame.size;
                    dataInternal.labelSize = CGSizeMake((dataInternal.labelSize.width<31)?31:dataInternal.labelSize.width, (dataInternal.labelSize.height<30)?30:dataInternal.labelSize.height);
                    dataInternal.height = dataInternal.labelSize.height + 30;
                    break;
                }
                case TYPE_PIC:
                {
                    //                    NSLog(@"type_pic...");
                    //                    if (dataInternal.data.data == nil) {
                    //                        return;
                    //                    }
                    UIImage *img = [UIImage imageWithData:dataInternal.data.data];
                    dataInternal.labelSize = [Utility calShowThumbSize:img.size];
                    dataInternal.height = dataInternal.labelSize.height + 40;
                    break;
                }
                case TYPE_VOICE:
                {
                    int length = dataInternal.data.length > 1000 ? dataInternal.data.length / 1000 : dataInternal.data.length;
                    float width = [self calVoiceViewWidth:length];
                    dataInternal.labelSize = CGSizeMake(width, 30);
                    dataInternal.height = dataInternal.labelSize.height + 30;
                    
                    if(dataInternal.data.data == nil || dataInternal.data.length < 0){
                        continue;
                    }
                    break;
                }
                case TYPE_VIDEO:
                {
                    UIImage *img = [UIImage imageWithData:dataInternal.data.data];
                    dataInternal.labelSize = [Utility calShowThumbSize:img.size];
                    dataInternal.height = dataInternal.labelSize.height + 40;
                    break;
                }
                case TYPE_LOC:
                {
                    dataInternal.labelSize = CGSizeMake(95, 95);
                    dataInternal.height = dataInternal.labelSize.height + 30;
                    break;
                }
                    
                default:
                    break;
            }
            
            dataInternal.header = nil;
            
            if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval)
            {
                currentSection = [[[NSMutableArray alloc] init] autorelease];
                //添加数据
                [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%d",i]];
                dataInternal.header = [dateFormatter stringFromDate:dataInternal.data.date];
                dataInternal.height += 30;
            }
            
            [currentSection addObject:dataInternal];
            last = dataInternal.data.date;
        }
        
        [dateFormatter release];
    }
    
    [super reloadData];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    if(flag) {
        float offsetY = self.contentSize.height-self.frame.size.height;
        self.contentOffset = CGPointMake(0, offsetY>0?offsetY:0);
    }else {
         float offsetY = self.contentSize.height-self.frame.size.height;
        self.contentOffset = CGPointMake(0, offsetY > 0 ? self.frame.size.height : 1);
    }
    [UIView commitAnimations];
}

#pragma mark - UITableViewDelegate implementation


#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.bubbleDictionary) return 0;
    return [[self.bubbleDictionary allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *keys = [self.bubbleDictionary allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
		return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
	}];
    NSString *key = [sortedArray objectAtIndex:section];
    return [[self.bubbleDictionary objectForKey:key] count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *keys = [self.bubbleDictionary allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
		return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
	}];
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    NSBubbleDataInternal *dataInternal = ((NSBubbleDataInternal *)[[self.bubbleDictionary objectForKey:key] objectAtIndex:indexPath.row]);

    return dataInternal.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"tblBubbleCell";
    
	NSArray *keys = [self.bubbleDictionary allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
		return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
	}];
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    NSBubbleDataInternal *dataInternal = ((NSBubbleDataInternal *)[[self.bubbleDictionary objectForKey:key] objectAtIndex:indexPath.row]);
    
    UIBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell = [self getBubbleCell:cell andData:dataInternal];
    
    if (cell == nil)
    {
        cell = [[UIBubbleTableViewCell alloc] init];
    }
    
//    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    [cell addGestureRecognizer:recognizer];
    cell.dataInternal = dataInternal;
    cell.viewController = viewController;
    cell.sendDelegate = self.navDelegate;
    if (cell.dataInternal.data.type == BubbleTypeSomeoneElse) {
//        if (cell.someOne == nil) {
//            NSLog(@"some one nil...");
//        }else{
//            NSLog(@"some one on...");
//        }
//        UIImageView *someOne = cell.someOne;
//        someOne.image = [UIImage imageNamed:@"error.png"];
//        someOne.backgroundColor = [UIColor clearColor];
        NSLog(@"_photoID : %@", USER_HEAD_IMG_URL(@"small", _chatFriend.photo));
        [cell.someOne setImageWithURL:USER_HEAD_IMG_URL(@"small", _chatFriend.photo) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
        cell.someOne.userInteractionEnabled = YES;
        cell.someOne.tag = CHAT_FRIEND;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserInfo:)];
        [cell.someOne addGestureRecognizer:singleTap];
        
        cell.someOne.backgroundColor = [UIColor grayColor];
        
        //==========================================================================================
        if (cell.dataInternal.data.isNewMessage == YES) {
            if (cell.dataInternal.data.dataType == TYPE_VOICE) {
                _numUnreadVoice += 1;
                [_unreadVoiceDic setObject:cell.dataInternal forKey:[[NSString alloc] initWithFormat:@"%d", _numUnreadVoice]];
                NSLog(@"change dataInternal tag:%d -> %d", cell.dataInternal.tag, _numUnreadVoice);
                NSLog(@"change data tag:%d -> %d", cell.dataInternal.data.tag, _numUnreadVoice);
                cell.dataInternal.data.tag = _numUnreadVoice;
                cell.dataInternal.tag = _numUnreadVoice;
                
                NSArray *voiceKeys = [_unreadVoiceDic allKeys];
                NSMutableArray *willDeleteVoice = [[NSMutableArray alloc] init];
                for (int i = 0; i < _unreadVoiceDic.count; i++) {
                    NSBubbleDataInternal *bubbleData = [_unreadVoiceDic objectForKey:[voiceKeys objectAtIndex:i]];
                    if (bubbleData.data.tag == -1 || (bubbleData.data.tag != [[voiceKeys objectAtIndex:i] intValue])) {
                        [willDeleteVoice addObject:[voiceKeys objectAtIndex:i]];
                    }
                }
                
                if (willDeleteVoice.count > 0) {
                    for (NSString *willDeleteBubbleDataInternal in willDeleteVoice) {
                        NSBubbleDataInternal* willDeleteData = [_unreadVoiceDic objectForKey:willDeleteBubbleDataInternal];
                    }
                    [_unreadVoiceDic removeObjectsForKeys:willDeleteVoice];
                }
            }
        }
        //==========================================================================================
    }else{
        AccountUser *user = [AccountUser getSingleton];
        NSLog(@"user.photoID : %@", USER_HEAD_IMG_URL(@"small", user.photoID));
        [cell.mine setImageWithURL:USER_HEAD_IMG_URL(@"small", user.photoID) placeholderImage:[UIImage imageNamed:AVATAR_PIC_HOLDER]];
        cell.mine.userInteractionEnabled = YES;
        cell.someOne.tag = CHAT_SELF;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserInfo:)];
        [cell.mine addGestureRecognizer:singleTap];
        cell.mine.backgroundColor = [UIColor grayColor];
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView = backView;
    [cell.selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [cell checkSelf];

    return cell;
}
//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//单击一个cell
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    return nil;
}

-(void) showUserInfo:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    NSLog(@"%@", [self.navDelegate class]);
    
    if(tap.view.tag == CHAT_FRIEND) {
        [self.navDelegate performSelector:@selector(showChatUserInfo:) withObject:_chatFriend];
    }else if(tap.view.tag == CHAT_SELF){
        AccountUser *user = [AccountUser getSingleton];
        [self.navDelegate performSelector:@selector(showChatUserInfo:) withObject:user];
    }
}



//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touchesBegan...");
//    [[NSNotificationCenter defaultCenter] postNotificationName:HIDEKEYBOARD object:nil];
//    
//}

- (float)calVoiceViewWidth:(int)length
{
    //width:40-180,length:1-30
    float width;
    float rate = 140.0/(sqrtf(30.0)-1);
    width = (sqrtf((float)length)-1)*rate+40;
    return width;
}

- (UIViewController *)getSuperViewController
{
    return [self.bubbleDataSource getController];
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		UIBubbleTableViewCell *cell = (UIBubbleTableViewCell *)recognizer.view;
        [cell becomeFirstResponder];
		
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItem:)];
        UIMenuItem *resendMessage = [[UIMenuItem alloc] initWithTitle:@"重发" action:@selector(resendMessage:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (cell.dataInternal.data.needToPost) {
            [menu setMenuItems:[NSArray arrayWithObjects:delete, resendMessage, nil]];
        }
        else{
            [menu setMenuItems:[NSArray arrayWithObjects:delete, nil]];
        }
//		[menu update];
        
        float x = (cell.dataInternal.data.type == BubbleTypeSomeoneElse) ? 61 : cell.frame.size.width - 61 - cell.dataInternal.labelSize.width -16;
        float y = (cell.dataInternal.header ? 35 : 5);
        CGRect currentBubbleImageFrame = [cell getBubbleImageFrame];
		[menu setTargetRect:CGRectMake(cell.frame.origin.x + x, cell.frame.origin.y + y, currentBubbleImageFrame.size.width, currentBubbleImageFrame.size.height) inView:cell.superview];
        [menu setMenuVisible:YES animated:YES];
	}
}

- (void)deleteItem:(id)sender {
	NSLog(@"Cell was flagged");
}

- (void)resendMessage:(id)sender {
	NSLog(@"Cell was approved");
}

- (void)deny:(id)sender {
	NSLog(@"Cell was denied");
}

#pragma mark - 数据更新时的数据处理
//获取指定bubbleDictionary中记录的个数
- (NSInteger)getRecordNum:(NSMutableDictionary *)bubbleDictionary
{
    //记录总数
    NSInteger recordNum = 0;
    
    for (NSMutableArray *bubbleDataArray in bubbleDictionary.allValues) {
        for (NSBubbleDataInternal *bubbleData in bubbleDataArray) {
            recordNum ++;
        }
    }
    
return recordNum;
}

- (BOOL)isEqualWithBubbleData:(NSBubbleData *)firstBubbleData and:(NSBubbleData *)secondBubbleData{
    
    if ([firstBubbleData.text isEqualToString:secondBubbleData.text]
        && [firstBubbleData.date timeIntervalSinceDate:secondBubbleData.date] == 0
        && firstBubbleData.dataType == secondBubbleData.dataType) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 音频播放记录处理
- (void)voideHavePalyed{
    _numUnreadVoice --;
}

- (void)handleVoicePlayed:(NSNotification *)notification{
    NSString *notificationString = notification.object;
    NSInteger voiceTag = [notificationString intValue];
    
    if (voiceTag < 0) {
        [_unreadVoiceDic removeObjectForKey:[[NSString alloc] initWithFormat:@"%d", - voiceTag]];
        return;
    }
    
    NSArray *voiceKeys = [_unreadVoiceDic allKeys];
    NSMutableArray *willDeleteVoice = [[NSMutableArray alloc] init];
    for (int i = 0; i < _unreadVoiceDic.count; i++) {
        NSBubbleDataInternal *bubbleData = [_unreadVoiceDic objectForKey:[voiceKeys objectAtIndex:i]];
        if (bubbleData.data.tag == -1 || (bubbleData.data.tag != [[voiceKeys objectAtIndex:i] intValue])) {
            [willDeleteVoice addObject:[voiceKeys objectAtIndex:i]];
        }
    }
    
    if (willDeleteVoice.count > 0) {
//        NSLog(@"WillDeleteData %@", willDeleteVoice);
        [_unreadVoiceDic removeObjectsForKeys:willDeleteVoice];
    }
    
    NSArray *voiceKeyArray = [_unreadVoiceDic allValues];
    NSArray *sortedArray = [voiceKeyArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSBubbleDataInternal *bubbleData1 = (NSBubbleDataInternal *)obj1;
        NSBubbleDataInternal *bubbleData2 = (NSBubbleDataInternal *)obj2;
        
        return [bubbleData1.data.date compare:bubbleData2.data.date];
    }];
    
//    NSLog(@"%@", sortedArray);
    for (int i = 0; i < sortedArray.count; i++) {
        NSBubbleDataInternal *bubbleData = [sortedArray objectAtIndex:i];
        NSBubbleDataInternal *bubbleDataIn = [_unreadVoiceDic objectForKey:notificationString];
        if (bubbleDataIn == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_PLAYNEWVOICE object:[[NSString alloc] initWithFormat:@"%d", bubbleData.data.tag]];
            break;
        }
        else if ([bubbleData.data.date compare:bubbleDataIn.data.date] == NSOrderedDescending && bubbleData.data.tag != -1) {
            NSLog(@"UIBubbleTableView Send PlayNewVoice Tag:%d Date:%@ Length:%d", bubbleData.data.tag, bubbleData.data.date, bubbleData.data.length);
            [self showHideCell];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_PLAYNEWVOICE object:[[NSString alloc] initWithFormat:@"%d", bubbleData.data.tag]];
            break;
        }
    }
    [_unreadVoiceDic removeObjectForKey:notificationString];
    [self deleteCell:nil];
    return;
    
}

//获取UIBubbleTableViewCell
/*
 * 功能：
 *      从隐藏的Cell队列中获取已经初始化的Cell，并将将要被隐藏的Cell存储在隐藏Cell队列中
 *
 * 参数：
 *      bubbleTableViewCell         需要被更新的Cell
 *      bubbleData                  将会更新Cell的数据
 *
 * 判断规则：
 *      若为新的信息并且为音频：查看是否已经存储在Dic中 ？ 返回Dic中的Cell指针 ：存储在Dic中并返回Cell指针
 *      若不为新的信息或音频：返回此Cell指针或Nil
 */
- (UIBubbleTableViewCell*)getBubbleCell:(UIBubbleTableViewCell *)bubbleTableViewCell andData:(NSBubbleDataInternal*)bubbleData{
    UIBubbleTableViewCell *returnBubbleCell = nil;
    UIBubbleTableViewCell *tempBubbleCell = [[UIBubbleTableViewCell alloc] init];
    if (bubbleTableViewCell) {
        //判断需要被更新的Cell内容是否为未播放的音频Cell
        if (bubbleTableViewCell.dataInternal.data.dataType == TYPE_VOICE &&
            bubbleTableViewCell.dataInternal.data.isNewMessage == YES &&
            bubbleTableViewCell.dataInternal.data.tag != -1) {
            //判断此Cell是否存储在隐藏Cell队列中
            NSArray *BubbleCellKeys = [self checkHideCellDic:bubbleTableViewCell];
            //若不在队列中则存储此Cell
            if (BubbleCellKeys) {
                if (BubbleCellKeys.count > 0) {
//                    returnBubbleCell = [[_tableViewHideCell objectsForKeys:BubbleCellKeys notFoundMarker:nil] objectAtIndex:0];
                    [self deleteCell:bubbleTableViewCell];
                    [self saveCell:bubbleTableViewCell];
                }
            }
            else{
                [self saveCell:bubbleTableViewCell];
            }
        }
    }
    else{
        returnBubbleCell = bubbleTableViewCell;
    }
    
    if (bubbleData) {
        //判断将会更新Cell的数据是否为未播放的音频数据
        if (bubbleData.data.dataType == TYPE_VOICE && bubbleData.data.isNewMessage == YES) {
            tempBubbleCell.dataInternal = bubbleData;
            //查询是否隐藏Cell存储在队列中
            NSArray *BubbleCellKeys = [self checkHideCellDic:tempBubbleCell];
            if (BubbleCellKeys) {
                if (BubbleCellKeys.count > 0) {
                    returnBubbleCell = [_tableViewHideCell objectForKey:[BubbleCellKeys objectAtIndex:0]];
                    NSLog(@"getBubbleCell tag:%d key:%@ cell:%@", returnBubbleCell.dataInternal.data.tag, [BubbleCellKeys objectAtIndex:0], tempBubbleCell);
//                    [self deleteCell:tempBubbleCell];
                }
            }
            else{
                [self saveCell:tempBubbleCell];
            }
        }
    }
    [self deleteCell:Nil];
    
    return returnBubbleCell;
}

//存储需要隐藏的Cell对象
//若已经存储则不再存储
- (void)saveCell:(UIBubbleTableViewCell *)bubbleTableViewCell{
    if (bubbleTableViewCell) {
        if (![self checkHideCellDic:bubbleTableViewCell]) {
            [_tableViewHideCell setObject:bubbleTableViewCell forKey:[NSString stringWithFormat:@"%d", bubbleTableViewCell.dataInternal.data.tag]];
            NSLog(@"saveCell tag:%d cell:%@", bubbleTableViewCell.dataInternal.data.tag, bubbleTableViewCell);
        }
    }
}

/*
 *  功能：删除包含此Cell中NSBubbleData对象的所有Cell
 *
 *  参数：
 *      bubbleTableViewCell     需要删除的Cell
 *
 */
- (void)deleteCell:(UIBubbleTableViewCell *)bubbleTableViewCell{
    if (bubbleTableViewCell) {
        NSArray *willBeDeletedBubbleCells = [self checkHideCellDic:bubbleTableViewCell];
        
        if (willBeDeletedBubbleCells) {
            [_tableViewHideCell removeObjectsForKeys:willBeDeletedBubbleCells];
            NSLog(@"deleteCell %@", willBeDeletedBubbleCells);
        }
    }
    
    //删除其他已经播放或Tag为-1的Cell
    NSMutableArray *willBeDeletedBubbleCells = [NSMutableArray arrayWithCapacity:3];
    for (NSString *cellTag in _tableViewHideCell.allKeys) {
        UIBubbleTableViewCell *checkCell = [_tableViewHideCell objectForKey:cellTag];
        if (checkCell.dataInternal.data.tag == -1 ||
            checkCell.dataInternal.data.isNewMessage == NO ||
            !([cellTag isEqualToString:[NSString stringWithFormat:@"%d", checkCell.dataInternal.data.tag]])) {
            [willBeDeletedBubbleCells addObject:cellTag];
        }
    }
    if (willBeDeletedBubbleCells && willBeDeletedBubbleCells.count > 0) {
        [_tableViewHideCell removeObjectsForKeys:willBeDeletedBubbleCells];
        NSLog(@"deleteCell check:%@", willBeDeletedBubbleCells);
    }
}

//查看存储隐藏Cell的数组中是否包含此Cell
//  若存在：返回此Cell的指针
//  若不存在：返回Nil
- (NSArray* )checkHideCellDic:(UIBubbleTableViewCell *)bubbleTableViewCell{
    if (bubbleTableViewCell && _tableViewHideCell) {
        if (_tableViewHideCell.count > 0) {
            for (UIBubbleTableViewCell* hideCell in _tableViewHideCell.allValues) {
                if ([hideCell.dataInternal.data isEqual:bubbleTableViewCell.dataInternal.data]
                    && hideCell.dataInternal.data.tag == bubbleTableViewCell.dataInternal.data.tag) {
                    return [_tableViewHideCell allKeysForObject:hideCell];
                }
            }
        }
        return Nil;
    }
    return Nil;
}

- (void)showHideCell{
    NSLog(@"show Cell");
    for (NSBubbleDataInternal* data in _unreadVoiceDic.allValues) {
        NSLog(@"BubbleData Tag:%d Date:%@ Length:%d BubbleData:%@", data.data.tag, data.data.date, data.data.length, data);
    }
    
    NSLog(@"show Hide Cell");
    for (UIBubbleTableViewCell* cell in _tableViewHideCell.allValues) {
        NSLog(@"BubbleTableViewCell Tag:%d Date:%@ Length:%d Cell:%@", cell.dataInternal.data.tag, cell.dataInternal.data.date, cell.dataInternal.data.length, cell);
    }
}

#pragma mark - 发送网址信息处理
//重复发送信息的回调函数
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 2001:{
            if (buttonIndex == 1) {
                [self openURL:self.strOpenURL];
            }
            else if (buttonIndex == 0){
                
            }
            
            break;
        }
            
        default:{
        }
    }
    
    
}

- (void)selectLinker:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *str = btn.titleLabel.text;
    NSLog(@"Open Safari with URL :%@", str);
    [self setStrOpenURL:str];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"特别提示"
                                                    message:@"将利用浏览器打开此网页，进入网页后请不要输入个人信息，以防诈骗"
                                                   delegate:self
                                          cancelButtonTitle:@"那算了"
                                          otherButtonTitles:@"知道了~", nil];
    alert.tag = 2001;
    [alert show];
}

- (BOOL)openURL:(NSString *)webURL{
    NSLog(@"Open Safari with URL :%@", webURL);
    if (![[webURL lowercaseString] hasPrefix: @"http://"]){
        webURL = [[NSString alloc] initWithFormat:@"http://%@", [webURL lowercaseString]];
        NSLog(@"Open Safari with URL :%@", webURL);
    }
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[webURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
}

@end
