//
//  UserNameChangeViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let UserChangeIDPwd_Seque = "GoChangeResult"
let UserChangeIDPwd_MaxLength = Int(16)

class UserChangeIDPwdViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var sourceTextfield: TextField!
    @IBOutlet weak var newTextfield: TextField!
    @IBOutlet weak var againTextfield: TextField!
    @IBOutlet weak var bottomView: UIView!
    private var isChangePassword = false
    private var errorMessage = ""
    
    // MARK: - Public
    func SetIsChangePassword() {
        isChangePassword = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! UserChangeIDPwdResultViewController
        controller.setErrorMessage(errorMessage)
    }
    
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        if sourceTextfield.text == nil || newTextfield.text == nil || againTextfield.text == nil || transactionId.isEmpty {
            return false
        }
        if newTextfield.text != againTextfield.text {
            return false
        }
        return true
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLoading(true)
        if !isChangePassword {
            getTransactionID("08002", TransactionID_Description)
            
        }
        else {
            getTransactionID("08003", TransactionID_Description)
            sourceTextfield.placeholder = "原使用者密碼"
            sourceTextfield.isSecureTextEntry = true
            newTextfield.placeholder = "新使用者密碼"
            newTextfield.isSecureTextEntry = true
            againTextfield.placeholder = "再次輸入新使用者密碼"
            againTextfield.isSecureTextEntry = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "USIF0201", "USIF0301":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: "ReturnMsg") as? String {
                    errorMessage = message
                }
            }
            performSegue(withIdentifier: UserChangeIDPwd_Seque, sender: nil)
            
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickChangeBtn(_ sender: Any) {
        if inputIsCorrect() {
            let idMd5 = SecurityUtility.utility.MD5(string: sourceTextfield.text!)
            let pdMd5 = SecurityUtility.utility.MD5(string: newTextfield.text!)
            if !isChangePassword {
                postRequest("Usif/USIF0201", "USIF0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08002","Operate":"dataConfirm","TransactionId":transactionId,"ID":idMd5,"NewID":pdMd5], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                postRequest("Usif/USIF0301", "USIF0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08003","Operate":"dataConfirm","TransactionId":transactionId,"PWD":idMd5,"NewPWD":pdMd5], true), AuthorizationManage.manage.getHttpHead(true))
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.characters.count)! - range.length + string.characters.count
        switch textField {
        case newTextfield:
            if newLength > UserChangeIDPwd_MaxLength {
                return false
            }
            
        case againTextfield:
            if newLength > UserChangeIDPwd_MaxLength {
                return false
            }
            
        default: break
        }

        return true
    }
    
}
