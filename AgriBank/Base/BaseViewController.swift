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
let URL_DOMAIN = "mbapiqa.naffic.org.tw/APP/api"
//for test
//let URL_DOMAIN = "122.147.4.202/FFICMAPI/api"//Roy測試假電文
#else
let URL_PROTOCOL = "https"
let URL_DOMAIN = "mbapi.naffic.org.tw/APP/api"
#endif

let REQUEST_URL = "\(URL_PROTOCOL)://\(URL_DOMAIN)"
let BarItem_Height_Weight = 40
let Loading_Weight = 100
let Loading_Height = 100

class BaseViewController: UIViewController, LoginDelegate, UIAlertViewDelegate {
    var request:ConnectionUtility? = nil        // 連線元件
    var needShowBackBarItem:Bool = true         // 是否需要顯示返回鍵
    var loadingView:UIView? = nil               // Loading畫面
    var transactionId = ""                      // 交易編號
    var headVarifyID = ""                       // 圖形驗證碼的「交易編號」
    var loginView:LoginView? = nil              // 登入頁面
    var curFeatureID:PlatformFeatureID? = nil   // 即將要登入的功能ID
    var touchTap:UITapGestureRecognizer? = nil  // 手勢: 用來關閉Textfield
    var tempTransactionId = ""                  // 暫存「繳費」「繳稅」的transactionId
    var m_bCanEnterQRP: Bool = false            // 暫存是否可進入QRP
    var m_bCanEnterGP: Bool = false             // 暫存是否可進入黃金存摺
    
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
        
        let imageName = needShowBackBarItem ? ImageName.BackBarItem.rawValue : ImageName.LeftBarItem.rawValue
        let lButton = UIButton(type: .custom)
        lButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
        lButton.addTarget(self, action: #selector(clickBackBarItem), for: .touchUpInside)
        lButton.setImage(UIImage(named: imageName), for: .normal)
        lButton.setImage(UIImage(named: imageName), for: .highlighted)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lButton)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
        super.viewWillDisappear(animated)
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
    func postRequest(_ strMethod:String, _ strSessionDescription:String, _ httpBody:Data?, _ loginHttpHead:[String:String]?, _ strURL:String? = nil, _ needCertificate:Bool = false, _ isImage:Bool = false, _ timeOut:TimeInterval = REQUEST_TIME_OUT)  {
        request = !isImage ? ConnectionUtility(.Json) : ConnectionUtility(.Image)
        request?.requestData(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, loginHttpHead, needCertificate, timeOut)
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
                        getTransactionID(workCode, BaseTransactionID_Description)
                        curFeatureID = ID
                    }
                    //Guester 20180626
                case .FeatureID_QRCodeTrans, .FeatureID_QRPay:
                    canEnter = false
                    if SecurityUtility.utility.isJailBroken() {
                        showErrorMessage(ErrorMsg_IsJailBroken, nil)
                    }
//                    else if AuthorizationManage.manage.canEnterQRP() == false {
                    else if m_bCanEnterQRP == false {
                        getTransactionID("09001", BaseTransactionID_Description)
                        curFeatureID = ID
                    }
                    else {
                        canEnter = true
                        m_bCanEnterQRP = false
                    }
                    //Guester 20180626 End
                    //Guester 20180731
                case .FeatureID_GPSingleBuy, .FeatureID_GPSingleSell:
                    canEnter = false
//                    if AuthorizationManage.manage.canEnterGold() == false {
                    if m_bCanEnterGP == false {
                        getTransactionID("10001", BaseTransactionID_Description)
                        curFeatureID = ID
                    }
                    else {
                        canEnter = true
                        m_bCanEnterGP = false
                    }
                    //Guester 20180731 End
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
    
    func setShadowView(_ view:UIView, _ direction:ShadowDirection = .All) {
        view.layer.shadowRadius = Shadow_Radious15
        view.layer.shadowOpacity = Shadow_Opacity
        view.layer.shadowColor = UIColor.black.cgColor
        if direction == .Bottom {
            view.layer.shadowRadius = Shadow_Radious10
            view.layer.shadowPath = CGPath(rect: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: Shadow_Radious10), transform: nil)
        }
        else if direction == .Top {
            view.layer.shadowRadius = Shadow_Radious10
            view.layer.shadowPath = CGPath(rect: CGRect(x: 0, y: -(Shadow_Radious10/2), width: view.frame.width, height: Shadow_Radious10), transform: nil)
        }
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
    
//                UIApplication.shared.windows.last?.addSubview(loadingView!)
                view.addSubview(loadingView!)
                navigationItem.leftBarButtonItem?.isEnabled = false
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
        else {
            if loadingView != nil {
                loadingView?.removeFromSuperview()
                loadingView = nil
                navigationItem.leftBarButtonItem?.isEnabled = true
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    func showErrorMessage(_ inputTitle:String?, _ message:String?) {
        let title = inputTitle != nil ? inputTitle! : UIAlert_Default_Title
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Determine_Title, style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    func showErrorMessageWithHandler(title : String?,
                                     msg : String?,
                                     confirmTitle : String?,
                                     confirmHandler : @escaping () -> Void) {
        
    }
    func showAlert(title:String?,
                   msg:String?,
                   confirmTitle:String?,
                   cancleTitle:String?,
                   completionHandler: @escaping ()->Void,
                   cancelHandelr: @escaping ()->Void) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: { (action: UIAlertAction!) in
            completionHandler()
        }))
        
        if cancleTitle != nil {
            alert.addAction(UIAlertAction(title: cancleTitle, style: .cancel, handler: { (action: UIAlertAction!) in
                cancelHandelr()
            }))
        }
        
        present(alert, animated: true, completion: nil)
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
    
    func getLocalIPAddressForCurrentWiFi() -> String {
        var address:String = Default_IP_Address
        // get list of all interfaces on the local machine
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else {
            return address
        }
        guard let firstAddr = ifaddr else {
            return address
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - UIBarButtonItem Selector
    func clickShowSideMenu() {
        dismissKeyboard()
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).ShowSideMenu(true)
        }
    }
    
    func clickBackBarItem() {
        if needShowBackBarItem {
            navigationController?.popViewController(animated: true)
        }
        else {
            enterFeatureByID(.FeatureID_Home, true)
        }
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
           getRequest("Comm/COMM0501?varifyId=\(varifyID!)", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirm)
        }
    }
    
    func checkImageConfirm(_ passWord:String, _ varifyID:String? = nil) { // 驗證圖形驗證碼
        if passWord.isEmpty {
            showErrorMessage(nil, ErrorMsg_Image_Empty)
        }
        else {
            setLoading(true)
            let ID = varifyID == nil ? headVarifyID : varifyID!
            getRequest("Comm/COMM0502?varifyId=\(ID)&captchaCode=\(passWord)", "COMM0502", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirmResult)
        }
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
        AuthorizationManage.manage.setLoginStatus(false)
        curFeatureID = nil
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
                loginView?.cleanImageConfirmText()
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
                if let balance = data["TotalBalance"] as? String {
                    info.Balance = balance
                }
                if let STATUS = data["STATUS"] as? String {
                    info.STATUS = STATUS
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
                
                if let status = info.STATUS {
                    // 帳戶狀態  (1.沒過期，2已過期，需要強制變更，3.已過期，不需要強制變更，4.首登，5.此ID已無有效帳戶)
                    switch status {
                    case Account_Status_Normal:
                        AuthorizationManage.manage.setLoginStatus(true)
                        if curFeatureID != nil {
                            enterFeatureByID(curFeatureID!, true)
                            if (curFeatureID != .FeatureID_QRPay && curFeatureID != .FeatureID_QRCodeTrans) {
                                curFeatureID = nil
                            }
                        }
                        
                    case Account_Status_ForcedChange_Password:
                        let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_Force_ChangePassword, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                            DispatchQueue.main.async {
                                /* 此時尚未登入成功，使用enterFeatureByID會失敗 */
                                if let con = self.navigationController?.viewControllers.first {
                                    if con is HomeViewController {
                                        self.navigationController?.popToRootViewController(animated: false)
                                        (con as! HomeViewController).pushFeatureController(.FeatureID_UserPwdChange, true)
                                    }
                                }
                                self.curFeatureID = nil
                            }
                        })
                        present(alert, animated: false, completion: nil)
                        
                    case Account_Status_Change_Password:
                        AuthorizationManage.manage.setLoginStatus(true)
                        let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_Suggest_ChangePassword, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Cancel_Title, style: .default) { _ in
                            DispatchQueue.main.async {
                                if self.curFeatureID != nil {
                                    self.enterFeatureByID(self.curFeatureID!, true)
                                    if (self.curFeatureID != .FeatureID_QRPay && self.curFeatureID != .FeatureID_QRCodeTrans) {
                                        self.curFeatureID = nil
                                    }
                                }
                                else {
                                    if self is HomeViewController {
                                        (self as! HomeViewController).updateLoginStatus(false)
                                    }
                                }
                            }
                        })
                        alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                            DispatchQueue.main.async {
                                self.curFeatureID = nil
                                /* 此時尚未登入成功，使用enterFeatureByID會失敗 */
                                if let con = self.navigationController?.viewControllers.first {
                                    if con is HomeViewController {
                                        self.navigationController?.popToRootViewController(animated: false)
                                        (con as! HomeViewController).pushFeatureController(.FeatureID_UserPwdChange, true)
                                    }
                                }
                            }
                        })
                        present(alert, animated: false, completion: nil)
                        
                    case Account_Status_FirstLogin:
                        let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_First_Login, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                            DispatchQueue.main.async {
                                self.curFeatureID = nil
                                /* 此時尚未登入成功，使用enterFeatureByID會失敗 */
                                if let con = self.navigationController?.viewControllers.first {
                                    if con is HomeViewController {
                                        self.navigationController?.popToRootViewController(animated: false)
                                        (con as! HomeViewController).pushFeatureController(.FeatureID_FirstLoginChange, true)
                                    }
                                }
                            }
                        })
                        present(alert, animated: false, completion: nil)
                        
                    case Account_Status_Invaild:
                        let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_InvalidAccount, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in 
                            DispatchQueue.main.async {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        })
                        present(alert, animated: false, completion: nil)
                        
                    default: curFeatureID = nil
                    }
                }
                registerAPNSToken()
                (UIApplication.shared.delegate as! AppDelegate).notificationAllEvent()
            }
            
        case "COMM0102": break
//            AuthorizationManage.manage.setLoginStatus(false)
//            curFeatureID = nil
            
        case BaseTransactionID_Description:
            if (self.curFeatureID == .FeatureID_GPSingleBuy || self.curFeatureID == .FeatureID_GPSingleSell) {
                if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                    tempTransactionId = tranId
                    self.postRequest("Gold/Gold0101", "Gold0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"getTerms","TransactionId":tempTransactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                tempTransactionId = tranId
                if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                    setLoading(true)
                    VaktenManager.sharedInstance().authenticateOperation(withSessionID: (info.Token ?? "")) { resultCode in
                        if VIsSuccessful(resultCode) {
                            if self.curFeatureID != nil {
                                switch self.curFeatureID {
                                case .FeatureID_TaxPayment?, .FeatureID_BillPayment?:
                                    var workCode = ""
                                    if self.curFeatureID! == .FeatureID_TaxPayment {
                                        workCode = "05001"
                                    }
                                    else if self.curFeatureID! == .FeatureID_BillPayment {
                                        workCode = "05002"
                                    }
                                    self.postRequest("Comm/COMM0802", "BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getLocalIPAddressForCurrentWiFi()], true), AuthorizationManage.manage.getHttpHead(true))
                                case .FeatureID_QRCodeTrans?, .FeatureID_QRPay?:
                                    self.postRequest("Comm/COMM0802", "BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09001","Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getLocalIPAddressForCurrentWiFi()], true), AuthorizationManage.manage.getHttpHead(true))
                                default:
                                    break
                                }
                            }
                        }
                        else {
                            self.showErrorMessage(nil, "\(ErrorMsg_Verification_Faild) \(resultCode.rawValue)")
                            self.setLoading(false)
                        }
                    }
                }
            }
            
        case "BaseCOMM0802":
            if (curFeatureID == .FeatureID_QRCodeTrans || curFeatureID == .FeatureID_QRPay) {
                self.postRequest("QR/QR0101", "QR0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09001","Operate":"getTerms","TransactionId":tempTransactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else if let con = navigationController?.viewControllers.first {
                if con is HomeViewController {
                    (con as! HomeViewController).tempTransactionId = tempTransactionId
                    (con as! HomeViewController).pushFeatureController(curFeatureID!, true)
                }
                curFeatureID = nil
                tempTransactionId = ""
            }
            
//        case "COMM0301":
//            print(response)
        case "QR0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
//                AuthorizationManage.manage.setQRPAcception(data)
//                if (AuthorizationManage.manage.canEnterQRP()) {
                if (data["Read"] == "Y") {
                    m_bCanEnterQRP = true
                    enterFeatureByID(curFeatureID!, true)
                }
                else {
                    let controller = getControllerByID(.FeatureID_AcceptRules)
                    (controller as! AcceptRulesViewController).m_dicData = data
                    (controller as! AcceptRulesViewController).m_nextFeatureID = curFeatureID
                    (controller as! AcceptRulesViewController).transactionId = tempTransactionId
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
            curFeatureID = nil
            tempTransactionId = ""
        case "Gold0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
//                AuthorizationManage.manage.setGoldAcception(data)
//                if (AuthorizationManage.manage.canEnterGold()) {
                if (data["Read"] == "Y") {
                    m_bCanEnterGP = true
                    enterFeatureByID(curFeatureID!, true)
                }
                else {
                    let controller = getControllerByID(.FeatureID_GPAcceptRules)
                    (controller as! GPAcceptRulesViewController).m_dicAcceptData = data
                    (controller as! GPAcceptRulesViewController).m_nextFeatureID = curFeatureID
                    (controller as! GPAcceptRulesViewController).transactionId = tempTransactionId
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
            curFeatureID = nil
            tempTransactionId = ""
        default: break
        }
    }
    
    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        /*  有到「結果頁」的電文都不需判斷ReturnCode  */
        case "TRAN0101","TRAN0102","TRAN0201","TRAN0302","TRAN0401","TRAN0502","TRAN0602",
             "LOSE0101","LOSE0201","LOSE0301","LOSE0302",
             "PAY0103","PAY0105","PAY0107",
             "USIF0102","USIF0201","USIF0301",
             "COMM0102","COMM0801","COMM0103","QR0302":
            didResponse(description, response)
        case "QR0201"://checkQRCode 自行處理回來的結果(因為有錯誤時，關閉alert後要重啟相機)
            didResponse(description, response)
        default:
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    didResponse(description, response)
                }
                else if returnCode == "E_COMM0101_05" {
                    let message = (response.object(forKey: ReturnMessage_Key) as? String) ?? ""
                    let alert = UIAlertController(title: UIAlert_Default_Title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Cancel_Title, style: .default) { _ in
                        DispatchQueue.main.async {
                            self.getImageConfirm()
                        }
                    })
                    alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                        DispatchQueue.main.async {
                            if let info = AuthorizationManage.manage.GetLoginInfo() {
                                let idMd5 = SecurityUtility.utility.MD5(string: info.id)
                                let pdMd5 = SecurityUtility.utility.MD5(string: info.password)
                                self.setLoading(true)
                                self.postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.account,"ID":idMd5,"PWD":pdMd5,"KINBR":info.bankCode,"LoginMode":AgriBank_ForcedLoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true))
                            }
                        }
                    })
                    present(alert, animated: false, completion: nil)
                    return
                }
                else {
                    if let type = response.object(forKey: "ActionType") as? String {
                        switch type {
//                        case "showMsg":
//                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
//                                showErrorMessage(nil, returnMsg)
//                            }
                            
                        case "backHome":
                            if returnCode == "E_HEADER_04" || returnCode == "E_HEADER_05" {
                                postLogout()
                            }
                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                                let alert = UIAlertController(title: UIAlert_Default_Title, message: returnMsg, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                                    DispatchQueue.main.async {
                                        if self.navigationController?.viewControllers.last is HomeViewController {
                                            (self.navigationController?.viewControllers.last as! HomeViewController).updateLoginStatus()
                                        }
                                        else {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }
                                })
                                present(alert, animated: false, completion: nil)
                            }
                            
                        default:
                            if let returnMsg = response.object(forKey: ReturnMessage_Key) as? String {
                                showErrorMessage(nil, returnMsg)
                            }
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
        if (error as NSError).code == -1009 {
            /* 網路*/
            showErrorMessage(nil, ErrorMsg_NoConnection)
        }
        else {
            showErrorMessage(nil, error.localizedDescription)
        }
    }
}
