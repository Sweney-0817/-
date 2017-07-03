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
            
        case .Default_Type: break;
            
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
            list = [.FeatureID_AccountOverView,.FeatureID_AccountDetailView, .FeatureID_NTTransfer, .FeatureID_LoseApply, .FeatureID_ReservationTransfer, .FeatureID_ReservationTransferSearchCancel]
            
        case .Menu_Type:
            list = [PlatformFeatureID]()
            if let editList = GetPlatformList(.Edit_Type) {
                list?.append(contentsOf: editList)
            }
            if let fixdList = GetPlatformList(.Fixd_Type) {
                list?.append(contentsOf: fixdList)
            }
        }
        
        return list
    }
}
