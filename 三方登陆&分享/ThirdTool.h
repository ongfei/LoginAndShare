//
//  ThirdTool.h
//  三方登陆&分享
//
//  Created by df on 2017/2/15.
//  Copyright © 2017年 df. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"

typedef enum : NSUInteger {
    shareAddrTypeQQFriend,
    shareAddrTypeQzone,
} shareAddrType;

typedef enum : NSUInteger {
    shareWXStateSession,
    shareWXStateTimeline,
    shareWXStateFavorite,
} shareWXScene;

typedef void(^ResultBlock)(QQApiSendResultCode code);
typedef void(^WXResultBlock)(NSString * result);

@protocol ThirdToolDelegate <NSObject>
/**
 *  qq登陆成功之后返回用户信息的代理
 *
 */
- (void)getUserInfoDic:(NSDictionary *)infoDic;
/**
 *  qq登陆成功返回登录信息的代理
 *
 */
- (void)getLoginInfo:(NSDictionary *)infoDic;
/**
 *  微信登陆成功 获取用户信息
 */
- (void)getWXUserInfo:(NSDictionary *)userInfo;

@end

typedef void(^responsBlock)(id responserObject);

@interface ThirdTool : NSObject<WXApiDelegate>

@property (nonatomic, assign) shareAddrType shareType;

@property (nonatomic, assign) shareAddrType shareType;

@property (nonatomic, weak) id<ThirdToolDelegate> delegate;

+ (instancetype)sharedManager;
- (BOOL)handleOpenUrl:(NSURL *)url;
#pragma mark - qq注册
/**
 *  注册QQapi 在 application: didFinishLaunchingWithOptions: 调用
 *
 *  @param appId
 *  @param appKey
 */
- (void)registQQWithAppId:(NSString *)appId andAppKey:(NSString *)appKey;
#pragma mark - 微信注册
/**
 *  注册微信api 在 application: didFinishLaunchingWithOptions: 调用
 *
 *  @param appId 微信appid
 */
- (BOOL)registWXWithAppId:(NSString *)appId;
#pragma mark - qq登陆
/**
 *  用QQ登陆
 *
 *  @param delegate 在 controller 里传self
 */
- (void)userQQloginAndDelegate:(id<ThirdToolDelegate>)delegate;
#pragma mark - 微信登陆
/**
 *  微信登陆
 *
 *  @param appId    appid
 *  @param secret   secret
 *  @param delegate 传self
 */
- (void)userWXloginWithAppId:(NSString *)appId andSecret:(NSString *)secret andDelegate:(id<ThirdToolDelegate>)delegate;
#pragma mark - 刷新微信的授权
/**
 *  刷新延长微信的授权
 */
- (void)refreshWXToken;
#pragma mark - qq分享文字
/**
 *  分享文字到QQ
 *
 *  @param text 文字
 *  @param resultB 返回结果
 */
- (void)shareTextToQQ:(NSString *)text andType:(shareAddrType)shareType result:(ResultBlock)resultB;
#pragma mark - qq分享新闻
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
#pragma mark - qq分享音乐
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

#pragma mark - 微信分享文字
/**
 *  分享文字到微信
 *
 *  @param text 文字
 *  @param resultB 返回结果
 */
- (void)shareTextToWX:(NSString *)text andType:(shareWXScene)shareType result:(WXResultBlock)resultB;
#pragma mark - 微信分享图片
/**
 *  分享图片到微信
 *
 *  @param pic data
 *  @param resultB 返回结果
 */
- (void)sharePicDataToWX:(NSData *)pic andType:(shareWXScene)shareType result:(WXResultBlock)resultB;
#pragma mark - 微信分享网页
/**
 *  分享链接
 *
 *  @param url    url
 *  @param titl   标题
 *  @param descri 描述
 *  @param imgUrl 预览图片url
 *  @param resultB 返回结果
 */
- (void)shareNewsUrlToWX:(NSString *)url andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImage:(UIImage *)img andType:(shareWXScene)shareType result:(WXResultBlock)resultB;
#pragma mark - 微信分享视频
/**
 *  分享链接
 *
 *  @param url    url
 *  @param titl   标题
 *  @param descri 描述
 *  @param imgUrl 预览图片url
 *  @param resultB 返回结果
 */
- (void)shareVideoUrlToWX:(NSString *)url andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImage:(UIImage *)img andType:(shareWXScene)shareType result:(WXResultBlock)resultB;
#pragma mark - 微信分享音乐
/**
 *  分享链接
 *
 *  @param url    url
 *  @param dataUrl    dataurl
 *  @param titl   标题
 *  @param descri 描述
 *  @param imgUrl 预览图片url
 *  @param resultB 返回结果
 */
- (void)shareMusicUrlToWX:(NSString *)url andMusicDataUrl:(NSString *)dataUrl andTitle:(NSString *)titl andDescription:(NSString *)descri andPreviewImage:(UIImage *)img andType:(shareWXScene)shareType result:(WXResultBlock)resultB;

#pragma mark - 微信支付

- (void)wxPayWithPartnerId:(NSString *)partnerId andPrepayId:(NSString *)prepayId andNonceStr:(NSString *)nonceStr andTimeStamp:(NSString *)timeStamp andSign:(NSString *)sign;



@end
