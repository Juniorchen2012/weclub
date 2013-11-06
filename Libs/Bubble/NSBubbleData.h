//
//  NSBubbleData.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

typedef enum _NSBubbleMessageState
{
    BubbleMessageNew = 0,
    BubbleMessageSeading = 1,
    BubbleMessageSucceed = 2,
    BubbleMEssageFailed = -1
} NSBubbleMessageState;

@interface NSBubbleData : NSObject
{
    NSInteger _dataType;
    NSData *_data;
    NSString *_urlString;
    BOOL _needToPost;
    NSString *_msgToPost;
    int _requestIndex;
    NSString *_mid;
    BOOL _isNewMessage;
    int _tag;
}

@property (nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic, strong) NSString *text;
@property (readonly, nonatomic) NSInteger dataType;
@property (nonatomic, assign) NSData *data;
@property (nonatomic,retain) NSString *urlString;
@property (nonatomic,assign) NSInteger length;
@property (nonatomic,assign) BOOL needToPost;
@property (nonatomic,retain) NSString *msgToPost;
@property (nonatomic,assign) int requestIndex;
@property (nonatomic,retain) NSString *mid;
@property (nonatomic, assign) NSBubbleMessageState messageState;
//判断当前记录是否为未读新信息
@property (nonatomic, assign) BOOL isNewMessage;
@property (nonatomic, retain) UIView *textView;
@property (nonatomic, assign) int tag;

- (id)initWithText:(NSString *)text andDate:(NSDate *)date andType:(NSBubbleType)type andData:(NSData *)dataBody withDataType:(NSInteger)dataBodyType;
+ (id)dataWithText:(NSString *)text andDate:(NSDate *)date andType:(NSBubbleType)type andData:(NSData *)dataBody withDataType:(NSInteger)dataBodyType;

@end
