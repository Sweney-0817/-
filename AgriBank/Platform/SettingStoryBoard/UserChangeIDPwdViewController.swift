//
//  UserNameChangeViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let UserChangeIDPwd_Seque = "GoChangeResult"

class UserChangeIDPwdViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var sourceTextfield: TextField!
    @IBOutlet weak var newTextfield: TextField!
    @IBOutlet weak var againTextfield: TextField!
    @IBOutlet weak var bottomView: UIView!
    private var isChangePassword = false
    
    // MARK: - Public
    func SetIsChangePassword() {
        isChangePassword = true
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if isChangePassword {
            sourceTextfield.placeholder = "原使用者密碼"
            newTextfield.placeholder = "新使用者密碼"
            againTextfield.placeholder = "再次輸入新使用者密碼"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickChangeBtn(_ sender: Any) {
        performSegue(withIdentifier: UserChangeIDPwd_Seque, sender: nil)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
