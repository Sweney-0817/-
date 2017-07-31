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
    private var bankList = [[String:[String]]]()
    private var bankCode = [String:String]()
    
    // MARK: - Life cycle
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
        
        AddObserverToKeyBoard()
        postRequest("Comm/COMM0201", "COMM0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01021","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false, false))
        postRequest("Comm/COMM0402", "COMM0402", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07002","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false, false))
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

    // MARK: - StoryBoard Touch Event
    @IBAction func clickLoginBtn(_ sender: Any) {
        if loginStatusLabel.text == Logout_Success {
            if login == nil {
                login = getUIByID(.UIID_Login) as? LoginView
                login?.frame = view.frame
                login?.setInitialList(bankList, bankCode, "", self)
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
        postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","ICIFKEY":"A123456789","ID":"Systexsoftware","PWD":"systex6214","KINBR":"systex6214","varifyId ":"A123456789","CaptchaCode ":"12345", "LoginMode":1,"TYPE":1,"appId": "FFICMBank", "Version": "1.0","appUid": "123456789","uid": "123456789","model": "123456789","systemVersion": "8.3.1","codeName": "X86_64","tradeMark": "Apple"], true, "a25dq"), AuthorizationManage.manage.getHttpHead(false, true))
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description: String, _ response: NSDictionary) {
        SetLoading(false)
        switch description {
        case "COMM0101":
            if let data = response.object(forKey: "Data") as? [String : Any], let token = data["Token"] as? String {
                AuthorizationManage.manage.SetLoginToken(token)
            }
            loginStatusLabel.text = Login_Success
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
        case "COMM0102":
            AuthorizationManage.manage.SetLoginToken(nil)
            loginStatusLabel.text = Logout_Success
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
            break
        case "COMM0103":
            enterFeatureByID(.FeatureID_FirstLoginChange, true)
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
        case "COMM0402":
            if let data = response.object(forKey: "Data") as? [String : Any], let array = data["Result"] as? [[String:Any]] {
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
            }
        default: break
        }
    }
    
    override func didFailedWithError(_ error: Error) {
        SetLoading(false)
        let alert = UIAlertView(title: nil, message: "Error Message:\(error.localizedDescription)", delegate: nil, cancelButtonTitle:"確認")
        alert.show()
    }
}

