//
//  WebContentViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class WebContentViewController: BaseViewController, UIWebViewDelegate {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_wvContent: UIWebView!
    private var m_Data:PromotionStruct? = nil
    private var contentData:Data? = nil
    
    // MARK: - Public
    func setData(_ data:PromotionStruct, _ contentData:Data? = nil) {
        self.m_Data = data
        self.contentData = contentData
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
    
        m_lbTitle.text = m_Data?.title
//        m_wvContent.stringByEvaluatingJavaScript(from: "document.characterSet='utf-8';")
//        m_wvContent.load(contentData!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL:URL(string: (m_Data?.url)!)!)
//        m_wvContent.loadHTMLString(String(data: contentData!, encoding: .utf8)!, baseURL: URL(string: (m_Data?.url)!)!)
        let request:URLRequest = URLRequest(url: URL(string: (m_Data?.url)!)!)
        setLoading(true)
        m_wvContent.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        setLoading(false)
    }
}
