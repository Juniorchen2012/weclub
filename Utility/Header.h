//
//  Header.h
//  WeClub
//
//  Created by chao_mit on 13-1-11.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#ifndef LBSCLUB_Header_h
#define LBSCLUB_Header_h
#define TINT_COLOR [UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225/255.0 alpha:1.0]
#define NAVIFONT_COLOR [UIColor colorWithRed:230.0/255.0 green:59.0/255.0 blue:28.0/255.0 alpha:1.0]
#define COLOR_BLACK [UIColor blackColor]
#define COLOR_WHITE [UIColor whiteColor]

#ifdef A
#define COLOR_RED   [UIColor redColor]
#define COLOR_GRAY  [UIColor lightGrayColor]
#define COLOR_BLUE   TINT_COLOR
#define COLOR_BROWN   [UIColor brownColor]
#define COLOR_TEST  lbl.textColor = COLOR_RED
#else
#define COLOR_RED   [UIColor clearColor]
#define COLOR_GRAY  [UIColor clearColor]
#define COLOR_BLUE  [UIColor clearColor]
#define COLOR_BROWN   [UIColor clearColor]
#define COLOR_TEST
#endif

#define TEST_COLOR [UIColor redColor]

#define FONT(fontSize)  [UIFont fontWithName:FONT_NAME_ARIAL size:fontSize]
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#if 1 // Set to 1 to enable debug logging
#define WeLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define WeLog(x, ...)
#endif

#define DeviceModel [[UIDevice currentDevice] model]
#define iosVersion [[[UIDevice currentDevice] systemVersion] intValue]

#define defaultLocation @"0.1,0.1"
#define TXTFIELDBG [UIImage imageNamed:@"txtFieldBg.png"]
#define BTNBG [UIImage imageNamed:@"btnbg.png"]
//#define BTNBG [UIImage imageNamed:(iosVersion == 7 ? @"":@"btnbg.png")]
#define RIGHT_BAR_ITEM_WIDTH 50
#define RIGHT_BAR_ITEM_HEIGHT 30
#define RIGHT_BAR_ITEM_FONT_SIZE 14


#pragma mark -
#pragma mark Color
#import "Constants.h"//常量字符串类
#import <QuartzCore/QuartzCore.h>//Layer层
#import "ASIHttpHeaders.h"//ASIHttpRequest网络库
#import "EGOImageView.h"//EGO图片查看库
#import "EGOImageButton.h"//EGO图片按钮库
#import "SDImageCache.h"
#import "JSONKit.h"//Json解析库
#import "EGOCache.h"//EGO图片缓存
#import "UIImageView+WebCache.h"//SDWebImageView库
#import "UIImageView+Addition.h"//图片查看扩展
#import "UIButton+WebCache.h"
#import "EGORefreshTableHeaderView.h"//下拉刷新
#import "UIScrollView+SVPullToRefresh.h"//SV下拉刷新
#import "UIScrollView+SVInfiniteScrolling.h"//SV无限加载
#import "MWPhotoBrowser.h"//MW图片查看库
#import "MMGridView.h"//GridView
#import <MediaPlayer/MediaPlayer.h>//视频库
#import <AVFoundation/AVFoundation.h>//音频类
#import "MBProgressHUD.h"//提示信息
#import "SVProgressHUD.h"//过程提示信息
#import "AccountUser.h"
#import "Constants.h"
#import "UIPlaceHolderTextView.h"//添加占位文本的UITextView
#import "Constant.h"
#import "DLCImagePickerController.h"//照片库
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>//位置
#import "SendRequest.h"
#import "RequestProxy.h"//发送请求
#import "ViewImage.h"
#import "MLScrollView.h"
#import "MLTableView.h"


typedef enum LIST_TYPE_ATICLE
{
	LIST_TYPE_ATICLE_BANMIAN = 0,
	LIST_TYPE_ATICLE_GOODARTICLE,
} LIST_TYPE_ATICLE;
typedef enum TAB_BAR
{
	CLUB_TAB = 0,
	ARTICLE_TAB,
	USER_TAB,
    SETTINGS_TAB
} TAB_BAR;

typedef enum CLUB_OP
{
	JOIN = 0,
	SHARE,
	FOLLOW,
    REPORT,
    POST
} CLUB_OP;

typedef enum LIST_TYPE
{
    LIST_TYPE_NEARBY = 0,
	LIST_TYPE_JOINED,
	LIST_TYPE_FOLLOWED,
	LIST_TYPE_CATOGRY,
    LIST_TYPE_MITBBSPAGE,
    LIST_TYPE_MITBBSCLUB
} LIST_TYPE;

typedef enum ARTICLE_STYLE
{
    ARTICLE_STYLE_WORDS = 0,
	ARTICLE_STYLE_PIC,
	ARTICLE_STYLE_AUDIO,
	ARTICLE_STYLE_VIDEO,
} ARTICLE_STYLE;

typedef enum USER_TYPE
{
    USER_TYPE_USER = 00,//普通用户
    USER_TYPE_ADMIN = 01,//版主
    USER_TYPE_VICE_ADMIN = 02,//副版
	USER_TYPE_MEMBER = 14,//俱乐部会员
	USER_TYPE_HONOR_MEMBER = 13 ,//荣誉会员
} USER_TYPE;

typedef enum CLUB_TYPE
{
    CLUB_TYPE_PUBLIC= 0,//公开
	CLUB_TYPE_PRIVATE,//私密
} CLUB_TYPE;

typedef enum FAILURE_TYPE
{
    FAILURE_TYPE_EXISTS= 1001
} FAILURE_TYPE;

typedef enum OPERATE_TYPE
{
    OPERATE_TYPE_ADD= 0,
    OPERATE_TYPE_DELETE
} OPERATE_TYPE;

typedef enum ARTICLE_LIST_TYPE
{
	ARTICLE_LIST_TYPE_I_POST = 1,
	ARTICLE_LIST_TYPE_I_REPLY,
    ARTICLE_LIST_TYPE_REPLY_ME,
} ARTICLE_LIST_TYPE;

//key words about Club
#define KEY_CLUB_ROW_KEY  @"clubrowkey"
#define KEY_USER_ROW_KEY  @"userrowkey"
#define KEY_FRIEND_CLUB_ROW_KEY  @"friendclubrowkey"
#define KEY_ID  @"clubId"
#define KEY_USER_ID  @"id"
#define KEY_NAME  @"name"
#define KEY_SEX  @"sex"
#define KEY_CLUB_NAME  @"clubname"
#define KEY_DESC  @"desc"
#define KEY_TYPE  @"type"
#define KEY_CATEGORY  @"category"
#define KEY_LOGO  @"logoURL"
#define KEY_POSITION  @"position"
#define KEY_DISTANCE  @"distance"
#define KEY_FOLLOW_THIS_CLUB  @"isfollow"
#define KEY_CREATOR  @"create"
#define KEY_CREATE_TIME  @"createTime"
#define KEY_LAST_ACTIVE_TIME  @"lastactiveTime"
#define KEY_QR  @"tdbc"
#define KEY_MEMBER_COUNT  @"memberNum"
#define KEY_FOLLOW_COUNT  @"followNum"
#define KEY_COLLECT_COUNT  @"collectCount"
#define KEY_SHARE_COUNT  @"shareNum"
#define KEY_TOPIC_COUNT  @"themeNum"
#define KEY_ARTICLE_COUNT  @"articleNum"
#define KEY_BROWSE_COUNT  @"viewNum"
#define KEY_STICKY_COUNT  @"stickyCount"
#define KEY_GOOD_ART_COUNT  @"goodArticleCount"
#define KEY_MAX_MEM_COUNT  @"maxMemberNUm"
#define KEY_STARLEVEL  @"clubrank"
#define KEY_HARDWORK_DEGREE  @"hardWorking"
#define KEY_ACTIVE_DEGREE  @"activity"
#define KEY_ADMIN  @"moderator"
#define KEY_VICE_ADMINS  @"vicemoderator"
#define KEY_FRIEND_CLUBS  @"friendClubs"
#define KEY_MEMBER_LIST  @"memberlist"
#define KEY_IS_REPLY_ARTICLE  @"isReplyArticle"
#define KEY_STATUS  @"status"
#define KEY_TOTAL  @"total"
#define KEY_FAILURES  @"failures"
#define KEY_MESSAGE  @"message"
#define KEY_DATA  @"data"
#define KEY_USER_TYPE  @"usertype"
#define KEY_RESULT  @"result"
#define KEY_FRIENDCLUB_NUM @"friendClubNum"
#define KEY_PIC_TIME @"picTime"
#define KEY_CLEAR_CACHE_TIME @"clearCacheTime"
#define KEY_AUTO_CLEAR_CACHE_DAYS 7
#define LOCATABLE @"LOCATABLE"


//JSON Key Word

//key words about TopicArticle
#define KEY_ARTICLE  @"article"
#define KEY_POST_TIME  @"postTime"
#define KEY_AUTHOR  @"author"
#define KEY_AVATAR  @"authorImage"
#define KEY_CONTENT  @"content"
#define KEY_REPLY_COUNT  @"replyNum"
#define KEY_MEDIA  @"attachment"
#define KEY_ARTICLE_STYLE  @"style"
#define KEY_SORT  @"sort"
#define KEY_BOARD  @"board"
#define KEY_STARTKEY  @"startKey"
#define KEY_END  @"end"
#define KEY_COUNT  @"count"
#define KEY_PAGESIZE  @"pagesize"
#define KEY_ARTICLE_ROW_KEY  @"articleRowkey"
#define KEY_ARTICLE_REPLY_ROW_KEY  @"replyRowkey"
#define KEY_ARTICLE_SUBJECT_ROW_KEY @"subjectRowkey"
#define KEY_ROW_KEY @"rowkey"
#define KEY_LOCATION  @"location"
#define KEY_READFLAG  @"readFlag"
#define KEY_MEMBER_TYPE  @"membertype"
#define KEY_ARTICLE_ISFOLLOW  @"isFollow"



#define COUNT_NUM  @"20"
#define KEY_PREFIX  @"prefix"
#define KEY_ATTACHMENT_INFO @"attachmentInfo"

//NOTIFICATION_NAME
#define NOTIFICATION_REFRESH_PIC @"refreshPicDownloaded"
#define NOTIFICATION_AUDIO_STOP @"AudioStop"

//POST_URLS


#define ITUNES_URL @"http://itunes.apple.com/hk/app/id350962117?mt=8"

#define URL_CLUB_LIST_SOMEONE_JOINED [NSString stringWithFormat:@"%@/%@/club/getUserJoindClublist",HOST,PHP]
#define URL_CLUB_LIST_SOMEONE_FOLLOWED [NSString stringWithFormat:@"%@/%@/club/getfollowList",HOST,PHP]
#define URL_CLUB_LIST_NEARBY [NSString stringWithFormat:@"%@/%@/club/searchNearbyClub",HOST,PHP]
#define URL_CLUB_LIST_JOINED [NSString stringWithFormat:@"%@/%@/club/getMyJoindClublist",HOST,PHP]
#define URL_CLUB_LIST_FOLLOWED [NSString stringWithFormat:@"%@/%@/club/memberfollowlist",HOST,PHP]
#define URL_CLUB_LIST_CLASSIFY [NSString stringWithFormat:@"%@/%@/club/searchByClassify",HOST,PHP]
#define URL_CLUB_LIST_ADOPT [NSString stringWithFormat:@"%@/%@/mitbbs/adoptlist",HOST,PHP]
#define URL_CLUB_LIST_BOARD [NSString stringWithFormat:@"%@/%@/mitbbs/boardlist",HOST,PHP]
#define URL_CLUB_LIST_MITBBS [NSString stringWithFormat:@"%@/%@/mitbbs/clublist",HOST,PHP]
#define URL_CLUB_SEARCH_BASEINFO_BY_NAME [NSString stringWithFormat:@"%@/%@/club/searchBaseByName",HOST,PHP]

#define URL_CLUB_ADOPT [NSString stringWithFormat:@"%@/%@/mitbbs/adopt",HOST,PHP]


#define URL_CLUB_JOIN [NSString stringWithFormat:@"%@/%@/club/memberadd",HOST,PHP]
#define URL_CLUB_QUIT [NSString stringWithFormat:@"%@/%@/club/memberQuit",HOST,PHP]
#define URL_CLUB_FOLLOW [NSString stringWithFormat:@"%@/%@/club/FollowClub",HOST,PHP]
#define URL_CLUB_UNFOLLOW [NSString stringWithFormat:@"%@/%@/club/unFollowClub",HOST,PHP]
#define URL_CLUB_REPORT [NSString stringWithFormat:@"%@/%@/user/report",HOST,PHP]
#define URL_CLUB_LOGIN [NSString stringWithFormat:@"%@/%@/user/login",HOST,PHP]
#define URL_CLUB_CREATE [NSString stringWithFormat:@"%@/%@/club/createclub",HOST,PHP]
#define URL_CLUB_CLOSE [NSString stringWithFormat:@"%@/%@/club/closeClub",HOST,PHP]
#define URL_CLUB_UPDATE_INFO [NSString stringWithFormat:@"%@/%@/club/updateInfo",HOST,PHP]
#define URL_CLUB_UPDATE_LOGO [NSString stringWithFormat:@"%@/%@/club/updateclubpic",HOST,PHP]
#define URL_CLUB_CHANGE_TO_PRIVATE [NSString stringWithFormat:@"%@/%@/club/changeToPrivate",HOST,PHP]
#define URL_CLUB_GET_ATTACHMENT [NSString stringWithFormat:@"%@/%@/club/getAttachment",HOST,PHP]
#define URL_CLUB_GET_DISPLAY_WINDOW [NSString stringWithFormat:@"%@/%@/club/checkWindows",HOST,PHP]
#define URL_CLUB_GET_BASICINFO [NSString stringWithFormat:@"%@/%@/club/searchBaseById",HOST,PHP]
#define URL_CLUB_GET_ADMINS [NSString stringWithFormat:@"%@/%@/club/searchModeratorById",HOST,PHP]
#define URL_CLUB_GET_MEMBER_LIST [NSString stringWithFormat:@"%@/%@/club/getMemberList",HOST,PHP]
#define URL_CLUB_SEARCH_MEMBER_LIST [NSString stringWithFormat:@"%@/%@/club/userNameSmartTips",HOST,PHP]
#define URL_USER_CLUBINVITE_LIST [NSString stringWithFormat:@"%@/%@/club/memberinvitelist",HOST,PHP]
#define URL_USER_CLUBINVITE_OPERATE [NSString stringWithFormat:@"%@/%@/club/memberInvite",HOST,PHP]

#define URL_CLUB_GET_FOLLOWER_LIST [NSString stringWithFormat:@"%@/%@/club/followMemberList",HOST,PHP]
#define URL_CLUB_GET_QR [NSString stringWithFormat:@"%@/%@/club/checktdbc",HOST,PHP]
#define URL_CLUB_GET_FRIENTCLUB [NSString stringWithFormat:@"%@/%@/club/searchFriendClub",HOST,PHP]
#define URL_CLUB_ADD_DISPLAY_WINDOW [NSString stringWithFormat:@"%@/%@/club/addWindows",PIC_HOST,PHP]
#define URL_CLUB_FRIENTCLUB_DELETE [NSString stringWithFormat:@"%@/%@/club/cancelFriendClub",HOST,PHP]
#define URL_CLUB_FRIENTCLUB_ADD [NSString stringWithFormat:@"%@/%@/club/addFriendClub",HOST,PHP]
#define URL_CLUB_CHANGE_NUMBER [NSString stringWithFormat:@"%@/%@/club/changeNumber",HOST,PHP]
#define URL_CLUB_DELETE_WINDOWS [NSString stringWithFormat:@"%@/%@/club/deleteWindows",HOST,PHP]
#define URL_CLUB_SEARCH_BY_NAME [NSString stringWithFormat:@"%@/%@/club/searchByName",HOST,PHP]
#define URL_CLUB_ATTACHMENT_DELETE [NSString stringWithFormat:@"%@/%@/club/deleteAttachment",HOST,PHP]
#define URL_CLUB_MEMBER_INVITE [NSString stringWithFormat:@"%@/%@/club/invite",HOST,PHP]
#define URL_CLUB_MEMBER_REMOVE [NSString stringWithFormat:@"%@/%@/club/removemember",HOST,PHP]
#define URL_CLUB_MEMBER_UPDATE_TYPE [NSString stringWithFormat:@"%@/%@/club/updateMemType",HOST,PHP]
#define URL_CLUB_APPLY_PROCESS [NSString stringWithFormat:@"%@/%@/club/rufuseOrAgreeUserApply",HOST,PHP]
#define URL_CLUB_APPLY_MEMBER_LIST [NSString stringWithFormat:@"%@/%@/club/applymemberList",HOST,PHP]
#define URL_CLUB_REPORT_HANDLE [NSString stringWithFormat:@"%@/%@/user/handleReport",HOST,PHP]
#define URL_USER_GET_MONEY [NSString stringWithFormat:@"%@/%@/user/getMoney",HOST,PHP]
#define URL_CLUB_HONOR_MEMBER_LIST [NSString stringWithFormat:@"%@/%@/club/searchHonoraryMember",HOST,PHP]
#define URL_CLUB_SHARE [NSString stringWithFormat:@"%@/%@/user/share",HOST,PHP]

#define URL_USER_CHANGE_PASSWD_EMAIL [NSString stringWithFormat:@"%@/%@/user/changeEmailPass",HOST,PHP]
#define URL_CLUB_LIST_SOMEONE_JOINED [NSString stringWithFormat:@"%@/%@/club/getUserJoindClublist",HOST,PHP]
#define URL_USER_FORGET_PASS [NSString stringWithFormat:@"%@/%@/user/forgetMail",HOST,PHP]
#define URL_USER_RESET_PASS [NSString stringWithFormat:@"%@/%@/user/emailChangePass",HOST,PHP]

#define URL_CLUB_ARTICLE_LIST [NSString stringWithFormat:@"%@/%@/article/subjectList",HOST,PHP]
#define URL_CLUB_ARTICLE_ONTOP_LIST [NSString stringWithFormat:@"%@/%@/article/ontopSubjectList",HOST,PHP]
#define URL_CLUB_GOODARTICLE_LIST [NSString stringWithFormat:@"%@/%@/article/digestsubjectList",HOST,PHP]
#define URL_CLUB_REPLYARTICLE_LIST [NSString stringWithFormat:@"%@/%@/article/articleList",HOST,PHP]
#define URL_CLUB_DIGEST_REPLYARTICLE_LIST [NSString stringWithFormat:@"%@/%@/article/digestArticleList",HOST,PHP]


#define URL_CLUB_ARTICLE_POST [NSString stringWithFormat:@"%@/%@/article/post",HOST,PHP]
#define URL_CLUB_REPORT_LIST [NSString stringWithFormat:@"%@/%@/user/reportList",HOST,PHP]
#define URL_ARTICLE_ATME_LIST [NSString stringWithFormat:@"%@/%@/article/atmelist",HOST,PHP]
#define URL_ARTICLE_LIST [NSString stringWithFormat:@"%@/%@/article/myArticle",HOST,PHP]
#define URL_ARTICLE_NEARBY_LIST [NSString stringWithFormat:@"%@/%@/article/nearbyArticleList",HOST,PHP]
#define URL_ARTICLE_FOLLOW_LIST [NSString stringWithFormat:@"%@/%@/article/followList",HOST,PHP]

#define URL_ARTICLE_TOPIC_SEARCH [NSString stringWithFormat:@"%@/%@/article/search",HOST,PHP]
#define URL_ARTICLE_TOPIC_LIST [NSString stringWithFormat:@"%@/%@/article/topicList",HOST,PHP]
#define URL_ARTICLE_GOOD [NSString stringWithFormat:@"%@/%@/article/digest",HOST,PHP]
#define URL_ARTICLE_REPORT [NSString stringWithFormat:@"%@/%@/user/getExprience",HOST,PHP]

#define URL_REPORT_DEL [NSString stringWithFormat:@"%@/%@/user/delReport",HOST,PHP]

#define URL_ARTICLE_DELETE [NSString stringWithFormat:@"%@/%@/article/delete",HOST,PHP]
#define URL_ARTICLE_FIX_DELETE [NSString stringWithFormat:@"%@/%@/article/fixdelete",HOST,PHP]
#define URL_ARTICLE_ONTOP [NSString stringWithFormat:@"%@/%@/article/ontop",HOST,PHP]
#define URL_ARTICLE_FOLLOW [NSString stringWithFormat:@"%@/%@/article/follow",HOST,PHP]
#define URL_ARTICLE_VIEW [NSString stringWithFormat:@"%@/%@/article/viewArticle",HOST,PHP]

#define URL_USER_CHECK_USERTYPE [NSString stringWithFormat:@"%@/%@/club/useridentityjudge",HOST,PHP]
#define CHECKCODE_IMG_URL [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/article/captcha?t=%d",HOST,PHP,arc4random()]]

#define URL_USER_CHECK_VERSION [NSString stringWithFormat:@"%@/%@/system/checkVersion",HOST,PHP]


#define DURATION @"duration"
#define FONT_NAME_ARIAL_BOLD  @"Arial-BoldMT"
#define FONT_NAME_ARIAL  @"Arial"
Constants *myConstants;
AccountUser *myAccountUser;
ASIFormDataRequest *asiRequest;

#define ATTACHTIME_LENGTH_LBL_COLOR [UIColor grayColor]
#define TYPE_RAW  @"raw"
#define TYPE_THUMB  @"thumb"
#define TYPE_ATTACH_PICTURE  @"p"
#define TYPE_ATTACH_AUDIO  @"a"
#define TYPE_ATTACH_VIDEO  @"v"

//头像占位 俱乐部版标占位 附件占位 大图占位
//#define ATTACHMENT_PIC_HOLDER  @"mediaImgPlaceHolder"
#define ATTACHMENT_PIC_HOLDER  @"thumbPlaceHolder"
#define ATTACHMENT_PIC_HOLDER_BIG @"thumbPlaceHolderBig"
#define VIDEO_PIC_HOLDER  @"videoPlaceHoder1"
#define LOGO_PIC_HOLDER  @"club_holder.png"
#define AVATAR_PIC_HOLDER  @"male_holder.png"
#define ICON_SEARCH  @"searchBtn.png"
#define VIDEO_PLAY_ICON @"video_offline_play.png"
#define IMAGE_SORT @"sort.png"

//chat_video_play.png

#define USER_HEAD_IMG_URL_TIME(type,picid,time) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/user/userHead?type=%@&picid=%@&pictime=%@",PIC_HOST,PHP,type,picid,time]]
#define USER_HEAD_IMG_URL(type,picid) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/user/userHead?type=%@&picid=%@",PIC_HOST,PHP,type,picid]]
#define URL(string) [NSURL URLWithString:string]
#define CLUB_LOGO(imageView,id,picTime) [imageView setImageWithURL:CLUB_LOGO_URL(id,TYPE_THUMB,picTime) placeholderImage:[UIImage imageNamed:LOGO_PIC_HOLDER]];
#define CLUB_LOGO_URL(id,type,picTime) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/club/file?name=%@0_p&type=%@&t=%@",PIC_HOST,PHP,id,type,picTime]]
#define CLUB_LOGO_URL_STRING(id,type,picTime) [NSString stringWithFormat:@"%@/%@/club/file?name=%@0_p&type=%@&t=%@",PIC_HOST,PHP,id,type,picTime]

#define DigestImageURL(filename,type) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/article/file?name=%@&type=%@&isdigest=1",PIC_HOST,PHP,filename,type]]

#define ClubImageURL(filename,type) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/club/file?name=%@&type=%@",PIC_HOST,PHP,filename,type]]
#define PersonImageURL(filename,type) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/club/file?name=%@&type=%@",PIC_HOST,PHP,filename,type]]
#define ArticleImageURL(filename,type) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/article/file?name=%@&type=%@",PIC_HOST,PHP,filename,type]]
#define DigestImageURL(filename,type) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/article/file?name=%@&type=%@&isdigest=1",PIC_HOST,PHP,filename,type]]

#endif
