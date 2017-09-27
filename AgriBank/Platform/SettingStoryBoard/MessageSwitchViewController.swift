//
//  MessageSwitchViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class MessageSwitchViewController: BaseViewController {
    @IBOutlet weak var messageSwitch: UISwitch!
    private var getStatus = true
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        getTransactionID("08004", TransactionID_Description)
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
            }
            else {
                super.didResponse(description, response)
            }
            
            if getStatus && getSettingStatus() {
                messageSwitch.isOn = true
            }
            else {
                messageSwitch.isOn = false
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSwitch(_ sender: Any) {
        if messageSwitch.isOn {
            setLoading(true)
            postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":transactionId,"action":messageSwitch.isOn ? "1" : "0"], true), AuthorizationManage.manage.getHttpHead(true))
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        else {
            if getStatus && !getSettingStatus() {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            else if !getStatus && getSettingStatus() {
                setLoading(true)
                postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":transactionId,"action":messageSwitch.isOn ? "1" : "0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else if !getStatus && !getSettingStatus() {
                setLoading(true)
                postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"dataSetup","TransactionId":transactionId,"action":messageSwitch.isOn ? "1" : "0"], true), AuthorizationManage.manage.getHttpHead(true))
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        }
    }
    
    // MARK: - Private
    func getSettingStatus() -> Bool {
        if let status = UIApplication.shared.currentUserNotificationSettings {
            if status.types == .alert {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}
