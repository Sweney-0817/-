//
//  MWQRPTransactionInfo.h
//  MobileWallet
//
//  Created by Jobs NO.1 on 2017/8/7.
//  Copyright © 2017年 Arthur Tseng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QRPTransactionType) {
    QRPTransactionType_Purchase = 1,            // 購物交易
    QRPTransactionType_P2PTransfer,             // 轉帳交易
    QRPTransactionType_Bill,                    // 繳費交易
    QRPTransactionType_TransferPurchase = 51,   // 購物轉帳交易
    QRPTransactionType_Unknown = 999,
};

static NSString * const kQRPTransactionSupportPaymentType = @"10000000"; // 僅支援金融卡

@interface MWQRPTransactionInfo : NSObject

@property (assign, nonatomic) QRPTransactionType transactionType;

- (instancetype)initWithQRCodeURL:(NSString *)strURL;

/**
 * 檢核QRCode是否符合QRP文件定義之規範
 */
- (BOOL)isValidQRCodeFromat;

/**
 * 檢核QRCode支付工具類型
 */
- (BOOL)isValidPaymentType;

/**
 * 國別碼
 */
- (NSString *)countryCode;

/**
 * 收單行
 */
- (NSString *)acqBank;

/**
 * 特店代號
 */
- (NSString *)merchantId;

/**
 * 端末代號
 */
- (NSString *)terminalId;

/**
 * 收單行資訊
 */
- (NSString *)acqInfo;

/**
 * 支付工具類型
 */
- (NSString *)paymentType;

/**
 * QR CODE安全碼
 */
- (NSString *)secureCode;

/**
 * QR CODE安全碼
 */
- (NSString *)secureData;

/**
 * 交易金額，含小數點兩位
 */
- (NSString *)txnAmt;

/**
 * 設定交易金額，含小數點兩位
 */
- (void)setTxnAmt:(NSString *)txnAmt;

/**
 * 特店名稱
 */
- (NSString *)merchantName;

/**
 * QRCode效期
 */
- (NSString *)qrExpirydate;

/**
 * 訂單編號
 */
- (NSString *)orderNumber;

/**
 * 轉入行代碼
 */
- (NSString *)transfereeBank;

/**
 * 轉入帳號
 */
- (NSString *)transfereeAccount;

/**
 * 交易幣別
 */
- (NSString *)txnCurrencyCode;

/**
 * 備註
 */
- (NSString *)note;

/**
 * 繳納期限(截止日)
 */
- (NSString *)deadlinefinal;

/**
 * 設定繳納期限(截止日)
 */
- (void)setDeadlinefinal:(NSString *)deadlinefinal;

/**
 * 銷帳編號
 */
- (NSString *)noticeNbr;

/**
 * 設定銷帳編號
 */
- (void)setNoticeNbr:(NSString *)noticeNbr;

/**
 * 費用資訊
 */
- (NSString *)feeInfo;

/**
 * 使用者支付手續費
 */
- (NSString *)charge;

/**
 * 費用名稱
 */
- (NSString *)feeName;

/**
 * M type data
 */
- (NSDictionary *)MTypeDic;

/**
 * D type Data
 */
- (NSDictionary *)DTypeDic;

/**
 * 轉入行代碼 for 購物轉帳交易
 */
- (NSString *)transfereeBankForPurchasing;

/**
 * 轉入行帳號 for 購物轉帳交易
 */
- (NSString *)transfereeAccountForPurchasing;

/**
 * 加密資料欄位解析
 */
- (void)parserSecureData:(NSString *)strSecureData;

//北市水及驗證繳費 chiu start
/**
 * 時戳
 */
- (NSString *)timestamp;

/**
 * 訊息ＴＡＣ
 */
- (NSString *)msgTAC;

/**
 * 錢包服務提供者
 */
- (NSString *)WalletBaseCode;

/**
 * 繳費支付工具類型及手續費
 */
- (NSString *)sPayType;

- (NSString *)sBillSID;
/**
* 設定繳費支付工具類型及手續費
*/
- (void)setsPayType:(NSString *)sPayType;

- (void)setsBillSID:(NSString *)sBillSID;

//台電 sweney

- (void)setspower64No:(NSString *)power64no;
- (void)setstxamt:(NSString *)txamt;
- (void)setspowerNo:(NSString *)powerNo ;
- (void)setsTotalAmount:(NSNumber *)TotalAmount;
- (void)setsTotalCount:(NSString *)TotalCount;
- (void)setsItemList:(NSString *)ItemList;
- (void)setsItemarrayList:(NSArray *)ItemarrayList;
- (void)setsTaipowerInfo:(NSArray *)TaipowerInfo;
- (void)setsMobileNo:(NSString *)MobileNo;
- (void)setsMBarcode:(NSString *)MBarcode;
- (NSString *)sPower64No;
- (NSString *)sItemList;
- (NSArray *)sItemarrayList;
- (NSString *)sTotalCount;
- (NSNumber *)sTotalAmount;
- (NSString *)spowerNo;
- (NSArray *)sTaipowerInfo;
- (NSString *)sMobileNo;
- (NSString *)sMBarcode;
@end
