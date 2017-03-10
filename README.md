#LoginAndShare

###用的时候 需要传自己的APPID scheme 别忘记修改



####QQ登陆分享
集成QQSDK的方法 可以去QQ开发平台去看步骤 或者 看最后



因为只需要注册一次 可以在 application:didFinishLaunchingWithOptions:这个方法中注册QQSDK 需要传入AppId 和AppKey


QQ登陆:只需调用userQQloginAndDelegate 两个代理一个是获取登陆的信息一个是获取用户的信息
QQ分享:文字分享,新闻分享,音乐分享等 都是以share开头的方法,block中返回的用户分享的结果 失败or成功


####微信登陆分享支付
因为只需要注册一次 可以在 application:didFinishLaunchingWithOptions:这个方法中注册WXSDK 需要传入AppId

微信登陆的时候需要传入secret;

代理 getWXUserInfo: 获取登陆用户的信息




####QQ集成

一:把工程的Lib包中的QQSDK拖进去或者去官方下载最新版本


二:添加SDK依赖的系统库文件。分别    是”Security.framework”,“libiconv.dylib”，“SystemConfiguration.framework”，“CoreGraphics.Framework”、“libsqlite3.dylib”、“CoreTelephony.framework”、“libstdc++.dylib”、“libz.dylib”


三:修改必要的工程配置属性。在工程配置中的“Build Settings”一栏中找到“Linking”配置区，给“Other Linker Flags”配置项添加属性值“-fobjc-arc”。


四:重写AppDelegate 的handleOpenURL和openURL方法 详情看 APPDelegate.m文件

over

####微信集成
一:把工程的Lib包中的WXSDK拖进去或者去官方下载最新版本

二:添加SDK依赖的系统库文件:

SystemConfiguration.framework, libz.dylib, libsqlite3.0.dylib, libc++.dylib, Security.framework, CoreTelephony.framework, CFNetwork.framework。


三:修改必要的工程配置属性:

在你的工程文件中选择Build Setting，在"Other Linker Flags"中加入"-Objc -all_load"，在Search Paths中添加 libWeChatSDK.a ，WXApi.h，WXApiObject.h，文件所在位置


四: 添加scheme  添加错误的影响就是微信的回调不会走: 

在Xcode中，选择你的工程设置项，选中“TARGETS”一栏，在“info”标签栏的“URL type“添加“URL scheme”为你所注册的应用程序id
