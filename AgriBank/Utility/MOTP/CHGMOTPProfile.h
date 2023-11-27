//
//  MOTPProfile.h
//  MOTPPushAPI
//
//  Created by Leo on 2019/1/28.
//  Copyright © 2019年 Changing Information Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHGProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHGMOTPProfile : CHGProfile

@property NSString* ik;
@property NSString* ikName;
@property NSString* mode;
@property NSString* account;

//3.8 push token(3.8 才有的欄位)
@property NSString* serverKey;
@property NSString* pushUrl;
@property NSString* flag;
@property NSString* sn;


- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

NS_ASSUME_NONNULL_END
