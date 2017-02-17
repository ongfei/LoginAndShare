# DfPodTest

集成QQSDK的方法 可以去QQ开发平台去看步骤

AppDelegate 有两个代理

因为只需要注册一次 可以在 application:didFinishLaunchingWithOptions:这个方法中注册QQSDK 需要传入AppId 和AppKey

QQ登陆:只需调用userQQloginAndDelegate 两个代理一个是获取登陆的信息一个是获取用户的信息
QQ分享:文字分享,新闻分享,音乐分享等 都是以share开头的方法,block中返回的用户分享的结果 失败or成功

微信的有时间再加

