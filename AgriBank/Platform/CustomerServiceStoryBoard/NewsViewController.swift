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
    private var m_curData:[PromotionStruct]? = nil
    private var webContent:Data? = nil

    // MARK: - Public
    func SetNewsList(_ center:[PromotionStruct]?, _ bank:[PromotionStruct]?) {
        if center != nil {
            m_Data1 = center!
        }
        if bank != nil {
            m_Data2 = bank!
        }
    }

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        initDataForType(AuthorizationManage.manage.IsLoginSuccess() ? News_TypeList[1]:News_TypeList[0])
        m_vChooseTypeView.setTypeList(News_TypeList, setDelegate: self, AuthorizationManage.manage.IsLoginSuccess() ? 1 : 0, view.frame.width/2)
        setShadowView(m_vChooseTypeView)
        
        m_tvData.register(UINib(nibName: UIID.UIID_NewsCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NewsCell.NibName()!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let webContentViewController = segue.destination as! WebContentViewController
        webContentViewController.setData((m_curData?[m_iSelectedIndex])!, webContent)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0101":
            super.didResponse(description, response)
            if AuthorizationManage.manage.IsLoginSuccess(),let loginInfo = AuthorizationManage.manage.GetLoginInfo() {
                var body = [String:Any]()
                body = ["WorkCode":"07041","Operate":"getListInfo","CB_Type":Int(1),"CB_CUM_BankCode":loginInfo.bankCode]
                setLoading(true)
                postRequest("Info/INFO0201", "INFO0201", AuthorizationManage.manage.converInputToHttpBody(body, false), AuthorizationManage.manage.getHttpHead(false))
            }
            
        case "INFO0201":
            m_Data2.removeAll()
            if let data = response.object(forKey: ReturnData_Key) as? [String : Any], let list = data["CB_List"] as? [[String:Any]] {
                for index in list {
                    if let title = index["CB_Title"] as? String, let date = index["CB_AddedDT"] as? String, let url = index["URL"] as? String, let ID = index["CB_ID"] as? String {
                        m_Data2.append(PromotionStruct(title, date, "", url, ID))
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            m_curData = m_Data2
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
        if type == News_TypeList.first! {
            m_curData = m_Data1
        }
        else {
            m_curData = m_Data2
        }
        m_tvData.reloadData()
    }

    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        if name == News_TypeList[1] && !AuthorizationManage.manage.IsLoginSuccess() {
            showLoginView()
        }
        else {
            initDataForType(name)
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
        return m_curData!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_NewsCell.NibName()!, for: indexPath) as! NewsCell
        cell.setData((m_curData?[indexPath.row].title!)!, News_ShowDate, (m_curData?[indexPath.row].date!)!)
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - LoginDelegate
    override func clickLoginCloseBtn() {
        m_vChooseTypeView.setTypeList(News_TypeList, setDelegate: self, 0, view.frame.width/2)
        super.clickLoginCloseBtn()
    }
}
