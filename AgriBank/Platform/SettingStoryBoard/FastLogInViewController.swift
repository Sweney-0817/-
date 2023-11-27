//
//  FastLogInViewController.swift
//  AgriBank
//
//  Created by ABOT on 2019/11/4.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit
import LocalAuthentication

 let GetFastLogIn_Segue = "GoGetFastLogInSeq"
let  GoTouchID_Deque = "GoTouchIDSeting"
let  GoGraphic_Seque = "GoGraphicSeting"
var FastLogIn_Type:String = "0" // 0:pod 1:touchid/faceid 2:picture

class FastLogInViewController: BaseViewController {
    
    @IBOutlet weak var TouchFaceIDSwitch: UISwitch!
    @IBOutlet weak var PanterSwitch: UISwitch!
     
    var ArContent: [String:String]? = nil
     private var loginInfo = LoginStrcture()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            let  bCode = info.bankCode
            let  bAccount = info.aot
            var wkFastLogInFlag = "0"
            wkFastLogInFlag = SecurityUtility.utility.readFileByKey( SetKey: bCode   , setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)")  as? String ?? "0"
            let  wkLogInCode = wkFastLogInFlag.substring(from: 0, length: 1)
            let wkID = wkFastLogInFlag.substring(from: 1)
            if wkID.localizedUppercase == bAccount.localizedUppercase {
            switch wkLogInCode
            {
            case "1":
                TouchFaceIDSwitch.isOn = true
                PanterSwitch.isOn = false
            case "2":
                TouchFaceIDSwitch.isOn = false
                PanterSwitch.isOn = true
            default:
                TouchFaceIDSwitch.isOn = false
                PanterSwitch.isOn = false
            }
            } else {
                TouchFaceIDSwitch.isOn = false
                PanterSwitch.isOn = false
            }
        }
            getTransactionID("10001", TransactionID_Description)
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            let  bCode = info.bankCode
            let  bAccount = info.aot
            var wkFastLogInFlag = "0"
            wkFastLogInFlag = SecurityUtility.utility.readFileByKey( SetKey: bCode  , setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)")  as? String ?? "0"
            let  wkLogInCode = wkFastLogInFlag.substring(from: 0, length: 1)
            let wkID = wkFastLogInFlag.substring(from: 1)
            if wkID.localizedUppercase == bAccount.localizedUppercase {
            switch wkLogInCode
            {
            case "1":
                TouchFaceIDSwitch.isOn = true
                PanterSwitch.isOn = false
            case "2":
                TouchFaceIDSwitch.isOn = false
                PanterSwitch.isOn = true
            default:
                TouchFaceIDSwitch.isOn = false
                PanterSwitch.isOn = false
            }
            }else { TouchFaceIDSwitch.isOn = false
                PanterSwitch.isOn = false}
            
        }
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            
                if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                    tempTransactionId = tranId
                    self.postRequest("COMM/COMM0106", "COMM0106", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"getTerms","TransactionId":tempTransactionId,"uid":AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))
                }
            else {
                super.didResponse(description, response)
            }
  //0104 go with accept page
//        case "COMM0104":
//            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
//                if returnCode == ReturnCode_Success {
//                    didResponse(description, response)
//                    switch FastLogIn_Type{
//                    case "1":
//                        TouchFaceIDSwitch.isOn = true
//                        PanterSwitch.isOn = false
//                    case "2":
//                        TouchFaceIDSwitch.isOn = false
//                        PanterSwitch.isOn = true
//                    }
//
//                    //寫入目前快登項目 0:pod 1:touchid/faceid 2:picture(1 byte)
//                    SecurityUtility.utility.writeFileByKey(FastLogIn_Type, SetKey:File_LogInType_Key , setEncryptKey: SEA)
//                    //write fasr login info
//                    if let info = AuthorizationManage.manage.GetLoginInfo(){
//                        let  bCode = info.bankCode
//                        let  bid   = info.account
//                SecurityUtility.utility.writeFileByKey(bid, SetKey: File_Account_Key, setEncryptKey: SEA)
//                 //When user login successful app will auto save bankcode, so didn't do this
//                  // SecurityUtility.utility.writeFileByKey(bCode, SetKey: File_BankCode_Key, setEncryptKey: SEA)
//                    }
//                }
//                else if returnCode == "E_COMM0401_02" {
//                    let message = (response.object(forKey: ReturnMessage_Key) as? String) ?? ""
//                    let alert = UIAlertController(title: UIAlert_Default_Title, message: message, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: Cancel_Title, style: .default) { _ in
//                        DispatchQueue.main.async {
//                            self.getImageConfirm()
//                        }
//                    })
//
//                }else{
//                    TouchFaceIDSwitch.isOn = false
//                    // unknow error
//                }
//
//            }
//            else {
//                super.didResponse(description, response)
//            }
    
         
        case "COMM0106" :
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
                if (data["Read"] == "N") {
                    if let data = response.object(forKey: ReturnData_Key) as? [String:String]{
                       ArContent = data 
                    }
                    transactionId = tempTransactionId
                    performSegue(withIdentifier: GetFastLogIn_Segue, sender: nil)
                }
            }
        case "COMM0109":
            // open touchid status
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
            SecurityUtility.utility.writeFileByKey("0" + bid , SetKey: bCode , setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
            }
        default: super.didResponse(description, response)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GetFastLogIn_Segue {
            let controller = segue.destination as! GetFastLogInViewController
            var barTitle:String? = nil
            barTitle = "快速登入約定條款"
            controller.setBrTitle(barTitle)
            controller.m_dicAcceptData = ArContent
            controller.m_nextFeatureID = curFeatureID
            controller.transactionId = tempTransactionId
            curFeatureID = nil
            tempTransactionId = ""
        }else if segue.identifier == GoTouchID_Deque {
            let controller = segue.destination as! TouchIDLogInViewController
            var barTitle:String? = nil
            barTitle = "設定快速登入指紋/臉部辨識"
            controller.setBrTitle(barTitle)
        }else if segue.identifier == GoGraphic_Seque {
            let controller = segue.destination as! FastLogInGraphicView
            var barTitle:String? = nil
            barTitle = "設定快速登入圖形密碼"
            controller.setBrTitle(barTitle)
        }
        
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickTouchSwitch(_ sender: Any) {
        var BoolCheckTouchYN = 0
        
        let context = LAContext()
        // First check if we have the needed hardware support.
        var error: NSError?
        if #available(iOS 9.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                BoolCheckTouchYN = 1
            } else {
                 BoolCheckTouchYN = 0
            }
        }
       
        if TouchFaceIDSwitch.isOn {
            if BoolCheckTouchYN == 1 {
                       performSegue(withIdentifier:GoTouchID_Deque, sender: nil)
            }else{
                let alert = UIAlertView(title: UIAlert_Default_Title, message: "裝置不支援指紋/臉部辨識快速登入", delegate: nil, cancelButtonTitle:Determine_Title)
                alert.show()
                    TouchFaceIDSwitch.isOn = false}
            }
              
        else {
            //TouchFaceIDSwitch.isOn = false
                if (PanterSwitch.isOn == false){
                    let message = "請確認是否要停用快速登入？"
                    //show del msg
                    let confirmHandler : ()->Void = {
                        
                    self.setLoading(true)
                        self.postRequest("Comm/COMM0109", "COMM0109", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","TransactionId":self.tempTransactionId,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))}
                    let cancelHandler : ()->Void = {
                        self.TouchFaceIDSwitch.isOn = true
                    }
                    showAlert(title: "注意", msg: message , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
                    
            }}
    }
    // MARK: - StoryBoard Touch Event
    @IBAction func clickPanterSwitch(_ sender: Any) {
        
            if PanterSwitch.isOn {
                performSegue(withIdentifier:GoGraphic_Seque, sender: nil)
            }
            else {
                if (TouchFaceIDSwitch.isOn == false){
                    let message = "請確認是否要停用快速登入？"
                    //show del msg
                    let confirmHandler : ()->Void = {
                        
                        self.setLoading(true)
                        self.postRequest("Comm/COMM0109", "COMM0109", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"10001","Operate":"termsConfirm","TransactionId":self.tempTransactionId,"uid": AgriBank_DeviceID], true), AuthorizationManage.manage.getHttpHead(true))}
                    let cancelHandler : ()->Void = {
                        self.TouchFaceIDSwitch.isOn = true
                    }
                    showAlert(title: "注意", msg: message , confirmTitle: "確認送出", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
                    
                }}
    }
   
}
