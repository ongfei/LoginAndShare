//
//  ThirdTool.h
//  三方登陆&分享
//
//  Created by df on 2017/2/15.
//  Copyright © 2017年 df. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>

typedef enum : NSUInteger {
    shareAddrTypeQQFriend,
    shareAddrTypeQzone,
} shareAddrType;

typedef void(^ResultBlock)(QQApiSendResultCode code);

@protocol ThirdToolDelegate <NSObject>

@property (nonatomic, assign) shareAddrType shareType;

/**
 *  登陆成功之后返回用户信息的代理
 *
 */
- (void)getUserInfoDic:(NSDictionary *)infoDic;
/**
 *  登陆成功返回登录信息的代理
 *
 */
- (void)getLoginInfo:(NSDictionary *)infoDic;

@end

typedef void(^responsBlock)(id responserObject);

@interface ThirdTool : NSObject

@property (nonatomic, weak) id<ThirdToolDelegate> delegate;

+ (instancetype)sharedManager;
/**
 *  注册QQ登陆 在 application: didFinishLaunchingWithOptions: 调用
 *
 *  @param appId
 *  @param appKey
 */
- (void)registQQWithAppId:(NSString *)appId andAppKey:(NSString *)appKey;
/**
 *  用QQ登陆
 *
 *  @param delegate 在 controller 里传self
 */
- (void)userQQloginAndDelegate:(id<ThirdToolDelegate>)delegate;
/**
 *  分享文字到QQ
 *
 *  @param text 文字
 *  @param resultB 返回结果
 */
- (void)shareTextToQQ:(NSString *)text andType:(shareAddrType)shareType result:(ResultBlock)resultB;
/**
 *  分享链接 新闻
 *
 *  @param url    新闻url
 *  @param titl   标题
 *  @param descri 描述
 *  @param imgUrl 预览图片url
 *  @param resultB 返回结果
 */
- (void)shareNewsUrlToQQ:(NSString *)url andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImageURL:(NSString *)imgUrl andType:(shareAddrType)shareType result:(ResultBlock)resultB;
/**
 *  分享链接 音乐
 *
 *  @param url    跳转的url
 *  @param musicurl    音乐url
 *  @param titl   标题
 *  @param descri 描述
 *  @param imgUrl 预览图片url
 *  @param resultB 返回结果
 */
- (void)shareMusicUrlToQQ:(NSString *)url musicUrl:(NSString *)musicurl andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImageURL:(NSString *)imgUrl andType:(shareAddrType)shareType result:(ResultBlock)resultB;



@end
