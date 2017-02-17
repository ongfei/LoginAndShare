# DfPodTest

集成QQSDK的方法 可以去QQ开发平台去看步骤 或者 看最后
AppDelegate 有两个代理

因为只需要注册一次 可以在 application:didFinishLaunchingWithOptions:这个方法中注册QQSDK 需要传入AppId 和AppKey

QQ登陆:只需调用userQQloginAndDelegate 两个代理一个是获取登陆的信息一个是获取用户的信息
QQ分享:文字分享,新闻分享,音乐分享等 都是以share开头的方法,block中返回的用户分享的结果 失败or成功

微信的有时间再加







一:把工程的Lib包拖进去


二:添加SDK依赖的系统库文件。分别    是”Security.framework”,“libiconv.dylib”，“SystemConfiguration.framework”，“CoreGraphics.Framework”、“libsqlite3.dylib”、“CoreTelephony.framework”、“libstdc++.dylib”、“libz.dylib”


三:修改必要的工程配置属性。在工程配置中的“Build Settings”一栏中找到“Linking”配置区，给“Other Linker Flags”配置项添加属性值“-fobjc-arc”。


四:重写AppDelegate 的handleOpenURL和openURL方法 详情看 APPDelegate.m文件



over
