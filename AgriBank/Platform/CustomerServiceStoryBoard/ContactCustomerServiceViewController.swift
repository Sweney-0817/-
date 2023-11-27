//
//  ContactCustomerServiceViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2018/1/8.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit
import CoreLocation
import WebKit

let Default_BankCode = "60000" // 資訊中心

class ContactCustomerServiceViewController: BaseViewController, UITableViewDelegate,  UITableViewDataSource , WKNavigationDelegate, WKUIDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var callPhoneButton: UIButton!
    private var mapWebView:WKWebView? = nil
    private var telePhone:String? = nil
    private var curLocation:CLLocationCoordinate2D? = nil
    private var info = [[Response_Key:"名稱",Response_Value:""],
                        [Response_Key:"地址",Response_Value:""],
                        [Response_Key:"電話",Response_Value:""],
                        [Response_Key:"傳真",Response_Value:""],
                        ]
    private var noteStr = ""
    
     // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        setShadowView(bottomView, .Top)
        
        setLoading(true)
        if AuthorizationManage.manage.IsLoginSuccess() {
            
             noteStr = "1.營業時間請洽各營業單位。\n2.非營業時間請洽(02)29676789 分機7201、7202\n或免付費電話0800-556788"
            info.append([Response_Key: "", Response_Value:noteStr ])
            
            if let bCode = SecurityUtility.utility.readFileByKey(SetKey: File_BankCode_Key, setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String {
                postRequest("Info/INFO0302", "INFO0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07053","Operate":"getListInfo","CUM_BankCode":bCode], false), AuthorizationManage.manage.getHttpHead(false))
            }
           
        }
        else {
            noteStr =  ""
            postRequest("Info/INFO0302", "INFO0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07053","Operate":"getListInfo","CUM_BankCode":Default_BankCode], false), AuthorizationManage.manage.getHttpHead(false))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
            case "INFO0302":
                if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                    if let unit = data["Unit"] as? [[String:String]], let first = unit.first {
                        if let name = first["CUM_FullBankChineseName"] {
                            info[0][Response_Value] = name
                        }
                        if let address = first["CUM_Address"] {
                            info[1][Response_Value] = address
                        }
                        if let tel = first["CUM_Telephone"] {
                            info[2][Response_Value] = tel
                            telePhone = tel
                        }
                        if let fax = first["CUM_Fax"] {
                            info[3][Response_Value] = fax
                        }
                       
                        if let longitude = first["CUM_Longitude"], let latitude = first["CUM_Latitude"] {
                            curLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0)
                        }
                    }
                }
                tableView.reloadData()
            
            default: super.didResponse(description, response)
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = ResultCell.GetStringHeightByWidthAndFontSize(info[indexPath.row][Response_Value] ?? "", tableView.frame.size.width)
        
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            clickCallPhoneButton(callPhoneButton)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.titleWeight.constant = ServiceBaseDetail_Cell_Title_Weight
        
        //
        if info[indexPath.row][Response_Key] == "" {
            let TitleWeightReset:CGFloat = 0
            cell.titleWeight.constant = TitleWeightReset
        }
        cell.selectionStyle = .none
      
        cell.set(info[indexPath.row][Response_Key] ?? "", info[indexPath.row][Response_Value] ?? "")
        
        
        return cell
    }
  


 
    
    // MARK: - StoryBoard Touch Event
    @IBAction func ClickShowMapBtn(_ sender: Any) {
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
    
    @IBAction func clickCallPhoneButton(_ sender: UIButton) {
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
    
    // MARK: - WKWebViewDelegate
//    func webViewDidFinishLoad(_ webView: WKWebView ) {
//        setLoading(false)
//
//    }
    // 加载完成的代理方法
    func webView(_ mapWebView: WKWebView, didFinish navigation: WKNavigation!) {
        setLoading(false)
    }
 
 
   
}
