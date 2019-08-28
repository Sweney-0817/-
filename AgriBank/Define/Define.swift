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
    case FeatureID_GetPersonalData                  //
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
    //Guester 20180626
    case FeatureID_MobilePay = 200000               // 農漁行動Pay
    case FeatureID_QRPay = 200100                   // 台灣Pay
    case FeatureID_QRCodeTrans = 200200             // 掃描轉帳
    case FeatureID_AcceptRules = 200101             // 農漁行動Pay服務注意事項
    //Guester 20180626 End
    
    //Guester 20180731
    case FeatureID_GoldPassbook = 210000                // 黃金存摺
    case FeatureID_GPAccountInfomation = 210100         // 帳戶總覽
    case FeatureID_GPSingleBuy = 210200                 // 單筆申購
    case FeatureID_GPSingleSell = 210300                // 單筆回售
    case FeatureID_GPRegularAccountInfomation = 210400  // 定期投資戶總覽
    case FeatureID_GPTransactionDetail = 210500         // 往來明細
    case FeatureID_GPGoldPrice = 210600                 // 牌告價格
    case FeatureID_GPAcceptRules = 210001               // 同意條款
    //Guester 20180731 End
    case FeatureID_CustomerService = 160000         // 客戶服務
    case FeatureID_Promotion = 160100               // 農漁會優惠產品
    case FeatureID_News = 160200                    // 最新消息
    case FeatureID_ServiceBase = 160300             // 農漁會據點
    case FeatureID_PersonalMessage = 160400         // 個人訊息
    case FeatureID_PersopnalSetting = 170000        // 個人設定
    case FeatureID_BasicInfoChange = 170100         // 基本資料變更
    case FeatureID_UserNameChange = 170200          // 使用者代號變更
    case FeatureID_UserPwdChange = 170300           // 使用者密碼變更
    case FeatureID_MessageSwitch = 170400           // 個人設定開關
//    case FeatureID_SetAvatar = 170500               // 登入頭像設定
    case FeatureID_DeviceBinding = 180100           // 設備綁定
    case FeatureID_ContactCustomerService = 190100  // 聯絡客服
    case FeatureID_Edit = 990300                    // 新增/編輯
    
    func StoryBoardID() -> String {
        switch self {
        case .FeatureID_Home:
            return "FeatureID_Home2"
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
    //Guester 20180626
        case .FeatureID_AcceptRules:
            return "FeatureID_AcceptRules"
        case .FeatureID_QRCodeTrans:
            return "FeatureID_QRCodeTrans"
        case .FeatureID_QRPay:
            return "FeatureID_QRPay"
    //Guester 20180626 End

    //Guester 20180731
        case .FeatureID_GPAccountInfomation:
            return "FeatureID_GPAccountInfomation"
        case .FeatureID_GPSingleBuy:
            return "FeatureID_GPSingleBuy"
        case .FeatureID_GPSingleSell:
            return "FeatureID_GPSingleSell"
        case .FeatureID_GPRegularAccountInfomation:
            return "FeatureID_GPRegularAccountInfomation"
        case .FeatureID_GPTransactionDetail:
            return "FeatureID_GPTransactionDetail"
        case .FeatureID_GPGoldPrice:
            return "FeatureID_GPGoldPrice"
        case .FeatureID_GPAcceptRules:
            return "FeatureID_GPAcceptRules"
    //Guester 20180731 End
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
//        case .FeatureID_SetAvatar:
//            return "FeatureID_SetAvatar"
        case .FeatureID_DeviceBinding:
            return "FeatureID_DeviceBinding"
        case .FeatureID_ContactCustomerService:
            return "FeatureID_ContactCustomerService"
        case .FeatureID_GetPersonalData:
            return "FeatureID_GetPersonalData"
        default:
            return ""
        }
    }
    
    func StoryBoardName() -> String {
        switch self {
        case .FeatureID_Home,
             .FeatureID_Menu,
             .FeatureID_Edit,
            .FeatureID_GetPersonalData:
            return "Main"
        case .FeatureID_AccountOverView,
             .FeatureID_AccountDetailView:
            return "Account"
        case .FeatureID_Confirm,
             .FeatureID_Result:
            return "Share"
        case .FeatureID_NTTransfer,
             .FeatureID_ReservationTransfer,
             .FeatureID_ReservationTransferSearchCancel,
             .FeatureID_DepositCombinedToDeposit,
             .FeatureID_DepositCombinedToDepositSearch,
             .FeatureID_LoanPrincipalInterest:
            return "Transfer"
        case .FeatureID_PassbookLoseApply,
             .FeatureID_DebitCardLoseApply,
             .FeatureID_CheckLoseApply:
            return "Lose"
        case .FeatureID_TaxPayment,
             .FeatureID_BillPayment:
            return "Payment"
        case .FeatureID_NTRation,
             .FeatureID_ExchangeRate,
             .FeatureID_RegularSavingCalculation:
            return "FinancialInformation"
        //Guester 20180626
        case .FeatureID_AcceptRules,
             .FeatureID_QRCodeTrans,
             .FeatureID_QRPay:
            return "MobilePay"
        //Guester 20180626 End
        
        //Guester 20180731
        case .FeatureID_GPAccountInfomation,
             .FeatureID_GPSingleBuy,
             .FeatureID_GPSingleSell,
             .FeatureID_GPRegularAccountInfomation,
             .FeatureID_GPTransactionDetail,
             .FeatureID_GPGoldPrice,
             .FeatureID_GPAcceptRules:
            return "GoldPassbook"
        //Guester 20180731 End
        case .FeatureID_Promotion,
             .FeatureID_News,
             .FeatureID_ServiceBase,
             .FeatureID_PersonalMessage,
             .FeatureID_ContactCustomerService:
            return "CustomerService"
        case .FeatureID_BasicInfoChange,
             .FeatureID_UserNameChange,
             .FeatureID_UserPwdChange,
             .FeatureID_MessageSwitch,
//             .FeatureID_SetAvatar,
             .FeatureID_DeviceBinding,
             .FeatureID_FirstLoginChange:
            return "Setting"
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
    var contentList:[PlatformFeatureID]? = nil  // 未經授權判斷的功能代碼表
    var belong:PlatformFeatureID? = nil
    var name = String()
}

struct ConfirmResultStruct {
    var image:String = ""
    var title:String = ""
    var list:[[String:Any]]? = nil
    var memo:String = ""
    var confirmBtnName = ""
    var resultBtnName = ""
    var checkRequest:RequestStruct? = nil
}

struct ConfirmOTPStruct {
    var image:String = ""
    var title:String = ""
    var list:[[String:String]]? = nil
    var memo:String = ""
    var confirmBtnName = ""
    var resultBtnName = ""
    var checkRequest:RequestStruct? = nil
    var httpBodyList:[String:Any]? = nil
    var task:VTask? = nil
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
    case UIID_ServiceBaseCell           // ServiceBaseCell for農漁會據點
    case UIID_DatePickerView          // DatePickerView class
    case UIID_ShowMessageHeadView     // ShowMessageHeadView class
    case UIID_ExchangeRateCell        // ExchangeRateCell class for牌告匯率
    case UIID_ResultEditCell        //QRCode掃描無金額用
    case UIID_GPTransactionDetailCell //黃金存摺往來明細
    case UIID_GPGoldPriceCell       //黃金存摺牌告價格
    case UIID_GPDiffAmountDetailView//黃金定期不定額投資檢視
    
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
        case .UIID_ShowMessageHeadView:
            return "ShowMessageHeadView"
        case .UIID_ExchangeRateCell:
            return "ExchangeRateCell"
        case .UIID_ResultEditCell:
            return "ResultEditCell"
        case .UIID_GPTransactionDetailCell:
            return "GPTransactionDetailCell"
        case .UIID_GPGoldPriceCell:
            return "GPGoldPriceCell"
        case .UIID_GPDiffAmountDetailView:
            return "GPDiffAmountDetailView"
        default:
            return nil
        }
    }
}

// MARK: - All View Tag
enum ViewTag: Int {
    case ActionSheet_Photo = 99             // 頭像設定
    case View_Status                        // 狀態欄
    case View_DatePickerBackground          // 日期Picker Background
    case View_StartDatePickerView           // 起始日期Picker
    case View_EndDatePickerView             // 截止日期Picker
    case View_AccountActionSheet            // 帳號列表ActionSheet
    case View_BankActionSheet               // 銀行列表ActionSheet
    case View_InAccountActionSheet          // 轉入帳號列表ActionSheet
    case View_ExpireSaveActionSheet         // 綜存戶轉定存-自動轉期利率
    case View_DepositTypeActionSheet        // 綜存戶轉定存-存款種類
    case View_RateTypeActionSheet           // 綜存戶轉定存-利率方式
    case View_TransPeriodActionSheet        // 綜存戶轉定存-轉存期別
    case View_LogOut                        // 登出
    case View_AlertActionType               // ReturnCode 電文response: ActionType = backHome
    case View_AlertForceUpdate              // 強制更新
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
let RESPONSE_IMAGE_KEY = "Image"
let RESPONSE_VARIFYID_KEY = "varifyId"
let RESPONSE_IMAGE_CONFIRM_RESULT_KEY = "ImageConfirmResult"
let RESPONSE_Data_KEY = "Data"
let Http_Post_Method = "POST"
let Http_Get_Method = "GET"

enum DownloadType: Int {
    case Json
    case Image
    case ImageConfirm
    case ImageConfirmResult
    case Data
}

struct RequestStruct {
    var strMethod = ""
    var strSessionDescription = ""
    var httpBody:Data? = nil
    var loginHttpHead:[String:String]? = nil
    var strURL:String? = nil
    var needCertificate = false
    var isImage = false
    var timeOut = REQUEST_TIME_OUT
}

// MARK: - 圖片名稱
enum ImageName: String {
    case BackBarItem, BackHome, ButtonLarge, ButtonSmall, ButtonMedium, Close, CowCheck, CowFailure, CowSuccess, DefaultLogo, DropDown, DropUp, EntryRight, HintDownArrow, Login, LoginLogo, Logout, LeftBarItem, Vegetable, Refresh, RightBarItem, RadioOn, RadioOff, Textfield, Checkon, Checkoff
}

// MARK: - 顏色定義
let Shadow_Radious10 = CGFloat(10)
let Shadow_Radious15 = CGFloat(15)
let Shadow_Opacity = Float(0.5)
let Shadow_Color = UIColor(red: 219/255, green: 217/255, blue: 217/255, alpha: 1)
//let Green_Color = UIColor(red: 69/255, green: 166/255, blue: 108/255, alpha: 1)
let Green_Color = UIColor(red: 224/255, green: 105/255, blue: 77/255, alpha: 1)
let Orange_Color = UIColor(red: 224/255, green: 105/255, blue: 77/255, alpha: 1)
let Gray_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
let Cell_Title_Color = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
let Cell_Detail_Color = UIColor.black
let Loading_Background_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 0.3)
let Disable_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 0.6)
let ToolBar_tintColor = UIColor.blue
let ToolBar_barTintColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
let NavigationBar_Color = UIColor(red: 46/255, green: 134/255, blue: 201/255, alpha: 1)

// MARK: - 畫面顯示定義
let Layer_BorderWidth:CGFloat = 1
let Layer_BorderRadius:CGFloat = 5
let ToolBar_Title_Weight:CGFloat = 100
let PickView_Height:CGFloat = 220
let Default_Font = UIFont(name: "PingFangTC-Medium", size: CGFloat(18)) ?? UIFont.systemFont(ofSize: CGFloat(18))
/*  為了因應3.5吋而做的調整 */
let AgriBank_4sInchSize:CGFloat = 480
let AgriBank_4sInchFont =  UIFont(name: "PingFangTC-Medium", size: AgriBank_Scale*CGFloat(15)) ?? UIFont.systemFont(ofSize: AgriBank_Scale*CGFloat(15))
let AgriBank_Scale = UIScreen.main.bounds.width / CGFloat(375)
let Scale_Default_Font = UIFont(name: "PingFangTC-Medium", size: AgriBank_Scale*CGFloat(15)) ?? UIFont.systemFont(ofSize: AgriBank_Scale*CGFloat(15))
// MARK: - 日期格式
let dataDateFormat = "yyyyMMdd"
let showDateFormat = "yyyy/MM/dd"
let emptyDate: String = "00000000"

// MARK: - Define
let SystemCell_Identify = "System_Cell"
let AES_Key = "hs3rwPsoYknnCCWjqIX57RgRflYGhKO1tmQxqWps21k="
let File_IDList_Key = "IDlist"
let File_Account_Key = "Account"
let File_CityCode_Key = "CityCode"
let File_BankCode_Key = "BankCode"
let TransactionID_Description = "TrID"
let TransactionID_Key = "TransactionId"
let LogoImage_Description = "LogoImage"
let BaseTransactionID_Description = "BaseTrID"
let File_FirstOpen_Key = "firstOpen"
let Default_IP_Address = "127.0.0.1"

let Login_Title = "登出"
let NoLogin_Title  = "登入"
let Logout_Title = "確定是否登出"
let Determine_Title = "確定"
let Cancel_Title = "取消"
let Transaction_Successful_Title = "交易成功"
let Transaction_Faild_Title = "交易失敗"
let Change_Successful_Title = "變更成功"
let Change_Faild_Title = "變更失敗"
let Check_Transaction_Title = "請確認本次交易資訊"
let UIAlert_Default_Title = "注意"
let Choose_Title = "請選擇"
let Enter_Title = "請輸入"
let Get_Null_Title = "您無"
let Error_Title = "錯誤訊息"
let Lose_Successful_Title = "掛失成功"
let Lose_Faild_Title = "掛失失敗"
let Currency_TWD_Title = "新臺幣"
let Update_Title = "更新"
let NextChange_Title = "沿用舊密碼"
let PerformChange_Title = "執行變更"
let SetNotification_Title = "您要打開系統應用通知才可收到推播通知"
let Setting_Title = "設定"
let Timeout_Title = "待機時間過長即將登出"
let ProvideUnit_Title = "提供單位"
let PersonalMessageKey = "PersonalMessageData"

let Max_ID_Password_Length:Int = 16 // 使用者代號、使用者密碼的長度限制
let Max_MobliePhone_Length:Int = 10 // 手機號碼
let Max_Identify_Length:Int = 11    // 身分證長度
let Min_Identify_Length:Int = 10    // 身分證長度
let Max19_Memo_Length:Int = 19      // 備註長度
let Max50_Memo_Length:Int = 50      // 備註長度
let Max_Email_Length:Int = 50       // Email長度
let Max_Account_Length:Int = 16     // 輸入轉入帳號長度
let NewInput_MinLength:Int = 8      // 新輸入代號or密碼最小長度
let NewInput_MaxLength:Int = 16     // 新輸入代號or密碼最大長度
let Max_Amount_Length:Int = 12       // 輸入金額最大長度
let Max_GoldGram_Length:Int = 9     // 黃金最大克數
let Max_GetAmount_Length:Int = 7    //我要收款金額最大長度
let Max_GoldSingleBuyGram_Length:Int = 4

let AgriBank_Type = Int(1)
let AgriBank_AppID = "agriBank_iOS"
let AgriBank_TradeMark = "Apple"
let AgriBank_LoginMode = Int(1)
let AgriBank_ForcedLoginMode = Int(2)
let AgriBank_InfoDictionary = Bundle.main.infoDictionary ?? ["CFBundleShortVersionString":""]
let AgriBank_Version:String = (AgriBank_InfoDictionary["CFBundleShortVersionString"] as? String) ?? ""
let AgriBank_SystemVersion = UIDevice.current.systemVersion
let AgriBank_DeviceType = UIDevice.current.model
let AgriBank_Platform = "1"
let AgriBank_DeviceID = UIDevice.current.identifierForVendor!.uuidString
let AgriBank_AppUid = Bundle.main.bundleIdentifier ?? ""
let AgriBank_TimeOut:TimeInterval = 300
let AgriBank_AppURL = "https://itunes.apple.com/tw/app/id1312705740?l=zh&mt=8"

// MARK: - Cell定義
enum CellStatus {
    case Hide
    case Expanding
    case Expand
    case none
}

// MARK: - Account Struct
struct AccountStruct {
    var accountNO = ""
    var currency = ""
    var balance = ""
    var status = ""
}

struct GPActInfo {  //黃金存摺帳戶對應的約定轉帳戶
    ///約定轉帳帳號
    var PAYACT = ""
    ///可用餘額
    var AVBAL = ""
    ///風險評量分數
    var SCORE = ""
    ///風險評量建檔日
    var CREDAY = ""
}
struct GPPriceInfo {//黃金牌告價格
    ///牌告日期
    var DATE = ""
    ///牌告時間
    var TIME = ""
    ///牌次
    var CNT = ""
    ///銀行賣出價
    var SELL = ""
    ///銀行買入價
    var BUY = ""
}

// MARK: - 電文定義
let ImageConfirm_Success = "true"
let ReturnCode_Success = "OK"
let ReturnCode_Key = "ReturnCode"
let ReturnMessage_Key = "ReturnMsg"
let ReturnData_Key = "Data"
let Response_Key = "Key"
let Response_Value = "Value"
let Response_Type = "Type"
let Currency_TWD = "00"             // 幣別代碼 00:台幣
let Account_EnableTrans = "2"       // 此帳號是否有轉出權限 2:可轉帳 除了2 其他不可轉帳
let Can_Transaction_Status = "0"    // 是否可進行交易 0:可交易 1:不可交易
let Account_Saving_Type = "P"       // 帳號類別 活存：P , 支存：K , 定存：T , 放款：L , 綜存：M
let Account_Check_Type = "K"        // 帳號類別 活存：P , 支存：K , 定存：T , 放款：L , 綜存：M
let Account_Deposit_Type = "M"      // 帳號類別 活存：P , 支存：K , 定存：T , 放款：L , 綜存：M
let Account_Loan_Type = "L"         // 帳號類別 活存：P , 支存：K , 定存：T , 放款：L , 綜存：M
let Account_Status_Normal = "1"     // 帳戶狀態  (1.沒過期，2已過期，需要強制變更，3.已過期，不需要強制變更，4.首登，5.此ID已無有效帳戶)
let Account_Status_ForcedChange_Password = "2"
let Account_Status_Change_Password = "3"
let Account_Status_FirstLogin = "4"
let Account_Status_Invaild = "5"

// MARK: - DropDownType
enum DropDownType:Int {
    case First
    case Second
    case Third
}

// MARK: - 錯誤訊息
let ErrorMsg_Image_ConfirmFaild = "圖形驗證碼錯誤"
let ErrorMsg_Image_Empty = "請輸入圖形驗證碼"
let ErrorMsg_Illegal_Character = "不得輸入非法字元"
let ErrorMsg_Invalid_Email = "E-mail格式不合"
let ErrorMsg_Choose_Date = "起始日不可大於截止日"
let ErrorMsg_Error_Identify = "身份證字號格式錯誤"
let ErrorMsg_Format = "格式不符"
let ErrorMsg_IsJailBroken = "此功能無法在JB下使用"
let ErrorMsg_DateMonthOnlyTwo = "查詢區間僅能兩個月"
let ErrorMsg_NoAuth = "本單位目前尚未開放此功能"
let ErrorMsg_IsNot_TransTime = "非營業時間，不受理交易"
let ErrorMsg_Input_Amount = "輸入金額不得0元"
let ErrorMsg_ID_LackOfLength = "身分證字號長度不足"
let ErrorMsg_NoPositioning = "此交易需開啟定位權限"
let ErrorMsg_NoConnection = "請確認網路是否正常。"
let ErrorMsg_GetList_InCommonAccount = "您無常用帳號" // 用於「即時轉帳」「繳費」
/*  用於「即時轉帳」 */
let ErrorMsg_GetList_InAgreedAccount = "您無轉入帳戶"
let ErrorMsg_Choose_InAccount = "請選擇轉入帳號"
let ErrorMsg_Predesignated_Amount = "轉帳金額不得大於200萬"
let ErrorMsg_NotPredesignated_Amount = "轉帳金額不得大於3萬"
/*  用於「預約轉帳」 */
let ErrorMsg_Transfer_Date = "請選擇轉出日期"
let ErrorMsg_Reservation_Amount = "轉帳金額不得大於200萬"
/*  用於「個人基本資料變更」 */
let ErrorMsg_NeedChangeOne = "至少需修改一項"
let ErrorMsg_Telephone = "「新區碼」及「新聯絡電話」必須一起修改"
let ErrorMsg_Address = "「新郵遞區號」及「新聯絡地址」必須一起修改"
/*  用於「登入頁」 */
let ErrorMsg_Choose_CityBank = "請選擇地區"
/*  用於「定期儲蓄試算」 */
let ErrorMsg_Enter_SaveAmount = "請輸入存款金額"
let ErrorMsg_Enter_SaveRate = "請輸入存款年利率"
let ErrorMsg_GreaterThan_MaxRate = "存款年利率不得大於18%"
let ErrorMsg_Choose_SaveDuration = "請選擇存款期限"
/*  用於「定期儲蓄試算」 */
let ErrorMsg_Not_Zero = "不得於0"
/*  用於「繳稅」 */
let ErrorMsg_Choose_PayDate = "請選擇繳費期間"
/*  用於keyPasco */
let ErrorMsg_Verification_Faild = "authenticateOperation faild"
let ErrorMsg_GetTasks_Faild = "getTasksOperation faild"
let ErrorMsg_GenerateOTP_Faild = "generateGeoOTPCode faild"
let ErrorMsg_SignTask_Faild = "signTaskOperation faild"
let ErrorMsg_CancelTask_Faild = "cancelTaskOperation faild"
let ErrorMsg_No_TaskId = "無法取得TaskID"
/* 用於「登入」 */
let ErrorMsg_First_Login = "首次登入請變更代號"
let ErrorMsg_Force_ChangePassword = "請強制變更密碼"
let ErrorMsg_Suggest_ChangePassword = "密碼已到期，建議變更密碼"
let ErrorMsg_InvalidAccount = "帳號已停用，請至臨櫃重新申請"
/* 用於「首頁」 */
let ErrorMsg_AntivirusSoftware_Title = "安裝防毒軟體"
let ErrorMsg_AntivirusSoftware_Content = "請於行動裝置上安裝防毒軟體"
let ErrorMsg_HaveNewVersion = "請更新農業金庫APP"
/* 用於「使用者代號變更」「使用者密碼變更」「首次登入變更」 */
let ErrorMsg_IDNotSame = "新使用者代號與舊使用者代號不得相同"
let ErrorMsg_PDNotSame = "新密碼不得與舊密碼相同"
let ErrorMsg_IDAgainIDNeedSame = "新使用者代號與再次輸入新使用者代號需要相同"
let ErrorMsg_PDAgainPDNeedSame = "新密碼與再次輸入新密碼需要相同"
let ErrorMsg_IDPD_Length = "組成必須為8至16位英數字"
let ErrorMsg_IDPD_Combine = "組成必須為英數夾雜"
let ErrorMsg_IDPD_Continous = "不得有三個以上相同的英數字、連續英文字或連號數字"
let ErrorMsg_IDPD_SameIdentify = "不可與身分證號相同"
/* 用於「綜存轉定存」 */
let ErrorMsg_DepositCombinedToDeposit_MinAmount = "輸入金額不得少於1萬元"
/* 用於「登入頭像設定」 */
let ErrorMsg_NoImage = "您尚未設定頭像"
/* 用於「服務據點」 */
let ErrorMsg_NoTelephone = "此單位尚無提供電話"
let ErrorMsg_NoMapAddress = "此單位尚無提供位址"
/* 黃金存摺 */
let ErrorMsg_NoGPAccount = "您無黃金存摺帳號"
let GPAccountTitle = "黃金存摺帳號"
let ErrorMsg_DateMonthOnlySix = "查詢區間僅能半年"
// MARK: - Shadow Direction:
enum ShadowDirection {
    case All
    case Top
    case Bottom
}
