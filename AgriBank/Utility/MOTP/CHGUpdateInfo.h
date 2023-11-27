//
//  UpdateInfo.h
//  MOTPPushAPI
//
//  Created by Leo on 2019/1/28.
//  Copyright © 2019年 Changing Information Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHGUpdateInfo : NSObject

@property NSString *clientID;
@property NSString *account;
@property NSString *serverURL;
@property NSString *SN;
@property NSString *encPushID;


@end

NS_ASSUME_NONNULL_END
