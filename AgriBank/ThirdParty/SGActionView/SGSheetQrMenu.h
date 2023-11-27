//
//  SGSheetMenu.h
//  SGActionView
//
//  Created by Sagi on 13-9-6.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBaseMenu.h"

@interface SGSheetQrMenu : SGBaseMenu

- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles;

- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles subTitles:(NSArray *)subTitles;
//搜尋用輸入匡 10206 by sweney
- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles findText:(NSString *)findText;

@property (nonatomic, assign) NSUInteger selectedItemIndex;
@property (nonatomic, assign) NSString* FindTextString;

- (void)triggerSelectedAction:(void(^)(NSInteger))actionHandle;

@end
