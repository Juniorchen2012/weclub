//
//  NSBubbleData.m
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

#import "NSBubbleData.h"

@implementation NSBubbleData

@synthesize date = _date;
@synthesize type = _type;
@synthesize text = _text;
@synthesize dataType = _dataType;
@synthesize data = _data;
@synthesize urlString = _urlString;
@synthesize needToPost = _needToPost;
@synthesize msgToPost = _msgToPost;
@synthesize requestIndex = _requestIndex;
@synthesize mid = _mid;
@synthesize isNewMessage = _isNewMessage;
@synthesize tag = _tag;

+ (id)dataWithText:(NSString *)text andDate:(NSDate *)date andType:(NSBubbleType)type andData:(NSData *)dataBody withDataType:(NSInteger)dataBodyType
{
    return [[[NSBubbleData alloc] initWithText:text andDate:date andType:type andData:dataBody withDataType:dataBodyType] autorelease];
}

- (id)initWithText:(NSString *)initText andDate:(NSDate *)initDate andType:(NSBubbleType)initType andData:(NSData *)dataBody withDataType:(NSInteger)dataBodyType
{
    self = [super init];
    if (self)
    {
        _text = [initText retain];
        if (!_text || [_text isEqualToString:@""]) _text = @" ";
        
        _date = [initDate retain];
        _type = initType;
        _dataType = dataBodyType;
        _data = [dataBody retain];
        _needToPost = NO;
        _mid = @"0";
        _messageState = BubbleMessageNew;
        _textView = nil;
        _isNewMessage = FALSE;
    }
    return self;
}

- (void)dealloc
{
    [_date release];
	_date = nil;
	[_text release];
	_text = nil;
    [_data release];
    _data = nil;
    _mid = nil;
    [super dealloc];
}

@end
