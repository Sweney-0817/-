//
//  Platform.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/5.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//
//108-8-28 Change by Sweney - 密碼沿用修改


import Foundation
import UIKit

class Platform {
    static let plat:Platform = Platform()
    private var informationList = [PlatformFeatureID:FeatureStruct]()
    private var currentFeatureID:PlatformFeatureID? = nil    // 目前的功能
    
    func getControllerByID(_ FeatureID:PlatformFeatureID) -> UIViewController {
        var controller:UIViewController? = nil
        let defaultController = UIViewController()
        
        controller = UIStoryboard(name: FeatureID.StoryBoardName(), bundle: nil).instantiateViewController(withIdentifier: FeatureID.StoryBoardID())
        
        switch FeatureID {
        case .FeatureID_Confirm, .FeatureID_Result: break
        case .FeatureID_UserPwdChange:
            (controller as! UserChangeIDPwdViewController).SetIsChangePod()
            (controller as! BaseViewController).needShowBackBarItem = false
            currentFeatureID = FeatureID
        case .FeatureID_Edit:
            (controller as! BaseViewController).needShowBackBarItem = true
            currentFeatureID = FeatureID
        default:
            (controller as! BaseViewController).needShowBackBarItem = false
            currentFeatureID = FeatureID
        }
        
        return controller ?? defaultController
    }
    
    func getFeatureNameByID(_ ID:PlatformFeatureID) -> String {
        if let content = informationList[ID] {
            return content.name
        }
        else {
            return ""
        }
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
    // $NewWork - 5 (記得在Head_Next_Type裡要增加contentList)
    init() {
        var feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "")
        informationList[.FeatureID_Home] = feature  // 首頁
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "帳戶總覽")
        informationList[.FeatureID_AccountOverView] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "帳戶往來明細")
        informationList[.FeatureID_AccountDetailView] = feature
        //2019-10-14 edit by sweney  新選單時要加在這才會顯示
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_NTTransfer, .FeatureID_ReservationTransfer, .FeatureID_ReservationTransferSearchCancel, .FeatureID_DepositCombinedToDeposit, .FeatureID_DepositCombinedToDepositSearch, .FeatureID_LoanPrincipalInterest,
            .FeatureID_LoanPartialSettIement,
            .FeatureID_TodayBillQry,
            .FeatureID_USAccount,
            .FeatureID_InitTransToNoQry], belong: nil, name: "臺幣帳戶交易")
        informationList[.FeatureID_NTAccountTransfer] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_NTAccountTransfer, name: "即時轉帳")
        informationList[.FeatureID_NTTransfer] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_NTAccountTransfer, name: "預約轉帳")
        informationList[.FeatureID_ReservationTransfer] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_NTAccountTransfer, name: "預約轉帳查詢/取消")
        informationList[.FeatureID_ReservationTransferSearchCancel] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_NTAccountTransfer, name: "綜存轉定存")
        informationList[.FeatureID_DepositCombinedToDeposit] = feature           
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_NTAccountTransfer, name: "綜存戶轉存明細查詢/解約")
        informationList[.FeatureID_DepositCombinedToDepositSearch] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_NTAccountTransfer, name: "繳交放款本息")
        informationList[.FeatureID_LoanPrincipalInterest] = feature
        //2019-12-19 add by sweney 當日待補票據查詢
        feature = FeatureStruct(type: .Select_Type, contentList: nil,belong: .FeatureID_NTAccountTransfer,  name: "當日待補票據查詢")
        informationList[.FeatureID_TodayBillQry] = feature
        
        //2019-10-14 add by sweney 放款部份清償
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_NTAccountTransfer, name: "放款部份清償")
        informationList[.FeatureID_LoanPartialSettIement] = feature
        //2019/10/02-Add by sweney 常用轉入帳號
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong:  .FeatureID_NTAccountTransfer, name: "常用帳號編輯")
         informationList[.FeatureID_USAccount] = feature
        feature = FeatureStruct(type: .Select_Type,contentList: nil,belong: .FeatureID_NTAccountTransfer,name: "約定帳號查詢")
        informationList[.FeatureID_InitTransToNoQry] = feature
        
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_MobileTransferSetup, .FeatureID_MobileNTTransfer], belong: nil, name: "手機門號轉帳")
        informationList[.FeatureID_MobileTransfer] = feature
        
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "手機門號轉帳審閱條款")
        informationList[.FeatureID_MobileTransferSetupAcceptRules] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobileTransfer, name: "設定收款門號")
        informationList[.FeatureID_MobileTransferSetup] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobileTransfer, name: "手機門號轉帳")
        informationList[.FeatureID_MobileNTTransfer] = feature
        
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_CardlessSetup,.FeatureID_CardlessQry,.FeatureID_CardlessDisable], belong: nil, name: "無卡提款")
        informationList[.FeatureID_Cardless] = feature
        
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "無卡提款審閱條款")
        informationList[.FeatureID_CardlessSetupAcceptRules] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_Cardless, name: "預約無卡提款")
        informationList[.FeatureID_CardlessSetup] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_Cardless, name: "查詢預約記錄")
        informationList[.FeatureID_CardlessQry] = feature
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_Cardless, name: "查詢/關閉無卡提款")
        informationList[.FeatureID_CardlessDisable] = feature
         
        
        
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_PassbookLoseApply,.FeatureID_DebitCardLoseApply,.FeatureID_CheckLoseApply], belong: nil, name: "掛失申請")
        informationList[.FeatureID_LoseApply] = feature             
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_LoseApply, name: "存摺掛失")
        informationList[.FeatureID_PassbookLoseApply] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_LoseApply, name: "金融卡掛失")
        informationList[.FeatureID_DebitCardLoseApply] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_LoseApply, name: "支票掛失")
        informationList[.FeatureID_CheckLoseApply] = feature
        
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_TaxPayment, .FeatureID_BillPayment], belong: nil, name: "繳款")
        informationList[.FeatureID_Payment] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_Payment, name: "繳稅")
        informationList[.FeatureID_TaxPayment] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_Payment, name: "繳費")
        informationList[.FeatureID_BillPayment] = feature
        
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_NTRation, .FeatureID_ExchangeRate, .FeatureID_RegularSavingCalculation], belong: nil, name: "理財資訊")
        informationList[.FeatureID_FinancialInformation] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_FinancialInformation, name: "新臺幣利率")
        informationList[.FeatureID_NTRation] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_FinancialInformation, name: "牌告匯率")
        informationList[.FeatureID_ExchangeRate] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_FinancialInformation, name: "定期儲蓄試算")
        informationList[.FeatureID_RegularSavingCalculation] = feature
    //Guester 20180626
//        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_QRPay], belong: nil, name: "行動支付")
//        informationList[.FeatureID_MobilePay] = feature
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_QRPay,.FeatureID_QRPay0,.FeatureID_QRCodeTrans  ,.FeatureID_QRPayDetailView ,.FeatureID_EinvoiceShow,.FeatureID_QRTaipowerDetail], belong: nil, name: "農漁行動Pay")
        informationList[.FeatureID_MobilePay] = feature

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobilePay, name: "掃描轉帳")
        informationList[.FeatureID_QRCodeTrans] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobilePay, name: "出示付款碼")
        informationList[.FeatureID_QRPay0] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobilePay, name: "掃描付款")
        informationList[.FeatureID_QRPay] = feature
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobilePay, name: "交易紀錄/退貨")
        informationList[.FeatureID_QRPayDetailView] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobilePay, name: "發票載具條碼")
        informationList[.FeatureID_EinvoiceShow] = feature
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MobilePay, name: "發票載具條碼")
        informationList[.FeatureID_EinvoiceAdd] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_QRTaipowerDetail, name: "台電交易紀錄")
        informationList[.FeatureID_QRTaipowerDetail] = feature
     

        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "農漁行動Pay服務注意事項")
        informationList[.FeatureID_AcceptRules] = feature
    //Guester 20180626 End
//    feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "振興三倍券綁定")
//    informationList[.FeatureID_Triple] = feature
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "振興五倍券綁定")
        informationList[.FeatureID_Quintuple] = feature
    //Guester 20180731
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_GPAccountInfomation, .FeatureID_GPSingleBuy, .FeatureID_GPSingleSell, .FeatureID_GPRegularAccountInfomation, .FeatureID_GPTransactionDetail, .FeatureID_GPGoldPrice,.FeatureID_GPRiskEvaluation], belong: nil, name: "黃金存摺")
        informationList[.FeatureID_GoldPassbook] = feature

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_GoldPassbook, name: "帳戶總覽")
        informationList[.FeatureID_GPAccountInfomation] = feature

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_GoldPassbook, name: "單筆申購")
        informationList[.FeatureID_GPSingleBuy] = feature

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_GoldPassbook, name: "單筆回售")
        informationList[.FeatureID_GPSingleSell] = feature

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_GoldPassbook, name: "定期投資戶總覽")
        informationList[.FeatureID_GPRegularAccountInfomation] = feature

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_GoldPassbook, name: "往來明細")
        informationList[.FeatureID_GPTransactionDetail] = feature

        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_GoldPassbook, name: "牌告價格")
        informationList[.FeatureID_GPGoldPrice] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_GPRiskEvaluation, name: "投資風險屬性評估")
             informationList[.FeatureID_GPRiskEvaluation] = feature
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "黃金存摺約定條款")
        informationList[.FeatureID_GPAcceptRules] = feature
//Guester 20180731 End
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_Promotion, .FeatureID_News, .FeatureID_ServiceBase, .FeatureID_PersonalMessage], belong: nil, name: "客戶服務")
        informationList[.FeatureID_CustomerService] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService, name: "農漁會優惠產品")
        informationList[.FeatureID_Promotion] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService, name: "最新消息")
        informationList[.FeatureID_News] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService, name: "服務據點")
        informationList[.FeatureID_ServiceBase] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_CustomerService, name: "個人訊息")
        informationList[.FeatureID_PersonalMessage] = feature
        
        
        
        feature = FeatureStruct(type: .Head_Next_Type, contentList: [.FeatureID_BasicInfoChange, .FeatureID_UserNameChange, .FeatureID_UserPwdChange, .FeatureID_MessageSwitch,.FeatureID_FastLogIn,.FeatureID_MOTPSetting,.FeatureID_MOTPEdit/*, .FeatureID_SetAvatar*/], belong: nil, name: "個人設定")
        informationList[.FeatureID_PersopnalSetting] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_PersopnalSetting, name: "基本資料變更")
        informationList[.FeatureID_BasicInfoChange] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_PersopnalSetting, name: "使用者代號變更")
        informationList[.FeatureID_UserNameChange] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_PersopnalSetting, name: "使用者密碼變更")
        informationList[.FeatureID_UserPwdChange] = feature
        
        //108-8-28 Add by Sweney
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_PersopnalSetting, name: "使用者密碼沿用")
        informationList[.FeatureID_UserPwdChangeByPass] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_PersopnalSetting, name: "個人設定開關")
        informationList[.FeatureID_MessageSwitch] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_PersopnalSetting, name: "快速登入設定")
        informationList[.FeatureID_FastLogIn] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MOTPSetting, name: "申請OTP服務")
        informationList[.FeatureID_MOTPSetting] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_MOTPEdit, name: "OTP服務裝置編輯")
            informationList[.FeatureID_MOTPEdit] = feature
        
//        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: .FeatureID_PersopnalSetting, name: "登入頭像設定")
//        informationList[.FeatureID_SetAvatar] = feature
        
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "首次登入基本資料變更")
        informationList[.FeatureID_FirstLoginChange] = feature
        
//        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "設備綁定")
//        informationList[.FeatureID_DeviceBinding] = feature
        //1090729 by chris
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "設備綁定")
        //informationList[.FeatureID_Device2Binding] = feature  //chiu 1091116
        informationList[.FeatureID_OTPDeviceBinding] = feature  //chiu 1091116
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "聯絡客服")
        informationList[.FeatureID_ContactCustomerService] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "引用")
        informationList[.FeatureID_ThirdPartyAnnounce] = feature
        
        feature = FeatureStruct(type: .Select_Type, contentList: nil, belong: nil, name: "新增")
        informationList[.FeatureID_Edit] = feature
        
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "")
        informationList[.FeatureID_Confirm] = feature                // 確認
        
        feature = FeatureStruct(type: .None_Type, contentList: nil, belong: nil, name: "")
        informationList[.FeatureID_Result] = feature                 // 結果
    }
}
