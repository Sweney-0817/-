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
    @IBOutlet weak var emailTextfield: TextField!
    @IBOutlet weak var mobliePhoneTextfield: TextField!
    @IBOutlet weak var telePhoneTextfield: TextField!
    @IBOutlet weak var addressTextfield: TextField!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BasicInfoResultViewController
        var list = [[String:String]]()
        list.append(["Key": "登入日期", "Value":"2017/01/03"])
        list.append(["Key": "預約轉帳日", "Value":"2017/02/01"])
        list.append(["Key": "銀行代碼", "Value":"008"])
        list.append(["Key": "轉入帳號", "Value":"1234567890"])
        list.append(["Key": "金額", "Value":"9999999999"])
        list.append(["Key": "交易備記", "Value":"-"])
        list.append(["Key": "處理結果", "Value":"-"])
        controller.SetList(list)
    }
    
    // MARK: - Life Cycle
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
    @IBAction func clickChangeBtn(_ sender: Any) {
        performSegue(withIdentifier: GoBaseInfoChangeResult_Segue, sender: nil)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
