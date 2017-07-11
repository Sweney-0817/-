//
//  WebContentViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class WebContentViewController: BaseViewController {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_wvContent: UIWebView!
    var m_Data: PromotionStruct? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        m_lbTitle.text = m_Data?.title
        let req:URLRequest = URLRequest(url: URL.init(string: (m_Data?.url)!)!)
        m_wvContent.loadRequest(req)
    }

    func setData(_ data:PromotionStruct) {
        self.m_Data = data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
