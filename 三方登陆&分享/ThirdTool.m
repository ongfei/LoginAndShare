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

@end

@implementation ThirdTool


static ThirdTool *thirdTool = nil;

+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        thirdTool = [[self alloc] init];
        
    });
    
    return thirdTool;
}

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
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
    
    resultB([self baseShareContent:req andType:shareType]);
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
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:content];
    
    QQApiSendResultCode sent;
    
    if (shareType == shareAddrTypeQQFriend) {
        
        sent = [QQApiInterface sendReq:req];
        
    }else if (shareType == shareAddrTypeQzone) {
        
        sent = [QQApiInterface SendReqToQZone:req];
    }
    
    return sent;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        thirdTool = [super allocWithZone:zone];
        
    });
    
    return thirdTool;
}

@end
