//
//  UserFirstChangeIDPwdViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let UserFirstChangeIDPwd_Seque = "GoFirstChangeResult"

class UserFirstChangeIDPwdViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var sourceIDTextfield: TextField!
    @IBOutlet weak var newIDTextfield: TextField!
    @IBOutlet weak var againIDTextfield: TextField!
    @IBOutlet weak var sourcePasswordTextfield: TextField!
    @IBOutlet weak var newPasswordTextfield: TextField!
    @IBOutlet weak var againPasswordTextfield: TextField!
    @IBOutlet weak var bottomView: UIView!
    private var errorMessage = ""
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setShadowView(bottomView)
        addGestureForKeyBoard()
        
        getTransactionID("01013", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! UserChangeIDPwdResultViewController
        controller.setErrorMessage(errorMessage)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0103":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                }
            }
            performSegue(withIdentifier: UserFirstChangeIDPwd_Seque, sender: nil)
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        if (sourceIDTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(sourceIDTextfield.placeholder!)")
            return false
        }
        if (newIDTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(newIDTextfield.placeholder!)")
            return false
        }
        if (againIDTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(againIDTextfield.placeholder!)")
            return false
        }
        if (sourcePasswordTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(sourcePasswordTextfield.placeholder!)")
            return false
        }
        if (newPasswordTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(newPasswordTextfield.placeholder!)")
            return false
        }
        
        if (againPasswordTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(againPasswordTextfield.placeholder!)")
            return false
        }
        if newIDTextfield.text! == sourceIDTextfield.text! {
            showErrorMessage(nil, ErrorMsg_IDNotSame)
            return false
        }
        if (newIDTextfield.text?.characters.count)! < NewInput_MinLength || (newIDTextfield.text?.characters.count)! > NewInput_MaxLength {
            showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Length)")
            return false
        }
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            if info.account == newIDTextfield.text! {
                showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_SameIdentify)")
                return false
            }
        }
        if DetermineUtility.utility.isAllEnglishOrNumber(newIDTextfield.text!) {
            showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Combine)")
            return false
        }
        if !DetermineUtility.utility.checkInputNotContinuous(newIDTextfield.text!) {
            showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Continous)")
            return false
        }
        if againIDTextfield.text! != newIDTextfield.text! {
            showErrorMessage(nil, ErrorMsg_IDAgainIDNeedSame)
            return false
        }
        if sourcePasswordTextfield.text! == newPasswordTextfield.text! {
            showErrorMessage(nil, ErrorMsg_PDNotSame)
            return false
        }
        if (newPasswordTextfield.text?.characters.count)! < NewInput_MinLength || (newIDTextfield.text?.characters.count)! > NewInput_MaxLength {
            showErrorMessage(nil, "\(newPasswordTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Length)")
            return false
        }
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            if info.account == newIDTextfield.text! {
                showErrorMessage(nil, "\(newPasswordTextfield.placeholder ?? "")\(ErrorMsg_IDPD_SameIdentify)")
                return false
            }
        }
        if DetermineUtility.utility.isAllEnglishOrNumber(newIDTextfield.text!) {
            showErrorMessage(nil, "\(newPasswordTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Combine)")
            return false
        }
        if !DetermineUtility.utility.checkInputNotContinuous(newIDTextfield.text!) {
            showErrorMessage(nil, "\(newPasswordTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Continous)")
            return false
        }
        if againPasswordTextfield.text! != newPasswordTextfield.text! {
            showErrorMessage(nil, ErrorMsg_PDAgainPDNeedSame)
            return false
        }
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCheckBtn(_ sender: Any) {
        if inputIsCorrect() {
            setLoading(true)
            postRequest("Comm/COMM0103", "COMM0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01013","Operate":"commitTxn","OID":SecurityUtility.utility.MD5(string: sourceIDTextfield.text!),"NID":SecurityUtility.utility.MD5(string: againIDTextfield.text!),"OPWD":SecurityUtility.utility.MD5(string: sourcePasswordTextfield.text!),"NPWD":SecurityUtility.utility.MD5(string: againPasswordTextfield.text!), "TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !DetermineUtility.utility.isEnglishAndNumber(newString) {
            return false
        }

        let newLength = (textField.text?.characters.count)! - range.length + string.characters.count
        if newLength > Max_ID_Password_Length {
            return false
        }
        
        return true
    }
}
