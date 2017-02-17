//
//  ViewController.m
//  三方登陆&分享
//
//  Created by df on 2017/2/15.
//  Copyright © 2017年 df. All rights reserved.
//

#import "ViewController.h"
#import "ThirdTool.h"

@interface ViewController ()<ThirdToolDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    
    btn.frame = CGRectMake(100, 100, 100, 100);
    
    [btn setTitle:@"qqlogin" forState:(UIControlStateNormal)];
    
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(click) forControlEvents:(UIControlEventTouchUpInside)];
    
}



- (void)click {
    
//    [[ThirdTool sharedManager] userQQloginAndDelegate:self];
    
    [[ThirdTool sharedManager] shareTextToQQ:@"11" andType:(shareAddrTypeQQFriend) result:^(QQApiSendResultCode code) {
        
        
    }];
}

- (void)getLoginInfo:(NSDictionary *)infoDic {
    
    NSLog(@"++++++++++++++++++=%@",infoDic);
}

- (void)getUserInfoDic:(NSDictionary *)infoDic {
    
    NSLog(@"-------------%@",infoDic);
}

@end
