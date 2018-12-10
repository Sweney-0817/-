//
//  MWQRPTransactionInfo.m
//  MobileWallet
//
//  Created by Jobs NO.1 on 2017/8/7.
//  Copyright © 2017年 Arthur Tseng. All rights reserved.
//

#import "MWQRPTransactionInfo.h"
//#import "SWUtility.h"

typedef NS_ENUM(NSInteger, QRPTransactionPathIndex) {
    QRPTransactionPathIndex_MerchantName = 0,   // 名稱
    QRPTransactionPathIndex_CountryCode,        // 國別碼
    QRPTransactionPathIndex_TransactionType,    // 交易型態
    QRPTransactionPathIndex_QRVersion,          // 版本
    QRPTransactionPathIndex_Count
};

typedef NS_ENUM(NSInteger, QRPTransactionQueryTag) {
    QRPTransactionQueryTag_TxnAmt = 1,          // 交易金額
    QRPTransactionQueryTag_OrderNbr,            // 訂單編號
    QRPTransactionQueryTag_SecureCode,          // 安全碼
    QRPTransactionQueryTag_Deadlinefinal,       // 繳納期限(截止日)
    QRPTransactionQueryTag_TransfereeBank,      // 轉入行代碼
    QRPTransactionQueryTag_TransfereeAccount,   // 轉入帳號
    QRPTransactionQueryTag_NoticeNbr,           // 銷帳編號
    QRPTransactionQueryTag_OtherInfo,           // 其他資訊
    QRPTransactionQueryTag_Note,                // 備註
    QRPTransactionQueryTag_TxnCurrencyCode,     // 交易幣別
    QRPTransactionQueryTag_AcqInfo,             // 收單行資訊
    QRPTransactionQueryTag_QrExpirydate,        // QR Code效期
    QRPTransactionQueryTag_OrgTxnData,          // 原始交易資訊
    QRPTransactionQueryTag_FeeInfo,             // 費用資訊
    QRPTransactionQueryTag_Charge,              // 使用者支付手續費
    QRPTransactionQueryTag_FeeName              // 費用名稱
};

static NSString * const kQRPTransactionScheme = @"TWQRP";

// 交易型別
static NSString * const kQRPTransacionTypePurchase  = @"01";
static NSString * const kQRPTransacionTypeTransfer  = @"02";
static NSString * const kQRPTransacionTypeBill      = @"03";

// 明文資料內容識別
static NSString * const kQRPParameterClearText      = @"D";
// 修改資料內容識別
static NSString * const kQRPParameterModifyText     = @"M";
// 密文資料內容識別
static NSString * const kQRPParameterEncryptedText  = @"E";

// 收單行資訊欄位長度
// 購物交易
/**
 * 收單行代號長度(3 bytes)
 */
static const NSUInteger kQRPAcqInfoAcqBankLength = 3;

/**
 * 特店代號長度(15 bytes)
 */
static const NSUInteger kQRPAcqInfoMerchantIdLength = 15;

/**
 * 端末代號長度(8 bytes)
 */
static const NSUInteger kQRPAcqInfoTerminalIdLength = 8;

/**
 * 費用代號長度(8 bytes)
 */
static const NSUInteger kQRPAcqInfoFeeRefIdLength = 8;

// 轉帳交易
/**
 * 轉入行代碼長度(3 bytes)
 */
static const NSUInteger kQRPAcqInfoTransfereeBankLength = 3;

/**
 * 轉入帳號長度(16 bytes)
 */
static const NSUInteger kQRPAcqInfoTransfereeAccountLength = 16;

// 繳費交易
/**
 * 費用長度(8 bytes)
 */
static const NSUInteger kQRPAcqInfoBillTypeLength = 8;

@interface MWQRPTransactionInfo ()

// path
@property (retain, nonatomic) NSString *m_strMerchantName;
@property (retain, nonatomic) NSString *m_strCountryCode;
@property (retain, nonatomic) NSString *m_strTransactionType;
@property (retain, nonatomic) NSString *m_strQrVersion;
// query
@property (retain, nonatomic) NSString *m_strTxnAmt;
@property (retain, nonatomic) NSString *m_strOrderNbr;
@property (retain, nonatomic) NSString *m_strSecureCode;
@property (retain, nonatomic) NSString *m_strDeadlinefinal;
@property (retain, nonatomic) NSString *m_strTransfereeBank;
@property (retain, nonatomic) NSString *m_strTransfereeAccount;
@property (retain, nonatomic) NSString *m_strNoticeNbr;
@property (retain, nonatomic) NSString *m_strOtherInfo;
@property (retain, nonatomic) NSString *m_strNote;
@property (retain, nonatomic) NSString *m_strTxnCurrencyCode;
@property (retain, nonatomic) NSString *m_strAcqInfo;
@property (retain, nonatomic) NSString *m_strQrExpirydate;
@property (retain, nonatomic) NSString *m_strOrgTxnData;
@property (retain, nonatomic) NSString *m_strFeeInfo;
@property (retain, nonatomic) NSString *m_strCharge;
@property (retain, nonatomic) NSString *m_strFeeName;
@property (retain, nonatomic) NSMutableDictionary *m_dicD;
@property (retain, nonatomic) NSMutableDictionary *m_dicM;
@property (retain, nonatomic) NSMutableDictionary *m_dicE;
@property (retain, nonatomic) NSMutableDictionary *m_dicSecureDatas;

// others
@property (retain, nonatomic) NSMutableDictionary *m_dicAcqInfo;
/**
 * 紀錄QRCode欄位
 */
@property (retain, nonatomic) NSMutableArray *m_arQueryTags;
/**
 * 紀錄重複的QRCode欄位
 */
@property (retain, nonatomic) NSMutableArray *m_arSameQueryTags;

@end

@implementation MWQRPTransactionInfo
{
    /**
     * 收單行代號 in 收單行資訊(acqInfo)
     */
    NSString *m_strAcqBank;
    
    /**
     * 特店代號 in 收單行資訊(acqInfo)
     */
    NSString *m_strMerchantId;
    
    /**
     * 端末機代號 in 收單行資訊(acqInfo)
     */
    NSString *m_strTerminalId;

    /**
     * 費用代號 in 收單行資訊(acqInfo)
     */
    NSString *m_strFeeRefId;

    /**
     * 購物轉帳 轉入行代碼 in 收單行資訊(acqInfo)
     */
    NSString *m_strTransfereeBankForPurchasing;

    /**
     * 購物轉帳 轉入帳號 in 收單行資訊(acqInfo)
     */
    NSString *m_strTransfereeAccountForPurchasing;
}

#pragma mark - public Setters & getters

- (NSString *)countryCode {
    return self.m_strCountryCode;
}

- (NSString *)acqBank {
    if (nil == m_strAcqBank &&
        nil != _m_strAcqInfo &&
        (self.transactionType == QRPTransactionType_Purchase ||
         self.transactionType == QRPTransactionType_Bill ||
         self.transactionType == QRPTransactionType_TransferPurchase)) {
            
            NSString *strPaymentType = self.paymentType;
            if (NO == [strPaymentType isEqualToString:@"51"]) {
                NSString *strAcqInfo = self.m_dicAcqInfo[strPaymentType];
                m_strAcqBank = [[strAcqInfo substringToIndex:kQRPAcqInfoAcqBankLength] copy];
            }
        }
    return m_strAcqBank;
}

- (NSString *)merchantId {
    if (nil == m_strMerchantId &&
        nil != _m_strAcqInfo &&
        (self.transactionType == QRPTransactionType_Purchase ||
         self.transactionType == QRPTransactionType_Bill ||
         self.transactionType == QRPTransactionType_TransferPurchase)) {
  
            NSString *strPaymentType = self.paymentType;
            if (NO == [strPaymentType isEqualToString:@"51"]) {
                NSString *strAcqInfo = self.m_dicAcqInfo[strPaymentType];
                m_strMerchantId = [[strAcqInfo substringWithRange:NSMakeRange(kQRPAcqInfoAcqBankLength, kQRPAcqInfoMerchantIdLength)] copy];
            }
        }
    return m_strMerchantId;
}

- (NSString *)terminalId {
    if (nil == m_strTerminalId &&
        nil != _m_strAcqInfo &&
        (self.transactionType == QRPTransactionType_Purchase ||
         self.transactionType == QRPTransactionType_Bill ||
         self.transactionType == QRPTransactionType_TransferPurchase)) {
            
            NSString *strPaymentType = self.paymentType;
            if (NO == [strPaymentType isEqualToString:@"51"]) {
                NSString *strAcqInfo = self.m_dicAcqInfo[strPaymentType];
                m_strTerminalId = [[strAcqInfo substringWithRange:NSMakeRange((kQRPAcqInfoAcqBankLength + kQRPAcqInfoMerchantIdLength), kQRPAcqInfoTerminalIdLength)] copy];
            }
        }
    return m_strTerminalId;
}

- (NSString *)feeRefId {
    if (nil == m_strFeeRefId &&
        nil != _m_strAcqInfo &&
        (self.transactionType == QRPTransactionType_Purchase ||
         self.transactionType == QRPTransactionType_Bill ||
         self.transactionType == QRPTransactionType_TransferPurchase)) {

            NSString *strPaymentType = self.paymentType;
            if (NO == [strPaymentType isEqualToString:@"51"]) {
                NSString *strAcqInfo = self.m_dicAcqInfo[strPaymentType];
                m_strFeeRefId = [[strAcqInfo substringWithRange:NSMakeRange((kQRPAcqInfoAcqBankLength + kQRPAcqInfoMerchantIdLength + kQRPAcqInfoTerminalIdLength), kQRPAcqInfoFeeRefIdLength)] copy];
            }
        }
    return m_strFeeRefId;
}

- (NSString *)transfereeBankForPurchasing {
    if (nil == m_strTransfereeBankForPurchasing &&
        nil != _m_strAcqInfo &&
        (self.transactionType == QRPTransactionType_TransferPurchase)) {
        
        NSString *strAcqInfo = self.m_dicAcqInfo[@"51"];
        if (strAcqInfo) {
            m_strTransfereeBankForPurchasing = [[strAcqInfo substringToIndex:kQRPAcqInfoTransfereeBankLength] copy];
        }
    }
    return m_strTransfereeBankForPurchasing;
}

- (NSString *)transfereeAccountForPurchasing {
    if (nil == m_strTransfereeAccountForPurchasing &&
        nil != _m_strAcqInfo &&
        (self.transactionType == QRPTransactionType_TransferPurchase)) {
        
        NSString *strAcqInfo = self.m_dicAcqInfo[@"51"];
        if (strAcqInfo) {
            m_strTransfereeAccountForPurchasing = [[strAcqInfo substringWithRange:NSMakeRange(kQRPAcqInfoTransfereeBankLength, kQRPAcqInfoTransfereeAccountLength)] copy];
        }
    }
    return m_strTransfereeAccountForPurchasing;
}

- (NSString *)acqInfo {
    return self.m_strAcqInfo;
}

- (NSString *)paymentType {
    
    NSString *strPaymentType = nil;
    
    if (0 < [self.m_dicAcqInfo allKeys].count)
    {
        for (NSString *paymentType in [self.m_dicAcqInfo allKeys]) {
            
            if ([paymentType isEqualToString:@"00"]) {
                strPaymentType = (nil == strPaymentType) ? paymentType : strPaymentType;
            }else if ([paymentType isEqualToString:@"01"] ||
                      [paymentType isEqualToString:@"02"] ||
                      [paymentType isEqualToString:@"51"] ) {
                strPaymentType = paymentType;
            }
        }
    }
    
    // for WS: action 201 checkQRCode, 購物交易PaymentType為"00"
    if (self.transactionType == QRPTransactionType_TransferPurchase) {
        strPaymentType = @"00";
    }
    
    return strPaymentType;
}

- (NSString *)secureCode {
    return self.m_strSecureCode;
}

- (NSString *)secureData {
    NSString *strSecureData = nil;
    
    NSMutableArray *arSecureDatas = [NSMutableArray array];
    
    for (NSString *strKey in [self.m_dicSecureDatas allKeys]) {
        NSString *strValue = self.m_dicSecureDatas[strKey];
        NSString *strSecureDataKeyWithValue = [NSString stringWithFormat:@"\"%@\":\"%@\"", strKey, strValue];
        [arSecureDatas addObject:strSecureDataKeyWithValue];
    }
    
    if (0 < arSecureDatas.count) {
        strSecureData = [NSString stringWithFormat:@"{%@}", [arSecureDatas componentsJoinedByString:@","]];
    }
    
    //    if (0 < [self.m_dicSecureDatas allKeys].count) {
    //        strSecureData = [self.m_dicSecureDatas JSONString];
    //    }
    
    return strSecureData;
}

- (NSString *)txnAmt {
    return self.m_strTxnAmt;
}

- (void)setTxnAmt:(NSString *)txnAmt {
    self.m_strTxnAmt = txnAmt;
}

- (NSString *)transfereeBank
{
    return self.m_strTransfereeBank;
}

- (NSString *)transfereeAccount
{
    return self.m_strTransfereeAccount;
}

- (NSString *)txnCurrencyCode
{
    return self.m_strTxnCurrencyCode;
}

- (NSString *)note
{
    NSString *strN = [_m_strNote stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return strN;
}

- (NSString *)merchantName {
    return self.m_strMerchantName;
}

- (NSString *)qrExpirydate {
    return self.m_strQrExpirydate;
}

- (NSString *)orderNumber {
    return self.m_strOrderNbr;
}

- (NSString *)deadlinefinal {
    return self.m_strDeadlinefinal;
}

- (NSString *)noticeNbr {
    return self.m_strNoticeNbr;
}

- (NSString *)feeInfo {
    return self.m_strFeeInfo;
}

- (NSString *)charge {
    return self.m_strCharge;
}

- (NSString *)feeName {
    if (self.m_strFeeName != nil)
    {
        return [self.m_strFeeName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return self.m_strFeeName;
}

- (NSDictionary *)MTypeDic
{
    return self.m_dicM;
}

- (NSDictionary *)DTypeDic
{
    return self.m_dicD;
}

- (NSDictionary *)ETypeDic
{
    return self.m_dicE;
}

- (QRPTransactionType)transactionType {
    
    if (_transactionType == QRPTransactionType_Unknown)
    {
        if ([_m_strTransactionType isEqualToString:kQRPTransacionTypePurchase]) {
            
            _transactionType = QRPTransactionType_Purchase;

            NSArray *arAcqInfos = [_m_strAcqInfo componentsSeparatedByString:@";"];
            for (NSString *strAcqInfo in arAcqInfos)
            {
                NSArray *arPaymentInfo = [strAcqInfo componentsSeparatedByString:@","];
                if (2 == arPaymentInfo.count) {
                    NSString *paymentType = arPaymentInfo.firstObject;
                    if ([paymentType isEqualToString:@"51"]) {
                        _transactionType = QRPTransactionType_TransferPurchase;
                        break;
                    }
                }
            }
        }else if ([_m_strTransactionType isEqualToString:kQRPTransacionTypeTransfer]) {
            _transactionType = QRPTransactionType_P2PTransfer;
        }else if ([_m_strTransactionType isEqualToString:kQRPTransacionTypeBill]) {
            _transactionType = QRPTransactionType_Bill;
        }else {
            _transactionType = QRPTransactionType_Unknown;
        }
    }
    return _transactionType;
}

#pragma mark - public methods

- (BOOL)isValidQRCodeFromat {
    
    if (![self isValidMerchantName]) {
        return NO;
    }
    if (![self isValidCountryCode]) {
        return NO;
    }
    if (![self isValidTransactionType]) {
        return NO;
    }
    if (![self isValidQrVersion]) {
        return NO;
    }

    BOOL bValid = NO;
    // 上述明文區(D類) 、修改區(M類) 、密文區(E類) 及其他擴充區(O類)的欄位名稱不可重複出現
    bValid = (self.m_arSameQueryTags.count == 0);
    if (!bValid)
    {
        NSLog(@"\n[QPCode error:欄位名稱重複出現] %@\n", self.m_arSameQueryTags);
        return NO;
    }

    // 現在僅提供M1欄位
    NSArray * ar = [self.m_dicM allKeys];
    if ([ar count] > 0)
    {
        bValid = ((self.transactionType == QRPTransactionType_Bill) && ([self.m_dicM objectForKey:@"1"] || [ar count] > 1));
        if (!bValid)
        {
            NSLog(@"\n[QPCode error:修改區僅提供M1] %@\n", self.m_dicM);
            return NO;
        }
    }

    if (bValid)
    {
        switch (self.transactionType)
        {
            case QRPTransactionType_Purchase:
            case QRPTransactionType_TransferPurchase:
                bValid = [self isValidPurchaseQRCode];
                break;
            case QRPTransactionType_P2PTransfer:
                bValid = [self isValidP2PTransferQRCode];
                break;
            case QRPTransactionType_Bill:
                bValid = [self isValidBillQRCode];
                break;
            case QRPTransactionType_Unknown:
                bValid = NO;
                break;
        }
    }
    
    return bValid;
}

- (BOOL)isValidPaymentType {
    
    BOOL bVaild = NO;
    
    // 原始AcqInfo中，以下三種支付工具類型，僅能三擇一檢核
    // 01: FISC金融卡2541
    // 02: FISC金融卡2525
    // 51: FISC金融卡(購物轉帳)
    BOOL bContainsFisc = NO;
    NSArray *arAcqInfos = [_m_strAcqInfo componentsSeparatedByString:@";"];
    for (NSString *strAcqInfo in arAcqInfos)
    {
        NSArray *arPaymentInfo = [strAcqInfo componentsSeparatedByString:@","];
        if (2 == arPaymentInfo.count)
        {
            NSString *strPaymentType = arPaymentInfo[0];
            if ([strPaymentType isEqualToString:@"00"]) {
                bVaild = YES;
            }else if ([strPaymentType isEqualToString:@"01"] ||
                      [strPaymentType isEqualToString:@"02"] ||
                      [strPaymentType isEqualToString:@"51"] ) {
                if (NO == bContainsFisc) {
                    bContainsFisc = YES;
                    bVaild = YES;
                }else {
                    bVaild = NO;
                    break;
                }
            }
        }
    }

    // 檢核有效支付資訊之PaymntType
    if (bVaild) {
        if (0 < [self.m_dicAcqInfo allKeys].count) {
            switch (self.transactionType) {
                case QRPTransactionType_Purchase:
                {
                    bVaild = (nil != self.m_dicAcqInfo[@"00"] ||
                              nil != self.m_dicAcqInfo[@"01"] ||
                              nil != self.m_dicAcqInfo[@"02"]);
                }
                    break;
                case QRPTransactionType_Bill:
                {
                    bVaild = (nil != self.m_dicAcqInfo[@"00"]);
                }
                    break;
                case QRPTransactionType_TransferPurchase:
                {
                    bVaild = (nil != self.m_dicAcqInfo[@"00"] && nil != self.m_dicAcqInfo[@"51"]);
                }
                    break;
                case QRPTransactionType_P2PTransfer:
                case QRPTransactionType_Unknown:
                    break;
            }
        }else {
            bVaild = NO;
        }
    }
    return bVaild;
    
    //    if (0 < [self.m_dicAcqInfo allKeys].count)
    //    {
    //        BOOL bVaild = NO;
    //        BOOL bContainsFisc = NO;
    //        for (NSString *strPaymentType in [self.m_dicAcqInfo allKeys])
    //        {
    //            if ([strPaymentType isEqualToString:@"00"]) {
    //                bVaild = YES;
    //            }else if ([strPaymentType isEqualToString:@"01"] ||
    //                      [strPaymentType isEqualToString:@"02"] ||
    //                      [strPaymentType isEqualToString:@"51"] ) {
    //                if (NO == bContainsFisc) {
    //                    bContainsFisc = YES;
    //                    bVaild = YES;
    //                }else {
    //                    bVaild = NO;
    //                    break;
    //                }
    //            }
    //        }
    //        return bVaild;
    //    }else {
    //        // 沒有支付工具類型
    //        return NO;
    //    }
}

- (void)parserSecureData:(NSString *)strSecureData {
    // secureData example: {E7:A123456789}
    NSString *strDecryptData = [strSecureData substringWithRange:NSMakeRange(1, strSecureData.length-2)];
    NSArray *arSecureDatas = [strDecryptData componentsSeparatedByString:@","];
    for (NSString *strSecureDataKeyWithValue in arSecureDatas) {
        
        NSRange range = [strSecureDataKeyWithValue rangeOfString:@":"];
        if (range.location != NSNotFound)
        {
            NSString *strTag = [strSecureDataKeyWithValue substringToIndex:range.location];
            NSString *strValue = [strSecureDataKeyWithValue substringFromIndex:(range.location + range.length)];
            if (strTag.length >= 2 /*&& strValue.length > 0*/) {
                NSString *strTagType = [strTag substringToIndex:1]; // E:密文
                if ([strTagType isEqualToString:kQRPParameterEncryptedText]) {
                    // 明文區
                    QRPTransactionQueryTag iTag = [[strTag substringFromIndex:1] integerValue];
                    [self setTxnValue:strValue forTag:iTag];
                    [self.m_dicE setObject:strValue forKey:[NSString stringWithFormat:@"%ld", (long)iTag]];
                }
            }
        }
    }
}

#pragma mark - private Setters & getters

- (NSDictionary *)m_dicD {
    if (nil == _m_dicD) {
        _m_dicD = [[NSMutableDictionary alloc] init];
    }
    return _m_dicD;
}

- (NSDictionary *)m_dicM {
    if (nil == _m_dicM) {
        _m_dicM = [[NSMutableDictionary alloc] init];
    }
    return _m_dicM;
}

- (NSDictionary *)m_dicSecureDatas {
    if (nil == _m_dicSecureDatas) {
        _m_dicSecureDatas = [[NSMutableDictionary alloc] init];
    }
    return _m_dicSecureDatas;
}

- (NSMutableDictionary *)m_dicAcqInfo {
    if (nil == _m_dicAcqInfo) {
        _m_dicAcqInfo = [[NSMutableDictionary alloc] init];
    }
    return _m_dicAcqInfo;
}

- (NSMutableArray *)m_arQueryTags {
    if (nil == _m_arQueryTags) {
        _m_arQueryTags = [[NSMutableArray alloc] init];
    }
    return _m_arQueryTags;
}

- (NSMutableArray *)m_arSameQueryTags {
    if (nil == _m_arSameQueryTags) {
        _m_arSameQueryTags = [[NSMutableArray alloc] init];
    }
    return _m_arSameQueryTags;
}

// 收單行資訊
- (void)setM_strAcqInfo:(NSString *)strAcqInfo {
    if (_m_strAcqInfo != strAcqInfo) {
        [_m_strAcqInfo release];
        _m_strAcqInfo = [strAcqInfo retain];
        
        // 支付工具類型處理
        if (0 < self.m_dicAcqInfo.count) {
            [self.m_dicAcqInfo removeAllObjects];
        }
        
        NSArray *arAcqInfos = [_m_strAcqInfo componentsSeparatedByString:@";"];
        for (NSString *strAcqInfo in arAcqInfos)
        {
            NSArray *arPaymentInfo = [strAcqInfo componentsSeparatedByString:@","];
            if (2 == arPaymentInfo.count)
            {
                NSString *paymentType = arPaymentInfo[0];
                NSString *acqInfo = arPaymentInfo[1];
                // 目前僅支援以下支付工具類型
                // 00: FISC金融卡2541
                // 01: FISC金融卡2541
                // 02: FISC金融卡2525
                // 51: FISC金融卡(轉帳)
                switch (self.transactionType) {
                    case QRPTransactionType_Purchase:
                    {
                        if (([paymentType isEqualToString:@"00"] || [paymentType isEqualToString:@"01"] || [paymentType isEqualToString:@"02"]) &&
                            acqInfo.length == (kQRPAcqInfoAcqBankLength+kQRPAcqInfoMerchantIdLength+kQRPAcqInfoTerminalIdLength)) {
                            [self.m_dicAcqInfo setObject:acqInfo forKey:paymentType];
                        }
                    }
                        break;
                    case QRPTransactionType_Bill:
                    {
                        if ([paymentType isEqualToString:@"00"] &&
                            acqInfo.length == (kQRPAcqInfoAcqBankLength+kQRPAcqInfoMerchantIdLength+kQRPAcqInfoTerminalIdLength+kQRPAcqInfoBillTypeLength)) {
                            [self.m_dicAcqInfo setObject:acqInfo forKey:paymentType];
                        }
                    }
                        break;
                    case QRPTransactionType_TransferPurchase:
                    {
                        if ([paymentType isEqualToString:@"00"] &&
                            acqInfo.length == (kQRPAcqInfoAcqBankLength+kQRPAcqInfoMerchantIdLength+kQRPAcqInfoTerminalIdLength)) {
                            [self.m_dicAcqInfo setObject:acqInfo forKey:paymentType];
                        }else if ([paymentType isEqualToString:@"51"] &&
                            acqInfo.length == (kQRPAcqInfoTransfereeBankLength + kQRPAcqInfoTransfereeAccountLength)) {
                            [self.m_dicAcqInfo setObject:acqInfo forKey:paymentType];
                        }
                    }
                        break;
                    case QRPTransactionType_P2PTransfer:
                    case QRPTransactionType_Unknown:
                        break;
                }
            }
        }
    }
}

#pragma mark - private methods

- (NSString *)getEncryptKeyWithTag:(QRPTransactionQueryTag)tag {
    return [NSString stringWithFormat:@"%@%ld", kQRPParameterEncryptedText, (long)tag];
}

- (void)setTxnValue:(NSString *)value forTag:(QRPTransactionQueryTag)tag {
    switch (tag) {
        case QRPTransactionQueryTag_TxnAmt:
            self.m_strTxnAmt = value;
            break;
        case QRPTransactionQueryTag_OrderNbr:
            self.m_strOrderNbr = value;
            break;
        case QRPTransactionQueryTag_SecureCode:
            self.m_strSecureCode = value;
            break;
        case QRPTransactionQueryTag_Deadlinefinal:
            self.m_strDeadlinefinal = value;
            break;
        case QRPTransactionQueryTag_TransfereeBank:
            self.m_strTransfereeBank = value;
            break;
        case QRPTransactionQueryTag_TransfereeAccount:
            self.m_strTransfereeAccount = value;
            break;
        case QRPTransactionQueryTag_NoticeNbr:
            self.m_strNoticeNbr = value;
            break;
        case QRPTransactionQueryTag_OtherInfo:
            self.m_strOtherInfo = value;
            break;
        case QRPTransactionQueryTag_Note:
            self.m_strNote = value;
            break;
        case QRPTransactionQueryTag_TxnCurrencyCode:
            self.m_strTxnCurrencyCode = value;
            break;
        case QRPTransactionQueryTag_AcqInfo:
            self.m_strAcqInfo = value;
            break;
        case QRPTransactionQueryTag_QrExpirydate:
            self.m_strQrExpirydate = value;
            break;
        case QRPTransactionQueryTag_OrgTxnData:
            self.m_strOrgTxnData = value;
            break;
        case QRPTransactionQueryTag_FeeInfo:
            self.m_strFeeInfo = value;
            break;
        case QRPTransactionQueryTag_Charge:
            self.m_strCharge = value;
            break;
        case QRPTransactionQueryTag_FeeName:
            self.m_strFeeName = value;
            break;
    }
}

/**
 * 檢核特店名稱
 */
- (BOOL)isValidMerchantName {
    if (nil != _m_strMerchantName) {
        if (_m_strMerchantName.length >= 1 && _m_strMerchantName.length <= 20) {
            return YES;
        }else {
            NSLog(@"\n[QPR error:格式錯誤] 特店名稱:%@\n", _m_strMerchantName);
        }
    }else {
        NSLog(@"\n[QPCode error:無此欄位] 特店名稱\n");
    }
    return NO;
}

/**
 * 檢核國別碼
 */
- (BOOL)isValidCountryCode {
    if (nil != _m_strCountryCode) {
        if ([self CheckString:_m_strCountryCode isValidWithRegex:@"^\\d{3}$"]) {
            return YES;
        }else {
            NSLog(@"\n[QPCode error:格式錯誤] 國別碼:%@\n", _m_strCountryCode);
        }
    }else {
        NSLog(@"\n[QPCode error:無此欄位] 國別碼\n");
    }
    return NO;
}

/**
 * 檢核交易型態
 */
- (BOOL)isValidTransactionType {
    if (nil != _m_strTransactionType) {
        if ([_m_strTransactionType isEqualToString:@"01"] ||
            [_m_strTransactionType isEqualToString:@"02"] ||
            [_m_strTransactionType isEqualToString:@"03"] ) {
            return YES;
        }else {
            NSLog(@"\n[QPCode error:無此交易類型] 交易類型:%@\n", _m_strTransactionType);
        }
    }else {
        NSLog(@"\n[QPCode error:無此欄位] 交易類型\n");
    }
    return NO;
}

/**
 * 檢核版本
 */
- (BOOL)isValidQrVersion {
    
    if (nil != _m_strQrVersion) {
        return YES;
    }else {
        NSLog(@"\n[QPCode error:無此欄位] 版本\n");
        return NO;
    }
}

/**
 * 檢核交易金額
 */
- (BOOL)isValidTxnAmtIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strTxnAmt) {
        bValid = [self CheckString:_m_strTxnAmt isValidWithRegex:@"[0-9]{3,12}"];
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 交易金額:%@\n", _m_strTxnAmt);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_TxnAmt];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 交易金額\n");
    }
    return bValid;
}

/**
 * 檢核訂單編號
 */
- (BOOL)isValidOrderNbrIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strOrderNbr) {
        bValid = (_m_strOrderNbr.length >= 1 && _m_strOrderNbr.length <= 19);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 訂單編號:%@\n", _m_strOrderNbr);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_OrderNbr];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 訂單編號\n");
    }
    return bValid;
}

/**
 * 檢核安全碼
 */
- (BOOL)isValidSecureCodeIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strSecureCode) {
        bValid = (_m_strSecureCode.length == 12);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 安全碼:%@\n", _m_strOrderNbr);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_SecureCode];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 安全碼\n");
    }
    return bValid;
}

/**
 * 檢核繳納期限(截止日)
 */
- (BOOL)isValidDeadlinefinalIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strDeadlinefinal) {
        bValid = [self CheckString:_m_strDeadlinefinal isValidWithRegex:@"^\\d{6,8}$"];
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 繳納期限(截止日):%@\n", _m_strDeadlinefinal);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_Deadlinefinal];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 繳納期限(截止日)\n");
    }
    return bValid;
}

/**
 * 檢核轉入行代碼
 */
- (BOOL)isValidTransfereeBankIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strTransfereeBank) {
        bValid = [self CheckString:_m_strTransfereeBank isValidWithRegex:@"^\\d{3}$"];
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 轉入行代碼:%@\n", _m_strTransfereeBank);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_TransfereeBank];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 轉入行代碼\n");
    }
    return bValid;
}

/**
 * 檢核轉入帳號
 */
- (BOOL)isValidTransfereeAccountIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strTransfereeAccount) {
        bValid = [self CheckString:_m_strTransfereeAccount isValidWithRegex:@"[0-9]{16}"];
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 轉入帳號:%@\n", _m_strTransfereeAccount);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_TransfereeAccount];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 轉入帳號\n");
    }
    return bValid;
}

/**
 * 檢核銷帳編號
 */
- (BOOL)isValidNoticeNbrIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strNoticeNbr) {
        bValid = [self CheckString:_m_strNoticeNbr isValidWithRegex:@"^[a-zA-Z0-9]{1,16}$"];
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 銷帳編號:%@\n", _m_strNoticeNbr);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_NoticeNbr];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 銷帳編號\n");
    }
    return bValid;
}

/**
 * 檢核其他資訊
 */
- (BOOL)isValidOtherInfoIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    NSString *strO = [_m_strOtherInfo stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (nil != strO) {
        bValid = (strO.length >= 1 && strO.length <= 50);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 其他資訊:%@\n", _m_strOtherInfo);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_OtherInfo];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 其他資訊\n");
    }
    return bValid;
}

/**
 * 檢核備註
 */
- (BOOL)isValidNoteIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    NSString *strN = [_m_strNote stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (nil != strN) {
        bValid = (strN.length >= 1 && strN.length <= 20);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 備註:%@\n", _m_strNote);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_Note];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 備註\n");
    }
    return bValid;
}

/**
 * 檢核交易幣別
 */
- (BOOL)isValidTxnCurrencyCodeIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strTxnCurrencyCode) {
        bValid = [self CheckString:_m_strTxnCurrencyCode isValidWithRegex:@"^\\d{3}$"];
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 交易幣別:%@\n", _m_strTxnCurrencyCode);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_TxnCurrencyCode];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 交易幣別\n");
    }
    return bValid;
}

/**
 * 檢核收單行資訊
 */
- (BOOL)isValidAcqInfoIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    NSString *strAcq = [_m_strAcqInfo stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (nil != strAcq) {
        bValid = (strAcq.length >= 1 && strAcq.length <= 256);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 收單行資訊:%@\n", _m_strAcqInfo);

        NSString *strAcqInfo = self.m_dicAcqInfo[self.paymentType];
        if (self.transactionType == QRPTransactionType_TransferPurchase && strAcqInfo.length >= 19)
        {
            // 收單行代號 (3)
            NSString * TransBank = [self transfereeBankForPurchasing];
            bValid = (TransBank.length == 3);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 收單行代號:%@\n", TransBank);
            // 轉入帳號 (16)
            NSString * TransAcnt = [self transfereeAccountForPurchasing];
            bValid = (TransAcnt.length == 16);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 轉入帳號號:%@\n", TransAcnt);
        }
        else if ((self.transactionType == QRPTransactionType_Purchase|| self.transactionType == QRPTransactionType_Bill) && strAcqInfo.length >= 26)
        {
            // 轉入行代號 (3)
            NSString * Bank = [self acqBank];
            bValid = (Bank.length == 3);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 轉入行代號:%@\n", Bank);
            // 特店代號 (15)
            NSString * merID = [self merchantId];
            bValid = (merID.length == 15);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 特店代號:%@\n", merID);
            // 端末代碼 (8)
            NSString * terID = [self terminalId];
            bValid = (terID.length == 8);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 端末代碼:%@\n", terID);
            if (self.transactionType == QRPTransactionType_Bill && strAcqInfo.length >= 34)
            {
                // 費用代號 (8)
                NSString * feeID = [self feeRefId];
                bValid = (feeID.length == 8);
                if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用代碼:%@\n", feeID);
            }
        }
        else
        {
            bValid = NO;
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] acqInfo長度錯誤:%@\n", strAcqInfo);
        }
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_AcqInfo];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 收單行資訊\n");
    }
    return bValid;
}

/**
 * 檢核QRCode效期
 */
- (BOOL)isValidQrExpirydateIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strQrExpirydate) {
        bValid = [self CheckString:_m_strQrExpirydate isValidWithRegex:@"^\\d{14}$"];
        if (bValid) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyyMMddHHmmss";
            dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
            NSDate *qrExpiryDate = [dateFormatter dateFromString:_m_strQrExpirydate];
            bValid = (qrExpiryDate != nil);
            [dateFormatter release];
            if (!bValid) NSLog(@"\n[QPCode error:非有效日期格式] QRCode效期:%@\n", _m_strQrExpirydate);
        }else {
            NSLog(@"\n[QPCode error:格式錯誤] QRCode效期:%@\n", _m_strQrExpirydate);
        }
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_QrExpirydate];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] QRCode效期\n");
    }
    return bValid;
}

/**
 * 檢核費用資訊
 */
- (BOOL)isValidFeeInfoIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strFeeInfo) {
        bValid = (_m_strFeeInfo.length >= 1 && _m_strFeeInfo.length <= 50);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊:%@\n", _m_strFeeInfo);
        NSArray * arrInfo = [_m_strFeeInfo componentsSeparatedByString:@","];
        // 全國繳費網 - 繳費資訊(1~48)
        if ([[arrInfo objectAtIndex:0] isEqualToString:@"0"] && [arrInfo count] == 2) {
            bValid = ([[arrInfo objectAtIndex:1] length] >= 1 && [[arrInfo objectAtIndex:1] length] <= 48);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(全國繳費網):%@\n", [arrInfo objectAtIndex:1]);
        }
        // 汽燃費 (無spec)
        else if ([[arrInfo objectAtIndex:0] isEqualToString:@"1"]) {

        }
        // 台灣自來水費 - 載具號碼(8), 收費年月(6)
        else if ([[arrInfo objectAtIndex:0] isEqualToString:@"2"] && [arrInfo count] == 3) {
            bValid = ([[arrInfo objectAtIndex:1] length] == 8);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(台灣自來水費):%@\n", [arrInfo objectAtIndex:1]);
            bValid = ([[arrInfo objectAtIndex:2] length] == 6);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(台灣自來水費):%@\n", [arrInfo objectAtIndex:2]);
        }
        // 電費 - 查核碼(3), 載具序號(5)
        else if ([[arrInfo objectAtIndex:0] isEqualToString:@"3"] && [arrInfo count] == 3) {
            bValid = ([[arrInfo objectAtIndex:1] length] == 3);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(電費):%@\n", [arrInfo objectAtIndex:1]);
            bValid = ([[arrInfo objectAtIndex:2] length] == 5);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(電費):%@\n", [arrInfo objectAtIndex:2]);
        }
        // 瓦斯費 - 第一條條碼(9), 第二條條碼(16), 第三條條碼(15)
        else if ([[arrInfo objectAtIndex:0] isEqualToString:@"4"] && [arrInfo count] == 4) {
            bValid = ([[arrInfo objectAtIndex:1] length] == 9);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(瓦斯費):%@\n", [arrInfo objectAtIndex:1]);
            bValid = ([[arrInfo objectAtIndex:2] length] == 16);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(瓦斯費):%@\n", [arrInfo objectAtIndex:2]);
            bValid = ([[arrInfo objectAtIndex:3] length] == 15);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊(瓦斯費):%@\n", [arrInfo objectAtIndex:3]);
            bValid = (_m_strNoticeNbr.length == 16 && [_m_strNoticeNbr isEqualToString:[arrInfo objectAtIndex:2]]);
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 銷帳編號:%@\n", _m_strNoticeNbr);
        }
        else {
            bValid = NO;
            if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用資訊欄位錯誤:%@\n", _m_strFeeInfo);
        }
    }
    else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_FeeInfo];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 費用資訊\n");
    }
    return bValid;
}

/**
 * 檢核使用者支付手續費
 */
- (BOOL)isValidChargeIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strCharge) {
        bValid = [self CheckString:_m_strCharge isValidWithRegex:@"[0-9]{3,6}"];
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 使用者支付手續費:%@\n", _m_strCharge);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_Charge];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 使用者支付手續費\n");
    }
    return bValid;
}

/**
 * 檢核費用名稱
 */
- (BOOL)isValidFeeNameIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    NSString *FeeName = [_m_strFeeName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (nil != FeeName) {
        bValid = (FeeName.length >= 1 && FeeName.length <= 30);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 費用名稱:%@\n", FeeName);
    }
    else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_FeeName];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 費用名稱\n");
    }
    return bValid;
}

/**
 * 檢核原始交易資訊
 */
- (BOOL)isValidOrgTxnDataIsNecessary:(BOOL)isNecessary {
    BOOL bValid = NO;
    if (nil != _m_strOrgTxnData) {
        bValid = (_m_strOrgTxnData.length == 71);
        if (!bValid) NSLog(@"\n[QPCode error:格式錯誤] 原始交易資訊:%@\n", _m_strOrgTxnData);
    }else {
        NSString *strEncryptKey = [self getEncryptKeyWithTag:QRPTransactionQueryTag_OrgTxnData];
        BOOL bSecureData = (nil != self.m_dicSecureDatas[strEncryptKey]);
        bValid = (isNecessary) ? bSecureData : YES;
        if (!bValid) NSLog(@"\n[QPCode error:無此欄位] 原始交易資訊\n");
    }
    return bValid;
}

/**
 * 購物付款 && 轉帳購物付款欄位檢核
 * 必填: 安全碼/ 收單行資訊
 * 選填: 交易金額/ 訂單編號/ 交易幣別/ QRCode效期
 */
- (BOOL)isValidPurchaseQRCode {
    // 必填
    if (![self isValidSecureCodeIsNecessary:YES]) {
        return NO;
    }
    if (![self isValidAcqInfoIsNecessary:YES]) {
        return NO;
    }
    // 選填
    if (![self isValidTxnAmtIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidOrderNbrIsNecessary:NO]){
        return NO;
    }
    if (![self isValidTxnCurrencyCodeIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidQrExpirydateIsNecessary:NO]) {
        return NO;
    }
    return YES;
}

/**
 * P2P轉帳欄位檢核
 * 必填: 轉入行代碼/ 轉入帳號
 * 選填: 交易金額/ 備註/ 交易幣別
 */
- (BOOL)isValidP2PTransferQRCode {
    // 必填
    if (![self isValidTransfereeBankIsNecessary:YES]) {
        return NO;
    }
    if (![self isValidTransfereeAccountIsNecessary:YES]) {
        return NO;
    }
    // 選填
    if (![self isValidTxnAmtIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidNoteIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidTxnCurrencyCodeIsNecessary:NO]) {
        return NO;
    }
    return YES;
}

/**
 * 繳費欄位檢核
 * 必填: 交易金額/ 安全碼/ 繳納期限(截止日)/ 銷帳編號/ 收單行資訊
 * 選填: 其他資訊/ 交易幣別/ QRCode效期 / 費用資訊 / 使用者支付手續費 / 費用名稱
 */
- (BOOL)isValidBillQRCode {
    // 必填
    if (![self isValidTxnAmtIsNecessary:YES]) {
        return NO;
    }
    if (![self isValidSecureCodeIsNecessary:YES]) {
        return NO;
    }
    if (![self isValidNoticeNbrIsNecessary:YES]) {
        return NO;
    }
    if (![self isValidAcqInfoIsNecessary:YES]) {
        return NO;
    }
    // 選填
    if (![self isValidDeadlinefinalIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidOtherInfoIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidTxnCurrencyCodeIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidQrExpirydateIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidFeeInfoIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidChargeIsNecessary:NO]) {
        return NO;
    }
    if (![self isValidFeeNameIsNecessary:NO]) {
        return NO;
    }
    return YES;
}


/**
 * QRP Host與Path解析
 */
- (void)parserURLWithHost:(NSString *)strHost path:(NSString *)strPath {

    NSString *strInfo = [NSString stringWithFormat:@"%@%@", strHost, strPath];
    NSArray *arPath = [strInfo componentsSeparatedByString:@"/"];
    if (QRPTransactionPathIndex_Count == arPath.count) {
        // 名稱
        self.m_strMerchantName = arPath[QRPTransactionPathIndex_MerchantName];
        // 國別碼
        self.m_strCountryCode = arPath[QRPTransactionPathIndex_CountryCode];
        // 交易型態
        self.m_strTransactionType = arPath[QRPTransactionPathIndex_TransactionType];
        // 版本
        self.m_strQrVersion = arPath[QRPTransactionPathIndex_QRVersion];
    }
}

/**
 * QRP query解析
 */
- (void)parserURLWithQuery:(NSString *)strQuery {
    
    if (0 < self.m_arQueryTags.count) {
        [self.m_arQueryTags removeAllObjects];
    }

    if (0 < [self.m_dicD allKeys].count) {
        [self.m_dicD removeAllObjects];
    }

    if (0 < [self.m_dicM allKeys].count) {
        [self.m_dicM removeAllObjects];
    }
    
    if (0 < [self.m_dicSecureDatas allKeys].count) {
        [self.m_dicSecureDatas removeAllObjects];
    }
    
    NSArray *arQuery = [strQuery componentsSeparatedByString:@"&"];
    for (NSString *strParameter in arQuery) {
        NSRange range = [strParameter rangeOfString:@"="];
        if (range.location != NSNotFound)
        {
            NSString *strTag = [strParameter substringToIndex:range.location];
            NSString *strValue = [strParameter substringFromIndex:(range.location + range.length)];
            
            if (strTag.length >= 2 && strValue)
            {
                NSString *strTagType = [strTag substringToIndex:1]; // D:明文/ M:修改/ E:密文
                if ([strTagType isEqualToString:kQRPParameterClearText]) {
                    // 明文區
                    QRPTransactionQueryTag iTag = [[strTag substringFromIndex:1] integerValue];
                    [self setTxnValue:strValue forTag:iTag];
                    [self.m_dicD setObject:strValue forKey:[NSString stringWithFormat:@"%ld", (long)iTag]];
                }
                else if ([strTagType isEqualToString:kQRPParameterModifyText]) {
                    // 修改區
                    QRPTransactionQueryTag iTag = [[strTag substringFromIndex:1] integerValue];
                    [self setTxnValue:strValue forTag:iTag];
                    [self.m_dicM setObject:strValue forKey:[NSString stringWithFormat:@"%ld", (long)iTag]];
                }
                else if ([strTagType isEqualToString:kQRPParameterEncryptedText]) {
                    // 密文區
                    [self.m_dicSecureDatas setObject:strValue forKey:strTag];
                }
                
                // for 上述明文區(D類) 、修改區(M類) 、密文區(E類) 及其他擴充區(O類)的欄位名稱不可重複出現
                if ([strTagType isEqualToString:kQRPParameterClearText] ||
                    [strTagType isEqualToString:kQRPParameterModifyText] ||
                    [strTagType isEqualToString:kQRPParameterEncryptedText]) {
                    QRPTransactionQueryTag iTag = [[strTag substringFromIndex:1] integerValue];
                    switch (iTag)
                    {
                        case QRPTransactionQueryTag_TxnAmt:
                        case QRPTransactionQueryTag_OrderNbr:
                        case QRPTransactionQueryTag_SecureCode:
                        case QRPTransactionQueryTag_Deadlinefinal:
                        case QRPTransactionQueryTag_TransfereeBank:
                        case QRPTransactionQueryTag_TransfereeAccount:
                        case QRPTransactionQueryTag_NoticeNbr:
                        case QRPTransactionQueryTag_OtherInfo:
                        case QRPTransactionQueryTag_Note:
                        case QRPTransactionQueryTag_TxnCurrencyCode:
                        case QRPTransactionQueryTag_AcqInfo:
                        case QRPTransactionQueryTag_QrExpirydate:
                        case QRPTransactionQueryTag_OrgTxnData:
                        case QRPTransactionQueryTag_FeeInfo:
                        case QRPTransactionQueryTag_Charge:
                        case QRPTransactionQueryTag_FeeName:
                        {
                            if (![self.m_arQueryTags containsObject:@(iTag)]) {
                                [self.m_arQueryTags addObject:@(iTag)];
                            }else {
                                [self.m_arSameQueryTags addObject:@(iTag)];
                            }
                        }
                            break;
                    }
                }
            }
        }
    }
}

// Check string with regular expression
- (BOOL)CheckString:(NSString *)_str isValidWithRegex:(NSString *)_reg
{
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", _reg] evaluateWithObject:_str];
}

#pragma mark - life cycle

- (void)initParameters {
    _transactionType = QRPTransactionType_Unknown;
    m_strAcqBank = nil;
    m_strMerchantId = nil;
    m_strTerminalId = nil;
    m_strTransfereeBankForPurchasing = nil;
    m_strTransfereeAccountForPurchasing = nil;
}

- (instancetype)initWithQRCodeURL:(NSString *)strURL {
    self = [super init];
    if (nil != self) {
        
        [self initParameters];
        
        NSString *decodeUrl = [strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"\n======================\nQRP Decode URL = %@\n======================\n", decodeUrl);
        
        NSString *encodeUrl = [decodeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodeUrl];
        if ([[[url scheme] uppercaseString] isEqualToString:kQRPTransactionScheme]) {
            
            // Host & Path
            NSString *strHost = [url host];
            NSString *strPath = [url path];
            if (0 < strHost.length && 0 < strPath.length) {
                [self parserURLWithHost:strHost path:strPath];
            }
            
            // Query
            NSString *strQuery = [url query];
            if (0 < strQuery.length) {
                [self parserURLWithQuery:strQuery];
            }
        }
    }
    return self;
}

- (void)dealloc {
    [_m_strMerchantName release];
    [_m_strCountryCode release];
    [_m_strQrVersion release];
    [_m_strTxnAmt release];
    [_m_strOrderNbr release];
    [_m_strSecureCode release];
    [_m_strDeadlinefinal release];
    [_m_strTransfereeBank release];
    [_m_strTransfereeAccount release];
    [_m_strNoticeNbr release];
    [_m_strOtherInfo release];
    [_m_strNote release];
    [_m_strTxnCurrencyCode release];
    [_m_strAcqInfo release];
    [_m_strQrExpirydate release];
    [_m_strOrgTxnData release];
    [_m_strFeeInfo release];
    [_m_strCharge release];
    [_m_strFeeName release];
    [_m_dicSecureDatas release];
    [_m_dicAcqInfo release];
    [_m_arQueryTags release];
    [_m_dicD release];
    [_m_dicM release];
    [_m_dicE release];
    [_m_arSameQueryTags release];
    [super dealloc];
}

@end
