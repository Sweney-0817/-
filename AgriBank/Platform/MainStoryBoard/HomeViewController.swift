    //
//  ViewController.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController, FeatureWallViewDelegate, LoginDelegate {
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var featureWall: FeatureWallView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginImageView: UIImageView!
    private var login:LoginView? = nil
    private var loginInf:LoginStrcture? = nil
    
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
        postRequest("Comm/COMM0201", "COMM0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01021","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false, false))
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
        
        GetAnnounceNewsInfo()
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
    private func GetAnnounceNewsInfo() {
        var body = [String:Any]()
        body = ["WorkCode":"07041","Operate":"getListInfo"]
        if AuthorizationManage.manage.IsLoginSuccess() {
            body["CB_Type"] = Int(1)
            body["CB_CUM_BankCode"] = loginInf?.bankCode ?? ""
        }
        else {
            body["CB_Type"] = Int(2)
            body["CB_CUM_BankCode"] = " "
        }
        postRequest("Info/INFO0201", "INFO0201", AuthorizationManage.manage.converInputToHttpBody(body, false), AuthorizationManage.manage.getHttpHead(false, false))
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickLoginBtn(_ sender: Any) {
        if loginStatusLabel.text == NoLogin_Title {
            if login == nil {
                login = getUIByID(.UIID_Login) as? LoginView
                login?.frame = view.frame
                postRequest("Comm/COMM0403", "COMM0403", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07003","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false, false))
            }
            view.addSubview(login!)
        }
        else {
            postRequest("Comm/COMM0102", "COMM0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01012","Operate":"commitTxn"], false), AuthorizationManage.manage.getHttpHead(true, false))
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
        loginInf = info
        postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn", "TransactionNo":"2017071700000001","ICIFKEY":info.account,"ID":info.id,"PWD":info.password,"KINBR":info.bankCode,"LoginMode":AgriBank_LoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID, "Version": AgriBank_Version,"appUid": "123456789","uid": "123456789","model": "123456789","systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark], true, "a25dq"), AuthorizationManage.manage.getHttpHead(false, true))
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description: String, _ response: NSDictionary) {
        switch description {
        case "COMM0101":
            if let data = response.object(forKey: "Data") as? [String : Any] {
                var info = UserInfo()
                if let name = data["CNAME"] as? String {
                    info.CNAME = name
                }
                if let token = data["Token"] as? String {
                    info.Token = token
                }
                if let ID = data["USUDID"] as? String {
                    info.USUDID = ID
                }
                if let bankCode = loginInf?.bankCode {
                    info.BankCode = bankCode
                }
                AuthorizationManage.manage.SetUserInfo(info, nil)
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
            }
            loginStatusLabel.text = AuthorizationManage.manage.IsLoginSuccess() ? Login_Title : NoLogin_Title
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
            
        case "COMM0102":
            AuthorizationManage.manage.SetUserInfo(nil, nil)
            loginStatusLabel.text = NoLogin_Title
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
            
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
            
        case "COMM0403":
            if let data = response.object(forKey: "Data") as? [String : Any], let array = data["Result"] as? [[String:Any]] {
                var bankList = [[String:[String]]]()
                var bankCode = [String:String]()
                for dic in array {
                    var bankNameList = [String]()
                    if let city = dic["hsienName"] as? String, let list = dic["bankList"] as? [[String:Any]] {
                        for bank in list {
                            if let name = bank["bankName"] as? String {
                                bankNameList.append(name)
                                if let code = bank["bankCode"] as? String {
                                    bankCode["\(city)\(name)"] = code
                                }
                            }
                        }
                        bankList.append( [city:bankNameList] )
                    }
                }
                login?.setInitialList(bankList, bankCode, "", self)
            }
            
        case "INFO0201":
            if let data = response.object(forKey: "Data") as? [String : Any], let list = data["CB_List"] as? [[String:Any]], let news = newsView.viewWithTag(ViewTag.View_AnnounceNews.rawValue) as? AnnounceNews {
                var newsList = [String]()
                let title = AuthorizationManage.manage.IsLoginSuccess() ? NewsTitle_Login : NewsTitle_NoLogin
                for dic in list {
                    newsList.append("\(title)  \(dic["CB_AddedDT"] ?? "")  \(dic["CB_Title"] ?? "")")
                }
                news.setContentList(newsList)
            }
        default: break
        }
    }
}

