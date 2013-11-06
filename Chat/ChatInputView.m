//
//  ChatInputView.m
//  Chat
//
//  Created by Archer on 13-1-19.
//  Copyright (c) 2013年 Archer. All rights reserved.
//

#import "ChatInputView.h"
#import "amrFileCodec.h"
#import "Header.h"
#import "DAKeyboardControl.h"

@implementation ChatInputView

@synthesize delegate = _delegate;
@synthesize normalInput = _normalInput;
@synthesize extraInput = _extraInput;
@synthesize textToSend = _textToSend;
@synthesize voiceChatButton = _voiceChatButton;
@synthesize extraButton = _extraButton;
@synthesize isKeyBoardShow;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        self.frame = CGRectMake(0, screenSize.height-109, 320, 265);
        self.backgroundColor = [UIColor clearColor];
        
        //文字输入框
        _normalInput = [[UIView alloc] init];
        _normalInput.frame = CGRectMake(0, 0, 320, 45);
        _normalInput.backgroundColor = [UIColor clearColor];
        [self addSubview:_normalInput];
        
        NSString *normalInputBgPath = [[NSBundle mainBundle] pathForResource:@"chat_input_bg" ofType:@"png"];
        UIImage *normalInputBgImg = [[UIImage imageWithContentsOfFile:normalInputBgPath] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 31)];
        UIImageView *normalInputBgView = [[UIImageView alloc] initWithImage:normalInputBgImg];
        normalInputBgView.tag = 101;
        normalInputBgView.frame = CGRectMake(0, 0, 320, 45);
        [_normalInput addSubview:normalInputBgView];
        
        _extraInput = [[UIView alloc] init];
        _extraInput.frame = CGRectMake(0, 45, 320, 220);
        _extraInput.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
        [self addSubview:_extraInput];
        
        _voiceChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _voiceChatButton.backgroundColor = [UIColor redColor];
        _voiceChatButton.frame = CGRectMake(4, 9, 26, 26);
        UIImage *voiceChatImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_input_voice" ofType:@"png"]];
        [_voiceChatButton setImage:voiceChatImg forState:UIControlStateNormal];
        [_voiceChatButton addTarget:self action:@selector(switchTextOrVoice) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_voiceChatButton];
        
        _extraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _extraButton.backgroundColor = [UIColor redColor];
        _extraButton.frame = CGRectMake(35, 9, 26, 26);
        UIImage *extraImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_input_extra" ofType:@"png"]];
        [_extraButton setImage:extraImg forState:UIControlStateNormal];
        [_extraButton addTarget:self action:@selector(showExtraInput) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_extraButton];
        
        _textToSend = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(65, 5, 190 + 50 + 5, 45)];
        _textToSend.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _textToSend.layer.cornerRadius = 5;
        _textToSend.backgroundColor = [UIColor yellowColor];
        _textToSend.minNumberOfLines = 1;
        _textToSend.maxNumberOfLines = 3;
        
        _textToSend.returnKeyType = UIReturnKeySend; //just as an example
        _textToSend.font = [UIFont systemFontOfSize:15.0f];
        _textToSend.delegate = self;
        _textToSend.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        _textToSend.backgroundColor = [UIColor whiteColor];
        [_normalInput addSubview:_textToSend];
        
        _pressToSpeak = [UIButton buttonWithType:UIButtonTypeCustom];
        _pressToSpeak.frame = CGRectMake(65, 5, 190 + 50 + 5, 35);
        _pressToSpeak.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        _pressToSpeak.layer.cornerRadius = 5;
        [_pressToSpeak setTitle:@"按住说话" forState:UIControlStateNormal];
        [_pressToSpeak setTitleColor:[UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1] forState:UIControlStateNormal];
        [_pressToSpeak setHidden:YES];
        [_pressToSpeak addTarget:self action:@selector(recordBegin) forControlEvents:UIControlEventTouchDown];
        [_pressToSpeak addTarget:self action:@selector(dropRecord:) forControlEvents:UIControlEventTouchUpOutside];
        [_pressToSpeak addTarget:self action:@selector(moveOut:) forControlEvents:UIControlEventTouchDragExit];
        [_pressToSpeak addTarget:self action:@selector(moveIn:) forControlEvents:UIControlEventTouchDragEnter];
//        [_pressToSpeak addTarget:self action:@selector(dragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [_normalInput addSubview:_pressToSpeak];
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        _sendButton.titleLabel.textColor = [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1];
        _sendButton.layer.cornerRadius = 5;
        _sendButton.frame = CGRectMake(260, 5, 50, 35);
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor colorWithRed:87/255.0 green:87/255.0 blue:87/255.0 alpha:1] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton setHidden:YES];
//        [self addSubview:_sendButton];
        
        isKeyBoardShow = false;
        
        //表情键
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.frame = CGRectMake(20, 20, 55, 55);
        faceButton.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
        UIImage *faceImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_face_icon" ofType:@"png"]];
        [faceButton setImage:faceImg forState:UIControlStateNormal];
        [faceButton addTarget:self action:@selector(handleExtraInput:) forControlEvents:UIControlEventTouchUpInside];
        faceButton.tag = 1;
        [_extraInput addSubview:faceButton];
        
        UILabel *faceLabel = [[UILabel alloc] init];
        faceLabel.frame = CGRectMake(20, 75, 55, 30);
        faceLabel.backgroundColor = [UIColor clearColor];
        faceLabel.text = @"表情";
        faceLabel.font = [UIFont systemFontOfSize:14];
        faceLabel.textAlignment = NSTextAlignmentCenter;
        faceLabel.textColor = [UIColor grayColor];
        [_extraInput addSubview:faceLabel];
        
        //图片键
        UIButton *picButton = [UIButton buttonWithType:UIButtonTypeCustom];
        picButton.frame = CGRectMake(95, 20, 55, 55);
        picButton.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
        UIImage *picImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_photo_icon" ofType:@"png"]];
        [picButton setImage:picImg forState:UIControlStateNormal];
        [picButton addTarget:self action:@selector(handleExtraInput:) forControlEvents:UIControlEventTouchUpInside];
        picButton.tag = 2;
        [_extraInput addSubview:picButton];
        
        UILabel *picLabel = [[UILabel alloc] init];
        picLabel.frame = CGRectMake(95, 75, 55, 30);
        picLabel.backgroundColor = [UIColor clearColor];
        picLabel.text = @"照片";
        picLabel.font = [UIFont systemFontOfSize:14];
        picLabel.textAlignment = NSTextAlignmentCenter;
        picLabel.textColor = [UIColor grayColor];
        [_extraInput addSubview:picLabel];
        
        //相机键
        UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        photoButton.frame = CGRectMake(170, 20, 55, 55);
        photoButton.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
        UIImage *photoImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_camera_icon" ofType:@"png"]];
        [photoButton setImage:photoImg forState:UIControlStateNormal];
        [photoButton addTarget:self action:@selector(handleExtraInput:) forControlEvents:UIControlEventTouchUpInside];
        photoButton.tag = 3;
        [_extraInput addSubview:photoButton];
        
        UILabel *photoLabel = [[UILabel alloc] init];
        photoLabel.frame = CGRectMake(170, 75, 55, 30);
        photoLabel.backgroundColor = [UIColor clearColor];
        photoLabel.text = @"拍摄";
        photoLabel.font = [UIFont systemFontOfSize:14];
        photoLabel.textAlignment = NSTextAlignmentCenter;
        photoLabel.textColor = [UIColor grayColor];
        [_extraInput addSubview:photoLabel];
        
        //位置键
        UIButton *locButton = [UIButton buttonWithType:UIButtonTypeCustom];
        locButton.frame = CGRectMake(245, 20, 55, 55);
        locButton.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
        UIImage *locImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_locate_icon" ofType:@"png"]];
        [locButton setImage:locImg forState:UIControlStateNormal];
        [locButton addTarget:self action:@selector(handleExtraInput:) forControlEvents:UIControlEventTouchUpInside];
        locButton.tag = 4;
        [_extraInput addSubview:locButton];
        
        UILabel *locLabel = [[UILabel alloc] init];
        locLabel.frame = CGRectMake(245, 75, 55, 30);
        locLabel.backgroundColor = [UIColor clearColor];
        locLabel.text = @"位置";
        locLabel.font = [UIFont systemFontOfSize:14];
        locLabel.textAlignment = NSTextAlignmentCenter;
        locLabel.textColor = [UIColor grayColor];
        [_extraInput addSubview:locLabel];
        
        //名片键
//        UIButton *nameCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        nameCardButton.frame = CGRectMake(20, 110, 55, 55);
//        nameCardButton.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
//        [nameCardButton setTitle:@"名片" forState:UIControlStateNormal];
//        [nameCardButton addTarget:self action:@selector(handleExtraInput:) forControlEvents:UIControlEventTouchUpInside];
//        nameCardButton.tag = 5;
//        [_extraInput addSubview:nameCardButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide) name:UIKeyboardDidHideNotification object:nil];
        
        [self setRecording:NO];
        
        //录音view
        volumeView = [[UIView alloc] initWithFrame:CGRectMake(60, -(screenSize.height - 190), screenSize.width, screenSize.height - 190)];
        volumeView.backgroundColor = [UIColor clearColor];
        [volumeView setHidden:YES];
        [self addSubview:volumeView];
        
        UIImageView *volumeViewBg = [[UIImageView alloc] init];
        volumeViewBg.frame = CGRectMake(0, 0, 200, 200);
        volumeViewBg.backgroundColor = [UIColor blackColor];
        volumeViewBg.alpha = 0.5;
        volumeViewBg.layer.cornerRadius = 10;
        [volumeView addSubview:volumeViewBg];
        
        phone = [[UIImageView alloc] init];
        phone.frame = CGRectMake(50, 21, 58, 157);
        NSString *phonePath = [[NSBundle mainBundle] pathForResource:@"voice_rcd_hint" ofType:@"png"];
        UIImage *phoneImage = [UIImage imageWithContentsOfFile:phonePath];
        [phone setImage:phoneImage];
        [volumeView addSubview:phone];
        
        volume = [[UIImageView alloc] init];
        NSString *volumePath = [[NSBundle mainBundle] pathForResource:@"amp1" ofType:@"png"];
        UIImage *volumeImage = [UIImage imageWithContentsOfFile:volumePath];
        [volume setImage:volumeImage];
        volume.frame = CGRectMake(108, 21+157-volumeImage.size.height, volumeImage.size.width, volumeImage.size.height);
        [volumeView addSubview:volume];
        
        //丢弃录音
        dropLabel = [[UILabel alloc] init];
        dropLabel.frame = CGRectMake(0, 160, 200, 40);
        dropLabel.text = @"松开手指，放弃语音";
        dropLabel.backgroundColor = [UIColor clearColor];
        dropLabel.textColor = [UIColor whiteColor];
        dropLabel.textAlignment = NSTextAlignmentCenter;
        [dropLabel setHidden:YES];
        [volumeView addSubview:dropLabel];
        
        //录音时间
        voiceTimeLabel = [[UILabel alloc] init];
        voiceTimeLabel.frame = CGRectMake(132, 0, 60, 60);
        voiceTimeLabel.text = @"0秒";
        voiceTimeLabel.font = [UIFont boldSystemFontOfSize:17];
        voiceTimeLabel.backgroundColor = [UIColor clearColor];
        voiceTimeLabel.textColor = [UIColor whiteColor];
        voiceTimeLabel.textAlignment = NSTextAlignmentRight;
        [volumeView addSubview:voiceTimeLabel];
        
        UIImage *dropImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_voice_drop" ofType:@"png"]];
        dropImgView = [[UIImageView alloc] init];
        dropImgView.image = dropImg;
        dropImgView.frame = CGRectMake(43, 37, 114, 126);
        [dropImgView setHidden:YES];
        [volumeView addSubview:dropImgView];
        
        //添加表情键盘
        _faceBoard = [[FaceBoard alloc] init];
        _faceBoard.inputTextView = (UITextView *)_textToSend;
        _faceBoard.delegate = self;
        [_faceBoard setHidden:YES];
        [_extraInput addSubview:_faceBoard];
        
//        dropVoice = [UIButton buttonWithType:UIButtonTypeCustom];
//        dropVoice.frame = CGRectMake(160, -250, 100, 100);
//        NSString *dropVoicePath = [[NSBundle mainBundle] pathForResource:@"voice_rcd_cancel_bg" ofType:@"png"];
//        UIImage *dropVoiceImage = [UIImage imageWithContentsOfFile:dropVoicePath];
//        [dropVoice setImage:dropVoiceImage forState:UIControlStateNormal];
//        
//        dropVoice.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 50, 0);
//        dropVoice.titleEdgeInsets = UIEdgeInsetsMake(50, 0, 0, 0);
//        [dropVoice setTitle:@"移到这里取消" forState:UIControlStateNormal];
////        [dropVoice bringSubviewToFront:dropVoice.titleLabel];
//        dropVoice.titleLabel.font = [UIFont systemFontOfSize:16];
//        dropVoice.titleLabel.textColor = [UIColor whiteColor];
//        [dropVoice setHidden:YES];
//        [self addSubview:dropVoice];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendText) name:NOTIFICATION_KEY_SEND_TEXT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopChatPrepare) name:NOTIFICATION_KEY_STOPCHAT object:nil];
        
        }
    return self;
}

- (void)dealloc
{
    NSLog(@"ChatInputView dealloc");
//    [super dealloc];
//    [_normalInput release];
    _normalInput = nil;
//    [_extraInput release];
    _extraInput = nil;
//    [volumeView release];
    volumeView = nil;
//    [_textToSend release];
    _textToSend = nil;
//    [volumeView release];
    volumeView = nil;
//    [phone release];
    phone = nil;
//    [volume release];
    volume = nil;
//    [dropVoice release];
//    dropVoice = nil;
    _faceBoard = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_SEND_TEXT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_KEY_STOPCHAT object:nil];
}

- (void)keyBoardShow
{
    isKeyBoardShow = true;
    [self.delegate showExtra:NO];
}

- (void)keyBoardHide
{
    isKeyBoardShow = false;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//切换语音输入和文字输入
- (void)switchTextOrVoice
{
    NSLog(@"switchTextOrVoice...");
    if (_pressToSpeak.isHidden) {
        UIImage *voiceChatImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_input_text" ofType:@"png"]];
        [_voiceChatButton setImage:voiceChatImg forState:UIControlStateNormal];
        [_sendButton setHidden:YES];
        _textToSend.maxNumberOfLines = 1;
        _textToSend.text = _textToSend.text;
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        if (isKeyBoardShow) {
            [_textToSend resignFirstResponder];
        }else{
            CGFloat bubbleHeight = screenSize.height - 109-(_normalInput.frame.size.height-45);
            [self.delegate changeBubbleView:bubbleHeight];
        }
        [_pressToSpeak setHidden:NO];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        CGRect frame = self.frame;
        frame.origin.y = screenSize.height - 109-(self.normalInput.frame.size.height-45);
        self.frame = frame;
        [UIView commitAnimations];
    }else{
        //[_sendButton setHidden:NO];//不显示发送按钮，改在输入的键盘中显示发送按钮
        UIImage *voiceChatImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_input_voice" ofType:@"png"]];
        [_voiceChatButton setImage:voiceChatImg forState:UIControlStateNormal];
        [_sendButton setHidden:YES];
        _textToSend.maxNumberOfLines = 3;
        _textToSend.text = _textToSend.text;
        [_textToSend becomeFirstResponder];
        [_pressToSpeak setHidden:YES];
    }
}

- (void)showExtraInput
{
    [_pressToSpeak setHidden:YES];
    [_faceBoard setHidden:YES];
    UIImage *voiceChatImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chat_input_voice" ofType:@"png"]];
    [_voiceChatButton setImage:voiceChatImg forState:UIControlStateNormal];
    [_sendButton setHidden:YES];
    _textToSend.maxNumberOfLines = 3;
    _textToSend.text = _textToSend.text;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (self.frame.origin.y != (screenSize.height - 109-(self.normalInput.frame.size.height-45))) {
        //不在最下面的情况
        if (isKeyBoardShow) {
            [self.delegate showExtra:true];
            [_textToSend resignFirstResponder];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3f];
            CGRect frame = self.frame;
            frame.origin.y = screenSize.height - 325-(self.normalInput.frame.size.height-45);
            self.frame = frame;
            [self.delegate changeBubbleView:frame.origin.y];
            [UIView commitAnimations];
            [self.delegate showExtra:NO];
        }else{
            [self.delegate showExtra:NO];
            [_textToSend becomeFirstResponder];
        }
        
    }else{
        [self.delegate showExtra:NO];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        CGRect frame = self.frame;
        frame.origin.y = screenSize.height - 325-(self.normalInput.frame.size.height-45);
        self.frame = frame;
        [self.delegate changeBubbleView:frame.origin.y];
        [UIView commitAnimations];
        
    }
}

- (void)sendText
{
    NSLog(@"sendText...");
    
    if ((_textToSend.text == nil) ||
        [_textToSend.text isEqualToString: @""] ||
        [[_textToSend.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <= 0) {
        NSLog(@"sendText.Length: %d", [_textToSend.text length]);
        [self alertString:@"发送文本不得为空文本"];
        [_textToSend setText:@""];
        return;
    }
    else if ([[_textToSend.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]] length] >= 1000){
        NSLog(@"sendText.Length: %d", [_textToSend.text length]);
        [self alertString:@"发送文本超出最大长度(1000字以内)"];
        return;
    }
    
    [self.delegate sendText:_textToSend.text];

    _textToSend.text = nil;
}

- (void)handleExtraInput:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"extra input:%d",btn.tag);
    if (btn.tag == 1) {
        [_faceBoard setHidden:NO];
    }else if (btn.tag == 2) {
        ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        ipc.mediaTypes = [NSArray arrayWithObjects:@"public.image",@"public.movie", nil];
        [self.delegate presentViewController:ipc animated:YES completion:nil];
    }else if (btn.tag == 3) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该设备不支持此功能" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        [self clearVideo];
        
        ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        ipc.videoQuality = UIImagePickerControllerQualityTypeMedium;
        ipc.videoMaximumDuration = 16.0f;   //最大拍摄时间
        ipc.mediaTypes = [NSArray arrayWithObjects:@"public.movie",@"public.image", nil];
        [self.delegate presentViewController:ipc animated:YES completion:nil];

    }else if (btn.tag == 4){
        //tag为4，位置信息
        LocationViewController *loc = [[LocationViewController alloc] init];
        loc.delegate = self;
        [self.delegate.navigationController pushViewController:loc animated:YES];
//        [loc release];
    }
}

//- (void)test
//{
//    NSLog(@"sendPic...");
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
//    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//    [self.delegate sendData:data withType:TYPE_PIC];
////    [data release];
//}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
    
    CGRect s = _normalInput.frame;
    s.size.height -= diff;
    r.origin.y += diff;
    _normalInput.frame = s;
    
    UIView *subView = [_normalInput viewWithTag:101];
    subView.frame = _normalInput.frame;
    
    CGRect r1 = _voiceChatButton.frame;
    r1.origin.y -= diff;
    _voiceChatButton.frame = r1;
    
    CGRect r2 = _extraButton.frame;
    r2.origin.y -= diff;
    _extraButton.frame = r2;
    
    CGRect r3 = _sendButton.frame;
    r3.origin.y -= diff;
    _sendButton.frame = r3;
    
    CGRect r4 = _extraInput.frame;
    r4.origin.y -= diff;
    _extraInput.frame = r4;
    
    CGRect r5 = _pressToSpeak.frame;
    r5.origin.y -= diff;
    _pressToSpeak.frame = r5;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [self sendText];
    
    return true;
}

//UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    NSArray *arr = [info allKeys];
//    for (NSString *key in arr) {
//        NSLog(@"%@",key);
//    }
    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];
    if ([mediaType isEqualToString:@"public.image"]) {
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
        
        //选取图片
        UIImage *imageOri = [info objectForKey:UIImagePickerControllerEditedImage];
        
        //判断是否写入相册，如果是拍摄则写入，选取则不写入
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(imageOri, self, nil, nil);
        }
        
//        //旋转图片方向，使之回归正常
//        UIImage *image = nil;
////        UIImageOrientation ori = imageOri.imageOrientation;
//        if (imageOri.imageOrientation == UIImageOrientationLeft || imageOri.imageOrientation == UIImageOrientationRight || imageOri.imageOrientation == UIImageOrientationDown) {
//            image = [Utility rotateImage:imageOri];
//        }else{
//            image = imageOri;
//        }
        
        //降低图片的质量和大小
//        NSData *data = UIImageJPEGRepresentation(image, 0.1);
        NSData *data = UIImageJPEGRepresentation(imageOri, 0.1);
        
        //生成图片的存储路径
        NSDate *now = [NSDate date];
        NSString *fileName = [NSString stringWithFormat:@"%f.jpeg",[now timeIntervalSince1970]];
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [arr objectAtIndex:0];
        _filePath = [documentDir stringByAppendingPathComponent:@"image"];
        _filePath = [_filePath stringByAppendingPathComponent:fileName];
//        [_filePath retain];
        NSLog(@"filePath:%@",_filePath);
        
        //存储图片
        if (_filePath == nil) {
            [self alertString:@"错误的存储路径"];
            [self.delegate dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        BOOL save = [data writeToFile:_filePath atomically:YES];
        if (!save) {
            [self alertString:@"图片存储失败"];
            [self.delegate dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        //发送图片
        [self.delegate sendData: data withType:TYPE_PIC andFilePath:_filePath andTimeLength:0.0];
        
    }else if ([mediaType isEqualToString:@"public.movie"]){
        //选取视频
        
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"xxxxxx:%@",url.path);
        
        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        int second = 0;
        second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
        NSLog(@"movie duration : %d", second);
        if (15 < second) {  //判断选择的视频长度是否超过15秒
            [Utility showHUD:@"您选择视频过长，已经超过了15秒。请重新选择"];
            [self.delegate dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        //判断是否要写入相册
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            _movPath = url.path;
        }else{
            _movPath = nil;
        }
        
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
        
        //保存路径
        NSDate *now = [NSDate date];
        NSString *fileName = [NSString stringWithFormat:@"%f.mp4",[now timeIntervalSince1970]];
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [arr objectAtIndex:0];
        _filePath = [documentDir stringByAppendingPathComponent:@"movie"];
        _filePath = [_filePath stringByAppendingPathComponent:fileName];
        NSLog(@"filePath:%@",_filePath);
        
        //##########
//        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
//        [player prepareToPlay];
//        CGSize movieSize = player.naturalSize;
//        NSLog(@"movieSize:%f,%f",movieSize.width,movieSize.height);
//        UIImage *thumb = [player thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];
//        NSLog(@"thumb ori:%d",thumb.imageOrientation);
//        UIImageWriteToSavedPhotosAlbum(thumb, self, nil, nil);

        //mov转成mp4格式
//        AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetExportSession *aSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetPassthrough];
        aSession.outputURL = [NSURL fileURLWithPath:_filePath];
        aSession.shouldOptimizeForNetworkUse = YES;
        aSession.outputFileType = AVFileTypeMPEG4;
        
        [Utility showTextOnly:@"处理中..." isWait:YES];
        [aSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([aSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"failed...");
                    [Utility hideWaitHUDForView];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"transcoding failed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    [Utility hideWaitHUDForView];
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"Successful!");
                    [Utility hideWaitHUDForView];
                    [self performSelectorOnMainThread:@selector(showVideoAlert) withObject:nil waitUntilDone:YES];
                    break;
                }
                default:
                    break;
            }
        }];
        [Utility hideWaitHUDForView];
        ipc = nil;
    }
//    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (void)showVideoAlert
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:_filePath];
    NSString *rest = [Utility calFileSize:data.length];
    NSString *msg = [NSString stringWithFormat:@"视频压缩后文件大小为%@，确定要发送吗？",rest];
    NSLog(@"msg:%@",msg);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

- (void)convertToMP4AndSend:(NSString *)filePath
{
    //取得mp4格式的数据并发送
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    NSLog(@"movie data:%d",[data length]);
    [self.delegate sendData:nil withType:TYPE_VIDEO andFilePath:filePath andTimeLength:0.0];
}

- (void)clearVideo
{
    NSString *path = NSTemporaryDirectory();
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSLog(@"arr length:%d",[arr count]);
    for (NSString *str in arr) {
        NSLog(@"str:%@",str);
        NSString *dir = [path stringByAppendingPathComponent:str];
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
}

//开始录制声音
- (void)recordBegin
{
    NSLog(@"recordBegin...");
    
    [_pressToSpeak addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    
    [volumeView setHidden:NO];
    
    //设定录制声音名称并获取录制文件存储路径
    NSString *fileName = @"testrecord.caf";
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    NSLog(@"filePath:%@",filePath);

    NSURL *url = [NSURL URLWithString:filePath];
    
    NSError *error;
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    /*
        五个参数：
            1.ID号
            2.采样率
            3.通道的数目 : 1单声道,2立体声
            4.采样位数  默认为16 : 8 16 24 32
            5.采样是否采用大端法(big endian)存储数据:在存储器中按照从最高有效字节到最低有效位字节的顺序存储对象.
            6.采样信号是整数还是浮点数
     */
    [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey]; 
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
//    if(_recorder==nil)
    _recorder = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    [_recorder performSelector:@selector(record) withObject:nil afterDelay:0];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:NULL];
//    [_recorder recordForDuration:30.0f];
    [self setRecording:YES];
    
    dropVoice = NO;
    recordingTimeLength = 0.0;
    
    volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleVolumeChange) userInfo:nil repeats:YES];
}

- (void)recordEnd
{
    NSLog(@"recordEnd...");
    [volumeView setHidden:YES];
    [self setRecording:NO];
    [_recorder pause];
    [self performSelector:@selector(moveIn:) withObject:nil];
    if (_recorder.currentTime < 1) {
        [Utility showHUD:@"语音时间太短!"];
        dropVoice = YES;
        //倒计时内容
        voiceTimeLabel.text = @"0秒";
    }else{
        dropVoice = NO;
    }
    NSLog(@"_recorder.currentTime : %f", _recorder.currentTime);
    [_pressToSpeak removeTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    recordingTimeLength = _recorder.currentTime;
    [_recorder performSelector:@selector(stop) withObject:nil afterDelay:0];
}

- (void)stopRecord{
    if (_recorder.currentTime > 0) {
        [self recordEnd];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [volumeTimer invalidate];
    if (recording) {
        NSLog(@"audioRecorderDidFinishRecording...  Droping...");
        return;
    }
    
    if (![volumeView isHidden]) {
        [volumeView setHidden:YES];
        [self performSelector:@selector(moveIn:) withObject:nil];
        [_pressToSpeak removeTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSLog(@"audioRecorderDidFinishRecording...");
    NSString *fileName = @"testrecord.caf";
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    if (dropVoice) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSData *amrData = EncodeWAVEToAMR(data, 1, 16);
    [self.delegate sendData:amrData withType:TYPE_VOICE andFilePath:filePath andTimeLength:recordingTimeLength];
    _recorder = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    
    //倒计时内容
    voiceTimeLabel.text = @"0秒";
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"audioRecorderEncodeErrorDidOccur...");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying...");
}


- (void)moveOut:(id)sender
{
    NSLog(@"moveOut...");
    
    [phone setHidden:YES];
    [volume setHidden:YES];
    [dropLabel setHidden:NO];
    [dropImgView setHidden:NO];
}

- (void)moveIn:(id)sender
{
    NSLog(@"moveIn...");
    [phone setHidden:NO];
    [volume setHidden:NO];
    [dropLabel setHidden:YES];
    [dropImgView setHidden:YES];
}

- (void)dropRecord:(id)sender
{
    NSLog(@"drop record...");
    [self setRecording:NO];
    [volumeView setHidden:YES];
    [self performSelector:@selector(moveIn:) withObject:nil];
    dropVoice = YES;
    [_recorder performSelector:@selector(stop) withObject:nil afterDelay:0.1];
}

- (void)handleVolumeChange
{
    [_recorder updateMeters];
    CGFloat peakPower = [_recorder peakPowerForChannel:0];
//    NSLog(@"peakPower:%f",peakPower);
    int v = (int)((35+peakPower)/5)+1;
    if (v>0 && v<=7) {
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"amp%d.png",v]];
        volume.frame = CGRectMake(108, 21+157-img.size.height, img.size.width, img.size.height);
        volume.image = img;
    }else{
        UIImage *img = [UIImage imageNamed:@"amp1.png"];
        volume.frame = CGRectMake(108, 21+157-img.size.height, img.size.width, img.size.height);
        volume.image = img;
    }
    //倒计时内容
    voiceTimeLabel.text = [[NSString alloc] initWithFormat:@"%d秒", (int)floor([_recorder currentTime])];
    
    //录制最大时间30秒
    if (_recorder.currentTime > 30) {
        [self recordEnd];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alert:%d",buttonIndex);
    if (buttonIndex == 1) {
        [Utility showTextOnly:@"处理中..." isWait:YES];
        //写入相册mov，统一写入mov格式文件，发送时转化成mp4，针对从照片库选择视频的情况
        if (_movPath != nil) {
            BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_movPath);
            NSLog(@"mov path:%@",_movPath);
            if (compatible) {
                NSLog(@"write to lib...");
                UISaveVideoAtPathToSavedPhotosAlbum(_movPath, self, nil, NULL);
            }
//            [_movPath release];
            _movPath = nil;
        }
//        MPMoviePlayerController *theMovie = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:_movPath]];
//        [theMovie setFullscreen:YES];
//        [theMovie.view setFrame:CGRectMake(0, 0, 320, 400)];
//        [self addSubview:theMovie.view];
//        [theMovie prepareToPlay];
//        [theMovie play];
        
        [self convertToMP4AndSend:_filePath];
        _filePath = nil;
    }
}

//alert something
- (void)alertString:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
//    [alert release];
}


//LocationViewDelegate中的方法实现
- (void)postLocationMsg:(NSDictionary *)dic
{
    NSLog(@"postLocationMsg...");
    
    [self.delegate sendLocation:dic];
}

#pragma mark - 退出聊天界面时处理
- (void)stopChatPrepare{
    //录音处理
    [self stopAudioRecord];
}

//停止录音
- (void)stopAudioRecord{
    if (recording) {
        dropVoice = YES;
        [_recorder performSelector:@selector(stop) withObject:nil afterDelay:0];
    }
}


@end

