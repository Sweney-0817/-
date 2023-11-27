//
//  DataModel.h
//  FiscQRLib
//
//  Created by Tony on 2018/4/23.
//  Copyright © 2018年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "Constant.h"

@interface DataModel : NSObject

@property NSMutableDictionary *json;
@property uint                 current_record_no;
@property NSMutableDictionary *index_ByFullTagID;
@property NSMutableDictionary *twqrp_json;

- (instancetype) init;
- (void) insertRecordWithParenTagID:(NSString *)parent_tagid
                              TagID:(NSString *)tagid
                             Length:(NSUInteger)length
                              Value:(NSString *)value;

- (void) saveToJsonFile;
- (void) saveTWQRPJsonFile;
@end
