//
//  Utility.m
//  WeClub
//
//  Created by chao_mit on 13-1-23.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"


@implementation Utility

- (id)init
{
    self = [super init];
    if (self) {
        rp = [[RequestProxy alloc]init];
        rp.delegate = self;
    }
    return self;
}
//字典打印
+(void)printDic:(NSDictionary *)dic{
    for( NSString *Key in [dic allKeys] )
    {
        WeLog(@"%@",[dic objectForKey:Key]);
    }
}

//提示窗口
+ (void)MsgBox:(NSString *)msg{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
												   delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+ (UIAlertView *)MsgBox:(NSString *)msg AndTitle:(NSString *)title  AndDelegate:(id)delegate AndCancelBtn:(NSString *)cancel AndOtherBtn:(NSString *)other withStyle:(UIAlertViewStyle) style{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                 message:msg
                                                delegate:delegate
                                       cancelButtonTitle:cancel
                                       otherButtonTitles:other, nil];
    alert.alertViewStyle =  style;
    [alert show];
    [alert release];
    return alert;
}

+ (void)showHUD:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows objectAtIndex:0] animated:YES];
    // Configure for text only and offset down
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = msg;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

+ (void)showHUD:(NSString *)msg afterDelay:(float)delayTime{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = msg;
    //    hud.margin = 10.f;
    //    hud.yOffset = -18.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delayTime];
}

+ (void)showTextOnly:(NSString *)msg isWait:(BOOL)bWait{
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = msg;
	hud.margin = 10.f;
	hud.yOffset = -[UIApplication sharedApplication].keyWindow.frame.size.height/2 + 85;
	hud.removeFromSuperViewOnHide = YES;
    
    if (!bWait) {
        [hud hide:YES afterDelay:2.0];
    }
    else{
        //添加Loading动画
        UIActivityIndicatorView *actionSheet = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [actionSheet setFrame:CGRectMake(0 ,
                                         roundf((hud.bounds.size.height - 101 + 50) / 2) + hud.yOffset,
                                         50,
                                         50)];

        [actionSheet startAnimating];
        [hud addSubview:actionSheet];
        
        //添加取消按钮
        UIButton *cancelButton = [[UIButton alloc] init];
        [cancelButton setImage:[UIImage imageNamed:@"rcd_cancel_icon.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(hud.bounds.size.width - 40 ,
                                          roundf((hud.bounds.size.height - 101 + 80) / 2) + hud.yOffset,
                                          20,
                                          20)];
        [cancelButton addTarget:self action:@selector(hideWaitHUDForView) forControlEvents:UIControlEventTouchUpInside];
//        [hud addSubview:cancelButton];
    }
}

+ (void)showWaitHUD:(NSString *)msg withView:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = msg;
}

+ (void)showHUDWithTitleAndButton:(NSString *)msg withView:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = msg;
}

+ (void)hideWaitHUDForView:(UIView *)view{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

+ (void) hideWaitHUDForView{
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
}

+ (BOOL)checkNetWork{
    if (([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) &&
        ([Reachability reachabilityForLocalWiFi].currentReachabilityStatus == NotReachable)){
        [self showHUD:@"无法连接到网络，请稍后再试"];
        return NO;
    }
    return YES;
}

+ (CATransition*)createAnimationWithType:(NSString *)type withsubtype:(NSString *)subtype withDuration:(double)duration{
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;

    if (duration) {
        animation.duration = duration;
    }
    
	animation.fillMode = kCAFillModeForwards;
//    animation.type = kCATransitionMoveIn;
    animation.type = type;
//    animation.subtype = kCATransitionFromTop;
    animation.subtype = subtype;
    return animation;
}


+ (UIImage *)rotateImage:(UIImage *)oldImage
{
    UIImage *newImage = nil;
    
    CGSize oldSize = oldImage.size;
    CGSize newSize = [self getNewSize:oldImage];
    WeLog(@"newSize:%f,%f",newSize.width,newSize.height);
    double angle = [self getRotateAngle:oldImage];
    
    UIGraphicsBeginImageContext(oldSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.5*newSize.width, 0.5*newSize.height);
    CGContextRotateCTM(context, angle);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(-0.5*oldSize.width, -0.5*oldSize.height, newSize.width, newSize.height), oldImage.CGImage);
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    WeLog(@"newImage ori:%d",newImage.imageOrientation);
    
    
    return newImage;
}

+ (CGSize)getNewSize:(UIImage *)img
{
    UIImageOrientation ori = img.imageOrientation;
    if (ori == UIImageOrientationLeft || ori == UIImageOrientationLeftMirrored || ori == UIImageOrientationRight || ori == UIImageOrientationRightMirrored) {
        WeLog(@"heng...");
        CGSize newSize = CGSizeMake(img.size.height, img.size.width);
        //        CGSize newSize = img.size;
        
        return newSize;
    }else{
        //        CGSize newSize = CGSizeMake(img.size.height, img.size.width);
        WeLog(@"shu...");
        CGSize newSize = img.size;
        return newSize;
    }
}

//获取图片方向
+ (double)getRotateAngle:(UIImage *)img
{
    double angle = 0.0;
    
    UIImageOrientation ori = img.imageOrientation;
    if (ori == UIImageOrientationLeft || ori == UIImageOrientationLeftMirrored) {
        angle = -M_PI_2;
    }else if (ori == UIImageOrientationRight || ori == UIImageOrientationRightMirrored){
        angle = M_PI_2;
    }else if (ori == UIImageOrientationDown || ori == UIImageOrientationDownMirrored){
        angle = M_PI;
    }
    
    return angle;
}

+ (CGSize)calShowThumbSize:(CGSize)oldSize
{
    CGSize newSize;
//    WeLog(@"old size:%f,%f",oldSize.width,oldSize.height);
    
    if (oldSize.width>oldSize.height) {
        float scale = 100.0/oldSize.width;
        newSize = CGSizeMake(100, oldSize.height*scale);
    }else{
        float scale = 100.0/oldSize.height;
        newSize = CGSizeMake(oldSize.width*scale, 100);
    }
    
    if (newSize.width<50) {
        newSize.width = 50;
    }
    
    if (newSize.height<50) {
        newSize.height = 50;
    }
    
    return newSize;
}

+ (CGSize)calSaveThumbSize:(CGSize)oldSize
{
    CGSize newSize;
    
    if (oldSize.width>oldSize.height) {
        float scale = 100.0/oldSize.width;
        newSize = CGSizeMake(100, oldSize.height*scale);
    }else{
        float scale = 100.0/oldSize.height;
        newSize = CGSizeMake(oldSize.width*scale, 100);
    }
    
    if (newSize.width<50) {
        float scale = 50/newSize.width;
        newSize.width = 50;
        newSize.height = newSize.height*scale;
    }
    
    if (newSize.height<50) {
        float scale = 50/newSize.height;
        newSize.height = 50;
        newSize.width = newSize.width*scale;
    }
    
    return newSize;
}

//数据校验
//获取字符串高度
+(CGFloat)getSizeByContent:(NSString *)content withWidth:(CGFloat)contentWidth withFontSize:(CGFloat)fontSize{
    UIFont *font = [UIFont fontWithName:FONT_NAME_ARIAL size:fontSize];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 900) lineBreakMode:UILineBreakModeTailTruncation];
    return size.height;
}

+(CGFloat)getWidthByContent:(NSString *)content withHeight:(CGFloat)contentheight withFontSize:(CGFloat)fontSize{
    UIFont *font = [UIFont fontWithName:FONT_NAME_ARIAL size:fontSize];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(900, contentheight) lineBreakMode:UILineBreakModeTailTruncation];
    return size.width;
}


//获取字符个数
+(NSUInteger) unicodeLengthOfString: (NSString *) text {
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    NSUInteger unicodeLength = asciiLength / 2;
    
    if(asciiLength % 2) {
        unicodeLength++;
    }
    
    return unicodeLength;
}

//获取字字节个数
+(NSUInteger) getByteLengthOfString: (NSString *) text {
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    return asciiLength;
}

+ (NSString *)calFileSize:(int)length
{
    int M = length/1024/1024;
    int K = length/1024;
    NSString *result;
    if (M > 0) {
        result = [NSString stringWithFormat:@"%.2fM",length/1024.0/1024.0];
    }else if (M == 0 && K > 0){
        result = [NSString stringWithFormat:@"%dK",length/1024];
    }else if (K == 0){
        result = [NSString stringWithFormat:@"%dB",length];
    }
    return result;
}

+ (void)addViews:(NSArray *)list withView:(UIView *)containerView withImageSize:(CGFloat)size withSpace:(CGFloat)space withSEL:(SEL)action{
    int i;
    for (i = 0; i < [list count]; i++) {
        EGOImageButton* deleteIcon = [[EGOImageButton alloc]initWithPlaceholderImage:[UIImage imageNamed:@"deleteIcon.png"] delegate:nil];
        UIImageView *Logo = [[[UIImageView alloc]init] autorelease];
        [Logo setImageWithURL:[NSURL URLWithString:[[list objectAtIndex:i] objectForKey:KEY_LOGO]] placeholderImage:[UIImage imageNamed:@"mediaImgPlaceHolder.jpg"]];
        [Logo setFrame:CGRectMake((size+space)*(i%4), (i/4)*(size+space), size, size)];
        Logo.backgroundColor = [UIColor redColor];
        [deleteIcon setFrame:CGRectMake((size+space)*(i%4)+(size)-10, (i/4)*(size+space)-10, 20, 20)];
        deleteIcon.tag = i;
        [deleteIcon addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:Logo];
        [containerView addSubview:deleteIcon];
    }
    [containerView setFrame:CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, 320, (i/4+1)*(size+space))];
    containerView.backgroundColor = [UIColor redColor];
}

//根据含有表情的字符串生成UIView

#define KFacialSizeWidth   22
#define KFacialSizeHeight  22
#define MAX_WIDTH          220
#define BEGIN_FLAG         @"["
#define END_FLAG           @"]"
#define BEGIN_WEB_HTTP     @"http://"
#define BEGIN_WEB_HTTPS    @"https://"
#define BEGIN_WEB_MITTBS   @"mittbs."
#define BEGIN_WEB_WWW      @"www."
#define END_WEB            @" "

+ (CGSize)calFaceViewSize:(NSString *)faceString
{
    UIView *view = [self getFaceView:faceString delegateView:nil];
    return view.frame.size;
}

+ (UIView *)getFaceView:(NSString *)faceString delegateView:(UIViewController *)view
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:faceString :array];
    UIFont *font = [UIFont systemFontOfSize:18];
    UIColor *linkerColor = [UIColor blueColor];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:18.0f];
    CGFloat upX = 0;
    CGFloat upY = 4;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *str=[data objectAtIndex:i];
            //            WeLog(@"str--->%@",str);
            //处理表情
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG] && [UIImage imageNamed:[self getImageName:str]] != nil)
            {
                if (upX+KFacialSizeWidth-5 >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 220;
                    Y = upY;
                }
                //                WeLog(@"str(image)---->%@",str);
                //                NSString *imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[self getImageName:str]]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                [img release];
                upX=KFacialSizeWidth+upX;
                if (X<220 && X < upX) X = upX;
            
            }
            //处理网站
            else if (([[str lowercaseString] hasPrefix: BEGIN_WEB_HTTP] ||
                      [[str lowercaseString] hasPrefix: BEGIN_WEB_HTTPS] ||
                      [[str lowercaseString] hasPrefix: BEGIN_WEB_MITTBS] ||
                      [[str lowercaseString] hasPrefix: BEGIN_WEB_WWW])){
                //链接
                NSString *titleKey = str;
                CGFloat x = upX;
                CGFloat y = upY;
                CGFloat maxWidth = MAX_WIDTH;
                NSString *piece = str;
                if (x + [str sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [str sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:str forState:UIControlStateNormal];
                    [btn setTitleColor:linkerColor forState:UIControlStateNormal];
                    [btn addTarget:view action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
                    [returnView addSubview:btn];
                    x += subSize.width;
                    upX = x;
                    upY = y;
                    Y = y;
                    WeLog(@"<MAX_WIDTH temp:%@ Y:%f", str , x);
                    if (X<220 && X < upX) X = upX;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        WeLog(@">MAX_WIDTH temp:%@ Y:%f", subString , x);
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        UILabel *subLabel = [[UILabel alloc] init];
                        subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                        subLabel.text = subString;
                        subLabel.textColor = linkerColor;
                        subLabel.backgroundColor = [UIColor clearColor];
                        [btn addSubview:subLabel];
                        [btn setTitle:titleKey forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [btn addTarget:view action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
                        [returnView addSubview:btn];
                        x += subSize.width;
                        
                        if (index < piece.length) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    UILabel *subLabel = [[UILabel alloc] init];
                    subLabel.frame = CGRectMake(0, 0, subSize.width, 22);
                    subLabel.text = piece;
                    subLabel.textColor = linkerColor;
                    subLabel.backgroundColor = [UIColor clearColor];
                    [btn addSubview:subLabel];
                    [btn setTitle:titleKey forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [btn addTarget:view action:@selector(selectLinker:) forControlEvents:UIControlEventTouchUpInside];
                    [returnView addSubview:btn];
                    x += subSize.width;
                    upX = x;
                    upY = y;
                    Y = y;
                    X = maxWidth;
                }
                
            }
            //处理文字
            else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (![@"\n" isEqualToString:temp] && j + 1 < [str length]) {
                        temp = [str substringWithRange:NSMakeRange(j, 2)];
                        j++;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(220, 40)];
                    if (upX+size.width > MAX_WIDTH)
                    {
                        j--;
                        temp = [str substringWithRange:NSMakeRange(j, 1)];
                        size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(220, 40)];
                        if (upX+size.width > MAX_WIDTH){
                            upY = upY + KFacialSizeHeight;
                            upX = 0;
                            X = 220;
                            Y = upY;
                        }
                    }
                    WeLog(@"temp:%@ Y:%f", temp , upX);
                    if ([temp isEqualToString:@"\n"]) {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        Y = upY;
                    }
                    
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    la.textAlignment = UITextAlignmentCenter;
                    [returnView addSubview:la];
                    [la release];
                    upX=upX+size.width;
                    if (X<220 && X < upX) {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(15.0f,1.0f, X, Y+KFacialSizeHeight); //@ 需要将该view的尺寸记下，方便以后使用
    //    WeLog(@"%.1f %.1f", X, Y);
    return returnView;
    
}

//图文混排

+ (void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    NSRange rangeSpace = [message rangeOfString:END_WEB];
    //判断当前字符串是否还有表情的标志。判断表情信息
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        //按照空格分隔
        if (rangeSpace.length > 0) {
            NSString *nextstr = [message substringWithRange:NSMakeRange(0, rangeSpace.location + 1)];
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:rangeSpace.location + 1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        else{
            [array addObject:message];
        }
    }
}

+ (NSString *)getImageName:(NSString *)str
{
    
    int imageIndex = [[Constants getSingleton].faceImageNames indexOfObject:str];
    NSString *imageName;
    if (imageIndex == NSNotFound) {
        return nil;
    }
    if (imageIndex < 9) {
        imageName = [NSString stringWithFormat:@"00%d.png",imageIndex+1];
    }else{
        imageName = [NSString stringWithFormat:@"0%d.png",imageIndex+1];
    }
    return imageName;
}

+ (NSMutableArray *)getSearchHistory{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"SearchHistory"];
}

+ (void)storeSearchHistory:(NSMutableArray *)searchHistory{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"SearchHistory"];
    [userDefaults setObject:searchHistory forKey:@"SearchHistory"];
}

//获取视频缩略图
+(UIImage *)getImage:(NSString *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
    
}

//时间戳转为格式化时间
+(NSString *)getDate:(NSString*)string{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[string floatValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    dateFormatter = nil;
    return dateString;
}

//为图片添加圆角，阴影
+(void)psImageView:(UIView *)imgView{
    imgView.layer.borderColor = [[UIColor grayColor]CGColor];
    imgView.layer.borderWidth = 1.0;
    imgView.layer.shadowOffset = CGSizeMake(4.0f, 4.0f);
    imgView.layer.shadowOpacity = 0.5;
    imgView.layer.shadowRadius = 2.0;
    imgView.layer.shadowColor = [[UIColor grayColor]CGColor];
    imgView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imgView.bounds].CGPath;
}

//星数
+(void)initStarLevelView:(NSString *)starLevel withStarView:(UIView *)starLevelView{
    for (int i = 0; i < [starLevel intValue]; i++) {
        UIImageView *star = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star.png"]];
        star.frame = CGRectMake(14*i, 5, 12, 12);
        [starLevelView addSubview:star];
    }
    if ((![starLevel intValue]||[starLevel intValue]<0)&&3 == starLevelView.tag) {
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, 20, 18)];
        [Utility styleLbl:lbl withTxtColor:nil withBgColor:nil withFontSize:17];
        lbl.text = @"无";
        [starLevelView addSubview:lbl];
    }
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if([alertView.title isEqualToString:@"特别提示"]){
        //        [Utility openURL:<#(NSString *)#>]
    }else if (alertView.tag == 1) {
        if (buttonIndex) {
            NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=587767923"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
        }else{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:@"1" forKey:@"notNoticeCheck"];
        }
        return;
    }
}

+ (void)processData:(NSDictionary *)dic requestType:(NSString *)type{
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString *newVersion = [[dic objectForKey:KEY_DATA] objectForKey:@"version"];
    if (![newVersion isEqualToString:currentVersion]) {
        UIAlertView *alert = [Utility MsgBox:[NSString stringWithFormat:@"%@",[[dic objectForKey:KEY_DATA] objectForKey:@"info"]] AndTitle:@"版本更新" AndDelegate:self AndCancelBtn:@"以后再说" AndOtherBtn:@"马上更新" withStyle:0];
        alert.tag = 1;
    }else{
        [Utility showHUD:@"已经是最新版本."];
    }
}

+ (void)processException:(int)excepCode desc:(NSString *)excepDesc info:(NSDictionary *)infoDic requestType:(NSString *)type{
}

+ (void)processFailed:(NSString *)failDesc requestType:(NSString *)type{

}
- (void)getUserTypeForClub:(Club *)togoClub{
    myClub = togoClub;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:togoClub.ID forKey:KEY_CLUB_ROW_KEY];
    [rp sendRequest:dic type:URL_USER_CHECK_USERTYPE];
}

+(NSString *)getDistance:(NSString *)distance{
    if (!distance) {
        return @"未知";
    }
    if([distance intValue] < 100) {
    return @"100米以内";
    }else
    if([distance intValue]< 500) {
    return @"500米以内";
    }else
    if([distance intValue]< 1000) {
    return @"1公里以内";
    }else
    if([distance intValue]< 2000) {
    return @"2公里以内";
    }else
    if([distance intValue]< 5000) {
    return @"5公里以内";
    }else
    if([distance intValue]< 10000) {
    return @"10公里以内";
    }else
    if([distance intValue]< 20000) {
    return @"20公里以内";
    }else
    if([distance intValue] < 50000) {
    return @"50公里以内";
    }else
    if([distance intValue] < 100000) {
        return @"100公里以内";
    }else
        return @"很遥远";
    }

//极限处理
+(NSString *)numberSwitch:(NSString *)number{
    int num = [number intValue];
    if (num < 10000) {
        return number;
    }else{
        float count = (float)(num)/10000;
        if ((int)(10*(count-(int)count)) == 0) {
            return [NSString stringWithFormat:@"%d万+",(int)count];
        }
        return [NSString stringWithFormat:@"%0.1f万+",count];
    }
}

//定制Label
+(void)styleLbl:(UILabel *)lbl withTxtColor:(UIColor *)txtColor withBgColor:(UIColor*)bgColor withFontSize:(CGFloat)size{
    if (!txtColor) {
        lbl.textColor = [UIColor grayColor];
    }else{
        lbl.textColor = txtColor;
    }
    
    if (!bgColor) {
        lbl.backgroundColor = [UIColor clearColor];
    }else{
        lbl.backgroundColor = bgColor;
    }
    if (0) {
        lbl.backgroundColor = [UIColor redColor];
    }
    lbl.font = [UIFont fontWithName:FONT_NAME_ARIAL size:size];
}

//为图片添加事件
+(void)addTapGestureRecognizer:(UIView *)view withTarget:(id)target action:(SEL)action{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:target action:action ];
    [view addGestureRecognizer:tapGestureRecognizer];
}

+ (NSString *)getCacheDir
{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [arr objectAtIndex:0];
    NSString *cacheDirectory = [documentDir stringByAppendingPathComponent:@"cacheDir"];
    
    return cacheDirectory;
}



//清空缓存，图片缓存，文件缓存
+(void)clearCache{
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache]clearMemory];
    [[EGOCache currentCache]clearCache];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    WeLog(@"DocumentsDirectory%@",documentsDirectory);
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        WeLog(@"file:%@",file);
        if ([file isEqualToString:@"NoticeManager"] || [file isEqualToString:@"userCredential"]) {
            continue;
        }
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
        if (!success || error) {
            WeLog(@"delete Files Failed");
        }
    }
//    [self showHUD:@"清除缓存成功"];
    [SVProgressHUD dismissWithSuccess:@"清除缓存成功"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KEY_CLEAR_CACHE_TIME];
    [self checkDirs];
}

+(NSString *)getStarLevel:(NSString *)number{
    int n = 0;
    while (10*(n*n*(n+4)) < [number intValue]) {
        n++;
    }
    return [NSString stringWithFormat:@"%d",n-1];
}

//获取时间
+(NSString *)getLastDate:(NSDate *)lastDate
{
    NSString *dateString;
    if ([lastDate isToday]) {
        if (lastDate.minute == 0) {
            dateString = [NSString stringWithFormat:@"今天%d:00",lastDate.hour]; 
        }else{
            if (lastDate.minute < 10) {
                dateString = [NSString stringWithFormat:@"今天%d:0%d",lastDate.hour,lastDate.minute];
            }else{
                dateString = [NSString stringWithFormat:@"今天%d:%d",lastDate.hour,lastDate.minute];
            }
        }
    }else if ([lastDate isYesterday]){
        dateString = @"昨天";
    }else if ([lastDate daysBeforeDate:[lastDate dateBySubtractingDays:1]]){
        dateString = [NSString stringWithFormat:@"%d天前",[lastDate daysBeforeDate:[NSDate date]]];

//        dateString = [NSString stringWithFormat:@"%d.%d",lastDate.month,lastDate.day];
    }
    return dateString;
}

//计算两经纬度点之间的距离
+(NSString *)getDistanceString:(NSString *)location{
    if (0 == [[[NSUserDefaults standardUserDefaults] objectForKey:LOCATABLE] boolValue] ) {
        return @"未知";
    }
    if ([location isEqualToString:@"0"]) {
        return @"很遥远";
    }
    if ([location isEqualToString:@"0.01,0.01"] || [location isEqualToString:@""]) {
        return @"未知";
    }
    CLLocation *location1 = [[[CLLocation alloc] initWithLatitude:myAccountUser.userLatitude longitude:myAccountUser.userLongitude] autorelease];
    NSArray *listItems = [location componentsSeparatedByString:@","];
    CLLocation *location2 = [[[CLLocation alloc] initWithLatitude:[[listItems objectAtIndex:1] doubleValue] longitude:[[listItems objectAtIndex:0] doubleValue]] autorelease];
//    WeLog(@"Distance i meters: %f", [location1 distanceFromLocation:location2]);
    return [self getDistance:[NSString stringWithFormat:@"%f",[location1 distanceFromLocation:location2]]];
}


//解析二维码字符串
+(NSDictionary *)qrAnalyse:(NSString *)qr{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if ([qr rangeOfString:[NSString stringWithFormat:@"/%@/mitbbs/info",PHP]].location == NSNotFound) {
        [dic setValue:@"3" forKey:KEY_TYPE];
        [dic setValue:qr forKey:@"id"];
    } else {
        NSArray *stArray = [[[qr componentsSeparatedByString:@"?"] objectAtIndex:1] componentsSeparatedByString:@"&"];
        //componentsSeparatedByString拆分字符串
        NSString *type = [[[stArray objectAtIndex:0] componentsSeparatedByString:@"type="] objectAtIndex:1];
        NSString *ID = [[[stArray objectAtIndex:1] componentsSeparatedByString:@"id="] objectAtIndex:1];
        [dic setValue:type forKey:KEY_TYPE];
        [dic setValue:ID forKey:@"id"];
    }
    return dic;
}

#define kCoverViewTag           1234
#define kImageViewTag           1235
#define kAnimationDuration      0.3f
#define kImageViewWidth         300.0f
//#define kBackViewColor          [UIColor colorWithWhite:0.667 alpha:0.8f]
#define kBackViewColor          [UIColor colorWithWhite:0.38 alpha:0.8f]

#import "UIImageView+Addition.h"

- (void)hiddenView
{
    UIView *coverView = (UIView *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:kCoverViewTag];
    [coverView removeFromSuperview];
}

- (void)hiddenViewAnimation
{
    //    UIImageView *imageView = (UIImageView *)[[self window] viewWithTag:kImageViewTag];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration]; //动画时长
    //    CGRect rect = [self convertRect:self.bounds toView:self.window];
    //    imageView.frame = rect;
    
    [UIView commitAnimations];
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:kAnimationDuration];
    
}

//自动按原UIImageView等比例调整目标rect
- (CGRect)autoFitFrame
{
    //调整为固定宽，高等比例动态变化
    AppDelegate* myDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    float width = kImageViewWidth;
    float targeHeight = 320;
    UIView *coverView = (UIView *)[myDelegate.window viewWithTag:kCoverViewTag];
    CGRect targeRect = CGRectMake(coverView.frame.size.width/2 - width/2, coverView.frame.size.height/2 - targeHeight/2, width, targeHeight);
    return targeRect;
}

- (void)imageTap
{
    AppDelegate* myDelegate = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    UIView *coverView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    coverView.backgroundColor = kBackViewColor;
    coverView.tag = kCoverViewTag;
    UITapGestureRecognizer *hiddenViewGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenViewAnimation)];
    [coverView addGestureRecognizer:hiddenViewGecognizer];
    [hiddenViewGecognizer release];
    
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    UIImageView *imageView = [[UIImageView alloc] init];
    
    imageView.tag = kImageViewTag;
    imageView.userInteractionEnabled = YES;
//    imageView.contentMode = self.contentMode;
//    CGRect rect = [self convertRect:self.bounds toView:self.window];
//    imageView.frame = rect;
    
    [coverView addSubview:imageView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    if (iPhone5) {
        btn.frame = CGRectMake(120, 510, 80, 30);
    }else{
        btn.frame = CGRectMake(120, 410, 80, 30);
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    [btn setTitle:@"查看原图" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(viewLarge) forControlEvents:UIControlEventTouchDown];
    [coverView addSubview:btn];
    [myDelegate.window addSubview:coverView];
    [coverView release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kAnimationDuration];
    imageView.frame = [self autoFitFrame];
    [UIView commitAnimations];
}

//-(void)viewLarge{
//    [self hiddenView];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewLargePhoto" object:self.superview.superview userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.superview.superview.tag],@"articleNO",[NSNumber numberWithInt:self.tag],@"mediaNO", nil]];
//}

+(void)addDetailShow:(UIImageView *)imageView
{
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [imageView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
    //    UISwipeGestureRecognizer *swipeGestureRecognizer1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doNothing)];
    //    [swipeGestureRecognizer1 setDirection:UISwipeGestureRecognizerDirectionUp];
    //    [self addGestureRecognizer:swipeGestureRecognizer1];
    //    [swipeGestureRecognizer1 release];
}

+ (void)attachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [self cutMixedString:str];
//    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"@"] && [piece hasSuffix:@" "]) {
                //@username
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    x += subSize.width;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"#"] && [piece hasSuffix:@"#"] && piece.length>1){
                //#话题#
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    x += subSize.width;
                    
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    
                    x += subSize.width;
                    
                }
                
            }else if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        
                        x += subSize.width;
                    }else{
                        int index = 0;
                        while (x + [piece sizeWithFont:font].width > maxWidth) {
                            NSString *subString = [piece substringToIndex:index];
                            while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                                index++;
                                subString = [piece substringToIndex:index];
                            }
                            index--;
                            if (index <= 0) {
                                x = 0;
                                y += 22;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        
                        x += subSize.width;
                        
                    }
                    
                }else{
                    if (x + 22 > maxWidth) {
                        x = 0;
                        y += 22;
                    }
                    
                    x += 22;
                }
                
            }else if ([piece hasPrefix:@"http://"] && [piece hasSuffix:@" "]){
                //链接
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    
                    x += subSize.width;
                    
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        CGSize subSize = [subString sizeWithFont:font];
                        x += subSize.width;
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    x += subSize.width;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 22;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    
                    x += subSize.width;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        
                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                        WeLog(@"yyyyy:%f,%@",y,piece);
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
//    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    targetView.frame = rect;
}

+ (NSMutableArray *)cutMixedString:(NSString *)str
{
//    WeLog(@"str to be cut:%@,%d",str,str.length);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int pStart = 0;
    int pEnd = 0;
    
    
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"@"]) {
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            WeLog(@"fuck substring:%@",subString);
            NSRange range = [subString rangeOfString:@" "];
            
            if (range.location != NSNotFound) {
                NSString *strPiece = [subString substringToIndex:range.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
            
        }else if ([a isEqualToString:@"#"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd+1];
            NSRange range = [subString rangeOfString:@"#"];
            if (range.location != NSNotFound) {
                NSString *strPiece = [NSString stringWithFormat:@"#%@",[subString substringToIndex:range.location+1]];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"["]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            NSRange range1 = [subString rangeOfString:@"["];
            NSRange range2 = [subString rangeOfString:@"]"];
            if (range2.location != NSNotFound && range2.location > range1.location) {
                NSString *strPiece = [subString substringToIndex:range2.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"h"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 9) {
                NSString *headStr = [subString substringToIndex:7];
//                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"http://"]) {
                    NSRange range = [subString rangeOfString:@" "];
                    if (range.location != NSNotFound) {
                        NSString *strPiece = [subString substringToIndex:range.location+1];
                        [returnArray addObject:strPiece];
                        pEnd += strPiece.length;
                        pStart = pEnd;
                        pEnd--;
                    }
                }
            }
            
        }else if ([a isEqualToString:@"\n"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 2) {
                NSString *headStr = [subString substringToIndex:1];
//                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"\n"]) {
                    [returnArray addObject:headStr];
                    pEnd += headStr.length;
                    pStart = pEnd;
                    pEnd--;
                }
            }
        }

        pEnd++;
    }
    if (pStart != pEnd) {
        NSString *strPiece = [str substringFromIndex:pStart];
        [returnArray addObject:strPiece];
    }
    
    return returnArray;
}

+ (CGFloat)getMixedViewHeight:(NSString *)str withWidth:(CGFloat)width
{
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:NSLineBreakByCharWrapping];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, size.width, size.height);
    int lineCount = 0;
    for (int i = 0; i < [str length]; i++) {
        NSString *s = [str substringWithRange:NSMakeRange(i, 1)];
//        WeLog(@"s%@",s);
        if ([s isEqualToString:@"\n"]) {
            lineCount++;
        }
    }
    [self attachString:str toView:view];
    return view.frame.size.height;
}

+(void)checkVersion{


    RequestProxy * rp = [[RequestProxy alloc]init];
    rp.delegate = self;
    NSMutableDictionary *dic =[[NSMutableDictionary alloc]init];
    [dic setValue:@"0" forKey:KEY_TYPE];
    [rp sendDictionary:dic andURL:URL_USER_CHECK_VERSION andData:nil];
}

+ (BOOL)calLines:(NSString *)string withMaxCount:(int)maxCount{
    int count = 0;
    for (int i = 0; i < [string length]; i++) {
        if ([[string substringWithRange:NSMakeRange(i, 1)]isEqualToString:@"\n"] ||[[string substringWithRange:NSMakeRange(i, 1)]isEqualToString:@"\r"]) {
            count++;
            if (count > maxCount) {
                return NO;
            }
        }
        
    }
    return YES;
}


+ (void)emotionAttachString:(NSString *)str toView:(UIView *)targetView
{
    NSMutableArray *testarr= [Utility mycutMixedString:str];
    //    WeLog(@"testarr:%@",testarr);
    
    float maxWidth = targetView.frame.size.width+3;
    float x = 0;
    float y = 0;
    UIFont *font = [UIFont systemFontOfSize:18];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                            [targetView addSubview:btn];
                        }
                        x += subSize.width;
                    }else{
                        int index = 0;
                        while (x + [piece sizeWithFont:font].width > maxWidth) {
                            NSString *subString = [piece substringToIndex:index];
                            while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                                index++;
                                subString = [piece substringToIndex:index];
                            }
                            index--;
                            if (index <= 0) {
                                x = 0;
                                y += 22;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [subString sizeWithFont:font];
                            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(x, y, subSize.width, 22);
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle:subString forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                            if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                                [targetView addSubview:btn];
                            }
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += 22;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:piece forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                            [targetView addSubview:btn];
                        }
                        x += subSize.width;
                    }
                    
                }else{
                    if (x + 22 > maxWidth) {
                        x = 0;
                        y += 22;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, 22, 22);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    if (imgView.frame.origin.y+imgView.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:imgView];
                    }
                    x += 22;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += 22;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:btn];
                    }                    x += subSize.width;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += 22;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(x, y, subSize.width, 22);
                        btn.backgroundColor = [UIColor clearColor];
                        [btn setTitle:subString forState:UIControlStateNormal];
                        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        btn.userInteractionEnabled = NO;
                        if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                            [targetView addSubview:btn];
                        }                        x += subSize.width;
                        
                        if (index < piece.length-1) {
                            x = 0;
                            y += 22;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(x, y, subSize.width, 22);
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:piece forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btn.userInteractionEnabled = NO;
                    if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:btn];
                    }                    x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
    //    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + 22;
    //    targetView.frame = rect;
}

+ (UIButton *)createDotBtnAtX:(CGFloat) x Y:(CGFloat)y content:(NSString*)content fontSize:(CGFloat)fontSize {
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSString *piece = content;
    CGSize subSize = [piece sizeWithFont:font];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(x, y, subSize.width + 2, fontSize + 4);
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:piece forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:FONT_NAME_ARIAL size:fontSize]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return btn;
}

+(NSArray *) cutStringArr:(NSArray *)source fontSize:(CGFloat)size maxLenth:(CGFloat)maxlen {
        if(!source)
            return nil;
    float lenth=0;
    UIFont *font = [UIFont systemFontOfSize:size];
    int  count = [source count];
    NSMutableArray *lastObj=nil;
    int lastIndex = 0;
    float emotionSize = size + 4;
    for(int i=0; i < count; i++) {
        lastIndex = i;
        NSString *p = [source objectAtIndex:i];
        if([p hasPrefix:@"["] && [p hasSuffix:@"]"]) {
            if([Utility getImageName:p] == nil) {
                    CGSize subSize = [p sizeWithFont:font];
                    
                if(lenth + subSize.width > maxlen) {
                    int index = 0;
                    NSString * substring = [p substringFromIndex:index];
                    while (lenth + [substring sizeWithFont:font].width < maxlen) {
                        index++;
                        substring = [p substringFromIndex:index];
                    }
                    if(index > 2) {
                        substring = [p substringFromIndex:index - 2];
                        substring = [NSString stringWithFormat:@"%@...", substring];
                    }else {
                        if(i > 0) {
                            NSString *lastP = [source objectAtIndex:i - 1];
                            if([Utility getImageName:p] == nil) {
                                substring = [lastP substringToIndex:lastP.length + index - 3];
                            }else {
                                substring = @"...";
                            }
                            lastIndex = i - 1;
                        }else {
                            substring = @"...";
                        }
                    }
                    lastObj = [NSMutableArray arrayWithObject:substring];
                }
                lenth += subSize.width;
                 
            }else {
                    if(lenth + emotionSize > maxlen) {
                        CGSize subSize = [@"..." sizeWithFont:font];
                        NSString *substring = @"...";
                        if(lenth + subSize.width > maxlen) {
                            if(i > 0) {
                                NSString *lastP = [source objectAtIndex:i - 1];
                                if([Utility getImageName:lastP] == nil) {
                                     substring = [lastP substringToIndex:lastP.length - 3];
                                     substring = [NSString stringWithFormat:@"%@...", substring];
                                }else {
                                    lastIndex = i - 1;
                                }
                            }
                        }
                        lastObj = [NSMutableArray arrayWithObject:substring];
                    }
                    lenth += emotionSize;
            }
        }else {
            CGSize subSize = [p sizeWithFont:font];
            
            if( lenth + subSize.width > maxlen) {
                int index = 0;
                NSString * substring = [p substringToIndex:index];
                while (lenth + [substring sizeWithFont:font].width < maxlen) {
                    index++;
                    substring = [p substringToIndex:index];
                }
                if(index > 2) {
                    substring = [p substringToIndex:index - 2];
                    substring = [NSString stringWithFormat:@"%@...", substring];
                }else {
                    if(i > 0) {
                            NSString *lastP = [source objectAtIndex:i - 1];
                            if([Utility getImageName:lastP] == nil) {
                                    if(lastP.length > 3)
                                         substring = [lastP substringToIndex:lastP.length + index - 3];
                                    else{
                                        lastIndex = i - 1;
                                        substring = @"...";
                                    }
                            }else {
                                    substring = @"...";
                            }
                        }
                }
                lastObj = [NSMutableArray arrayWithObject:substring];
            }
            
            lenth += subSize.width;
        
        }
        if(lastObj) {
            NSMutableArray *ret = [[NSMutableArray alloc] initWithArray:[source subarrayWithRange:NSMakeRange(0, lastIndex)]];
            [ret addObject:[lastObj lastObject]];
            return (NSArray *)ret;
        }
        
    }
    return source;
}

+ (void)emotionAttachString:(NSString *)str toView:(UIView *)targetView font:(float)fontSize isCut:(BOOL)cutFlag
{
    NSMutableArray *testarr= nil;
    float maxWidth = targetView.frame.size.width;
  //  WeLog(@"testarr:%@",testarr);
    if(cutFlag) {
        testarr = [Utility mycutMixedString:str];
        testarr = (NSMutableArray *)[Utility cutStringArr:testarr fontSize:fontSize maxLenth:maxWidth];
    }else {
        [Utility emotionAttachString:str toView:targetView font:fontSize];
        return;
    }
    
    float x = 0;
    float y = 0;
    float btnSize = fontSize + 4;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [Utility createDotBtnAtX:x Y:y content:piece fontSize:fontSize];
                        if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                            [targetView addSubview:btn];
                        }
                        x += subSize.width;
                    
                }else{
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, btnSize, btnSize);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    if (imgView.frame.origin.y+imgView.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:imgView];
                    }
                    x += btnSize;
                }
                
            }else {
                //普通文字
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [Utility createDotBtnAtX:x Y:y content:piece fontSize:fontSize];
                    btn.userInteractionEnabled = NO;
                    if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:btn];
                    }
                    x += subSize.width;
            }
        }
    }
    CGRect rect = targetView.frame;
//    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + btnSize;
//    targetView.frame = rect;
}


+ (void)emotionAttachString:(NSString *)str toView:(UIView *)targetView font:(float)fontSize
{
    NSMutableArray *testarr= [Utility mycutMixedString:str];
    float maxWidth = targetView.frame.size.width;
    //  WeLog(@"testarr:%@",testarr);
    float x = 0;
    float y = 0;
    float btnSize = fontSize + 4;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    if (testarr) {
        for (int index = 0; index<[testarr count]; index++) {
            NSString *piece = [testarr objectAtIndex:index];
            if ([piece hasPrefix:@"["] && [piece hasSuffix:@"]"]){
                //表情
                if ([Utility getImageName:piece] == nil) {
                    if (x + [piece sizeWithFont:font].width <= maxWidth) {
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [Utility createDotBtnAtX:x Y:y content:piece fontSize:fontSize];
                        if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                            [targetView addSubview:btn];
                        }
                        x += subSize.width;
                    }else{
                        int index = 0;
                        while (x + [piece sizeWithFont:font].width > maxWidth) {
                            NSString *subString = [piece substringToIndex:index];
                            while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                                index++;
                                subString = [piece substringToIndex:index];
                            }
                            index--;
                            if (index <= 0) {
                                x = 0;
                                y += btnSize;
                                index = 0;
                                continue;
                            }else{
                                subString = [piece substringToIndex:index];
                            }
                            
                            CGSize subSize = [piece sizeWithFont:font];
                            UIButton *btn = [Utility createDotBtnAtX:x Y:y content:subString fontSize:fontSize];
                            if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                                [targetView addSubview:btn];
                            }
                            x += subSize.width;
                            
                            if (index < piece.length-1) {
                                x = 0;
                                y += btnSize;
                                piece = [piece substringFromIndex:index+1];
                                index = 0;
                            }
                        }
                        CGSize subSize = [piece sizeWithFont:font];
                        UIButton *btn = [Utility createDotBtnAtX:x Y:y content:piece fontSize:fontSize];
                        if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                            [targetView addSubview:btn];
                        }
                        x += subSize.width;
                    }
                    
                }else{
                    if (x + btnSize > maxWidth) {
                        x = 0;
                        y += btnSize;
                    }
                    UIImageView *imgView = [[UIImageView alloc] init];
                    imgView.frame = CGRectMake(x, y, btnSize, btnSize);
                    imgView.backgroundColor = [UIColor clearColor];
                    imgView.image = [UIImage imageNamed:[Utility getImageName:piece]];
                    if (imgView.frame.origin.y+imgView.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:imgView];
                    }
                    x += btnSize;
                }
                
            }else if ([piece isEqualToString:@"\n"]){
                //换行
                x = 0;
                y += btnSize;
            }else{
                //普通文字
                if (x + [piece sizeWithFont:font].width <= maxWidth) {
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [Utility createDotBtnAtX:x Y:y content:piece fontSize:fontSize];
                    if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:btn];
                    }                    x += subSize.width;
                }else{
                    int index = 0;
                    while (x + [piece sizeWithFont:font].width > maxWidth) {
                        NSString *subString = [piece substringToIndex:index];
                        while ((x + [subString sizeWithFont:font].width < maxWidth) && (index < piece.length)) {
                            index++;
                            subString = [piece substringToIndex:index];
                        }
                        index--;
                        if (index <= 0) {
                            x = 0;
                            y += btnSize;
                            index = 0;
                            continue;
                        }else{
                            subString = [piece substringToIndex:index];
                        }
                        
                        CGSize subSize = [subString sizeWithFont:font];
                        UIButton *btn = [Utility createDotBtnAtX:x Y:y content:subString fontSize:fontSize];
                        if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                            [targetView addSubview:btn];
                        }                        x += subSize.width;
                        
                        if (index <= piece.length-1) {
                            x = 0;
                            y += btnSize;
                            piece = [piece substringFromIndex:index];
                            index = 0;
                        }
                    }
                    CGSize subSize = [piece sizeWithFont:font];
                    UIButton *btn = [Utility createDotBtnAtX:x Y:y content:piece fontSize:fontSize];
                    if (btn.frame.origin.y+btn.frame.size.height < targetView.frame.size.height) {
                        [targetView addSubview:btn];
                    }   x += subSize.width;
                }
            }
        }
    }
    CGRect rect = targetView.frame;
    //    WeLog(@"old height:%f,new height:%f",rect.size.height,y+22);
    rect.size.height = y + btnSize;
    //    targetView.frame = rect;
}


+ (NSMutableArray *)mycutMixedString:(NSString *)str
{
//    WeLog(@"str to be cut:%@",str);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int pStart = 0;
    int pEnd = 0;
    
    while (pEnd < [str length]) {
        NSString *a = [str substringWithRange:NSMakeRange(pEnd, 1)];
        if ([a isEqualToString:@"["]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            NSRange range1 = [subString rangeOfString:@"["];
            NSRange range2 = [subString rangeOfString:@"]"];
            if (range2.location != NSNotFound && range2.location > range1.location) {
                NSString *strPiece = [subString substringToIndex:range2.location+1];
                [returnArray addObject:strPiece];
                pEnd += strPiece.length;
                pStart = pEnd;
                pEnd--;
            }
        }else if ([a isEqualToString:@"\n"]){
            if (pStart != pEnd) {
                NSString *strPiece = [str substringWithRange:NSMakeRange(pStart, pEnd-pStart)];
                [returnArray addObject:strPiece];
                pStart = pEnd;
            }
            
            NSString *subString = [str substringFromIndex:pEnd];
            if (subString.length >= 2) {
                NSString *headStr = [subString substringToIndex:1];
//                WeLog(@"headStr:%@",headStr);
                if ([headStr isEqualToString:@"\n"]) {
                    
                    [returnArray addObject:headStr];
                    pEnd += headStr.length;
                    pStart = pEnd;
                    pEnd--;
                }
            }
        }
        pEnd++;
    }
    if (pStart != pEnd) {
        NSString *strPiece = [str substringFromIndex:pStart];
        [returnArray addObject:strPiece];
    }
    
    return returnArray;
}

/*
 @method 分享时自动绑定账号
 @param shareType 分享的平台
 */
+ (void)addShareList:(int)shareType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (shareType == ShareTypeWeixiSession || shareType == ShareTypeWeixiTimeline) {
        return;
    }
    [ShareSDK getUserInfoWithType:shareType authOptions:nil result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
        NSString *keyStr = nil;
        switch (shareType) {
            case ShareTypeSinaWeibo:
                keyStr = [myConstants.shareTypeNames objectAtIndex:0];
                break;
            case ShareTypeTencentWeibo:
                keyStr = [myConstants.shareTypeNames objectAtIndex:1];
                break;
            case ShareTypeQQSpace:
                keyStr = [myConstants.shareTypeNames objectAtIndex:2];
                break;
            case ShareTypeRenren:
                keyStr = [myConstants.shareTypeNames objectAtIndex:3];
                break;
            case ShareTypeTwitter:
                keyStr = [myConstants.shareTypeNames objectAtIndex:4];
                break;
            case ShareTypeGooglePlus:
                keyStr = [myConstants.shareTypeNames objectAtIndex:5];
                break;
            case ShareTypeLinkedIn:
                keyStr = [myConstants.shareTypeNames objectAtIndex:6];
                break;
            case ShareTypeFacebook:
                keyStr = [myConstants.shareTypeNames objectAtIndex:7];
                break;
            default:
                break;
        }
        [userDefaults setObject:[userInfo nickname] forKey:keyStr];
        [userDefaults synchronize];
    }];
}

+ (int)emtionAanalyse:(NSString *)str{
    if ([str hasSuffix:@"]"]) {
        if ([str length]>=3) {
            for (int i = [str length]-3; i >= 0 ; i--) {
                if ([[str substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"["]) {
                    if ([myConstants.faceImageNames containsObject:[str substringFromIndex:i]]) {
                        WeLog(@"[所在的位置%d",i);
                        return i;
                    }
                }
            }
        }

    }
    return -1;
}
+ (void)checkDirs
{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [arr objectAtIndex:0];
    
    //检查image路径是否存在
    NSString *imageDir = [documentDir stringByAppendingPathComponent:@"image"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
        WeLog(@"imageDir:%@",imageDir);
    }
    //检查voice路径是否存在
    NSString *voiceDir = [documentDir stringByAppendingPathComponent:@"voice"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:voiceDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:voiceDir withIntermediateDirectories:YES attributes:nil error:nil];
        WeLog(@"imageDir:%@",voiceDir);
    }
    //检查movie路径是否存在
    NSString *movieDir = [documentDir stringByAppendingPathComponent:@"movie"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:movieDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:movieDir withIntermediateDirectories:YES attributes:nil error:nil];
        WeLog(@"imageDir:%@",movieDir);
    }
    
    //检查缓存目录
    NSString *cacheDirectory = [documentDir stringByAppendingPathComponent:@"cacheDir"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        WeLog(@"cacheDirectory:%@",cacheDirectory);
    }
    
}

+ (NSString *)getDirectorySize:(NSString *)path{
    NSFileManager *fm = [[NSFileManager alloc]init];
    NSDictionary *attDic = [fm attributesOfItemAtPath:path error:nil];
    return [attDic objectForKey:NSFileSize];
}

+ (NSString *)processClubName:(NSString *)clubName withWidth:(CGFloat)labelWidth  withHeight:(CGFloat)contentheight withFontSize:(CGFloat)fontSize{
    NSString *st = [NSString stringWithFormat:@"发于<%@>",clubName];
    UIFont *font = [UIFont fontWithName:FONT_NAME_ARIAL size:fontSize];
    CGSize size = [st sizeWithFont:font constrainedToSize:CGSizeMake(900, contentheight) lineBreakMode:UILineBreakModeTailTruncation];
    if (size.width > labelWidth) {
        for (int i = 0; i < [clubName length]; i++) {
            NSString *tmpSt = [NSString stringWithFormat:@"发于<%@...>",[clubName substringToIndex:i]];
            CGSize size1 = [tmpSt sizeWithFont:font constrainedToSize:CGSizeMake(900, contentheight) lineBreakMode:UILineBreakModeTailTruncation];
            if (size1.width >= labelWidth) {
                return [NSString stringWithFormat:@"%@...",[clubName substringToIndex:i-1]];
            }
        }
    }
    return clubName;
}
+ (NSString *)switchCategory:(NSString *)categoryStr{
    //将字符串转换为@"0011"的格式
    if (!categoryStr) {
        return @"0000";
    }
    NSMutableString *categoryToSend = [[NSMutableString alloc] init];
    for (int i = 0; i < (4-[categoryStr length]); i++) {
        [categoryToSend appendString:@"0"];
    }
    [categoryToSend appendString:categoryStr];
    return categoryToSend;
}

+ (int)minNum:(int)a andNum1:(int)b andNum2:(int)c{
    int tmp;
    if (a > b) {
        tmp = b;
    }else{
        tmp = a;
    }
    
    if (c > tmp) {
        return tmp;
    }else{
        return c;
    }
}

+ (void)removeSubViews:(UIView *)view{
    for (UIView *subView in [view subviews]) {
        [subView removeFromSuperview];
    }
    return;
}

+(NSString *)getDirectory{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [arr objectAtIndex:0];
    return documentDir;
}
+ (NSString *)urlSwitch:(NSString *)url{
    NSString *newurl;
    if (!myConstants.serverNO) {
        newurl = url;
    }else{
        newurl = [NSString stringWithFormat:@"%@1%@",[url substringToIndex:8],[url substringFromIndex:8]];
    }
    return newurl;
}

+ (NSString *)urlSwitchBack:(NSString *)url{
    NSString *newurl;
    if (!myConstants.serverNO) {
        newurl = url;
    }else{
        newurl = [NSString stringWithFormat:@"%@1%@",[url substringToIndex:8],[url substringFromIndex:9]];
    }
    return newurl;
}

+ (void)clearCacheAuto{
    NSDate *lastClearDate = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_CLEAR_CACHE_TIME];
    if (lastClearDate) {
        double timeInterval = [[NSDate date]timeIntervalSinceDate:lastClearDate];
        if (((int) timeInterval/(3600*24))>= KEY_AUTO_CLEAR_CACHE_DAYS) {
            [[SDImageCache sharedImageCache] clearDisk];
            [[SDImageCache sharedImageCache]clearMemory];
            [[EGOCache currentCache]clearCache];
        }
    }
    return;
}

+(NSArray *)getIndexPaths:(NSArray *)dataArray withTable:(UITableView *)table{
    int tableCount = [table numberOfRowsInSection:0];
    int count = dataArray.count - tableCount;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        [array addObject:[NSIndexPath indexPathForRow:tableCount+i inSection:0]];
    }
    return array;
}

@end
