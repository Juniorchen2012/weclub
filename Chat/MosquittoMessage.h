//
//  MosquittoMessage.h
//  Marquette
//
//  Created by horace on 11/10/12.
//
//

#import <Foundation/Foundation.h>

@interface MosquittoMessage : NSObject
{
    unsigned short mid;
    NSString *topic;
    NSString *payload;
    unsigned short payloadlen;
    unsigned short qos;
    BOOL retain;
    NSData *data;
}


@property (readwrite, assign) unsigned short mid;
@property (nonatomic, retain) NSString *topic;
@property (readwrite, retain) NSString *payload;
@property (readwrite, assign) unsigned short payloadlen;
@property (readwrite, assign) unsigned short qos;
@property (readwrite, assign) BOOL retain;
@property (readwrite, retain) NSData *data;

-(id)init;

@end