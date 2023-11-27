//
//  Profile.h
//  MOTPPushAPI
//
//  Created by Leo on 2019/1/28.
//  Copyright © 2019年 Changing Information Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHGProfile : NSObject

@property NSString* type;
@property NSString* clientID;
@property NSString* pushID;

@end

NS_ASSUME_NONNULL_END
