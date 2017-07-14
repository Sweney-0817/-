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
    
    func SetLoginToken(_ token:String?) {
        loginToken = token
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
    
    func GetPlatformList(_ type:AuthorizationType) -> [PlatformFeatureID]? {
        var list:[PlatformFeatureID]? = nil
        switch type {
        case .Fixd_Type:
            list = [.FeatureID_Edit]
            
        case .Default_Type:
            if SecurityUtility.utility.readFileByKey(SetKey: File_IDList_Key, setDecryptKey: AES_Key) == nil {
                if loginToken == nil {
                    list = [.FeatureID_AccountOverView, .FeatureID_AccountDetailView, .FeatureID_ExchangeRate, .FeatureID_Promotion, .FeatureID_ServiceBase, .FeatureID_News]
                }
                else {
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
