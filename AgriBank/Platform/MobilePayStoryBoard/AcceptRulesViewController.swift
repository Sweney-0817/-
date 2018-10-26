//
//  AcceptRulesViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class AcceptRulesViewController: BaseViewController {
    var m_nextFeatureID : PlatformFeatureID? = nil
    var m_dicData : [String:String]? = nil
    @IBOutlet var m_wvContent: UIWebView!
    @IBOutlet var m_btnCheck: UIButton!
    @IBAction func m_btnCheckClick(_ sender: Any) {
        m_btnCheck.isSelected = !m_btnCheck.isSelected
    }
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        guard m_btnCheck.isSelected else {
            showErrorMessage(nil, "請勾選我已審閱並同意上述事項")
            return
        }
        guard m_nextFeatureID != nil else {
            showErrorMessage("錯誤", "沒帶FeatureID")
            return
        }
        self.send_confirm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let content: String = AuthorizationManage.manage.getQRPAcception().Content
        let content: String = m_dicData?["Content"] ?? ""
        m_wvContent.loadHTMLString(content, baseURL: nil)
    }
    func send_confirm() {
        self.setLoading(true)
//        let version: String = AuthorizationManage.manage.getQRPAcception().Version
        let version: String = m_dicData?["Version"] ?? ""
        postRequest("QR/QR0102", "QR0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"09001","Operate":"termsConfirm","TransactionId":transactionId,"Version":version,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "QR0102":
            enterFeatureByID(m_nextFeatureID!, true)
            break
        default:
            super.didResponse(description, response)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
