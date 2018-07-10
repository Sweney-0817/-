//
//  AcceptRulesViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/6/26.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class AcceptRulesViewController: BaseViewController {
    var m_nextFeatureID : PlatformFeatureID? = nil
    @IBOutlet var m_wvContent: UIWebView!
    @IBOutlet var m_btnCheck: UIButton!
    @IBAction func m_btnCheckClick(_ sender: Any) {
        m_btnCheck.isSelected = !m_btnCheck.isSelected
    }
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        guard m_nextFeatureID != nil else {
            showErrorMessage("錯誤", "沒帶FeatureID")
            return
        }
        enterFeatureByID(m_nextFeatureID!, false)
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
