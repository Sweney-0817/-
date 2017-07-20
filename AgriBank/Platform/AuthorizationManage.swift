//
//  AuthorizationManage.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/16.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

class AuthorizationManage {
    static let manage = AuthorizationManage()
    private let featureList:[PlatformFeatureID:Bool]? = nil
    private var loginToken:String? = nil
    private let CIDListKey = ["a25dq":"hs3rwPsoYknnCCWjqIX57RgRflYGhKO1tmQxqWps21k=",
                              "b4wp0":"Az9jU/D/6d6+MANr/y/V78FimjSMHNj9A4i7TGS3JyU=",
                              "cni24":"gvpZZ70O8Tks20vMcGUEi2IiKDPk74gUhz9cndSIBTA=",
                              "dw67m":"KkfD6l0TqI50ix7uBPjKC52XrZhuJFVoAHWR4B1TFUo=",
                              "ez98f":"hIb8YaYT2ooLiU2q39k/O5s8W0VO0BdGesGbDZISGiY="
                             ]
    
    func SetLoginToken(_ token:String?) {
        loginToken = token
    }

    func getHttpHead(_ isNeedToken:Bool) -> [String:String] {
        var head = ["Content-Type":"application/json", "DeviceID":UIDevice.current.identifierForVendor!.uuidString]
        if isNeedToken {
            head["Token"] = loginToken ?? ""
            head["CID"] = "a25dq"
        }
        return head
    }
    
    func GetCIDKey(_ ID:String) -> String? {
        return CIDListKey[ID]
    }
    
    func converInputToHttpBody(_ input:[String:Any], _ needEncrypt:Bool, _ encryptID:String? = nil) -> Data? {
        var httpBody:Data? = nil
        do {
            httpBody = try JSONSerialization.data(withJSONObject: input, options: .prettyPrinted)
            if needEncrypt {
                if let encrypt = String(data: httpBody!, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: ""), let key = CIDListKey[encryptID ?? ""] {
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
    
    func CanEnterFeature(_ ID:PlatformFeatureID) -> Bool {
        var canEnter = false
        switch ID {
        case .FeatureID_NTRation, .FeatureID_ExchangeRate, .FeatureID_RegularSavingCalculation, .FeatureID_Promotion, .FeatureID_News, .FeatureID_ServiceBase, .FeatureID_Home, .FeatureID_Edit:
            canEnter = true
        default:
            canEnter = loginToken != nil ? true : false
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
        let ID = IDList.joined(separator: ",")
        if loginToken != nil {
            SecurityUtility.utility.writeFileByKey(ID, SetKey: File_IDList_Key, setEncryptKey: AES_Key)
        }
        else {
            SecurityUtility.utility.writeFileByKey(ID, SetKey: File_NoLogin_IDList_key, setEncryptKey: AES_Key)
        }
    }
    
    func GetPlatformList(_ type:AuthorizationType) -> [PlatformFeatureID]? {
        var list:[PlatformFeatureID]? = nil
        switch type {
        case .Fixd_Type:
            list = [.FeatureID_Edit]
            
        case .Default_Type:
            if loginToken != nil {
                if SecurityUtility.utility.readFileByKey(SetKey: File_IDList_Key, setDecryptKey: AES_Key) == nil {
                    list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_ExchangeRate, .FeatureID_Promotion, .FeatureID_ServiceBase, .FeatureID_News]
                }
            }
            else {
                if SecurityUtility.utility.readFileByKey(SetKey: File_NoLogin_IDList_key, setDecryptKey: AES_Key) == nil {
                    list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_ExchangeRate, .FeatureID_Promotion, .FeatureID_ServiceBase]
                }
            }
            
        case .User_Type:
            if let IDString = SecurityUtility.utility.readFileByKey(SetKey: File_IDList_Key, setDecryptKey: AES_Key) {
                if !(IDString as! String).isEmpty {
                    let IDStringList = (IDString as! String).components(separatedBy: ",")
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
            
        case .FeatureWall_Type:
            list = [PlatformFeatureID]()
            if let defaultList = GetPlatformList(.Default_Type) {
                list?.append(contentsOf: defaultList)
            }
            if let userList = GetPlatformList(.User_Type) {
                list?.append(contentsOf: userList)
            }
            if let fixList = GetPlatformList(.Fixd_Type) {
                list?.append(contentsOf: fixList)
            }
            
        case .Edit_Type:
            list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_NTAccountTransfer, .FeatureID_LoseApply, .FeatureID_Payment, .FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_PersopnalSetting, .FeatureID_DeviceBinding]
            
            
        case .Menu_Type:
            if loginToken == nil {
                list = [.FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_DeviceBinding]
            }
            else {
                list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_NTAccountTransfer, .FeatureID_LoseApply, .FeatureID_Payment, .FeatureID_FinancialInformation, .FeatureID_CustomerService, .FeatureID_PersopnalSetting, .FeatureID_DeviceBinding]
            }
        }
        
        return list
    }
}
