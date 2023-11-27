//
//  BasicInfoChangeViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let GoBaseInfoChangeResult_Segue = "GoBaseInfoChangeResult"

class BasicInfoChangeViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobilePhoneLabel: UILabel!
    @IBOutlet weak var telePhoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailTextfield: TextField!        // 新Email
    @IBOutlet weak var mobliePhoneTextfield: TextField!  // 新行動電話
    @IBOutlet weak var telePhoneTextfield: TextField!    // 新電話號碼
    @IBOutlet weak var addressTextfield: TextField!      // 新聯絡地址
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var teleAreaCodeTextfield: TextField! // 新區碼
    @IBOutlet weak var postalCodeTextfield: TextField!   // 新郵遞區號
    private var currentTextField:UITextField? = nil
    private var resultList:[[String:String]]? = nil
    private var emailFG = ""      // input需要的「E-MAIL  通知狀態」
    private var funcd = ""        // input需要的「變更項目」
    private var teleAreaCode = "" // 原區碼
    private var telePhone = ""    // 原電話號碼
    private var postalCode = ""   // 原郵遞區號
    private var address = ""      // 原聯絡地址
    private var oemail = ""
    private var omobile = ""
    private var changeSuccess = false
    // add temp by sweney 112/6
    private var MAILFG = ""
    private var MSG1 = ""
    private var MSG2 = ""
    private var MSG3 = ""
    
    
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        if !AuthorizationManage.manage.getChangeBaseInfoStaus() {
            showErrorMessage(nil, ErrorMsg_NoAuth)
            return false
        }
//        if emailTextfield.text!.isEmpty && mobliePhoneTextfield.text!.isEmpty && telePhoneTextfield.text!.isEmpty && teleAreaCodeTextfield.text!.isEmpty && postalCodeTextfield.text!.isEmpty && addressTextfield.text!.isEmpty {
//            showErrorMessage(nil, ErrorMsg_NeedChangeOne)
//            return false
//        }
        if emailTextfield.text!.isEmpty && telePhoneTextfield.text!.isEmpty && teleAreaCodeTextfield.text!.isEmpty && postalCodeTextfield.text!.isEmpty && addressTextfield.text!.isEmpty {
                   showErrorMessage(nil, ErrorMsg_NeedChangeOne)
                   return false
               }
        if (telePhoneTextfield.text!.isEmpty && !teleAreaCodeTextfield.text!.isEmpty) || (!telePhoneTextfield.text!.isEmpty && teleAreaCodeTextfield.text!.isEmpty) {
            showErrorMessage(nil, ErrorMsg_Telephone)
            return false
        }
        if (postalCodeTextfield.text!.isEmpty && !addressTextfield.text!.isEmpty) || (!postalCodeTextfield.text!.isEmpty && addressTextfield.text!.isEmpty) {
            showErrorMessage(nil, ErrorMsg_Address)
            return false
        }
        if !DetermineUtility.utility.isValidEmail(emailTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Invalid_Email)
            return false
        }
        
        return true
    }
    
    func setDiableTextfield(_ title:String, _ textfield:TextField) {
        textfield.text = title
        textfield.isEnabled = false
//        textfield.background = nil
//        textfield.backgroundColor = Disable_Color
//        textfield.borderStyle = .line
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setShadowView(bottomView, .Top)
        getTransactionID("08001", TransactionID_Description)
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        if !AuthorizationManage.manage.getChangeBaseInfoStaus() {
            setDiableTextfield("", emailTextfield)
            setDiableTextfield("", mobliePhoneTextfield)
            setDiableTextfield(telePhone, telePhoneTextfield)
            setDiableTextfield(teleAreaCode, teleAreaCodeTextfield)
            setDiableTextfield(telePhone, telePhoneTextfield)
            setDiableTextfield(address, addressTextfield)
            setDiableTextfield(postalCode, postalCodeTextfield)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BasicInfoResultViewController
        controller.setInitial(resultList, changeSuccess, changeSuccess ? Change_Successful_Title : Change_Faild_Title, nil)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "USIF0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let email = data["EMAIL"] as? String {
                   // emailLabel.text = email.trimmingCharacters(in: .whitespaces)
                    var Email = email.trimmingCharacters(in: .whitespaces)
                    if ( email.count  != 0) && ( email.count >= 14 ){
                    let start = Email.index(Email.startIndex,offsetBy: 6)
                    let end = Email.index(Email.startIndex,offsetBy: 6+8)
                   
                    Email.replaceSubrange(start..<end, with: "********")
                    }
//                    else{
//                        Email = Email.substring(from: 0 ,length: 6) + "********"
//                    }
                    emailLabel.text = Email
                    oemail = email
                }
                if let mobilePhone = data["MPHONE"] as? String {
                   // mobilePhoneLabel.text = mobilePhone.trimmingCharacters(in: .whitespaces)
                    var phone = mobilePhone.trimmingCharacters(in: .whitespaces)
                    if (phone.count != 0 ) && (phone.count >= 7 ){
                    let start = phone.index(phone.startIndex,offsetBy: 4)
                    let end = phone.index(phone.startIndex,offsetBy: 3+4)
                  
                        phone.replaceSubrange(start..<end, with: "***")}
                    mobilePhoneLabel.text = phone
                    omobile = mobilePhone
                }
                if let telePhone = data["TELNO1"] as? String, let teleAreaCode = data["AREA1"] as? String {
                    var phone = telePhone.trimmingCharacters(in: .whitespaces)
                    let code = teleAreaCode.trimmingCharacters(in: .whitespaces)
                    if phone.count >= 6{
                    let start = phone.index(phone.startIndex,offsetBy: 3)
                    let end = phone.index(phone.startIndex,offsetBy: 3+3)
                    phone.replaceSubrange(start..<end, with: "***")
                    }
//                    else{
//                        phone = phone.substring(from: 0,length: 3) + "***"
//                    }
                    telePhoneLabel.text = "\(code)-\(phone)"
                    self.teleAreaCode = teleAreaCode.trimmingCharacters(in: .whitespaces)
                    self.telePhone = telePhone.trimmingCharacters(in: .whitespaces)
                }
                if let address = data["ADR2"] as? String, let postalCode = data["ZIPCD2"] as? String {
                    let addr = address.trimmingCharacters(in: .whitespaces)
                    let code = postalCode.trimmingCharacters(in: .whitespaces)
                    
                    //  let start = addr.index(addr.startIndex,offsetBy: 6)
                   // let end = addr.index(addr.startIndex,offsetBy: 8+6)
                   // addr.replaceSubrange(start..<end, with: "********")
                    addressLabel.text = "\(code) \(addr.substring(from: 0,length: 6) + "********")"
                    self.address = address.trimmingCharacters(in: .whitespaces)// addr
                    self.postalCode = postalCode.trimmingCharacters(in: .whitespaces)//code
                }
                if let flage = data["EMAILFG"] as? String {
                    emailFG = flage
                }
                if let mailfg = data["MAILFG"] as? String {
                    MAILFG = mailfg
                }
                if let msg1 = data["MSG1"] as? String {
                    MSG1 = msg1
                }
                if let msg2 = data["MSG2"] as? String {
                    MSG2 = msg2
                }
                if let msg3 = data["MSG3"] as? String {
                    MSG3 = msg3
                }
                 
                if let member = data["MEMBER"] as? String {
                    // 會員別 = 0 為非會員 其他則為會員
                    if member == "0" {
                        funcd = "88"
                        teleAreaCodeTextfield.isHidden = false
                        telePhoneTextfield.isHidden = false
                        addressTextfield.isHidden = false
                        postalCodeTextfield.isHidden = false
                    }
                    else {
                        funcd = "89"
                        if AuthorizationManage.manage.getChangeBaseInfoStaus() {
                            setDiableTextfield(teleAreaCode, teleAreaCodeTextfield)
                            setDiableTextfield(telePhone, telePhoneTextfield)
                            setDiableTextfield(address, addressTextfield)
                            setDiableTextfield(postalCode, postalCodeTextfield)
                            teleAreaCodeTextfield.isHidden = true
                            telePhoneTextfield.isHidden = true
                            addressTextfield.isHidden = true
                            postalCodeTextfield.isHidden = true
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("Usif/USIF0101", "USIF0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"queryData","TransactionId":tranId], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "USIF0102":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                if let responseData = response.object(forKey: ReturnData_Key) as? [[String:String]] {
                    resultList = responseData
                }
                changeSuccess = true
            }
            else {
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    resultList = [[String:String]]()
                    resultList?.append([Response_Key:Error_Title,Response_Value:message])
                }
            }
            performSegue(withIdentifier: GoBaseInfoChangeResult_Segue, sender: nil)
            
        default: super.didResponse(description, response)
        }
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickChangeBtn(_ sender: Any) {
        if inputIsCorrect() {
            setLoading(true)
            let email:String = emailTextfield.text!.isEmpty ? oemail : emailTextfield.text!
            //chiu 1090819
         //   let mobliePhone:String = mobliePhoneTextfield.text!.isEmpty ? mobilePhoneLabel.text! : mobliePhoneTextfield.text!
            let mobliePhone:String = omobile //mobilePhoneLabel.text! //chiu 1090819
            let areaCode:String = teleAreaCodeTextfield.text!.isEmpty ?  teleAreaCode : teleAreaCodeTextfield.text!
            let phone:String = telePhoneTextfield.text!.isEmpty ? telePhone : telePhoneTextfield.text!
            
            let code:String = postalCodeTextfield.text!.isEmpty ? postalCode : postalCodeTextfield.text!
            let ADR2:String = addressTextfield.text!.isEmpty ? address : addressTextfield.text!
            postRequest("Usif/USIF0102", "USIF0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08001","Operate":"dataConfirm","TransactionId":transactionId,"FUNCD":funcd,"EMAIL":email,"EMAILFG":emailFG,"MAILFG":MAILFG,"MSG1":MSG1,"MSG2":MSG2,"MSG3":MSG3,"MPHONE ":mobliePhone,"AREA1":areaCode,"TELNO1":phone,"ZIPCD2":code,"ADR2":ADR2], true), AuthorizationManage.manage.getHttpHead(true))
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count)! - range.length + string.count
        switch textField {
        case mobliePhoneTextfield:
            if newLength > Max_MobliePhone_Length {
                return false
            }
            
        default: break
        }
        
        return true
    }
    
    // MARK: - KeyBoard
    override func keyboardWillShow(_ notification:NSNotification) {
        if currentTextField == postalCodeTextfield || currentTextField == addressTextfield // ||currentTextField == teleAreaCodeTextfield || currentTextField == telePhoneTextfield
        {
            super.keyboardWillShow(notification)
        }
    }
}
