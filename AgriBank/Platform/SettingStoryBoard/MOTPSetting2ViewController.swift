//
//  MOTPSettingViewController.swift
//  AgriBank
//
//  Created by ABOT on 2020/10/19.
//  Copyright © 2020 Systex. All rights reserved.
//


import UIKit
import LocalAuthentication

private var errorMessage = ""
let MOTPResult_Segue = "GoMOTPRulSeq"
class MOTPSetting2ViewController: BaseViewController {
    
    @IBOutlet weak var labelBankName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelMobile: UILabel!
    
    @IBOutlet weak var TextFieldOTP: TextField!
    @IBOutlet weak var txtDeviceRemark: TextField!
    
    private var currentTextField:UITextField? = nil
    //var StrMobile :String = ""
    var StrMobileNo: String = ""
    
    private var loginInfo = LoginStrcture()
    private var BankCode = ""
    private var ID = ""
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated:true)
        setView()
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        setLoading(true)
        getTransactionID("08011", TransactionID_Description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    private func setView() {
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            BankCode = info.bankCode
            ID =  info.aot.uppercased()
            let start = ID.index(ID.startIndex,offsetBy: 4)
            let end = ID.index(ID.startIndex,offsetBy: 3+4)
            ID.replaceSubrange(start..<end, with: "***")
            labelID.text = ID
            labelMobile.text = StrMobileNo
        }
        
        
        labelBankName.text = BankChineseName
        
       
        
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId

            }else {
                super.didResponse(description, response)
            }
        case "COMM0810":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "簡訊OTP密碼驗證錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    let controller = getControllerByID(.FeatureID_MOTPSetting)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }else {
                setLoading(true)
                postRequest("Comm/COMM0808", "COMM0808", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"12007","Operate":"queryData","TransactionId":transactionId,"MotpDeviceID": MOTPPushAPI.getDeviceID()], true), AuthorizationManage.manage.getHttpHead(true))
            }
        case "COMM0808":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "取得Profile發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    let controller = getControllerByID(.FeatureID_MOTPSetting)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }else {
             if let data = response.object(forKey: RESPONSE_Data_KEY) as? String {
                let JsonStr = data
                let regInfo = MOTPPushAPI.addProfile(JsonStr)
                let rtn:Int32? = MOTPPushAPI.getErrorCode()
                if rtn == 0{
                    let PsAccountId =  regInfo!.pushAccount
                    let Account = regInfo?.account
                    let DeviceID = regInfo?.deviceID
                    let ClientID = regInfo?.clientID
                    let SN = regInfo?.sn
                    let PushId = regInfo?.pushID
                    let ServerUrl = regInfo?.serverURL
                    
                    // let Remark = 裝置暱稱
                    setLoading(true)
                    postRequest("Comm/COMM0809", "COMM0809", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"12005","Operate":"commitTxn","TransactionId":transactionId,"Account":Account ,"DeviceID":DeviceID ,"ClientID":ClientID ,"SN":SN ,"PushId":PushId ,"ServerUrl":ServerUrl ,"PsAccountId":PsAccountId ,"MobileType":"2","Remark":txtDeviceRemark.text], true), AuthorizationManage.manage.getHttpHead(true))
                }
               // showAlert(title: "addProfile", msg:showMsg, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                }
            }
        case "COMM0809":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "MOTP Register Token 發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    let controller = getControllerByID(.FeatureID_MOTPSetting)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }else {
                super.didResponse(description, response)
                performSegue(withIdentifier:MOTPResult_Segue, sender: nil)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    @IBAction func send_SMS(_ sender: Any) {
        if inputIsCorrect() == true {
           setLoading(true)
           postRequest("Comm/COMM0810", "COMM0810", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"12001","Operate":"queryData","TransactionId":transactionId
               ,"Group":"SMS"
               ,"OTPOD": TextFieldOTP.text!], true), AuthorizationManage.manage.getHttpHead(true))
            }
    }
    
    private func inputIsCorrect() -> Bool {
        if TextFieldOTP.text == ""{
        showErrorMessage(nil, "請輸入OTP密碼")
        return false
        }
        if txtDeviceRemark.text == ""{
        showErrorMessage(nil, "請輸入行動裝置暱稱")
        return false
        }
    
    return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == MOTPResult_Segue {
            let controller = segue.destination as! MOTPSettingResultViewController
            var barTitle:String? = nil
            barTitle = "申請OTP服務"
            var titlemsg:String? = nil
            titlemsg = "恭喜你已成功申請OTP服務!"
            controller.setBrTitle(barTitle,titlemsg)
            
        }
        
        
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - KeyBoard
    override func keyboardWillShow(_ notification:NSNotification) {
        if currentTextField == TextFieldOTP   {
            super.keyboardWillShow(notification)
        }
    }
}

