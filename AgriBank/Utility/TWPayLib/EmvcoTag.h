//
//  EmvcoRecord.h
//  TWPayLibTest
//
//  Created by FISC on 2018/5/14.
//  Copyright © 2018年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmvcoTag : NSObject

@property NSString *tag_id;
@property NSString *tag_name;
@property NSString *format;
@property NSString *compare_method;
@property int      length;

- (instancetype) initWithDictionary: (NSDictionary *) dict;
@end
