//
//  ViewController.m
//  三方登陆&分享
//
//  Created by df on 2017/2/15.
//  Copyright © 2017年 df. All rights reserved.
//

#import "ViewController.h"
#import "ThirdTool.h"

@interface ViewController ()<ThirdToolDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableV;

@property (nonatomic, strong) NSArray *sourceArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableV = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStylePlain)];
    
    [self.view addSubview:self.tableV];
    
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    
    [self.tableV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.sourceArr = [NSArray arrayWithObjects:@"QQLogin",@"QQShareWithText",@"WXLogin",@"WXShare",@"WXPay", nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.sourceArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self respondsToSelector: NSSelectorFromString(self.sourceArr[indexPath.row])]) {
    
        [self performSelector:NSSelectorFromString(self.sourceArr[indexPath.row])];
    }
    
}

- (void)QQLogin {
    
    [[ThirdTool sharedManager] userQQloginAndDelegate:self];

}
- (void)QQShareWithText {
    
    [[ThirdTool sharedManager] shareTextToQQ:@"QQShareWithText" andType:(shareAddrTypeQQFriend) result:^(QQApiSendResultCode code) {
        
        NSLog(@"%d",code);
        
    }];
}

- (void)getLoginInfo:(NSDictionary *)infoDic {
    
    NSLog(@"++++++++++++++++++=%@",infoDic);
}

- (void)getUserInfoDic:(NSDictionary *)infoDic {
    
    NSLog(@"-------------%@",infoDic);
}

#pragma mark - 微信

- (void)WXLogin {
    
    [[ThirdTool sharedManager] userWXloginWithAppId:@"wx8d4e96c8ef765646" andSecret:@"cf7a380c4a2920e209174581e97e5dc9" andDelegate:self];
    
}
// 获取微信登陆用户的信息
- (void)getWXUserInfo:(NSDictionary *)userInfo {
    
    NSLog(@"%@",userInfo);
    
    [[ThirdTool sharedManager] refreshWXToken];
}

- (void)WXShare {
    
    [[ThirdTool sharedManager] shareTextToWX:@"ceshi" andType:(shareWXStateSession) result:^(NSString *result) {
       
        NSLog(@"%@",result);
        
    }];
}

- (void)WXPay {
    
    UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"警告"
                                                   message:@"ViewController里面的 WXPay方法你先看一下"
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"好的", nil];
    
    [aler show];
    
    //从服务器获取订单信息
    NSString *url =[NSString stringWithFormat:@"xxxx"];
    
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
                NSLog(@"%@",dic);
        
                [[ThirdTool sharedManager] wxPayWithPartnerId:dic[@"params"][@"partnerId"] andPrepayId:dic[@"params"][@"prepay_id"] andNonceStr:dic[@"params"][@"nonce_str"] andTimeStamp:dic[@"params"][@"timestamp"] andSign:dic[@"params"][@"sign"]];
            }
        });
    });
}

@end
