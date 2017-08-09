//
//  ServiceBaseDetailViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import CoreLocation

class ServiceBaseDetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_tvData: UITableView!
    private var data:ConfirmResultStruct? = nil
    private var telePhone = ""
    private var curLocation = CLLocationCoordinate2D()
    private var mapWebView:UIWebView? = nil
    
    func setData(_ data:ConfirmResultStruct, _ telePhone:String, _ curLocation:CLLocationCoordinate2D) {
        self.data = data
        self.telePhone = telePhone
        self.curLocation = curLocation
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
    }
    
    func setAllSubView() {
        setDataTableView()
    }
    
    func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        m_tvData.allowsSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize((data?.list?[indexPath.row][Response_Value]!)!, m_tvData.frame.size.width)
        return height
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.list?.count)!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((data?.list?[indexPath.row][Response_Key]!)!, (data?.list?[indexPath.row][Response_Value]!)!)
        return cell
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnShowMapClick(_ sender: Any) {
        mapWebView = UIWebView(frame: view.frame)
    
        mapWebView?.loadRequest(URLRequest(url: URL(string: "https://www.google.com.tw/maps?addr=\(curLocation.latitude),\(curLocation.longitude)")!))
        view.addSubview(mapWebView!)
    }
    
    @IBAction func m_btnCallOutClick(_ sender: Any) {
        if let url = URL(string: "tel://\(telePhone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            }
            else {
                UIApplication.shared.openURL(url)
            }
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
}
