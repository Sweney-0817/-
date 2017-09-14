//
//  ExchangeRateViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/5.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ExchangeRate_Bank_Title = "農會"
let ExchangeRate_Cell_Height:CGFloat = 60

class ExchangeRateViewController: BaseViewController, OneRowDropDownViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_tvData: UITableView!

    private var m_DDPlace: OneRowDropDownView? = nil
    private var m_Data1: [NTRationStruct] = [NTRationStruct]()
    private let m_tfPicker: UITextField = UITextField()
    private var m_PickerData = [[String:[String]]]()
    private var bankCode = [String:String]()

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        setShadowView(m_vPlace)
        setLoading(true)
        
        postRequest("Comm/COMM0402", "COMM0402", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07002","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description: String, _ response: NSDictionary) {
        switch description {
        case "MANG0201":
            m_Data1.removeAll()
            if let data = response.object(forKey: "Data") as? [String:Any] {
                if let list = data["Result"] as? [[String:Any]] {
                    for info in list {
                        if let name = info["FC_Name"] as? String, let buy = info["CashToBuy"] as? Double, let sole = info["CashIsSold"] as? Double {
                            m_Data1.append( NTRationStruct(name, String(buy), String(sole)) )
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            m_tvData.reloadData()
            
        case "COMM0402":
            m_PickerData.removeAll()
            if let data = response.object(forKey: "Data") as? [String : Any], let array = data["Result"] as? [[String:Any]] {
                let cCode = (SecurityUtility.utility.readFileByKey(SetKey: File_CityCode_Key, setDecryptKey: AES_Key) as? String) ?? ""
                let bCode = (SecurityUtility.utility.readFileByKey(SetKey: File_BankCode_Key, setDecryptKey: AES_Key) as? String) ?? ""
                var cCity:String? = nil
                var cBank:String? = nil
                for dic in array {
                    var bankList = [String]()
                    if let city = dic["hsienName"] as? String, let cityID = dic["hsienCode"] as? String, let list = dic["bankList"] as? [[String:Any]] {
                        cCity = (cityID == cCode) ? city : cCity
                        for bank in list {
                            if let name = bank["bankName"] as? String {
                                bankList.append(name)
                                if let code = bank["bankCode"] as? String {
                                    bankCode["\(city)\(name)"] = code
                                    cBank = (code == bCode) ? name : cBank
                                }
                            }
                        }
                        m_PickerData.append([city:bankList])
                    }
                }
                if cCity != nil && cBank != nil {
                    m_DDPlace?.setOneRow(ExchangeRate_Bank_Title, cCity!+" "+cBank!)
                    setLoading(true)
                    postRequest("Mang/MANG0201", "MANG0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"06002","Operate":"queryData","BR_CODE":"\(bCode)"], false), AuthorizationManage.manage.getHttpHead(false))
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: -Private
    private func setAllSubView() {
        setDDPlace()
        setDataTableView()
    }
    
    private func setDDPlace() {
        if m_DDPlace == nil {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow(ExchangeRate_Bank_Title, Choose_Title)
            m_DDPlace?.m_lbFirstRowTitle.textAlignment = .center
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
        m_vPlace.layer.borderColor = Gray_Color.cgColor
        m_vPlace.layer.borderWidth = 1
    }
    
    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_NTRationCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NTRationCell.NibName()!)
        m_tvData.allowsSelection = false
    }
    
    private func setPicker() {
        m_tfPicker.delegate = self
        m_vPlace.addSubview(m_tfPicker)
        
        // UIPickerView
        let pickerView = UIPickerView(frame: CGRect(x:0, y:self.view.frame.height-PickView_Height, width:self.view.frame.width, height:PickView_Height))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.selectRow(0, inComponent: 0, animated: false)
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barTintColor = ToolBar_barTintColor
        toolBar.tintColor = ToolBar_tintColor
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: ToolBar_DoneButton_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: ToolBar_CancelButton_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ToolBar_Title_Weight, height: toolBar.frame.height))
        titleLabel.textColor = .black
        titleLabel.text = Choose_Title
        titleLabel.textAlignment = .center
        let titleButton = UIBarButtonItem(customView: titleLabel)
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        m_tfPicker.inputAccessoryView = toolBar
        m_tfPicker.inputView = pickerView
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if m_Data1.count > 0 {
            textFieldShouldBeginEditing(m_tfPicker)
            m_tfPicker.becomeFirstResponder()
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ExchangeRate_Cell_Height
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_Data1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_NTRationCell.NibName()!, for: indexPath) as! NTRationCell
        let data = m_Data1[indexPath.row]
        cell.setData(data.title!, data.data1!, data.data2!)
        return cell
    }
    
    // MARK: - For Picker
    func clickCancelBtn(_ sender:Any) {
        m_tfPicker.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        let pickerView = m_tfPicker.inputView as! UIPickerView
        let a = m_PickerData[pickerView.selectedRow(inComponent: 0)]
        let city = [String](a.keys).first ?? ""
        let place = a[city]?[pickerView.selectedRow(inComponent: 1)] ?? ""
        m_DDPlace?.setOneRow(ExchangeRate_Bank_Title, city+" "+place)
        m_tfPicker.resignFirstResponder()
        
        if let code = bankCode["\(city)\(place)"] {
            setLoading(true)
            postRequest("Mang/MANG0201", "MANG0201", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"06002","Operate":"queryData","BR_CODE":"\(code)"], false), AuthorizationManage.manage.getHttpHead(false))
        }
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
        if component == 0 {
            return m_PickerData.count
        }
        else {
            let a = m_PickerData[pickerView.selectedRow(inComponent: 0)]
            let city = [String](a.keys).first ?? ""
            return (a[city]?.count)!
        }
    }
    
    // MARK - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let a = m_PickerData[row]
            return [String](a.keys).first
        }
        else {
            let a = m_PickerData[pickerView.selectedRow(inComponent: 0)]
            let city = [String](a.keys).first ?? ""
            return a[city]?[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
    }
}
