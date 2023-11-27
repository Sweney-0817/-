//
//  MOTPPushAPI.h
//  MOTPPushAPI
//
//  Created by ChangingTec on 2015/7/14.
//  Copyright (c) 2015年 Changing Information Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "CHGRegInfo.h"
#import "CHGProfile.h"
#import "CHGUpdateInfo.h"
#import "CHGMOTPProfile.h"
#import "CHGErrorCode.h"

@interface MOTPPushAPI : NSObject

#pragma mark - 資訊處理
+ (NSString*)getVersion;
+ (NSString*)getDeviceID;
+ (int)getErrorCode;

#pragma mark - Push ID
+ (int)setPushID:(NSData*)deviceToken;
+ (NSArray<CHGUpdateInfo *>*)getUpdateInfo;

#pragma mark - 多Profile 處理
+ (CHGRegInfo*)addProfile:(NSString*)jsonStr;
+ (CHGProfile*)getProfile:(NSString *)clientID;
+ (int)updateProfile:(NSString *)clientID;
+ (BOOL)removeProfile:(NSString *)clientID;
+ (NSArray*)getProfileList;

#pragma mark - Push解密
+ (NSString*)decryptPushMsg:(NSDictionary*)msginfo;

#pragma mark - OTP
+ (NSString*)getTbOTP:(NSString*)clientID;

#pragma mark - CR OTP
+ (NSString *)getCrOTP:(NSString*)clientID cr:(NSString*)cr;

+ (void)setCurrentToken:(NSString*) clientID;
+ (BOOL)checkCurrentToken:(NSDictionary*) msginfo;
@end
