//
//  NSMutableArray+Stack.h
//  FiscQRLib
//
//  Created by Tony on 2018/4/23.
//  Copyright © 2018年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

@interface NSMutableArray (Stack)

- (BOOL) isEmpty;

//------- integer part ----------
- (void) pushi: (int)limit;
- (int) popi;
- (int) topi;
- (NSString *) dumpi;

//------- pointer part ----------
- (void) pushp: (NSMutableArray *)obj;
- (NSMutableArray *) popp;
- (NSMutableArray *) topp;
- (NSString *) dumpp;

//------- string part ----------
- (void) pushs: (NSString *)obj;
- (NSString *) pops;
- (NSString *) tops;
- (NSString *) dumps;

@end
