//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  LKMessageSwitchPod.m
//  LKMessageSwitchPod
//
//  Created by sherlock on 2017/10/12.
//  Copyright (c) 2017年 sherlock. All rights reserved.
//

#import "LKMessageSwitchPod.h"
#import <UIKit/UIKit.h>
#import "CaptainHook.h"
#import "WeChatHeader.h"




@interface LKNewestMsgManager:NSData
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSMutableString *content;
+(instancetype)sharedInstance;
@end

@implementation LKNewestMsgManager

+(instancetype)sharedInstance{
    static LKNewestMsgManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LKNewestMsgManager new];
    });
    return instance;
}

- (void)LKDidReceiveNewMessage{
    
}

- (UIViewController *)getCurrentVC{
    //获取默认window
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication]windows];
        for(UIWindow *tmpWindow in windows){
            if (tmpWindow.windowLevel == UIWindowLevelNormal) {
                window = tmpWindow;
                break;
            }
        }
    }
    
    //获取window的根视图
    UIViewController *currentVC = window.rootViewController;
    while (currentVC.presentedViewController) {
        currentVC = currentVC.presentedViewController;
    }
    if ([currentVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [(UITabBarController*)currentVC selectedViewController];
    }
    if ([currentVC isKindOfClass:[UINavigationController class]]) {
        currentVC = [(UINavigationController*)currentVC visibleViewController];
    }
    return currentVC;
}
@end



// hook MMUIViewController基类

CHDeclareClass(MMUIViewController)

CHDeclareMethod1(void, MMUIViewController, backToMsgContentViewController, id, sender){
    [sender removeFromSuperview];
    UINavigationController *navi = [objc_getClass("CAppViewControllerManager") getCurrentNavigationController];
    
    MMServiceCenter* serviceCenter = [objc_getClass("MMServiceCenter") defaultCenter];
    CContactMgr *contactMgr = [serviceCenter getService:[objc_getClass("CContactMgr") class]];
    CContact *contact = [contactMgr getContactByName:[LKNewestMsgManager sharedInstance].username];
    MMMsgLogicManager *logicManager = [serviceCenter getService:[objc_getClass("MMMsgLogicManager") class]];
    [logicManager PushOtherBaseMsgControllerByContact:contact navigationController:navi animated:YES];
    
}

CHOptimizedMethod0(self, void, MMUIViewController, viewDidLoad){
    NSLog(@"成功 hook MMUIViewController!!!");
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"LkWechatMessageNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        NSLog(@"收到消息!!!");
        
        NSString *currentVCClassName = [NSString stringWithUTF8String:object_getClassName([[LKNewestMsgManager sharedInstance]getCurrentVC])];
        if (![currentVCClassName  isEqual: @"NSKVONotifying_NewMainFrameViewController"]) {
            
            if(self == [[LKNewestMsgManager sharedInstance]getCurrentVC]){
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                btn.frame = CGRectMake(self.view.frame.size.width-100-2, 74, 100, 40);
                btn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
                btn.tintColor = [UIColor whiteColor];
                [btn setTitle:[LKNewestMsgManager sharedInstance].content forState:UIControlStateNormal];
                btn.clipsToBounds = YES;
                btn.layer.cornerRadius = 10;
                btn.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
                [btn addTarget:self action:@selector(backToMsgContentViewController:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btn];
                
                
            }
        }
    }];
    
    
    CHSuper0(MMUIViewController, viewDidLoad);
}

CHConstructor{
    CHLoadLateClass(MMUIViewController);
    CHClassHook0(MMUIViewController, viewDidLoad );
}



// hook 消息接收类

CHDeclareClass(CMessageMgr)

CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsg, NSString*, msg, MsgWrap, CMessageWrap*, wrap){
    
    [LKNewestMsgManager sharedInstance].username = msg;
    NSLog(@"%@", [LKNewestMsgManager sharedInstance].username);
    [LKNewestMsgManager sharedInstance].content = wrap.m_nsPushContent;
    NSLog(@"%@", [LKNewestMsgManager sharedInstance].content);
    
    if([LKNewestMsgManager sharedInstance].content != NULL){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LkWechatMessageNotification" object:nil];
    }
    
    CHSuper2(CMessageMgr, AsyncOnAddMsg, msg, MsgWrap, wrap);
    
}

CHConstructor{
    CHLoadLateClass(CMessageMgr);
    CHClassHook2(CMessageMgr, AsyncOnAddMsg, MsgWrap);
}

