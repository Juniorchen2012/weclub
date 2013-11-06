//
//  UserListTableViewController.m
//  WeClub
//
//  Created by Archer on 13-3-15.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "UserListTableViewController.h"

@interface UserListTableViewController ()

@end

@implementation UserListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataArray = [Constants getSingleton].userListArray;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
//    self.view.layer.cornerRadius = 5;
//    self.view.layer.borderWidth = 0;
//    self.view.backgroundColor = [UIColor clearColor];
    
//    self.tableView.layer.cornerRadius = 5;
//    self.tableView.layer.borderWidth = 0;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor grayColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    cell.textLabel.font = btn.titleLabel.font;
    cell.backgroundColor = btn.backgroundColor;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"hhhh:%d",(indexPath.row+4)%5);
    if ((indexPath.row+4)%5 == 0) {
        if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsUserAttention"]) {
            [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsUserAttention"];
        }
    }
    if ((indexPath.row+4)%5 == 1) {
        if ([[NoticeManager sharedNoticeManager] noticeIsExistWithType:@"bbsUserFollow"]) {
            [[NoticeManager sharedNoticeManager] resetNoticeWithType:@"bbsUserFollow"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_USERLIST object:[NSNumber numberWithInt:(indexPath.row+4)%5]];
    NSLog(@"hhhh:%d",(indexPath.row+4)%5);
}

@end
