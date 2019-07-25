//
//  PersonalMessageViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let PersonalMessage_Segue = "goDetail"
let PersonalMessage_PushTime_Title = "推播時間"

class PersonalMessageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_tvData: UITableView!
    private var m_iSelectedIndex = -1
    private var m_Data: [PromotionStruct] = [PromotionStruct]()

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        
        getTransactionID("07061", TransactionID_Description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let personalMessageDetailViewController = segue.destination as! PersonalMessageDetailViewController
        personalMessageDetailViewController.setData(m_Data[m_iSelectedIndex])
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("COMM/COMM0303", "COMM0303", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07061","Operate":"getList","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0303":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let list = data["Result"] as? [[String:Any]] {
                m_Data.removeAll()
                for dic in list {
                    let msg = (dic["msg"] as? String) ?? ""
                    let pushDate = (dic["pushDate"] as? String) ?? ""
                    m_Data.append(PromotionStruct(msg, pushDate, "", "", ""))
                }
                if (list.count > 0) {
                    let pushDate: String = (list.first!["pushDate"] as? String)!
                    let msgUid: String = (list.first!["msgUid"] as? String)!
                    var personalMessageData: [String:String]? = UserDefaults.standard.object(forKey: PersonalMessageKey) as? [String:String]
                    if (personalMessageData == nil) {
                        personalMessageData = [String:String]()
                    }
                    let info = AuthorizationManage.manage.getResponseLoginInfo()
                    let USUDID = info!.USUDID

                    personalMessageData![USUDID!] = pushDate + msgUid
                    UserDefaults.standard.set(personalMessageData, forKey: PersonalMessageKey)
                }
                m_tvData.reloadData()
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func goDetail() {
        performSegue(withIdentifier: PersonalMessage_Segue, sender: nil)
    }
    
    private func setAllSubView() {
        setDataTableView()
    }
    
    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_NewsCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NewsCell.NibName()!)
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        m_iSelectedIndex = indexPath.row
        goDetail()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_Data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_NewsCell.NibName()!, for: indexPath) as! NewsCell
        cell.setData(m_Data[indexPath.row].title!, PersonalMessage_PushTime_Title, m_Data[indexPath.row].date!)
        cell.selectionStyle = .none
        return cell
    }
}
