//
//  BaseViewController.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/6.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//
//新增功能時請先收尋$NewWork 采蓉

import Foundation
import UIKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork


#if DEBUG
let URL_PROTOCOL = "http"
let URL_DOMAIN = "mbapiqa.naffic.org.tw/APP/api"
//let URL_DOMAIN = "192.168.65.2/APP_WEBAPI/api"
//for test
//let URL_DOMAIN = "122.147.4.202/FFICMAPI/api"//Roy測試假電文
//let URL_PROTOCOL = "https"
//let URL_DOMAIN = "mbapi.afisc.com.tw/APP/api"
#else
let URL_PROTOCOL = "https"
let URL_DOMAIN = "mbapi.afisc.com.tw/APP/api"
//let URL_DOMAIN = "mbapi.naffic.org.tw/APP/api"
#endif

let REQUEST_URL = "\(URL_PROTOCOL)://\(URL_DOMAIN)"
let BarItem_Height_Weight = 40
let Loading_Weight = 100
let Loading_Height = 100
//2019-11-6 add by sweney for fastlogin bank
var tempBankCode = ""              //暫存快登單位
var E2Eobject : E2E? = nil

@objcMembers
class BaseViewController: UIViewController, LoginDelegate, GesturePwdDelegate, UIAlertViewDelegate {
    var request:ConnectionUtility? = nil        // 連線元件
    var needShowBackBarItem:Bool = true         // 是否需要顯示返回鍵
    var loadingView:UIView? = nil               // Loading畫面
    var transactionId = ""                      // 交易編號
    var headVarifyID = ""                       // 圖形驗證碼的「交易編號」
    var loginView:LoginView? = nil              // 登入頁面
    var curFeatureID:PlatformFeatureID? = nil   // 即將要登入的功能ID
    var touchTap:UITapGestureRecognizer? = nil  // 手勢: 用來關閉Textfield
    var tempTransactionId = ""                  // 暫存「繳費」「繳稅」的transactionId
    var m_bCanEnterMTS: Bool = false            // 暫存是否可進入註冊手機帳號
    var m_bCanEnterCardless: Bool = false       // 暫存是否可進入無卡提款預約
    var m_bCanENterCardlessQry: Bool = false    // 暫存是否可進入無卡提款
    var m_bCanEnterCDS: Bool = false            // 暫存是否可進入預約無卡
    var m_bCanEnterQRP: Bool = false            // 暫存是否可進入QRP
    var m_bCanEnterGP: Bool = false             // 暫存是否可進入黃金存摺
    var m_bCanEnterCLs: Bool = false            // 暫存是否可進入無卡提款
    
    
    var GesturePwdView:GesturePwd? = nil        // 圖形密碼頁
    var Gpod = ""                               // 圖形密碼
    //for news by sweney
    var m_NewsData1:[[String:Any]]? = nil
    var m_NewsData2:[[String:Any]]? = nil
   
    private var wkFastLogInFlag = "0"
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let rButton = UIButton(type: .custom)
        rButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
        rButton.addTarget(self, action: #selector(clickShowSideMenu), for: .touchUpInside)
        rButton.setImage(UIImage(named: ImageName.RightBarItem.rawValue), for: .normal)
        rButton.setImage(UIImage(named: ImageName.RightBarItem.rawValue), for: .highlighted)
        //無障礙＋
        rButton.accessibilityLabel = "選單"
        rButton.accessibilityHint = "點選開啟選單"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rButton)
        
        let imageName = needShowBackBarItem ? ImageName.BackBarItem.rawValue : ImageName.LeftBarItem.rawValue
        let lButton = UIButton(type: .custom)
        lButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
        lButton.addTarget(self, action: #selector(clickBackBarItem), for: .touchUpInside)
        lButton.setImage(UIImage(named: imageName), for: .normal)
        lButton.setImage(UIImage(named: imageName), for: .highlighted)
        //無障礙＋
        if needShowBackBarItem ==  true
        {
            lButton.accessibilityLabel = "回上頁"
        }else{
            lButton.accessibilityLabel = "回首頁"
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lButton)
        
        // 設定NavigationBar顏色
        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            gradient.frame = navigationBar.frame
            gradient.colors = [UIColor(netHex: 0xf0f36c).cgColor, UIColor(netHex: 0xe3a721).cgColor]
            gradient.locations = [0.0, 1.0]
            
            if let image = getImageFrom(gradientLayer: gradient) {
                //2021-12-16 add by sweney ios 15 navigationbar use scrolledgeappearance
                if #available(iOS 15.0, *) {
                    let barApp = UINavigationBarAppearance()
                    barApp.backgroundImage = image
                    barApp.backgroundColor = .white
                    barApp.titleTextAttributes = [NSAttributedStringKey.font:Default_Font,NSAttributedStringKey.foregroundColor:UIColor(red:0.51, green:0.35, blue:0.20, alpha:1.00)]
                    navigationBar.scrollEdgeAppearance = barApp
                    navigationBar.standardAppearance = barApp
                    
                    
                   }else{
                       
                navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
                   }
            }
        }
        
 }
    
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        originalY = view.frame.origin.y
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = getFeatureName(getCurrentFeatureID())
       // navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font:Default_Font,NSAttributedStringKey.foregroundColor:UIColor.white]
navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font:Default_Font,NSAttributedStringKey.foregroundColor:UIColor(red:0.51, green:0.35, blue:0.20, alpha:1.00)]
        originalY = view.frame.origin.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
        removeObserverToKeyBoard()
        super.viewWillDisappear(animated)
    }
    
    deinit {
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        removeObserverToKeyBoard()
        if touchTap != nil {
            view.removeGestureRecognizer(touchTap!)
            touchTap = nil
        }
    }
    
    // MARK: - Public
    #if DEBUG
    func postRequest(_ strMethod:String, _ strSessionDescription:String, _ httpBody:Data?, _ loginHttpHead:[String:String]?, _ strURL:String? = nil, _ needCertificate:Bool = false, _ isImage:Bool = false, _ timeOut:TimeInterval = REQUEST_TIME_OUT)  {
        request = !isImage ? ConnectionUtility(.Json) : ConnectionUtility(.Image)
        request?.requestData(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, loginHttpHead, needCertificate, timeOut)
    }
    #else
    func postRequest(_ strMethod:String, _ strSessionDescription:String, _ httpBody:Data?, _ loginHttpHead:[String:String]?, _ strURL:String? = nil, _ needCertificate:Bool = true, _ isImage:Bool = false, _ timeOut:TimeInterval = REQUEST_TIME_OUT)  {
        request = !isImage ? ConnectionUtility(.Json) : ConnectionUtility(.Image)
        request?.requestData(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, loginHttpHead, needCertificate, timeOut)
    }
    #endif
    
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
            //for test
            //        else if ID == .FeatureID_QRCodeTrans || ID == .FeatureID_QRPay {
            //            let con = navigationController?.viewControllers.first
            //                if con is HomeViewController {
            //                    self.navigationController?.popToRootViewController(animated: false)
            //                    (con as! HomeViewController).pushFeatureController(ID, animated)
            //                }
            //        }
        else {
            if AuthorizationManage.manage.CanEnterFeature(ID) { // 判斷是否需要登入
                if (AuthorizationManage.manage.checkAuth(ID) == true) {
                    var canEnter = true
                    switch ID {
                    case .FeatureID_TaxPayment, .FeatureID_BillPayment:
                        canEnter = false
                        if SecurityUtility.utility.isJailBroken() {
                            showErrorMessage(ErrorMsg_IsJailBroken, nil)
                        }
                        else {
                            //                            if (checkLocationAuthorization() == true) {
                            var workCode = ""
                            if ID == .FeatureID_TaxPayment {
                                workCode = "05001"
                            }
                            else if ID == .FeatureID_BillPayment {
                                workCode = "05002"
                            }
                            getTransactionID(workCode, BaseTransactionID_Description)
                            curFeatureID = ID
                            //                  }
                        }
                    //Guester 20180626
                        //設備驗證
                    case .FeatureID_QRCodeTrans, .FeatureID_QRPay,.FeatureID_QRPayDetailView,.FeatureID_QRPay0:
                        canEnter = false
//                        if SecurityUtility.utility.isJailBroken() {
//                            showErrorMessage(ErrorMsg_IsJailBroken, nil)
//                        }
//                        else
                            if m_bCanEnterQRP == false {
                            if !AuthorizationManage.manage.getCanEnterQRPay() {
                                showErrorMessage(nil, ErrorMsg_NoAuth)
                            }
                                //                            else if (checkLocationAuthorization() == true) {
                            else {
                                getTransactionID("09001", BaseTransactionID_Description)
                                curFeatureID = ID
                            }
                        }
                        else {
                            canEnter = true
                            m_bCanEnterQRP = false
                        }
                        //Guester 20180626 End
                    //Guester 20180731
                    case.FeatureID_BasicInfoChange:
                        canEnter = false
                            if !AuthorizationManage.manage.getChangeBaseInfoStaus() {
                                showErrorMessage(nil, ErrorMsg_NoAuth)
                            }
                            else {
                                getTransactionID("09001", BaseTransactionID_Description)
                                curFeatureID = ID
                            }
                   
                        
                    case .FeatureID_GPSingleBuy, .FeatureID_GPSingleSell:
                        canEnter = false
                        if m_bCanEnterGP == false {
                            getTransactionID("10001", BaseTransactionID_Description)
                            curFeatureID = ID
                        }
                        else {
                            canEnter = true
                            m_bCanEnterGP = false
                        }
                        //Guester 20180731 End
                    case .FeatureID_DeviceBinding:
                        canEnter = false
                        if let canBindDevice: Bool = SecurityUtility.utility.readFileByKey(SetKey: "canBindDevice") as? Bool {
                            if (canBindDevice == true) {
                                canEnter = true
                            }
                        }
                        else {
                            showAlert(title: UIAlert_Default_Title, msg: "要允許農漁行動達人存取以下權限嗎？\n取用IDFV。", confirmTitle: Determine_Title, cancleTitle: Cancel_Title, completionHandler: {
                                SecurityUtility.utility.writeFileByKey(true, SetKey: "canBindDevice")
                                self.enterFeatureByID(.FeatureID_DeviceBinding, true)
                            }, cancelHandelr: {()})
                        }
                        case .FeatureID_Device2Binding:
                                               canEnter = false
                                               if let canBindDevice: Bool = SecurityUtility.utility.readFileByKey(SetKey: "canBindDevice") as? Bool {
                                                   if (canBindDevice == true) {
                                                       canEnter = true
                                                   }
                                               }
                                               else {
                                                   showAlert(title: UIAlert_Default_Title, msg: "要允許農漁行動達人存取以下權限嗎？\n取用IDFV。", confirmTitle: Determine_Title, cancleTitle: Cancel_Title, completionHandler: {
                                                       SecurityUtility.utility.writeFileByKey(true, SetKey: "canBindDevice")
                                                       self.enterFeatureByID(.FeatureID_Device2Binding, true)
                                                   }, cancelHandelr: {()})
                                               }
                        case .FeatureID_OTPDeviceBinding: //add 1091116 chiu
                        canEnter = false
                        if let canBindDevice: Bool = SecurityUtility.utility.readFileByKey(SetKey: "canBindDevice") as? Bool {
                            if (canBindDevice == true) {
                                canEnter = true
                            }
                        }
                        else {
                            showAlert(title: UIAlert_Default_Title, msg: "要允許農漁行動達人存取以下權限嗎？\n取用IDFV。", confirmTitle: Determine_Title, cancleTitle: Cancel_Title, completionHandler: {
                                SecurityUtility.utility.writeFileByKey(true, SetKey: "canBindDevice")
                                self.enterFeatureByID(.FeatureID_OTPDeviceBinding, true)
                            }, cancelHandelr: {()})
                        }
                    case.FeatureID_CardlessQry,.FeatureID_CardlessDisable:
                     canEnter = false
                        if m_bCanENterCardlessQry == false {
                        getTransactionID("16003", BaseTransactionID_Description)
                        curFeatureID = ID
                        }else{
                            canEnter = true
                            m_bCanENterCardlessQry = false
                        }
                        if canEnter, let con = navigationController?.viewControllers.first {
                            if con is HomeViewController {
                                self.navigationController?.popToRootViewController(animated: false)
                                (con as! HomeViewController).tempTransactionId = tempTransactionId
                                (con as! HomeViewController).pushFeatureController(ID, animated)
                                return
                            }
                        }
                    case.FeatureID_CardlessSetup:
                        canEnter = false
                        if m_bCanEnterCardless == false {
                                getTransactionID("16001", BaseTransactionID_Description)
                                curFeatureID = ID
                        }else {
                            canEnter = true
                            m_bCanEnterCardless = false
                        }
                        if canEnter, let con = navigationController?.viewControllers.first {
                            if con is HomeViewController {
                                self.navigationController?.popToRootViewController(animated: false)
                                (con as! HomeViewController).tempTransactionId = tempTransactionId
                                (con as! HomeViewController).pushFeatureController(ID, animated)
                                return
                            }
                        }
                        
                    case .FeatureID_MobileTransferSetup, .FeatureID_MobileNTTransfer:
                        canEnter = false
                        if SecurityUtility.utility.isJailBroken() {
                            showErrorMessage(ErrorMsg_IsJailBroken, nil)
                        }
                        else {
                            if m_bCanEnterMTS == false {
                                var workCode = ""
                                if ID == .FeatureID_MobileTransferSetup {
                                    workCode = "15001"
                                }
                                else if ID == .FeatureID_MobileNTTransfer {
                                    workCode = "15005"
                                }
                                getTransactionID(workCode, BaseTransactionID_Description)
                                curFeatureID = ID
                            }else {
                                canEnter = true
                                m_bCanEnterMTS = false
                            }
                        }
                        
                        if canEnter, let con = navigationController?.viewControllers.first {
                            if con is HomeViewController {
                                self.navigationController?.popToRootViewController(animated: false)
                                (con as! HomeViewController).tempTransactionId = tempTransactionId
                                (con as! HomeViewController).pushFeatureController(ID, animated)
                                return
                            }
                        }
                        
//                        // for mobileTransfer test
//                        canEnter = true
//                        var workCode = ""
//                        if ID == .FeatureID_MobileTransferSetup {
//                            workCode = "15001"
//                        }
//                        else if ID == .FeatureID_MobileNTTransfer {
//                            workCode = "15005"
//                        }
//                        getTransactionID(workCode, BaseTransactionID_Description)
//                        curFeatureID = ID
                    case .FeatureID_ThirdPartyAnnounce:
                        canEnter = true
                    default: break
                    }
                    
                    if canEnter, let con = navigationController?.viewControllers.first {
                        if con is HomeViewController {
                            self.navigationController?.popToRootViewController(animated: false)
                            (con as! HomeViewController).pushFeatureController(ID, animated)
                        }
                    }
                }
                else {
                    showErrorMessage(nil, ErrorMsg_NoAuth)
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
    
    func enterConfirmResultController(_ isConfirm:Bool, _ data:ConfirmResultStruct, _ animated:Bool, _ title:String? = nil) {
        if isConfirm {
            let controller = getControllerByID(.FeatureID_Confirm)
            (controller as! ConfirmViewController).transactionId = transactionId
            (controller as! ConfirmViewController).setData(data)
            (controller as! ConfirmViewController).m_strTitle = title
            navigationController?.pushViewController(controller, animated: animated)
        }
        else {
            let controller = getControllerByID(.FeatureID_Result)
            (controller as! ResultViewController).transactionId = transactionId
            (controller as! ResultViewController).setData(data)
            //            (controller as! ConfirmViewController).m_strTitle = title
            navigationController?.pushViewController(controller, animated: animated)
        }
    }
    
    func enterConfirmOTPController(_ data:ConfirmOTPStruct, _ animated:Bool, _ title:String? = nil) {
        let controller = getControllerByID(.FeatureID_Confirm)
        (controller as! ConfirmViewController).transactionId = transactionId
        (controller as! ConfirmViewController).setDataNeedOTP(data)
        (controller as! ConfirmViewController).m_strTitle = title
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
          let title = title != nil ? title! : UIAlert_Default_Title
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: (confirmTitle != nil) ? confirmTitle : Determine_Title, style: .default, handler: { (action: UIAlertAction!) in
            confirmHandler()
        }))
        present(alert, animated: false, completion: nil)      
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
            loginView?.frame = CGRect(origin: .zero, size: view.frame.size)
            loginView?.delegate = self as? LoginDelegate
            getCanLoginBankInfo()
            getImageConfirm()
            view.addSubview(loginView!)
            addObserverToKeyBoard()
            addGestureForKeyBoard()    
        }
    }
    func showGestureView(wkPod: String) {
        if GesturePwdView == nil {
            //關掉手勢滑動選單
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                (rootViewController as! SideMenuViewController).SetGestureStatus(false)
            }
            GesturePwdView = getUIByID(.UIID_Gesture) as? GesturePwd
            GesturePwdView?.frame = CGRect(origin: .zero, size: view.frame.size)
            GesturePwdView?.delegate = self as? GesturePwdDelegate
            GesturePwdView?.pod = wkPod
            if let info = AuthorizationManage.manage.GetLoginInfo() {
                GesturePwdView?.m_BankCode = info.bankCode
                GesturePwdView?.m_account = info.aot
            }
            view.addSubview(GesturePwdView!)
            addObserverToKeyBoard()
            addGestureForKeyBoard()
        }
    }
    
    //取得連線的網路，wifi回名稱，4G回空
    private func getUsedSSID() -> String {
        let interfaces = CNCopySupportedInterfaces()
        var ssid = ""
        if interfaces != nil {
            let interfacesArray = CFBridgingRetain(interfaces) as! Array<AnyObject>
            if interfacesArray.count > 0 {
                let interfaceName = interfacesArray[0] as! CFString
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                if (ussafeInterfaceData != nil) {
                    let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                    ssid = interfaceData["SSID"]! as! String
                }
            }
        }
        return ssid
    }
    //取得4G IP
    private func GetIPAddresses() -> String? {
        var addresses = [String]()
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }
    //取得wifi IP
    private func getLocalIPAddressForCurrentWiFi() -> String {
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
    func getIP() -> String {
        if (getUsedSSID().isEmpty == true) {
            return GetIPAddresses() ?? Default_IP_Address
        }
        else {
            return getLocalIPAddressForCurrentWiFi()
        }
    }
        
    // MARK: - LoginDelegate
    func clickLoginBtn(_ info:LoginStrcture) {
        AuthorizationManage.manage.SetLoginInfo(info)
        checkImageConfirm(info.imgPod)
    }
    
    func clickGestureShowBtn( _ info:LoginStrcture ) {
        AuthorizationManage.manage.SetLoginInfo(info)
         self.postRequest("Comm/COMM0110", "COMM0110",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","KINBR":info.bankCode,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
       // showGestureView( )
    }
    func clickLoginRefreshBtn() {
        getImageConfirm()
    }
    func clickLoadBtn () {
        setLoading(true)
    }
    
    //2019-11-1 add by sweney for fastlogin
    func clickFastLogInBtn(_ bankCode:String, _ account:String , success:NSInteger ) {
        // AuthorizationManage.manage.SetLoginInfo(info)
        switch success
        {
        case 1:
            SendFastLogIn(bankCode,account)
        case 0:
            let gestureErCntr = SecurityUtility.utility.readFileByKey(SetKey: "GestureEr", setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String ?? "0"
            //錯6次重設
            if gestureErCntr == "5" {
                SecurityUtility.utility.writeFileByKey("0" + account , SetKey: bankCode , setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                SecurityUtility.utility.writeFileByKey("0"
                    , SetKey: "GestureEr", setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
            }
            tempBankCode =  bankCode
            SendFastLogInError( bankCode)
            
        default:
            break
        }
    }
    func SendFastLogInError (_ bCode:String){
        self.postRequest("Comm/COMM0108", "COMM0108",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","KINBR":bCode,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    
    
    func SendFastLogIn(_ bCode:String, _ account:String){
        setLoading(true)
        let now:Date =  Date()
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.timeZone = NSTimeZone.init(abbreviation:"UTC")! as TimeZone
        dateFormat.dateFormat = "yyyyMMddHHmm"
        // 將當下時間轉換成設定的時間格式
        let dateString = dateFormat.string(from: now)
        let MacKey = SecurityUtility.utility.getMacData(iLogInTime:now , iUID: account)
        self.postRequest("Comm/COMM0105", "COMM0105",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01015","Operate":"commitTxn","ICIFKEY":account,"MAC":MacKey,"TIME":dateString,"KINBR":bCode,"LoginMode":2, "TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark, "UserIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    func clickLoginCloseBtn() {
        loginView?.removeFromSuperview()
        loginView = nil
        curFeatureID = nil
        if touchTap != nil {
            view.removeGestureRecognizer(touchTap!)
            touchTap = nil
        }
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        removeObserverToKeyBoard()
    }
    func clickGesturePwdCloseBtn(_ ClossStatus: Bool) {
        
        GesturePwdView?.removeFromSuperview()
        GesturePwdView = nil
        GesturePwdView?.setNeedsDisplay()
        //開啟手勢滑動選單
        if ClossStatus == true {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                (rootViewController as! SideMenuViewController).SetGestureStatus(true)
            }}
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
        removeObserverToKeyBoard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeObserverToKeyBoard() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    var originalY: CGFloat = 0
    func keyboardWillShow(_ notification:NSNotification) {
        if loginView != nil, !(loginView?.isNeedRise())! {
            view.frame.origin.y = 0
            return
        }
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        view.frame.origin.y = originalY - keyboardHeight
    }
    
    func keyboardWillHide(_ notification:NSNotification) {
        view.frame.origin.y = originalY
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
            getRequest("Comm/COMM0501", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, true, .ImageConfirm)
        }
        else {
            getRequest("Comm/COMM0501?varifyId=\(varifyID!)", "COMM0501", nil, AuthorizationManage.manage.getHttpHead(false), nil, true, .ImageConfirm)
        }
    }
    
    func checkImageConfirm(_ pod:String, _ varifyID:String? = nil) { // 驗證圖形驗證碼
        if pod.isEmpty {
            showErrorMessage(nil, ErrorMsg_Image_Empty)
        }
        else {
            setLoading(true)
            let ID = varifyID == nil ? headVarifyID : varifyID!
            getRequest("Comm/COMM0502?varifyId=\(ID)&captchaCode=\(pod)", "COMM0502", nil, AuthorizationManage.manage.getHttpHead(false), nil, true, .ImageConfirmResult)
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
    
    func didResponse(_ description: String, _ response: NSDictionary) {
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
                    if E2EKeyData == "" {
                                     showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NoKeyAdConnection, confirmTitle: "確認", cancleTitle: nil, completionHandler: {exit(0)}, cancelHandelr: {()})
                               }else{
                    let idMd5 = SecurityUtility.utility.MD5(string: info.id)
                    let idMd5_1 = SecurityUtility.utility.MD5(string: info.id.uppercased())
                     //E2E
                     // let pdMd5 = SecurityUtility.utility.MD5(string: info.pod)
                     // let pdMd5_1 = SecurityUtility.utility.MD5(string: info.pod.uppercased())
                   // let fmt = DateFormatter()
                    //let timeZone = TimeZone.ReferenceType.init(abbreviation:"UTC") as TimeZone?
                    //fmt.timeZone = timeZone
                    //fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
                    //let loginDateTIme: String = fmt.string(from: Date())
                    let loginDateTIme: String = Date().date2String(dateFormat: "yyyy/MM/dd HH:mm:ss")
                    let pdMd50 = info.pod + loginDateTIme
                    let pdMd51 = info.pod.uppercased() + loginDateTIme
                    let pdMd5 = E2E.e2Epod(E2EKeyData, pod:pdMd50)
                    let pdMd5_1 = E2E.e2Epod(E2EKeyData, pod:pdMd51)
                    //109-10-16 add by sweney for check e2e key

                    //E2E
                    setLoading(true)
                    if (pdMd5 != ""||pdMd5_1 != "") {
                                          setLoading(true)
                                           postRequest("Comm/COMM0111", "COMM0111",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.aot,"ID":idMd5,"PWD":pdMd5,"ID1":idMd5_1,"PWD1":pdMd5_1, "KINBR":info.bankCode,"LoginMode":AgriBank_LoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark, "UserIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                                      }else{
                                           let alert = UIAlertView(title: UIAlert_Default_Title, message: "設備驗證發生錯誤！", delegate: nil, cancelButtonTitle:Determine_Title)
                                           alert.show()
                                          
                                      }
                    }
                    // //109-10-16 end
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
            loginView?.InitFastLogIn(false)
            
        //2019-11-1 add by sweney for 快速登入 0105
        case "COMM0111","COMM0105" :
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
                if let tBalance = data["TotalTBalance"] as? String {
                    info.TBalance = tBalance
                }
                if let STATUS = data["STATUS"] as? String {
                    info.STATUS = STATUS
                }
                if let WalletBasecode = data["WalletBasecode"] as? String {
                    info.WalletBasecode = WalletBasecode
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
                            if (curFeatureID != .FeatureID_QRPay && curFeatureID != .FeatureID_QRCodeTrans ) {
                                curFeatureID = nil
                            }
                        }
                        
                    case Account_Status_ForcedChange_Pod:
                        let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_Force_ChangePod, preferredStyle: .alert)
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
                        
                    case Account_Status_Change_Pod:
                        AuthorizationManage.manage.setLoginStatus(true)
                        let alert = UIAlertController(title: UIAlert_Default_Title, message: ErrorMsg_Suggest_ChangePod, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NextChange_Title, style: .default) { _ in
                            DispatchQueue.main.async {
                                if self.curFeatureID != nil {
                                    self.enterFeatureByID(self.curFeatureID!, false)
                                    if (self.curFeatureID != .FeatureID_QRPay && self.curFeatureID != .FeatureID_QRCodeTrans ) {
                                        self.curFeatureID = nil
                                    }
                                }
                                else {
                                    if self is HomeViewController {
                                        // (self as! HomeViewController).updateLoginStatus(false)
                                        //108-8-28 Add by Sweney For pod Change ByPass
                                        
                                        (self as! HomeViewController).pushFeatureController(.FeatureID_UserPwdChangeByPass, true)
                                        self.setLoading(true)
                                    }
                                }
                            }
                        })
                        alert.addAction(UIAlertAction(title: PerformChange_Title, style: .default) { _ in
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
                if #available(iOS 10.0, *) {
                    (UIApplication.shared.delegate as! AppDelegate).notificationAllEvent()
                } else {
                    // Fallback on earlier versions
                }
            }
        case "COMM0108":
            //快速登入錯誤次數紀錄
             let gestureErCntr = SecurityUtility.utility.readFileByKey(SetKey: "GestureEr", setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String ?? "0"
             var gestureErNew = Int(gestureErCntr)! + 1
                        if gestureErNew == 6 {
                            gestureErNew = 0
            
                        }
                         SecurityUtility.utility.writeFileByKey(String(gestureErNew), SetKey: "GestureEr", setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
        case "COMM0110":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] , let GrpPod = data[GraphPWD_Key] as? String{
                if GrpPod == "" {
                    let alert = UIAlertView(title: UIAlert_Default_Title, message: "尚未設定快速登入！", delegate: nil, cancelButtonTitle:Determine_Title)
                    //寫入目前快登項目 0:pod 1:touchid/faceid 2:picture(1 byte)
                      if let info = AuthorizationManage.manage.GetLoginInfo(){
                    SecurityUtility.utility.writeFileByKey("0" + info.aot  , SetKey: info.bankCode , setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                        alert.show()}
                }else{
                    showGestureView(wkPod: GrpPod)}
            }
           
            
        case "COMM0102": break
            //            AuthorizationManage.manage.setLoginStatus(false)
            //            curFeatureID = nil
//  //五倍卷   by sweney
//    case "USIF0101":
//        if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
//             var birday = ""
//            if let birthday = data["BIRTHDAY"] as? String {
//                birday = birthday
//            }
//         postRequest("QR/QR1001", "QR1001", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"11002","Operate":"getTerms","TransactionId":transactionId,"uid": AgriBank_DeviceID,"rebind":"0","born": birday
//], true), AuthorizationManage.manage.getHttpHead(true))
//         
//        }
//    case "QR1001":
//     if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
//       // QuintupleFlag = true
//        }
//     else
//         {
//         if let data = response.object(forKey: ReturnData_Key) as? [String:AnyObject]{
//             
//             if (data["Read"] as? String == "3") {
//                QuintupleFlag = false
//     }  }}
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
                                    self.postRequest("Comm/COMM0802", "BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                                case .FeatureID_QRCodeTrans?, .FeatureID_QRPay? ,.FeatureID_QRPayDetailView?, .FeatureID_QRPay0?:
                                    self.postRequest("Comm/COMM0802", "BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09001","Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                                case .FeatureID_BasicInfoChange?:
                                    self.postRequest("Comm/COMM0802", "BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09001","Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                                case .FeatureID_CardlessSetup?,.FeatureID_CardlessQry?,.FeatureID_CardlessDisable?:
                                    var workCode = ""
                                    if self.curFeatureID! == .FeatureID_CardlessSetup{
                                            workCode = "16001"
                                        }
                                        else   {
                                            workCode = "16003"
                                        }
                                        self.postRequest("Comm/COMM0802", "BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                                case .FeatureID_MobileTransferSetup?, .FeatureID_MobileNTTransfer?:
                                    var workCode = ""
                                    if self.curFeatureID! == .FeatureID_MobileTransferSetup {
                                        workCode = "15001"
                                    }
                                    else if self.curFeatureID! == .FeatureID_MobileNTTransfer {
                                        workCode = "15005"
                                    }
                                    self.postRequest("Comm/COMM0802", "BaseCOMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
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
            else if curFeatureID == .FeatureID_MobileTransferSetup {
                self.postRequest("Comm/COMM0115", "COMM0115", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"15002","Operate":"getTerms","TransactionId":tempTransactionId,"uid": AgriBank_DeviceID,"MotpDeviceID": MOTPPushAPI.getDeviceID()], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else if curFeatureID == .FeatureID_CardlessSetup {
                
                self.postRequest("Comm/COMM0117", "COMM0117", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"16001","Operate":"getTerms","TransactionId":tempTransactionId,"uid": AgriBank_DeviceID,"MotpDeviceID": MOTPPushAPI.getDeviceID()], true), AuthorizationManage.manage.getHttpHead(true))
               
            }
            else if (curFeatureID == .FeatureID_CardlessQry || curFeatureID == .FeatureID_CardlessDisable){
                m_bCanENterCardlessQry = true
                
                enterFeatureByID(curFeatureID!, false)
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
                    enterFeatureByID(curFeatureID!, false)
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
                    enterFeatureByID(curFeatureID!, false)
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
        case "COMM0117":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
                //                AuthorizationManage.manage.setGoldAcception(data)
                //                if (AuthorizationManage.manage.canEnterGold()) {
                if (data["Read"] == "Y") {
                   // requestAcnt()
                    m_bCanEnterCardless = true
                    enterFeatureByID(curFeatureID!, false)
                }
                else {
                    let controller = getControllerByID(.FeatureID_CardlessSetupAcceptRules)
                    (controller as! CardlessSetupAcceptRulesViewController).m_dicAcceptData = data
                    (controller as! CardlessSetupAcceptRulesViewController).m_nextFeatureID = .FeatureID_CardlessSetup
                    (controller as! CardlessSetupAcceptRulesViewController).transactionId = tempTransactionId
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
      
            
        case "COMM0115":
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
                //                AuthorizationManage.manage.setGoldAcception(data)
                //                if (AuthorizationManage.manage.canEnterGold()) {
                if (data["Read"] == "Y") {
                    m_bCanEnterMTS = true
                    enterFeatureByID(curFeatureID!, false)
                }
                else {
                    let controller = getControllerByID(.FeatureID_MobileTransferSetupAcceptRules)
                    (controller as! MobileTransferSetupAcceptRulesViewController).m_dicAcceptData = data
                    (controller as! MobileTransferSetupAcceptRulesViewController).m_nextFeatureID = curFeatureID
                    (controller as! MobileTransferSetupAcceptRulesViewController).transactionId = tempTransactionId
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
        case "TRAN0101","TRAN0102","TRAN0201","TRAN0302","TRAN0401","TRAN0502","TRAN0602","TRAN0802",
             "LOSE0101","LOSE0201","LOSE0301","LOSE0302","LOSE0303",  //chiu 1090819 add LOSE0303
             "PAY0103","PAY0105","PAY0107","TRAN1005",
             "USIF0102","USIF0201","USIF0303","QR1102","QR1103",
             "COMM0102","COMM0801","COMM0112","COMM0814",//chiu 20201119
             "QR0302","QR0402","QR0502","QR0702","QR0504",//QRP
        "Gold0301","Gold0302","Gold0401","Gold0402","Gold0403","Gold0404"://黃金存摺
            didResponse(description, response)
        case "QR0202"://checkQRCode  ==>QR0201>QR0202 自行處理回來的結果(因為有錯誤時，關閉alert後要重啟相機)
            didResponse(description, response)
        case "QR0703":// sweney for p2p
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
                               // let pdMd5 = SecurityUtility.utility.MD5(string: info.pod)
                                let idMd5_1 = SecurityUtility.utility.MD5(string: info.id.uppercased())
                                //let pdMd5_1 = SecurityUtility.utility.MD5(string: info.pod.uppercased())
                               //E2E
                                // let fmt = DateFormatter()
                                 //let timeZone = TimeZone.ReferenceType.init(abbreviation:"UTC") as TimeZone?
                                 //fmt.timeZone = timeZone
                                 //fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
                                 //let loginDateTIme: String = fmt.string(from: Date())
                                 let loginDateTIme: String = Date().date2String(dateFormat: "yyyy/MM/dd HH:mm:ss")
                               let pdMd50 = info.pod + loginDateTIme
                               let pdMd51 = info.pod.uppercased() + loginDateTIme
                               let pdMd5 = E2E.e2Epod(E2EKeyData, pod:pdMd50)
                               let pdMd5_1 = E2E.e2Epod(E2EKeyData, pod:pdMd51)
                               //E2E
                                self.setLoading(true)
                                self.postRequest("Comm/COMM0111", "COMM0111",  AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01011","Operate":"commitTxn","appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"ICIFKEY":info.aot,"ID":idMd5,"PWD":pdMd5,"ID1":idMd5_1,"PWD1":pdMd5_1,"KINBR":info.bankCode,"LoginMode":AgriBank_ForcedLoginMode,"TYPE":AgriBank_Type,"appId": AgriBank_AppID,"Version": AgriBank_Version,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark, "UserIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                            }
                        }
                    })
                    present(alert, animated: false, completion: nil)
                    return
                }
                    //for fast login error
               else if returnCode == "E_COMM0401_02" {
                                        let message = "此ID已設定二台裝置，請確認是否要設定此裝置，停用另二台裝置快速登入？"
                                        //(response.object(forKey: ReturnMessage_Key) as? String) ??""
                                        //show del msg
                                        let confirmHandler : ()->Void = {
                    
                                            self.setLoading(true)
                                            if let info = AuthorizationManage.manage.GetLoginInfo(){
                                                let  bCode = info.bankCode
                                                self.postRequest("Comm/COMM0104", "COMM0104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01014","Operate":"commitTxn","TransactionId":self.transactionId,"KINBR":bCode,"appId": AgriBank_AppID,"Version": AgriBank_Version,"appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark,"CreateMode":"2","GraphPWD":SecurityUtility.utility.AES256Encrypt("AFISCCOMTW" +  self.Gpod.description, "\(SEA1)\(SEA2)\(SEA3)")], true), AuthorizationManage.manage.getHttpHead(true))
                                            }
                    
                                        }
                                        let cancelHandler : ()->Void = {()}
                                        showAlert(title: "注意", msg: message , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
                    
                                    }
//                else if returnCode == "XG396" {
//                     let message = "查無資料!"
//                      showErrorMessage(nil, message)
//                }
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
                                if   //(self is HomeViewController &&
                                    (response.object(forKey:"ReturnCode") as? String == "E_TRAN0000_01")||(self is HomeViewController && response.object(forKey:"ReturnCode") as? String == "E_Gold0502_02") || (self is OTPDeviceBindingViewController && response.object(forKey:"ReturnCode") as? String == "E_KEYPASCO_01") || ( response.object(forKey:"ReturnCode") as? String == "E_QR1001_01"){
                                    //首頁的transactionID無效時不跳錯誤訊息
                                   
                                    //2019-11-8 add by sweney 不顯示"查無黃金牌告價格 ->E_Gold0502_02"
                                    //2020-11-25 add by chiu 設備綁定畫面執行前檢查若尚未綁定不顯示訊息
                                    //2021-1-14 add by sweney E_QR1001_01 五倍卷
                                }
                                    //2019-11-7 add by sweney for fastlogin
                                else if (returnCode == "E_COMM0401_08")||(returnCode == "E_COMM0401_04")||(returnCode == "E_COMM0501_02")||(returnCode == "E_COMM0401_05"){
                                    //2019-11-4 add by sweney 快登暫停
                                    //寫入目前快登項目 0:pod
                                    if let info = AuthorizationManage.manage.GetLoginInfo(){
                                        let  bCode = info.bankCode
                                        let  bid   = info .aot
                                        SecurityUtility.utility.writeFileByKey("0" + bid, SetKey: bCode , setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                                        showErrorMessage(nil, returnMsg)
                                    }
                                }
                                //dont show msg
                                else if (returnCode == "XO065" ){
                                          if (  response.object(forKey:"WorkCode") as? String == "16003"){
                                    let mmsg = "請使用晶片金融卡至ＡＴＭ設定提款帳號"
                                    showAlert(title: UIAlert_Default_Title, msg: mmsg, confirmTitle: "確認", cancleTitle: nil, completionHandler: {
                                        self.enterFeatureByID(.FeatureID_Home, true)
                                    }, cancelHandelr: {()})
                                }else{
                                              didResponse(description, response)
}
                              }
                                //資安檢測修改錯誤次數超過5次刪除記住ＩＤ
                                else if (returnCode == "E_USIF0301_04") || (returnCode == "E_COMM0101_02") || (returnCode == "E_USIF0301_03"){
                                    if returnCode != "E_USIF0301_03"{
                                    KeychainManager.keyChianDelete(identifier: File_Account_Key)
                                        loginView?.aotTextfield.text = ""
                                    loginView?.checkImg.image = UIImage(named: ImageName.Checkoff.rawValue)
                                        //如果是驗證交易,直接登出
                                        if AuthorizationManage.manage.IsLoginSuccess() {
                                           postLogout()
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                    loginView?.cleanImageConfirmText()
                                   
                                   
                                    showErrorMessage(nil, returnMsg)
                                }
                                else if (  response.object(forKey:"WorkCode") as? String == "09012") {
                                    didResponse(description, response)
                                }
                                else {
                                    showErrorMessage(nil, returnMsg)
                                }
                            }
                        }
                    }
                    /*  登入失敗，需要重取圖形驗證碼 */
                    if description == "COMM0111" {
                        getImageConfirm()
                    }
                  
                }
            }
            else {
                showErrorMessage(nil, String(describing: response))
            }
        }
    }
    
    func didFailedWithError(_ error: Error, _ sessionDescription: String?) {
        setLoading(false)
        //版號控管電文 取加密key電文
        if (sessionDescription == "COMM0901" || sessionDescription == "GetKey") {
        // showErrorMessageWithHandler(title: nil, msg: ErrorMsg_NoConnection, confirmTitle: nil, confirmHandler: { exit(0) })
            //edit by sweney - show app close msg
//            showErrorMessageWithHandler(title: nil, msg: ErrorMsg_NoKeyAdConnection  , confirmTitle: nil, confirmHandler: { exit(0)})
        }
        else if (error as NSError).code == -1009 {
            /* 網路*/
            showErrorMessage(nil, ErrorMsg_NoConnection)
        }
 else if (error as NSError).code == -999 {
            showErrorMessage(nil, ErrorMsg_NoCertificate)
        }
        else {
            showErrorMessage(nil, error.localizedDescription)
        }
    }
 
}


//Mark - 檢查定位權限
extension BaseViewController {
    func checkLocationAuthorization() -> Bool {
        if (CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            return true
        }
        else {
            showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NoPositioning, confirmTitle: Determine_Title, cancleTitle: Cancel_Title, completionHandler: { self.goToSetting() }, cancelHandelr: {()})
            return false
        }
    }
    func goToSetting() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl)  {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            }
            else  {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
}
extension Date {
    //日期 -> 字符
    func date2String(dateFormat:String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier:"Asia/Taipei")
        formatter.locale = Locale.init(identifier: "zh_Hant_TW")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date
    }
}
