//
//  PromotionViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

struct PromotionStruct {
    var title:String? = nil
    var date:String? = nil
    var place:String? = nil
    var url:String? = nil
    init (_ title:String, _ date:String, _ place:String, _ url:String)
    {
        self.title = title
        self.date = date
        self.place = place
        self.url = url
    }
}

class PromotionViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_tvData: UITableView!
    var m_iSelectedIndex = -1
    var m_DDPlace: OneRowDropDownView? = nil

    var m_Data: [PromotionStruct] = [PromotionStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setFakeData()
        setAllSubView()
        setShadowView(m_vPlace)
    }
    
    func goDetail() {
        performSegue(withIdentifier: "goDetail", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let webContentViewController = segue.destination as! WebContentViewController
        webContentViewController.setData(m_Data[m_iSelectedIndex])
        
    }

    func setFakeData() {
        m_Data.append(PromotionStruct.init("2017桃園農業博覽會－風華大同，永續農博", "2017/04/27", "XXX農會", "https://www.google.com.tw/"))
        m_Data.append(PromotionStruct.init("臺灣最盛大美麗的花節－苗栗，客家桐花祭", "2017/04/26", "XXX農會", "https://www.apple.com/tw/"))
        m_Data.append(PromotionStruct.init("魅力新社，幸福景綻野餐日，滿滿幸福洋溢", "2017/04/25", "XXX農會", "https://eip.systex.com.tw/athena/"))
        m_Data.append(PromotionStruct.init("2017樂活台南白河蓮花季", "2017/04/24", "XXX農會", "https://tw.yahoo.com/"))
        //m_Data.append(PromotionStruct.init("", "", ""))
    }

    func setAllSubView() {
        setDDPlace()
        setDataTableView()
    }

    func setDDPlace() {
        if (m_DDPlace == nil)
        {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow("提供單位", "彰化縣")
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
        m_vPlace.layer.borderColor = Gray_Color.cgColor
        m_vPlace.layer.borderWidth = 1
    }

    func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_PromotionCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_PromotionCell.NibName()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        var a = [String]()
        a.append("001")
        a.append("002")
        a.append("003")
        a.append("004")
        a.append("005")
        let action = UIActionSheet.init()
        action.delegate = self
        action.title = "select"
        for s in a  {
            action.addButton(withTitle: s)
        }
        action.addButton(withTitle: "cancel")
        action.cancelButtonIndex = a.count
        action.tag = 1000
        
        action.show(in: self.view)
    }
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if (actionSheet.buttonTitle(at: buttonIndex)! != "cancel")
        {
            m_DDPlace?.setOneRow((m_DDPlace?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 129
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
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_PromotionCell.NibName()!, for: indexPath) as! PromotionCell
        cell.setData(m_Data[indexPath.row].title!, m_Data[indexPath.row].date!, m_Data[indexPath.row].place!)
        cell.selectionStyle = .none
        return cell
    }

}
