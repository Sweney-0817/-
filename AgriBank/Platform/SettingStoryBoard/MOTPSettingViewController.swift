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
let GetMOTP_Segue = "GoGetMOTP_Segue"
let GOSMS_Segue = "GOSMS_Segue"
class MOTPSettingViewController: BaseViewController {
    
    @IBOutlet weak var labelBankName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelMobile: UILabel!
    
    @IBOutlet weak var BtnShowInfo: UIButton!
    @IBOutlet weak var labelEmail: UILabel!
    
    @IBOutlet weak var ImgEyeEmail: UIImageView!
    @IBOutlet weak var ImgEyeMobile: UIImageView!
    var ArContent: [String:String]? = nil
    var StrMobile: String = ""
    var StrMobileNo: String = ""
    var OTPregistered: String = ""
    
    var OMobile: String = ""
    var OEmail: String = ""
    var Oshow: String = "0"
    
    private var loginInfo = LoginStrcture()
    private var BankCode = ""
    private var ID = ""
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = AuthorizationManage.manage.GetLoginInfo(){
            BankCode = info.bankCode
            ID =  info.aot.uppercased()
            let start = ID.index(ID.startIndex,offsetBy: 4)
            let end = ID.index(ID.startIndex,offsetBy: 3+4)
            ID.replaceSubrange(start..<end, with: "***")
            labelID.text = ID
        }
        
        labelBankName.text = BankChineseName
        
        getTransactionID("08001", TransactionID_Description)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                tempTransactionId = tranId
                setLoading(true)
                postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":tranId], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
        case "USIF0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let email = data["EMAIL"] as? String {
                   // labelEmail.text = email.trimmingCharacters(in: .whitespaces)
                    OEmail = email
                    var Email = email.trimmingCharacters(in: .whitespaces)
                    if (Email.count != 0) && (Email.count >= 14 ){
                    let start = Email.index(Email.startIndex,offsetBy: 6)
                    let end = Email.index(Email.startIndex,offsetBy: 8+6)
                    
                    Email.replaceSubrange(start..<end, with: "********")
                    }
                    labelEmail.text = Email
                }
                if let mobilePhone = data["MPHONE"] as? String {
                    OMobile = mobilePhone
                    var phone = mobilePhone.trimmingCharacters(in: .whitespaces)
                    if (phone.count != 0) && (phone.count >= 7){
                    let start = phone.index(phone.startIndex,offsetBy: 4)
                    let end = phone.index(phone.startIndex,offsetBy: 4+3)
                   
                    phone.replaceSubrange(start..<end, with: "***")
                    }
                    labelMobile.text = phone  + "(簡訊通知用)" //mobilePhone.trimmingCharacters(in: .whitespaces) + "(簡訊通知用)"
                    StrMobileNo = mobilePhone.trimmingCharacters(in: .whitespaces)
                    StrMobile = labelMobile.text!
                }
                
                setLoading(true)
                self.postRequest("COMM/COMM0113", "COMM0113", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"12002","Operate":"getTerms","TransactionId":tempTransactionId,"uid": AgriBank_DeviceID,"MotpDeviceID": MOTPPushAPI.getDeviceID() ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
            }
            
        case "COMM0811":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                    showAlert(title: "取得簡訊密碼時發生錯誤", msg:errorMessage, confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                    let controller = getControllerByID(.FeatureID_MOTPSetting)
                    navigationController?.pushViewController(controller, animated: true)
                }
            }else {
                performSegue(withIdentifier: GOSMS_Segue, sender: nil)
            }
        case "COMM0113" :
            if let data = response.object(forKey: ReturnData_Key) as? [String:String] {
                if let strRegistered = data["Registered"]{
                    OTPregistered = strRegistered
                }
                if (data["Read"] == "N") {
                    if let data = response.object(forKey: ReturnData_Key) as? [String:String]{
                        ArContent = data
                    }
                    performSegue(withIdentifier: GetMOTP_Segue, sender: nil)
                }
            }  else {
                super.didResponse(description, response)
            }
        default: super.didResponse(description, response)
        }
    }
    
    @IBAction func getSMS(_ sender: Any) {
       // performSegue(withIdentifier: GOSMS_Segue, sender: nil)
        if inputIsCorrect(){
            setLoading(true)
            postRequest("Comm/COMM0811", "COMM0811", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"12003","Operate":"queryData","TransactionId":tempTransactionId,"MPHONE":StrMobileNo], true), AuthorizationManage.manage.getHttpHead(true))
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == GetMOTP_Segue {
            let controller = segue.destination as! GetMOTPViewController
            var barTitle:String? = nil
            barTitle = "OTP服務約定條款"
            controller.setBrTitle(barTitle)
            controller.m_dicAcceptData = ArContent
            controller.m_nextFeatureID = curFeatureID
            controller.transactionId = tempTransactionId
            controller.StrMobileNo =  self.StrMobileNo
            //取消上一頁，以防transactionId失效 112/6 modfiy by sweney
            controller.needShowBackBarItem = false
            curFeatureID = nil
            tempTransactionId = ""
        }
        if segue.identifier == GOSMS_Segue {
            let controller = segue.destination as! MOTPSetting2ViewController
            controller.transactionId = tempTransactionId
            //controller.StrMobile =  self.StrMobile
            controller.StrMobileNo =  self.StrMobileNo
        }
        
    }
    
    @IBAction func BtnShowClick(_ sender: Any) {
        if Oshow == "1" {
            var Email = OEmail.trimmingCharacters(in: .whitespaces)
            if (Email.count != 0) && (Email.count >= 14){
            let start = Email.index(Email.startIndex,offsetBy: 6)
            let end = Email.index(Email.startIndex,offsetBy: 8+6)
           
                Email.replaceSubrange(start..<end, with: "********")}
            labelEmail.text = Email
            ImgEyeEmail.image = UIImage(named:"mask114")
       
            var phone = OMobile.trimmingCharacters(in: .whitespaces)
            if (phone.count != 0 ) && (phone.count >= 7){
            let startp = phone.index(phone.startIndex,offsetBy: 4)
            let endp = phone.index(phone.startIndex,offsetBy: 4+3)
           
            phone.replaceSubrange(startp..<endp, with: "***")
            }
            labelMobile.text = phone  + "(簡訊通知用)" //mobilePhone.trimmingCharacters(in: .whitespaces) + "(簡訊通知用)"
            ImgEyeMobile.image = UIImage(named:"mask114")
            Oshow = "0"
        }else {
                self.labelMobile.text = self.OMobile  + "(簡訊通知用)"
            ImgEyeMobile.image = UIImage(named:"unmask114_1")
                self.labelEmail.text = self.OEmail
            ImgEyeEmail.image = UIImage(named:"unmask114_1")
            Oshow = "1"
            } 
        
    }
    private func inputIsCorrect() -> Bool {
        if StrMobileNo == ""{
        showErrorMessage(nil, "未約定行動電話號碼，請洽原開戶單位辦理或以網路銀行以晶片金融卡申請")
        return false
        }
        var profileArray: [Any]?
        profileArray = MOTPPushAPI.getProfileList()
        //判斷是否申請過
        //profileArray:手機紀錄
        //OTPregistered ：資料庫註冊記錄
        if profileArray == nil || profileArray!.count == 0 {
            return true
        }else
        {
            if OTPregistered == "Y"
            {
                showErrorMessage(nil, "此裝置已申請過OTP服務！")
                return false
            }
            else
            {
                //未註冊（但count==0)，表示已被註銷(被從另一台註銷）所可以再申請
                return true
            }
            
        }
    
    }
    
}

