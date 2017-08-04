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
    override func viewDidLoad() {
        super.viewDidLoad()

        setLoading(true)
        getTransactionID("07061", "TrID")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSwitch(_ sender: Any) {
        setLoading(true)
        postRequest("Comm/COMM0305", "COMM0305", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"commitTxn","TransactionId":transactionId,"action":messageSwitch.isOn ? "1" : "0"], true), AuthorizationManage.manage.getHttpHead(true))
    }

    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case "TrID":
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data["TransactionId"] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("Comm/COMM0306", "COMM0306", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "COMM0306":
            if let data = response.object(forKey: "Data") as? [String:Any], let status = data["ReceiveMsgFlag"] as? String {
                messageSwitch.isOn = status == "0" ? false : true
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        default: break
        }
    }

}
