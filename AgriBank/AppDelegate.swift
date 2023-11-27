//
//  AppDelegate.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/1.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@available(iOS 10.0, *)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, ConnectionUtilityDelegate, UNUserNotificationCenterDelegate, UIAlertViewDelegate {

    var window: UIWindow?
    var logoutTimer:Timer? = nil
    var notification:NSObjectProtocol? = nil
    var enterBackgroundTime:Date? = nil
    var interval:TimeInterval = 0
    let m_locationManager = CLLocationManager()
    var m_location: CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    var vc: UIViewController? //chiu push test
    var contentHandler: ((UNNotificationContent) -> Void)?  //chiu push test
    var bestAttemptContent: UNMutableNotificationContent?   //chiu push test
    var updateInfoArray: NSArray?
//    func getUpdateInfoArray() -> (CHGUpdateInfo?) -> NSArray{
//        return updateInfoArray
//    }
    //2021-11-16- add by sweney 禁止第三方鍵盤
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplicationExtensionPointIdentifier.keyboard {
            return false
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 連線暫存檔清除
        SecurityUtility.utility.removeConnectCatche()
        // 設定Root View Controller
        window = UIWindow(frame:UIScreen.main.bounds)
        window?.rootViewController = Platform.plat.getUIByID(.UIID_SideMenu) as? UIViewController
        window?.makeKeyAndVisible()
        // Status bar
        let statusView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusView.backgroundColor = .clear
        statusView.tag = ViewTag.View_Status.rawValue
        window?.addSubview(statusView)
        // APNS註冊
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound,.alert,.badge]) { granted, error in
                if granted {
                    center.getNotificationSettings(completionHandler: { (setting) in
                    })
                }
                else {
                }
            }
        }
        else {
            if application.responds(to: #selector(getter: UIApplication.isRegisteredForRemoteNotifications)) {
                application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil))
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
        // 檢查定位權限
        checkLocation()
        // 偵測APP縮至背景
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: OperationQueue.current, using: appWillEnterBackground)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.current, using: appWillEnterForeground)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.current, using: appWillEnterForeground)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if logoutTimer != nil {
            enterBackgroundTime = Date() // Date(timeIntervalSinceNow: TimeInterval(NSTimeZone.system.secondsFromGMT(for: Date())))
            interval = AgriBank_TimeOut - (logoutTimer?.fireDate.timeIntervalSince(enterBackgroundTime!))!
            /* Timer 在背景不確定什麼時候會停止 */
            logoutTimer?.invalidate()
            logoutTimer = nil
        }
        
//        print("applicationDidEnterBackground \(String(describing: logoutTimer?.fireDate))  \(String(describing: enterBackgroundTime)) \(interval)")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if enterBackgroundTime != nil {
            if Date().timeIntervalSince(enterBackgroundTime!) + interval >= AgriBank_TimeOut {
                if AuthorizationManage.manage.IsLoginSuccess() {
                    appWillEnterForeground(nil)
                    let alert = UIAlertView(title: UIAlert_Default_Title, message: Timeout_Title, delegate: self, cancelButtonTitle: Determine_Title)
                    alert.show()
                }
                removeNotificationAllEvent()
            }
            else {
                logoutTimer = Timer.scheduledTimer(timeInterval: AgriBank_TimeOut, target: self, selector: #selector(timeOut(_:)), userInfo: nil, repeats: false)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        AuthorizationManage.manage.SetAPNSToken(token)
        //chiu MOTP 20201111
        let rtn:Int32? = MOTPPushAPI.setPushID(token.data(using: String.Encoding.utf8))
        if rtn == 0{
            updateInfoArray = MOTPPushAPI.getUpdateInfo()! as NSArray
        }
        
    }
    
 
    @objc func timeOut(_ sender:Timer) {
        if sender == logoutTimer {
            if AuthorizationManage.manage.IsLoginSuccess() {
                let alert = UIAlertView(title: UIAlert_Default_Title, message: Timeout_Title, delegate: self, cancelButtonTitle: Determine_Title)
                alert.show()
            }
            removeNotificationAllEvent()
        }
    }
    
    func notificationAllEvent() {
        if AuthorizationManage.manage.IsLoginSuccess() {
            logoutTimer = Timer.scheduledTimer(timeInterval: AgriBank_TimeOut, target: self, selector: #selector(timeOut(_:)), userInfo: nil, repeats: false)
            if notification == nil {
                notification = NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { notification in
                    if notification.name.rawValue == "_UIWindowSystemGestureStateChangedNotification" {
                        self.logoutTimer?.invalidate()
                        self.logoutTimer = Timer.scheduledTimer(timeInterval: AgriBank_TimeOut, target: self, selector: #selector(self.timeOut(_:)), userInfo: nil, repeats: false)
                    }
                }
            }
        }
    }
    
    func removeNotificationAllEvent() {
        logoutTimer?.invalidate()
        logoutTimer = nil
        if notification != nil {
            NotificationCenter.default.removeObserver(notification!, name: nil, object: nil)
            notification = nil
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    // chiu push 備註 當使用者點選推播打開APP時（App在背景或是沒被啟動）將觸發userNotificationCenter(:didReceive:withCompletionHandler:)
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name("PushResult"), object: response.notification.request.content.userInfo)
        completionHandler()
        self.bestAttemptContent = (response.notification.request.content.mutableCopy()
        as? UNMutableNotificationContent)
        let Data = bestAttemptContent?.userInfo
        pushResultList = Data
        //出示付款碼交易結果推播，交易當時沒收到交易結果推播就關閉APP,點取推播訊息時顯示訊息請其查詢交易紀錄
        var pushcheck = "" //檢查推播類型
        //chiu 20210611 add start
        if let aps = pushResultList![AnyHashable("aps")] as? NSDictionary{
        if aps["WorkCode"]  as? String == "09004"{
        pushResultList = aps as! [AnyHashable : Any]
                    }
                }
                //chiu 20210611 add end
        if (pushResultList![AnyHashable("ReturnCode")] as? String == "OK") && (pushResultList![AnyHashable("WorkCode")] as? String == "09004"){
            pushcheck = "PAY"
           let alert = UIAlertView(title: "農漁行動達人 出示付款碼交易訊息！", message: "請至 農漁行動PAY-交易紀錄/退貨 查詢結果", delegate: self, cancelButtonTitle: Determine_Title)
            alert.show()
        }
         if let pushString = pushResultList![AnyHashable("msg")] as? String {
                   do{
                       let jsonDic = try JSONSerialization.jsonObject(with: (pushString.data(using: .utf8)!), options: .mutableContainers) as? [String:Any]
                                      //showErrorMessage("CONT",jsonDic!["CONT"] as? String)
                       if (jsonDic!["CONT"] as? String) != nil
                            {
                            pushcheck = "OTP"
                            let alert = UIAlertView(title: "農漁行動達人 OTP！", message: "若仍須執行請原交易重新執行！取得OTP", delegate: self, cancelButtonTitle: Determine_Title)
                            alert.show()
                       }
                   
                   }
                   catch {
                       
                   }
               }
        if pushcheck == ""{
            if let aps = pushResultList![AnyHashable("aps")] as? NSDictionary{

                    if let apsalert = aps["alert"] as? NSString{
                    let alert = UIAlertView(title: UIAlert_Default_Title, message: apsalert as String, delegate: self, cancelButtonTitle: Determine_Title)
                    alert.show()
                }
            }
        }
        
    }
    // chiu 當APP本來就在前景，收到推播時將觸發userNotificationCenter(_:willPresent:withCompletionHandler:) 另completionHandler可以傳入參數，控制是否在前景顯示推播，completionHandler([])代表不顯示，completionHandler([.alert])則可顯示推播文字
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //chiu push test start
/*
            let userInfo = notification.request.content.userInfo
        let userBody = notification.request.content.body
        let alert = UIAlertView(title: UIAlert_Default_Title + "willPresent", message: userInfo.description, delegate: self, cancelButtonTitle: Determine_Title)
            alert.show()
 */
        
        self.bestAttemptContent = (notification.request.content.mutableCopy()
              as? UNMutableNotificationContent)
      // Try to decode the encrypted message data.
       // pushResultList = bestAttemptContent?.userInfo
        let Data = bestAttemptContent?.userInfo
        //test debug ==========
//        let alert = UIAlertView(title: UIAlert_Default_Title , message: Data?.description, delegate: self, cancelButtonTitle: Determine_Title)
//                   alert.show()
        //======================
        pushResultList = Data
        //chiu 20210611 add start
        if let aps = pushResultList![AnyHashable("aps")] as? NSDictionary{
        if aps["WorkCode"]  as? String == "09004"{
        pushResultList = aps as! [AnyHashable : Any]
        }
    }
                //chiu 20210611 add end
        
        
        if (pushResultList![AnyHashable("ReturnCode")] as? String == "OK") && (pushResultList![AnyHashable("WorkCode")] as? String == "09004"){
            pushReceiveFlag = "PAY"
        }
        if let pushString = pushResultList![AnyHashable("msg")] as? String {
            do{
                let jsonDic = try JSONSerialization.jsonObject(with: (pushString.data(using: .utf8)!), options: .mutableContainers) as? [String:Any]
                               //showErrorMessage("CONT",jsonDic!["CONT"] as? String)
                if (jsonDic!["CONT"] as? String) != nil
                               {
                     pushReceiveFlag = "OTP"

                }
            
            }
            catch {
                
            }
        }
        //chiu 公告推播顯示訊息 20201231(不是ＹＥＳ 也不是 ＯＴＰ
        if pushReceiveFlag == ""{
            if let aps = pushResultList![AnyHashable("aps")] as? NSDictionary{
                           if let apsalert = aps["alert"] as? NSString{
                            pushReceiveFlag = "MSG"
                       }
            }
        }
       
//         if (pushResultList![AnyHashable("ReturnCode")] as? String != "OK") && (pushResultList![AnyHashable("WorkCode")] as? String == "09004")
//        {
//            pushReceiveFlag = "NO"
//        }
        

        //chiu push test
    }

    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description: String, _ response: NSDictionary) {
        switch description {
//        case "COMM0102":
//            AuthorizationManage.manage.setLoginStatus(false)
//            let center = ((window?.rootViewController as! SideMenuViewController).getController(.center) as! UINavigationController)
//            center.popToRootViewController(animated: true)
//            (center.viewControllers.first as! HomeViewController).updateLoginStatus()
//            (window?.rootViewController as! SideMenuViewController).ShowSideMenu(false)
            
        default: break
        }
    }
    
     func didFailedWithError(_ error: Error, _ sessionDescription: String?) {
        let alert = UIAlertView(title: UIAlert_Default_Title, message: error.localizedDescription, delegate: nil, cancelButtonTitle:Determine_Title)
        alert.show()
    }
    
    // MARK: - UIAlertViewDelegate
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        let request = ConnectionUtility()
        request.requestData(self, "\(REQUEST_URL)/Comm/COMM0102", "COMM0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01012","Operate":"commitTxn"], false), AuthorizationManage.manage.getHttpHead(false))

        AuthorizationManage.manage.setLoginStatus(false)
        
        let center = ((window?.rootViewController as! SideMenuViewController).getController(.center) as! UINavigationController)
        center.popToRootViewController(animated: true)
       // (center.viewControllers.first as! HomeViewController).updateLoginStatus()
        if center.viewControllers.last is HomeViewController {
            (center.viewControllers.last as! HomeViewController).updateLoginStatus()
        }
        else {
            center.popToRootViewController(animated: true)
        }
        (window?.rootViewController as! SideMenuViewController).ShowSideMenu(false)
    }
    
    func appWillEnterBackground(_ notification: Notification?) {
        let vc:UIViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "FeatureID_LaunchScreenView") as UIViewController
        let window: UIWindow = UIApplication.shared.keyWindow!
        vc.view.frame = window.frame
        vc.view.tag = 8866
        window.addSubview(vc.view)
    }
    func appWillEnterForeground(_ notification: Notification?) {
        let window: UIWindow = UIApplication.shared.keyWindow!
        window.viewWithTag(8866)?.removeFromSuperview()
    }
    
}

@available(iOS 10.0, *)
extension AppDelegate: CLLocationManagerDelegate {
    func checkLocation() {
        m_locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            m_locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            m_locationManager.startUpdatingLocation()
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            m_locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        m_location = locations.last ?? CLLocation(latitude: 0.0, longitude: 0.0)
    }
   
    
//chiu push test
   func getControllerByID(_ ID:PlatformFeatureID) -> UIViewController {
       return Platform.plat.getControllerByID(ID)
   }
}
