//
//  TouchIDLogInViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/11/5.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit
import WebKit

let GoFastLogInResult = "GoFastLogInResult"
class TouchIDLogInViewController: BaseViewController {

    var m_nextFeatureID : PlatformFeatureID? = nil
    var m_dicData: [String:Any]? = nil
    var m_dicAcceptData : [String:String]? = nil
    var m_version :String = ""
    
   var barTitle:String = ""
    
    @IBOutlet var m_wvContent: WKWebView!
    @IBOutlet var m_btnCheck: UIButton!
    @IBAction func m_btnCheckClick(_ sender: Any) {
        m_btnCheck.isSelected = !m_btnCheck.isSelected
    }
    
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        guard m_btnCheck.isSelected else {
            showErrorMessage(nil, "請勾選我同意農漁行動達人指紋/臉部辨識身分驗證及服務條款")
            return
        }
  let wkLogInType = "0"
    //wkLogInType = SecurityUtility.utility.readFileByKey( SetKey: bCode  , setDecryptKey: SEA)  as? String ?? "0"
       //when fast login flg is disable ,send 01014 work
        if( wkLogInType == "0"){
           self.send_confirm()
        }
      
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        FastLogIn_Type = "1"  // 0:pod  *1:touchid/faceid 2:picture
        getTransactionID("01014", TransactionID_Description)
        // Do any additional setup after loading the view.
        //        let content: String = AuthorizationManage.manage.getGoldAcception().Content
        let wkContent = "<p align=\"center\"><strong>服務條款說明</strong></p><br><p>為了您的使用權益，請詳閱以下條款後，勾選同意以繼續申請<br>"
        let content: String = wkContent
        
        m_wvContent.loadHTMLString(content, baseURL: nil)
        m_wvContent.scrollView.bounces = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if barTitle != "" {
            navigationController?.navigationBar.topItem?.title = barTitle
        }
    }
    // MARK: - Public
    func setBrTitle( _ barTitle:String? = nil) {
        self.barTitle = barTitle!
        self.needShowBackBarItem = true
    }
    func send_confirm() {
        self.setLoading(true)
                    if let info = AuthorizationManage.manage.GetLoginInfo(){
                        let  bCode = info.bankCode
        
                        postRequest("Comm/COMM0104", "COMM0104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01014","Operate":"commitTxn","TransactionId":transactionId,"KINBR":bCode,"appId": AgriBank_AppID,"Version": AgriBank_Version,"appUid": AgriBank_AppUid,"uid": AgriBank_DeviceID,"model": AgriBank_DeviceType,"systemVersion": AgriBank_SystemVersion,"codeName": AgriBank_DeviceType,"tradeMark": AgriBank_TradeMark,"GraphPWD":""], true), AuthorizationManage.manage.getHttpHead(true))
                    }
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
       
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                tempTransactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0104":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    
                
                    //write fasr login info
                    if let info = AuthorizationManage.manage.GetLoginInfo(){
                        let  bCode = info.bankCode
                        let  bid   = info.aot
                       // SecurityUtility.utility.writeFileByKey(bid, SetKey: File_Account_Key, setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                        //2020-10 資安檢測修正 by sweney
                        //將Accounte改存到keychain
                        //=====================================
                          KeychainManager.keyChianDelete(identifier: File_Account_Key)
                          //KeychainManager.keyChainSaveData(data:  SecurityUtility.utility.AES256Encrypt(bid, "\(SEA1)\(SEA2)\(SEA3)"), withIdentifier: File_Account_Key)
                        KeychainManager.keyChainSaveData(data:bid, withIdentifier: File_Account_Key)
                       //==========================================
                        //寫入目前快登項目 0:pod 1:touchid/faceid 2:picture(1 byte)
                        SecurityUtility.utility.writeFileByKey(FastLogIn_Type + bid , SetKey: bCode , setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
                        //When user login successful app will auto save bankcode, so didn't do this
                        // SecurityUtility.utility.writeFileByKey(bCode, SetKey: File_BankCode_Key, setEncryptKey: SEA)
                        //GoFastLogInResult
                         super.didResponse(description, response)
                            performSegue(withIdentifier:GoFastLogInResult, sender: nil)

                    }
                }
                
                   else{
                    let message = (response.object(forKey: ReturnMessage_Key) as? String) ?? ""
                    let alert = UIAlertController(title: UIAlert_Default_Title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: Cancel_Title, style: .default) { _ in
                        DispatchQueue.main.async {
                            self.getImageConfirm()
                        }
                    })
                }
                
            }
            else {
                super.didResponse(description, response)
            }
        default: super.didResponse(description, response)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GoFastLogInResult {
            let controller = segue.destination as! FastLogInResultViewController
            var barTitle:String? = nil
            barTitle = "設定快速登入指紋/臉部辨識"
            var titlemsg:String? = nil
            titlemsg = "設定成功，下次可使用指紋/臉部辨識快速登入!"
            controller.setBrTitle(barTitle,titlemsg)
        }
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
}
