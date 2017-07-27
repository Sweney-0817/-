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
        postRequest("COMM0201", "COMM0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01021","Operate":"getList"], false), false)
//        postRequest("COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","ICIFKEY":"A123456789","ID":"Systexsoftware","PWD":"systex6214","KINBR":"systex6214","varifyId ":"A123456789","CaptchaCode ":"12345", "LoginMode":1,"TYPE":1,"appId": "FFICMBank", "Version": "1.0","appUid": "123456789","uid": "123456789","model": "123456789","systemVersion": "8.3.1","codeName": "X86_64","tradeMark": "Apple"], true, "a25dq"), true)
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
        if login == nil {
            login = getUIByID(.UIID_Login) as? LoginView
            login?.frame = view.frame
            login?.setInitialList( ["桃園市":["全國農會1"], "台北市":["全國農會4","全國農會5"], "新北市":["全國農會7","全國農會8","全國農會9"]], "台北市", self )
        }
        view.addSubview(login!)
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
    func clickLoginBtn() {
        featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description: String, _ response: NSDictionary) {
        switch description {
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
        default: break
        }
    }
    
    override func didFailedWithError(_ error: Error) {
        let alert = UIAlertView(title: "連線失敗", message: "Error Message:\(error.localizedDescription)", delegate: nil, cancelButtonTitle:"確認")
        alert.show()
    }
}

