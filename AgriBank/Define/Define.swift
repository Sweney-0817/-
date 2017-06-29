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
    case FeatureID_DemandDepositActDetail   // 活期存款帳戶明細
    case FeatureID_CheckDepositActDetail    // 支票存款帳戶明細
    case FeatureID_TimeDepositActDetail     // 定期存款帳戶明細
    case FeatureID_LoansActDetail           // 放款帳戶明細
    case FeatureID_AccountDetailView        // 帳戶往來明細
    case FeatureID_LoseApply                // 掛失申請
    case FeatureID_PassbookLoseApply        // 存摺掛失
    case FeatureID_DebitCardLoseApply       // 金融卡掛失
    case FeatureID_CheckLoseApply           // 支票掛失
    case FeatureID_Menu                     // 側邊選單
    case FeatureID_Edit                     // 新增/編輯
    case FeatureID_Confirm                  // 確認頁
    case FeatureID_Result                   // 結果頁
    case FeatureID_Transfer                 // 即時轉帳
    
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
        case .FeatureID_Transfer:
            return "FeatureID_Transfer"
	case .FeatureID_PassbookLoseApply:
            return "FeatureID_PassbookLoseApply"
        case .FeatureID_DebitCardLoseApply:
            return "FeatureID_DebitCardLoseApply"
        case .FeatureID_CheckLoseApply:
            return "FeatureID_CheckLoseApply"
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
        case .FeatureID_Transfer:
            return "Transfer"
        case .FeatureID_PassbookLoseApply, .FeatureID_DebitCardLoseApply, .FeatureID_CheckLoseApply:
            return "Lose"
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
        case .FeatureID_DemandDepositActDetail:
            return "活期存款帳戶明細"
        case .FeatureID_CheckDepositActDetail:
            return "支票存款帳戶明細"
        case .FeatureID_TimeDepositActDetail:
            return "定期存款帳戶明細"
        case .FeatureID_LoansActDetail:
            return "放款帳戶明細"
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
            return "首頁功能捷徑新增/編輯"
        case .FeatureID_Transfer:
            return "即時轉帳"
        default:
            return ""
        }
    }
}

enum FeatureType: Int {  // 新增編輯 Cell Type
    case Head_Next_Type
    case Title_Type
    case Select_Type
    case Next_Type
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
    case UIID_ImageConfirmCell        // ImageConfirmCell class in CustomizeCell.swift (圖形驗證碼)
    case UIID_MemoView                // MemoView class
    case UIID_DropDownView            // DropDownView class
    
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
        case .UIID_ImageConfirmCell:
            return "ImageConfirmCell"
        case .UIID_MemoView:
            return "MemoView"
        case .UIID_DropDownView:
            return "DropDownView"
        default:
            return nil
        }
    }
}

// MARK: - ActionSheet Tag
enum ActionSheetTag: Int {
    case Photo              //相片
}

// MARK: - AuthorizationManager
enum AuthorizationType: Int {
    case Fixd_Type          // 固定
    case Default_Type       // 預設
    case User_Type          // 使用者自訂
    case Edit_Type          // 新增/編輯
    case Menu_Type          // 側邊選單
    case FeatureWall_Type   // 廣告牆
}

// MARK: - Connection Utility
let RESPONSE_IMAGE_KEY = "ImageKey"
enum DownloadType: Int {
    case Json
    case Image
}

// MARK: - 圖片名稱
enum ImageName: String {
    case BackBarItem, BackHome, ButtonOBox, Close, CowCheck, CowFailure, CowSuccess, DropDown, DropUp, EntryRight, HintDownArrow, Locker, Login, Orange, Refresh, RightBarItem, Textfield, Unlocker
}

// MARK: - 顏色定義
let Shadow_Radious = CGFloat(20)
let Shadow_Opacity = Float(0.5)
let Shadow_Color = UIColor(red: 219/255, green: 217/255, blue: 217/255, alpha: 1)
let Orange_Color = UIColor(red: 246/255, green: 113/255, blue: 16/255, alpha: 1)
let Gray_Color = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1)
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
