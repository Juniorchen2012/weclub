//
//  MQttTxFlow.h
//

#import <Foundation/Foundation.h>
#import "MQTTMessage.h"

@interface MQttTxFlow : NSObject {
    MQTTMessage *   msg;
    unsigned int    deadline;
}

+ (id)flowWithMsg:(MQTTMessage*)aMsg
         deadline:(unsigned int)aDeadline;

- (id)initWithMsg:(MQTTMessage*)aMsg deadline:(unsigned int)aDeadline;

- (void)setMsg:(MQTTMessage*)aMsg;
- (void)setDeadline:(unsigned int)newValue;
- (MQTTMessage*)msg;
- (unsigned int)deadline;

@end

