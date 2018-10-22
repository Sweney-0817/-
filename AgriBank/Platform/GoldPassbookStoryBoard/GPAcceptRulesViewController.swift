//
//  GPAcceptRulesViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/8/15.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class GPAcceptRulesViewController: BaseViewController {
    var m_nextFeatureID: PlatformFeatureID? = nil
    var m_dicData: [String:Any]? = nil
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
        guard (m_nextFeatureID != nil || m_dicData != nil) else {
            showErrorMessage("錯誤", "沒有下一步")
            return
        }
        switch m_nextFeatureID {
        case .FeatureID_GPSingleBuy?, .FeatureID_GPSingleSell?:
            enterFeatureByID(m_nextFeatureID!, false)
        default:
            performSegue(withIdentifier: m_dicData!["nextStep"] as! String, sender: m_dicData!["data"])
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let data: passData = sender as! passData
        switch segue.identifier {
        case "showBuy":
            let controller = segue.destination as! GPRegularSubscriptionViewController
            let act: String = data.m_accountStruct.accountNO
            let currency: String = data.m_accountStruct.currency
            let transOutAct: String = data.m_strTransOutAct
            let date: String = data.m_settingData.m_strDate
            controller.setData(act, currency, transOutAct, date)
        case "showChange":
            let controller = segue.destination as! GPRegularChangeViewController
//            let act: String = data.m_accountStruct.accountNO
//            let transOutAct: String = data.m_strTransOutAct
//            let date: String = data.m_settingData.m_strDate
//            controller.setData(act, transOutAct, date)
            controller.setData(data)
        default:
            return
        }
    }
}
