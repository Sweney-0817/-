//
//  NTRationViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/5.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

struct NTRationStruct {
    var title:String? = nil
    var data1:String? = nil
    var data2:String? = nil
    init (_ title:String, _ data1:String, _ data2:String)
    {
        self.title = title
        self.data1 = data1
        self.data2 = data2
    }
}


class NTRationViewController: BaseViewController, OneRowDropDownViewDelegate, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_vTitle: UIView!
    @IBOutlet weak var m_lbData1Title: UILabel!
    @IBOutlet weak var m_lbData2Title: UILabel!
    @IBOutlet weak var m_tvData: UITableView!

    var m_DDPlace: OneRowDropDownView? = nil
    var m_strType: String? = nil
    var m_Data1: [NTRationStruct] = [NTRationStruct]()
    var m_Data2: [NTRationStruct] = [NTRationStruct]()
    var m_Data3: [NTRationStruct] = [NTRationStruct]()
    var m_Data4: [NTRationStruct] = [NTRationStruct]()
    let m_tfPicker: UITextField = UITextField()
    var m_PickerData: [[String:[String]]]? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setFakeData()
        setAllSubView()
        initDataTitleForType("活存")
        setShadowView(m_vChooseTypeView)
    }
    func setFakeData() {
        m_Data1.append(NTRationStruct.init("活期存款", "", "0.10010 %"))
        m_Data1.append(NTRationStruct.init("活期儲蓄存款", "", "0.10010 %"))

        m_Data2.append(NTRationStruct.init("定期存款1個月", "0.10010 %", "0.10010 %"))
        m_Data2.append(NTRationStruct.init("定期存款3個月", "0.10010 %", "0.10010 %"))
        m_Data2.append(NTRationStruct.init("定期存款6個月", "0.10010 %", "0.10010 %"))
        m_Data2.append(NTRationStruct.init("定期存款9個月", "0.10010 %", "0.10010 %"))
        m_Data2.append(NTRationStruct.init("定期存款1年", "0.10010 %", "0.10010 %"))
        m_Data2.append(NTRationStruct.init("定期存款2年", "0.10010 %", "0.10010 %"))
        m_Data2.append(NTRationStruct.init("定期存款3年", "0.10010 %", "0.10010 %"))

        m_Data3.append(NTRationStruct.init("定期儲蓄存款1年", "0.10010 %", "0.10010 %"))
        m_Data3.append(NTRationStruct.init("定期儲蓄存款2年", "0.10010 %", "0.10010 %"))
        m_Data3.append(NTRationStruct.init("定期儲蓄存款3年", "0.10010 %", "0.10010 %"))

        m_Data4.append(NTRationStruct.init("基本放款利率", "", "0.10010 %"))
        m_Data4.append(NTRationStruct.init("基準利率", "", "0.10010 %"))
        m_Data4.append(NTRationStruct.init("指標利率", "", "0.10010 %"))
        m_Data4.append(NTRationStruct.init("指數型房貸利率", "", "0.10010 %"))
        m_Data4.append(NTRationStruct.init("指數型指標房貸利率(月調)", "", "0.10010 %"))
        m_Data4.append(NTRationStruct.init("一定比率", "", "0.10010 %"))
        m_Data4.append(NTRationStruct.init("指標利率(月調)", "", "0.10010 %"))
        m_Data4.append(NTRationStruct.init("基標利率(月調)", "", "0.10010 %"))
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
            m_DDPlace?.setOneRow("農會", "彰化縣 彰化區農會")
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
        m_vPlace.layer.borderColor = Gray_Color.cgColor
        m_vPlace.layer.borderWidth = 1
    }
    func setChooseTypeView() {
        let typeList = ["活存","定期","定儲","其他"]
        m_vChooseTypeView.setTypeList(typeList, setDelegate: self)
        m_vChooseTypeView.layer.borderColor = Gray_Color.cgColor
        m_vChooseTypeView.layer.borderWidth = 1
    }
    func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_NTRationCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NTRationCell.NibName()!)
        m_tvData.allowsSelection = false
    }
    func setPicker()
    {
        if (m_PickerData == nil) {
            m_PickerData = [["桃園市":["全國農會1"]], ["台北市":["全國農會4","全國農會5"]], ["新北市":["全國農會7","全國農會8","全國農會9"]]]
        }
        m_tfPicker.delegate = self
        m_vPlace.addSubview(m_tfPicker)

        // UIPickerView
        let pickerView = UIPickerView(frame: CGRect(x:0, y:self.view.frame.height-Login_PickView_Height, width:self.view.frame.width, height:Login_PickView_Height))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.selectRow(0, inComponent: 0, animated: false)
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = Login_ToolBar_tintColor
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: Login_DoneButton_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Login_CancelButton_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        m_tfPicker.inputAccessoryView = toolBar
        m_tfPicker.inputView = pickerView
    }
    func initDataTitleForType(_ type:String) {
        m_strType = type
        switch type {
            case "活存", "其他":
                m_lbData1Title.text = ""
                m_lbData2Title.text = "利率"
            case "定期", "定儲":
                m_lbData1Title.text = "固定利率"
                m_lbData2Title.text = "機動利率"
        default:
            m_lbData1Title.text = ""
            m_lbData2Title.text = ""
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        textFieldShouldBeginEditing(m_tfPicker)
        m_tfPicker.becomeFirstResponder()
    }
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if (actionSheet.buttonTitle(at: buttonIndex)! != "cancel")
        {
            m_DDPlace?.setOneRow(actionSheet.buttonTitle(at: buttonIndex)!, actionSheet.buttonTitle(at: buttonIndex)!)
        }
    }
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        initDataTitleForType(name)
        m_tvData.reloadData()
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch m_strType! {
            case "活存":
            return m_Data1.count
            case "定期":
            return m_Data2.count
            case "定儲":
            return m_Data3.count
            case "其他":
            return m_Data4.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_NTRationCell.NibName()!, for: indexPath) as! NTRationCell
            switch m_strType! {
            case "活存":
                let data = m_Data1[indexPath.row]
                cell.setData(data.title!, data.data1!, data.data2!)
            case "定期":
                let data = m_Data2[indexPath.row]
                cell.setData(data.title!, data.data1!, data.data2!)
            case "定儲":
                let data = m_Data3[indexPath.row]
                cell.setData(data.title!, data.data1!, data.data2!)
            case "其他":
                let data = m_Data4[indexPath.row]
                cell.setData(data.title!, data.data1!, data.data2!)
            default:
                cell.setData("", "", "")
            }
            return cell
        }
    }

    // MARK: - For Picker
    func clickCancelBtn(_ sender:Any) {
        m_tfPicker.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        let pickerView = m_tfPicker.inputView as! UIPickerView
        let a = m_PickerData?[pickerView.selectedRow(inComponent: 0)]
        let city = [String](a!.keys)[0]
        let place = a?[city]?[pickerView.selectedRow(inComponent: 1)]
        m_DDPlace?.setOneRow((m_DDPlace?.m_lbFirstRowTitle.text)!, city+" "+place!)
        m_tfPicker.resignFirstResponder()
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setPicker()
        return true
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0)
        {
            return m_PickerData!.count
        }
        else
        {
            let a = m_PickerData?[pickerView.selectedRow(inComponent: 0)]
            let city = [String](a!.keys)[0]
            return (a![city]?.count)!
        }
    }
    
    // MARK - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let a = m_PickerData?[row]
            return [String](a!.keys)[0]
        }
        else {
            let a = m_PickerData?[pickerView.selectedRow(inComponent: 0)]
            let city = [String](a!.keys)[0]
            return a![city]?[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
    }

}
