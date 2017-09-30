    //
//  ViewController.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class HomeViewController: BasePhotoViewController, FeatureWallViewDelegate, AnnounceNewsDelegate {
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var featureWall: FeatureWallView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginImageView: UIImageView!
    private var centerNewsList:[[String:Any]]? = nil
    private var bankNewsList:[[String:Any]]? = nil
    private var logoImage:UIImage? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = nil
        
        let news = getUIByID(.UIID_AnnounceNews) as! AnnounceNews
        news.frame = newsView.frame
        news.frame.origin = .zero
        newsView.addSubview(news)
        
        let banner = getUIByID(.UIID_Banner) as! BannerView
        banner.frame = bannerView.frame
        banner.frame.origin = .zero
        bannerView.addSubview(banner)
        
        featureWall.setInitial(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!, setVertical: 3, setHorizontal: 2, SetDelegate: self)
        
        getVersionInfo()
        getBannerInfo()
        getAnnounceNewsInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLoginStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        if let statusView = UIApplication.shared.keyWindow?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = false
        }
    }

    override func didResponse(_ description: String, _ response: NSDictionary) {
        switch description {
        case "COMM0101", "COMM0102":
            super.didResponse(description, response)
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
            updateLoginStatus()
            
        case "COMM0201":
            var bannerList = [BannerStructure]()
            if let data:[String:Any] = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let list:[[String:String]] = data["Result"] as? [[String:String]] {
                    for banner in list {
                        bannerList.append(BannerStructure(imageURL: banner["picUrl"]!, link: banner["lnkUrl"]!))
                    }
                    (bannerView.subviews.first as! BannerView).setContentList(bannerList)
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0404":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let url = data["url"] as? String {
                postRequest("", LogoImage_Description, nil, nil, url, false, true)
                getAnnounceNewsInfo()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0901":
            if let data = response.object(forKey: ReturnData_Key) as? [String : Any] {
                if let isNew = data["isNew"] as? String, isNew == "Y" { // 是否有更新版本
                    if let newVersion = data["newVersion"] as? String, newVersion != AgriBank_Version {
                        if let forcedChange = data["forcedChange"] as? String { //是否強制換版
                            if forcedChange == "Y" {
                                let alert = UIAlertView(title: UIAlert_Default_Title, message: ErrorMsg_HaveNewVersion, delegate: self, cancelButtonTitle:Update_Title)
                                alert.tag = ViewTag.View_AlertForceUpdate.rawValue
                                alert.show()
                            }
                            else {
                                let alert = UIAlertView(title: UIAlert_Default_Title, message: ErrorMsg_HaveNewVersion, delegate: self, cancelButtonTitle:Cancel_Title, otherButtonTitles:Update_Title)
                                alert.tag = ViewTag.View_AlertForceUpdate.rawValue
                                alert.show()
                            }
                        }
                    }
                }
                if let showLaunchAppMsg = data["showLaunchAppMsg"] as? String, showLaunchAppMsg == "Y" { //App啟動時是否顯示金管會要求訊息
                    showErrorMessage(ErrorMsg_AntivirusSoftware_Title, ErrorMsg_AntivirusSoftware_Content)
                }
            }
            else {
                super.didResponse(description, response)
            }
        
        case "INFO0201":
            if let data = response.object(forKey: ReturnData_Key) as? [String : Any], let list = data["CB_List"] as? [[String:Any]] {
                if AuthorizationManage.manage.IsLoginSuccess() {
                    bankNewsList?.removeAll()
                    bankNewsList = list
                }
                else {
                    centerNewsList?.removeAll()
                    centerNewsList = list
                }
                var newsList = [String]()
                for dic in list {
                    newsList.append("\(dic["CB_Title"] ?? "")")
                }
                (newsView.subviews.first as! AnnounceNews).setContentList(newsList, self)
            }
            else {
                super.didResponse(description, response)
            }
            
        case LogoImage_Description:
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                logoImageView.image = responseImage
                logoImage = responseImage
            }
            
        case "COMM0102":
            logoImage = UIImage(named: ImageName.DefaultLogo.rawValue)
            super.didResponse(description, response)
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Pubilc
    func pushFeatureController(_ ID:PlatformFeatureID, _ animated:Bool) {
        let controller = getControllerByID(ID)
        switch ID {
        case .FeatureID_Edit:
            (controller as! EditViewController).setInitial(true, setShowList: AuthorizationManage.manage.GetPlatformList(.Edit_Type)!, setAddList: AuthorizationManage.manage.GetPlatformList(.User_Type) ?? AuthorizationManage.manage.GetPlatformList(.Default_Type)!)
            
        case .FeatureID_News:
            var centerNews:[PromotionStruct]? = nil
            var bankNews:[PromotionStruct]? = nil
            if centerNewsList != nil {
                centerNews = [PromotionStruct]()
                for index in centerNewsList! {
                    if let title = index["CB_Title"] as? String, let date = index["CB_AddedDT"] as? String, let url = index["URL"] as? String {
                        centerNews?.append(PromotionStruct(title, date, "", url, ""))
                    }
                }
            }
            if bankNewsList != nil {
                bankNews = [PromotionStruct]()
                for index in bankNewsList! {
                    if let title = index["CB_Title"] as? String, let date = index["CB_AddedDT"] as? String, let url = index["URL"] as? String {
                        bankNews?.append(PromotionStruct(title, date, "", url, ""))
                    }
                }
            }
            (controller as! NewsViewController).SetNewsList(centerNews, bankNews)
            
        case .FeatureID_TaxPayment:
            (controller as! TaxPaymentViewController).transactionId = tempTransactionId
            tempTransactionId = ""
            
        case .FeatureID_BillPayment:
            (controller as! BillPaymentViewController).transactionId = tempTransactionId
            tempTransactionId = ""
            
        default: break
        }
        navigationController?.pushViewController(controller, animated: animated)
    }

    func updateLoginStatus() {
        /* Time out登出，不會viewWillAppear */
        navigationController?.navigationBar.isHidden = true
        if let statusView = UIApplication.shared.keyWindow?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = true
        }
        
        featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
        var list:[[String:Any]]? = nil
        if AuthorizationManage.manage.IsLoginSuccess() {
            if let info = AuthorizationManage.manage.GetLoginInfo() {
                loginImageView.image = getPersonalImage(SetAESKey: AES_Key, SetIdentify: info.id, setAccount: info.id)
                loginImageView.layer.cornerRadius = loginImageView.frame.width/2
                loginImageView.layer.masksToBounds = true
            }
            if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                accountBalanceLabel.text = "活存總餘額 \(String(info.Balance ?? 0).separatorThousand())"
            }
            loginStatusLabel.text = Login_Title
            if centerNewsList == nil {
                getAnnounceNewsInfo()
            }
            if logoImage != nil {
                logoImageView.image = logoImage
            }
            else {
                getBankLogoInfo()
            }
            list = bankNewsList
        }
        else {
            loginImageView.image = UIImage(named: ImageName.Login.rawValue)
            logoImage = nil
            logoImageView.image = UIImage(named: ImageName.DefaultLogo.rawValue)
            loginImageView.layer.cornerRadius = 0
            loginImageView.layer.masksToBounds = false
            loginStatusLabel.text = NoLogin_Title
            accountBalanceLabel.text = "-"
            list = centerNewsList
        }
        
        if list != nil {
            var newsList = [String]()
            for dic in list! {
                newsList.append("\(dic["CB_Title"] ?? "")")
            }
            (newsView.subviews.first as! AnnounceNews).setContentList(newsList, self)
        }
    }
    
    // MARK: - Private Post 電文
    private func getAnnounceNewsInfo() { // 最新消息電文
        var body = [String:Any]()
        body = ["WorkCode":"07041","Operate":"getListInfo"]
        if AuthorizationManage.manage.IsLoginSuccess() {
            body["CB_Type"] = Int(1)
            if let loginInfo = AuthorizationManage.manage.GetLoginInfo() {
                body["CB_CUM_BankCode"] = loginInfo.bankCode 
            }
        }
        else {
            body["CB_Type"] = Int(2)
            body["CB_CUM_BankCode"] = ""
        }
        postRequest("Info/INFO0201", "INFO0201", AuthorizationManage.manage.converInputToHttpBody(body, false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func getVersionInfo() {  // 版號控管電文
        postRequest("Comm/COMM0901", "COMM0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01001","Operate":"queryData","version":AgriBank_Version,"platform":AgriBank_Platform], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func getBannerInfo() {   // 廣告Banner電文
        postRequest("Comm/COMM0201", "COMM0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01021","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func getBankLogoInfo() { // 取得農、漁會LOGO
        if let loginInfo = AuthorizationManage.manage.GetLoginInfo() {
            postRequest("Comm/COMM0404", "COMM0404", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07004","Operate":"queryData","hsienCode":loginInfo.cityCode,"bankCode":loginInfo.bankCode], false), AuthorizationManage.manage.getHttpHead(false))
        }
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickLoginBtn(_ sender: Any) {
        if !AuthorizationManage.manage.IsLoginSuccess() {
            showLoginView()
        }
        else {
            let alert = UIAlertView(title: LogOut_Title, message: "", delegate: self, cancelButtonTitle: Cancel_Title, otherButtonTitles: Determine_Title)
            alert.tag = ViewTag.View_LogOut.rawValue
            alert.show()
        }
    }
    
    @IBAction func clickRightBarButton(_ sender: Any) {
        clickShowSideMenu()
    }
    
    // MARK: - FeatureWallViewDelegate
    func clickFeatureBtn(_ ID: PlatformFeatureID) {
        enterFeatureByID(ID, true)
    }
    
    // MARK: - AnnounceNewsDelegate
    func clickNews(_ index:Int) {
        enterFeatureByID(.FeatureID_News, true)
    }
    
    // MARK: - UIAlertViewDelegate
    override func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch alertView.tag {
        case ViewTag.View_LogOut.rawValue:
            if buttonIndex != alertView.cancelButtonIndex {
                postLogout()
            }
            
        case ViewTag.View_AlertForceUpdate.rawValue:
            if let title = alertView.buttonTitle(at: buttonIndex), title == Update_Title {
                
            }
            
        default: super.alertView(alertView, clickedButtonAt: buttonIndex)
        }
    }
}

