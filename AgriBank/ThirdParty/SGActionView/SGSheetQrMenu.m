//
//  SGSheetMenu.m
//  SGActionView
//
//  Created by Sagi on 13-9-6.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import "SGSheetQrMenu.h"
#import <QuartzCore/QuartzCore.h>

#define kMAX_SHEET_TABLE_HEIGHT   400

@interface SGSheetQrMenu () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *FindTextField;//搜尋用輸入匡 10206 by sweney
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *subItems;
@property (nonatomic, strong) NSArray *showitems;

@property (nonatomic, strong) void(^actionHandle)(NSInteger);
@end

@implementation SGSheetQrMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = BaseMenuBackgroundColor(self.style);

        _selectedItemIndex = NSIntegerMax;
        _items = [NSArray array];
        _showitems = [NSArray array];
        _subItems = [NSArray array];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = BaseMenuTextColor(self.style);
        [self addSubview:_titleLabel];
        
        //搜尋用輸入匡 10206 by sweney
        _FindTextField =[[UITextField alloc] initWithFrame:self.bounds];
        _FindTextField.delegate = self;
        _FindTextField.borderStyle = UITextBorderStyleLine;
        _FindTextField.font = [UIFont boldSystemFontOfSize:17];
        _FindTextField.textColor = BaseMenuTextColor(self.style);
        _FindTextField.placeholder = @"請輸入銀行代碼或關鍵字查詢";
        [self addSubview:_FindTextField];
        
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self addSubview:_tableView];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles
{
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self setupWithTitle:title items:itemTitles subItems:nil];
    }
    return self;
}

//搜尋用輸入匡 10206 by sweney
- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles findText:(NSString *)findText
{
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self setupWithTitle:title items:itemTitles subItems:nil];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles subTitles:(NSArray *)subTitles
{
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self setupWithTitle:title items:itemTitles subItems:subTitles];
    }
    return self;
}

- (void)setupWithTitle:(NSString *)title items:(NSArray *)items subItems:(NSArray *)subItems;
{
    _titleLabel.text = title;
    _items = items;
    _showitems = items;
    _subItems = subItems;
    _FindTextField.text = @"";
}

- (void)setStyle:(SGActionViewStyle)style{
    _style = style;
    
    self.backgroundColor = BaseMenuBackgroundColor(style);
    self.titleLabel.textColor = BaseMenuTextColor(style);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float height = 0;
    float table_top_margin = 0;
    float table_bottom_margin = 50;
    
    self.titleLabel.frame = (CGRect){CGPointZero, CGSizeMake(self.bounds.size.width, 40)};
    height += self.titleLabel.bounds.size.height;
    height += table_top_margin;
    
    //搜尋用輸入匡 10206 by sweney
    self.FindTextField.frame = CGRectMake(self.bounds.size.width * 0.05, height, self.bounds.size.width * 0.9, self.FindTextField.intrinsicContentSize.height);
    height += self.FindTextField.intrinsicContentSize.height;
    self.FindTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    float contentHeight = self.tableView.contentSize.height;
    if (contentHeight > kMAX_SHEET_TABLE_HEIGHT) {
        contentHeight = kMAX_SHEET_TABLE_HEIGHT;
        self.tableView.scrollEnabled = YES;
    }else{
        self.tableView.scrollEnabled = NO;
    }
    self.tableView.frame = CGRectMake(self.bounds.size.width * 0.05, height, self.bounds.size.width * 0.9, contentHeight);
    height += self.tableView.bounds.size.height;
    
    height += table_bottom_margin;
    
    self.bounds = (CGRect){CGPointZero, CGSizeMake(self.bounds.size.width, height)};
}

#pragma mark - 

- (void)triggerSelectedAction:(void (^)(NSInteger))actionHandle
{
    self.actionHandle = actionHandle;
}

#pragma mark - 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showitems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.subItems.count > 0) {
        return 55;
    }else{
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = BaseMenuTextColor(self.style);
        cell.detailTextLabel.textColor = BaseMenuTextColor(self.style);
    }
    cell.textLabel.text = self.showitems[indexPath.row];
    if (self.subItems.count > indexPath.row) {
        NSString *subTitle = self.subItems[indexPath.row];
        if (![subTitle isEqual:[NSNull null]]) {
            cell.detailTextLabel.text = subTitle;
        }
    }
    if (self.selectedItemIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}
 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedItemIndex != indexPath.row) {
        self.selectedItemIndex = indexPath.row;
        [tableView reloadData];
    }
    if (self.actionHandle) {
        double delayInSeconds = 0.15;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSInteger indexValue = [self.items indexOfObject:self.showitems[indexPath.row]];
            self.actionHandle(indexValue);
        });
    }
}
 
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *tempFindStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
      
    NSUInteger tfLength = [tempFindStr length];
    
    if (tfLength > 0){
        NSString *containStr = tempFindStr;
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", containStr];
        _showitems = [_items filteredArrayUsingPredicate: pre];
    }
    else{
        _showitems = _items;
    }
    [_tableView reloadData];
    return YES;
 
}

@end
