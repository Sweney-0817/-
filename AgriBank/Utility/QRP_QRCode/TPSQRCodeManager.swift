//
//  TPSQRCodeManager.swift
//  TaiwanPayShop
//
//  Created by Jobs NO.1 on 2017/7/13.
//  Copyright © 2017年 Softmobile. All rights reserved.
//

import Foundation

enum TPSQRCodeType : String {
    case staticQRCode   // 靜態
    case dynamicQRCode  // 動態
}

enum TPSQRCodeTxnType : String {
    case purchase   = "01" // 購物交易
    case transfer   = "02" // 轉帳交易
    case bill       = "03" // 繳費交易
}

enum TPSQRCodeFieldName : String {
    case txnAmt             = "D1"  // 交易金額
    case orderNbr           = "D2"  // 訂單編號
    case secureCode         = "D3"  // 安全碼
    case deadlinefinal      = "D4"  // 繳納期限(截止日)
    case transfereeBank     = "D5"  // 轉入行代碼
    case transfereeAccount  = "D6"  // 轉入帳號
    case noticeNbr          = "E7"  // 銷帳編號
    case otherInfo          = "D8"  // 其他資訊
    case note               = "D9"  // 備註
    case txnCurrencyCode    = "D10" // 交易幣別
    case acqInfo            = "D11" // 收單行資訊
    case qrExpirydate       = "D12" // QR Code效期
    case orgTxnData         = "D13" // 原始交易資訊
    case feeInfo            = "D14" // 費用資訊
    case charge             = "D15" // 使用者支付手續費
    case feeName            = "D16" // 費用名稱
    case timestamp          = "D97" // 時戳 chiu
    case walletcode         = "D98" // 錢包服務提供者 sweney
    case msgTAC             = "D99" // 訊息押碼 chiu
}


class TPSQRCodeManager : NSObject {

    static let sharedManager = TPSQRCodeManager()

    var merchantInfo: TPSMerchantInfo? = nil

    /// TWQRP: 固定值(無大小寫之分)，用於識別財金共用QRCodes內容
    let qrCodeScheme : String = "TWQRP://"

    private override init() {
        super.init()
    }

    /// 取得訂單編號(yyyyMMddHHmmss)
    ///
    /// - Returns: 訂單編號
    private func orderNbr() -> String {
        let currnetDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: currnetDate)
    }

    /// 取得QRCode效期 (yyyyMMddHHmmss)
    ///
    /// - Parameter qrExpiryPeriod: QRCode效期秒數
    /// - Returns: QRCode效期
    private func qrExpirydate(qrExpiryPeriod: String) -> String {
        let timeInterval = Double(qrExpiryPeriod)
        let currnetDate = Date()
        let expiryDate = currnetDate.addingTimeInterval(timeInterval!)
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: expiryDate)
    }

    /// 取得QRCode path字串
    ///
    /// - Returns: QRCode path字串
    private func qrCodePath() -> String? {

        if let merchantInfo = self.merchantInfo {

            var arPath = Array<String>()

            // 名稱:可放特店名稱、事業單位名稱及個人資訊等等，支援中文UTF-8編碼，長度最多支援20個中文字。
            if let strMerchantName = merchantInfo.merchantName {
                arPath += [strMerchantName]
            }
            // 國別碼：詳見ISO 3166-1之數字編碼。
            if let strCountryCode = merchantInfo.countryCode {
                arPath += [strCountryCode]
            }
            // 交易型態：01：購物交易、02：轉帳交易、03：繳費交易。
            if let shopType = merchantInfo.shopType {
                switch shopType
                {
                case TPSMerchantInfoShopType.purchase:
                    arPath += [TPSQRCodeTxnType.purchase.rawValue]
                case TPSMerchantInfoShopType.transfer:
                    arPath += [TPSQRCodeTxnType.transfer.rawValue]
                case TPSMerchantInfoShopType.bill:
                    arPath += [TPSQRCodeTxnType.bill.rawValue]
                }
            }
            // 版本：目前固定為V1。
            if let strQrVersion = merchantInfo.qrVersion {
                arPath += [strQrVersion]
            }

            let strPath = arPath.joined(separator: "/")
            return strPath

        }
        return nil
    }

    /// 取得購物交易Query字串
    ///
    /// - Parameters:
    ///   - qrCodetype:  靜態/ 動態
    ///   - txnAmt: 交易金額(動態才帶值)
    /// - Returns: 購物交易Query字串
    private func qrCodeQueryForPurchase(qrCodeType: TPSQRCodeType , txnAmt: String?) -> String? {

        // 若為動態QRCode，但無交易金額，回傳nil
        if qrCodeType == .dynamicQRCode && txnAmt == nil {
            return nil
        }

        if let merchantInfo = self.merchantInfo {

            var arQuery = Array<String>()
            let amt : String = "00"; // 用於金額最後兩位

            if qrCodeType == TPSQRCodeType.dynamicQRCode {
                // 交易金額
                //arQuery += ["\(TPSQRCodeFieldName.txnAmt.rawValue)=\(txnAmt!)"]
                arQuery += ["\(TPSQRCodeFieldName.txnAmt.rawValue)=\(txnAmt!+amt)"]
                // 訂單編號
                arQuery += ["\(TPSQRCodeFieldName.orderNbr.rawValue)=\(self.orderNbr())"]
                // QRCode效期
                arQuery += ["\(TPSQRCodeFieldName.qrExpirydate.rawValue)=\(self.qrExpirydate(qrExpiryPeriod: merchantInfo.qrExpiryPeriod!))"]
            }
            // 安全碼
            if let strSecureCode = merchantInfo.secureCode {
                arQuery += ["\(TPSQRCodeFieldName.secureCode.rawValue)=\(strSecureCode)"]
            }
            // 交易幣別
            if let strTxnCurrnecyCode = merchantInfo.txnCurrencyCode {
                arQuery += ["\(TPSQRCodeFieldName.txnCurrencyCode.rawValue)=\(strTxnCurrnecyCode)"]
            }
            // 收單行資訊
            if let strAcqInfo = merchantInfo.acqInfo {
                arQuery += ["\(TPSQRCodeFieldName.acqInfo.rawValue)=\(strAcqInfo)"]
            }
            

            let strQuery = arQuery.joined(separator: "&")
            return strQuery
        }
        return nil
    }
 

    /// 取得轉帳交易Query字串
    ///
    /// - Parameters:
    ///   - qrCodetype:  靜態/ 動態
    ///   - txnAmt: 交易金額(動態才帶值)
    /// - Returns: 購物交易Query字串
    private func qrCodeQueryForTransfer(qrCodeType: TPSQRCodeType , txnAmt: String?) -> String? {

        // 若為動態QRCode，但無交易金額，回傳nil
        if qrCodeType == .dynamicQRCode && txnAmt == nil {
            return nil
        }

        if let merchantInfo = self.merchantInfo {

            var arQuery = Array<String>()
            let amt : String = "00"; // 用於金額最後兩位

            if qrCodeType == TPSQRCodeType.dynamicQRCode {
                // 交易金額
                //arQuery += ["\(TPSQRCodeFieldName.txnAmt.rawValue)=\(txnAmt!)"]
                arQuery += ["\(TPSQRCodeFieldName.txnAmt.rawValue)=\(txnAmt!+amt)"]
            }
            // 轉入行代碼
            if let strTransfereeBank = merchantInfo.transfereeBank {
                arQuery += ["\(TPSQRCodeFieldName.transfereeBank.rawValue)=\(strTransfereeBank)"]
            }
            // 轉入帳號
            if let strTransfereeAccount = merchantInfo.transfereeAccount {
                var temp = strTransfereeAccount
                if temp.count < 16 {
                    for _ in 0..<(16-temp.count) {
                        temp = "0" + temp
                    }
                }
                //arQuery += ["\(TPSQRCodeFieldName.transfereeAccount.rawValue)=\(strTransfereeAccount)"]
                arQuery += ["\(TPSQRCodeFieldName.transfereeAccount.rawValue)=\(temp)"]
            }

            // 交易幣別
            if let strTxnCurrnecyCode = merchantInfo.txnCurrencyCode {
                arQuery += ["\(TPSQRCodeFieldName.txnCurrencyCode.rawValue)=\(strTxnCurrnecyCode)"]
            }
            // D97 時戳
             let currnetDate = Date()
             let dateFormatter = DateFormatter()
             dateFormatter.calendar = Calendar.init(identifier: Calendar.Identifier.iso8601) 
             dateFormatter.dateFormat = "yyyyMMddHHmmss"
             let strDateTime:String = dateFormatter.string(from: currnetDate)
            arQuery +=  ["\(TPSQRCodeFieldName.timestamp.rawValue)=\(strDateTime)"]
             
             //D98
            if let info = AuthorizationManage.manage.getResponseLoginInfo() ,let walletcode:String = info.WalletBasecode {
                arQuery += ["\(TPSQRCodeFieldName.walletcode.rawValue)=\(walletcode)"]
            }
 
            let strQuery = arQuery.joined(separator: "&")
            return strQuery
        }

        return nil
    }


    /// 取得繳費交易Query字串
    ///
    /// - Parameters:
    ///   - txnAmt: 交易金額
    ///   - deadlinefinal: 繳納期限(截止日)
    ///   - noticeNbr: 銷帳編號
    /// - Returns: 繳費交易Query字串
    private func qrCodeQueryForBill(txnAmt: String, deadlinefinal: String, noticeNbr: String) -> String? {

        if let merchantInfo = self.merchantInfo {

            var arQuery = Array<String>()
            let amt : String = "00"; // 用於金額最後兩位
            
            // 交易金額
            //arQuery += ["\(TPSQRCodeFieldName.txnAmt.rawValue)=\(txnAmt)"]
            arQuery += ["\(TPSQRCodeFieldName.txnAmt.rawValue)=\(txnAmt+amt)"]

            // 安全碼
            if let strSecureCode = merchantInfo.secureCode {
                arQuery += ["\(TPSQRCodeFieldName.secureCode.rawValue)=\(strSecureCode)"]
            }

            // 繳納期限(截止日)
            arQuery += ["\(TPSQRCodeFieldName.deadlinefinal.rawValue)=\(deadlinefinal)"]

            // 銷帳編號
            arQuery += ["\(TPSQRCodeFieldName.noticeNbr.rawValue)=\(noticeNbr)"]

            // 交易幣別
            if let strTxnCurrnecyCode = merchantInfo.txnCurrencyCode {
                arQuery += ["\(TPSQRCodeFieldName.txnCurrencyCode.rawValue)=\(strTxnCurrnecyCode)"]
            }

            // 收單行資訊
            if let strAcqInfo = merchantInfo.acqInfo {
                arQuery += ["\(TPSQRCodeFieldName.acqInfo.rawValue)=\(strAcqInfo)"]
            }

            // QRCode效期
            arQuery += ["\(TPSQRCodeFieldName.qrExpirydate.rawValue)=\(self.qrExpirydate(qrExpiryPeriod: merchantInfo.qrExpiryPeriod!))"]


            let strQuery = arQuery.joined(separator: "&")
            return strQuery
        }

        return nil
    }

    private func generateQRCodeString(qrCodeType: TPSQRCodeType, txnAmt: String?, deadlinefinal: String?, noticeNbr: String?) -> String?{

        // scheme
        // var strQrCode: String = qrCodeScheme
        var strQrCode: String = "TWQRP://"
        // path
        if let strPath = self.qrCodePath() {
            strQrCode += strPath
            strQrCode += "?"
        }

        // qurery
        if let shopType = self.merchantInfo?.shopType {
            switch shopType {
            case .purchase:
                if let strQuery = self.qrCodeQueryForPurchase(qrCodeType: qrCodeType, txnAmt: txnAmt) {
                    strQrCode += strQuery
                }
            case .transfer:

                if let strQuery = self.qrCodeQueryForTransfer(qrCodeType: qrCodeType, txnAmt: txnAmt) {
                    strQrCode += strQuery
                }
            case .bill:
                if txnAmt == nil || deadlinefinal == nil || noticeNbr == nil {
                    return nil
                }
                if let strQuery = self.qrCodeQueryForBill(txnAmt: txnAmt!, deadlinefinal: deadlinefinal!, noticeNbr: noticeNbr!) {
                    strQrCode += strQuery
                }
            }
        }
       #if DEBUG
        print("\n==============================\nQRCode:\n\(strQrCode)\n==============================\n")
        #endif
        return strQrCode.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }

    /// 取得靜態QR Code字串 for 購物交易與轉帳交易
    ///
    /// - Returns: 靜態QR Code字串
    func staticQRCodeString() -> String? {

        if let shopType = self.merchantInfo?.shopType {
            switch shopType {
            case TPSMerchantInfoShopType.purchase, TPSMerchantInfoShopType.transfer:
                return self.generateQRCodeString(qrCodeType: .staticQRCode, txnAmt: nil, deadlinefinal: nil, noticeNbr: nil)
            default:
                return nil
            }
        }
        return nil
    }

    /// 取得動態QR Code字串 for 購物交易與轉帳交易
    ///
    /// - Parameters:
    ///   - txnAmt: 交易金額
    /// - Returns: 動態QR Code字串
    func dynamicQRCodeString(txnAmt: String) -> String? {

        if let shopType = self.merchantInfo?.shopType {
            switch shopType {
            case TPSMerchantInfoShopType.purchase, TPSMerchantInfoShopType.transfer:
                return self.generateQRCodeString(qrCodeType: .dynamicQRCode, txnAmt: txnAmt, deadlinefinal: nil, noticeNbr: nil)
            default:
                return nil
            }
        }
        return nil
    }

    /// 取得繳費交易動態QR Code字串
    ///
    /// - Parameters:
    ///   - txnAmt: 交易金額
    ///   - deadlinefinal: 繳納期限(截止日)
    ///   - noticeNbr: 銷帳編號
    /// - Returns: 取得繳費交易動態QR Code字串
    func dynamicBillQRCodeString(txnAmt: String, deadlinefinal: String, noticeNbr: String) -> String? {

        if let shopType = self.merchantInfo?.shopType {
            switch shopType {
            case TPSMerchantInfoShopType.bill:
                return self.generateQRCodeString(qrCodeType: .dynamicQRCode, txnAmt: txnAmt, deadlinefinal: deadlinefinal, noticeNbr: noticeNbr)
            default:
                return nil
            }

        }
        return nil
    }
}
