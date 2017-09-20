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
        case "COMM0103":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: "ReturnMsg") as? String {
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
        if newIDTextfield.text! == sourceIDTextfield.text! {
            showErrorMessage(nil, "新使用者代號與舊使用者代號不得相同")
            return false
        }
        if (againIDTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(againIDTextfield.placeholder!)")
            return false
        }
        if againIDTextfield.text! != newIDTextfield.text! {
            showErrorMessage(nil, "新使用者代號與再次輸入新使用者代號需要相同")
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
        if sourcePasswordTextfield.text! == newPasswordTextfield.text! {
            showErrorMessage(nil, "新密碼不得與舊密碼相同")
            return false
        }
        if (againPasswordTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(againPasswordTextfield.placeholder!)")
            return false
        }
        if againPasswordTextfield.text! != newPasswordTextfield.text! {
            showErrorMessage(nil, "新密碼與再次輸入新密碼需要相同")
            return false
        }
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCheckBtn(_ sender: Any) {
        if inputIsCorrect() {
            setLoading(true)
            postRequest("Comm/COMM0103", "COMM0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01013","Operate":"commitTxn","OID":SecurityUtility.utility.MD5(string: sourceIDTextfield.text!),"NID":SecurityUtility.utility.MD5(string: againIDTextfield.text!),"OPWD":SecurityUtility.utility.MD5(string: sourcePasswordTextfield.text!),"NPWD":SecurityUtility.utility.MD5(string: againPasswordTextfield.text!)], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
