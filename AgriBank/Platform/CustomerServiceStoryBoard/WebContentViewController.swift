//
//  WebContentViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import WebKit

class WebContentViewController: BaseViewController, WKNavigationDelegate {
    @IBOutlet weak var m_lbTitle: UILabel!
    @IBOutlet weak var m_wvContent: WKWebView!
    @IBOutlet weak var provideUnit: UILabel!
    @IBOutlet weak var provideHeight: NSLayoutConstraint!
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
        if let place = m_Data?.place, !place.isEmpty {
            provideUnit.text = "\(ProvideUnit_Title):\(place)"
        }
        else {
            provideHeight.constant = 0
            provideUnit.isHidden = false
        }
//        m_wvContent.stringByEvaluatingJavaScript(from: "document.characterSet='utf-8';")
//        m_wvContent.load(contentData!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL:URL(string: (m_Data?.url)!)!)
//        m_wvContent.loadHTMLString(String(data: contentData!, encoding: .utf8)!, baseURL: URL(string: (m_Data?.url)!)!)
        
        
        let request:URLRequest = URLRequest(url: URL(string: (m_Data?.url)!)!)
       //setLoading(true)
        m_wvContent.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - WKWebViewDelegate
//    func webViewDidFinishLoad(_ webView: WKWebView ) {
//        setLoading(false)
//    }
    // 加载完成的代理方法
    func webView(_ m_wvContent: WKWebView, didFinish navigation: WKNavigation!) {
        setLoading(false)
    }
    
    func webView(_ m_wvContent: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: WKNavigationType) -> Bool {
        if navigationType == .linkActivated {
            guard let url = request.url else { return true }
            UIApplication.shared.open(url)
            return false
        }
        return true
    }
}
