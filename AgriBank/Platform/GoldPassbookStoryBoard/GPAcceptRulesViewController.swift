//
//  GPAcceptRulesViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/8/15.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class GPAcceptRulesViewController: BaseViewController {
    var m_nextFeatureID : PlatformFeatureID? = nil
    @IBOutlet var m_wvContent: UIWebView!
    @IBOutlet var m_btnCheck: UIButton!
    @IBAction func m_btnCheckClick(_ sender: Any) {
        m_btnCheck.isSelected = !m_btnCheck.isSelected
    }
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        guard m_btnCheck.isSelected else {
            showErrorMessage(nil, "請勾選我已審閱並同意上述事項")
            return
        }
        guard m_nextFeatureID != nil else {
            showErrorMessage("錯誤", "沒帶FeatureID")
            return
        }
        enterFeatureByID(m_nextFeatureID!, false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_wvContent.loadRequest(URLRequest.init(url: URL.init(string: "https://www.google.com")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
