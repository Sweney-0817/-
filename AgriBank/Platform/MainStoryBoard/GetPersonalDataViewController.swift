//
//  GetPersonalDataViewController.swift
//  AgriBank
//
//  Created by Systex on 2019/7/30.
//  Copyright © 2019 Systex. All rights reserved.
//

import UIKit
import WebKit

class GetPersonalDataViewController: BaseViewController {
    @IBOutlet weak var m_vContent: UIView!
    @IBOutlet weak var m_wvContent: WKWebView!
    @IBOutlet weak var m_btnCheck: UIButton!
    // MARK:- Init Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        m_vContent.layer.cornerRadius = 10
        m_vContent.layer.borderWidth = Layer_BorderWidth
        m_vContent.layer.borderColor = Cell_Title_Color.cgColor

//        m_wvContent.loadRequest(URLRequest(url: URL(string: "https://www.google.com")!))
  let url = Bundle.main.url(forResource: "PersonalInfoAgreement", withExtension: "html")!
      //  let Request = "http://www.afisc.com.tw/index.html"
      //  let url:URL = URL(string: (Request))!
        m_wvContent.load(URLRequest(url: url))
       
       
    }
    // MARK:- UI Methods
    
    // MARK:- Logic Methods
    
    // MARK:- WebService Methods

    // MARK:- Handle Actions
    @IBAction func m_btnCheckClick(_ sender: Any) {
        m_btnCheck.isSelected = !m_btnCheck.isSelected
    }
    @IBAction func m_btnCancelClick(_ sender: Any) {
        exit(0)
    }
    @IBAction func m_btnConfirmClick(_ sender: Any) {
        if (m_btnCheck.isSelected) {
            SecurityUtility.utility.writeFileByKey(true, SetKey: "confirmGetPersonalData")
            self.dismiss(animated: true, completion: nil)
        }
        else {
            showAlert(title: "注意", msg: "請勾選我已審閱並同意上述事項", confirmTitle: "確定", cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
        }
    }
}
