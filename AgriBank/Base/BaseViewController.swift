//
//  BaseViewController.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/6.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import Foundation
import UIKit

#if DEBUG
let URL_PROTOCOL = "http"
//let URL_DOMAIN = "52.187.113.27/FFICMAPIFORMAL/api"
//let URL_DOMAIN = "52.187.113.27/FFICMAPI/api"
let URL_DOMAIN = "172.16.132.52/APP/api"
#else
let URL_PROTOCOL = "https"
let URL_DOMAIN = ""
#endif

let REQUEST_URL = "\(URL_PROTOCOL)://\(URL_DOMAIN)"
let BarItem_Height_Weight = 30
let Loading_Weight = 100
let Loading_Height = 100

class BaseViewController: UIViewController, LoginDelegate, UIAlertViewDelegate {
    var request:ConnectionUtility? = nil        // 連線元件
    var needShowBackBarItem:Bool = true         // 是否需要顯示返回鍵
    var loadingView:UIView? = nil               // Loading畫面
    var transactionId = ""                      // 交易編號
    var headVarifyID = ""                       // 圖形驗證碼的「交易編號」
    var loginView:LoginView? = nil              // 登入頁面
    var curFeatureID:PlatformFeatureID? = nil   // 目前要登入的功能ID
    var touchTap:UITapGestureRecognizer? = nil  // 手勢: 用來關閉Textfield
    var tempTransactionId = ""                  // 暫存「繳費」「繳稅」的transactionId
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let rButton = UIButton(type: .custom)
        rButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
        rButton.addTarget(self, action: #selector(clickShowSideMenu), for: .touchUpInside)
        rButton.setImage(UIImage(named: ImageName.RightBarItem.rawValue), for: .normal)
        rButton.setImage(UIImage(named: ImageName.RightBarItem.rawValue), for: .highlighted)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rButton)
        
        if needShowBackBarItem {
            let lButton = UIButton(type: .custom)
            lButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
            lButton.addTarget(self, action: #selector(clickBackBarItem), for: .touchUpInside)
            lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .normal)
            lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .highlighted)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lButton)
        }
        else {
            navigationItem.setHidesBackButton(true, animated:false);
        }
        
        navigationController?.navigationBar.barTintColor = NavigationBar_Color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = getFeatureName(getCurrentFeatureID())
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:Default_Font,NSForegroundColorAttributeName:UIColor.white]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if touchTap != nil {
            view.removeGestureRecognizer(touchTap!)
            touchTap = nil
        }
    }
    
    // MARK: - Public
    func postRequest(_ strMethod:String, _ strSessionDescription:String, _ httpBody:Data?, _ loginHttpHead:[String:String]?, _ strURL:String? = nil, _ needCertificate:Bool = false, _ isImage:Bool = false)  {
        request = !isImage ? ConnectionUtility(.Json) : ConnectionUtility(.Image)
        request?.requestData(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, loginHttpHead, needCertificate)
    }
    
    func getRequest(_ strMethod:String, _ strSessionDescription:String, _ httpBody:Data?, _ loginHttpHead:[String:String]?, _ strURL:String?, _ needCertificate:Bool, _ type:DownloadType)  {
        request = ConnectionUtility(type, false)
        request?.requestData(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, loginHttpHead, needCertificate)
    }
    
    func getControllerByID(_ ID:PlatformFeatureID) -> UIViewController {
        return Platform.plat.getControllerByID(ID)
    }
    
    func getUIByID(_ ID:UIID) -> Any? {
        return Platform.plat.getUIByID(ID, self)
    }
    
    func getFeatureName(_ ID:PlatformFeatureID) -> String {
        return Platform.plat.getFeatureNameByID(ID)
    }
    
    func getFeatureInfoByID(_ ID:PlatformFeatureID) -> FeatureStruct? {
        return Platform.plat.getFeatureInfoByID(ID)
    }
    
    func getCurrentFeatureID() -> PlatformFeatureID {
        return Platform.plat.getCurrentFeatureID()
    }
    
    func getAuthFeatureIDContentList(_ ID:PlatformFeatureID) -> [PlatformFeatureID]? {
        var list:[PlatformFeatureID]? = nil
        if let info = getFeatureInfoByID(ID) {
            if let content = info.contentList {
                if AuthorizationManage.manage.IsLoginSuccess() {
                    list =  AuthorizationManage.manage.getAuthList(content)
                }
                else {
                    list = content
                }
            }
        }
        return list
    }
    
    func enterFeatureByID(_ ID:PlatformFeatureID, _ animated:Bool) {
        if ID == .FeatureID_Home {
            Platform.plat.popToRootViewController()
            navigationController?.popToRootViewController(animated: animated)
        }
        else {
            if AuthorizationManage.manage.CanEnterFeature(ID) { // 判斷是否需要登入
                var canEnter = true
                switch ID {
                case .FeatureID_TaxPayment, .FeatureID_BillPayment:
                    canEnter = false
                    if SecurityUtility.utility.isJailBroken() {
                        showErrorMessage(ErrorMsg_IsJailBroken, nil)
                    }
                    else {
                        var workCode = ""
                        if ID == .FeatureID_TaxPayment {
                            workCode = "05001"
                        }
                        else if ID == .FeatureID_BillPayment {
                            workCode = "05002"
                        }
                        getTransactionID(workCode, TransactionID_Description)
                        curFeatureID = ID
                    }
                    
                default: break
                }
                
                if canEnter, let con = navigationController?.viewControllers.first {
                    if con is HomeViewController {
                        (con as! HomeViewController).pushFeatureController(ID, animated)
                    }
                }
            }
            else {
                curFeatureID = ID
                showLoginView()
            }
        }
    }
    
    func setShadowView(_ view:UIView) {
        view.layer.shadowRadius = Shadow_Radious
        view.layer.shadowOpacity = Shadow_Opacity
        view.layer.shadowColor = UIColor.black.cgColor
    }
    
    func enterConfirmResultController(_ isConfirm:Bool, _ data:ConfirmResultStruct, _ animated:Bool) {
        if isConfirm {
            let controller = getControllerByID(.FeatureID_Confirm)
            (controller as! ConfirmViewController).transactionId = transactionId
            (controller as! ConfirmViewController).setData(data)
            navigationController?.pushViewController(controller, animated: animated)
        }
        else {
            let controller = getControllerByID(.FeatureID_Result)
            (controller as! ResultViewController).transactionId = transactionId
            (controller as! ResultViewController).setData(data)
            navigationController?.pushViewController(controller, animated: animated)
        }
    }
    
    func enterConfirmOTPController(_ data:ConfirmOTPStruct, _ animated:Bool) {
        let controller = getControllerByID(.FeatureID_Confirm)
        (controller as! ConfirmViewController).transactionId = transactionId
        (controller as! ConfirmViewController).setDataNeedOTP(data)
        navigationController?.pushViewController(controller, animated: animated)
    }
    
    func setLoading(_ isLoading:Bool) {
        if isLoading {
            if loadingView == nil {
                loadingView = UIView(frame: view.bounds)
                loadingView?.backgroundColor = Loading_Background_Color
                
                let backgroundView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Loading_Weight, height: Loading_Height)))
                backgroundView.backgroundColor = Gray_Color
                backgroundView.layer.cornerRadius = Layer_BorderRadius
                backgroundView.center = loadingView!.center
                loadingView?.addSubview(backgroundView)
                
                let loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                loading.startAnimating()
                loading.center = loadingView!.center
                loadingView?.addSubview(loading)
    
                UIApplication.shared.windows.last?.addSubview(loadingView!)
            }
        }
        else {
            if loadingView != nil {
                loadingView?.removeFromSuperview()
                loadingView = nil
            }
        }
    }
    
    func showErrorMessage(_ inputTitle:String?, _ message:String?) {
        let title = inputTitle != nil ? inputTitle! : UIAlert_Default_Title
//        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle:Determine_Title)
//        alert.show()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Determine_Title, style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    func showLoginView() { // 顯示Login畫面
        if loginView == nil {
            loginView = getUIByID(.UIID_Login) as? LoginView
            loginView?.frame = view.frame
            loginView?.delegate = self
            getCanLoginBankInfo()
            getImageConfirm()
            view.addSubview(loginView!)
            addObserverToKeyBoard()
            addGestureForKeyBoard()
        }
    }
    
    func getLocalIPAddressForCurrentWiFi() -> String? {
        var address: String?
        // get list of all interfaces on the local machine
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        guard let firstAddr = ifaddr else {
            return nil
        }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            
            let interface = ifptr.pointee
            
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return address
    }

    // MARK: - LoginDelegate
    func clickLoginBtn(_ info:LoginStrcture) {
        AuthorizationManage.manage.SetLoginInfo(info)
        checkImageConfirm(info.imgPassword)
    }
    
    func clickLoginRefreshBtn() {
        getImageConfirm()
    }
    
    func clickLoginCloseBtn() {
        loginView?.removeFromSuperview()
        loginView = nil
        curFeatureID = nil
        if touchTap != nil {
            view.removeGestureRecognizer(touchTap!)
            touchTap = nil
        }
    }
    
    // MARK: - UIBarButtonItem Selector
    func clickShowSideMenu() {
        dismissKeyboard()
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).ShowSideMenu(true)
        }
    }
    
    func clickBackBarItem() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - KeyBoard
    func addObserverToKeyBoard() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:NSNotification) {
        if loginView != nil, !(loginView?.isNeedRise())! {
            view.frame.origin.y = 0
            return
        }
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        view.frame.origin.y = -keyboardHeight
    }
    
    func keyboardWillHide(_ notification:NSNotification) {
        view.frame.origin.y = 0
    }
    
    func addGestureForKeyBoard() {
        if touchTap == nil {
            touchTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(touchTap!)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        switch alertView.tag {
        case ViewTag.View_ForceLogin.rawValue:
            if alertView.cancelButtonIndex != buttonIndex {
                if let info = AuthorizationManage.manage.GetLoginInfo() {
                    let idMd5 = SecurityUtility.utility.MD5(string: info.id)
                    let pdMd5 = SecurityUtility.utility.MD5(string: info.password)
                    setLoading(true)
                    postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.account,"ID":idMd5,"PWD":pdMd5,"KINBR":info.bankCode,"LoginMode":AgriBank_ForcedLoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                clickLoginCloseBtn()
            }
            
        case ViewTag.View_OptionModifyPassword.rawValue:
            if alertView.cancelButtonIndex != buttonIndex {
                AuthorizationManage.manage.setLoginStatus(true)
                if curFeatureID != nil {
                    enterFeatureByID(curFeatureID!, true)
                }
            }
            else {
                AuthorizationManage.manage.setLoginStatus(false)
                enterFeatureByID(.FeatureID_UserPwdChange, true)
                if let con = navigationController?.viewControllers.first {
                    if con is HomeViewController {
                        navigationController?.popToRootViewController(animated: true)
                        (con as! HomeViewController).pushFeatureController(.FeatureID_UserPwdChange, true)
                    }
                }
            }
            curFeatureID = nil
            
        case ViewTag.View_AlertActionType.rawValue:
            navigationController?.popToRootViewController(animated: true)
            
        default: navigationController?.popToRootViewController(animated: true)
        }
        
    }
}

// MARK: - 電文發送 接收
extension BaseViewController: ConnectionUtilityDelegate {
    func getTransactionID(_ workCode:String, _ description:String) { // 取得交易編號
        setLoading(true)
        postRequest("Comm/COMM0601", description, AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"getTranID"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    func getImageConfirm(_ varifyID:String? = nil) { // 取得圖形驗證碼
        setLoading(true)
        if varifyID == nil {
            getRequest("Comm/COMM0501", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirm)
        }
        else {
//            let componenets = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: Date())
//            if let day = componenets.day, let month = componenets.month, let minute = componenets.minute, let second = componenets.second, let hour = componenets.hour {
//                headVarifyID = "\(month)\(day)\(hour)\(minute)\(second)"
//                getRequest("Comm/COMM0501?varifyId=\(headVarifyID)", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirm)
//           }
           getRequest("Comm/COMM0501?varifyId=\(varifyID!)", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirm)
        }
    }
    
    func checkImageConfirm(_ passWord:String, _ varifyID:String? = nil) { // 驗證圖形驗證碼
        setLoading(true)
//        let ID = headVarifyID
        let ID = varifyID == nil ? headVarifyID : varifyID!
        getRequest("Comm/COMM0502?varifyId=\(ID)&captchaCode=\(passWord)", "COMM0502", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirmResult)
    }
    
    func getCanLoginBankInfo() { // 取得農、漁會可登入代碼清單
        setLoading(true)
        postRequest("Comm/COMM0403", "COMM0403", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07003","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    func registerAPNSToken() { // 註冊推播Token
        if AuthorizationManage.manage.GetAPNSToken() != nil {
            postRequest("Comm/COMM0301", "COMM0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01031","Operate":"commitTxn","appUid":AgriBank_AppUid,"uid":AgriBank_DeviceID,"model":AgriBank_DeviceType,"appId":AgriBank_AppID,"version":AgriBank_Version,"token":AuthorizationManage.manage.GetAPNSToken()!,"systemVersion":AgriBank_SystemVersion,"codeName":AgriBank_DeviceType,"tradeMark":AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    func postLogout() { // 登出電文
        postRequest("Comm/COMM0102", "COMM0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01012","Operate":"commitTxn"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                loginView?.setImageConfirm(responseImage)
            }
            if let ID = response[RESPONSE_VARIFYID_KEY] as? String {
                headVarifyID = ID
            }
            
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                if let info = AuthorizationManage.manage.GetLoginInfo() {
                    let idMd5 = SecurityUtility.utility.MD5(string: info.id)
                    let pdMd5 = SecurityUtility.utility.MD5(string: info.password)
                    setLoading(true)
                    postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.account,"ID":idMd5,"PWD":pdMd5,"KINBR":info.bankCode,"LoginMode":AgriBank_LoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                getImageConfirm()
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
            }
            
        case "COMM0403":
            var bankList = [[String:[String]]]()
            var bankCode = [String:String]()
            var cityCode = [String:String]()
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]] {
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
            }
            loginView?.setInitialList(bankList, bankCode, cityCode)
            
        case "COMM0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                var info = ResponseLoginInfo()
                var authList:[[String:String]]? = nil
                if let name = data["CNAME"] as? String {
                    info.CNAME = name
                }
                if let token = data["Token"] as? String {
                    info.Token = token
                }
                if let ID = data["USUDID"] as? String {
                    info.USUDID = ID
                }
                if let balance = data["TotalBalance"] as? Double {
                    info.Balance = balance
                }
                if let Auth = data["Auth"] as? [String: Any], let list = Auth["AuthList"] as? [[String:String]] {
                    authList = list
                }
                AuthorizationManage.manage.setResponseLoginInfo(info, authList)
                
                loginView?.saveDataInFile()
                loginView?.removeFromSuperview()
                loginView = nil
                
                if touchTap != nil {
                    view.removeGestureRecognizer(touchTap!)
                    touchTap = nil
                }
                
                if let status = data["STATUS"] as? String {
                    // 帳戶狀態  (1.沒過期，2已過期，需要強制變更，3.已過期，不需要強制變更，4.首登，5.此ID已無有效帳戶)
                    switch status {
                    case "1":
                        AuthorizationManage.manage.setLoginStatus(true)
                        if curFeatureID != nil {
                            enterFeatureByID(curFeatureID!, true)
                        }
                        curFeatureID = nil
                        
                    case "2":
                        showErrorMessage(nil, ErrorMsg_Force_ChangePassword)
                        if let con = navigationController?.viewControllers.first {
                            if con is HomeViewController {
                                navigationController?.popToRootViewController(animated: true)
                                (con as! HomeViewController).pushFeatureController(.FeatureID_UserPwdChange, true)
                            }
                        }
                        curFeatureID = nil
                        
                    case "3":
                        let alert = UIAlertView(title: UIAlert_Default_Title, message: ErrorMsg_Suggest_ChangePassword, delegate: self, cancelButtonTitle: "下次變更", otherButtonTitles: "執行變更")
                        alert.tag = ViewTag.View_OptionModifyPassword.rawValue
                        alert.show()
                        
                    case "4":
                        showErrorMessage(nil, ErrorMsg_First_Login)
                        if let con = navigationController?.viewControllers.first {
                            if con is HomeViewController {
                                navigationController?.popToRootViewController(animated: true)
                                (con as! HomeViewController).pushFeatureController(.FeatureID_FirstLoginChange, true)
                            }
                        }
                        curFeatureID = nil
                        
//                    case "5": curFeatureID = nil
                        
                    default: curFeatureID = nil
                    }
                }
//                registerAPNSToken()
                (UIApplication.shared.delegate as! AppDelegate).notificationAllEvent()
            }
            
        case "COMM0102":
            AuthorizationManage.manage.setLoginStatus(false)
            
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                tempTransactionId = tranId
                let info = AuthorizationManage.manage.getResponseLoginInfo()
//                VaktenManager.sharedInstance().authenticateOperation(withSessionID: tranId) { resultCode in
                VaktenManager.sharedInstance().authenticateOperation(withSessionID: (info?.Token)!) { resultCode in
                    if VIsSuccessful(resultCode) {
                        var workCode = ""
                        if self.curFeatureID! == .FeatureID_TaxPayment {
                            workCode = "05001"
                        }
                        else if self.curFeatureID! == .FeatureID_BillPayment {
                            workCode = "05002"
                        }
                        self.setLoading(true)
                        self.postRequest("Comm/COMM0802", "COMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getLocalIPAddressForCurrentWiFi() ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                    }
                    else {
                        self.showErrorMessage(nil, ErrorMsg_Verification_Faild)
                    }
                }
            }
            
        case "COMM0802":
            if let con = navigationController?.viewControllers.first {
                if con is HomeViewController {
                    (con as! HomeViewController).tempTransactionId = tempTransactionId
                    (con as! HomeViewController).pushFeatureController(curFeatureID!, true)
                }
            }
            curFeatureID = nil
            tempTransactionId = ""
            
        case "COMM0301":
            print(response)
            
        default: break
        }
    }
    
    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        /*  有到「結果頁」的電文都不需判斷ReturnCode  */
        case "TRAN0101","TRAN0103","TRAN0201","TRAN0302","TRAN0401","TRAN0502","TRAN0602",
             "LOSE0101","LOSE0201","LOSE0301","LOSE0302",
             "PAY0103","PAY0105","PAY0107",
             "USIF0102","USIF0201","USIF0301",
             "COMM0102":
            didResponse(description, response)
            
        default:
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    didResponse(description, response)
                }
                else if returnCode == "E_COMM0101_05" {
                    let message = (response.object(forKey: ReturnMessage_Key) as? String) ?? ""
//                    let alert = UIAlertView(title: UIAlert_Default_Title, message: message, delegate: self, cancelButtonTitle: Cancel_Title, otherButtonTitles: Determine_Title)
//                    alert.tag = ViewTag.View_ForceLogin.rawValue
//                    alert.show()
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Cancel_Title, style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                        if let info = AuthorizationManage.manage.GetLoginInfo() {
                            let idMd5 = SecurityUtility.utility.MD5(string: info.id)
                            let pdMd5 = SecurityUtility.utility.MD5(string: info.password)
                            self.setLoading(true)
                            self.postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.account,"ID":idMd5,"PWD":pdMd5,"KINBR":info.bankCode,"LoginMode":AgriBank_ForcedLoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true))
                        }
                    })
                    present(alert, animated: false, completion: nil)
                    return
                }
                else {
                    if let type = response.object(forKey: "ActionType") as? String {
                        switch type {
                        case "showMsg":
                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                                showErrorMessage(nil, returnMsg)
                            }
                            
                        case "backHome":
                            if returnCode == "E_HEADER_04" || returnCode == "E_HEADER_05" {
                                AuthorizationManage.manage.setLoginStatus(false)
                            }
                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                                let alert = UIAlertView(title: UIAlert_Default_Title, message: returnMsg, delegate: self, cancelButtonTitle: Determine_Title)
                                alert.tag = ViewTag.View_AlertActionType.rawValue
                                alert.show()
                            }
                       
                        default: break
                        }
                    }
                    /*  登入失敗，需要重取圖形驗證碼 */
                    if description == "COMM0101" {
                        getImageConfirm()
                    }
                }
            }
            else {
                showErrorMessage(nil, String(describing: response))
            }
        }
    }
    
    func didFailedWithError(_ error: Error) {
        setLoading(false)
        showErrorMessage(nil, error.localizedDescription)
    }
}
