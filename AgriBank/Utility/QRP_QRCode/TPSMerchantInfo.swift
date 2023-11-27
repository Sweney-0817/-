//
//  TPSMerchantInfo.swift
//  TaiwanPayShop
//
//  Created by Jobs NO.1 on 2017/7/10.
//  Copyright © 2017年 Softmobile. All rights reserved.
//

import Foundation

enum TPSMerchantInfoRespTag : String {
    case merchantName       = "merchantName"
    case countryCode        = "countryCode"
    case shopType           = "shopType"
    case qrVersion          = "qrVersion"
    case qrExpiryPeriod     = "qrExpiryPeriod"
    case secureCode         = "secureCode"
    case txnCurrencyCode    = "txnCurrencyCode"
    case acqInfo            = "acqInfo"
    case transfereeBank     = "transfereeBank"
    case transfereeAccount  = "transfereeAccount"
    case appRoleId          = "appRoleId"
    case appRoleName        = "appRoleName"
    case appFunction        = "appFunction"
    case pushStatus         = "pushStatus"
    case forceChangePod     = "forceChangePod"
}

enum TPSMerchantInfoShopType: String {
    case purchase   = "PURCHASE"    // 購物交易
    case transfer   = "TRANSFER"    // 轉帳交易
    case bill       = "BILL"        // 繳費交易
}

enum TPSMerchantInfoAppFunctionType: String {
    case CancelTransaction  = "CancelTransaction"   // 退款
    case ChangeRole         = "ChangeRole"          // 角色管理
    case CheckOut           = "CheckOut"            // 收款
    case MenuSettings       = "MenuSettings"        // 常用金額管理
    case TransactionList    = "TransactionList"     // 交易紀錄
}

class TPSMerchantInfo: NSObject, NSCoding {

    /**
     * 特店名稱
     */
    var merchantName : String? = nil

    /**
     * 國別碼
     */
    var countryCode : String? = nil

    /**
     * 收款類型 (PURCHASE:購物交易 / TRANSFER:購物轉帳交易 / BILL:繳費交易)
     */
    var shopType : TPSMerchantInfoShopType? = nil

    /**
     * QR code版本
     */
    var qrVersion : String? = nil

    /**
     * QR code效期(秒)
     */
    var qrExpiryPeriod : String? = nil

    /**
     * QR code安全碼
     */
    var secureCode : String? = nil

    /**
     * 交易幣別
     */
    var txnCurrencyCode : String? = nil

    /**
     * 收單行資訊
     */
    var acqInfo : String? = nil

    /**
     * 轉入行代碼
     */
    var transfereeBank : String? = nil

    /**
     * 轉入行帳號
     */
    var transfereeAccount : String? = nil

    /**
     * 所屬角色
     */
    var appRoleId : String? = nil

    /**
     * 所屬角色名稱
     */
    var appRoleName : String? = nil
    
    /**
     * 可執行功能 可執行功能（多筆，功能代號以|區隔）
     */
    var appFunction : String? = nil
    
    /**
     * 推播狀態(Y/N)
     */
    var pushStatus : String? = nil
    
    /**
     * 強制密碼變更（Y/N）
     */
    var forceChangePod: Bool = false
    
    init(dictionary: Dictionary<String, Any>) {
        self.merchantName = dictionary[TPSMerchantInfoRespTag.merchantName.rawValue] as? String
        self.countryCode = dictionary[TPSMerchantInfoRespTag.countryCode.rawValue] as? String
        self.shopType = (dictionary[TPSMerchantInfoRespTag.shopType.rawValue] as? String).map { TPSMerchantInfoShopType(rawValue: $0) }!
        self.qrVersion = dictionary[TPSMerchantInfoRespTag.qrVersion.rawValue] as? String
        self.qrExpiryPeriod = dictionary[TPSMerchantInfoRespTag.qrExpiryPeriod.rawValue] as? String
        self.secureCode = dictionary[TPSMerchantInfoRespTag.secureCode.rawValue] as? String
        self.txnCurrencyCode = dictionary[TPSMerchantInfoRespTag.txnCurrencyCode.rawValue] as? String
        self.acqInfo = dictionary[TPSMerchantInfoRespTag.acqInfo.rawValue] as? String
        self.transfereeBank = dictionary[TPSMerchantInfoRespTag.transfereeBank.rawValue] as? String
        self.transfereeAccount = dictionary[TPSMerchantInfoRespTag.transfereeAccount.rawValue] as? String
        self.appRoleId = dictionary[TPSMerchantInfoRespTag.appRoleId.rawValue] as? String
        self.appRoleName = dictionary[TPSMerchantInfoRespTag.appRoleName.rawValue] as? String
        self.appFunction = dictionary[TPSMerchantInfoRespTag.appFunction.rawValue] as? String
        
        if let pushStatus = dictionary[TPSMerchantInfoRespTag.pushStatus.rawValue] as? String {
            self.pushStatus = pushStatus
        } else {
            self.pushStatus = "N"
        }
        if let forceChangePod = dictionary[TPSMerchantInfoRespTag.forceChangePod.rawValue] as? String
        {
            self.forceChangePod = (forceChangePod == "Y")
        }
    }

    required init(coder decoder: NSCoder) {
        self.merchantName = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.merchantName.rawValue) as? String
        self.countryCode = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.countryCode.rawValue) as? String
        if decoder.decodeObject(forKey: TPSMerchantInfoRespTag.shopType.rawValue) != nil
        {
            self.shopType = (decoder.decodeObject(forKey: TPSMerchantInfoRespTag.shopType.rawValue) as? String).map { TPSMerchantInfoShopType(rawValue: $0) }!
        }
        self.qrVersion = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.qrVersion.rawValue) as? String
        self.qrExpiryPeriod = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.qrExpiryPeriod.rawValue) as? String
        self.secureCode = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.secureCode.rawValue) as? String
        self.txnCurrencyCode = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.txnCurrencyCode.rawValue) as? String
        self.acqInfo = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.acqInfo.rawValue) as? String
        self.transfereeBank = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.transfereeBank.rawValue) as? String
        self.transfereeAccount = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.transfereeAccount.rawValue) as? String
        self.appRoleId = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.appRoleId.rawValue) as? String
        self.appRoleName = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.appRoleName.rawValue) as? String
        self.appFunction = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.appFunction.rawValue) as? String
        self.pushStatus = decoder.decodeObject(forKey: TPSMerchantInfoRespTag.pushStatus.rawValue) as? String
        self.forceChangePod = (decoder.decodeObject(forKey: TPSMerchantInfoRespTag.appFunction.rawValue) != nil)
    }

    func encode(with coder: NSCoder) {
        coder.encode(merchantName, forKey: TPSMerchantInfoRespTag.merchantName.rawValue)
        coder.encode(countryCode, forKey: TPSMerchantInfoRespTag.countryCode.rawValue)
        coder.encode(shopType?.rawValue, forKey: TPSMerchantInfoRespTag.shopType.rawValue)
        coder.encode(qrVersion, forKey: TPSMerchantInfoRespTag.qrVersion.rawValue)
        coder.encode(qrExpiryPeriod, forKey: TPSMerchantInfoRespTag.qrExpiryPeriod.rawValue)
        coder.encode(secureCode, forKey: TPSMerchantInfoRespTag.secureCode.rawValue)
        coder.encode(txnCurrencyCode, forKey: TPSMerchantInfoRespTag.txnCurrencyCode.rawValue)
        coder.encode(acqInfo, forKey: TPSMerchantInfoRespTag.acqInfo.rawValue)
        coder.encode(transfereeBank, forKey: TPSMerchantInfoRespTag.transfereeBank.rawValue)
        coder.encode(transfereeAccount, forKey: TPSMerchantInfoRespTag.transfereeAccount.rawValue)
        coder.encode(appRoleId, forKey: TPSMerchantInfoRespTag.appRoleId.rawValue)
        coder.encode(appRoleName, forKey: TPSMerchantInfoRespTag.appRoleName.rawValue)
        coder.encode(appFunction, forKey: TPSMerchantInfoRespTag.appFunction.rawValue)
        coder.encode(pushStatus, forKey: TPSMerchantInfoRespTag.pushStatus.rawValue)
        coder.encode(forceChangePod, forKey: TPSMerchantInfoRespTag.forceChangePod.rawValue)
    }
    /// 判斷是否可執行動作
    ///
    /// - Parameter type: 要判斷是否可執行的功能
    /// - Returns: 是否可執行此功能
//    class func hasFunction(type: TPSMerchantInfoAppFunctionType) -> Bool {
//        return AppDelegate.sharedInstance().m_merchantInfo?.appFunction?.range(of: type.rawValue) != nil
//    }
}
