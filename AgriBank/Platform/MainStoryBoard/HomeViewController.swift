    //
//  ViewController.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class HomeViewController: BasePhotoViewController, FeatureWallViewDelegate, LoginDelegate, AnnounceNewsDelegate {
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var featureWall: FeatureWallView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginImageView: UIImageView!
    private var login:LoginView? = nil
    private var centerNewsList:[[String:Any]]? = nil
    private var bankNewsList:[[String:Any]]? = nil
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = nil
        
        let news = getUIByID(.UIID_AnnounceNews) as! AnnounceNews
        news.frame = newsView.frame
        news.frame.origin = .zero
        news.tag = ViewTag.View_AnnounceNews.rawValue
        newsView.addSubview(news)
        
        let banner = getUIByID(.UIID_Banner) as! BannerView
        banner.frame = bannerView.frame
        banner.frame.origin = .zero
        bannerView.addSubview(banner)
        
        featureWall.setInitial(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!, setVertical: 3, setHorizontal: 2, SetDelegate: self)
        
        AddObserverToKeyBoard()
        GetVersionInfo()
        GetBannerInfo()
        GetAnnounceNewsInfo()
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
        UpdateLoginImageView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        if let statusView = UIApplication.shared.keyWindow?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = false
        }
    }
    
    // MARK: - pubilc 
    override func enterFeatureByID(_ ID:PlatformFeatureID, _ animated:Bool) {
        super.enterFeatureByID(ID, animated)
        if AuthorizationManage.manage.CanEnterFeature(ID) {
            if ID != .FeatureID_Home {
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
        }
        else {
            clickLoginBtn(loginBtn)
        }
    }
    
    // MARK: - Private
    private func UpdateLoginImageView() {
        if AuthorizationManage.manage.IsLoginSuccess() {
            if let loginInfo = AuthorizationManage.manage.GetLoginInfo() {
                loginImageView.image = getPersonalImage(SetAESKey: AES_Key, SetIdentify: loginInfo.id, setAccount: loginInfo.id)
                loginImageView.layer.cornerRadius = loginImageView.frame.width/2
                loginImageView.layer.masksToBounds = true
            }
        }
        else {
            loginImageView.image = UIImage(named: ImageName.Login.rawValue)
            loginImageView.layer.cornerRadius = 0
            loginImageView.layer.masksToBounds = false
        }
    }
    
    // MARK: - Private Post 電文
    private func GetAnnounceNewsInfo() { // 最新消息電文
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
    
    private func GetVersionInfo() {  // 版號控管電文
        postRequest("Comm/COMM0901", "COMM0901", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01001","Operate":"queryData","version":AgriBank_Version,"platform":AgriBank_Platform], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func GetBannerInfo() { // 廣告Banner電文
        postRequest("Comm/COMM0201", "COMM0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01021","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func PostLogout() { // 登出電文
        postRequest("Comm/COMM0102", "COMM0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01012","Operate":"commitTxn"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func GetCanLoginBankInfo() { // 取得農、漁會可登入代碼清單
        postRequest("Comm/COMM0403", "COMM0403", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07003","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func GetBankLogoInfo() { // 取得農、漁會LOGO
        let loginInfo = AuthorizationManage.manage.GetLoginInfo()
        postRequest("Comm/COMM0404", "COMM0404", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07004","Operate":"queryData","hsienCode":loginInfo?.cityCode ?? "","bankCode":loginInfo?.bankCode ?? ""], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func RegisterAPNSToken() { // 註冊推播Token
        if AuthorizationManage.manage.GetAPNSToken() != nil {
            postRequest("Comm/COMM0301", "COMM0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01031","Operate":"commitTxn","appUid":AgriBank_AppUid,"uid":AgriBank_DeviceID,"model":AgriBank_DeviceType,"auth":AgriBank_Auth,"appId":AgriBank_AppID,"version":AgriBank_Version,"token":AuthorizationManage.manage.GetAPNSToken()!,"systemVersion":AgriBank_SystemVersion,"codeName":AgriBank_DeviceType,"tradeMark":AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(false))
        }
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickLoginBtn(_ sender: Any) {
        if loginStatusLabel.text == NoLogin_Title {
            if login == nil {
                login = getUIByID(.UIID_Login) as? LoginView
                login?.frame = view.frame
                GetCanLoginBankInfo()
            }
            view.addSubview(login!)
        }
        else {
            PostLogout()
        }
    }
    
    @IBAction func clickRightBarButton(_ sender: Any) {
        clickShowSideMenu()
    }
    
    // MARK: - FeatureWallViewDelegate
    func clickFeatureBtn(_ ID: PlatformFeatureID) {
        enterFeatureByID(ID, true)
    }
    
    // MARK: - KeyBoard
    override func keyboardWillShow(_ notification:NSNotification) {
        if let need = login?.isNeedRise() {
            if need {
                super.keyboardWillShow(notification)
            }
        }
    }
    
    // MARK: - LoginDelegate
    func clickLoginBtn(_ info:LoginStrcture) {
        AuthorizationManage.manage.SetLoginInfo(info)
        postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.account,"ID":info.id,"PWD":info.password,"KINBR":info.bankCode,"LoginMode":AgriBank_LoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description: String, _ response: NSDictionary) {
        switch description {
        case "COMM0101":
            if let data = response.object(forKey: "Data") as? [String : Any] {
                var info = ResponseLoginInfo()
                if let name = data["CNAME"] as? String {
                    info.CNAME = name
                }
                if let token = data["Token"] as? String {
                    info.Token = token
                }
                if let ID = data["USUDID"] as? String {
                    info.USUDID = ID
                }
                AuthorizationManage.manage.SetResponseLoginInfo(info, nil)
                
                if let balance = data["TotalBalance"] as? Int {
                    accountBalanceLabel.text = String(balance)
                }
                if let status = data["STATUS"] as? String {
                // 帳戶狀態  (1.沒過期，2已過期，需要強制變更，3.已過期，不需要強制變更，4.首登，5.此ID已無有效帳戶)
                    switch status {
                    case "1": break
                    case "2": break
                    case "3": break
                    case "4": enterFeatureByID(.FeatureID_FirstLoginChange, true)
                    case "5": break
                    default: break
                    }
                }
                
                if AuthorizationManage.manage.IsLoginSuccess() {
                    loginStatusLabel.text = Login_Title
                    featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
                    GetBankLogoInfo()
                    GetAnnounceNewsInfo()
                    RegisterAPNSToken()
                }
                UpdateLoginImageView()
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "COMM0102":
            AuthorizationManage.manage.SetResponseLoginInfo(nil, nil)
            loginStatusLabel.text = NoLogin_Title
            accountBalanceLabel.text = ""
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
            UpdateLoginImageView()
            
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
            
        case "COMM0403":
            if let data = response.object(forKey: "Data") as? [String : Any], let array = data["Result"] as? [[String:Any]] {
                var bankList = [[String:[String]]]()
                var bankCode = [String:String]()
                var cityCode = [String:String]()
                for dic in array {
                    var bankNameList = [String]()
                    if let city = dic["hsienName"] as? String, let cityID = dic["hsienCode"] as? String, let list = dic["bankList"] as? [[String:Any]] {
                        for bank in list {
                            if let name = bank["bankName"] as? String {
                                bankNameList.append(name)
                                if let code = bank["bankCode"] as? String {
                                    bankCode["\(city)\(name)"] = code
                                }
                            }
                        }
                        bankList.append( [city:bankNameList] )
                        cityCode[city] = cityID
                    }
                }
                login?.setInitialList(bankList, bankCode, cityCode, "", self)
            }
            else {
                super.didRecvdResponse(description, response)
            }
        
        case "COMM0404":
            if let data = response.object(forKey: "Data") as? [String:Any], let url = data["url"] as? String {
                postRequest("", "LogoImage", nil, nil, url, false, true)
                GetAnnounceNewsInfo()
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "COMM0901":
            if let data = response.object(forKey: "Data") as? [String : Any] {
//                if let forcedChange = data["forcedChange"] as? String { //是否強制換版
//                    
//                }
//                if let isNew = data["isNew"] as? String { // 是否有更新版本
//                    
//                }
//                if let newVersion = data["newVersion"] as? String { //最新版號
//                    
//                }
                print(data)
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
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
//                let title = AuthorizationManage.manage.IsLoginSuccess() ? NewsTitle_Login : NewsTitle_NoLogin
                for dic in list {
                    newsList.append("\(dic["CB_AddedDT"] ?? "")  \(dic["CB_Title"] ?? "")")
                }
                news.setContentList(newsList, self)
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "LogoImage":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                logoImageView.image = responseImage
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        default: break
        }
    }
    
    // MARK: - AnnounceNewsDelegate
    func clickNesw(_ index:Int) {
        enterFeatureByID(.FeatureID_News, true)
    }
}

