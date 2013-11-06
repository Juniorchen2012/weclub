//
//  MenuListTableViewController.h
//  WeClub
//
//  Created by Archer on 13-3-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuListTableViewController : UITableViewController
{
    NSMutableArray *_menuItemArray;
}

- (void)setInFollow:(BOOL)inFollow andInBlack:(BOOL)inBlack;

@end
