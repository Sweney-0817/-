//
//  Record.h
//  FiscQRLib
//
//  Created by Tony on 2018/4/23.
//  Copyright © 2018年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSString;

@interface Record : NSObject

@property NSString *ParentTagID;
@property NSString *TagID;
@property NSInteger Length;
@property NSString *Value;
@property BOOL     hasChild;
@property NSMutableArray *child_records;

- (instancetype) initWithParentTagID:(NSString *)parent_tagid TagID:(NSString *)tagid Length:(NSInteger)length Value:(NSString *)value;

- (NSString *) toString;

@end
