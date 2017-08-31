    //
//  ViewController.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class HomeViewController: BasePhotoViewController, FeatureWallViewDelegate, AnnounceNewsDelegate, UIAlertViewDelegate {
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
        news.tag = ViewTag.View_AnnounceNews.rawValue
        news.delegate = self
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
        featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
        navigationController?.navigationBar.isHidden = true
        if let statusView = UIApplication.shared.keyWindow?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = true
        }
        updateLoginStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        if let statusView = UIApplication.shared.keyWindow?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = false
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
                        centerNews?.append(PromotionStruct(title, date, "", url))
                    }
                }
            }
            if bankNewsList != nil {
                bankNews = [PromotionStruct]()
                for index in bankNewsList! {
                    if let title = index["CB_Title"] as? String, let date = index["CB_AddedDT"] as? String, let url = index["URL"] as? String {
                        bankNews?.append(PromotionStruct(title, date, "", url))
                    }
                }
            }
            (controller as! NewsViewController).SetNewsList(centerNews, bankNews)
            
        default:
            break
        }
        navigationController?.pushViewController(controller, animated: animated)
    }
    
    // MARK: - Private
    private func updateLoginStatus() {
        if AuthorizationManage.manage.IsLoginSuccess() {
            if let info = AuthorizationManage.manage.GetLoginInfo() {
                loginImageView.image = getPersonalImage(SetAESKey: AES_Key, SetIdentify: info.id, setAccount: info.id)
                loginImageView.layer.cornerRadius = loginImageView.frame.width/2
                loginImageView.layer.masksToBounds = true
            }
            if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                accountBalanceLabel.text = "活存總餘額 \(String(info.Balance ?? 0))"
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
        }
        else {
            loginImageView.image = UIImage(named: ImageName.Login.rawValue)
            logoImage = nil
            loginImageView.layer.cornerRadius = 0
            loginImageView.layer.masksToBounds = false
            loginStatusLabel.text = NoLogin_Title
            accountBalanceLabel.text = "-"
        }
    }
    
    // MARK: - Private Post 電文
    private func getAnnounceNewsInfo() { // 最新消息電文
        let loginInfo = AuthorizationManage.manage.GetLoginInfo()
        var body = [String:Any]()
        body = ["WorkCode":"07041","Operate":"getListInfo"]
        if AuthorizationManage.manage.IsLoginSuccess() {
            body["CB_Type"] = Int(1)
            body["CB_CUM_BankCode"] = loginInfo?.bankCode ?? ""
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
    
    private func getBannerInfo() { // 廣告Banner電文
        postRequest("Comm/COMM0201", "COMM0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01021","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func getBankLogoInfo() { // 取得農、漁會LOGO
        let loginInfo = AuthorizationManage.manage.GetLoginInfo()
        postRequest("Comm/COMM0404", "COMM0404", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07004","Operate":"queryData","hsienCode":loginInfo?.cityCode ?? "","bankCode":loginInfo?.bankCode ?? ""], false), AuthorizationManage.manage.getHttpHead(false))
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickLoginBtn(_ sender: Any) {
        if !AuthorizationManage.manage.IsLoginSuccess() {
            showLoginView()
        }
        else {
            let alert = UIAlertView(title: LogOut_Title, message: "", delegate: self, cancelButtonTitle: UIAlert_Cancel_Title, otherButtonTitles: UIAlert_Confirm_Title)
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
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description: String, _ response: NSDictionary) {
        switch description {
        case "COMM0101", "COMM0102":
            super.didRecvdResponse(description, response)
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
            updateLoginStatus()
            
        case "COMM0201":
            var bannerList = [BannerStructure]()
            if let data:[String:Any] = response.object(forKey: "Data") as? [String:Any] {
                if let list:[[String:String]] = data["Result"] as? [[String:String]] {
                    for banner in list {
                        bannerList.append(BannerStructure(imageURL: banner["picUrl"]!, link: banner["lnkUrl"]!))
                    }
                    (bannerView.subviews.first as! BannerView).SetContentList(bannerList)
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
        
        case "COMM0404":
            if let data = response.object(forKey: "Data") as? [String:Any], let url = data["url"] as? String {
                postRequest("", "LogoImage", nil, nil, url, false, true)
                getAnnounceNewsInfo()
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "COMM0901": break
//            if let data = response.object(forKey: "Data") as? [String : Any] {
//                if let forcedChange = data["forcedChange"] as? String { //是否強制換版
//                    
//                }
//                if let isNew = data["isNew"] as? String { // 是否有更新版本
//                    
//                }
//                if let newVersion = data["newVersion"] as? String { //最新版號
//                    
//                }
//            }
//            else {
//                super.didRecvdResponse(description, response)
//            }
            
        case "INFO0201":
            if let data = response.object(forKey: "Data") as? [String : Any], let list = data["CB_List"] as? [[String:Any]], let
                news = newsView.viewWithTag(ViewTag.View_AnnounceNews.rawValue) as? AnnounceNews {
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
                news.setContentList(newsList, self)
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "LogoImage":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                logoImageView.image = responseImage
                logoImage = responseImage
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "COMM0102":
            logoImage = UIImage(named: ImageName.DefaultLogo.rawValue)
            super.didRecvdResponse(description, response)
            
        default: super.didRecvdResponse(description, response)
        }
    }
    
    // MARK: - AnnounceNewsDelegate
    func clickNesw(_ index:Int) {
        enterFeatureByID(.FeatureID_News, true)
    }
    
    // MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            postLogout()
        }
    }
}

