//
//  ThirdPartyAnnounceViewController.swift
//  AgriBank
//
//  Created by 1800096SamChang on 2021/8/11.
//  Copyright © 2021 Systex. All rights reserved.
//

import Foundation
import WebKit

class ThirdPartyAnnounceViewController: BaseViewController {
    @IBOutlet weak var m_wvContent: WKWebView!
    // MARK:- Init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "ThirdPartyAnnounce", withExtension: "html")!
        m_wvContent.load(URLRequest(url: url))
    }
    // MARK:- UI Methods
    
    // MARK:- Logic Methods
    
    // MARK:- WebService Methods

    // MARK:- Handle Actions
    
}
