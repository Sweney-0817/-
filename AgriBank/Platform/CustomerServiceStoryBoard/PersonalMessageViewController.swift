//
//  PersonalMessageViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class PersonalMessageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var m_tvData: UITableView!
    var m_iSelectedIndex = -1
    var m_Data: [PromotionStruct] = [PromotionStruct]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setFakeData()
        setAllSubView()
    }
    func goDetail() {
        performSegue(withIdentifier: "goDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let personalMessageDetailViewController = segue.destination as! PersonalMessageDetailViewController
        personalMessageDetailViewController.setData(m_Data[m_iSelectedIndex])
    }
    func setFakeData() {
        //m_Data1.append(PromotionStruct.init("", "", ""))
        m_Data.append(PromotionStruct.init("106年度小型農業專題研究徵稿啟事", "2017/04/27", "", "https://www.google.com.tw/"))
        m_Data.append(PromotionStruct.init("106年第二季金融卡消費扣款促刷活動", "2017/04/21", "", "https://www.apple.com/tw/"))
        m_Data.append(PromotionStruct.init("賀 ! 南投市農會.魚池鄉農會.水里鄉農會.信義鄉農會.中埔鄉農會順利完成資訊...", "2017/04/17", "", "https://eip.systex.com.tw/athena/"))
        m_Data.append(PromotionStruct.init("農漁會資訊整合新共用系統，將強化資安與洗錢防制 北區共用中心55家農漁...", "2017/04/13", "", "https://tw.yahoo.com/"))
        m_Data.append(PromotionStruct.init("賀 ! 溪湖鎮農會.花壇鄉農會.大村鄉農會.社頭鄉農會.大城鄉農會.埔鹽鄉農會順...", "2017/03/27", "", "https://www.youtube.com/"))
    }
    
    func setAllSubView() {
        setDataTableView()
    }
    func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_NewsCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NewsCell.NibName()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.setData(m_Data[indexPath.row].title!, "推播時間", m_Data[indexPath.row].date!)
        cell.selectionStyle = .none
        return cell
    }
}
