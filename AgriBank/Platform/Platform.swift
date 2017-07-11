//
//  Platform.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/5.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import Foundation
import UIKit

class Platform {
    static let plat:Platform = Platform()
    private var informationList = [PlatformFeatureID:FeatureStruct]()
    private var currentFeatureID:PlatformFeatureID? = nil
    
    func getControllerByID(_ FeatureID:PlatformFeatureID) -> UIViewController {
        var controller:UIViewController? = nil
        let defaultController = UIViewController()
        
        switch FeatureID {
    
        default:
            controller = UIStoryboard(name: FeatureID.StoryBoardName(), bundle: nil).instantiateViewController(withIdentifier: FeatureID.StoryBoardID())
        }
        
        if FeatureID != .FeatureID_Confirm && FeatureID != .FeatureID_Result {
            (controller as! BaseViewController).needShowBackBarItem = false
            currentFeatureID = FeatureID
        }
        
        return controller ?? defaultController
    }
    
    func getFeatureNameByID(_ ID:PlatformFeatureID) -> String {
        return ID.Name()
    }
    
    func getFeatureInfoByID(_ ID:PlatformFeatureID) -> FeatureStruct? {
        if let content = informationList[ID] {
            return content
        }
        else {
            return nil
        }
    }
    
    func getCurrentFeatureID() -> PlatformFeatureID {
        var currentID:PlatformFeatureID = .FeatureID_Home
        if currentFeatureID != nil {
            currentID = currentFeatureID!
        }
        return currentID
    }
    
    func popToRootViewController() {
        currentFeatureID = .FeatureID_Home
    }
    
    init() {
        var feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_Home] = feature  // 首頁
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_AccountOverView] = feature   // 帳戶總覽
        
//        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
//        informationList[.FeatureID_DemandDepositActDetail] = feature // 活期存款帳戶明細
//        
//        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
//        informationList[.FeatureID_CheckDepositActDetail] = feature  // 支票存款帳戶明細
//        
//        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
//        informationList[.FeatureID_TimeDepositActDetail] = feature   // 定期存款帳戶明細
//        
//        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
//        informationList[.FeatureID_LoansActDetail] = feature         // 放款帳戶明細
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_AccountDetailView] = feature      // 帳戶往來明細
        
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_PassbookLoseApply,.FeatureID_DebitCardLoseApply,.FeatureID_CheckLoseApply], belong: nil)
        informationList[.FeatureID_LoseApply] = feature              // 掛失申請
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_LoseApply)
        informationList[.FeatureID_PassbookLoseApply] = feature      // 存摺掛失
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_LoseApply)
        informationList[.FeatureID_DebitCardLoseApply] = feature     // 金融卡掛失
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_LoseApply)
        informationList[.FeatureID_CheckLoseApply] = feature         // 支票掛失
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_Edit] = feature                   // 新增/編輯
        
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_Confirm] = feature                // 確認
        
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_Result] = feature                 // 結果
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_NTTransfer] = feature             // 即時轉帳
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_ReservationTransfer] = feature    // 預約轉帳
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_ReservationTransferSearchCancel] = feature     // 預約轉帳查詢取消

        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_TaxPayment, .FeatureID_BillPayment], belong: nil)
        informationList[.FeatureID_Payment] = feature                // 繳款

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_Payment)
        informationList[.FeatureID_TaxPayment] = feature             // 繳稅
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_Payment)
        informationList[.FeatureID_BillPayment] = feature            // 繳費
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_DepositCombinedToDeposit] = feature            // 綜存轉定存

        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_NTRation, .FeatureID_ExchangeRate, .FeatureID_RegularSavingCalculation], belong: nil)
        informationList[.FeatureID_FinancialInformation] = feature    // 理財資訊
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_FinancialInformation)
        informationList[.FeatureID_NTRation] = feature                // 新臺幣利率
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_FinancialInformation)
        informationList[.FeatureID_ExchangeRate] = feature            // 牌告匯率
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_FinancialInformation)
        informationList[.FeatureID_RegularSavingCalculation] = feature // 定期儲蓄試算

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_DepositCombinedToDepositSearch] = feature       // 綜存戶轉存明細查詢/解約
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil)
        informationList[.FeatureID_LoanPrincipalInterest] = feature    // 繳交放款本息

        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_Promotion, .FeatureID_News, .FeatureID_ServiceBase, .FeatureID_PersonalMessage], belong: nil)
        informationList[.FeatureID_CustomerService] = feature    // 客戶服務
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService)
        informationList[.FeatureID_Promotion] = feature                // 農漁會優惠產品
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService)
        informationList[.FeatureID_News] = feature            // 最新消息
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService)
        informationList[.FeatureID_ServiceBase] = feature // 服務據點

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService)
        informationList[.FeatureID_PersonalMessage] = feature // 個人訊息
    }
}
