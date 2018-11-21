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
let AuthorizationManage_CIDListKey = ["a25dq":"hs3rwPsoYknnCCWjqIX57RgRflYGhKO1tmQxqWps21k=",
                                      "b4wp0":"Az9jU/D/6d6+MANr/y/V78FimjSMHNj9A4i7TGS3JyU=",
                                      "cni24":"gvpZZ70O8Tks20vMcGUEi2IiKDPk74gUhz9cndSIBTA=",
                                      "dw67m":"KkfD6l0TqI50ix7uBPjKC52XrZhuJFVoAHWR4B1TFUo=",
                                      "ez98f":"hIb8YaYT2ooLiU2q39k/O5s8W0VO0BdGesGbDZISGiY="]
let AuthorizationManage_Random = Int(arc4random_uniform(UInt32(AuthorizationManage_CIDListKey.count)))

struct ResponseLoginInfo {
    var CNAME:String? = nil         // 用戶名稱
    var Token:String? = nil         // Token
    var USUDID:String? = nil        // 使用者ID
    var Balance:String? = nil       // 餘額
    var STATUS:String? = nil        // 帳戶狀態 
}

//struct QRPAcception {
//    //for test
////    var Read: String = "Y"
//    var Read: String = "N"
//    var Version: String = ""
//    var Content: String = ""
//}

//struct GoldAcception {
//    //for test
////    var Read: String = "Y"
//    var Read: String = "N"
//    var Version: String = ""
//    var Content: String = ""
//}

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
    //QRP同意條款狀態
//    private var m_qrpAcception: QRPAcception = QRPAcception()
    //黃金同意條款狀態
//    private var m_goldAcception: GoldAcception = GoldAcception()
    
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
                        
                    default:
                        if let pID = getPlatformIDByAuthID(ID) {
                            if authList?.index(of: pID) == nil {
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
            (UIApplication.shared.delegate as! AppDelegate).removeNotificationAllEvent()
            canNTNonAgreedTransfer = false
            canReservationTransferCancel = false
            canDepositTermination = false
            canPayLoan = false
            canChangeBaseInfo = false
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
        print(jsonString)
        
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
             .FeatureID_ContactCustomerService:
            canEnter = true
            
        default:
            canEnter = AuthorizationManage.manage.IsLoginSuccess()
        }
        return canEnter
    }
    
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
        case "T32": return PlatformFeatureID.FeatureID_SetAvatar
        case "T33": return PlatformFeatureID.FeatureID_DeviceBinding
        case "T40": return PlatformFeatureID.FeatureID_ContactCustomerService
    //Guester 20180626
        case "T41": return PlatformFeatureID.FeatureID_MobilePay    // 行動支付
        case "T42": return PlatformFeatureID.FeatureID_QRCodeTrans  // QR Code轉帳
        case "T43": return PlatformFeatureID.FeatureID_QRPay        // QR Pay
    //Guester 20180626 End

    //Guester 20180731
        case "T44": return PlatformFeatureID.FeatureID_GoldPassbook         // 黃金存摺
        case "T45": return PlatformFeatureID.FeatureID_GPAccountInfomation  // 帳號總覽
        case "T46": return PlatformFeatureID.FeatureID_GPSingleBuy          // 單筆申購
        case "T47": return PlatformFeatureID.FeatureID_GPSingleSell         // 單筆回售
        case "T48": return PlatformFeatureID.FeatureID_GPRegularAccountInfomation   // 定期投資戶總覽
        case "T49": return PlatformFeatureID.FeatureID_GPTransactionDetail  // 交易明細
        case "T50": return PlatformFeatureID.FeatureID_GPGoldPrice          // 牌告價格
    //Guester 20180731 End
        default: return nil
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
                let key = SecurityUtility.utility.AES256Encrypt("\(loginInfo!.bankCode)\(loginInfo!.account.uppercased())", AES_Key)
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
//            list = [.FeatureID_Edit, .FeatureID_QRPay, .FeatureID_GPRegularAccountInfomation]
            list = [.FeatureID_Edit]
            
        case .Default_Type:
            if IsLoginSuccess() {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_ExchangeRate, .FeatureID_Promotion, .FeatureID_ServiceBase]
            }
            else {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_ExchangeRate, .FeatureID_Promotion, .FeatureID_ServiceBase, .FeatureID_News]
            }
            
        case .User_Type:
            needReAddList.removeAll()
            if IsLoginSuccess() {
                if loginInfo != nil {
                    let key = SecurityUtility.utility.AES256Encrypt("\(loginInfo!.bankCode)\(loginInfo!.account.uppercased())", AES_Key)
                    if let IDString = SecurityUtility.utility.readFileByKey(SetKey: key) {
                        if !(IDString as! String).isEmpty {
                            let IDStringList = (IDString as! String).components(separatedBy: AuthorizationManage_IDList_Separator)
                            list = [PlatformFeatureID]()
                            let editList = GetPlatformList(.Edit_Type)
                            IDStringList.forEach { ID in
                                let featureID = PlatformFeatureID(rawValue: Int(ID)!)!
                                let info = Platform.plat.getFeatureInfoByID(featureID)
                                if editList?.index(of: featureID) != nil || editList?.index(of: (info?.belong ?? featureID)) != nil {
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
                            if editList?.index(of: featureID) != nil || editList?.index(of: (info?.belong ?? featureID)) != nil {
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
//            list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_NTAccountTransfer, .FeatureID_LoseApply, .FeatureID_Payment, .FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_PersopnalSetting, .FeatureID_DeviceBinding]
            
        case .Menu_Type, .Edit_Type:
            if !IsLoginSuccess() {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_FinancialInformation, .FeatureID_MobilePay, /* .FeatureID_GoldPassbook,*/ .FeatureID_CustomerService, .FeatureID_DeviceBinding,.FeatureID_ContactCustomerService]
            }
            else {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_NTAccountTransfer, .FeatureID_LoseApply, .FeatureID_Payment, .FeatureID_FinancialInformation, .FeatureID_MobilePay, .FeatureID_GoldPassbook, .FeatureID_CustomerService, .FeatureID_PersopnalSetting, .FeatureID_DeviceBinding, .FeatureID_ContactCustomerService]
            }
        }
        
        if list != nil && IsLoginSuccess() {
            let sList = list!
            list?.removeAll()
            for ID in sList {
                if authList?.index(of: ID) != nil {
                    list?.append(ID)
                }
                else {
                    if type == .User_Type {
                        needReAddList[ID] = sList.index(of: ID)!
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
                if authList?.index(of: ID) != nil {
                    temp?.append(ID)
                }
            }
        }
        return temp
    }

//    func setQRPAcception(_ data:[String:String]) {
//        m_qrpAcception.Read = data["Read"] ?? "N"
//        m_qrpAcception.Version = data["Version"] ?? ""
//        m_qrpAcception.Content = data["Content"] ?? ""
//    }
    
//    func getQRPAcception() -> QRPAcception {
//        return m_qrpAcception
//    }
    
//    func canEnterQRP() -> Bool {
//        if (m_qrpAcception.Read == "Y") {
//            return true
//        }
//        else {
//            return false
//        }
//    }
    
//    func setGoldAcception(_ data:[String:String]) {
//        m_goldAcception.Read = data["Read"] ?? "N"
//        m_goldAcception.Version = data["Version"] ?? ""
//        m_goldAcception.Content = data["Content"] ?? ""
//    }
    
//    func getGoldAcception() -> GoldAcception {
//        return m_goldAcception
//    }
    
//    func canEnterGold() -> Bool {
//        if (m_goldAcception.Read == "Y") {
//            return true
//        }
//        else {
//            return false
//        }
//    }
}
