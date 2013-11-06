//
//  Constant.h
//  Chat
//
//  Created by Archer on 13-1-16.
//  Copyright (c) 2013年 Archer. All rights reserved.
//


#define MQTTPort 1883
#define MQTTTopicHead @"weclub"
#define MQTTUserName @"weclub_mosquitto"
#define MQTTPassWord @"go2weclub"

//MixedCoding
#define MIXEDCODING_STATE           @"state"
#define MIXEDCODING_STATE_MISSING   1
#define MIXEDCODING_STATE_TEXT      2
#define MIXEDCODING_STATE_TEXTDATA  3
#define JSONSTRING                  @" jsonString"
#define FILEDATA                    @"fileData"

//json key
#define MSG_KEY_TYPE      @"m"
#define MSG_KEY_DATE      @"d"
#define MSG_KEY_CONTENT   @"c"
#define MSG_KEY_FROM      @"f"
#define MSG_KEY_TO        @"t"
#define MSG_KEY_URL       @"u"
#define MSG_KEY_ORI       @"o"
#define MSG_KEY_LENGTH    @"l"
#define MSG_KEY_LATITUDE  @"la"
#define MSG_KEY_LONGITUDE @"lo"
#define MSG_KEY_PHONE     @"p"
#define MSG_KEY_SESSIONID @"sid"

//消息类型
#define TYPE_TEXT         0
#define TYPE_PIC          1
#define TYPE_VOICE        2
#define TYPE_VIDEO        3
#define TYPE_LOC          4
#define TYPE_SYSTEM       5

#define HIDEKEYBOARD    @"hideKeyBoard"
#define PUSHVIEW        @"pushViewController"

#define THUMBWIDTH       100
#define THUMBHEIGHT      100

#define LOC_LATITUDE         @"latitude"
#define LOC_LONGITUDE        @"longitude"
#define LOC_DISCRIPTION      @"Discription"

//发送request请求的参数
#define REQUEST_MSGKEY_TYPE         @"type"
#define REQUEST_MSGKEY_ID           @"id"
#define REQUEST_MSGKEY_PASSWORD     @"pass"
#define REQUEST_MSGKEY_NUMBERID     @"numberid"
#define REQUEST_MSGKEY_TOTAL        @"total"
#define REQUEST_MSGKEY_LAST         @"last"
#define REQUEST_MSGKEY_MSG          @"msg"
#define REQUEST_MSGKEY_FLAG         @"flag"
#define REQUEST_MSGKEY_LOCATION         @"location"
#define REQUEST_MSGKEY_PAGESIZE         @"pagesize"
#define REQUEST_MSGKEY_STARTKEY         @"startKey"

//request入口URL

#define LOCAL 2

#ifdef SERVER1
#define HOST @"http://a1.weclub.cc"
#define PIC_HOST @"http://p1.weclub.cc"
#define REQUEST_HOST @"http://a1.weclub.cc"
#define UPLOADSERVER @"http://p1.weclub.cc/chat/fileService.php"
#define MQTTHost @"m.weclub.cc"
#elif SERVER
#define HOST @"http://a.weclub.cc"
#define PIC_HOST @"http://p.weclub.cc"
#define REQUEST_HOST @"http://a.weclub.cc"
#define UPLOADSERVER @"http://p.weclub.cc/chat/fileService.php"
#define MQTTHost @"m.weclub.cc"
#elif LOCAL
#define HOST @"http://192.168.1.102"
#define PIC_HOST @"http://192.168.1.102"
#define REQUEST_HOST @"http://192.168.1.102"
#define UPLOADSERVER @"http://192.168.1.102/chat/fileService.php"
#define MQTTHost @"192.168.1.123"
#endif

#define PHP @"club/weclub.php"
#define REQUEST_PATH @"club/weclub.php"
#define REQUEST_URL_GETCOOKIE  [NSString stringWithFormat:@"%@/%@/user/getCookie",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_LOGIN      [NSString stringWithFormat:@"%@/%@/user/login",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_CHECKISLOGIN      [NSString stringWithFormat:@"%@/%@/user/islogin",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_IFOLLOW    [NSString stringWithFormat:@"%@/%@/user/iFollow",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_FOLLOWME   [NSString stringWithFormat:@"%@/%@/user/followMe",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_BLACKLIST  [NSString stringWithFormat:@"%@/%@/user/blacklist",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_USERINFO   [NSString stringWithFormat:@"%@/%@/user/getUserInfoById",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_USERATTINFO   [NSString stringWithFormat:@"%@/%@/user/getUserAttInfo",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_SCANINFO   [NSString stringWithFormat:@"%@/%@/user/getInfoById",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_USERARTICLE  [NSString stringWithFormat:@"%@/%@/article/userArticle",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_FOLLOWPERSON [NSString stringWithFormat:@"%@/%@/user/followPerson",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_CANCELFOLLOWPERSON  [NSString stringWithFormat:@"%@/%@/user/cancelFollowPerson",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_BLACKADD   [NSString stringWithFormat:@"%@/%@/user/blackadd",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_BLACKCANCEL  [NSString stringWithFormat:@"%@/%@/user/blackcancel",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_REPORTPERSON [NSString stringWithFormat:@"%@/%@/user/report",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_ARTICLEFILE  [NSString stringWithFormat:@"%@/%@/article/file?",REQUEST_HOST,REQUEST_PATH]

#define REQUEST_URL_ADDWINDOW    [NSString stringWithFormat:@"%@/%@/user/addwindow",PIC_HOST,REQUEST_PATH]

#define REQUEST_URL_DELWINDOW    [NSString stringWithFormat:@"%@/%@/user/deluserwindow",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_CHANGEMAININFO   [NSString stringWithFormat:@"%@/%@/user/changemaininfo",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_UPUSERPHOTO  [NSString stringWithFormat:@"%@/%@/user/upuserphoto",PIC_HOST,REQUEST_PATH]
#define REQUEST_URL_PRIVACYSETTING  [NSString stringWithFormat:@"%@/%@/user/privacysetting",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_LOGOUT   [NSString stringWithFormat:@"%@/%@/user/logout",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_GETINFORM   [NSString stringWithFormat:@"%@/%@/user/readnotice",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_PRIVATE_LETTER   [NSString stringWithFormat:@"%@/%@/user/private_letter",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_PUBLIC_SETTING   [NSString stringWithFormat:@"%@/%@/user/public_setting",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_REGISTER    [NSString stringWithFormat:@"%@/%@/user/userregister",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_IMPORTFRIEND   [NSString stringWithFormat:@"%@/%@/mitbbs/mitbbsFriendsList",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_FOLLOWPERSONS   [NSString stringWithFormat:@"%@/%@/mitbbs/importFriends",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_CLEARNOTICE   [NSString stringWithFormat:@"%@/%@/user/clearNotice",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_SEARCHUSER   [NSString stringWithFormat:@"%@/%@/user/searchUser",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_CHANGEPASSEMAIL  [NSString stringWithFormat:@"%@/%@/user/changeemailpass",REQUEST_HOST,REQUEST_PATH]
#define REQUEST_URL_GETUSERINFOBYLOCATION  [NSString stringWithFormat:@"%@/%@/user/getUserInfoByLocation",REQUEST_HOST,REQUEST_PATH]

//request type
#define REQUEST_TYPE_GETCOOKIES   @"getcookies"
#define REQUEST_TYPE_LOGIN        @"login"
#define REQUEST_TYPE_CHECKISLOGIN @"checkislogin"
#define REQUEST_TYPE_REGISTER     @"register"
#define REQUEST_TYPE_IFOLLOW      @"ifollow"
#define REQUEST_TYPE_FOLLOWME     @"followme"
#define REQUEST_TYPE_BLACKLIST    @"blacklist"
#define REQUEST_TYPE_USERINFO     @"userinfo"
#define REQUEST_TYPE_USERATTINFO  @"userattinfo"
#define REQUEST_TYPE_USERARTICLE    @"userarticle"
#define REQUEST_TYPE_FOLLOWPERSON   @"followperson"
#define REQUEST_TYPE_CANCELFOLLOWPERSON   @"cancelfollowperson"
#define REQUEST_TYPE_BLACKADD     @"blackadd"
#define REQUEST_TYPE_BLACKCANCEL  @"blackcancel"
#define REQUEST_TYPE_REPORTPERSON @"reportperson"
#define REQUEST_TYPE_ARTICLEFILE  @"articlefile"
#define REQUEST_TYPE_CHANGEMAININFO  @"changemaininfo"
#define REQUEST_TYPE_UPUSERPHOTO  @"upuserphoto"
#define REQUEST_TYPE_PRIVACYSETTING  @"privacysetting"
#define REQUEST_TYPE_LOGOUT       @"logout"
#define REQUEST_TYPE_INFORM       @"inform"
#define REQUEST_TYPE_PRIVATE_LETTER  @"private_letter"
#define REQUEST_TYPE_PUBLIC_SETTING  @"public_setting"
#define REQUEST_TYPE_IMPORT_FRIEND   @"import_friend"
#define REQUEST_TYPE_FOLLOWPERSONS    @"follow_persons"
#define REQUEST_TYPE_CLEAR_NOTICE   @"clear_notice"
#define REQUEST_TYPE_SEARCH_USER    @"search_user"
#define REQUEST_TYPE_CHANGEPASSEMAIL  @"changePassEmail"
#define REQUEST_TYPE_GETUSERINFOBYLOCATION  @"getUserInfoByLocation"
#define REQUEST_TYPE_SCANINFO     @"scanInfo"

//notification key
#define NOTIFICATION_KEY_USERLIST      @"user_list"
#define NOTIFICATION_KEY_ADDFRIEND     @"addfriend"
#define NOTIFICATION_KEY_INFOMENU      @"infomenu"
#define NOTIFICATION_KEY_INFORMPUSH    @"informpush"
#define NOTIFICATION_KEY_FOLLOWLIST    @"followlist"
#define NOTIFICATION_KEY_UPDATENOTICE  @"updatenotice"
#define NOTIFICATION_KEY_NOTICECENTER  @"noticecenter"
#define NOTIFICATION_KEY_SHOW_LIST     @"showlist"
#define NOTIFICATION_KEY_LOGOUT        @"logout"
#define NOTIFICATION_KEY_DISTORYMQTTCONNECT @"distoryMQTTconnect"
#define NOTIFICATION_KEY_CONNECTMQTT   @"connectMQTT"
#define NOTIFICATION_KEY_DICCONNECT_MQTT @"disconnectMQTT"
#define NOTIFICATION_KEY_CHECKUNREAD   @"checkunread"
#define NOTIFICATION_KEY_JOINCLUBLIST  @"join_club_list"
#define NOTIFICATION_KEY_MENTIONME     @"atricle_mentionme_list"
#define NOTIFICATION_KEY_ATTENTIONLIST @"attention_user_list"
#define NOTIFICATION_KEY_AUDIOPLAY_STOPALLARTICLEAUDIO      @"stop_all_article_audio"
#define NOTIFICATION_KEY_AUDIOPLAY_STOPALLAUSERINFOAUDIO    @"stop_all_userinfo_audio"
#define NOTIFICATION_KEY_STOPCHAT      @"stop_chat"
#define NOTIFICATION_KEY_PLAYNEWVOICE     @"play_new_voice"
#define NOTIFICATION_KEY_PLAYEDVOICE     @"played_voice"
#define NOTIFICATION_KEY_STOPVOICE     @"stop_voice"
#define NOTIFICATION_KEY_SEND_TEXT     @"send_text"
#define NOTIFICATION_KEY_MQTT_CONNECT_STATE_CHANGE @"MQTT_connect_state_change"
#define NOTIFICATION_KEY_DESTROY_MQTT  @"Destroy_MQTT"

#define USER_WINDOW_PIC_URL(filename,type) [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/user/getuserwidnowpic?fileid=%@&type=%@",HOST,PHP,filename,type]]
#define USER_WINDOW_PIC_PATH(filename,type) [NSString stringWithFormat:@"%@/%@/user/getuserwidnowpic?fileid=%@&type=%@",HOST,PHP,filename,type]
#define CREATE_TDCSTRING(type,id) [NSString stringWithFormat:@"%@/%@/mitbbs/info?type=%@&id=%@",REQUEST_HOST,REQUEST_PATH,type,id]
#define USER_HEAD_IMG_PATH(type,picid) [NSString stringWithFormat:@"%@/%@/user/userHead?type=%@&picid=%@",REQUEST_HOST,REQUEST_PATH,type,picid]
#define USER_HEAD_IMG_PATH_TIME(type,picid,time) [NSString stringWithFormat:@"%@/%@/user/userHead?type=%@&picid=%@&pictime",REQUEST_HOST,REQUEST_PATH,type,picid,time]
