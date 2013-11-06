//
//  Constants.m
//  WeClub
//
//  Created by chao_mit on 13-1-26.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "Constants.h"

@implementation Constants
@synthesize urls,pics,clubNames,content,replyArticleContent,userAvatars,userNames,listTypeNames,postStyleNames,itemNames,articleLists,clubOperateNames,article_media_pics, clubCategory,screenHeight,userTypeNames,clubTypeNames,faceImageNames,userListArray,articleListNames,settingArr1,settingArr2,settingArr3,settingArr4,chatSettingArr,talkArea,shareTypeNames,reportTypeNames,mitBBSDic,mitbbsCategory,serverNO,BARHEIGHT;
static Constants *constants = nil;
+(Constants *)getSingleton{
    @synchronized (self){//为了确保多线程情况下，仍然确保实体的唯一性
        
        if (!constants) {
            
            [[self alloc] init];//非ARC模式下,该方法会调用 allocWithZone
            
        }
        return constants;
    }
}

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        
        if (!constants) {
            
            constants = [super allocWithZone:zone]; //确保使用同一块内存地址
            
            return constants;
            
        }
        
        return nil;
    }
}

- (id)init;
{
    @synchronized(self) {
        
        if (self = [super init]){
            self.listTypeNames =[NSArray arrayWithObjects:@"附近的俱乐部",@"我加入的俱乐部",@"我关注的俱乐部",@"俱乐部分类",@"mitbbs版面",@"mitbbs俱乐部", @"创建俱乐部",nil];
            self.articleListNames = [NSArray arrayWithObjects:@"附近的文章",@"我发表的文章",@"我回复的文章",@"我被回复的文章",@"我收藏的文章",@"提到我的文章",@"加入俱乐部文章",@"关注俱乐部文章",@"关注用户文章",nil];
            self.postStyleNames = [NSArray arrayWithObjects:@"发文章",@"发图",@"发音频",@"发视频", nil];
            self.itemNames = [NSArray arrayWithObjects:@"接受站内短信",@"关联帐号",@"手机通讯录匹配",@"隐私设置",@"系统通知",@"帮助与反馈", nil];
            self.articleLists = [[NSMutableArray alloc]init];
            self.clubOperateNames = [NSArray arrayWithObjects:@"加入",@"分享",@"关注",@"举报",@"发文",nil];
            self.clubCategory = [NSArray arrayWithObjects:@"爱好",@"情感",@"体育",@"娱乐",@"女性",@"购物",@"生活",@"旅游",@"科技",@"财经",@"音乐",@"文学",@"艺术",@"校友",@"同乡",@"其它",nil];
            self.mitbbsCategory = [NSArray arrayWithObjects:@"爱好",@"情感",@"体育",@"娱乐",@"女性",@"游戏",@"生活",@"科技",@"财经",@"音乐",@"文学",@"艺术",@"校友",@"同乡",@"其它",nil];
            self.talkArea = [NSArray arrayWithObjects:@"新闻中心",@"海外生活",@"华人世界",@"体育健身",@"娱乐休闲",@"情感杂想",@"文学艺术",@"校友联谊",@"乡里乡情",@"电脑网络",@"学术学科",@"本站系统",nil];
            self.mitBBSDic = [[NSMutableDictionary alloc]init];
            [mitBBSDic setValue:@"1" forKey:@"爱好"];
            [mitBBSDic setValue:@"2" forKey:@"情感"];
            [mitBBSDic setValue:@"3" forKey:@"体育"];
            [mitBBSDic setValue:@"4" forKey:@"娱乐"];
            [mitBBSDic setValue:@"5" forKey:@"女性"];
            [mitBBSDic setValue:@"6" forKey:@"购物"];
            [mitBBSDic setValue:@"7" forKey:@"生活"];
            [mitBBSDic setValue:@"8" forKey:@"旅游"];
            [mitBBSDic setValue:@"6" forKey:@"游戏"];
            [mitBBSDic setValue:@"9" forKey:@"科技"];
            [mitBBSDic setValue:@"10" forKey:@"财经"];
            [mitBBSDic setValue:@"11" forKey:@"音乐"];
            [mitBBSDic setValue:@"12" forKey:@"文学"];
            [mitBBSDic setValue:@"13" forKey:@"艺术"];
            [mitBBSDic setValue:@"14" forKey:@"校友"];
            [mitBBSDic setValue:@"15"forKey:@"同乡"];
            [mitBBSDic setValue:@"16" forKey:@"其它"];
            
            [mitBBSDic setValue:@"1" forKey:@"新闻中心"];
            [mitBBSDic setValue:@"2" forKey:@"海外生活"];
            [mitBBSDic setValue:@"3" forKey:@"华人世界"];
            [mitBBSDic setValue:@"4" forKey:@"体育健身"];
            [mitBBSDic setValue:@"5" forKey:@"娱乐休闲"];
            [mitBBSDic setValue:@"6" forKey:@"情感杂想"];
            [mitBBSDic setValue:@"7" forKey:@"文学艺术"];
            [mitBBSDic setValue:@"8" forKey:@"校友联谊"];
            [mitBBSDic setValue:@"9" forKey:@"乡里乡情"];
            [mitBBSDic setValue:@"10" forKey:@"电脑网络"];
            [mitBBSDic setValue:@"11" forKey:@"学术学科"];
            [mitBBSDic setValue:@"13" forKey:@"本站系统"];

            self.userTypeNames = [NSArray arrayWithObjects:@"普通用户",@"版主",@"版副",@"俱乐部会员",@"荣誉会员",nil];
            self.clubTypeNames = [NSArray arrayWithObjects:@"公开俱乐部",@"私密俱乐部",nil];
            if (iPhone5) {
                self.screenHeight = 568;
            }else{
                self.screenHeight = 480;
            }
            self.shareTypeNames = [NSArray arrayWithObjects:@"ShareTypeSinaWeibo",@"ShareTypeTencentWeibo",@"ShareTypeQQSpace",@"ShareTypeRenren",@"ShareTypeTwitter",@"ShareTypeGooglePlus", @"ShareTypeLinkedIn",@"ShareTypeFacebook",nil];
            self.faceImageNames = [NSArray arrayWithObjects:@"[嘻嘻]",@"[哈哈]",@"[喜欢]",@"[晕]",@"[泪]",@"[馋嘴]",@"[抓狂]",@"[哼]",@"[可爱]",@"[怒]",@"[汗]",@"[微笑]",@"[睡觉]",@"[钱]",@"[偷笑]",@"[酷]",@"[衰]",@"[吃惊]",@"[怒骂]",@"[鄙视]",@"[挖鼻屎]",@"[色]",@"[鼓掌]",@"[悲伤]",@"[思考]",@"[生病]",@"[亲亲]",@"[抱抱]",@"[白眼]",@"[右哼哼]",@"[左哼哼]",@"[嘘]",@"[委屈]",@"[哈欠]",@"[敲打]",@"[疑问]",@"[挤眼]",@"[害羞]",@"[快哭了]",@"[拜拜]",@"[黑线]",@"[强]",@"[弱]",@"[给力]",@"[浮云]",@"[围观]",@"[威武]",@"[相机]",@"[汽车]",@"[飞机]",@"[爱心]",@"[奥特曼]",@"[兔子]",@"[熊猫]",@"[不要]",@"[ok]",@"[赞]",@"[勾引]",@"[耶]",@"[爱你]",@"[拳头]",@"[差劲]",@"[握手]",@"[玫瑰]",@"[心]",@"[伤心]",@"[猪头]",@"[咖啡]",@"[麦克风]",@"[月亮]",@"[太阳]",@"[啤酒]",@"[萌]",@"[礼物]",@"[互粉]",@"[钟]",@"[自行车]",@"[蛋糕]",@"[围巾]",@"[手套]",@"[雪花]",@"[雪人]",@"[帽子]",@"[树叶]",@"[足球]", nil];
//            if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hant"]||[[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"zh-Hans"]) {
//
//            }else{
//
//            self.faceImageNames = [NSArray arrayWithObjects:@"[hee hee]",@"[lol]",@"[nice]",@"[dizzy]",@"[cry]",@"[greedy]",@"[crazy]",@"[hum]",@"[cute]",@"[angry]",@"[sweat]",@"[smile]",@"[sleepy]",@"[money]",@"[razz]",@"[cool]",@"[bad luck]",@"[surprise]",@"[curse]",@"[contempt]",@"[booger]",@"[lust]",@"[clap]",@"[sad]",@"[think]",@"[sick]",@"[kiss]",@"[hug]",@"[supercilious]",@"[right hum]",@"[left hum]",@"[quiet]",@"[grievance]",@"[yawn]",@"[beat]",@"[question]",@"[winking]",@"[shy]",@"[gonna cry]",@"[bye]",@"[silent]",@"[strong]",@"[weak]",@"[awesome]",@"[meaningless]",@"[onlooker]",@"[mighty]",@"[camera]",@"[car]",@"[plane]",@"[love]",@"[ultraman]",@"[rabbit]",@"[panda]",@"[no]",@"[ok]",@"[like]",@"[tempt]",@"[yeah]",@"[love u]",@"[fist]",@"[poor]",@"[shake hand]",@"[rose]"@"[bike]",@"[cake]",@"[scarf]",@"[glove]",@"[snow]",@"[snowman]",@"[hat]",@"[leaf]", nil];
//            }

            
            self.userListArray = [NSArray arrayWithObjects:@"私聊",@"我关注的人",@"关注我的人",@"附近的用户",@"黑名单", nil];
            self.settingArr1 = [NSArray arrayWithObjects:@"个人信息", @"二维码名片", @"展示窗口", @"通知中心",  nil];
            self.settingArr2 = [NSArray arrayWithObjects:@"私聊权限", @"公开内容", @"清除缓存", nil];
            self.settingArr3 = [NSArray arrayWithObjects:@"第三方绑定", nil];
            self.settingArr4 = [NSArray arrayWithObjects:@"关于", nil];
            self.chatSettingArr = [NSArray arrayWithObjects:@"任何人", @"只允许我关注的人", @"同一俱乐部的人", @"拒绝所有人", nil];
            self.reportTypeNames = [NSArray arrayWithObjects:@"未审批", @"已忽略", nil];

            NSString *path = [[NSBundle mainBundle] pathForResource:@"InfoPlist" ofType:@"strings"];
            self.mainDic = [[NSDictionary alloc] initWithContentsOfFile:path];
            self.serverNO = 1;
            if (iosVersion == 7) {
                BARHEIGHT = 44+20;
            }else{
                BARHEIGHT = 0;
            }
//            NSLog(@"打印InfoPlist.strings%@",path);
//            [Utility printDic:self.mainDic];
            return self;
        }
        
        return nil;
    }
}

- (id)copyWithZone:(NSZone *)zone;{
    
    return self; //确保copy对象也是唯一
    
}



//-(id)retain{
//
//    return self; //确保计数唯一
//
//}
//
//
//
//- (unsigned)retainCount
//
//{
//
//    return UINT_MAX;  //装逼用的，这样打印出来的计数永远为-1
//
//}
//
//
//
//- (id)autorelease
//
//{
//
//    return self;//确保计数唯一
//
//}
//
//
//
//- (oneway void)release
//
//{
//
//    //重写计数释放方法
//
//}

//+(Constants*)getSingleton{
//    static Constants *constants = nil;
//
//    @synchronized(self)
//    {
//        if (!constants)
//            constants = [[Constants alloc] init];
//        return constants;
//    }
//}

@end
