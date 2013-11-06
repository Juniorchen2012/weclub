//
//  ChatListSaveProxy.m
//  WeClub
//
//  Created by Archer on 13-2-27.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "ChatListSaveProxy.h"

#define STOREPATH [NSHomeDirectory() stringByAppendingString:@"/Documents/chat1.sqlite"]

@implementation ChatListSaveProxy

@synthesize context;
@synthesize results;

SYNTHESIZE_SINGLETON_FOR_CLASS(ChatListSaveProxy);

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"ChatListSaveProxy init...");
        [self initCoreData];
    }
    return self;
}

-(void)dealloc {
    self.results.delegate = nil;
}

//初始化CoreData“Documents/chat1.sqlite”
- (void)initCoreData
{
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:STOREPATH];
    NSLog(@"url path:%@",url.path);
    
    //搜索工程中所有的.xcdatamodeld文件，并加载所有的实体到一个managedObjectModel实例中
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    // 创建持久化数据存储协调器
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    // 创建一个SQLite数据库作为数据存储
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }else{
        NSLog(@"successful...");
        // 创建托管对象上下文
        self.context = [[NSManagedObjectContext alloc] init];
        [self.context setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
}

//向数据库中添加一个用户信息
- (void)addFriend:(FriendModel *)fri
{
    NSLog(@"add friend...");
    ChatFriend *friend = (ChatFriend *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatFriend" inManagedObjectContext:self.context];
    friend.friendID = fri.friendID;
    friend.photo = fri.photo;
    friend.name = fri.name;
    friend.lastMsg = fri.lastMsg;
    friend.sex = fri.sex;
    friend.masterID = fri.masterID;
    
    //save the data
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    
//    [self getFriends];
}

//从数据库中获取所有用户信息
- (NSArray *)getFriends
{
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    self.results = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatFriend" inManagedObjectContext:self.context]];
    
    //增加一个筛选条件
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastDate" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterID == %@",[AccountUser getSingleton].numberID];
    NSLog(@"master ID:%@",[AccountUser getSingleton].numberID);
    fetchRequest.predicate = predicate;
    
    //设置结果集
    NSError *error = [[NSError alloc] init];
    self.results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                       managedObjectContext:self.context
                                                         sectionNameKeyPath:nil cacheName:@"Root"];
    self.results.delegate = self;
    //FIXME:经常在此崩溃
    if (![[self results] performFetch:&error]) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
//    if (self.results.fetchedObjects.count != 0) {
//        if (![[self results] performFetch:&error]) {
//            NSLog(@"Error: %@",[error localizedDescription]);
//        }
//    }
    
    if (!self.results.fetchedObjects.count) {
        NSLog(@"has no results...");
        return nil;
    }else{
        return self.results.fetchedObjects;
    }

}

//根据ID获取指定用户信息
- (ChatFriend *)getFriendByID:(NSString *)ID
{
    ChatFriend *result;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatFriend" inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"friendID" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendID == %@ and masterID == %@",ID,[AccountUser getSingleton].numberID];
    fetchRequest.predicate = predicate;
    
    NSError *error;
    self.results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.results.delegate = self;
    if (![[self results] performFetch:&error]) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    
    if (!self.results.fetchedObjects.count) {
        NSLog(@"has no results...");
        return nil;
    }else if([self.results.fetchedObjects count] > 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"data error:repeat friendID" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    result = [self.results.fetchedObjects objectAtIndex:0];

    return result;
}

//获取所有聊天信息（未用到）
- (NSArray *)getMessages
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:self.context]];
    
    //增加一个筛选条件
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"text" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"masterID == %@",[AccountUser getSingleton].numberID];
    NSLog(@"master ID:%@",[AccountUser getSingleton].numberID);
    fetchRequest.predicate = predicate;
    
    //设置结果集
    NSError *error;
    self.results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:@"Root"];
    self.results.delegate = self;
    if (![[self results] performFetch:&error]) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    
    if (!self.results.fetchedObjects.count) {
        NSLog(@"has no results...");
        return nil;
    }else{
        return self.results.fetchedObjects;
    }
}

#pragma mark - 删除信息
//删除所有好友，连带将与这个好友的聊天记录全部删除
- (void)removeAllFriend
{
    NSArray *allFriends = [self getFriends];
    
    if (allFriends.count > 0) {
        for (ChatFriend *friend in allFriends) {
            [self removeFriend:friend];
        }
    }
}

//删除指定好友，连带将与这个好友的聊天记录全部删除
- (void)removeFriend:(ChatFriend *)fri
{
    //删除聊天记录
    [self removeFriendMessages:fri];
    
    //删除好友
    [self.context deleteObject:fri];
    
    //保存
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"error :%@",[error localizedDescription]);
    }
    
}


//删除所有好友的聊天记录聊天记录，不删除好友信息
- (void)removeAllMessages
{
    NSArray *allFriends = [self getFriends];
    
    if (allFriends.count > 0) {
        for (ChatFriend *friend in allFriends) {
            [self removeFriendMessages:friend];
        }
    }
}

//删除指定好友的聊天记录，不删除好友信息
- (void)removeFriendMessages:(ChatFriend *) friend
{
    if ([friend.messages count] != 0) {
        //获取所有聊天信息
        NSArray *messages = [friend getMessagesDataArray];
        for (int i = 0; i < [friend.messages count]; i++) {
            [[messages objectAtIndex:i] setMaster:nil];
            [self removeMessage:[messages objectAtIndex:i]];
        }
    }
    
    //需要验证这个方法是否将messages本体删除
    [friend removeMessages:friend.messages];
    
    //保存
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"error :%@",[error localizedDescription]);
    }
}

//删除一条聊天记录
- (void)removeMessage:(ChatMessage *)msg
{
    //删除message中的链接的数据
    int dataType = [msg.dataType intValue];
    if (dataType == TYPE_PIC && dataType == TYPE_VIDEO) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:msg.text error:&error]) {
            NSLog(@"error :%@",[error localizedDescription]);
        }
    }
    
    ChatFriend *friend = msg.master;
    msg.master = nil;
    [friend removeMessagesObject:msg];
    
    [self.context deleteObject:msg];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"remove msg error:%@",[error localizedDescription]);
    }
}

#pragma mark - 添加信息
//给某个好友增加一条聊天记录
- (void)addMessage:(NSBubbleData *)bubbleData to:(ChatFriend *)fri
{
    ChatMessage *msg = (ChatMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"ChatMessage" inManagedObjectContext:self.context];
    msg.date = bubbleData.date;
    msg.type = [NSNumber numberWithInt:bubbleData.type];
    msg.text = bubbleData.text;
    msg.dataType = [NSNumber numberWithInt:bubbleData.dataType];
    msg.data = bubbleData.data;
    msg.urlString = bubbleData.urlString;
    msg.length = [NSNumber numberWithInt:bubbleData.length];
    msg.needToPost = bubbleData.needToPost;
    msg.msgToPost = bubbleData.msgToPost;
    msg.requestIndex = [NSNumber numberWithInt:bubbleData.requestIndex];
    msg.master = fri;
    msg.mid = bubbleData.mid;
    msg.isNewMessage = bubbleData.isNewMessage;
    //TODO:ChatMessageProxy
//    msg.messageState = bubbleData.messageState;
    NSLog(@"%@",bubbleData.mid);
    [fri addMessagesObject:msg];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"add msg error:%@",[error localizedDescription]);
    }
}

#pragma mark - 获得信息
//根据Text查询某条聊天记录
- (ChatMessage *)getMessageWithText:(NSString *)text
{
    ChatMessage *msg;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"text" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text == %@",text];
    fetchRequest.predicate = predicate;
    
    NSError *error;
    self.results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.results.delegate = self;
    if (![[self results] performFetch:&error]) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    
    if (!self.results.fetchedObjects.count) {
        NSLog(@"has no results...");
        return nil;
    }else if([self.results.fetchedObjects count] > 1){
        NSLog(@"data error:repeat message.text,count:%d",[self.results.fetchedObjects count]);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"data error:repeat message.text,count:%d",[self.results.fetchedObjects count]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
    
    msg = [self.results.fetchedObjects objectAtIndex:0];
    
    return msg;
}

//根据Text和日期查询某条聊天记录
- (ChatMessage *)getMessageByText:(NSString *)text andDate:(NSDate *)date{
    ChatMessage *msg;
    int nMessageIndex = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:self.context]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"text" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"text == %@",text];
    fetchRequest.predicate = predicate;
    
    NSError *error;
    self.results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.results.delegate = self;
    if (![[self results] performFetch:&error]) {
        NSLog(@"Error: %@",[error localizedDescription]);
    }
    
    if (!self.results.fetchedObjects.count) {
        NSLog(@"has no results...");
        return nil;
    }else if([self.results.fetchedObjects count] > 1){
        NSLog(@"data error:repeat message.text,count:%d",[self.results.fetchedObjects count]);
        
        for(int i = 0; i < [self.results.fetchedObjects count]; i++){
            ChatMessage *message = [self.results.fetchedObjects objectAtIndex:i];
            if([message.date isEqualToDate:date]){
                nMessageIndex = i;
                break;
            }
        }
    }
    
    msg = [self.results.fetchedObjects objectAtIndex:nMessageIndex];
    
    return msg;
}

//获取与此好友发送的所有照片(ChatMessage)
- (NSArray *)getAllPICMessages:(ChatFriend *) friend
{
    NSMutableArray *PicMessages = nil;
    NSArray *sortedArray;
    if ([friend.messages count] != 0) {
        PicMessages = [[NSMutableArray alloc] init];
        
        for (ChatMessage *message in [friend getMessagesDataArray]) {
            if ([message.dataType intValue] == TYPE_PIC) {
                [PicMessages addObject:message];
            }
        }
    }
    
    sortedArray = [PicMessages sortedArrayUsingComparator:^(id item1,id item2){
        ChatMessage *data1 = item1;
        ChatMessage *data2 = item2;
        NSComparisonResult result = (NSComparisonResult)[data1.date compare:data2.date];
        return result;
    }];
    
    return [[NSArray alloc] initWithArray:sortedArray];
}

//获取与此好友发送的所有照片(BubbleData)
- (NSArray *)getAllPICBubbleData:(ChatFriend *) friend
{
    NSMutableArray *PicMessages = nil;
    NSArray *sortedArray;
    if ([friend.messages count] != 0) {
        PicMessages = [[NSMutableArray alloc] init];
        NSArray *bubledata = friend.getBubbleDataArray;
        
        for (NSBubbleData *data in bubledata) {
            if (data.type == TYPE_PIC) {
                [PicMessages addObject:data];
            }
        }
    }
    
    sortedArray = [PicMessages sortedArrayUsingComparator:^(id item1,id item2){
        ChatMessage *data1 = item1;
        ChatMessage *data2 = item2;
        NSComparisonResult result = (NSComparisonResult)[data1.date compare:data2.date];
        return result;
    }];
    
    return [[NSArray alloc] initWithArray:sortedArray];
}

- (NSComparisonResult)compareLength:(NSNumber *)num
{
    if ([num intValue]>15) {
        return NSOrderedDescending;
    }else{
        return NSOrderedAscending;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//	NSLog(@"Controller content did change");
    
}

- (void)testModel
{
//    NSArray * arr = [self getFriends];
//    ChatFriend *f = [arr objectAtIndex:0];
//    for (ChatMessage *msg in f.messages) {
//        NSLog(@"aaaaa:%@",msg.text);
//    }
    
//    FriendModel *friend = [[FriendModel alloc] init];
//    friend.name = @"super girl";
//    [self addFriend:friend];
//    
    NSArray *friendArray = [self getFriends];
    NSLog(@"numbers of friend:%d",[friendArray count]);
    ChatFriend *f = [friendArray objectAtIndex:0];
    NSLog(@"f msgs:%d",[f.messages count]);

//    NSBubbleData *data = [NSBubbleData dataWithText:@"world" andDate:nil andType:nil andData:nil withDataType:nil];
//    [self addMessage:data to:f];
    
//    [self removeFriend:f];
    
//    NSArray *msgArray = [self getMessages];
//    NSLog(@"numbers of message:%d",[msgArray count]);
//    if ([msgArray count]) {
//        for (ChatMessage *msg in msgArray) {
//            NSLog(@"msg:%@",msg.text);
//            [self removeMessage:msg];
//        }
//    }
    NSArray *msgArray2 = [self getMessages];
    NSLog(@"numbers of message:%d",[msgArray2 count]);
    
    NSArray *friendArray2 = [self getFriends];
    NSLog(@"numbers of friend:%d",[friendArray2 count]);
    ChatFriend *f2 = [friendArray2 objectAtIndex:0];
    NSLog(@"f msgs:%d",[f2.messages count]);
    
    for (ChatMessage *msg in f2.messages) {
        NSLog(@"msg text:%@",msg.text);
    }
    
}

#pragma mark - 保存信息
- (void)saveUpdate
{
    NSError *error;
    if (self.context) {
        if ([self.context hasChanges]) {
            if (![self.context save:&error]) {
                NSLog(@"remove msg error:%@",[error localizedDescription]);
            }
        }
    }
    
}

@end
