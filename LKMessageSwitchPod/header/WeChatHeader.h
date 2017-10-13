//
//  WeChatHeader.h
//  WechatPod
//
//  Created by monkey on 2017/8/2.
//  Copyright © 2017年 Coder. All rights reserved.
//

#ifndef WeChatHeader_h
#define WeChatHeader_h

#import <UIKit/UIKit.h>

@interface CMessageWrap

@property(nonatomic, strong) NSString* m_nsContent;        //发送消息的内容
@property(nonatomic, strong) NSString* m_nsToUsr;          //发送人
@property(nonatomic, strong) NSString* m_nsFromUsr;        //接收人
@property(nonatomic, strong) NSMutableString *m_nsPushContent;
@property(nonatomic, assign) unsigned long m_uiStatus;
@property(nonatomic, assign) unsigned long m_uiCreateTime;
@property(nonatomic, assign) unsigned long m_uiMessageType;
@property(nonatomic, assign) unsigned long m_uiGameType;
@property(nonatomic, assign) unsigned long m_uiGameContent;
@property(nonatomic, strong) NSString *m_nsEmoticonMD5;

+ (BOOL)isSenderFromMsgWrap:(CMessageWrap*) msgWrap;

- (CMessageWrap*)initWithMsgType:(int) type;

@end

@interface MMServiceCenter

- (id)getService:(Class) name;
- (id)defaultCenter;

@end

@interface CMessageMgr

- (void)AddLocalMsg:(NSString*)from MsgWrap:(CMessageWrap*) msgWrap;
- (void)AsyncOnAddMsg:(NSString*)msg MsgWrap:(CMessageMgr*) wrap;

@end

@interface GameController : NSObject

+ (NSString*)getMD5ByGameContent:(NSInteger) content;

@end

@interface ManualAuthAesReqData

-(void)setBundleId:(NSString*) bundleID;

@end

@interface MMUIViewController : UIViewController

@property(nonatomic, strong) UIView *view;
//@property(nonatomic ,strong) UIButton *btn;

//- (void)popViewControllerAnimated:(BOOL)animated;
//- (void)backToMsgContentViewController;
@end

@interface CContact

@end

@interface MMMsgLogicManager

-(void)PushOtherBaseMsgControllerByContact:(CContact*)contact navigationController:(UINavigationController*)navi animated:(BOOL)animated;
@end


@interface CContactMgr

-(CContact*)getContactByName:(NSString*)name;
@end

@interface CAppViewControllerManager

+ (UINavigationController*)getCurrentNavigationController;
@end

@interface BaseMsgContentViewController

- (id)getCurrentChatName;

@end


#endif /* WeChatHeader_h */

