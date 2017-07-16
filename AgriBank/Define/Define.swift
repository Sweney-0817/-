//
//  Define.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/4.
//  Copyright © 2017年 Systex. All rights reserved.
//

import Foundation

// MARK: 功能ID
enum PlatformFeatureID: Int {
    case FeatureID_Home                     // 首頁
    case FeatureID_AccountOverView          // 帳戶總覽
    case FeatureID_AccountDetailView        // 帳戶往來明細
    case FeatureID_NTAccountTransfer        // 臺幣帳戶交易
    case FeatureID_NTTransfer               // 即時轉帳
    case FeatureID_ReservationTransfer      // 預約轉帳
    case FeatureID_ReservationTransferSearchCancel  // 預約轉帳查詢取消
    case FeatureID_DepositCombinedToDeposit // 綜存戶轉定存
    case FeatureID_DepositCombinedToDepositSearch   // 綜存戶轉存明細查詢/解約
    case FeatureID_LoanPrincipalInterest    // 繳交放款本息
    case FeatureID_LoseApply                // 掛失申請
    case FeatureID_PassbookLoseApply        // 存摺掛失
    case FeatureID_DebitCardLoseApply       // 金融卡掛失
    case FeatureID_CheckLoseApply           // 支票掛失
    case FeatureID_Payment                  // 繳款
    case FeatureID_TaxPayment               // 繳稅
    case FeatureID_BillPayment              // 繳費
    case FeatureID_FinancialInformation     // 理財資訊
    case FeatureID_NTRation                 // 新臺幣利率
    case FeatureID_ExchangeRate             // 牌告匯率
    case FeatureID_RegularSavingCalculation // 定期儲蓄試算
    case FeatureID_CustomerService          // 客戶服務
    case FeatureID_Promotion                // 農漁會優惠產品
    case FeatureID_News                     // 最新消息
    case FeatureID_ServiceBase              // 服務據點
    case FeatureID_PersonalMessage          // 個人訊息
    case FeatureID_PersopnalSetting         // 個人設定
    case FeatureID_BasicInfoChange          // 基本資料變更
    case FeatureID_UserNameChange           // 使用者代號變更
    case FeatureID_UserPwdChange            // 使用者密碼變更
    case FeatureID_FirstLoginChange         // 首次登入變更
    case FeatureID_MessageSwitch            // 個人訊息開關
    case FeatureID_SetAvatar                // 登入頭像設定
    case FeatureID_DeviceBinding            // 設備綁定
    case FeatureID_Menu                     // 側邊選單
    case FeatureID_Edit                     // 新增/編輯
    case FeatureID_Confirm                  // 確認頁
    case FeatureID_Result                   // 結果頁
    
    func StoryBoardID() -> String {
        switch self {
        case .FeatureID_Home:
            return "FeatureID_Home"
        case .FeatureID_Menu:
            return "FeatureID_Menu"
        case .FeatureID_Edit:
            return "FeatureID_Edit"
        case .FeatureID_AccountOverView:
            return "FeatureID_AccountOverView"
        case .FeatureID_AccountDetailView:
            return "FeatureID_AccountDetailView"
        case .FeatureID_Confirm:
            return "FeatureID_Confirm"
        case .FeatureID_Result:
            return "FeatureID_Result"
        case .FeatureID_NTTransfer:
            return "FeatureID_NTTransfer"
        case .FeatureID_PassbookLoseApply:
            return "FeatureID_PassbookLoseApply"
        case .FeatureID_DebitCardLoseApply:
            return "FeatureID_DebitCardLoseApply"
        case .FeatureID_CheckLoseApply:
            return "FeatureID_CheckLoseApply"
        case .FeatureID_ReservationTransfer:
            return "FeatureID_ReservationTransfer"
        case .FeatureID_ReservationTransferSearchCancel:
            return "FeatureID_ReservationTransferSearchCancel"
        case .FeatureID_TaxPayment:
            return "FeatureID_TaxPayment"
        case .FeatureID_BillPayment:
            return "FeatureID_BillPayment"
        case .FeatureID_DepositCombinedToDeposit:
            return "FeatureID_DepositCombinedToDeposit"
        case .FeatureID_DepositCombinedToDepositSearch:
            return "FeatureID_DepositCombinedToDepositSearch"
        case .FeatureID_NTRation:
            return "FeatureID_NTRation"
        case .FeatureID_ExchangeRate:
            return "FeatureID_ExchangeRate"
        case .FeatureID_RegularSavingCalculation:
            return "FeatureID_RegularSavingCalculation"
        case .FeatureID_LoanPrincipalInterest:
            return "FeatureID_LoanPrincipalInterest"
        case .FeatureID_Promotion:
            return "FeatureID_Promotion"
        case .FeatureID_News:
            return "FeatureID_News"
        case .FeatureID_ServiceBase:
            return "FeatureID_ServiceBase"
        case .FeatureID_PersonalMessage:
            return "FeatureID_PersonalMessage"
        case .FeatureID_BasicInfoChange:
            return "FeatureID_BasicInfoChange"
        case .FeatureID_UserNameChange, .FeatureID_UserPwdChange:
            return "FeatureID_UserChangeIDPwd"
        case .FeatureID_FirstLoginChange:
            return "FeatureID_FirstLoginChange"
        case .FeatureID_MessageSwitch:
            return "FeatureID_MessageSwitch"
        case .FeatureID_SetAvatar:
            return "FeatureID_SetAvatar"
        case .FeatureID_DeviceBinding:
            return "FeatureID_DeviceBinding"
        default:
            return "";
        }
    }
    
    func StoryBoardName() -> String {
        switch self {
        case .FeatureID_Home, .FeatureID_Menu, .FeatureID_Edit:
            return "Main"
        case .FeatureID_AccountOverView, .FeatureID_AccountDetailView:
            return "Account"
        case .FeatureID_Confirm, .FeatureID_Result:
            return "Share"
        case .FeatureID_NTTransfer, .FeatureID_ReservationTransfer, .FeatureID_ReservationTransferSearchCancel, .FeatureID_DepositCombinedToDeposit, .FeatureID_DepositCombinedToDepositSearch, .FeatureID_LoanPrincipalInterest:
            return "Transfer"
        case .FeatureID_PassbookLoseApply, .FeatureID_DebitCardLoseApply, .FeatureID_CheckLoseApply:
            return "Lose"
        case .FeatureID_TaxPayment, .FeatureID_BillPayment:
            return "Payment"
        case .FeatureID_NTRation, .FeatureID_ExchangeRate, .FeatureID_RegularSavingCalculation:
            return "FinancialInformation"
        case .FeatureID_Promotion, .FeatureID_News, .FeatureID_ServiceBase, .FeatureID_PersonalMessage:
            return "CustomerService"
        case .FeatureID_BasicInfoChange, .FeatureID_UserNameChange, .FeatureID_UserPwdChange, .FeatureID_MessageSwitch, .FeatureID_SetAvatar, .FeatureID_DeviceBinding, .FeatureID_FirstLoginChange:
            return "Setting"
        default:
            return "";
        }
    }
    
    func Name() -> String {
        switch self {
        case .FeatureID_Home:
            return ""
        case .FeatureID_AccountOverView:
            return "帳戶總覽"
        case .FeatureID_AccountDetailView:
            return "帳戶往來明細"
        case .FeatureID_LoseApply:
            return "掛失申請"
        case .FeatureID_PassbookLoseApply:
            return "存摺掛失"
        case .FeatureID_DebitCardLoseApply:
            return "金融卡掛失"
        case .FeatureID_CheckLoseApply:
            return "支票掛失"
        case .FeatureID_Edit:
            return "新增"
        case .FeatureID_NTTransfer:
            return "即時轉帳"
        case .FeatureID_ReservationTransfer:
            return "預約轉帳"
        case .FeatureID_ReservationTransferSearchCancel:
            return "預約轉帳明細查詢/取消"
        case .FeatureID_Payment:
            return "繳款"
        case .FeatureID_TaxPayment:
            return "繳稅"
        case .FeatureID_BillPayment:
            return "繳費"
        case .FeatureID_DepositCombinedToDeposit:
            return "綜存轉定存"
        case .FeatureID_DepositCombinedToDepositSearch:
            return "綜存戶轉存明細查詢/解約"
        case .FeatureID_FinancialInformation:
            return "理財資訊"
        case .FeatureID_NTRation:
            return "新臺幣利率"
        case .FeatureID_ExchangeRate:
            return "牌告匯率"
        case .FeatureID_RegularSavingCalculation:
            return "定期儲蓄試算"
        case .FeatureID_LoanPrincipalInterest:
            return "繳交放款本息"
        case .FeatureID_CustomerService:
            return "客戶服務"
        case .FeatureID_Promotion:
            return "農漁會優惠產品"
        case .FeatureID_News:
            return "最新消息"
        case .FeatureID_ServiceBase:
            return "服務據點"
        case .FeatureID_PersonalMessage:
            return "個人訊息"
        case .FeatureID_PersopnalSetting:
            return "個人設定"
        case .FeatureID_BasicInfoChange:
            return "基本資料變更"
        case .FeatureID_UserNameChange:
            return "使用者代號變更"
        case .FeatureID_UserPwdChange:
            return "使用者密碼變更"
        case .FeatureID_MessageSwitch:
            return "個人訊息開關"
        case .FeatureID_SetAvatar:
            return "登入頭像設定"
        case .FeatureID_DeviceBinding:
            return "設備綁定"
        case .FeatureID_NTAccountTransfer:
            return "臺幣帳戶交易"
        case .FeatureID_FirstLoginChange:
            return "重新設定使用者代號與密碼"
        default:
            return ""
        }
    }
}

enum FeatureType: Int {  // 新增編輯 Cell Type
    case Head_Next_Type
    case Select_Type
    case None_Type
}

struct FeatureStruct {
    var type:FeatureType
    var contentList:[PlatformFeatureID]? = nil
    var belong:PlatformFeatureID? = nil
}

struct ConfirmResultStruct {
    var image:String
    var title:String
    var list:[[String:String]]? = nil
    var memo:String
    var confirmBtnName:String
    var resultBtnName:String
    init(_ image:String, _ title:String, _ list:[[String:String]]?, _ memo:String? = nil, _ confirmBtnName:String? = nil, _ resultBtnName:String? = nil) {
        self.image = image
        self.title = title
        self.list = list
        self.memo = memo ?? ""
        self.confirmBtnName = confirmBtnName ?? ""
        self.resultBtnName = resultBtnName ?? ""
    }
}

// MARK: - UIID
enum UIID: Int {
    case UIID_Banner                  // BannerView class
    case UIID_AnnounceNews            // AnnounceNews class
    case UIID_FeatureWall             // FeatureWallView class <可在介面檔使用>
    case UIID_FeatureWallCell         // FeatureWallCellView class in FeatureWallView.swift(繼承UIView而不是UITablwViewCell)
    case UIID_Introduction            // IntroductionView class <可在介面檔使用>
    case UIID_MenuCell                // MenuCell class in CustomizeCell.swift
    case UIID_MenuExpandCell          // MenuExpandCell class in CustomizeCell.swift
    case UIID_EditCell                // EditCell in CustomizeCell.swift
    case UIID_SideMenu                // SideMenu 架構
    case UIID_Login                   // LoginView class
    case UIID_ChooseType              // ChooseTypeView class <可在介面檔使用>
    case UIID_OverviewCell            // ActOverviewCell class in CustomizeCell.swift
    case UIID_TypeSection             // TypeSection class in TypeSection.swift
    case UIID_ExpandView              // ExpandView class in ExpandView.swift
    case UIID_ResultCell              // ResultCell class in CustomizeCell.swift
    case UIID_ImageConfirmView        // ImageConfirmView class in CustomizeCell.swift (圖形驗證碼)
    case UIID_MemoView                // MemoView class
    case UIID_OneRowDropDownView      // OneRowDropDownView class
    case UIID_TwoRowDropDownView      // TwoRowDropDownView class
    case UIID_ThreeRowDropDownView    // ThreeRowDropDownView class
    case UIID_NTRationCell            // NTRationCell for新臺幣利率
    case UIID_LoanPrincipalInterestCell // LoanPrincipalInterestCell class in CustomizeCell.swift
    case UIID_PromotionCell             // PromotionCell for農漁會優惠產品
    case UIID_NewsCell                  // NewsCell for最新消息、個人訊息
    case UIID_ServiceBaseCell           // ServiceBaseCell for服務據點
    
    func NibName() -> String? {
        switch self {
        case .UIID_Banner:
            return "BannerView"
        case .UIID_AnnounceNews:
            return "AnnounceNews"
        case .UIID_FeatureWallCell:
            return "FeatureWallCellView"
        case .UIID_MenuCell:
            return "MenuCell"
        case .UIID_MenuExpandCell:
            return "MenuExpandCell"
        case .UIID_EditCell:
            return "EditCell"
        case .UIID_Login:
            return "LoginView"
        case .UIID_OverviewCell:
            return "OverviewCell"
        case .UIID_TypeSection:
            return "TypeSection"
        case .UIID_ExpandView:
            return "ExpandView"
        case .UIID_ResultCell:
            return "ResultCell"
        case .UIID_ImageConfirmView:
            return "ImageConfirmView"
        case .UIID_MemoView:
            return "MemoView"
        case .UIID_OneRowDropDownView:
            return "OneRowDropDownView"
        case .UIID_TwoRowDropDownView:
            return "TwoRowDropDownView"
        case .UIID_ThreeRowDropDownView:
            return "ThreeRowDropDownView"
        case .UIID_NTRationCell:
            return "NTRationCell"
        case .UIID_LoanPrincipalInterestCell:
            return "LoanPrincipalInterestCell"
        case .UIID_PromotionCell:
            return "PromotionCell"
        case .UIID_NewsCell:
            return "NewsCell"
        case .UIID_ServiceBaseCell:
            return "ServiceBaseCell"
        default:
            return nil
        }
    }
}

// MARK: - All View Tag
enum ViewTag: Int {
    case ActionSheet_Photo = 99             // 頭像設定
    case View_Status                        // 狀態欄
    case View_DoubleDatePickerBackground    // 起始日picker
}

// MARK: - AuthorizationManager
enum AuthorizationType: Int {
    case Fixd_Type          // 固定
    case Default_Type       // 預設
    case User_Type          // 使用者自訂
    case Edit_Type          // 新增/編輯
    case Menu_Type          // 側邊選單
    case FeatureWall_Type   // 功能牆
}

// MARK: - Connection Utility
let RESPONSE_IMAGE_KEY = "ImageKey"
enum DownloadType: Int {
    case Json
    case Image
}

// MARK: - 圖片名稱
enum ImageName: String {
    case BackBarItem, BackHome, ButtonLarge, ButtonSmall, ButtonMedium, Close, CowCheck, CowFailure, CowSuccess, DropDown, DropUp, EntryRight, HintDownArrow, Locker, Login, Vegetable, Refresh, RightBarItem, RadioOn, RadioOff, Textfield, Unlocker
}

// MARK: - 顏色定義
let Shadow_Radious = CGFloat(20)
let Shadow_Opacity = Float(0.5)
let Shadow_Color = UIColor(red: 219/255, green: 217/255, blue: 217/255, alpha: 1)
let Green_Color = UIColor(red: 69/255, green: 166/255, blue: 108/255, alpha: 1)
let Gray_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
let Memo_Color = UIColor(red: 130/255, green: 179/255, blue: 66/255, alpha: 1)
let Cell_Title_Color = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
let Cell_Detail_Color = UIColor.black
let Default_Font = UIFont.systemFont(ofSize: CGFloat(18))
let Layer_BorderWidth:CGFloat = 1
let Layer_BorderRadius:CGFloat = 5

// MARK: - 字串定義
let SystemCell_Identify = "System_Cell"
let ShowDetail_Segue_Identify = "ShowDetail"
let AES_Key = "Systex"
let File_IDList_Key = "IDlist"

// MARK: - Cell定義
let Separator_Height = CGFloat(1)
let Cell_Font_Size = UIFont.systemFont(ofSize: 18)
enum CellStatus {
    case Hide
    case Expanding
    case Expand
    case none
}
