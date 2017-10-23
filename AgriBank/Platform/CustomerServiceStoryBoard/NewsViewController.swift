//
//  NewsViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let News_TypeList = ["中心公告","農漁會公告"]
let News_ShowDetail_Seque = "goDetail"
let News_ShowDate = "發佈日期:"

class NewsViewController: BaseViewController, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_tvData: UITableView!
    private var m_iSelectedIndex = -1
    private var m_Data1:[PromotionStruct] = [PromotionStruct]()
    private var m_Data2:[PromotionStruct] = [PromotionStruct]()
    private var webContent:Data? = nil
    private var curDateType:String? = nil

    // MARK: - Public
//    func SetNewsList(_ center:[PromotionStruct]?, _ bank:[PromotionStruct]?) {
//        if center != nil {
//            m_Data1 = center!
//        }
//        if bank != nil {
//            m_Data2 = bank!
//        }
//    }

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        m_vChooseTypeView.setTypeList(News_TypeList, setDelegate: self, AuthorizationManage.manage.IsLoginSuccess() ? 1 : 0, view.frame.width/2)
        
        setShadowView(m_vChooseTypeView)
        
        m_tvData.register(UINib(nibName: UIID.UIID_NewsCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NewsCell.NibName()!)
        initDataForType(AuthorizationManage.manage.IsLoginSuccess() ? News_TypeList[1]:News_TypeList[0])
        getAnnounceNewsInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let webContentViewController = segue.destination as! WebContentViewController
        let curData = curDateType == News_TypeList.first ? m_Data1 : m_Data2
        webContentViewController.setData(curData[m_iSelectedIndex], webContent)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0101":
            /* 「中心公告」切換至「農漁會公告」，需要登入成功 */
            super.didResponse(description, response)
            getAnnounceNewsInfo()
            
        case "INFO0201":
            if let data = response.object(forKey: ReturnData_Key) as? [String : Any], let list = data["CB_List"] as? [[String:Any]] {
                if curDateType == News_TypeList.first {
                    if let con = navigationController?.viewControllers.first {
                        if con is HomeViewController {
                            (con as! HomeViewController).setNewsList(true, list)
                        }
                    }
                    m_Data1.removeAll()
                    for index in list {
                        if let title = index["CB_Title"] as? String, let date = index["CB_AddedDT"] as? String, let url = index["URL"] as? String, let ID = index["CB_ID"] as? String {
                            m_Data1.append(PromotionStruct(title, date, "", url, ID))
                        }
                    }
                }
                else {
                    if let con = navigationController?.viewControllers.first {
                        if con is HomeViewController {
                            (con as! HomeViewController).setNewsList(false, list)
                        }
                    }
                    m_Data2.removeAll()
                    for index in list {
                        if let title = index["CB_Title"] as? String, let date = index["CB_AddedDT"] as? String, let url = index["URL"] as? String, let ID = index["CB_ID"] as? String {
                            m_Data2.append(PromotionStruct(title, date, "", url, ID))
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            m_tvData.reloadData()
            
        case "INFO0202":
            if let data = response.object(forKey: RESPONSE_Data_KEY) as? Data {
                webContent = data
                performSegue(withIdentifier: News_ShowDetail_Seque, sender: nil)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func initDataForType(_ type:String) {
        curDateType = type
        if curDateType == News_TypeList.first {
            m_Data1.removeAll()
        }
        else {
            m_Data2.removeAll()
        }
        m_tvData.reloadData()
    }
    
    private func getAnnounceNewsInfo() { // 最新消息電文
        var body = [String:Any]()
        body = ["WorkCode":"07041","Operate":"getListInfo"]
        if curDateType == News_TypeList.first {
            body["CB_Type"] = Int(2)
            body["CB_CUM_BankCode"] = ""
        }
        else {
            body["CB_Type"] = Int(1)
            if let loginInfo = AuthorizationManage.manage.GetLoginInfo() {
                body["CB_CUM_BankCode"] = loginInfo.bankCode
            }
        }
        setLoading(true)
        postRequest("Info/INFO0201", "INFO0201", AuthorizationManage.manage.converInputToHttpBody(body, false), AuthorizationManage.manage.getHttpHead(false))
    }

    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        initDataForType(name)
        if name == News_TypeList[1] && !AuthorizationManage.manage.IsLoginSuccess() {
            showLoginView()
        }
        else {
            getAnnounceNewsInfo()
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        m_iSelectedIndex = indexPath.row
//        if let ID = m_curData?[m_iSelectedIndex].ID {
//            setLoading(true)
//            getRequest("Info/INFO0202?CMIID=\(ID)", "INFO0202", nil, AuthorizationManage.manage.getHttpHead(false), nil, false, .Data)
//        }
        performSegue(withIdentifier: News_ShowDetail_Seque, sender: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let curData = curDateType == News_TypeList.first ? m_Data1 : m_Data2
        return curData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let curData = curDateType == News_TypeList.first ? m_Data1 : m_Data2
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_NewsCell.NibName()!, for: indexPath) as! NewsCell
        cell.setData(curData[indexPath.row].title!, News_ShowDate, curData[indexPath.row].date!)
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - LoginDelegate
    override func clickLoginCloseBtn() {
        m_vChooseTypeView.setTypeList(News_TypeList, setDelegate: self, 0, view.frame.width/2)
        clickChooseTypeBtn(News_TypeList.first!)
        super.clickLoginCloseBtn()
    }
}
