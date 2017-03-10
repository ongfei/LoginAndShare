//
//  ThirdTool.m
//  三方登陆&分享
//
//  Created by df on 2017/2/15.
//  Copyright © 2017年 df. All rights reserved.
//

#import "ThirdTool.h"
#import <TencentOpenAPI/TencentOAuth.h>


@interface ThirdTool ()<TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *oauth;

@property (nonatomic, copy) NSString *WXAppId;

@property (nonatomic, copy) NSString *WXSecret;

@property (nonatomic, copy) NSString *WXCode;

@property (nonatomic, copy) NSString *WXtoken;

@property (nonatomic, copy) NSString *WXOpenId;

@property (nonatomic, copy) NSString *WXRefresh_token;



@end

@implementation ThirdTool


static ThirdTool *thirdTool;

+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        thirdTool = [[ThirdTool alloc] init];
        
    });
    
    return thirdTool;
}

#pragma mark - QQ

- (void)registQQWithAppId:(NSString *)appId andAppKey:(NSString *)appKey {
    
    self.oauth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];

}

- (void)userQQloginAndDelegate:(id<ThirdToolDelegate>)delegate {
    
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
//                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            nil];
    
    [self.oauth authorize:permissions inSafari:NO];
    
    self.delegate = delegate;
    
}

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin {
    
    if (_oauth.accessToken && 0 != [_oauth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        
        NSLog(@"------登陆成功------");
        
        if ([self.delegate respondsToSelector:@selector(getLoginInfo:)]) {
            
            [self.delegate getLoginInfo:@{@"accessToken": _oauth.accessToken,
                                         @"expirationDate": _oauth.expirationDate,
                                         @"openId": _oauth.openId,
                                         @"appId": _oauth.appId,
                                         @"passData": _oauth.passData,
                                         }];
        }
        
        [_oauth getUserInfo];
    }
    else {
        
        NSLog(@"登录不成功 没有获取accesstoken");
    }
    
}

- (void)getUserInfoResponse:(APIResponse*) response {

    if ([self.delegate respondsToSelector:@selector(getUserInfoDic:)]) {
        
        [self.delegate getUserInfoDic:response.jsonResponse];
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
    
    if (cancelled) {
        
        NSLog(@"用户取消登录");
    }
    else {
        NSLog(@"登录失败");
    }
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork {
    
    NSLog(@"网络问题");
}

- (void)shareTextToQQ:(NSString *)text andType:(shareAddrType)shareType result:(ResultBlock)resultB {
    
    QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
    
    resultB([self baseShareContent:txtObj andType:shareType]);
}

- (void)shareNewsUrlToQQ:(NSString *)url andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImageURL:(NSString *)imgUrl andType:(shareAddrType)shareType result:(ResultBlock)resultB {
    
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL: [NSURL URLWithString:url]
                                title: titl
                                description: descri
                                previewImageURL: [NSURL URLWithString:imgUrl]];
    
    resultB([self baseShareContent:newsObj andType:shareType]);
}

- (void)shareMusicUrlToQQ:(NSString *)url musicUrl:(NSString *)musicurl andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImageURL:(NSString *)imgUrl andType:(shareAddrType)shareType result:(ResultBlock)resultB {
    
    QQApiAudioObject *audioObj =[QQApiAudioObject
                                 objectWithURL:[NSURL URLWithString:url]
                                 title:titl
                                 description:descri
                                 previewImageURL:[NSURL URLWithString:imgUrl]];
    
    
    //设置播放流媒体地址
    [audioObj setFlashURL:[NSURL URLWithString:musicurl]];
    
    resultB([self baseShareContent:audioObj andType:shareType]);
}

- (QQApiSendResultCode)baseShareContent:(id)content andType:(shareAddrType)shareType {
    
    if (![TencentOAuth iphoneQQInstalled]) {
        
        NSLog(@"木有安装QQ");
    }
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:content];
    
    QQApiSendResultCode sent;
    
    if (shareType == shareAddrTypeQQFriend) {
        
        sent = [QQApiInterface sendReq:req];
        
    }else if (shareType == shareAddrTypeQzone) {
        
        sent = [QQApiInterface SendReqToQZone:req];
    }
    
    return sent;
}

#pragma mark - 微信

- (BOOL)registWXWithAppId:(NSString *)appId {
    
    
    return [WXApi registerApp:appId];
}

- (void)userWXloginWithAppId:(NSString *)appId andSecret:(NSString *)secret andDelegate:(id<ThirdToolDelegate>)delegate {

    self.WXAppId = appId;
    
    self.WXSecret = secret;
    
    self.delegate = delegate;
    
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    
    req.scope = @"snsapi_userinfo,snsapi_base";
    
    req.state = @"ThirdTool";
    
    [WXApi sendReq:req];
    
}

- (void)shareTextToWX:(NSString *)text andType:(shareWXScene)shareType result:(WXResultBlock)resultB {
    
    resultB([self wxBaseShareContent:text andbText:YES andType:shareType]);
}

- (void)sharePicDataToWX:(NSData *)pic andType:(shareWXScene)shareType result:(WXResultBlock)resultB {
    
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    WXImageObject *image = [WXImageObject object];
    
    image.imageData = pic;
    
    message.mediaObject = image;
    
    [self wxBaseShareContent:message andbText:NO andType:shareType];
}


- (void)shareNewsUrlToWX:(NSString *)url andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImage:(UIImage *)img andType:(shareWXScene)shareType result:(WXResultBlock)resultB {
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    message.title = titl;
    
    message.description = descri;
    
    [message setThumbImage:img];
    
    [self wxBaseShareContent:message andbText:NO andType:shareType];
}

- (void)shareVideoUrlToWX:(NSString *)url andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImage:(UIImage *)img andType:(shareWXScene)shareType result:(WXResultBlock)resultB {
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    message.title = titl;
    
    message.description = descri;
    
    [message setThumbImage:img];
    
    WXVideoObject *video = [WXVideoObject object];
    
    video.videoUrl = url;
    
    video.videoLowBandUrl = url;
    
    message.mediaObject = video;
    
    [self wxBaseShareContent:message andbText:NO andType:shareType];

}

- (void)shareMusicUrlToWX:(NSString *)url andMusicDataUrl:(NSString *)dataUrl andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImage:(UIImage *)img andType:(shareWXScene)shareType result:(WXResultBlock)resultB {
    
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    message.title = titl;
    
    message.description = descri;
    
    [message setThumbImage:img];
    
    WXMusicObject *music = [WXMusicObject object];
    
    music.musicUrl = url;
    
    music.musicLowBandUrl = url;
    
    music.musicDataUrl = dataUrl;
    
    music.musicLowBandDataUrl = dataUrl;
    
    message.mediaObject = music;
    
    [self wxBaseShareContent:message andbText:NO andType:shareType];

}


- (NSString *)wxBaseShareContent:(id)content andbText:(BOOL)btext andType:(shareWXScene)shareType {
    
    if (![WXApi isWXAppInstalled]) {
        
        NSLog(@"未安装微信");
        
        return @"未安装微信";
    }
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    
    
    req.bText = btext;
    
    if (btext) {
        
        req.text = content;

    }else {
        
        req.message = content;
    }
    
    req.scene = shareType;
    
    BOOL isSuc = [WXApi sendReq:req];
    
    if (isSuc) {
        
        return @"Succeed";
        
    }else {
        
        return @"fail";
    }
}


- (void)wxPayWithPartnerId:(NSString *)partnerId andPrepayId:(NSString *)prepayId andNonceStr:(NSString *)nonceStr andTimeStamp:(NSString *)timeStamp andSign:(NSString *)sign {
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = partnerId;
    request.prepayId= prepayId;
    request.package = @"Sign=WXPay";
    request.nonceStr= nonceStr;
    request.timeStamp = (UInt32)[timeStamp integerValue];
    request.sign= sign;
    
    BOOL isS = [WXApi sendReq:request];
    
    NSLog(@"+++%d",isS);
}


#pragma mark - 微信delegate

-(void)onReq:(BaseReq*)req {
    
    NSLog(@"%d -- %@",req.type,req.openID);
}

-(void)onResp:(BaseResp*)resp {
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        self.WXCode = [(SendAuthResp *)resp code];
        
        [self requestToken];
        
    }
    if([resp isKindOfClass:[PayResp class]]) {
    
        PayResp *response = (PayResp*)resp;
    
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }

    }
}

- (void)requestToken {

    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",self.WXAppId,self.WXSecret,self.WXCode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                self.WXtoken = [dic objectForKey:@"access_token"];
                self.WXOpenId = [dic objectForKey:@"openid"];
                self.WXRefresh_token = [dic objectForKey:@"refresh_token"];
                
                [self getWXUserInfo];
            }
        });
    });
}

- (void)getWXUserInfo {
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.WXtoken,self.WXOpenId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                
                if ([self.delegate respondsToSelector:@selector(getWXUserInfo:)]) {
                    
                    [self.delegate getWXUserInfo:dic];
                }
            }
        });
        
    });
}


- (void)refreshWXToken {
    
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",self.WXAppId,self.WXRefresh_token];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "JUFTxb9RPoCOc4ozDfn-jOU75-Mun4KfZnh3nq7gL1eB-f03ZrtdlJPlxv87qQ_fx8yzVwn2i089FOuw_PjoGUfGCEuXYJ6p9zl0k1FwVs8";
                 "expires_in" = 7200;
                 openid = "oajnbso3jsD-wd9Is9GOKhJ-z_bo";
                 "refresh_token" = "ZcDgCo3izN7pvMtHZOBoKSc6GoXCw3e3T70oZ0jjMGoXjL_fj5hztNEUJep46AVPLBEEhfpGmHmp42HyYXBcW5RwSmkZJEjYiMuTE0h0Ib0";
                 scope = "snsapi_base,snsapi_userinfo,";
                 }
                 */
                self.WXRefresh_token = [dic objectForKey:@"refresh_token"];
            }
        });
    });

}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        thirdTool = [super allocWithZone:zone];
        
    });
    
    return thirdTool;
}

@end
