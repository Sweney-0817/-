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
    private var confirmIsSuccess = false
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setShadowView(bottomView)
        
        sourceIDTextfield.text = "Systexsoftware"
        newIDTextfield.text = "softwareSystex"
        againIDTextfield.text = "softwareSystex"
        sourcePasswordTextfield.text = "systex6214"
        newPasswordTextfield.text = "6214systex"
        againPasswordTextfield.text = "6214systex"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! UserChangeIDPwdResultViewController
        controller.SetConrirmIsSuccess(confirmIsSuccess)
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCheckBtn(_ sender: Any) {
        postRequest("Comm/COMM0103", "COMM0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01013","Operate":"commitTxn","OID":SecurityUtility.utility.MD5(string: sourceIDTextfield.text!),"NID":SecurityUtility.utility.MD5(string: againIDTextfield.text!),"OPWD":SecurityUtility.utility.MD5(string: sourcePasswordTextfield.text!),"NPWD":SecurityUtility.utility.MD5(string: againPasswordTextfield.text!)], true), AuthorizationManage.manage.getHttpHead(true))
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
            if let returnCode = response.object(forKey: "ReturnCode") as? String, returnCode == ReturnCode_Success {
                confirmIsSuccess = true
            }
            performSegue(withIdentifier: UserFirstChangeIDPwd_Seque, sender: nil)
            
        default: break
        }
    }
}
