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
    case FeatureID_Home                             // 首頁
    case FeatureID_Menu                             // 側邊選單
    case FeatureID_Confirm                          // 確認頁
    case FeatureID_Result                           // 結果頁
    case FeatureID_FirstLoginChange                 // 首次登入變更
    case FeatureID_AccountOverView = 100100         // 帳戶總覽
    case FeatureID_AccountDetailView = 110100       // 帳戶往來明細
    case FeatureID_NTAccountTransfer = 120000       // 臺幣帳戶交易
    case FeatureID_NTTransfer = 120100              // 即時轉帳
    case FeatureID_ReservationTransfer = 120200     // 預約轉帳
    case FeatureID_ReservationTransferSearchCancel = 120300 // 預約轉帳查詢取消
    case FeatureID_DepositCombinedToDeposit = 120400        // 綜存戶轉定存
    case FeatureID_DepositCombinedToDepositSearch = 120500  // 綜存戶轉存明細查詢/解約
    case FeatureID_LoanPrincipalInterest = 120600   // 繳交放款本息
    case FeatureID_LoseApply = 130000               // 掛失申請
    case FeatureID_PassbookLoseApply = 130100       // 存摺掛失
    case FeatureID_DebitCardLoseApply = 130200      // 金融卡掛失
    case FeatureID_CheckLoseApply = 130300          // 支票掛失
    case FeatureID_Payment = 140000                 // 繳款
    case FeatureID_TaxPayment = 140100              // 繳稅
    case FeatureID_BillPayment = 140200             // 繳費
    case FeatureID_FinancialInformation = 150000    // 理財資訊
    case FeatureID_NTRation = 150100                // 新臺幣利率
    case FeatureID_ExchangeRate = 150200            // 牌告匯率
    case FeatureID_RegularSavingCalculation = 150300// 定期儲蓄試算
    case FeatureID_CustomerService = 160000         // 客戶服務
    case FeatureID_Promotion = 160100               // 農漁會優惠產品
    case FeatureID_News = 160200                    // 最新消息
    case FeatureID_ServiceBase = 160300             // 服務據點
    case FeatureID_PersonalMessage = 160400         // 個人訊息
    case FeatureID_PersopnalSetting = 170000        // 個人設定
    case FeatureID_BasicInfoChange = 170100         // 基本資料變更
    case FeatureID_UserNameChange = 170200          // 使用者代號變更
    case FeatureID_UserPwdChange = 170300           // 使用者密碼變更
    case FeatureID_MessageSwitch = 170400           // 個人訊息開關
    case FeatureID_SetAvatar = 170500               // 登入頭像設定
    case FeatureID_DeviceBinding = 180100           // 設備綁定
    case FeatureID_Edit = 990300                    // 新增/編輯
    
    
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
    var name = String()
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
    case View_Loading                       // 讀取頁面
    case View_AnnounceNews                  // 訊息跑馬燈
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
let Shadow_Radious = CGFloat(15)
let Shadow_Opacity = Float(0.5)
let Shadow_Color = UIColor(red: 219/255, green: 217/255, blue: 217/255, alpha: 1)
let Green_Color = UIColor(red: 69/255, green: 166/255, blue: 108/255, alpha: 1)
let Gray_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
let Memo_Color = UIColor(red: 130/255, green: 179/255, blue: 66/255, alpha: 1)
let Cell_Title_Color = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
let Cell_Detail_Color = UIColor.black
let Loading_Background_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 0.3)
let Default_Font = UIFont(name: "PingFangTC-Medium", size: CGFloat(18)) ?? UIFont.systemFont(ofSize: CGFloat(18))
let Disable_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 0.6)
let Layer_BorderWidth:CGFloat = 1
let Layer_BorderRadius:CGFloat = 5
let ToolBar_tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
let PickView_Height:CGFloat = 250

// MARK: - 字串定義
let SystemCell_Identify = "System_Cell"
let AES_Key = "hs3rwPsoYknnCCWjqIX57RgRflYGhKO1tmQxqWps21k="
let File_IDList_Key = "IDlist"
let File_NoLogin_IDList_key = "NoLoginIDlist"
let Login_Title = "登出"
let NoLogin_Title  = "登入"
let ToolBar_DoneButton_Title = "確認"
let ToolBar_CancelButton_Title = "取消"
let Response_Key = "key"
let Response_Value = "value"
let Transaction_Successful_Title = "交易成功"
let Transaction_Faild_Title = "交易失敗"
let Change_Successful_Title = "變更成功"
let Change_Faild_Title = "變更失敗"
let TransactionID_Description = "TrID"
let TransactionID_Key = "TransactionId"
let UIActionSheet_Confirm_Title = "確認"
let UIActionSheet_Cancel_Title = "取消"
//let NewsTitle_Login = "地方農漁會公告訊息"
//let NewsTitle_NoLogin = "中心公告訊息"

let AgriBank_Type = Int(1)
let AgriBank_AppID = "FFICMBank"
let AgriBank_TradeMark = "Apple"
let AgriBank_LoginMode = Int(1)
let AgriBank_InfoDictionary = Bundle.main.infoDictionary ?? ["CFBundleShortVersionString":""]
let AgriBank_Version:String = (AgriBank_InfoDictionary["CFBundleShortVersionString"] as? String) ?? ""
let AgriBank_SystemVersion = UIDevice.current.systemVersion
let AgriBank_DeviceType = UIDevice.current.model
let AgriBank_Platform = "1"
let AgriBank_DeviceID = UIDevice.current.identifierForVendor!.uuidString
let AgriBank_AppUid = AgriBank_DeviceID + Bundle.main.bundleIdentifier!
let AgriBank_Auth = "ED57C853AC9744D58B8A9B3F527D0940"

// MARK: - Cell定義
let Separator_Height = CGFloat(1)
let Cell_Font_Size = UIFont.systemFont(ofSize: 18)
enum CellStatus {
    case Hide
    case Expanding
    case Expand
    case none
}
