//
//  CheckLoseApplyViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/28.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class CheckLoseApplyViewController: BaseViewController {
    @IBOutlet weak var m_vDDType: UIView!
    @IBOutlet weak var m_vDDAccount: UIView!
    @IBOutlet weak var m_tfCheckNumber: TextField!
    @IBOutlet weak var m_vCheckAmount: UIView!
    @IBOutlet weak var m_tfCheckAmount: TextField!
    @IBOutlet weak var m_consCheckAmountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vCheckDate: UIView!
    @IBOutlet weak var m_consCheckDateHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vFeeAccount: UIView!
    @IBOutlet weak var m_consFeeAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vImageConfirmView: UIView!
    @IBAction func m_btnSendClick(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
