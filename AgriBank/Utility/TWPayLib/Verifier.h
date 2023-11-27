//
//  Verifier.h
//  FiscQRLib
//
//  Created by Tony on 2018/4/23.
//  Copyright © 2018年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"
#import "DataModel.h"
#import "EmvcoTag.h"
#import "EmvcoModel.h"
#import "NSMutableArray+Stack.h"
#import "NSString+isNumeric.h"

@interface Verifier : NSObject

@property DataModel           *model;
@property EmvcoModel          *emvco_model;
@property NSString            *txn_msg;
@property NSMutableArray      *root_records;
@property NSMutableDictionary *supported_scheme;
@property BOOL                isCRCerror;
@property NSString            *crc;
@property BOOL                isLoadTagTable;
@property BOOL                isEMV;
@property BOOL                isTWQRP;

typedef enum _CardType{
    NONE = -1,
    VISA = 1,
    MASTER = 2,
    JCB = 4,
    QRP = 8
} CardType;

- (id) initWithDataFile: (NSString *) filePath;
- (BOOL) checkSize;
- (BOOL) checkPayload;

- (NSString *) calcCRC;

- (BOOL) checkCRC;

- (NSArray *) getSupportScheme;

- (int) getQRtype;

- (NSString *)  convertToTaiwanPay;

- (int) rootParse;

- (int) fullParse;

- (int) dumpRecord;

- (BOOL) isNestedTagId: (NSString *)tagid;

- (int) checkTagFormatWithID:(NSString *) tag_id
                       Value:(NSString *) value
                     Lenghth:(NSString *) length
                       Error:(NSString *) errmsg;

@end
