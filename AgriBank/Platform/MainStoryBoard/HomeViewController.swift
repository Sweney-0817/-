    //
//  ViewController.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import LocalAuthentication

class HomeViewController: BasePhotoViewController, FeatureWallViewDelegate, AnnounceNewsDelegate {
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var featureWall: FeatureWallView!
//Guester 20181024 首頁改版
    @IBOutlet var m_vTitleBackground: UIView!
    @IBOutlet var m_btnAlert: UIButton!
    @IBAction func m_btnAlertClick(_ sender: Any) {
        enterFeatureByID(.FeatureID_PersonalMessage, false)
    }
    @IBOutlet var m_ivLocationLogo: UIImageView!
    @IBOutlet var m_lbLocationTitle: UILabel!
    @IBAction func m_btnSideMenuClick(_ sender: Any) {
        clickShowSideMenu()
    }

    @IBAction func m_btnHex1Click(_ sender: Any) {
        enterFeatureByID(.FeatureID_QRPay, false)
    }
    @IBOutlet var m_lbGoldBuyPrice: UILabel!
    @IBOutlet var m_lbGoldSellPrice: UILabel!
    @IBOutlet weak var GoldIn: UILabel!
    @IBAction func m_btnHex2Click(_ sender: Any) {
        
    }
    @IBAction func m_btnHex3Click(_ sender: Any) {
        enterFeatureByID(.FeatureID_QRCodeTrans, false)
    }

    @IBOutlet var m_vBeforeLogin: UIView!
    @IBAction func m_btnLoginClick(_ sender: Any) {
//        showLoginView()
        self.clickLoginBtn(sender)
    }
    @IBOutlet var m_vAfterLogin: UIView!
    @IBOutlet var m_lbBalance: UILabel!
    @IBOutlet var m_lbTBalance: UILabel!
    @IBAction func m_btnActInfoClick(_ sender: Any) {
        self.clickLoginBtn(sender)
    }
    func initNews() {
        let news = getUIByID(.UIID_AnnounceNews) as! AnnounceNews
        news.frame = newsView.frame
        news.frame.origin = .zero
        newsView.addSubview(news)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       

        initNews()
        featureWall.setInitial(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!, setVertical: 3, setHorizontal: 2, SetDelegate: self)
        getVersionInfo()
        //getAnnounceNewsInfo()
        setTitleBackground()
        checkGetPersonalData()
          if (SecurityUtility.utility.isSimulator()) {
            //#if DEBUG  //chiu 20210915
            //#else
            showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_IsSimulator, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: { exit(0) }, cancelHandelr: {()})
            //#endif
        }
        else if (SecurityUtility.utility.isJailBroken()) {
            showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_JailBroken, confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
        }

    }
    func setTitleBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = m_vTitleBackground.frame
        gradient.colors = [UIColor(netHex: 0xf0f36c).cgColor, UIColor(netHex: 0xe3a721).cgColor]
        gradient.locations = [0.0, 1.0]
        
        m_vTitleBackground.backgroundColor = UIColor(patternImage: getImageFrom(gradientLayer: gradient)!)
    }
    func updateLoginStatus(_ getAmount:Bool = true) {
        /* Time out登出，不會viewWillAppear */
        navigationController?.navigationBar.isHidden = true
        if let statusView = UIApplication.shared.windows.first?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = true
        }

        featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
        var list:[[String:Any]]? = nil
        if AuthorizationManage.manage.IsLoginSuccess() {
            if let _ = AuthorizationManage.manage.getResponseLoginInfo() {
                m_vBeforeLogin.isHidden = true
                m_vAfterLogin.isHidden = false
//                if homeTouch != ""{
                                   m_lbBalance.text = "***,***.**"
                                   m_lbTBalance.text = "***,***.**"
                                   homeTouch = "1"
//                               }else{
//                                   m_lbBalance.text = (String(info.Balance ?? "0").separatorThousandDecimal())
//                                   m_lbTBalance.text = (String(info.TBalance ?? "0").separatorThousandDecimal())
//                                   homeTouch = ""
//                               }
//                m_lbBalance.text = (String(info.Balance ?? "0").separatorThousandDecimal())
//                m_lbTBalance.text = (String(info.TBalance ?? "0").separatorThousandDecimal())
            }
            //chiu 公告推播顯示訊息 20201231
            if pushReceiveFlag == "MSG"{
                pushReceiveFlag = ""
    //            let alert = UIAlertView(title: UIAlert_Default_Title, message: "有訊息公告請看最新消息！", delegate: nil, cancelButtonTitle:Determine_Title)
    //            alert.show()
                
                if let aps = pushResultList![AnyHashable("aps")] as? NSDictionary{
                   if let apsalert = aps["alert"] as? NSString{
                   let alert = UIAlertView(title: UIAlert_Default_Title, message: apsalert as String, delegate: self, cancelButtonTitle: Determine_Title)
                   alert.show()
                        }}}
            if centerNewsList == nil {
                getAnnounceNewsInfo()
            }
            if logoImage != nil {
                m_ivLocationLogo.image = logoImage
            }
            else {
                getBankLogoInfo()
            }
            if list != nil {
            list = bankNewsList
            }
            /* 登入成功不需要發送 */
            if getAmount {
                getTransactionID("03001", "Home\(TransactionID_Description)")
            }
        }
        else {
            m_vBeforeLogin.isHidden = false
            m_vAfterLogin.isHidden = true
            logoImage = nil
            m_ivLocationLogo.image = UIImage(named: "logo")
            m_lbLocationTitle.text = "農漁資訊共用"
            list = centerNewsList
        }

        if list != nil {
            var newsList = [String]()
            for dic in list! {
                newsList.append("\(dic["CB_Title"] ?? "")")
            }
            (newsView.subviews.first as! AnnounceNews).setContentList(newsList, self)
        }
        self.send_queryData()
    }
//Guester 20181024 首頁改版 end
    private var centerNewsList:[[String:Any]]? = nil
    private var bankNewsList:[[String:Any]]? = nil
    private var logoImage:UIImage? = nil
    
    // MARK: - Override

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setTitleBackground()
        updateLoginStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        if let statusView = UIApplication.shared.windows.first?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = false
        }
    }

    override func didResponse(_ description: String, _ response: NSDictionary) {
        switch description {
            //2019-11-1 add by sweney for 快速登入 0105
        case "COMM0111", "COMM0102","COMM0105":
            super.didResponse(description, response)
            featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
//            updateLoginStatus(false)
            updateLoginStatus()

        case "COMM0404":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let surl = data["SUrl"] as? String, let name = data["Name"] as? String {
                postRequest("", LogoImage_Description, nil, nil, surl, false, true)
                m_lbLocationTitle.text = name
                BankChineseName = name // 農會名稱save by chris 1090729
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
                if let showLaunchAppMsg = data["showLaunchAppMsg"] as? String, showLaunchAppMsg == "Y", SecurityUtility.utility.readFileByKey(SetKey: File_FirstOpen_Key) == nil { //App啟動時是否顯示金管會要求訊息
                    showErrorMessage(ErrorMsg_AntivirusSoftware_Title, ErrorMsg_AntivirusSoftware_Content)
                    SecurityUtility.utility.writeFileByKey("N", SetKey: File_FirstOpen_Key)
                }
                //2023 checklist update
              if let IsScreenLock = data["IsScreenLock"] as? String, IsScreenLock == "Y" {
                    authenticationWithTouchID()
              }
              send_getKey()
            }
            else {
                super.didResponse(description, response)
            }
        //E2E
        case "INFO0201","INFO0203":
           if let data = response.object(forKey: ReturnData_Key) as? [String : Any], var list = data["CB_List"] as? [[String:Any]]{
                //E2E get public key
                if  let E2EPK = data["E2EPK"]  as? String {
                    E2EKeyData = E2EPK
                }
                if AuthorizationManage.manage.IsLoginSuccess() {
                    if list.count == 0 {
                        list = centerNewsList!
                    }
                    else {
                    bankNewsList?.removeAll()
                    bankNewsList = list
                    }
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
//                logoImageView.image = responseImage
                m_ivLocationLogo.image = responseImage
                logoImage = responseImage
            }
            
        case "Home\(TransactionID_Description)":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                getCurrentAmount(tranId)
                self.transactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }
        case "ACCT0103":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let TotalBalance = data["TotalBalance"] as? String, let TotalTBalance = data["TotalTBalance"] as? String {
//                accountBalanceLabel.text = "活存總餘額 \(TotalBalance.separatorThousand())"
                //chiu  20200610
//               m_lbBalance.text = TotalBalance.separatorThousandDecimal()
//               m_lbTBalance.text = TotalTBalance.separatorThousandDecimal()
               iTotalBal = TotalBalance.separatorThousandDecimal()
               iTotalTBal = TotalTBalance.separatorThousandDecimal()
                self.send_getList()
            }
            else {
                super.didResponse(description, response)
            }
        case "Gold0502":
            if let priceInfo = response.object(forKey: ReturnData_Key) as? [String:String] {
                if let BUY = priceInfo["BUY"], let SELL = priceInfo["SELL"] {
                    m_lbGoldBuyPrice.text = BUY
                    m_lbGoldSellPrice.text = SELL
                }
            }
        case "COMM0303":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let list = data["Result"] as? [[String:Any]]
            {
                if (list.count > 0 )
                {
                    let pushDate: String = (list.first!["pushDate"] as? String)!
                    let msgUid: String = (list.first!["msgUid"] as? String)!
                    
                    if let personalMessageData: [String : String] = UserDefaults.standard.object(forKey: PersonalMessageKey) as? [String:String],
                        let info = AuthorizationManage.manage.getResponseLoginInfo(),
                        let USUDID = info.USUDID,
                        let oldData = personalMessageData[USUDID]
                    {
                        if (pushDate + msgUid == oldData)
                        {//local與最新一則相同
                            m_btnAlert.setImage(UIImage(named: "alert1"), for: UIControl.State.normal)
                        }
                        else
                        {
                            m_btnAlert.setImage(UIImage(named: "alert2"), for: UIControl.State.normal)
                        }
                    }
                    else {
                        m_btnAlert.setImage(UIImage(named: "alert2"), for: UIControl.State.normal)

                    }
                }
            }
       case "GetKey":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let CIDListKey = data["CIDListKey"] as? [[String:Any]], let DATAKey = data["DATAKey"] as? String {
                AuthorizationManage_CIDListKey.removeAll()
                let strPrivateKeyPath = Bundle.main.path(forResource: "private_key", ofType: "p12")
                SEA1 = RSAObjC.decrypt(DATAKey, keyFilePath: strPrivateKeyPath, filecheck: "systex")
                for item in CIDListKey {
                    let Key: String = item["Key"] as! String
                    let Value: String = RSAObjC.decrypt((item["Value"] as! String), keyFilePath: strPrivateKeyPath, filecheck: "systex")
                    AuthorizationManage_CIDListKey[Key] = Value
                }
                getAnnounceNewsInfo()
                updateLoginStatus()
            }
            else {
                showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NoCertificate, confirmTitle: "確認", cancleTitle: nil, completionHandler: {exit(0)}, cancelHandelr: {()})
            }
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Pubilc
    func pushFeatureController(_ ID:PlatformFeatureID, _ animated:Bool) {
        let controller = getControllerByID(ID)
        switch ID {
        case .FeatureID_Edit:
            (controller as! EditViewController).setInitial(true, setShowList: AuthorizationManage.manage.GetPlatformList(.Edit_Type)!, setAddList: AuthorizationManage.manage.GetPlatformList(.User_Type) ?? AuthorizationManage.manage.GetPlatformList(.Default_Type)!)

        case .FeatureID_TaxPayment:
            (controller as! TaxPaymentViewController).transactionId = tempTransactionId
            tempTransactionId = ""
            
        case .FeatureID_BillPayment:
            (controller as! BillPaymentViewController).transactionId = tempTransactionId
            tempTransactionId = ""
            
        case .FeatureID_News:
            (controller as! NewsViewController).m_NewsData1 = centerNewsList
            (controller as! NewsViewController).m_NewsData2 = bankNewsList
            
        case .FeatureID_MobileTransferSetup:
            (controller as! MobileTransferSetupViewController).transactionId = tempTransactionId
            tempTransactionId = ""
            
        case .FeatureID_MobileNTTransfer:
            (controller as! MobileNTTransferViewController).transactionId = tempTransactionId
            tempTransactionId = ""
        case .FeatureID_CardlessSetup:
            (controller as! CardlessSetupViewController).transactionId = tempTransactionId
            tempTransactionId = ""
        case .FeatureID_CardlessQry:
            (controller as! CardlessQryViewController).transactionId = tempTransactionId
            tempTransactionId = ""
        case .FeatureID_CardlessDisable:
            (controller as! CardlessDisableViewController).transactionId = tempTransactionId
            tempTransactionId = ""
         
      
        default: break
        }
        navigationController?.pushViewController(controller, animated: animated)
    }

    /* 為了在「最新消息」中更新的列表，更新回首頁 */
    func setNewsList(_ isCenter:Bool, _ list:[[String:Any]]?) {
        if isCenter {
            centerNewsList = list
        }
        else {
            bankNewsList = list
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
        //change for E2E
        //postRequest("Info/INFO0201", "INFO0201", AuthorizationManage.manage.converInputToHttpBody(body, false), AuthorizationManage.manage.getHttpHead(false))
        postRequest("Info/INFO0203", "INFO0203", AuthorizationManage.manage.converInputToHttpBody(body, false), AuthorizationManage.manage.getHttpHead(false))
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
    
    private func getCurrentAmount(_ tranID:String) { // 取得金額
        postRequest("ACCT/ACCT0103", "ACCT0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03001","Operate":"queryData","TransactionId":tranID], true), AuthorizationManage.manage.getHttpHead(true))
    }

    private func send_queryData() {
        self.setLoading(true)
        postRequest("Gold/Gold0502", "Gold0502", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10013","Operate":"queryData"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    private func send_getList() {//取左上角個人訊息
        setLoading(true)
        postRequest("COMM/COMM0303", "COMM0303", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"getList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
    }
    private func send_getKey() {//取加密用的key
        setLoading(true)
        postRequest("Security/GetKey", "GetKey", nil, AuthorizationManage.manage.getHttpHead(false))
    }
    // MARK: - StoryBoard Touch Event
    @IBAction func clickLoginBtn(_ sender: Any) {
        if !AuthorizationManage.manage.IsLoginSuccess() {
            showLoginView()       
        }
        else {
//            let alert = UIAlertView(title: UIAlert_Default_Title, message: Logout_Title, delegate: self, cancelButtonTitle: Cancel_Title, otherButtonTitles: Determine_Title)
//            alert.tag = ViewTag.View_LogOut.rawValue
//            alert.show()
            if AuthorizationManage.manage.getResponseLoginInfo() != nil {
//                m_vBeforeLogin.isHidden = true
//                m_vAfterLogin.isHidden = false
                if homeTouch == ""{
                    m_lbBalance.text = "***,***.**"
                    m_lbTBalance.text = "***,***.**"
                    homeTouch = "1"
                }else{
                    m_lbBalance.text = iTotalBal
                    m_lbTBalance.text = iTotalTBal
                    homeTouch = ""
                }
                
            }
        }
    }
    
    @IBAction func clickRightBarButton(_ sender: Any) {
        clickShowSideMenu()
    }
    
    func checkGetPersonalData() {
         let confirmed = SecurityUtility.utility.readFileByKey(SetKey: "confirmGetPersonalData") as! Bool?
         if (confirmed == nil || confirmed! != true) {
            showGetPersonalDataView()
        }
    }
    func showGetPersonalDataView() {
        let vc = getControllerByID(.FeatureID_GetPersonalData) as! GetPersonalDataViewController
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
//        performSegue(withIdentifier: "showGetPersonalData", sender: nil)
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
                featureWall.setContentList(AuthorizationManage.manage.GetPlatformList(.FeatureWall_Type)!)
                updateLoginStatus(false)
                m_btnAlert.setImage(UIImage(named: "alert1"), for: UIControl.State.normal)
            }
            
        case ViewTag.View_AlertForceUpdate.rawValue:
            if let title = alertView.buttonTitle(at: buttonIndex), title == Update_Title {
                if let url = URL(string: AgriBank_AppURL), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options:[:], completionHandler:  { (success) in exit(0) })
                    }
                    else {
                        UIApplication.shared.openURL(url)
                        exit(0)
                    }
                }
            }
            else if buttonIndex != alertView.cancelButtonIndex {
                send_getKey()
            }     
        default: super.alertView(alertView, clickedButtonAt: buttonIndex)
        }
    }
    
    //資安檢測修改檢查是否啟用密碼鎖
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        var authError: NSError?
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
        } else {
            guard let error = authError else {
                return
            }
            if error._code == LAError.passcodeNotSet.rawValue {
                showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_passcodeNotSet, confirmTitle: "確認", cancleTitle: nil, completionHandler: {exit(0)}, cancelHandelr: {()})
            }
        }
    }
}

