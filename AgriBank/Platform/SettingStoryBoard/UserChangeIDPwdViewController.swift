//
//  UserNameChangeViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let UserChangeIDPwd_Seque = "GoChangeResult"
let UserChangeIDPwd_ClickCancel_Title = "您尚未完成強制變更密碼，系統將執行登出"

class UserChangeIDPwdViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var sourceTextfield: TextField!
    @IBOutlet weak var newTextfield: TextField!
    @IBOutlet weak var againTextfield: TextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var leadingCons: NSLayoutConstraint!  //「變更」Button的leading
    @IBOutlet weak var trailingCons: NSLayoutConstraint! //「變更」Button的trailing
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var changeBtn: UIButton!
    private var isChangePassword = false
    private var errorMessage = ""
    private var isClickChangeBtn = false
    private var gesture:UIPanGestureRecognizer? = nil
    
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
        if (sourceTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(sourceTextfield.placeholder!)")
            return false
        }
        if (newTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(newTextfield.placeholder!)")
            return false
        }
        if (againTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(againTextfield.placeholder!)")
            return false
        }
        if sourceTextfield.text == newTextfield.text {
            showErrorMessage(nil, isChangePassword ? ErrorMsg_PDNotSame : ErrorMsg_IDNotSame)
            return false
        }
        if (newTextfield.text?.characters.count)! < NewInput_MinLength || (newTextfield.text?.characters.count)! > NewInput_MaxLength {
            showErrorMessage(nil, "\(newTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Length)")
            return false
        }
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            if info.account == newTextfield.text! {
                showErrorMessage(nil, "\(newTextfield.placeholder ?? "")\(ErrorMsg_IDPD_SameIdentify)")
                return false
            }
        }
        if DetermineUtility.utility.isAllEnglishOrNumber(newTextfield.text!) {
            showErrorMessage(nil, "\(newTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Combine)")
            return false
        }
        if !DetermineUtility.utility.checkInputNotContinuous(newTextfield.text!) {
            showErrorMessage(nil, "\(newTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Continous)")
            return false
        }
        if newTextfield.text != againTextfield.text {
            showErrorMessage(nil, isChangePassword ? ErrorMsg_PDAgainPDNeedSame : ErrorMsg_IDAgainIDNeedSame)
            return false
        }
        
        return true
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if !isChangePassword {
            getTransactionID("08002", TransactionID_Description)
        }
        else {
            /* 帳戶狀態在「已過期，需要強制變更」下，只能回首頁並登出 or 變更密碼  */
            if let info = AuthorizationManage.manage.getResponseLoginInfo(), let STATUS = info.STATUS, STATUS == Account_Status_ForcedChange_Password {
                navigationItem.leftBarButtonItem = nil
                navigationItem.hidesBackButton = true
                navigationItem.rightBarButtonItem = nil
                gesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture))
                navigationController?.view.addGestureRecognizer(gesture!)
                
                /*   左邊界| --15-- 「取消」 --25-- 「變更」 -- 15 -- |右邊界  */
                leadingCons.constant = view.frame.width / 2 + 12.5
                trailingCons.constant = 15
                cancelBtn.isHidden = false
                changeBtn.setBackgroundImage(UIImage(named: ImageName.ButtonMedium.rawValue), for: .normal)
            }
            
            getTransactionID("08003", TransactionID_Description)
            sourceTextfield.placeholder = "原使用者密碼"
            sourceTextfield.isSecureTextEntry = true
            newTextfield.placeholder = "新使用者密碼"
            newTextfield.isSecureTextEntry = true
            againTextfield.placeholder = "再次輸入新使用者密碼"
            againTextfield.isSecureTextEntry = true
        }
        addGestureForKeyBoard()
        setShadowView(bottomView, .Top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if gesture != nil {
            navigationController?.view.removeGestureRecognizer(gesture!)
        }
        super.viewWillDisappear(animated)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "USIF0201", "USIF0301":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                }
            }
            performSegue(withIdentifier: UserChangeIDPwd_Seque, sender: nil)
            
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
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
            isClickChangeBtn = true
            let idMd5 = SecurityUtility.utility.MD5(string: sourceTextfield.text!)
            let pdMd5 = SecurityUtility.utility.MD5(string: newTextfield.text!)
            setLoading(true)
            if !isChangePassword {
                postRequest("Usif/USIF0201", "USIF0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08002","Operate":"dataConfirm","TransactionId":transactionId,"ID":idMd5,"NewID":pdMd5], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                postRequest("Usif/USIF0301", "USIF0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08003","Operate":"dataConfirm","TransactionId":transactionId,"PWD":idMd5,"NewPWD":pdMd5], true), AuthorizationManage.manage.getHttpHead(true))
            }
        }
    }
    
    @IBAction func clickCancelBtn(_ sender: Any) {
        let alert = UIAlertController(title: UIAlert_Default_Title, message: UserChangeIDPwd_ClickCancel_Title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Cancel_Title, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
            DispatchQueue.main.async {
                self.postLogout()
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(alert, animated: false, completion: nil)
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
        switch textField {
        case newTextfield, againTextfield:
            if newLength > Max_ID_Password_Length {
                return false
            }
            
        default: break
        }

        return true
    }
    
    // MARK: - GestureRecognizer Selector
    func HandlePanGesture(_ sender: UIPanGestureRecognizer) {}
}
