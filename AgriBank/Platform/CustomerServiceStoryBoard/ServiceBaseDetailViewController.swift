//
//  ServiceBaseDetailViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import CoreLocation
import WebKit

let ServiceBaseDetail_Cell_Title_Weight:CGFloat = 50
let ServiceBaseDetail_Map_URL = "https://maps.google.com/?q=@"

class ServiceBaseDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource ,WKNavigationDelegate, WKUIDelegate {
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var callPhoneButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    private var data:[[String:String]]? = nil
    private var telePhone:String? = nil
    private var curLocation:CLLocationCoordinate2D? = nil
    private var mapWebView:WKWebView? = nil
    
    // MARK: - Public
    func setData(_ data:[[String:String]]?, _ telePhone:String?, _ curLocation:CLLocationCoordinate2D?) {
        self.data = data
        self.telePhone = telePhone
        self.curLocation = curLocation
    }

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        setShadowView(bottomView, .Top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize((data?[indexPath.row][Response_Value]!)!, m_tvData.frame.size.width)
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            m_btnCallOutClick(callPhoneButton)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.titleWeight.constant = ServiceBaseDetail_Cell_Title_Weight
        cell.selectionStyle = .none
        cell.set((data?[indexPath.row][Response_Key]!)!, (data?[indexPath.row][Response_Value]!)!)
        return cell
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnShowMapClick(_ sender: Any) {
        if curLocation != nil {
            if mapWebView == nil {
                mapWebView = WKWebView(frame: view.frame)
                mapWebView?.navigationDelegate = self
                view.addSubview(mapWebView!)
            }
            setLoading(true)
            mapWebView?.load(URLRequest(url: URL(string: "\(ServiceBaseDetail_Map_URL)\(curLocation!.latitude),\(curLocation!.longitude)")!))
        }
        else {
            showErrorMessage(nil, ErrorMsg_NoMapAddress)
        }
    }
    
    @IBAction func m_btnCallOutClick(_ sender: Any) {
        if telePhone != nil && !telePhone!.isEmpty {
            if let url = URL(string: "tel://\(telePhone!)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                }
                else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_NoTelephone)
        }
    }
    
    // MARK: - UIBarButtonItem Selector
    override func clickBackBarItem() {
        if mapWebView == nil {
            navigationController?.popViewController(animated: true)
        }
        else {
            mapWebView?.removeFromSuperview()
            mapWebView = nil
        }
    }
    
//    // MARK: - WKWebViewDelegate
//    func webViewDidFinishLoad(_ webView: WKWebView ) {
//        setLoading(false)
//    }
    // 加载完成的代理方法
    func webView(_ mapWebView: WKWebView, didFinish navigation: WKNavigation!)  {
        setLoading(false)
    }
}
