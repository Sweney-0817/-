//
//  AuthorizationManage.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/16.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit
import Darwin

let AuthorizationManage_IDList_Separator = ","
let AuthorizationManage_HttpHead_Token = "Token"
let AuthorizationManage_HttpHead_CID = "CID"
let AuthorizationManage_HttpHead_VarifyId = "varifyId"
let AuthorizationManage_HttpHead_Default = ["Content-Type":"application/json", "DeviceID":AgriBank_DeviceID]
var AuthorizationManage_CIDListKey: [String: String] = [:]
let AuthorizationManage_Random = Int(arc4random_uniform(UInt32(AuthorizationManage_CIDListKey.count)))

struct ResponseLoginInfo {
    var CNAME:String? = nil         // 用戶名稱
    var Token:String? = nil         // Token
    var USUDID:String? = nil        // 使用者ID
    var Balance:String? = nil       // 餘額
    var TBalance:String? = nil      // 定期總額
    var STATUS:String? = nil        // 帳戶狀態
    var WalletBasecode:String? = nil  //WalletBasecode add by sweney for P2P 110/4/7
}

class AuthorizationManage {
    static let manage = AuthorizationManage()
    private var authList:[PlatformFeatureID]? = nil      // 功能授權資料
    private var userInfo:ResponseLoginInfo? = nil        // 登入成功後回傳的資訊
    private var loginInfo:LoginStrcture? = nil           // 使用者登入的資訊
    private var apnsToken:String? = nil                  // APNS回傳的token
    private var needReAddList = [PlatformFeatureID:Int]()// 使用者加入的功能，但功能授權未開啟
    private var isLoginSuccess = false                   // 判斷是否登入成功
    /* 與當初預期不同，只能特殊處理 */
    private var canNTNonAgreedTransfer = false           // 是否可以「非約轉」
    private var canReservationTransferCancel = false     // 是否可以「預約轉帳取消」
    private var canDepositTermination = false            // 是否可以「綜存戶轉存明細解約」
    private var canPayLoan = false                       // 是否可以「繳交放款本息」
    private var canChangeBaseInfo = false                // 是否可以「基本資料變更」
   
    private var canEnterQRPay = false                   // 是否可以進入QRPay
    private var canEnterP2PTrans = false                // 是否可進入p2p轉帳
    //2020-1-3 add by sweney
    private var canShowQRCode0 = false                  // 是否可出示付款碼
    
    func setResponseLoginInfo(_ info:ResponseLoginInfo?, _ list:[[String:String]]?) {
        userInfo = info
        if list != nil {
            authList = [PlatformFeatureID]()
            for index in list! {
                if let ID = index["TransactionId"] {
                    switch ID {
                    case "T05":
                        canNTNonAgreedTransfer = true
                        
                    case "T34":
                        canReservationTransferCancel = true
                    
                    case "T35":
                        canDepositTermination = true
                        
                    case "T36":
                        canPayLoan = true
                        
                    case "T37":
                        canChangeBaseInfo = true
                        
                    case "T43":
                        canEnterQRPay = true
                        if let pID = getPlatformIDByAuthID(ID) {
                            if authList?.firstIndex(of: pID) == nil {
                                authList?.append(pID)
                            }
                        }
                    case "T56":
                        canEnterP2PTrans = true
                    case "T63":
                        canShowQRCode0 = true
                        if let pID = getPlatformIDByAuthID(ID) {
                            if authList?.firstIndex(of: pID) == nil {
                                authList?.append(pID)
                            }
                        }
                    default:
                        if let pID = getPlatformIDByAuthID(ID) {
                            if authList?.firstIndex(of: pID) == nil {
                                authList?.append(pID)
                            }
                        }
                    }
                }
            }
            authList?.append(.FeatureID_Edit) // 新增/編輯
        }
    }
    
    func getResponseLoginInfo() -> ResponseLoginInfo? {
        return userInfo
    }
    
    func SetLoginInfo(_ info:LoginStrcture?) {
        loginInfo = info
    }
    
    func GetLoginInfo() -> LoginStrcture? {
        return loginInfo
    }
    
    func SetAPNSToken(_ token:String) {
        apnsToken = token
    }
    
    func GetAPNSToken() -> String? {
        return apnsToken
    }
    
    func IsLoginSuccess() -> Bool {
        return isLoginSuccess
    }
    
    func setLoginStatus(_ status:Bool) {
        isLoginSuccess = status
        /* 登出後，狀態要更新 */
        if status == false {
            AuthorizationManage.manage.setResponseLoginInfo(nil, nil)
            if #available(iOS 10.0, *) {
                (UIApplication.shared.delegate as! AppDelegate).removeNotificationAllEvent()
            } else {
                // Fallback on earlier versions
            }
            canNTNonAgreedTransfer = false
            canReservationTransferCancel = false
            canDepositTermination = false
            canPayLoan = false
            canChangeBaseInfo = false
            canEnterQRPay = false
            canEnterP2PTrans = false
        }
    }
    
    func canEnterNTNonAgreedTransfer() -> Bool {
        return canNTNonAgreedTransfer
    }
    
    func canCancelReservationTransfer() -> Bool {
        return canReservationTransferCancel
    }
    
    func canTerminationDeposit() -> Bool {
        return canDepositTermination
    }
    
    func getPayLoanStatus() -> Bool {
        return canPayLoan
    }
    
    func getChangeBaseInfoStaus() -> Bool {
        return canChangeBaseInfo
    }
    
    func getCanEnterQRPay() -> Bool {
        return canEnterQRPay
    }

    func getCanEnterP2PTrans() -> Bool {
        return canEnterP2PTrans
    }
//2020-1-3 add by sweney
    func getCanShowQRCode0() -> Bool {
        return canShowQRCode0
    }
    func getHttpHead(_ isNeedCID:Bool) -> [String:String] {
        var head = AuthorizationManage_HttpHead_Default
	//for test
        head[AuthorizationManage_HttpHead_Token] = userInfo?.Token ?? ""
//        head[AuthorizationManage_HttpHead_Token] = userInfo?.Token ?? "123"
    
        if isNeedCID {
            head[AuthorizationManage_HttpHead_CID] = [String](AuthorizationManage_CIDListKey.keys)[AuthorizationManage_Random]
        }
        return head
    }
    
    func GetCIDKey(_ ID:String) -> String? {
        return AuthorizationManage_CIDListKey[ID]
    }
    
    func converInputToHttpBody(_ input:[String:Any], _ needEncrypt:Bool) -> Data? {
        var httpBody:Data? = nil
        do {
            httpBody = try JSONSerialization.data(withJSONObject: input, options: .prettyPrinted)
            if needEncrypt {
                let encryptID = [String](AuthorizationManage_CIDListKey.keys)[AuthorizationManage_Random]
                if let encrypt = String(data: httpBody!, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""), let key = AuthorizationManage_CIDListKey[encryptID] {
                    // 中台需求: " + body + "
                    let encryptString = "\"" + SecurityUtility.utility.AES256Encrypt( encrypt, key ) + "\""
                    httpBody = encryptString.data(using: .utf8)
                }
            }
        }
        catch {
            print(error)
        }
        
        return httpBody
    }
    
    // 不濾空白
    func converInputToHttpBody2(_ input:[String:Any], _ needEncrypt:Bool) -> Data? {
        
        let jsonData = try? JSONSerialization.data(withJSONObject: input, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        print(jsonString ?? "empty string")
        
        var httpBody:Data? = nil
        do {
            httpBody = try JSONSerialization.data(withJSONObject: input, options: .prettyPrinted)
            if needEncrypt {
                let encryptID = [String](AuthorizationManage_CIDListKey.keys)[AuthorizationManage_Random]
                if let encrypt = String(data: httpBody!, encoding: .utf8)?.replacingOccurrences(of: "\n", with: ""), let key = AuthorizationManage_CIDListKey[encryptID] {
                    // 中台需求: " + body + "
                    let encryptString = "\"" + SecurityUtility.utility.AES256Encrypt( encrypt, key ) + "\""
                    httpBody = encryptString.data(using: .utf8)
                }
            }
        }
        catch {
            print(error)
        }
        
        return httpBody
    }
    
    func CanEnterFeature(_ ID:PlatformFeatureID) -> Bool { // 判斷是否需要登入
        var canEnter = false
        switch ID {

        case .FeatureID_NTRation,
             .FeatureID_ExchangeRate,
             .FeatureID_RegularSavingCalculation,
             .FeatureID_Promotion,
             .FeatureID_News,
             .FeatureID_ServiceBase,
             .FeatureID_Home,
             .FeatureID_Edit,
             .FeatureID_DeviceBinding,
        //for test
//        .FeatureID_QRCodeTrans,
//        .FeatureID_QRPay,
//        .FeatureID_AcceptRules,
//        .FeatureID_GPAccountInfomation,
//        .FeatureID_GPSingleBuy,
//        .FeatureID_GPSingleSell,
//        .FeatureID_GPRegularAccountInfomation,
//        .FeatureID_GPTransactionDetail,
//        .FeatureID_GPGoldPrice,
//             // for mobileTransfer test
//        .FeatureID_MobileNTTransfer,
//        .FeatureID_MobileTransferSetup,
             .FeatureID_ContactCustomerService,
             .FeatureID_ThirdPartyAnnounce:
            canEnter = true
            
        default:
            canEnter = AuthorizationManage.manage.IsLoginSuccess()
        }
        return canEnter
    }
    // $NewWork - 1
    func getPlatformIDByAuthID(_ ID:String) -> PlatformFeatureID? {
        switch ID {
        case "T01": return PlatformFeatureID.FeatureID_AccountOverView
        case "T02": return PlatformFeatureID.FeatureID_AccountDetailView
        case "T03": return PlatformFeatureID.FeatureID_NTAccountTransfer
        case "T04": return PlatformFeatureID.FeatureID_NTTransfer               // 約轉
        case "T06": return PlatformFeatureID.FeatureID_ReservationTransfer
        case "T07": return PlatformFeatureID.FeatureID_ReservationTransferSearchCancel
        case "T08": return PlatformFeatureID.FeatureID_DepositCombinedToDeposit
        case "T09": return PlatformFeatureID.FeatureID_DepositCombinedToDepositSearch
        case "T10": return PlatformFeatureID.FeatureID_LoanPrincipalInterest
        case "T11": return PlatformFeatureID.FeatureID_LoseApply
        case "T12": return PlatformFeatureID.FeatureID_PassbookLoseApply
        case "T13": return PlatformFeatureID.FeatureID_DebitCardLoseApply
        case "T14": return PlatformFeatureID.FeatureID_CheckLoseApply
        case "T15": return PlatformFeatureID.FeatureID_Payment
        case "T16": return PlatformFeatureID.FeatureID_TaxPayment
        case "T17": return PlatformFeatureID.FeatureID_BillPayment
        case "T18": return PlatformFeatureID.FeatureID_FinancialInformation
        case "T19": return PlatformFeatureID.FeatureID_NTRation
        case "T20": return PlatformFeatureID.FeatureID_ExchangeRate
        case "T21": return PlatformFeatureID.FeatureID_RegularSavingCalculation
        case "T22": return PlatformFeatureID.FeatureID_CustomerService
        case "T23": return PlatformFeatureID.FeatureID_Promotion
        case "T24": return PlatformFeatureID.FeatureID_News
        case "T25": return PlatformFeatureID.FeatureID_ServiceBase
        case "T26": return PlatformFeatureID.FeatureID_PersonalMessage
        case "T27": return PlatformFeatureID.FeatureID_PersopnalSetting
        case "T28": return PlatformFeatureID.FeatureID_BasicInfoChange
        case "T29": return PlatformFeatureID.FeatureID_UserNameChange
        case "T30": return PlatformFeatureID.FeatureID_UserPwdChange
        case "T31": return PlatformFeatureID.FeatureID_MessageSwitch
//        case "T32": return PlatformFeatureID.FeatureID_SetAvatar
        //case "T33": return PlatformFeatureID.FeatureID_DeviceBinding //1090729 by chris
        //case "T33": return PlatformFeatureID.FeatureID_Device2Binding  //1090729 by chris
        case "T33": return PlatformFeatureID.FeatureID_OTPDeviceBinding  //1091116 by chiu
        case "T40": return PlatformFeatureID.FeatureID_ContactCustomerService
    //Guester 20180626
        case "T41": return PlatformFeatureID.FeatureID_MobilePay    // 行動支付
        case "T42":
            return PlatformFeatureID.FeatureID_QRCodeTrans  // 掃描轉帳
        case "T43": return PlatformFeatureID.FeatureID_QRPay        // 台灣Pay
    //Guester 20180626 End

    //Guester 20180731
        case "T44": return PlatformFeatureID.FeatureID_GoldPassbook         // 黃金存摺
        case "T45": return PlatformFeatureID.FeatureID_GPAccountInfomation  // 帳戶總覽
        case "T46": return PlatformFeatureID.FeatureID_GPSingleBuy          // 單筆申購
        case "T47": return PlatformFeatureID.FeatureID_GPSingleSell         // 單筆回售
        case "T48": return PlatformFeatureID.FeatureID_GPRegularAccountInfomation   // 定期投資戶總覽
        case "T49": return PlatformFeatureID.FeatureID_GPTransactionDetail  // 往來明細
        case "T50": return PlatformFeatureID.FeatureID_GPGoldPrice          // 牌告價格
    //Guester 20180731 End
    //2019-10-2 add by sweney
        case "T57": return PlatformFeatureID.FeatureID_UserPwdChangeByPass   //密碼沿用
        case "T58": return PlatformFeatureID.FeatureID_USAccount             //常用轉入帳號
        case "T59": return PlatformFeatureID.FeatureID_LoanPartialSettIement //部分清償
       // case "T60": return PlatformFeatureID.//全部清償
        case "T61": return PlatformFeatureID.FeatureID_FastLogIn             //快速登入
        //2019-10-2 end
        case "T62": return PlatformFeatureID.FeatureID_TodayBillQry           //當日待補票據查詢
        case "T63":
            return PlatformFeatureID.FeatureID_QRPay0       //出示付款碼
        case "T64":
            return PlatformFeatureID.FeatureID_QRPayDetailView //交易紀錄/退貨
        case "T65":
            return PlatformFeatureID.FeatureID_InitTransToNoQry //約定轉帳帳號查詢
        case "T66":
            return PlatformFeatureID.FeatureID_Quintuple //振興五倍券綁定
           // return PlatformFeatureID.FeatureID_Triple //振興三倍券綁定
            
        case "T67":
            return PlatformFeatureID.FeatureID_MOTPSetting      //申請OTP服務
        case "T68" :
            return PlatformFeatureID.FeatureID_MOTPEdit            //OTP服務裝置編輯
        case "T69":
            return PlatformFeatureID.FeatureID_GPRiskEvaluation       //投資風險屬性評估
        case "T70" :
            return PlatformFeatureID.FeatureID_EinvoiceShow            //發票載具條碼
        case "T71" :
            return PlatformFeatureID.FeatureID_MobileTransfer         //手機門號轉帳
        case "T72" :
            return PlatformFeatureID.FeatureID_MobileTransferSetup    //註冊帳號
        case "T73" :
            return PlatformFeatureID.FeatureID_MobileNTTransfer       //手機門號即時轉帳
        case "T74" :
            return PlatformFeatureID.FeatureID_QRTaipowerDetail       //台電
        case "T75" :
            return PlatformFeatureID.FeatureID_Cardless     //無卡提款
        case "T76" :
            return PlatformFeatureID.FeatureID_CardlessSetup      //無卡預約
        case "T77" :
            return PlatformFeatureID.FeatureID_CardlessQry     //無卡預約查詢
        case "T78" :
            return PlatformFeatureID.FeatureID_CardlessDisable      //無卡關閉
       
       
        default: return nil
        }
    }
    // $NewWork - 2
    func getAuthIDByPlatformID(_ ID:PlatformFeatureID) -> String? {
        switch ID {
        case PlatformFeatureID.FeatureID_AccountOverView: return "T01"
        case PlatformFeatureID.FeatureID_AccountDetailView: return "T02"
        case PlatformFeatureID.FeatureID_NTAccountTransfer: return "T03"
        case PlatformFeatureID.FeatureID_NTTransfer: return "T04"               // 約轉
        case PlatformFeatureID.FeatureID_ReservationTransfer: return "T06"
        case PlatformFeatureID.FeatureID_ReservationTransferSearchCancel: return "T07"
        case PlatformFeatureID.FeatureID_DepositCombinedToDeposit: return "T08"
        case PlatformFeatureID.FeatureID_DepositCombinedToDepositSearch: return "T09"
        case PlatformFeatureID.FeatureID_LoanPrincipalInterest: return "T10"
        case PlatformFeatureID.FeatureID_LoseApply: return "T11"
        case PlatformFeatureID.FeatureID_PassbookLoseApply: return "T12"
        case PlatformFeatureID.FeatureID_DebitCardLoseApply: return "T13"
        case PlatformFeatureID.FeatureID_CheckLoseApply: return "T14"
        case PlatformFeatureID.FeatureID_Payment: return "T15"
        case PlatformFeatureID.FeatureID_TaxPayment: return "T16"
        case PlatformFeatureID.FeatureID_BillPayment: return "T17"
        case PlatformFeatureID.FeatureID_FinancialInformation: return "T18"
        case PlatformFeatureID.FeatureID_NTRation: return "T19"
        case PlatformFeatureID.FeatureID_ExchangeRate: return "T20"
        case PlatformFeatureID.FeatureID_RegularSavingCalculation: return "T21"
        case PlatformFeatureID.FeatureID_CustomerService: return "T22"
        case PlatformFeatureID.FeatureID_Promotion: return "T23"
        case PlatformFeatureID.FeatureID_News: return "T24"
        case PlatformFeatureID.FeatureID_ServiceBase: return "T25"
        case PlatformFeatureID.FeatureID_PersonalMessage: return "T26"
        case PlatformFeatureID.FeatureID_PersopnalSetting: return "T27"
        case PlatformFeatureID.FeatureID_BasicInfoChange: return "T28"
        case PlatformFeatureID.FeatureID_UserNameChange: return "T29"
        case PlatformFeatureID.FeatureID_UserPwdChange: return "T30"
        case PlatformFeatureID.FeatureID_MessageSwitch: return "T31"
//        case PlatformFeatureID.FeatureID_SetAvatar: return "T32"
        //case PlatformFeatureID.FeatureID_DeviceBinding: return "T33"
        //case PlatformFeatureID.FeatureID_Device2Binding: return "T33"  //1090729 by chris
        case PlatformFeatureID.FeatureID_OTPDeviceBinding: return "T33"  //1091116 by chiu
        case PlatformFeatureID.FeatureID_ContactCustomerService: return "T40"
        //Guester 20180626
        case PlatformFeatureID.FeatureID_MobilePay: return "T41"    // 行動支付
        case PlatformFeatureID.FeatureID_QRCodeTrans:
            return "T42"  // 掃描轉帳
        case PlatformFeatureID.FeatureID_QRPay:
            return "T43"        // 台灣Pay碼
            //Guester 20180626 End
            
        //Guester 20180731
        case PlatformFeatureID.FeatureID_GoldPassbook: return "T44"         // 黃金存摺
        case PlatformFeatureID.FeatureID_GPAccountInfomation: return "T45"  // 帳戶總覽
        case PlatformFeatureID.FeatureID_GPSingleBuy: return "T46"          // 單筆申購
        case PlatformFeatureID.FeatureID_GPSingleSell: return "T47"         // 單筆回售
        case PlatformFeatureID.FeatureID_GPRegularAccountInfomation: return "T48"   // 定期投資戶總覽
        case PlatformFeatureID.FeatureID_GPTransactionDetail: return "T49"  // 往來明細
        case PlatformFeatureID.FeatureID_GPGoldPrice: return "T50"          // 牌告價格
        //Guester 20180731 End
        //2019-10-2 add by sweney
        case PlatformFeatureID.FeatureID_UserPwdChangeByPass: return "T57"  //密碼沿用
        case PlatformFeatureID.FeatureID_USAccount: return "T58"            //常用轉入帳號
        case PlatformFeatureID.FeatureID_LoanPartialSettIement: return "T59"            //部分清償
      // case PlatformFeatureID. : return "T60"            //全部清償
        case PlatformFeatureID.FeatureID_FastLogIn:return "T61"             //快速登入
        //2019-10-2 end
        case PlatformFeatureID.FeatureID_TodayBillQry:return "T62"    //當日待補票據查詢
        case  PlatformFeatureID.FeatureID_QRPay0: return "T63"    // 出示付款碼
        case PlatformFeatureID.FeatureID_QRPayDetailView: return "T64" //交易紀錄/退貨
        case   PlatformFeatureID.FeatureID_InitTransToNoQry: return "T65" //約定轉帳帳號查詢
       // case   PlatformFeatureID.FeatureID_Triple: return "T66" //振興三倍券綁定
        case   PlatformFeatureID.FeatureID_Quintuple: return "T66" //振興五倍券綁定
        case   PlatformFeatureID.FeatureID_MOTPSetting: return "T67" //申請OTP服務
        case   PlatformFeatureID.FeatureID_MOTPEdit: return "T68" //OTP服務裝置編輯
        case   PlatformFeatureID.FeatureID_GPRiskEvaluation: return "T69" //風險評估
        case   PlatformFeatureID.FeatureID_EinvoiceShow:return "T70" //發票載具條碼
        case   PlatformFeatureID.FeatureID_MobileTransfer: return "T71" //手機門號轉帳
        case   PlatformFeatureID.FeatureID_MobileTransferSetup: return "T72" //註冊帳號
        case   PlatformFeatureID.FeatureID_MobileNTTransfer: return "T73" //手機門號即時轉帳
        case   PlatformFeatureID.FeatureID_QRTaipowerDetail: return "T74"       //台電
        case   PlatformFeatureID.FeatureID_Cardless: return "T75"       //無卡預約
        case   PlatformFeatureID.FeatureID_CardlessSetup: return "T76"       //無卡預約
        case   PlatformFeatureID.FeatureID_CardlessQry: return "T77"       //無卡預約
        case   PlatformFeatureID.FeatureID_CardlessDisable: return "T78"       //無卡預約
        default: return nil
        }
    }
    func checkAuth(_ pID:PlatformFeatureID) -> Bool {
        switch pID {
        case .FeatureID_NTRation,
             .FeatureID_ExchangeRate,
             .FeatureID_RegularSavingCalculation,
             .FeatureID_Promotion,
             .FeatureID_News,
             .FeatureID_ServiceBase,
             .FeatureID_Home,
             .FeatureID_Edit,
             .FeatureID_DeviceBinding,
             .FeatureID_Device2Binding, //1090729 by chris
             .FeatureID_OTPDeviceBinding, // 1091116 by chiu
             .FeatureID_ContactCustomerService,
             .FeatureID_ThirdPartyAnnounce
//             // for mobileTransfer test
//             ,.FeatureID_MobileTransferSetup,
//             .FeatureID_MobileNTTransfer
             :
            return true
        default:
            if authList?.firstIndex(of: pID) == nil {
                return false
            }
            else {
                return true
            }
        }
    }
    func SaveIDListInFile(_ addList:[PlatformFeatureID]) {
        var IDList = [String]()
        addList.forEach{ ID in IDList.append(ID.rawValue.description) }
        /*  將使用者原有加入的功能，但因此次沒有授權開啟，所以沒有在list中，所以需要重新加入  */
        for (key,value) in needReAddList {
            if value < IDList.count {
                IDList.insert(key.rawValue.description, at: value)
            }
            else {
                IDList.append(key.rawValue.description)
            }
        }
        
        let ID = IDList.joined(separator: AuthorizationManage_IDList_Separator)
        if IsLoginSuccess() {
            if loginInfo != nil {
                /* 因大小寫身分證都是同一人，統一轉成大寫當key值 */
                let key = SecurityUtility.utility.AES256Encrypt("\(loginInfo!.bankCode)\(loginInfo!.aot.uppercased())", "\(SEA1)\(SEA2)\(SEA3)")
                SecurityUtility.utility.writeFileByKey(ID, SetKey: key)
            }
        }
        else {
            SecurityUtility.utility.writeFileByKey(ID, SetKey: File_IDList_Key)
        }
    }
    
    func GetPlatformList(_ type:AuthorizationType) -> [PlatformFeatureID]? {
        var list:[PlatformFeatureID]? = nil
        switch type {
        case .Fixd_Type:
            //for test
//            list = [.FeatureID_Edit, .FeatureID_QRPay, .FeatureID_QRCodeTrans]
            list = [.FeatureID_Edit]
            
        case .Default_Type:
            if IsLoginSuccess() {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView,.FeatureID_ExchangeRate, .FeatureID_NTTransfer, .FeatureID_MobileTransferSetup,.FeatureID_CardlessSetup]
            }
            else {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView,.FeatureID_ExchangeRate, .FeatureID_NTTransfer, .FeatureID_MobileTransferSetup, .FeatureID_News]
            }
            
        case .User_Type:
            needReAddList.removeAll()
            if IsLoginSuccess() {
                if loginInfo != nil {
                    let key = SecurityUtility.utility.AES256Encrypt("\(loginInfo!.bankCode)\(loginInfo!.aot.uppercased())", "\(SEA1)\(SEA2)\(SEA3)")
                    if let IDString = SecurityUtility.utility.readFileByKey(SetKey: key) {
                        if !(IDString as! String).isEmpty {
                            let IDStringList = (IDString as! String).components(separatedBy: AuthorizationManage_IDList_Separator)
                            list = [PlatformFeatureID]()
                            let editList = GetPlatformList(.Edit_Type)
                            IDStringList.forEach { ID in
                                let featureID = PlatformFeatureID(rawValue: Int(ID)!)!
                                let info = Platform.plat.getFeatureInfoByID(featureID)
                                if editList?.firstIndex(of: featureID) != nil || editList?.firstIndex(of: (info?.belong ?? featureID)) != nil {
                                    list?.append( PlatformFeatureID(rawValue: Int(ID)!)! )
                                }
                            }
                        }
                        else {
                            list = [PlatformFeatureID]()
                        }
                    }
                }
            }
            else {
                if let IDString = SecurityUtility.utility.readFileByKey(SetKey: File_IDList_Key) {
                    if !(IDString as! String).isEmpty {
                        let IDStringList = (IDString as! String).components(separatedBy: AuthorizationManage_IDList_Separator)
                        list = [PlatformFeatureID]()
                        let editList = GetPlatformList(.Edit_Type)
                        IDStringList.forEach { ID in
                            let featureID = PlatformFeatureID(rawValue: Int(ID)!)!
                            let info = Platform.plat.getFeatureInfoByID(featureID)
                            if editList?.firstIndex(of: featureID) != nil || editList?.firstIndex(of: (info?.belong ?? featureID)) != nil {
                                list?.append( PlatformFeatureID(rawValue: Int(ID)!)! )
                            }
                        }
                    }
                    else {
                        list = [PlatformFeatureID]()
                    }
                }
            }
            
        case .FeatureWall_Type:
            list = [PlatformFeatureID]()
            list?.append(contentsOf: (GetPlatformList(.User_Type) ?? GetPlatformList(.Default_Type)!))
            if let fixList = GetPlatformList(.Fixd_Type) {
                list?.append(contentsOf: fixList)
            }
            
//        case .Edit_Type:
//            list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_NTAccountTransfer, .FeatureID_LoseApply, .FeatureID_Payment, .FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_PersopnalSetting, .FeatureID_DeviceBinding, .FeatureID_Device2Binding, .FeatureID_OTPDeviceBinding]
            
        case .Menu_Type, .Edit_Type:
            if !IsLoginSuccess() {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_FinancialInformation, .FeatureID_MobilePay,/* .FeatureID_Triple, *//* .FeatureID_GoldPassbook,*/ .FeatureID_CustomerService, /*.FeatureID_DeviceBinding,*/.FeatureID_ContactCustomerService]
//                // for mobileTransfer test
//                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_FinancialInformation, .FeatureID_MobilePay,/* .FeatureID_Triple, *//* .FeatureID_GoldPassbook,*/ .FeatureID_CustomerService, /*.FeatureID_DeviceBinding,*/.FeatureID_ContactCustomerService, .FeatureID_MobileTransfer]
            }
            else {
                list = [.FeatureID_AccountOverView,
                        .FeatureID_AccountDetailView,
                        .FeatureID_NTAccountTransfer,
                        .FeatureID_MobileTransfer,
                        .FeatureID_Cardless,
                        .FeatureID_LoseApply, .FeatureID_Payment,
                        .FeatureID_FinancialInformation,
                        .FeatureID_MobilePay,.FeatureID_Quintuple,
                        .FeatureID_GoldPassbook,
                        .FeatureID_CustomerService,
                        .FeatureID_PersopnalSetting, /*.FeatureID_DeviceBinding , .FeatureID_Device2Binding,*/
                        .FeatureID_OTPDeviceBinding,.FeatureID_ContactCustomerService]   //1090729 by chris add FeatureID_Device2Binding 1091116 add .FeatureID_OTPDeviceBinding
            }
        }
        
        if list != nil && IsLoginSuccess() {
            let sList = list!
            list?.removeAll()
            for ID in sList {
                if authList?.firstIndex(of: ID) != nil {
                    list?.append(ID)
                }
                else {
                    if type == .User_Type {
                        needReAddList[ID] = sList.firstIndex(of: ID)!
                    }
                }
            }
        }
        
        return list
    }
    
    func getAuthList(_ list:[PlatformFeatureID]?) -> [PlatformFeatureID]? {
        var temp:[PlatformFeatureID]? = nil
        if list != nil && IsLoginSuccess() {
            temp = [PlatformFeatureID]()
            for ID in list! {
                if authList?.firstIndex(of: ID) != nil {
                    temp?.append(ID)
                }
            }
        }
        return temp
    }
}
