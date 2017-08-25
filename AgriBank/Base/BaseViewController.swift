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
let URL_DOMAIN = "52.187.113.27/FFICMAPI/api"
#else
let URL_PROTOCOL = "https"
let URL_DOMAIN = ""
#endif
let REQUEST_URL = "\(URL_PROTOCOL)://\(URL_DOMAIN)"
let BarItem_Height_Weight = 30
let NavigationBarColor = UIColor(colorLiteralRed: 46/255, green: 134/255, blue: 201/255, alpha: 1)
let Loading_Weight = 100
let Loading_Height = 100

class BaseViewController: UIViewController, LoginDelegate {
    var request:ConnectionUtility? = nil
    var needShowBackBarItem:Bool = true
    var transactionId = ""                    // 交易編號
    var headVarifyID = ""                     // 圖形驗證碼的「交易編號」
    var loginView:LoginView? = nil            // 登入頁面
    var curFeatureID:PlatformFeatureID? = nil // 目前要登入的功能ID
    
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
        
        navigationController?.navigationBar.barTintColor = NavigationBarColor
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
    }
    
    // MARK: - public
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
    
    func enterFeatureByID(_ ID:PlatformFeatureID, _ animated:Bool) {
        if ID == .FeatureID_Home {
            Platform.plat.popToRootViewController()
            navigationController?.popToRootViewController(animated: animated)
        }
        else {
            if AuthorizationManage.manage.CanEnterFeature(ID) { // 判斷是否需要登入
                switch ID {
                case .FeatureID_TaxPayment, .FeatureID_BillPayment:
                    if !SecurityUtility.utility.isJailBroken() {
                        
                    }
                    else {
                        showErrorMessage("此功能無法在JB下使用", nil)
                    }
                    
                default:
                    if let con = navigationController?.viewControllers.first {
                        if con is HomeViewController {
                            (con as! HomeViewController).pushFeatureController(ID, animated)
                        }
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
    
    func enterConfirmResultController(_ isConfirm:Bool,_ data:ConfirmResultStruct,_ animated:Bool) {
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
    
    func setLoading(_ isLoading:Bool) {
        if isLoading {
            if view.viewWithTag(ViewTag.View_Loading.rawValue) == nil {
                let loadingView = UIView(frame: view.frame)
                loadingView.tag = ViewTag.View_Loading.rawValue
                loadingView.backgroundColor = Loading_Background_Color
                
                let backgroundView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Loading_Weight, height: Loading_Height)))
                backgroundView.backgroundColor = .white
                backgroundView.center = loadingView.center
                loadingView.addSubview(backgroundView)
                
                let loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                loading.startAnimating()
                loading.center = loadingView.center
                loadingView.addSubview(loading)
                
                view.addSubview(loadingView)
            }
        }
        else {
            if let loadingView = view.viewWithTag(ViewTag.View_Loading.rawValue) {
                loadingView.removeFromSuperview()
            }
        }
    }
    
    
    func showErrorMessage(_ title:String?, _ message:String?) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle:UIAlert_Cancel_Title)
        alert.show()
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
    }
    
    // MARK: - UIBarButtonItem Selector
    func clickShowSideMenu() {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).ShowSideMenu(true)
        }
    }
    
    func clickBackBarItem() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - KeyBoard
    func AddObserverToKeyBoard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:NSNotification) {        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        view.frame.origin.y = -keyboardHeight
    }
    
    func keyboardWillHide(_ notification:NSNotification) {
        view.frame.origin.y = 0
    }
}

// MARK: - 登入頁面
extension BaseViewController: ConnectionUtilityDelegate {
    func getTransactionID(_ workCode:String, _ description:String) { // 取得交易編號
        postRequest("Comm/COMM0601", description, AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"getTranID"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    func showLoginView() { // 顯示Login畫面
        if loginView == nil {
            loginView = getUIByID(.UIID_Login) as? LoginView
            loginView?.frame = view.frame
            getCanLoginBankInfo()
            getImageConfirm()
            view.addSubview(loginView!)
        }
        AddObserverToKeyBoard()
    }
    
    func getImageConfirm(_ varifyID:String? = nil) { // 取得圖形驗證碼
        setLoading(true)
        if varifyID == nil {
            getRequest("Comm/COMM0501", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirm)
        }
        else {
            let componenets = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: Date())
            if let day = componenets.day, let month = componenets.month, let minute = componenets.minute, let second = componenets.second, let hour = componenets.hour {
                headVarifyID = "\(month)\(day)\(hour)\(minute)\(second)"
                getRequest("Comm/COMM0501?varifyId=\(headVarifyID)", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirm)
            }
//            getRequest("Comm/COMM0501?varifyId=\(varifyID!)", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirm)
        }
    }
    
    func checkImageConfirm(_ passWord:String, _ varifyID:String? = nil) { // 驗證圖形驗證碼
        setLoading(true)
//        let ID = varifyID == nil ? headVarifyID : varifyID!
        let ID = headVarifyID
        getRequest("Comm/COMM0502?varifyId=\(ID)&captchaCode=\(passWord)", "COMM0502", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .ImageConfirmResult)
    }
    
    func getCanLoginBankInfo() { // 取得農、漁會可登入代碼清單
        setLoading(true)
        postRequest("Comm/COMM0403", "COMM0403", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07003","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    func registerAPNSToken() { // 註冊推播Token
        if AuthorizationManage.manage.GetAPNSToken() != nil {
            postRequest("Comm/COMM0301", "COMM0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01031","Operate":"commitTxn","appUid":AgriBank_AppUid,"uid":AgriBank_DeviceID,"model":AgriBank_DeviceType,"auth":AgriBank_Auth,"appId":AgriBank_AppID,"version":AgriBank_Version,"token":AuthorizationManage.manage.GetAPNSToken()!,"systemVersion":AgriBank_SystemVersion,"codeName":AgriBank_DeviceType,"tradeMark":AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(false))
        }
    }
    
    func postLogout() { // 登出電文
        postRequest("Comm/COMM0102", "COMM0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01012","Operate":"commitTxn"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        var showReturnMsg = false
        setLoading(false)
        switch description {
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                loginView?.SetImageConfirm(responseImage)
            }
            if let ID = response[RESPONSE_VARIFYID_KEY] as? String {
                headVarifyID = ID
            }
            else {
                showReturnMsg = true
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
                loginView?.setInitialList(bankList, bankCode, cityCode, "", self)
            }
            else {
                showReturnMsg = true
            }
            
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                if let info = AuthorizationManage.manage.GetLoginInfo() {
                    let idMd5 = SecurityUtility.utility.MD5(string: info.id)
                    let pdMd5 = SecurityUtility.utility.MD5(string: info.password)
                    postRequest("Comm/COMM0101", "COMM0101",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.account,"ID":idMd5,"PWD":pdMd5,"KINBR":info.bankCode,"LoginMode":AgriBank_LoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                showErrorMessage(ErrorMsg_Image_ConfirmFaild, nil)
            }
            
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
                if let balance = data["TotalBalance"] as? Double {
                    info.Balance = balance
                }
                AuthorizationManage.manage.SetResponseLoginInfo(info, nil)
                registerAPNSToken()
                loginView?.removeFromSuperview()
                loginView = nil
                if curFeatureID != nil {
                    enterFeatureByID(curFeatureID!, true)
                    curFeatureID = nil
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
            else {
                showReturnMsg = true
            }
            
        case "COMM0102":
            AuthorizationManage.manage.SetResponseLoginInfo(nil, nil)
            
        default: showReturnMsg = true
        }
        
        if showReturnMsg {
            if let returnMsg = response.object(forKey: "ReturnMsg") as? String, let returnCode = response.object(forKey: "ReturnCode") as? String  {
                let message = "ReturnMsg:\(returnMsg) ReturnCode:\(returnCode)"
                showErrorMessage(nil, message)
            }
        }
    }
    
    func didFailedWithError(_ error: Error) {
        setLoading(false)
        let alert = UIAlertView(title: nil, message: "Error Message:\(error.localizedDescription)", delegate: nil, cancelButtonTitle:"確認")
        alert.show()
    }
}
