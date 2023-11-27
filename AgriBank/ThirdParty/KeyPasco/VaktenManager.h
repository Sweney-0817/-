//
//  VaktenManager.h
//  LydsecVakten
//
//  Created by Jinfu Wang on 2016/4/22.
//  Copyright © 2016年 Jinfu Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Vakten/Vakten.h>
#import <Vakten/VaktenPKI.h>

@interface VaktenManager : NSObject

typedef void(^CompleteHandle)(VResultCode resultCode);
typedef void(^CompleteTasksHandle)(VResultCode resultCode, NSArray *tasks);

+ (instancetype)sharedInstance;

//- (void)setDeviceToken:(NSData *)deviceToken;

- (void)associationOperationWithAssociationCode:(NSString *)associationCode complete:(CompleteHandle)handle;

- (void)authenticateOperationWithSessionID:(NSString *)sessionID complete:(CompleteHandle)handle;

- (void)getTasksOperationWithComplete:(CompleteTasksHandle)handle;

- (void)signTaskOperationWithTask:(VTask *)task complete:(CompleteHandle)handle;

- (void)cancelTaskOperationWithTask:(VTask *)task complete:(CompleteHandle)handle;

- (VGeoOTP*)generateGeoOTPCode;

//- (NSString *)getOneTimePod;

//- (void)nextOneTimePod;

- (BOOL)isJailbroken;
@end
