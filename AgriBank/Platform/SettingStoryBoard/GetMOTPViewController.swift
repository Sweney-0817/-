//
//  GetOMTP.swift
//  AgriBank
//
//  Created by ABOT on 2020/10/19.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
import WebKit


private var errorMessage = ""

let GobackMOTPseting_seque = "GobackMOTPseting_seque"

class GetMOTPViewController: BaseViewController {
    
    var m_nextFeatureID : PlatformFeatureID? = nil
    var m_dicData: [String:Any]? = nil
    var m_dicAcceptData : [String:String]? = nil
    var m_version :String = ""
    var StrMobileNo: String = ""
    
    private var barTitle:String? = nil
    
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
        
        self.send_confirm()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        let content: String = AuthorizationManage.manage.getGoldAcception().Content
        let content: String = m_dicAcceptData?["Content"] ?? ""
        m_version = m_dicAcceptData?["Version"] ?? ""
        m_wvContent.loadHTMLString(content, baseURL: nil)
        m_wvContent.scrollView.bounces = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if barTitle != nil {
            navigationController?.navigationBar.topItem?.title = barTitle
        }
    }
    
    func send_confirm() {
        self.setLoading(true)
        postRequest("COMM/COMM0114", "COMM0114", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"070702","Operate":"termsConfirm","TransactionId":self.transactionId,"Version":m_version,"uid":AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "COMM0114":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "OTP審閱條款時發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    let controller = getControllerByID(.FeatureID_MOTPSetting)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }else{
                performSegue(withIdentifier: GobackMOTPseting_seque, sender: nil)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Public
    func setBrTitle( _ barTitle:String? = nil) {
        self.barTitle = barTitle
        self.needShowBackBarItem = false
    }
    func setDataInfo( _ dataInfo:String? = nil){
        self.m_wvContent.loadHTMLString( dataInfo!, baseURL: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GobackMOTPseting_seque {
            let controller = segue.destination as! MOTPSettingViewController
            controller.StrMobileNo =  self.StrMobileNo
            controller.transactionId = tempTransactionId
        }
        
    }
    
}

