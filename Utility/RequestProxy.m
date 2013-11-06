//
//  RequestProxy.m
//  WeClub
//
//  Created by Archer on 13-3-13.
//  Copyright (c) 2013年 mitbbs. All rights reserved.
//

#import "RequestProxy.h"

@implementation RequestProxy

//@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
        _requestArray = [[NSMutableArray alloc] init];
        _responseDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)cancel
{
//    [_networkQueue cancelAllOperations];
    for (ASIFormDataRequest *request in _requestArray) {
        [request cancel];
        request.delegate = nil;
//        [_requestArray removeObject:request];
    }
//    [_responseDataArray removeAllObjects];
}

- (void)sendDictionary:(NSMutableDictionary *)dic andURL:(NSString *)urlString andData:(NSDictionary *)dataDic
{
    NSString *jsonString = [dic JSONString];
    WeLog(@"urlString:%@",urlString);

    WeLog(@"jsonString:%@",jsonString);
    
    _request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    _request.delegate = self;
    [_request setTimeOutSeconds:60];
    [_request setRequestMethod:@"POST"];
    [_request setPostValue:jsonString forKey:@"data"];
    if (dataDic != nil) {
        NSArray *allKeys = [dataDic allKeys];
        for (NSString *key in allKeys) {
            [_request setData:[dataDic objectForKey:key] forKey:key];
        }
    }
    _request.username = urlString;
    
    AccountUser *user = [AccountUser getSingleton];
    if (user.cookie) {
        [_request setRequestCookies:[[NSMutableArray alloc] initWithObjects:user.cookie, nil]];
    }
    
    [_requestArray addObject:_request];
    NSMutableData *responseData = [[NSMutableData alloc] init];
    [_responseDataArray addObject:responseData];
    [_request startAsynchronous];
//    [_networkQueue addOperation:_request];
}

- (void)sendRequest:(NSMutableDictionary *)dic type:(NSString *)type
{
    NSString *urlString = [self getURLStringOfType:type];
    WeLog(@"urlString:%@",urlString);
    
    _request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    _request.delegate = self;
    [_request setRequestMethod:@"POST"];
    [_request setTimeOutSeconds:60];
    [_request setAllowCompressedResponse:YES];
    if (dic != nil) {
        NSString *jsonString = [dic JSONString];
        WeLog(@"jsonString:%@",jsonString);
        [_request setPostValue:jsonString forKey:@"data"];
    }
    _request.username = type;
    
    AccountUser *user = [AccountUser getSingleton];
    if (user.cookie) {
        [_request setRequestCookies:[[NSMutableArray alloc] initWithObjects:user.cookie, nil]];
    }
    
    [_requestArray addObject:_request];
    NSMutableData *responseData = [[NSMutableData alloc] init];
    [_responseDataArray addObject:responseData];
    [_request startAsynchronous];
//    [_networkQueue addOperation:_request];
}

- (void)sendRequest:(NSMutableDictionary *)dic andData:(NSData *)data type:(NSString *)type
{
    AccountUser *user = [AccountUser getSingleton];
    if ([type isEqualToString:REQUEST_TYPE_REGISTER]) {
        NSString *locationInfo = user.locationInfo;
        if (![locationInfo isEqualToString:@"0.01,0.01"]) {
            [dic setObject:locationInfo forKey:@"location"];
        }
        //获取UUID
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *UUID = [defaults objectForKey:@"UUID"];
        [dic setObject:UUID forKey:@"device"];
    }
    
    NSString *jsonString = [dic JSONString];

    WeLog(@"jsonString:%@",jsonString);
    
    NSString *urlString = [self getURLStringOfType:type];
    _request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    _request.delegate = self;
    [_request setRequestMethod:@"POST"];
    [_request setPostValue:jsonString forKey:@"data"];
    [_request setData:data forKey:@"attachment"];
    [_request setAllowCompressedResponse:YES];
    
    _request.username = type;
    
    
    if (user.cookie && ![type isEqualToString:REQUEST_TYPE_REGISTER]) {
        [_request setRequestCookies:[[NSMutableArray alloc] initWithObjects:user.cookie, nil]];
    }
    
    [_requestArray addObject:_request];
    NSMutableData *responseData = [[NSMutableData alloc] init];
    [_responseDataArray addObject:responseData];
    [_request startAsynchronous];
//    [_networkQueue addOperation:_request];
}



- (void)getCookies
{
//    _request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:REQUEST_URL_GETCOOKIE]];
//    _request.delegate = self;
//    [_request setRequestMethod:@"POST"];
//    [_request setPostValue:@"aaa" forKey:@"data"];
//    _request.username = REQUEST_TYPE_GETCOOKIES;
//    
//    [_requestArray addObject:_request];
//    [_request startAsynchronous];
}

- (void)loginWithKey:(NSString *)keyValue andPassWord:(NSString *)passWord andType:(NSString *)type andForce:(BOOL)forceLogin
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:type forKey:REQUEST_MSGKEY_TYPE];
    [dic setObject:keyValue forKey:REQUEST_MSGKEY_ID];
    [dic setObject:passWord forKey:REQUEST_MSGKEY_PASSWORD];
    if (forceLogin) {
        [dic setObject:@"1" forKey:@"force_login"];
    }
    AccountUser *user = [AccountUser getSingleton];
    NSString *locationInfo = user.locationInfo;
    if (![locationInfo isEqualToString:@"0.01,0.01"]) {
        [dic setObject:locationInfo forKey:@"location"];
    }
    //获取UUID
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UUID = [defaults objectForKey:@"UUID"];
    [dic setObject:UUID forKey:@"device"];
    
    [self sendRequest:dic type:REQUEST_TYPE_LOGIN];
}

- (void)checkIsLogin
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[[AccountUser getSingleton] numberID] forKey:@"numberid"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UUID = [defaults objectForKey:@"UUID"];
    [dic setObject:UUID forKey:@"device"];
    
    [self sendRequest:dic type:REQUEST_TYPE_CHECKISLOGIN];
}

- (void)registerWithPhoto:(NSData *)photo andDictionary:(NSMutableDictionary *)dic
{
    [self sendRequest:dic andData:photo type:REQUEST_TYPE_REGISTER];
}

- (void)getUsersIFollow:(NSString *)ID total:(NSString *)total last:(NSString *)last
{
    if (ID == nil) {
//        [self alertStr:@"numberID为空，数据错误"];
        [Utility showHUD:@"numberID为空，数据错误"];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:ID forKey:REQUEST_MSGKEY_NUMBERID];
    [dic setObject:total forKey:REQUEST_MSGKEY_TOTAL];
    [dic setObject:last forKey:REQUEST_MSGKEY_LAST];
    
    [self sendRequest:dic type:REQUEST_TYPE_IFOLLOW];
}

- (void)getUsersFollowMe:(NSString *)ID total:(NSString *)total last:(NSString *)last
{
    if (ID == nil) {
//        [self alertStr:@"numberID为空，数据错误"];
        [Utility showHUD:@"numberID为空，数据错误"];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:ID forKey:REQUEST_MSGKEY_NUMBERID];
    [dic setObject:total forKey:REQUEST_MSGKEY_TOTAL];
    [dic setObject:last forKey:REQUEST_MSGKEY_LAST];
    
    [self sendRequest:dic type:REQUEST_TYPE_FOLLOWME];
}

- (void)getUsersBlackList:(NSString *)ID total:(NSString *)total last:(NSString *)last
{
    if (ID == nil) {
        [self alertStr:@"numberID为空，数据错误"];
        
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:ID forKey:REQUEST_MSGKEY_NUMBERID];
    [dic setObject:total forKey:REQUEST_MSGKEY_TOTAL];
    [dic setObject:last forKey:REQUEST_MSGKEY_LAST];
    
    [self sendRequest:dic type:REQUEST_TYPE_BLACKLIST];
}

- (void)getUserInfoByKey:(NSString *)key andValue:(NSString *)value
{
    if (value == nil) {
        [self alertStr:@"空的value id"];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:value forKey:key];
    
    [self sendRequest:dic type:REQUEST_TYPE_USERINFO];
}

- (void)getUsersInfoByLocation:(NSString *)location PageSize:(NSString *)size StartKey:(NSString *)key
{
    if (location == nil) {
        //        [self alertStr:@"numberID为空，数据错误"];
        [Utility showHUD:@"Location为空，数据错误"];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:location forKey:REQUEST_MSGKEY_LOCATION];
    [dic setObject:size forKey:REQUEST_MSGKEY_PAGESIZE];
    [dic setObject:key forKey:REQUEST_MSGKEY_STARTKEY];
    
    [self sendRequest:dic type:REQUEST_TYPE_GETUSERINFOBYLOCATION];
}

-(void)getUserArticles:(NSString *)type count:(NSString *)count startKey:(NSString *)startKey id:(NSString *)ID key:(NSString *)key
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:type forKey:@"type"];
    [dic setObject:count forKey:@"count"];
    [dic setObject:startKey forKey:@"startkey"];
    if (ID != nil && key != nil) {
        [dic setObject:ID forKey:key];
    }
    
    [self sendRequest:dic type:REQUEST_TYPE_USERARTICLE];
}

- (void)followPerson:(NSString *)numberid
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:numberid forKey:REQUEST_MSGKEY_NUMBERID];
    [self sendRequest:dic type:REQUEST_TYPE_FOLLOWPERSON];
}

- (void)cancelFollowPerson:(NSString *)numberid
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:numberid forKey:REQUEST_MSGKEY_NUMBERID];
    [self sendRequest:dic type:REQUEST_TYPE_CANCELFOLLOWPERSON];
}

- (void)blackAdd:(NSString *)numberid
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:numberid forKey:REQUEST_MSGKEY_NUMBERID];
    [self sendRequest:dic type:REQUEST_TYPE_BLACKADD];
}

- (void)blackCancel:(NSString *)numberid
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:numberid forKey:REQUEST_MSGKEY_NUMBERID];
    [self sendRequest:dic type:REQUEST_TYPE_BLACKCANCEL];
}

- (void)reportPerson:(NSString *)type reason:(NSString *)reason numberid:(NSString *)numberid
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:type forKey:@"type"];
    [dic setObject:reason forKey:@"reason"];
    [dic setObject:numberid forKey:@"oldrowkey"];
    [self sendRequest:dic type:REQUEST_TYPE_REPORTPERSON];
}

- (void)changeMainInfo:(NSDictionary *)dic andPhoto:(NSData *)data
{
    NSMutableDictionary *dictionary = [dic mutableCopy];
    [self sendRequest:dictionary andData:data type:REQUEST_TYPE_CHANGEMAININFO];
}

- (void)upUserPhoto:(NSData *)photoData
{
    [self sendRequest:nil andData:photoData type:REQUEST_TYPE_UPUSERPHOTO];
}

- (void)changePrivacySetting:(NSDictionary *)dic
{
    NSMutableDictionary *dictionary = [dic mutableCopy];
    [self sendRequest:dictionary type:REQUEST_TYPE_PRIVACYSETTING];
}

- (void)logout
{
    [self sendRequest:nil type:REQUEST_TYPE_LOGOUT];
    [AccountUser getSingleton].isLogin = NO;
}

- (void)getInformWithType:(NSString *)type total:(NSString *)total last:(NSString *)last
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:type forKey:@"type"];
    [dic setObject:total forKey:@"total"];
    [dic setObject:last forKey:@"last"];
    [self sendRequest:dic type:REQUEST_TYPE_INFORM];
}

- (void)testPrivateLetterWithNumberID:(NSString *)numberid
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:numberid forKey:@"numberid"];
    
    [self sendRequest:dic type:REQUEST_TYPE_PRIVATE_LETTER];
}

- (void)testPublicSettingWithNumberID:(NSString *)numberid
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:numberid forKey:@"numberid"];
    
    [self sendRequest:dic type:REQUEST_TYPE_PUBLIC_SETTING];
}

- (void)getImportFriendsWithPage:(NSString *)pageSize andStartKey:(NSString *)startKey
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:pageSize forKey:@"pagesize"];
    [dic setObject:startKey forKey:@"startKey"];
    
    [self sendRequest:dic type:REQUEST_TYPE_IMPORT_FRIEND];
}

- (void)followPersons:(NSMutableArray *)personList
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:personList forKey:@"list"];
    
    [self sendRequest:dic type:REQUEST_TYPE_FOLLOWPERSONS];
}

- (void)clearNoticeWithType:(NSString *)type
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:type forKey:@"type"];
    
    [self sendRequest:dic type:REQUEST_TYPE_CLEAR_NOTICE];
}

- (void)searchUserWithID:(NSString *)userID total:(NSString *)total andStartKey:(NSString *)startKey
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:userID forKey:@"id"];
    [dic setObject:total forKey:@"total"];
    [dic setObject:startKey forKey:@"last"];
    
    [self sendRequest:dic type:REQUEST_TYPE_SEARCH_USER];
}

- (void)changePassOrEmail:(NSString *)type withID:(NSString *)ID andOldPass:(NSString *)oldPass
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:ID forKey:@"id"];
    [dic setObject:type forKey:@"type"];
    [dic setObject:oldPass forKey:@"pass"];
    
    [self sendRequest:dic type:REQUEST_TYPE_CHANGEPASSEMAIL];
}

- (NSString *)getURLStringOfType:(NSString *)type
{
    if ([type isEqualToString:REQUEST_TYPE_LOGIN]) {
        return REQUEST_URL_LOGIN;
    }else if ([type isEqualToString:REQUEST_TYPE_CHECKISLOGIN]){
        return REQUEST_URL_CHECKISLOGIN;
    }else if ([type isEqualToString:REQUEST_TYPE_IFOLLOW]){
        return REQUEST_URL_IFOLLOW;
    }else if ([type isEqualToString:REQUEST_TYPE_FOLLOWME]){
        return REQUEST_URL_FOLLOWME;
    }else if ([type isEqualToString:REQUEST_TYPE_BLACKLIST]){
        return REQUEST_URL_BLACKLIST;
    }else if ([type isEqualToString:REQUEST_TYPE_USERINFO]){
        return REQUEST_URL_USERINFO;
    }else if ([type isEqualToString:REQUEST_TYPE_USERATTINFO]){
        return REQUEST_URL_USERATTINFO;
    }else if ([type isEqualToString:REQUEST_TYPE_USERARTICLE]){
        return REQUEST_URL_USERARTICLE;
    }else if ([type isEqualToString:REQUEST_TYPE_FOLLOWPERSON]){
        return REQUEST_URL_FOLLOWPERSON;
    }else if ([type isEqualToString:REQUEST_TYPE_CANCELFOLLOWPERSON]){
        return REQUEST_URL_CANCELFOLLOWPERSON;
    }else if ([type isEqualToString:REQUEST_TYPE_BLACKADD]){
        return REQUEST_URL_BLACKADD;
    }else if ([type isEqualToString:REQUEST_TYPE_BLACKCANCEL]){
        return REQUEST_URL_BLACKCANCEL;
    }else if ([type isEqualToString:REQUEST_TYPE_REPORTPERSON]){
        return REQUEST_URL_REPORTPERSON;
    }else if ([type isEqualToString:REQUEST_TYPE_CHANGEMAININFO]){
        return REQUEST_URL_CHANGEMAININFO;
    }else if ([type isEqualToString:REQUEST_TYPE_UPUSERPHOTO]){
        return REQUEST_URL_UPUSERPHOTO;
    }else if ([type isEqualToString:REQUEST_TYPE_PRIVACYSETTING]){
        return REQUEST_URL_PRIVACYSETTING;
    }else if ([type isEqualToString:REQUEST_TYPE_CHECKISLOGIN]){
        return REQUEST_URL_CHECKISLOGIN;
    }else if ([type isEqualToString:REQUEST_TYPE_LOGOUT]){
        return REQUEST_URL_LOGOUT;
    }else if ([type isEqualToString:REQUEST_TYPE_INFORM]){
        return REQUEST_URL_GETINFORM;
    }else if ([type isEqualToString:REQUEST_TYPE_PRIVATE_LETTER]){
        return REQUEST_URL_PRIVATE_LETTER;
    }else if ([type isEqualToString:REQUEST_TYPE_REGISTER]){
        return REQUEST_URL_REGISTER;
    }else if ([type isEqualToString:REQUEST_TYPE_PUBLIC_SETTING]){
        return REQUEST_URL_PUBLIC_SETTING;
    }else if ([type isEqualToString:REQUEST_TYPE_IMPORT_FRIEND]){
        return REQUEST_URL_IMPORTFRIEND;
    }else if ([type isEqualToString:REQUEST_TYPE_FOLLOWPERSONS]){
        return REQUEST_URL_FOLLOWPERSONS;
    }else if ([type isEqualToString:REQUEST_TYPE_CLEAR_NOTICE]){
        return REQUEST_URL_CLEARNOTICE;
    }else if ([type isEqualToString:REQUEST_TYPE_SEARCH_USER]){
        return REQUEST_URL_SEARCHUSER;
    }else if ([type isEqualToString:REQUEST_TYPE_CHANGEPASSEMAIL]){
        return REQUEST_URL_CHANGEPASSEMAIL;
    }else if ([type isEqual:REQUEST_TYPE_GETUSERINFOBYLOCATION]){
        return REQUEST_URL_GETUSERINFOBYLOCATION;
    }else if ([type isEqualToString:REQUEST_TYPE_SCANINFO]){
        return REQUEST_URL_SCANINFO;
    }
    return nil;
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestStarted:(ASIHTTPRequest *)request
{
    WeLog(@"requestStarted...");
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    WeLog(@"didReceiveData...");
    int index = [_requestArray indexOfObject:request];
    if (index != NSNotFound) {
        if (_requestArray.count > _responseDataArray.count) {
            for (int i=0; i <= _requestArray.count; i++) {
                [_responseDataArray addObject:[[NSMutableData alloc] init]];
            }
        }
        NSMutableData *responseData = [_responseDataArray objectAtIndex:index];
        [responseData appendData:data];
//        WeLog(@"aaaaaaaaaa.....");
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    WeLog(@"requestFinished");
    WeLog(@"请求地址:%@",request.username);
    NSArray *cookies = request.responseCookies;
    if ([cookies count] == 0) {
        WeLog(@"Error : none cookies!");
    }else{
        AccountUser *user = [AccountUser getSingleton];
        user.cookie = [cookies objectAtIndex:0];
    }
    
//    if ([request.username isEqualToString:REQUEST_TYPE_GETCOOKIES]) {
//        AccountUser *user = [AccountUser getSingleton];
//        user.cookie = [cookies objectAtIndex:0];
//    }
    
    NSMutableData *responseData;
    NSString *responseStr;
    int index = [_requestArray indexOfObject:request];
    WeLog(@"%d",index);
    if (index != NSNotFound) {
        if (_requestArray.count > _responseDataArray.count) {
            for (int i=0; i <= _requestArray.count; i++) {
                [_responseDataArray addObject:[[NSMutableData alloc] init]];
            }
        }
        //        WeLog(@"aaaaaaaaaa.....");
        responseData = [_responseDataArray objectAtIndex:index];
        responseStr=nil;
    }
    
    if([request isResponseCompressed]) {
         //WeLog(@"recieved compressed data %d",responseData.length);
        responseStr = [[ NSString alloc] initWithData:[ASIHTTPRequest uncompressZippedData:responseData] encoding:NSUTF8StringEncoding];
       
    }else {
        // WeLog(@"recieved  data %d",responseData.length);
        responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    
    WeLog(@"response :%@",responseStr);
    //WeLog(@"username:%@",request.username);
    if (![responseStr length]) {
//        [Utility showHUD:@"抱歉，服务器暂时失去相应，请耐心等待..."];
        if (_delegate) {
            [_delegate processFailed:@"failed" requestType:request.username];
        }
    return;
    }
    
    NSDictionary *dic = [responseStr objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    if (dic == nil) {
        
    }
    NSString *resultStr = [dic objectForKey:@"result"];
    int result;
    if (resultStr == nil) {
        result = -1;
        [Utility showHUD:@"抱歉，服务器暂时失去相应，请耐心等待..."];
//        [self alertStr:@"数据格式错误"];
        if (_delegate) {
            [_delegate processFailed:@"failed" requestType:request.username];
        }
        return;
    }else{
        result = [resultStr intValue];
    }
    
    NSArray *codeArr = [dic objectForKey:@"code"];
    if (result == 0) {
        if (_delegate) {
            [_delegate processData:dic requestType:request.username];
        }
    }
    else if (result == 1 && [codeArr isKindOfClass:[NSArray class]] && [codeArr containsObject:@"363"]) {
        if (_delegate) {
            [_delegate processData:dic requestType:request.username];
        }
    }
    else{
        if (_delegate) {
            codeArr = [dic objectForKey:@"code"];
            NSArray *msgArr = [dic objectForKey:@"msg"];
            
            //判断是否登录超时
            if ([codeArr isKindOfClass:[NSArray class]] && [codeArr containsObject:@"394"]) {
                [self cancel];
                NSString *str = @"aaa";
                if ([msgArr isKindOfClass:[NSArray class]] && [msgArr count]>0) {
                    str = [msgArr objectAtIndex:0];
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }else if ([codeArr isKindOfClass:[NSArray class]] && [codeArr containsObject:@"399"]){
                [self cancel];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号已在其它地方登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
            if (![[dic objectForKey:@"msg"] isKindOfClass:[NSArray class]]) {
                if ([[dic objectForKey:@"msg"] isKindOfClass:[NSDictionary class]]) {
                    NSString *s = [[dic objectForKey:@"msg"] objectForKey:@"article"];
//                    [Utility showHUD:s];
//                    [Utility MsgBox:s];
                }else{
                    if ([[dic objectForKey:@"msg"] isEqualToString:@"此用户已在其他地方登录"]) {
                    }else if([[dic objectForKey:@"msg"] isEqualToString:@"未登录"]){
                    }else if([[dic objectForKey:@"msg"] isEqualToString:@"长时间未操作，请重新登录"]){
                    }else{
                        [Utility showHUD:[dic objectForKey:@"msg"]];
                    }
                    //[Utility showHUD:[dic objectForKey:@"msg"]];
                    if ([[dic objectForKey:@"code"] isKindOfClass:[NSArray class]]) {
                        NSString *code = [[dic objectForKey:@"code"] objectAtIndex:0] ;
                        [_delegate processException:[code intValue] desc:[dic objectForKey:@"msg"] info:dic requestType:request.username];
                    }else{
                        [_delegate processException:[[dic objectForKey:@"code"] intValue] desc:[dic objectForKey:@"msg"] info:dic requestType:request.username];
                    }

                }
                
            }else{
                int code = 0;
                NSString *msg;
                if ([codeArr isKindOfClass:[NSArray class]] && [codeArr count]>0) {
                    code = [[codeArr objectAtIndex:0] intValue];
                }
                if ([msgArr isKindOfClass:[NSArray class]] && [msgArr count]>0) {
                    msg = [msgArr objectAtIndex:0];
                }else{
                    msg = @"unknow error!";
                }
                [_delegate processException:code desc:msg info:dic requestType:request.username];
                switch (code) {
                    case 301:
                    case 302:
                        [Utility MsgBox:msg];
                        break;//用户已关闭的提示在个人信息界面做独自提示
                    case 395:{
                        //不做提示处理的错误码
                        break;
                    }
                    default:{
                        [Utility MsgBox:msg];
                        break;
                    }
                }
            }
            
            
        }
    }
    
    [_requestArray removeObject:request];
    [_responseDataArray removeObject:responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_delegate processFailed:[request.error description] requestType:request.username];
    
    WeLog(@"request failed error:%@",[request.error description]);
    if (request.error.code == 2) {
//        [Utility showHUD:@"请求超时"];
    }
    switch (request.error.code) {
        case 1:
//            [self alertStr:@"抱歉，服务器暂时失去响应，请耐心等候..."];
            [Utility showHUD:@"抱歉，服务器暂时失去响应，请耐心等候..."];
            break;
        case 4:
            WeLog(@"请求已取消......");
            break;
        default:
            [Utility showHUD:@"抱歉，服务器暂时失去响应，请耐心等候..."];
            break;
    }

    if ([_requestArray indexOfObject:request] != NSNotFound) {
        [_responseDataArray removeObjectAtIndex:[_requestArray indexOfObject:request]];
        [_requestArray removeObject:request];
    }
}

- (void)alertStr:(NSString *)str
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    WeLog(@"%@",str);
    [Utility MsgBox:str];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[ChatListSaveProxy sharedChatListSaveProxy] saveUpdate];
        [self logout];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_LOGOUT object:nil];
    }
}

@end
