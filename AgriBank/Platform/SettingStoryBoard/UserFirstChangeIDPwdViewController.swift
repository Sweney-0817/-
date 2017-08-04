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
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setShadowView(bottomView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCheckBtn(_ sender: Any) {
        postRequest("Comm/COMM0103", "COMM0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01013","Operate":"commitTxn","OID":"","NID":"","OPWD":"","NPWD":""], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0103":
            performSegue(withIdentifier: UserFirstChangeIDPwd_Seque, sender: nil)
        default: break
        }
    }
    
}
