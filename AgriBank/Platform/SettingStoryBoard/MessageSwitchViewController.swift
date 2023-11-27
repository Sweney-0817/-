//
//  MessageSwitchViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import UserNotifications

class MessageSwitchViewController: BaseViewController {
    @IBOutlet weak var messageSwitch: UISwitch!
    private var getStatus:Bool? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        getTransactionID("08004", TransactionID_Description)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: .UIApplicationDidBecomeActive, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data["TransactionId"] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("Comm/COMM0306", "COMM0306", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0306":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let status = data["ReceiveMsgFlag"] as? String {
                if status == "0" {
                    getStatus = false
                }
                else {
                    getStatus = true
                }
                if getStatus! {
                    if #available(iOS 10.0, *) {
                        let center = UNUserNotificationCenter.current()
                        center.getNotificationSettings() { setting in
                            if setting.alertStyle != .none {
                                DispatchQueue.main.async {
                                    self.messageSwitch.isOn = true
                                }
                            }
                        }
                    }
                    else {
                        if UIApplication.shared.currentUserNotificationSettings != nil {
                            messageSwitch.isOn = true
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSwitch(_ sender: Any) {
        if messageSwitch.isOn {
            if getStatus! == false {
                setLoading(true)
                postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":transactionId,"action":messageSwitch.isOn ? "1" : "0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.getNotificationSettings() { setting in
                    if setting.alertStyle == .none {
                        DispatchQueue.main.async {
                        self.showAlertViewController()
                        }
                    }
                }
            }
            else {
                if UIApplication.shared.currentUserNotificationSettings == nil {
                    showAlertViewController()
                }
            }
        }
        else {
            setLoading(true)
            postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":transactionId,"action":messageSwitch.isOn ? "1" : "0"], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    // MARK: - Private
    private func showAlertViewController() {
        let alert = UIAlertController(title: UIAlert_Default_Title, message: SetNotification_Title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Cancel_Title, style: .default) { _ in
            DispatchQueue.main.async {
                self.setLoading(true)
                self.postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":self.transactionId,"action":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                self.messageSwitch.isOn = false
            }
        })
        alert.addAction(UIAlertAction(title: Setting_Title, style: .default) { _ in
            DispatchQueue.main.async {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        })
        present(alert, animated: false, completion: nil)
    }
    
    // MARK: - Public
    func appWillEnterForeground(_ sender:Any) {  /* 從背景返回 */
        if getStatus != nil {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.getNotificationSettings() { setting in
                    if setting.alertStyle != .none {
                        DispatchQueue.main.async {
                            if self.messageSwitch.isOn == true {
                                self.setLoading(true)
                                self.postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":self.transactionId,"action":"1"], true), AuthorizationManage.manage.getHttpHead(true))
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            if self.messageSwitch.isOn == true {
                                self.setLoading(true)
                                self.postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":self.transactionId,"action":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                                self.messageSwitch.isOn = false
                            }
                        }
                    }
                }
            }
            else {
                if UIApplication.shared.currentUserNotificationSettings != nil {
                    if self.messageSwitch.isOn == true {
                        setLoading(true)
                        postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":transactionId,"action":"1"], true), AuthorizationManage.manage.getHttpHead(true))
                    }
                }
                else {
                    if self.messageSwitch.isOn == true {
                        self.setLoading(true)
                        self.postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":self.transactionId,"action":"0"], true), AuthorizationManage.manage.getHttpHead(true))
                        messageSwitch.isOn = false
                    }
                }
            }
        }
    }
}
