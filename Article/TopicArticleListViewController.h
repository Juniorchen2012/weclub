//
//  TopicArticleListViewController.h
//  WeClub
//
//  Created by chao_mit on 13-4-3.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleCell.h"

@interface TopicArticleListViewController : UITableViewController<RequestProxyDelegate>{
    NSString *topicKey;
    RequestProxy * rp;
    NSMutableArray *list;
    NSString *startKey;
    bool isLoadMore;
    NSString *searchType;
}
@property(nonatomic,assign)bool isLoadMore;
- (id)initWithTopic:(NSString *)topicStr withType:(NSString *)mysearchType;
@end
