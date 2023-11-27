//
//  AcceptRulesViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
import WebKit

class AcceptRulesViewController: BaseViewController {
    var m_nextFeatureID : PlatformFeatureID? = nil
    var m_dicData : [String:String]? = nil
    private var gesture:UIPanGestureRecognizer? = nil
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
        guard m_nextFeatureID != nil else {
            showErrorMessage("錯誤", "沒帶FeatureID")
            return
        }
        self.send_confirm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let lButton = UIButton(type: .custom)
        lButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
        lButton.addTarget(self, action: #selector(clickBackBarItem), for: .touchUpInside)
        lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .normal)
        lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .highlighted)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lButton)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = nil
        gesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture))
        navigationController?.view.addGestureRecognizer(gesture!)

        let content: String = m_dicData?["Content"] ?? ""
        m_wvContent.loadHTMLString(content, baseURL: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if gesture != nil {
            navigationController?.view.removeGestureRecognizer(gesture!)
        }
        super.viewWillDisappear(animated)
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
    func HandlePanGesture(_ sender: UIPanGestureRecognizer) {}

}
