//
//  ServiceBaseViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

struct ServiceBaseStruct {
    var name:String? = nil
    var address:String? = nil
    var phone:String? = nil
    var fax:String? = nil
    var distance:String? = nil
    init (_ name:String, _ address:String, _ phone:String, _ fax:String, _ distance:String)
    {
        self.name = name
        self.address = address
        self.phone = phone
        self.fax = fax
        self.distance = distance
    }
}

class ServiceBaseViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_tvData: UITableView!

    var m_DDPlace: OneRowDropDownView? = nil
    var m_iSelectedIndex = -1
    var m_Data1: [ServiceBaseStruct] = [ServiceBaseStruct]()
    var m_Data2: [ServiceBaseStruct] = [ServiceBaseStruct]()
    var m_Data3: [ServiceBaseStruct] = [ServiceBaseStruct]()
    var m_curData: [ServiceBaseStruct] = [ServiceBaseStruct]()
    var m_strSearchRange: String = "我的週遭"

    override func viewDidLoad() {
        super.viewDidLoad()

        setFakeData()
        setAllSubView()
        initDataTitleForType("全部")
        setShadowView(m_vChooseTypeView)
    }
    func goDetail() {
        performSegue(withIdentifier: "goDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var data = ConfirmResultStruct("", "", [[String:String]](), "", "", "")
        data.list!.append(["Key": "名稱", "Value":m_curData[m_iSelectedIndex].name!])
        data.list!.append(["Key": "地址", "Value":m_curData[m_iSelectedIndex].address!])
        data.list!.append(["Key": "電話", "Value":m_curData[m_iSelectedIndex].phone!])
        data.list!.append(["Key": "傳真", "Value":m_curData[m_iSelectedIndex].fax!])
        super.prepare(for: segue, sender: sender)
        let serviceBaseDetailViewController = segue.destination as! ServiceBaseDetailViewController
        serviceBaseDetailViewController.setData(data)
    }
    func setFakeData() {
        m_Data1.append(ServiceBaseStruct.init("新北市農會", "新北市板橋區縣民大道一段291號", "02-29685191", "02-22710901", "800公尺外"))
        m_Data1.append(ServiceBaseStruct.init("ATM", "新北市板橋區府中路29號", "02-29685191", "02-22710901", "2公里外"))
        m_Data1.append(ServiceBaseStruct.init("三重區農會", "新北市三重區重新路二段1號", "02-29685191", "02-22710901", "8公里外"))
        m_Data1.append(ServiceBaseStruct.init("ATM", "新北市樹林區鎮前街77號", "02-29685191", "02-22710901", "10公里外"))
        m_Data1.append(ServiceBaseStruct.init("宜蘭縣農會", "宜蘭市林森路155號", "02-29685191", "02-22710901", "10公里外"))
        m_Data1.append(ServiceBaseStruct.init("ATM", "宜蘭縣羅東鎮純精路一段109號", "02-29685191", "02-22710901", "10公里外"))

        m_Data2.append(ServiceBaseStruct.init("新北市農會", "新北市板橋區縣民大道一段291號", "02-29685191", "02-22710901", "800公尺外"))
        m_Data2.append(ServiceBaseStruct.init("三重區農會", "新北市三重區重新路二段1號", "02-29685191", "02-22710901", "8公里外"))
        m_Data2.append(ServiceBaseStruct.init("宜蘭縣農會", "宜蘭市林森路155號", "02-29685191", "02-22710901", "10公里外"))

        m_Data3.append(ServiceBaseStruct.init("ATM", "新北市板橋區府中路29號", "02-29685191", "02-22710901", "2公里外"))
        m_Data3.append(ServiceBaseStruct.init("ATM", "新北市樹林區鎮前街77號", "02-29685191", "02-22710901", "10公里外"))
        m_Data3.append(ServiceBaseStruct.init("ATM", "宜蘭縣羅東鎮純精路一段109號", "02-29685191", "02-22710901", "10公里外"))

//        m_Data1.append(ServiceBaseStruct.init("", "", "", "", ""))
    }
    func setAllSubView() {
        setDDPlace()
        setChooseTypeView()
        setDataTableView()
    }
    func setDDPlace() {
        if (m_DDPlace == nil)
        {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow("查詢範圍", "我的週遭")
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
        m_vPlace.layer.borderColor = Gray_Color.cgColor
        m_vPlace.layer.borderWidth = 1
    }
    func setChooseTypeView() {
        let typeList = ["全部","農漁會","ATM"]
        m_vChooseTypeView.setTypeList(typeList, setDelegate: self)
        m_vChooseTypeView.layer.borderColor = Gray_Color.cgColor
        m_vChooseTypeView.layer.borderWidth = 1
    }
    func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_ServiceBaseCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ServiceBaseCell.NibName()!)
    }
    func initDataTitleForType(_ type:String) {
        switch type {
        case "全部":
            m_curData = m_Data1
        case "農漁會":
            m_curData = m_Data2
        case "ATM":
            m_curData = m_Data3
        default:
            m_curData = m_Data1
        }
        m_tvData.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        let a = ["我的週遭", "台北市", "新北市"]
        let action = UIActionSheet.init()
        action.delegate = self
        action.title = "請選擇查詢範圍"
        for s in a  {
            action.addButton(withTitle: s)
        }
        action.addButton(withTitle: "cancel")
        action.cancelButtonIndex = a.count
        
        action.show(in: self.view)
    }
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if (actionSheet.buttonTitle(at: buttonIndex)! != "cancel")
        {
            m_strSearchRange = actionSheet.buttonTitle(at: buttonIndex)!
            m_DDPlace?.setOneRow((m_DDPlace?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
            m_tvData.reloadData()
        }
    }
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        initDataTitleForType(name)
        m_tvData.reloadData()
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
        return m_curData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ServiceBaseCell.NibName()!, for: indexPath) as! ServiceBaseCell
            cell.setData(m_curData[indexPath.row].name!, m_curData[indexPath.row].address!, m_strSearchRange == "我的週遭" ? m_curData[indexPath.row].distance! : "")
            cell.selectionStyle = .none
            return cell
        }
    }
}
