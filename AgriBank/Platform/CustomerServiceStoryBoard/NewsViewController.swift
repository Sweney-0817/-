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

class NewsViewController: BaseViewController, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_tvData: UITableView!
    @IBOutlet weak var disableView: UIView!
    var m_iSelectedIndex = -1
    var m_Data1: [PromotionStruct] = [PromotionStruct]()
    var m_Data2: [PromotionStruct] = [PromotionStruct]()
    var m_curData: [PromotionStruct]? = nil

    // MARK: - Public
    func SetNewsList(_ center:[PromotionStruct]?, _ bank:[PromotionStruct]?) {
        if center != nil {
            m_Data1 = center!
        }
        if bank != nil {
            m_Data2 = bank!
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let webContentViewController = segue.destination as! WebContentViewController
        webContentViewController.setData((m_curData?[m_iSelectedIndex])!)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        initDataForType(News_TypeList.first!)
        setShadowView(m_vChooseTypeView)
        disableView.isHidden = AuthorizationManage.manage.IsLoginSuccess()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private
    private func goDetail() {
        performSegue(withIdentifier: News_ShowDetail_Seque, sender: nil)
    }
    
    private func setAllSubView() {
        setChooseTypeView()
        setDataTableView()
    }
    
    private func setChooseTypeView() {
        m_vChooseTypeView.setTypeList(News_TypeList, setDelegate: self, nil, view.frame.width/2)
    }

    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_NewsCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NewsCell.NibName()!)
    }
    
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
        initDataForType(name)
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
        return m_curData!.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_NewsCell.NibName()!, for: indexPath) as! NewsCell
        cell.setData((m_curData?[indexPath.row].title!)!, "發佈日期", (m_curData?[indexPath.row].date!)!)
        cell.selectionStyle = .none
        return cell
    }
}
