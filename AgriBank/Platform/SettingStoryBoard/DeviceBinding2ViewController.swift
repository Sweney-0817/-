//
//  DeviceBinding2ViewController.swift
//  AgriBank
//
//  Created by 數位資訊部 on 2020/7/29.
//  Copyright © 2020 Systex. All rights reserved.
//

import UIKit
let Device2BindingResult_Segue = "GoDevice2BindingResult"
let Device2Binding_Bank_Title = "農漁會"
let Device2Binding_CheckCode_Length:Int = 7
let Device2Binding_Binding_Success_Title = "綁定成功"
let Device2Binding_Binding_Faild_Title = "綁定失敗"
let Device2Binding_Memo = "恭喜您已成功綁定此設備！\n若想取消此設備綁定，\n請至本中心網路銀行網頁辦理。"
class DeviceBinding2ViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var labelBankName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var checkCodeTextfield: TextField!
    
    private var topDropView:OneRowDropDownView? = nil
    private var bindingSuccess = false
    private var resultList:[[String:String]]? = nil
    private var loginInfo = LoginStrcture() //loginInfo.account 身分證號
    private var BankCode = ""
    private var ID = ""
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
        
        addGestureForKeyBoard()
        // Do any additional setup after loading the view.
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
        case "COMM0804":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                setLoading(true)
                VaktenManager.sharedInstance().associationOperation(withAssociationCode: checkCodeTextfield.text ?? "") { resultCode in
                    self.setLoading(false)
                    if VIsSuccessful(resultCode) {
                        self.bindingSuccess = true
                        self.performSegue(withIdentifier: Device2BindingResult_Segue, sender: self)
                    }
                    else {
                        self.resultList = [[String:String]]()
                        self.resultList?.append([Response_Key:Error_Title,Response_Value:"\(resultCode.rawValue)"])
                        self.performSegue(withIdentifier: Device2BindingResult_Segue, sender: self)
                    }
                }
            }
            else {
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    resultList = [[String:String]]()
                    resultList?.append([Response_Key:Error_Title,Response_Value:message])
                    self.performSegue(withIdentifier: DeviceBindingResult_Segue, sender: self)
                }
            }
            
        default: super.didResponse(description, response)
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
        if inputIsCorrect() {
            setLoading(true)
            let uuid = UUID().uuidString
            VaktenManager.sharedInstance().authenticateOperation(withSessionID: uuid) { resultCode in
                if VIsSuccessful(resultCode) {
                    if let info = AuthorizationManage.manage.GetLoginInfo(){
                    let bankCode = info.bankCode
                    let id = info.aot.uppercased()
                   
                    self.postRequest("COMM/COMM0804", "COMM0804", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08011","Operate":"queryData","SessionId":uuid,"BR_CODE":bankCode,"ID_DATA":id,"USER_ID":id,"ASSOCIATIONCODE":self.checkCodeTextfield.text!], true), AuthorizationManage.manage.getHttpHead(true))
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
