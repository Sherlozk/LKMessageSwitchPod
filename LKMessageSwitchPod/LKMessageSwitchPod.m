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
#import <CaptainHook/CaptainHook.h>
#import "WeChatHeader.h"



@interface LKNewestMsgManager:NSData
@property(nonatomic, strong) NSMutableString *username;
@property(nonatomic, strong) NSMutableString *content;
@property(nonatomic, strong) NSMutableString *nickname;
@property(nonatomic, strong) NSMutableString *currentChat;
@property(nonatomic, strong) NSMutableString *didTouchBtnName;
@property(nonatomic, strong) NSString *FromUsr;
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


@interface LKButton : UIButton<CAAnimationDelegate>
@property(nonatomic, strong)NSMutableString *username;
@property(nonatomic, strong)UISwipeGestureRecognizer *swipeGestureRecognizer;
@end

@implementation LKButton

-(void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"btnDidTouch" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*note){
        if ([self.username isEqual: [LKNewestMsgManager sharedInstance].didTouchBtnName]) {
            [self removeFromSuperview];
        }
    }];
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"回调了");
    [self removeFromSuperview];
}

@end

CHDeclareClass(MicroMessengerAppDelegate)

CHOptimizedMethod2(self, BOOL, MicroMessengerAppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary*, launchOptions){
    NSLog(@"成功 hook appDelegate!!!!!");
    
    //  Usage 2: 打印在运行过程中调用了哪些方法
    //    [ANYMethodLog logMethodWithClass:NSClassFromString(@"CMessageMgr") condition:^BOOL(SEL sel) {
    //        return YES;
    //    } before:^(id target, SEL sel, NSArray *args, int deep) {
    //        NSLog(@"target:%@ sel:%@", target, NSStringFromSelector(sel));
    //    } after:nil];
    //
    //    [ANYMethodLog logMethodWithClass:[UIViewController class] condition:^BOOL(SEL sel) {
    //        return YES;
    //    } before:^(id target, SEL sel, NSArray *args, int deep) {
    //        NSLog(@"target:%@ sel:%@", target, NSStringFromSelector(sel));
    //    } after:nil];
    
    // Usage 4: 打印调用方法时的参数值
    //    [ANYMethodLog logMethodWithClass:NSClassFromString(@"UIViewController") condition:^BOOL(SEL sel) {
    //
    //        return [NSStringFromSelector(sel) isEqualToString:@"viewWillAppear:"];
    //
    //    } before:^(id target, SEL sel, NSArray *args, int deep) {
    //
    //        NSLog(@"before target:%@ sel:%@ args:%@", target, NSStringFromSelector(sel), args);
    //
    //    } after:nil];
    
    //    打印某个类所有方法
    //    [ANYMethodLog logMethodWithClass:NSClassFromString(@"MMServiceCenter") condition:^BOOL(SEL sel) {
    //        NSLog(@"method:%@", NSStringFromSelector(sel));
    //        return NO;
    //    } before:nil after:nil];
    
    CHSuper2(MicroMessengerAppDelegate, application, application, didFinishLaunchingWithOptions, launchOptions);
}

CHConstructor{
    CHLoadLateClass(MicroMessengerAppDelegate);
    CHClassHook2(MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions);
}


//CHDeclareClass(MMMsgLogicManager)
//
//CHOptimizedMethod3(self, void, MMMsgLogicManager, PushOtherBaseMsgControllerByContact, CContact*, contact, navigationController, UINavigationController*, navi, animated, BOOL, animated){
//
//    NSLog(@"hahaha");
//
//    CHSuper3(MMMsgLogicManager, PushOtherBaseMsgControllerByContact, contact, navigationController, navi, animated, animated);
//}
//
//CHConstructor{
//    CHLoadLateClass(MMMsgLogicManager);
//    CHClassHook3(MMMsgLogicManager, PushOtherBaseMsgControllerByContact, navigationController, animated);
//
//}



//聊天基本页面
CHDeclareClass(BaseMsgContentViewController)

CHOptimizedMethod1(self, void, BaseMsgContentViewController, viewDidAppear, BOOL, flag){
    //    NSLog(@"hehehehe");
    [LKNewestMsgManager sharedInstance].currentChat = [(BaseMsgContentViewController*)[[LKNewestMsgManager sharedInstance] getCurrentVC]getCurrentChatName];
    
    NSLog(@"%@", [LKNewestMsgManager sharedInstance].currentChat);
    
    CHSuper1(BaseMsgContentViewController, viewDidAppear, flag);
}

CHOptimizedMethod1(self, void, BaseMsgContentViewController, viewWillDisappear, BOOL, disappear){
    [LKNewestMsgManager sharedInstance].currentChat = NULL;
    
    CHSuper1(BaseMsgContentViewController, viewWillDisappear, disappear);
}

CHConstructor{
    CHLoadLateClass(BaseMsgContentViewController);
    CHClassHook1(BaseMsgContentViewController, viewWillDisappear);
    CHClassHook1(BaseMsgContentViewController, viewDidAppear);
    
}

// hook MMUIViewController基类

CHDeclareClass(MMUIViewController)

CHDeclareMethod1(void, MMUIViewController, backToMsgContentViewController, id, sender){
    [sender removeFromSuperview];
    UINavigationController *navi = [objc_getClass("CAppViewControllerManager") getCurrentNavigationController];
    
    LKButton *btn = (LKButton *)sender;
    [LKNewestMsgManager sharedInstance].didTouchBtnName = btn.username;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"btnDidTouch" object:nil];
    MMServiceCenter* serviceCenter = [objc_getClass("MMServiceCenter") defaultCenter];
    CContactMgr *contactMgr = [serviceCenter getService:[objc_getClass("CContactMgr") class]];
    CContact *contact = [contactMgr getContactByName:btn.username];
    //    CContact *contact = [contactMgr getSelfContact];
    
    MMMsgLogicManager *logicManager = [serviceCenter getService:[objc_getClass("MMMsgLogicManager") class]];
    [logicManager PushOtherBaseMsgControllerByContact:contact navigationController:navi animated:YES];
    
}

CHDeclareMethod1(void, MMUIViewController, handleSwipes, UISwipeGestureRecognizer*, sender){
    NSLog(@"右滑了");
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    //    __weak __typeof(self)weakSelf = self;
    animation.delegate = sender.view;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(sender.view.frame.origin.x+sender.view.frame.size.width/2, sender.view.frame.origin.y+sender.view.frame.size.height/2)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(sender.view.frame.origin.x+sender.view.frame.size.width*1.5+10, sender.view.frame.origin.y+sender.view.frame.size.height/2)];
    
    animation.duration = 0.2f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [sender.view.layer addAnimation:animation forKey:@"positionAnimation"];
    //    [sender.view removeFromSuperview];
    
    
}



CHOptimizedMethod0(self, void, MMUIViewController, viewDidLoad){
    NSLog(@"成功 hook MMUIViewController!!!");
    
    NSString *currentVCClassName = [NSString stringWithUTF8String:object_getClassName([[LKNewestMsgManager sharedInstance]getCurrentVC])];
    
    //&& ![currentVCClassName isEqual:@"NSKVONotifying_BaseMsgContentViewController"]
    if (![currentVCClassName  isEqual: @"NSKVONotifying_NewMainFrameViewController"]
        && ![currentVCClassName isEqual:@"NSKVONotifying_WCCommentListViewController"]
        && ![currentVCClassName isEqual:@"NSKVONotifying_SayHelloViewController"]) { //对新好友提示页面和朋友圈评论列表页面设置通知,会导致页面不被释放,消息重复提示的bug
        
        [[NSNotificationCenter defaultCenter]addObserverForName:@"LkWechatMessageNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
            NSLog(@"收到消息!!!");
            //        UIViewController *VC = [[LKNewestMsgManager sharedInstance]getCurrentVC];
            
            NSString *currentChatName = [LKNewestMsgManager sharedInstance].currentChat;
            if(self == [[LKNewestMsgManager sharedInstance]getCurrentVC] && ![currentChatName isEqual: [LKNewestMsgManager sharedInstance].username]){
                
                LKButton *btn = [LKButton buttonWithType:UIButtonTypeRoundedRect];
                btn.frame = CGRectMake(self.view.frame.size.width-100-2, 74, 100, 40);
                btn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
                btn.tintColor = [UIColor whiteColor];
                [btn setTitle:[LKNewestMsgManager sharedInstance].content forState:UIControlStateNormal];\
                btn.username = [LKNewestMsgManager sharedInstance].username;
                btn.clipsToBounds = YES;
                btn.layer.cornerRadius = 10;
                btn.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
                [btn addTarget:self action:@selector(backToMsgContentViewController:) forControlEvents:UIControlEventTouchUpInside];
                [btn registerNotification];
                btn.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipes:)];
                btn.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
                btn.swipeGestureRecognizer.numberOfTouchesRequired = 1;
                [btn addGestureRecognizer:btn.swipeGestureRecognizer];
                
                
                [self.view addSubview:btn];
                
                
            }
        }];
    }
    
    CHSuper0(MMUIViewController, viewDidLoad);
}

CHConstructor{
    CHLoadLateClass(MMUIViewController);
    CHClassHook0(MMUIViewController, viewDidLoad );
}



// hook 消息接收类

CHDeclareClass(CMessageMgr)

CHOptimizedMethod2(self, void, CMessageMgr, AsyncOnAddMsg, NSMutableString*, msg, MsgWrap, CMessageWrap*, wrap){
    
    //    UINavigationController *navi = [objc_getClass("CAppViewControllerManager") getCurrentNavigationController];
    //    NSLog(@"%@",navi.navigationItem.title);
    //    BaseMsgContentViewController *VC = (BaseMsgContentViewController*)[[LKNewestMsgManager sharedInstance]getCurrentVC];
    //    NSLog(@"%@", [VC getCurrentChatName]);
    
    
    
    //    NSLog(@"%@", [LKNewestMsgManager sharedInstance].username);
    //    if([LKNewestMsgManager sharedInstance].username == NULL){
    //        [LKNewestMsgManager sharedInstance].username = msg;
    ////        NSLog(@"%@", [LKNewestMsgManager sharedInstance].content);
    //    }
    //    if([LKNewestMsgManager sharedInstance].content == NULL){
    //        [LKNewestMsgManager sharedInstance].content = wrap.m_nsPushContent;
    //    }
    //    if([LKNewestMsgManager sharedInstance].currentChat == NULL){
    //        [LKNewestMsgManager sharedInstance].currentChat = [(BaseMsgContentViewController*)[[LKNewestMsgManager sharedInstance] getCurrentVC]getCurrentChatName];
    //    }
    
    if(![wrap.m_nsPushContent isEqual: @""] && wrap.m_nsPushContent != NULL){
        [LKNewestMsgManager sharedInstance].username = msg;
        NSLog(@"%@", [LKNewestMsgManager sharedInstance].username);
        [LKNewestMsgManager sharedInstance].content = wrap.m_nsPushContent;
        NSLog(@"%@", [LKNewestMsgManager sharedInstance].content);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LkWechatMessageNotification" object:nil];
        
    }
    
    
    CHSuper2(CMessageMgr, AsyncOnAddMsg, msg, MsgWrap, wrap);
    
}

CHConstructor{
    CHLoadLateClass(CMessageMgr);
    CHClassHook2(CMessageMgr, AsyncOnAddMsg, MsgWrap);
}

