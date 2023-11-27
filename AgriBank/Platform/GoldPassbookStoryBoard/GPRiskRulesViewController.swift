//
//  GPRiskRulesViewController.swift
//  AgriBank
//
//  Created by ABOT on 2022/9/22.
//  Copyright © 2022 Systex. All rights reserved.
//

import UIKit
import WebKit

class GPRiskRulesViewController: BaseViewController {
    var m_nextFeatureID : PlatformFeatureID? = nil
    var m_dicData: [String:Any]? = nil
    var m_dicAcceptData : [String:String]? = nil
    @IBOutlet var m_wvContent: WKWebView!
    @IBOutlet var m_btnCheck: UIButton!
    @IBAction func m_btnCheckClick(_ sender: Any) {
        m_btnCheck.isSelected = !m_btnCheck.isSelected
    }
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        guard m_btnCheck.isSelected else {
            showErrorMessage(nil, "請勾選我已審閱並同意上述事項")
            return
        }
        guard (m_nextFeatureID != nil || m_dicData != nil) else {
            showErrorMessage("錯誤", "沒有下一步")
            return
        }
        self.send_confirm()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let content: String = AuthorizationManage.manage.getGoldAcception().Content
        let content: String = m_dicAcceptData?["Content"] ?? ""
        m_wvContent.loadHTMLString(content, baseURL: nil)
        m_wvContent.scrollView.bounces = false
    }
    func send_confirm() {
        self.setLoading(true)
//        let version: String = AuthorizationManage.manage.getGoldAcception().Version
        let version: String = m_dicAcceptData?["Version"] ?? ""
        postRequest("Gold/Gold0703", "Gold0703", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10015","Operate":"termsConfirm","TransactionId":transactionId,"Version":version,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "Gold0703":
            enterFeatureByID(m_nextFeatureID!, false)
        default:
            super.didResponse(description, response)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
