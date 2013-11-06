//
//  UIBubbleTableViewCell.h
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


#import <UIKit/UIKit.h>
#import "NSBubbleDataInternal.h"
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieViewController.h"
#import "PicViewController.h"
#import "JSONKit.h"
#import "ReLocateViewController.h"
#import "RequestQueue.h"
#import "ChatListSaveProxy.h"

@interface UIBubbleTableViewCell : UITableViewCell<AVAudioPlayerDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate, UIAlertViewDelegate,MWPhotoBrowserDelegate, NSCopying>
{
    UILabel *headerLabel;
    UILabel *contentLabel;
    UIImageView *bubbleImage;
    UIButton *contentButton;
//    UIButton *bigButton;
    AVAudioPlayer *AudioPlayer;
    
    UIImageView *_someOne;
    UIImageView *_mine;
    
    NSTimer *_timer;
    int _voicePicTag;
    
    ASIFormDataRequest *_request;
    UIProgressView *uploadProgress;
    UIButton *uploadCancelButton;
    UIButton *reupload;
//    BOOL isPostingMsg;
    
    NSArray *picLibrary;
    UIViewController *viewController;
}

@property (nonatomic, strong) NSBubbleDataInternal *dataInternal;
@property (nonatomic, retain) UIImageView *someOne;
@property (nonatomic, retain) UIImageView *mine;
@property (nonatomic, assign) id sendDelegate;
@property (nonatomic, retain) UIViewController *viewController;


- (void)showPic;
//- (IBAction)playVoice:(id)sender;
- (void)playVoice;
//- (void)postHideKeyBoardNotification;
- (void)checkSelf;
- (void)playMovie;
- (void)myMovieFinishedCallback:(NSNotification *)aNotification;
- (CGRect)getBubbleImageFrame;

@end
