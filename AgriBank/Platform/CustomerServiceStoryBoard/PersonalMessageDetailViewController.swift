//
//  PersonalMessageDetailViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class PersonalMessageDetailViewController: BaseViewController {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_lbDate: UILabel!
    @IBOutlet weak var m_tfContent: UITextField!
    var m_Data: PromotionStruct? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        m_lbTitle.text = m_Data?.title
        m_lbDate.text = m_Data?.date
        m_tfContent.text = m_Data?.url
    }
    func setData(_ data:PromotionStruct) {
        self.m_Data = data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
