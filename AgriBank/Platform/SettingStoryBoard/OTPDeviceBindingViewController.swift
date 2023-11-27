//
//  OTPDeviceBindingViewController.swift
//  AgriBank
//
//  Created by 數位資訊部 on 2020/11/16.
//  Copyright © 2020 AFISC. All rights reserved.
//

import Foundation
private var errorMessage = ""
let OTPDeviceBindingResult_Segue = "GoOTPDeviceBindingResult"
let OTPDeviceBinding_Bank_Title = "農漁會"
let OTPDeviceBinding_CheckCode_Length:Int = 7
let OTPDeviceBinding_Binding_Success_Title = "綁定成功"
let OTPDeviceBinding_Binding_Faild_Title = "綁定失敗"
let OTPDevice2Binding_Memo = "恭喜您已成功綁定此設備！\n若想取消此設備綁定，\n請至本中心網路銀行網頁辦理。"
class OTPDeviceBindingViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnBinding: UIButton!
    @IBOutlet weak var btnOTPonline: UIButton!
    @IBOutlet weak var labelBankName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var checkCodeTextfield: TextField!
    
    @IBOutlet weak var OtpCodeTextfield: TextField!
    @IBOutlet weak var labelDescript: UILabel!
    @IBOutlet weak var m_ViewBindCode: UIView!
    @IBOutlet weak var m_ViewOTPpod: UIView!
    @IBOutlet weak var btnTypeBindOTP: UIButton!
    @IBOutlet weak var ViewBindingHeight: NSLayoutConstraint!
    @IBOutlet weak var ViewOtpHeight: NSLayoutConstraint!
    var counter = 180
    var MaxTime = 180
    var timer = Timer()
    var isPlaying = false
    var countertime = Date()//改用時間算才不會被警暫停
    private var isBinging = true     // 是否已申請綁定驗證碼
    private var isOTP = true     // 取得OTP密碼：true ,取得綁定驗證碼：false
    private var topDropView:OneRowDropDownView? = nil
    private var bindingSuccess = false
    private var resultList:[[String:String]]? = nil
    private var loginInfo = LoginStrcture() //loginInfo.account 身分證號
    private var BankCode = ""
    private var ID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoading(true)
        SetBtnColor(true)
        
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            BankCode = info.bankCode
            ID =  info.aot.uppercased()
            let start = ID.index(ID.startIndex,offsetBy: 4)
            let end = ID.index(ID.startIndex,offsetBy: 3+4)
            ID.replaceSubrange(start..<end, with: "***")
            labelID.text = ID
        }
        labelBankName.text = BankChineseName
        
        addGestureForKeyBoard()
        getTransactionID("00802", TransactionID_Description)
        //setLoading(true) // loading show
        // Do any additional setup after loading the view.
    }
    deinit {
           
           timer.invalidate()
           isPlaying = false
       }
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
     
    }
   override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BasicInfoResultViewController
        controller.setInitial(resultList, bindingSuccess, bindingSuccess ? Device2Binding_Binding_Success_Title : Device2Binding_Binding_Faild_Title, bindingSuccess ? Device2Binding_Memo : "")
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        
        switch description {
            case TransactionID_Description:
            
             if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                           transactionId = tranId
                           if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                               setLoading(true)
                               VaktenManager.sharedInstance().authenticateOperation(withSessionID: (info.Token ?? "")) { resultCode in
                                   if VIsSuccessful(resultCode) {
                                       
                                       self.postRequest("Comm/COMM0802", "COMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"00802","Operate":"KPDeviceCF","TransactionId":tranId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                                       
                                   }
                                   else {
                                       self.showErrorMessage(nil, "\(ErrorMsg_Verification_Faild) \(resultCode.rawValue)")
                                       self.setLoading(false)
                                   }
                               }
                           }
                       }
        case "COMM0802":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: UIAlert_Default_Title, msg:"此設備已綁定過！", confirmTitle: "確定", cancleTitle: nil, completionHandler: {self.navigationController?.popViewController(animated: true)}, cancelHandelr: {()})
                    
                    enterFeatureByID(.FeatureID_Home, true)
                }
            }else
            {
            //print(response)
                getTransactionID("08011", TransactionID_Description)
            }
        case "COMM0807":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                setLoading(true)
                VaktenManager.sharedInstance().associationOperation(withAssociationCode: checkCodeTextfield.text ?? "") { resultCode in
                    self.setLoading(false)
                    if VIsSuccessful(resultCode) {
                        self.bindingSuccess = true
                        self.performSegue(withIdentifier: OTPDeviceBindingResult_Segue, sender: self)
                    }
                    else {
                        self.resultList = [[String:String]]()
                        self.resultList?.append([Response_Key:Error_Title,Response_Value:"\(resultCode.rawValue)"])
                        self.performSegue(withIdentifier: OTPDeviceBindingResult_Segue, sender: self)
                    }
                }
            }
            else {
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    resultList = [[String:String]]()
                    resultList?.append([Response_Key:Error_Title,Response_Value:message])
                    self.performSegue(withIdentifier: OTPDeviceBindingResult_Segue, sender: self)
                }
            }
        case "COMM0806":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "取得OTP密碼 發生錯誤！", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    let controller = getControllerByID(.FeatureID_MOTPSetting)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }else {
                if(isPlaying)
                {
                   timer.invalidate()
                   isPlaying = false
                   counter = 180
                }
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
                isPlaying = true
           
                ViewOtpHeight.constant = 55
                m_ViewOTPpod.isHidden = false
                ViewBindingHeight.constant = 0
                m_ViewBindCode.isHidden = true
                btnOTPonline.backgroundColor = Green_Color
                btnOTPonline.setTitleColor(.white, for: .normal)
                btnBinding.backgroundColor = .white
                btnBinding.setTitleColor(.black, for: .normal)
                btnTypeBindOTP.titleLabel?.adjustsFontSizeToFitWidth = true
                btnTypeBindOTP.titleLabel?.minimumScaleFactor = 1
                //btnTypeBindOTP.titleLabel?.text = "取得綁定驗證碼"
                btnTypeBindOTP.setTitle("取得綁定驗證碼", for: .normal)
                isOTP = false
                super.didResponse(description, response)
                //performSegue(withIdentifier:OTPDeviceBindingResult_Segue, sender: nil)
            }
        case "COMM0805":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "取得綁定碼 發生錯誤！", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    let controller = getControllerByID(.FeatureID_MOTPSetting)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }else {
                if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                    if let KeyWSCode = data["KeyWSCode"] as? String {
                        checkCodeTextfield.text = KeyWSCode
                    }
                }
                SetBtnColor(true)
                super.didResponse(description, response)
                //performSegue(withIdentifier:MOTPResult_Segue, sender: nil)
            }
        
            
        default: super.didResponse(description, response)
            
        }
    }

    func UpdateTimer() {
       if (counter == 0 ){
           counter = 180
           timer.invalidate()
           isPlaying = false
           return
       }
       //counter = counter - 1
       let now = Date()
       let SecInfo = Int(now.timeIntervalSince(countertime))
       counter = MaxTime - SecInfo
    
       if pushReceiveFlag == "OTP"{
    
            let pushString = pushResultList![AnyHashable("msg")] as? String
             
            do{
                let jsonDic = try JSONSerialization.jsonObject(with: (pushString?.data(using: .utf8)!)!, options: .mutableContainers) as? [String:Any]
                //showErrorMessage("CONT",jsonDic!["CONT"] as? String)
                if let CONT = jsonDic!["CONT"] as? String
                {
                    do{
                        let jsonCOND = try JSONSerialization.jsonObject(with: (CONT.data(using: .utf8)!), options: .mutableContainers) as? [String:Any]
                        //showErrorMessage("OD",jsonCOND!["OD"] as? String)
                        OtpCodeTextfield.text = jsonCOND!["OD"] as? String
                        counter = 0
                    }catch {
                        showErrorMessage("OD","error")
                    }
                }
            }
            catch {
                       showErrorMessage("msg","error")
                   }
        }
    }

    private func inputIsCorrect() -> Bool {
       
        if (checkCodeTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(checkCodeTextfield.placeholder ?? "")")
            return false
        }
        return true
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == topTextfield {
//            if bankList.count > 0 {
//                addPickerView(textField)
//            }
//            textField.tintColor = .clear
//        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = (textField.text?.count)! - range.length + string.count
        var maxLength = 0
        switch textField {

        case checkCodeTextfield:
            maxLength = DeviceBinding_CheckCode_Length
            
        default: break
        }
        
        if newLength <= maxLength {
            return true
        }
        else {
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func clickBindingBtn(_ sender: Any) {
      
        self.setLoading(true)
        if isBinging {
            if inputIsCorrect() {
              if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                VaktenManager.sharedInstance().authenticateOperation(withSessionID: info.Token ?? ""){ resultCode in
                    if VIsSuccessful(resultCode) {
                        if let info1 = AuthorizationManage.manage.GetLoginInfo(){
                            //let bankCode = info.bankCode
                            let id = info1.aot.uppercased()
                            self.postRequest("COMM/COMM0807", "COMM0807", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08011","Operate":"queryData","TransactionId":self.transactionId,"ID_DATA":id,"ASSOCIATIONCODE":self.checkCodeTextfield.text!], true), AuthorizationManage.manage.getHttpHead(true))
                        }
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_Verification_Faild) \(resultCode.rawValue)")
                        self.setLoading(false)
                    }
                }
               }
            }
        }
            else{
                if isOTP  //取得OTP密碼
                {
                    //setLoading(true)
                    self.postRequest("Comm/COMM0806", "COMM0806", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08011","Operate":"queryData","TransactionId":self.transactionId,"MotpDeviceID": MOTPPushAPI.getDeviceID() ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                }else   //取得綁定驗證碼
                {
                    setLoading(true)
                    postRequest("Comm/COMM0805", "COMM0805", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08011","Operate":"commitTxn","TransactionId":transactionId,"OTPOD": self.OtpCodeTextfield.text!], true), AuthorizationManage.manage.getHttpHead(true))
                }
                
            }

       
    }
    
    @IBAction func ActionBinding(_ sender: Any) {
        
         SetBtnColor(true)
    }
    
    @IBAction func ActionOTPonline(_ sender: Any) {

         SetBtnColor(false)
    }
    // MARK: - Private
    private func SetBtnColor(_ isBinging:Bool) {
        self.isBinging = isBinging
        if isBinging {
            ViewOtpHeight.constant = 0
            m_ViewOTPpod.isHidden = true
            ViewBindingHeight.constant = 53
            m_ViewBindCode.isHidden = false
            labelDescript.text = "已經由行動達人、網路銀行或臨櫃申請綁定驗證碼。"
            //labelDescript.textColor = .red
            btnBinding.backgroundColor = Green_Color
            btnBinding.setTitleColor(.white, for: .normal)
            btnOTPonline.backgroundColor = .white
            btnOTPonline.setTitleColor(.black, for: .normal)
            //btnTypeBindOTP.titleLabel?.text = "綁      定"
            btnTypeBindOTP.setTitle("綁      定", for: .normal)
        }
        else {
            ViewOtpHeight.constant = 0
            m_ViewOTPpod.isHidden = true
            ViewBindingHeight.constant = 0
            m_ViewBindCode.isHidden = true
            btnOTPonline.backgroundColor = Green_Color
            btnOTPonline.setTitleColor(.white, for: .normal)
            labelDescript.text = "請留意OTP密碼會推播至手機，並自動填至OTP密碼欄位。"
            //labelDescript.textColor = .red
            btnBinding.backgroundColor = .white
            btnBinding.setTitleColor(.black, for: .normal)
            btnTypeBindOTP.titleLabel?.adjustsFontSizeToFitWidth = true
            btnTypeBindOTP.titleLabel?.minimumScaleFactor = 1
            //btnTypeBindOTP.titleLabel?.text = "取得OTP密碼"
            btnTypeBindOTP.setTitle("取得OTP密碼", for: .normal)
        }
    }
}

