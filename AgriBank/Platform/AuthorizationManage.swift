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


struct ResponseLoginInfo {
    var CNAME:String? = nil         // 用戶名稱
    var Token:String? = nil         // Token
    var USUDID:String? = nil        // 使用者ID
    var Balance:Double? = nil       // 餘額
}

class AuthorizationManage {
    static let manage = AuthorizationManage()
    private let featureList:[PlatformFeatureID:Bool]? = nil
    private var userInfo:ResponseLoginInfo? = nil       // 登入成功後回傳的資訊
    private var loginInfo:LoginStrcture? = nil          // 使用者登入的資訊
    private var apnsToken:String? = nil                 // APNS回傳的token
    
    func SetResponseLoginInfo(_ info:ResponseLoginInfo?, _ authList:[[String:String]]?) {
        userInfo = info
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
        return userInfo?.Token != nil
    }

    func getHttpHead(_ isNeedCID:Bool) -> [String:String] {
        var head = AuthorizationManage_HttpHead_Default
        head[AuthorizationManage_HttpHead_Token] = userInfo?.Token ?? ""
    
        if isNeedCID {
//            let random = Int(arc4random_uniform(UInt32(AuthorizationManage_CIDListKey.count)))
//            head[AuthorizationManage_HttpHead_CID] = [String](AuthorizationManage_CIDListKey.keys)[random]
            head[AuthorizationManage_HttpHead_CID] = "a25dq"
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
//                let random = Int(arc4random_uniform(UInt32(AuthorizationManage_CIDListKey.count)))
//                let encryptID = [String](AuthorizationManage_CIDListKey.keys)[random]
                let encryptID = "a25dq"
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
    
    func CanEnterFeature(_ ID:PlatformFeatureID) -> Bool { // 判斷是否需要登入
        var canEnter = false
        switch ID {
        case .FeatureID_NTRation, .FeatureID_ExchangeRate, .FeatureID_RegularSavingCalculation, .FeatureID_Promotion, .FeatureID_News, .FeatureID_ServiceBase, .FeatureID_Home, .FeatureID_Edit:
            canEnter = true
            
        default:
            canEnter = userInfo?.Token != nil ? true : false
        }
        return canEnter
    }
    
    func IsOpen(_ ID:PlatformFeatureID) -> Bool {
        if let bIS = featureList?[ID] {
            return bIS
        }
        return false
    }
    
    func SetAuthorization() {
        // 中台 <-轉換-> 功能代碼
    }
    
    func SaveIDListInFile(_ addList:[PlatformFeatureID]) {
        var IDList = [String]()
        addList.forEach{ ID in IDList.append(ID.rawValue.description) }
        let ID = IDList.joined(separator: AuthorizationManage_IDList_Separator)
        if userInfo?.Token != nil {
            SecurityUtility.utility.writeFileByKey(ID, SetKey: File_IDList_Key)
        }
        else {
            SecurityUtility.utility.writeFileByKey(ID, SetKey: File_NoLogin_IDList_key)
        }
    }
    
    func GetPlatformList(_ type:AuthorizationType) -> [PlatformFeatureID]? {
        var list:[PlatformFeatureID]? = nil
        switch type {
        case .Fixd_Type:
            list = [.FeatureID_Edit]
            
        case .Default_Type:
            if userInfo?.Token != nil {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_ExchangeRate, .FeatureID_Promotion, .FeatureID_ServiceBase, .FeatureID_News]
            }
            else {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_ExchangeRate, .FeatureID_Promotion, .FeatureID_ServiceBase]
            }
            
        case .User_Type:
            if userInfo?.Token != nil {
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
                }
            }
            else {
                if let IDString = SecurityUtility.utility.readFileByKey(SetKey: File_NoLogin_IDList_key) {
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
                }
            }
            
        case .FeatureWall_Type:
            list = [PlatformFeatureID]()
            list?.append(contentsOf: (GetPlatformList(.User_Type) ?? GetPlatformList(.Default_Type)!))
            if let fixList = GetPlatformList(.Fixd_Type) {
                list?.append(contentsOf: fixList)
            }
            
        case .Edit_Type:
            list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_NTAccountTransfer, .FeatureID_LoseApply, .FeatureID_Payment, .FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_PersopnalSetting, .FeatureID_DeviceBinding]
            
            
        case .Menu_Type:
            if userInfo?.Token == nil {
                list = [.FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_DeviceBinding]
            }
            else {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_NTAccountTransfer, .FeatureID_LoseApply, .FeatureID_Payment, .FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_PersopnalSetting, .FeatureID_DeviceBinding]
            }
        }
        
        return list
    }
}
