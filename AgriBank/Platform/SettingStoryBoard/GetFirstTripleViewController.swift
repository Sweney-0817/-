//
//  GetFirstTripleViewController.swift
//  AgriBank
//
//  Created by 數位資訊部 on 2020/6/18.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
import WebKit

let FirstTriple_AcpSeq = "GoFirstTripleList"
let FirstTriple_BackSeq = "GoBackFirstTriple"
 private var errorMessage = ""

class GetFirstTripleViewController: BaseViewController {
     var m_nextFeatureID : PlatformFeatureID? = nil
        var m_dicData: [String:Any]? = nil
        var m_dicAcceptData : [String:String]? = nil
        var m_version :String = ""
        
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
            getTransactionID("09008", TransactionID_Description)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            if barTitle != nil {
                navigationController?.navigationBar.topItem?.title = barTitle
            }
        }
        
        func send_confirm() {
            self.setLoading(true)
            postRequest("QR/QR1002", "QR1002", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10002","Operate":"termsConfirm","TransactionId":transactionId,"Version":m_version,"uid":AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
        }
        override func didResponse(_ description:String, _ response: NSDictionary) {
            self.setLoading(false)
            switch description {
            case "QR1002":
                if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                    if let message = response.object(forKey: ReturnMessage_Key) as? String {
                        errorMessage = message
                        showAlert(title: "振興條款時發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    }
                }
                else{
                  // performSegue(withIdentifier: FastLogIn_AcpSeq, sender: nil)
                    let controller = getControllerByID(.FeatureID_Triple)
                    navigationController?.pushViewController(controller, animated: true)
                }
                //                else {
                //                    super.didResponse(description, response)
                //                }
                case TransactionID_Description:
                if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                    transactionId = tranId
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
           if segue.identifier == FirstTriple_BackSeq {
               
           }
        }
    }
