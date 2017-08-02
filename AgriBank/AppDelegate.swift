//
//  AppDelegate.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/1.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ConnectionUtilityDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 連線暫存檔清除
        SecurityUtility.utility.removeConnectCatche()
        // 設定Root View Controller
        window = UIWindow(frame:UIScreen.main.bounds)
        window?.rootViewController = Platform.plat.getUIByID(.UIID_SideMenu) as? UIViewController
        window?.makeKeyAndVisible()
        // Status bar
        let statusView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusView.backgroundColor = .white
        statusView.tag = ViewTag.View_Status.rawValue
        window?.addSubview(statusView)
        // APNS註冊
//        if #available(iOS 10.0, *) {
//            let center = UNUserNotificationCenter.current()
//            center.delegate = self
//            center.requestAuthorization(options: [.sound,.alert], completionHandler: { (granted, error) in
//                if granted {
//                    center.getNotificationSettings(completionHandler: { (setting) in
//                        print(setting)
//                    })
//                }
//                else {
//                    print("使用者不允許 註冊失敗")
//                }
//            })
//        }
//        else {
//            if application.responds(to: #selector(getter: UIApplication.isRegisteredForRemoteNotifications)) {
//                application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound], categories: nil))
//            }
//        }
//        postRegisterToken("testtest")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
    }
    
    func RegisterAPNSToken(_ token:String) {
        AuthorizationManage.manage.SetAPNSToken(token)
        if AuthorizationManage.manage.IsLoginSuccess() {
            let request = ConnectionUtility()
            request.postRequest(self, "\(REQUEST_URL)/COMM0301", "COMM0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01031","Operate":"commitTxn","appUid":"","uid":"1234567","model":"1234567","auth":"123456789","appId":AgriBank_AppID,"version":AgriBank_Version,"token":token,"systemVersion":AgriBank_SystemVersion,"codeName":AgriBank_DeviceType,"tradeMark":AgriBank_TradeMark], true), AuthorizationManage.manage.getHttpHead(true, false), false)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }

    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description: String, _ response: NSDictionary) {
        
    }
    
    func didFailedWithError(_ error: Error) {
        
    }
}


