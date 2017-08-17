//
//  UIPlatform.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/16.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

extension Platform {
    func getUIByID(_ UIID: UIID, _ owner: Any? = nil) -> Any? {
        
        var any:Any? = nil
        
        switch UIID {
        case .UIID_FeatureWall:
            any = FeatureWallView()
            
        case .UIID_Introduction:
            any = IntroductionView()
            
        case .UIID_ChooseType:
            any = ChooseTypeView()
        
        case .UIID_SideMenu:
            any = SideMenuViewController(SetCenter: getControllerByID(.FeatureID_Home), SetLeft: nil, SetRight: getControllerByID(.FeatureID_Menu), SetWidthRate:0.3)
            
        case .UIID_DatePickerView:
            any = DatePickerView()
            
        default:
            any = Bundle.main.loadNibNamed(UIID.NibName()!, owner: owner, options: nil)?.first
        }
        
        return any
    }
}
