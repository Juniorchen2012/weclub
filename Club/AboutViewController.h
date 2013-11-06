//
//  AboutViewController.h
//  WeClub
//
//  Created by chao_mit on 13-3-30.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITextView *tv;
    int contentType;
    
    UITableView             *table;
    NSArray                 *qList;
    NSArray                 *aList;
    NSMutableArray          *array_section_open;
    
    UITextView              *_protocolText;
    UITextView              *_helpText;
}

@property (nonatomic,strong) NSString *zbarHelpFlag;

- (id)initWithContentType:(NSString *)type;
@end
