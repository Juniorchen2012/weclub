//
//  UIBubbleTableViewCell.m
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


#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "Header.h"
#import "PicViewController.h"
#import "MsgResender.h"

@interface UIBubbleTableViewCell ()
- (void) setupInternalData;
@end

@implementation UIBubbleTableViewCell

@synthesize dataInternal = _dataInternal;
@synthesize viewController = viewController;
@synthesize someOne = _someOne;
@synthesize mine = _mine;

- (id)init{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"tblBubbleCell"];
    if (self) {
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 20)];
        [headerLabel setTextAlignment:NSTextAlignmentCenter];
        [headerLabel setTextColor:[UIColor darkGrayColor]];
        [headerLabel setFont:[UIFont fontWithName:@"System Bold" size:12]];
        [self.contentView addSubview:headerLabel];
        
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 29, 220, 52)];
        [contentLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:contentLabel];
        
        bubbleImage = [[UIImageView alloc] initWithFrame:CGRectMake(17, 38, 75, 41)];
        [self.contentView addSubview:bubbleImage];
        
        contentButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, 73, 44)];
        [self.contentView addSubview:contentButton];
        
        self.someOne = [[UIImageView alloc] init];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [contentLabel setHidden:YES];
    [contentButton setHidden:YES];
    contentLabel.text = @"";
    [contentButton setImage:nil forState:UIControlStateNormal];
    [contentButton setTitle:@"" forState:UIControlStateNormal];
    [contentButton removeTarget:self action:@selector(showPic) forControlEvents:UIControlEventTouchUpInside];
    [contentButton removeTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchDown];
    [contentButton removeTarget:self action:@selector(playMovie) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in contentButton.imageView.subviews) {
        [view removeFromSuperview];
    }

    [self.contentView addSubview:bubbleImage];
    
	[self setupInternalData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoice) name:NOTIFICATION_KEY_STOPVOICE object:nil];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (CGRect)getBubbleImageFrame{
    return bubbleImage.frame;
}

- (void) dealloc
{
    NSLog(@"UIBubble dealloc contentLable: %@", self.dataInternal.data.text);
    headerLabel = nil;
    contentLabel = nil;
    bubbleImage = nil;
    contentButton = nil;
	_dataInternal = nil;
    _someOne = nil;
    _mine = nil;
}

//为上传信息添加上传进度条与取消按钮
- (void)addUploadProgress
{
    if (self.dataInternal.data.type != BubbleTypeMine) {
        return;
    }
    _request.delegate = self;
    _request.uploadProgressDelegate = self;
    NSLog(@"total bytes:%lld,post length:%lld",_request.totalBytesSent,_request.postLength);
    
    //若信息已经发送成功，将发送环境置为初始化状态
    if (_request.totalBytesSent == _request.postLength && _request.postLength != 0) {
        //删除队列中的请求
        [[RequestQueue sharedRequestQueue] removeRequest:self.dataInternal.data.requestIndex];
        //初始化请求环境
        self.dataInternal.data.requestIndex = -1;
        self.dataInternal.data.needToPost = NO;
        ChatMessage *msg = [[ChatListSaveProxy sharedChatListSaveProxy] getMessageWithText:self.dataInternal.data.text];
        msg.requestIndex = [NSNumber numberWithInt:self.dataInternal.data.requestIndex];
        msg.needToPost = NO;
        return;
    }
    
    //添加上传进度条
    if (uploadProgress == nil) {
        uploadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    }
    uploadProgress.frame = CGRectMake(contentButton.frame.origin.x-5, contentButton.frame.origin.y+contentButton.frame.size.height+10, contentButton.frame.size.width+10, 10);
    [uploadProgress setHidden:NO];
    [self.contentView addSubview:uploadProgress];
    
    //添加上传取消按钮
    if (uploadCancelButton == nil) {
        uploadCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    uploadCancelButton.frame = CGRectMake(uploadProgress.frame.origin.x+uploadProgress.frame.size.width-10, uploadProgress.center.y-10, 20, 20);
    uploadCancelButton.backgroundColor = [UIColor clearColor];
    UIImage *uploadCancelImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_post_cancel" ofType:@"png"]];
    [uploadCancelButton setImage:uploadCancelImg forState:UIControlStateNormal];
    [uploadCancelButton addTarget:self action:@selector(cancelUpload) forControlEvents:UIControlEventTouchUpInside];
    [uploadCancelButton setHidden:NO];
    [self.contentView addSubview:uploadCancelButton];
}

//取消上传
- (void)cancelUpload
{
    NSLog(@"cancelUpload...");
    [uploadProgress setHidden:YES];
    [uploadCancelButton setHidden:YES];
    self.dataInternal.data.needToPost = YES;
    [[RequestQueue sharedRequestQueue] cancelRequest:self.dataInternal.data.requestIndex];
    ChatMessage *msg = [[ChatListSaveProxy sharedChatListSaveProxy] getMessageWithText:self.dataInternal.data.text];
    msg.needToPost = YES;
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
//    [self addResendTagX:0 Y:0];
    [self addReuploadButton];
}

//添加再次上传的按钮
- (void)addReuploadButton
{
    NSLog(@"addReuploadButton...");
    reupload = [UIButton buttonWithType:UIButtonTypeCustom];
    reupload.frame = CGRectMake(contentButton.frame.origin.x-35, contentButton.center.y-13, 26, 26);
    UIImage *reuploadImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_reupload" ofType:@"png"]];
    [reupload setImage:reuploadImg forState:UIControlStateNormal];
    reupload.backgroundColor = [UIColor clearColor];
    [reupload addTarget:self action:@selector(reuploadData) forControlEvents:UIControlEventTouchUpInside];
    reupload.tag = 1001;
    [self.contentView addSubview:reupload];
}

//再次上传图片和视频信息
- (void)reuploadData
{
    //删除再次上传按钮
    [reupload removeFromSuperview];
    reupload = nil;
    [self addUploadProgress];
    [self postMessage];
    _request.delegate = self;
    _request.uploadProgressDelegate = self;
}

//发送图片和视频信息
- (void)postMessage
{
    //根据url初始化请求
    NSLog(@"post message...");
    NSURL *url = [NSURL URLWithString:UPLOADSERVER];
    _request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    //获取需要发送的数据的地址
    NSLog(@"file path:%@",self.dataInternal.data.text);
    NSData *data = [NSData dataWithContentsOfFile:self.dataInternal.data.text];
    NSLog(@"fuck length:%d",data.length);
    
    //根据发送类型设定发送内容与类型信息
    int type = self.dataInternal.data.dataType;
    if (type == TYPE_PIC) {
        NSLog(@"11");
        [_request setData:data withFileName:@"image" andContentType:@"image/jpeg" forKey:@"microfile"];
    }else if(type == TYPE_VIDEO){
        [_request setData:data withFileName:@"video" andContentType:@"video/mpeg" forKey:@"microfile"];
    }
    
    //设定发送信息
    NSString *msg = self.dataInternal.data.msgToPost;
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    //    [request setFile:path forKey:@"microfile"];
    //    [request setPostValue:data forKey:@"microfile"];
    [_request setPostValue:msg forKey:@"message"];
    NSLog(@"msg:%@",msg);
    
    //设置发送请求头部
    [_request buildRequestHeaders];
    
    //获取发送请求的下标（为删除request和判断request是否成功做准备）
    self.dataInternal.data.requestIndex = [[RequestQueue sharedRequestQueue] addRequest:_request];
    self.dataInternal.data.needToPost = NO;
    
    ChatMessage *chatMsg = [[ChatListSaveProxy sharedChatListSaveProxy] getMessageWithText:self.dataInternal.data.text];
    chatMsg.needToPost = NO;
    chatMsg.requestIndex = [NSNumber numberWithInt:self.dataInternal.data.requestIndex];
    
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    //开始异步发送信息
    [_request startAsynchronous];
}

#pragma mark - ASIProgressDelegate
//发送视频图片上传过程当中回调函数
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
//    NSLog(@"total %lld,postlength:%lld",request.totalBytesSent,request.postLength);
    float rate = request.totalBytesSent*1.0/request.postLength;
    if (rate > uploadProgress.progress) {
        uploadProgress.progress = (rate >= 1) ? 1.0 : rate;
    }
    NSLog(@"progress:%f",uploadProgress.progress);
    //上传成功后初始化请求环境
    if (rate >= 1) {
        [self requestFinished:request];
    }
}

//视频图片上传结束时的回调函数
/* 判断信息是否发送成功机制
 若信息发送成功后会将会把mid至0（重发）或至空（发送成功）
 若信息发送没有成功那么mid则保存发表时间与发送对象名称
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished...");
    self.dataInternal.data.needToPost = NO;
    [uploadProgress setHidden:YES];
    [uploadCancelButton setHidden:YES];
    [[RequestQueue sharedRequestQueue] removeRequest:self.dataInternal.data.requestIndex];
    self.dataInternal.data.requestIndex = -1;
    ChatMessage *msg = [[ChatListSaveProxy sharedChatListSaveProxy] getMessageWithText:self.dataInternal.data.text];
    msg.requestIndex = [NSNumber numberWithInt:self.dataInternal.data.requestIndex];
    msg.needToPost = self.dataInternal.data.needToPost;
    msg.mid = @"0";
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
    _request = nil;
}

//视频图片上传失败时的回调函数
- (void)requestFailed:(ASIHTTPRequest *)request{
    //获取信息类型
    NSBubbleType type = self.dataInternal.data.type;
    /* 设定信息显示基准坐标
     X：若为接受的信息则为61（左侧），否则为 屏幕宽度-61-文字宽度-16（右侧）
     Y：若为时间标签则为35，否则为5
     */
    float x = (type == BubbleTypeSomeoneElse) ? 61 : self.frame.size.width - 61 - self.dataInternal.labelSize.width -16;
    float y = (self.dataInternal.header ? 35 : 5);
    
    [self cancelUpload];
    [self addResendTagX:x Y:y];
}

//重复发送信息提示
-(void)resendAlert:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"重发" message:@"是否重发消息？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

//重复发送信息的回调函数
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 2001:{
            break;
        }
            
        default:{
            if (buttonIndex == 1) {//确定
                //判断是否网络是否连接
                if([_sendDelegate respondsToSelector:@selector(isConnect)])
                    [_sendDelegate performSelector:@selector(isConnect)];
                //如果MQTT未连接、网络未连接并且未被踢
                //0x01：0未连接 1已连接
                //0x02：0正常 1被踢
                if(!myAccountUser.MQTTconnected || !(myAccountUser.netWorkStatus & 0x01) || (myAccountUser.netWorkStatus & 0x02)) {
                    return;
                }
                /* 重新发送数据
                 文字和音频：调用resendMsg函数发送数据
                 视频和图片：调用self的postMessage发送数据
                 */
                switch (self.dataInternal.data.dataType) {
                    case TYPE_TEXT:
                    case TYPE_VOICE:
                    case TYPE_LOC:
                    {
                        if([_sendDelegate respondsToSelector:@selector(resendMsg:)]) {
                            [_sendDelegate performSelector:@selector(resendMsg:) withObject:self.dataInternal.data.mid];
                        }
                    }
                        break;
                    case TYPE_VIDEO:
                    case TYPE_PIC:
                    {
                        [reupload removeFromSuperview];
                        reupload = nil;
                        [self addUploadProgress];
                        [self removeResendTag];
                        [self postMessage];
                        _request.delegate = self;
                        _request.uploadProgressDelegate = self;
                    }
                    default:
                        break;
                }
                //将mid设置为0
                self.dataInternal.data.mid = @"0";
                ChatMessage *msg = [[ChatListSaveProxy sharedChatListSaveProxy] getMessageWithText:self.dataInternal.data.text];
                msg.mid = self.dataInternal.data.mid;
                
                [self saveDataUpdate];
            }
            break;
        }
    }
    

}

//根据XY的值添加发送失败按钮（文字，语音，位置）
-(void)addResendTagX:(CGFloat)x Y:(CGFloat)y {
     NSLog(@"dataInternal.data.mid :%@", self.dataInternal.data.mid);

    //判断mid是否为空、“”和“0”
    if(self.dataInternal.data.mid != nil && ![self.dataInternal.data.mid isEqualToString: @""] &&  ![self.dataInternal.data.mid isEqualToString:@"0"]) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"chatto_notsend.png"] forState:UIControlStateNormal];
        btn.userInteractionEnabled = YES;
        btn.frame = CGRectMake(x-26, y+(self.dataInternal.labelSize.height - 20), 20, 20);
        [btn addTarget:self action:@selector(resendAlert:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 12;
        [self.contentView addSubview:btn];
    }else {
        //如果当前mid不为空、“”和“0”，则将已经存在的按钮删除
        //（mid有正常数据，则表明数据已经发送成功，因为此mid是从服务器端获取的，获取成功则表明数据已经发送成功）
        for (UIView *v in [self.contentView subviews]) {
            if(v.tag == 12){
                [v removeFromSuperview];
            }
        }
    }
}

- (void)addUnreadTag:(CGFloat)x andY:(CGFloat)y{
    UIImageView *unreadView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_UnreadTag_Green.png"]];
    unreadView.tag = 1001;
    [unreadView setFrame:CGRectMake(x, y, 10, 10)];
    [self.contentView addSubview:unreadView];
}

- (void)removeResendTag{
    //如果当前mid不为空、“”和“0”，则将已经存在的按钮删除
    //（mid有正常数据，则表明数据已经发送成功，因为此mid是从服务器端获取的，获取成功则表明数据已经发送成功）
    for (UIView *v in [self.contentView subviews]) {
        if(v.tag == 12){
            [v removeFromSuperview];
        }
    }
}

//根据XY的值添加发送失败按钮（文字，语音，位置）
-(void)addActivityIndicatorX:(CGFloat)x Y:(CGFloat)y {
    NSLog(@"dataInternal.data.mid :%@", self.dataInternal.data.mid);
    
    UIActivityIndicatorView *activityIndecator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndecator.frame = CGRectMake(x-26, y+(self.dataInternal.labelSize.height - 20), 20, 20);
//    UIButton *bn = [[UIButton alloc] initWithFrame:CGRectMake(x-26, y+(self.dataInternal.labelSize.height - 20), 20, 20)];
//    [bn setBackgroundColor:[UIColor blackColor]];
    
    [activityIndecator startAnimating];
    
    [self.contentView addSubview:activityIndecator];
//    [self addSubview:bn];
}

- (void)setDataInternal:(NSBubbleDataInternal *)value
{
	_dataInternal = value;
//	[self setupInternalData];
}

//处理需要显示的信息
- (void) setupInternalData
{
    //如果为聊天信息的时间标签，则显示标签内容（如 2013-7-31 下午4：20）
    if (self.dataInternal.header)
    {
        [self.contentView addSubview:headerLabel];
        headerLabel.hidden = NO;
        headerLabel.text = self.dataInternal.header;
    }
    else
    {
        headerLabel.hidden = YES;
    }
    
    //获取信息类型
    NSBubbleType type = self.dataInternal.data.type;
    
    /* 设定信息显示基准坐标
         X：若为接受的信息则为61（左侧），否则为 屏幕宽度-61-文字宽度-16（右侧）
         Y：若为时间标签则为35，否则为5
     */
    float x = (type == BubbleTypeSomeoneElse) ? 61 : self.frame.size.width - 61 - self.dataInternal.labelSize.width -16;
    float y = (self.dataInternal.header ? 35 : 5);
    
    /*  发送的信息处理
        文字信息：TYPE_TEXT
        图片信息：TYPE_PIC
        声音信息：TYPE_VOICE
        视频信息：TYPE_VIDEO
        位置信息：TYPE_LOC
     */
    switch (self.dataInternal.data.dataType) {
        case TYPE_TEXT:
        {
            //获取处理过表情信息的View（其中包括文字信息与表情图片）
            UIView *mixView;
            if (self.dataInternal.data.textView == nil) {
                mixView = [Utility getFaceView:self.dataInternal.data.text delegateView:viewController];
            }
            else{
                mixView = self.dataInternal.data.textView;
            }
            //设置位置
            if (type == BubbleTypeSomeoneElse) {
                mixView.frame = CGRectMake(x+10, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
            }else{
                mixView.frame = CGRectMake(x+6, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
                //添加发送失败的按钮
                [self addResendTagX:x Y:y];
            }
            [self.contentView addSubview:mixView];
            if (self.dataInternal.data.tag > 0) {
                self.dataInternal.data.tag = -2;
            }
            break;
        }
        case TYPE_PIC:
        {
            //设定位置
            if (type == BubbleTypeSomeoneElse) {
                contentButton.frame = CGRectMake(x+10, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
            }else{
                contentButton.frame = CGRectMake(x+6, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
                [self addResendTagX:x Y:y];
            }
            
            //初始化图片按钮
            UIImage *img = [UIImage imageWithData:self.dataInternal.data.data];
            contentButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [contentButton setImage:img forState:UIControlStateNormal];
            contentButton.imageView.layer.cornerRadius = 5;
            [contentButton addTarget:self action:@selector(showPic) forControlEvents:UIControlEventTouchUpInside];
            [contentButton setHidden:NO];
            [self.contentView addSubview:contentButton];
            
            //发送图片
            if (self.dataInternal.data.needToPost) {
                NSLog(@"first send...");
                if (self.dataInternal.data.requestIndex == -1) {
                    [self postMessage];
                }else{
//                    [self addReuploadButton];
                }
            }
            
            //判断是否需要添加上传进度条
            if (self.dataInternal.data.requestIndex >= 0) {
                _request = (ASIFormDataRequest *)[[RequestQueue sharedRequestQueue] getRequest:self.dataInternal.data.requestIndex];
                if (_request != nil) {
                    [self addUploadProgress];
                }
            }
            
            if (self.dataInternal.data.tag > 0) {
                self.dataInternal.data.tag = -2;
            }
            
            break;
        }
        case TYPE_VOICE:
        {
            //设定位置
            if (self.dataInternal.labelSize.width > 900) {
                self.dataInternal.labelSize = CGSizeMake(50 , self.dataInternal.labelSize.height);
            }
            if (type == BubbleTypeSomeoneElse) {
                contentButton.frame = CGRectMake(x+10, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
            }else{
                contentButton.frame = CGRectMake(x+6, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
                [self addResendTagX:x-25 Y:y+4];
            }
            [contentButton addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchDown];
            [contentButton setHidden:NO];
            [self.contentView addSubview:contentButton];
            
            //设置显示时间长度的Label和按钮上显示的图标
            UILabel *voiceLength = [[UILabel alloc] init];
            if (type == BubbleTypeSomeoneElse) {
                voiceLength.frame = CGRectMake(x+self.dataInternal.labelSize.width+15, y+20, 40, self.dataInternal.labelSize.height);
                voiceLength.textAlignment = NSTextAlignmentCenter;
                //添加按钮上的图标
                UIImage *voiceImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_voice_someone4" ofType:@"png"]];
                UIImageView *voiceIcon = [[UIImageView alloc] initWithImage:voiceImg];
                voiceIcon.frame = CGRectMake(contentButton.frame.origin.x, contentButton.frame.origin.y, 29, 30);
                voiceIcon.tag = 101;
                
                if (self.dataInternal.data.isNewMessage == YES) {
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayVoiceNotification:) name:NOTIFICATION_KEY_PLAYNEWVOICE object:nil];
                    [self addUnreadTag:voiceLength.frame.origin.x + 10 andY:voiceLength.frame.origin.y - 15];
                }
                
                [self.contentView addSubview:voiceIcon];
            }else{
                voiceLength.frame = CGRectMake(x-31, y+9, 30, self.dataInternal.labelSize.height);
                voiceLength.textAlignment = UITextAlignmentRight;
                //添加按钮上的图标
                UIImage *voiceImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_voice_mine4" ofType:@"png"]];
                UIImageView *voiceIcon = [[UIImageView alloc] initWithImage:voiceImg];
                voiceIcon.frame = CGRectMake(contentButton.frame.size.width-29+contentButton.frame.origin.x, contentButton.frame.origin.y, 29, 30);
                voiceIcon.tag = 101;
                [self.contentView addSubview:voiceIcon];
            }
            int len = self.dataInternal.data.length > 900 ? self.dataInternal.data.length / 1000 : self.dataInternal.data.length;
            if (len == 31 && type == BubbleTypeMine) {
                len = 30;
            }
            voiceLength.text = [NSString stringWithFormat:@"%d''",len <= 0 ? 1 : len];
            voiceLength.backgroundColor = [UIColor clearColor];
            voiceLength.textColor = [UIColor grayColor];
            voiceLength.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:voiceLength];
            break;
        }
        case TYPE_VIDEO:
        {
            //设定位置
            if (type == BubbleTypeSomeoneElse) {
                contentButton.frame = CGRectMake(x+10, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
            }else{
                contentButton.frame = CGRectMake(x+6, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
                [self addResendTagX:x Y:y];
            }
            
            //获取视频的第一画面图片
            UIImage *firstFrame = [UIImage imageWithData:self.dataInternal.data.data];
            [contentButton setImage:firstFrame forState:UIControlStateNormal];
            contentButton.imageView.layer.cornerRadius = 5;
            [contentButton addTarget:self action:@selector(playMovie) forControlEvents:UIControlEventTouchUpInside];
            [contentButton setHidden:NO];
            [self.contentView addSubview:contentButton];
            //添加黑底图片
            UIImageView *blackView = [[UIImageView alloc] init];
            blackView.frame = CGRectMake(0, contentButton.frame.size.height-20, contentButton.frame.size.width, 20);
            blackView.backgroundColor = [UIColor blackColor];
            blackView.alpha = 0.5;
            [contentButton.imageView addSubview:blackView];
            //添加播放图标图片
            UIImageView *playView = [[UIImageView alloc] init];
            playView.frame = CGRectMake(contentButton.frame.size.width/2-20, contentButton.frame.size.height/2-20, 40, 40);
//            playView.backgroundColor = [UIColor blackColor];
            UIImage *playImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_video_play" ofType:@"png"]];
            playView.image = playImg;
//            playView.alpha = 0.5;
            [contentButton.imageView addSubview:playView];
            
            //添加影片时长的label
            UILabel *movieLength = [[UILabel alloc] init];
            movieLength.frame = CGRectMake(contentButton.frame.size.width/2, blackView.frame.origin.y, contentButton.frame.size.width/2-3, blackView.frame.size.height);
            movieLength.backgroundColor = [UIColor clearColor];
            movieLength.textColor = [UIColor whiteColor];
            movieLength.alpha = 0.5;
            int length =  self.dataInternal.data.length;
            NSString *lengthStr;
            if (length/60>=10) {
                lengthStr = [NSString stringWithFormat:@"%d",length/60];
            }else{
                lengthStr = [NSString stringWithFormat:@"0%d",length/60];
            }
            if (length%60>=10) {
                if (length%60 == 16 && type == BubbleTypeMine) {
                    lengthStr = [lengthStr stringByAppendingFormat:@":15"];
                }
                else{
                    lengthStr = [lengthStr stringByAppendingFormat:@":%d",length%60];
                }
            }else{
                lengthStr = [lengthStr stringByAppendingFormat:@":0%d",length%60];
            }
            movieLength.text = lengthStr;
            movieLength.font = [UIFont systemFontOfSize:10];
            movieLength.textAlignment = UITextAlignmentRight;
            [contentButton.imageView addSubview:movieLength];
            
            //上传视频
            if (self.dataInternal.data.needToPost) {
                if (self.dataInternal.data.requestIndex == -1) {
                    [self postMessage];
                }else{
//                    [self addReuploadButton];
                }
            }
            if (self.dataInternal.data.requestIndex >= 0) {
                _request = (ASIFormDataRequest *)[[RequestQueue sharedRequestQueue] getRequest:self.dataInternal.data.requestIndex];
                if (_request != nil) {
                    [self addUploadProgress];
                }
            }
            if (self.dataInternal.data.tag > 0) {
                self.dataInternal.data.tag = -2;
            }
            break;
        }
        case TYPE_LOC:
        {
            //设置位置
            if (type == BubbleTypeSomeoneElse) {
                contentButton.frame = CGRectMake(x+10, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
            }else{
                contentButton.frame = CGRectMake(x+6, y+10, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
                [self addResendTagX:x Y:y];
            }
            [contentButton setHidden:NO];
            //获取位置图片
            UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"map_located" ofType:@"png"]];
            [contentButton setImage:img forState:UIControlStateNormal];
            contentButton.imageView.layer.cornerRadius = 5;
            [contentButton addTarget:self action:@selector(reLocate) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:contentButton];
            //添加地址信息label
            [contentLabel setHidden:NO];
            if (type == BubbleTypeSomeoneElse) {
                contentLabel.frame = CGRectMake(x+10, y+72, 95, 33);
            }else{
                contentLabel.frame = CGRectMake(x+11, y+71, 95, 33);
            }
            contentLabel.numberOfLines = 2;
            contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
            contentLabel.font = [UIFont systemFontOfSize:10];
            contentLabel.textColor = [UIColor whiteColor];
            NSDictionary *dic = [self.dataInternal.data.text objectFromJSONString];
            contentLabel.text = [dic objectForKey:LOC_DISCRIPTION];
            [self.contentView addSubview:contentLabel];
            if (self.dataInternal.data.tag > 0) {
                self.dataInternal.data.tag = -2;
            }
            break;
        }
        default:
            break;
    }
    
    /*设定发送信息的背景
        本人发送信息就用SenderBubble.png做为背景
        收到别人发送的信息就用ReceiverBubble.png做为背景
     */
    if (type == BubbleTypeSomeoneElse)
    {
        if (_someOne == nil) {
            _someOne = [[UIImageView alloc] init];
        }
        _someOne.frame = CGRectMake(10, y+5, 41, 41);
        [self.contentView addSubview:_someOne];

        bubbleImage.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ReceiverBubble" ofType:@"png"]] stretchableImageWithLeftCapWidth:30 topCapHeight:35];
        bubbleImage.frame = CGRectMake(x , y+5 , self.dataInternal.labelSize.width+16, self.dataInternal.labelSize.height+11);
//        NSLog(@"bubble image:%f,%f",bubbleImage.frame.size.width,bubbleImage.frame.size.height);
//        bubbleImage.backgroundColor = [UIColor greenColor];
    }
    else {
        if (_mine == nil) {
            _mine = [[UIImageView alloc] init];
        }
        _mine.frame = CGRectMake(self.frame.size.width-51, y+5, 41, 41);
        [self.contentView addSubview:_mine];
        
        bubbleImage.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SenderBubble" ofType:@"png"]] stretchableImageWithLeftCapWidth:30 topCapHeight:35];
        bubbleImage.frame = CGRectMake(x , y+5 , self.dataInternal.labelSize.width+16, self.dataInternal.labelSize.height+11);
    }
}

#pragma mark - PictureShower
//跳转页面显示照片
- (void)showPic
{
////    PicViewController *pic = [[PicViewController alloc] init];
//    PicViewController *pic = [[PicViewController alloc] initWithURL:[NSURL URLWithString:self.dataInternal.data.urlString] andSavePath:self.dataInternal.data.text];
//    [[NSNotificationCenter defaultCenter] postNotificationName:PUSHVIEW object:pic];
    
    NSArray *messages = [[ChatListSaveProxy sharedChatListSaveProxy] getAllPICMessages:[[[ChatListSaveProxy sharedChatListSaveProxy] getMessageWithText:self.dataInternal.data.text] master]];
    
    // Browser
	NSMutableArray *photos = [[NSMutableArray alloc] init];
    int initialPageIndex = 0;
    int index = 0;
    MWPhoto *photo;
    for (ChatMessage *message in messages) {
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:message.text];
        if (exist) {
            photo = [MWPhoto photoWithFilePath:message.text];
            [photos addObject:photo];
        }else{
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:message.urlString]]];
        }
        // 获取起始页面的下标
        if ([self.dataInternal.data.text isEqualToString:message.text]) {
            initialPageIndex = index;
        }
        else{
            index++;
        }
    }
    
    picLibrary = photos;
	
	// Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    // 设定起始页面的下标
    [browser setInitialPageIndex:initialPageIndex];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:browser];
    [viewController presentModalViewController:nav animated:YES];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:PUSHVIEW object:browser];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return picLibrary.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < picLibrary.count)
        return [picLibrary objectAtIndex:index];
    return nil;
}

#pragma mark - VoicePlayer

//播放声音
- (void)playVoice
{
    NSLog(@"playVoice... %d:%@", self.dataInternal.data.tag, self);
    NSLog(@"voice length:%d",self.dataInternal.data.data.length);
    if (self.dataInternal.data.data.length == 0) {
        return;
    }
    
    //若正在播放，再次点击则停止播放
    if (AudioPlayer != nil && [AudioPlayer isPlaying]) {
        //处理当前正在播放音频的情况
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_STOPVOICE object:nil];
        NSLog(@"AudioPlayer stop");
        return;
    }
    
//    //处理当前正在播放音频的情况
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_STOPVOICE object:nil];
    
    NSError *error;
    //播放声音
    AudioPlayer = [[AVAudioPlayer alloc] initWithData:DecodeAMRToWAVE(self.dataInternal.data.data) error:&error];
    AudioPlayer.delegate = self;
    [AudioPlayer prepareToPlay];
    [AudioPlayer play];
//    NSLog(@"UIBubbleTableViewCell self.tag:%d", self.tag);
    //将记录置为已播放音频
    if (self.dataInternal.data.isNewMessage == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_PLAYNEWVOICE object:nil];
//        NSLog(@"UIBubbleTableViewCell AutoPlayVoice Tag:%d", self.dataInternal.data.tag);
        self.dataInternal.data.isNewMessage = NO;
        [self changeToDidRead];
    }
    
    //利用timer显示声音图像动画
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(handleVoiceAnimation) userInfo:nil repeats:YES];
    _voicePicTag = 1;
}

//播放声音
- (void)handlePlayVoiceNotification:(NSNotification *)notification{
    NSString *strVoiceTag = (NSString *)notification.object;
    NSInteger voiceTag = [strVoiceTag intValue];
    NSLog(@"getNotification dataInternaltag:%d, datatag:%d self:%@", self.dataInternal.tag, self.dataInternal.data.tag, self);
    if(voiceTag == self.dataInternal.data.tag &&
       voiceTag == self.dataInternal.tag){
        [self playVoice];
        return;
    }
}

//停止播放声音
- (void)stopVoice
{
    if (AudioPlayer != nil) {
        NSLog(@"UIBubbleTableViewCell stopVoice self.dataInternal.tag:%d", self.dataInternal.data.tag);
        [AudioPlayer stop];
        [_timer invalidate];
        AudioPlayer = nil;
        NSString *fileName;
        if (self.dataInternal.data.type == BubbleTypeSomeoneElse) {
            fileName = [NSString stringWithFormat:@"chat_voice_someone4"];
        }else{
            fileName = [NSString stringWithFormat:@"chat_voice_mine4"];
        }
        UIImage *voicePic = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"png"]];
        UIImageView *imgView = (UIImageView *)[self viewWithTag:101];
        imgView.image = voicePic;
        //手动停止播放音频时删除自动播放Dic中的信息
        if (self.dataInternal.data.tag > 0) {
            NSString *selfTag = [[NSString alloc] initWithFormat:@"%d", - self.dataInternal.data.tag];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_PLAYEDVOICE object:selfTag];
            self.dataInternal.data.tag = -1;
        }
    }
}

//声音图像动画
- (void)handleVoiceAnimation
{
    //获取声音图片动画文件名称
    NSString *fileName;
    if (self.dataInternal.data.type == BubbleTypeSomeoneElse) {
        fileName = [NSString stringWithFormat:@"chat_voice_someone%d",_voicePicTag];
    }else{
        fileName = [NSString stringWithFormat:@"chat_voice_mine%d",_voicePicTag];
    }
    //获取声音图片
    UIImage *voicePic = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"png"]];
    UIImageView *imgView = (UIImageView *)[self viewWithTag:101];
    imgView.image = voicePic;

    if (_voicePicTag == 4) {
        _voicePicTag = 1;
    }else{
        _voicePicTag++;
    }
}

//音频播放完成后调用的回调函数
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying.....###");
    AudioPlayer = nil;
    [_timer invalidate];
    NSString *fileName;
    if (self.dataInternal.data.type == BubbleTypeSomeoneElse) {
        fileName = [NSString stringWithFormat:@"chat_voice_someone4"];
    }else{
        fileName = [NSString stringWithFormat:@"chat_voice_mine4"];
    }
    UIImage *voicePic = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"png"]];
    UIImageView *imgView = (UIImageView *)[self viewWithTag:101];
    imgView.image = voicePic;
    
    
    NSString *selfTag = [[NSString alloc] initWithFormat:@"%d", self.dataInternal.data.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_PLAYEDVOICE object:selfTag];
    self.dataInternal.data.tag = -1;
}

- (void)checkSelf{
    if ([AudioPlayer isPlaying]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(handleVoiceAnimation) userInfo:nil repeats:YES];
    }
}

#pragma mark - MoviePlayer
//播放视频
- (void)playMovie
{
    //处理当前正在播放音频的情况
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_STOPVOICE object:nil];
    
    NSLog(@"playMovie...");
    NSString *filePath = self.dataInternal.data.text;
    NSURL *url;
//    NSLog(@"aaaaa%d",self.dataInternal.data.type);
    //判断播放他人或自己的视频
    if (self.dataInternal.data.type == BubbleTypeMine) {
        NSLog(@"%@ : my filePath:%@", NSStringFromSelector(_cmd),filePath);
        //获取文件路径
        url = [NSURL fileURLWithPath:filePath];
        [[VideoPlayer getSingleton] playVideoWithURL:filePath withType:@"localVideo" view:self.viewController];
//        MovieViewController *movie = [[MovieViewController alloc] initWithURL:url];
//        [[NSNotificationCenter defaultCenter] postNotificationName:PUSHVIEW object:movie];
    }else{
        NSLog(@"%@ : my filePath:%@", NSStringFromSelector(_cmd),filePath);
        NSLog(@"%@ : my urlPath:%@", NSStringFromSelector(_cmd),self.dataInternal.data.urlString);
        //获取文件路径
        url = [NSURL URLWithString:self.dataInternal.data.urlString];
        [[VideoPlayer getSingleton] playVideoWithURL:self.dataInternal.data.urlString withType:@"urlVideo" view:self.viewController];
//        MovieViewController *movie = [[MovieViewController alloc] initWithURL:url andSavePath:self.dataInternal.data.text];
//        [[NSNotificationCenter defaultCenter] postNotificationName:PUSHVIEW object:movie];
    }
    
    
//    [movie release];
    
//    MPMoviePlayerController *theMovie = [[MPMoviePlayerController alloc] initWithContentURL:url];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerDidExitFullscreenNotification object:theMovie];
//    [theMovie prepareToPlay];
//    [self addSubview:theMovie.view];
//    
//    [theMovie setFullscreen:YES];
//    theMovie.shouldAutoplay = YES;
//    [theMovie.view setFrame:CGRectMake(0, 0, 320, 480)];
//    [theMovie play];
}

//视频播放完毕后的回调函数
- (void)myMovieFinishedCallback:(NSNotification *)aNotification
{
    NSLog(@"movie finished...");
    MPMoviePlayerController *theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:theMovie];
    [theMovie.view removeFromSuperview];
}
#pragma mark - 将记录置为已读
- (void)changeToDidRead{
    switch (self.dataInternal.data.dataType) {
        case TYPE_VOICE:{
            for (UIView *voiceSubView in self.contentView.subviews) {
                if (voiceSubView.tag == 1001) {
                    [voiceSubView setHidden:YES];
                    [self saveDataUpdate];
                }
            }
            break;
        }
        default:{
            NSLog(@"UIBubbleTableViewCell 已读信息设置错误");
            break;
        }
    }
}

#pragma mark - ChatMessageDataControl

- (void)saveDataUpdate{
    ChatMessage *msg = [[ChatListSaveProxy sharedChatListSaveProxy] getMessageByText:self.dataInternal.data.text andDate:self.dataInternal.data.date];
    msg.date = self.dataInternal.data.date;
    msg.type = [NSNumber numberWithInt:self.dataInternal.data.type];
    msg.text = self.dataInternal.data.text;
    msg.dataType = [NSNumber numberWithInt:self.dataInternal.data.dataType];
    msg.data = self.dataInternal.data.data;
    msg.urlString = self.dataInternal.data.urlString;
    msg.length = [NSNumber numberWithInt:self.dataInternal.data.length];
    msg.needToPost = self.dataInternal.data.needToPost;
    msg.msgToPost = self.dataInternal.data.msgToPost;
    msg.requestIndex = [NSNumber numberWithInt:self.dataInternal.data.requestIndex];
    msg.mid = self.dataInternal.data.mid;
    msg.isNewMessage = self.dataInternal.data.isNewMessage;
    
    [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
}

#pragma mark -
- (void)reLocate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_STOPVOICE object:nil];
    NSLog(@"reLocate...");
    NSDictionary *dic = [self.dataInternal.data.text objectFromJSONString];
    ReLocateViewController *reLocate = [[ReLocateViewController alloc] initWithDictionary:dic];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PUSHVIEW object:reLocate];
}

@end
