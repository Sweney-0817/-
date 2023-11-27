//
//  EmvcoModel.h
//  TWPayLibTest
//
//  Created by FISC on 2018/5/14.
//  Copyright © 2018年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmvcoTag.h"
#import "Constant.h"

@interface EmvcoModel : NSObject

// NSDictionary(TagID, TagName, Format, CompareMethod, Length)
@property NSDictionary        *tag_source;    // emvco tag source (read from JSON file)
@property NSMutableDictionary *tagID_index;   // create index by tagID ex: { tagID, index }
@property NSMutableDictionary *tagName_index; // create index by tagName ex: { tagName, index }

- (instancetype) init;
- (EmvcoTag *) getRecordByTagID:(NSString *) tag_id;
@end
