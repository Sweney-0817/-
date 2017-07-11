//
//  NewsViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class NewsViewController: BaseViewController, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_tvData: UITableView!
    var m_iSelectedIndex = -1
    var m_Data1: [PromotionStruct] = [PromotionStruct]()
    var m_Data2: [PromotionStruct] = [PromotionStruct]()
    var m_curData: [PromotionStruct]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setFakeData()
        setAllSubView()
        initDataForType("中心公告")
        setShadowView(m_vChooseTypeView)
    }
    func goDetail() {
        performSegue(withIdentifier: "goDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let webContentViewController = segue.destination as! WebContentViewController
        webContentViewController.setData((m_curData?[m_iSelectedIndex])!)
    }
    
    func setFakeData() {
        //m_Data1.append(PromotionStruct.init("", "", ""))
        m_Data1.append(PromotionStruct.init("106年度小型農業專題研究徵稿啟事", "2017/04/27", "", "https://www.google.com.tw/"))
        m_Data1.append(PromotionStruct.init("106年第二季金融卡消費扣款促刷活動", "2017/04/21", "", "https://www.apple.com/tw/"))
        m_Data1.append(PromotionStruct.init("賀 ! 南投市農會.魚池鄉農會.水里鄉農會.信義鄉農會.中埔鄉農會順利完成資訊...", "2017/04/17", "", "https://eip.systex.com.tw/athena/"))
        m_Data1.append(PromotionStruct.init("農漁會資訊整合新共用系統，將強化資安與洗錢防制 北區共用中心55家農漁...", "2017/04/13", "", "https://tw.yahoo.com/"))
        m_Data1.append(PromotionStruct.init("賀 ! 溪湖鎮農會.花壇鄉農會.大村鄉農會.社頭鄉農會.大城鄉農會.埔鹽鄉農會順...", "2017/03/27", "", "https://www.youtube.com/"))

        m_Data2.append(PromotionStruct.init("1", "1-1", "", "https://www.youtube.com/"))
        m_Data2.append(PromotionStruct.init("2", "2-1", "", "https://tw.yahoo.com/"))
        m_Data2.append(PromotionStruct.init("3", "3-1", "", "https://eip.systex.com.tw/athena/"))
        m_Data2.append(PromotionStruct.init("4", "4-1", "", "https://www.apple.com/tw/"))
        m_Data2.append(PromotionStruct.init("5", "5-1", "", "https://www.google.com.tw/"))
        m_Data2.append(PromotionStruct.init("1", "1-1", "", "https://www.youtube.com/"))
        m_Data2.append(PromotionStruct.init("2", "2-1", "", "https://tw.yahoo.com/"))
        m_Data2.append(PromotionStruct.init("3", "3-1", "", "https://eip.systex.com.tw/athena/"))
        m_Data2.append(PromotionStruct.init("4", "4-1", "", "https://www.apple.com/tw/"))
        m_Data2.append(PromotionStruct.init("5", "5-1", "", "https://www.google.com.tw/"))
    }
    
    func setAllSubView() {
        setChooseTypeView()
        setDataTableView()
    }
    func setChooseTypeView() {
        let typeList = ["中心公告","農漁會公告"]
        m_vChooseTypeView.setTypeList(typeList, setDelegate: self)
        m_vChooseTypeView.layer.borderColor = Gray_Color.cgColor
        m_vChooseTypeView.layer.borderWidth = 1
    }

    func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_NewsCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NewsCell.NibName()!)
    }
    
    func initDataForType(_ type:String) {
        if (type == "中心公告") {
            m_curData = m_Data1
        }
        else {
            m_curData = m_Data2
        }
        m_tvData.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
