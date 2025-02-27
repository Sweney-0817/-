//
//  ExchangeRateViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/5.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ExchangeRate_Bank_Title = "農漁會"
let ExchangeRate_Cell_Height:CGFloat = 60
let ExchangeRate_Memo = "本資料僅供參考，實際匯率以臨櫃交易當時匯率為準"

class ExchangeRateViewController: BaseViewController, OneRowDropDownViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_tvData: UITableView!

    private var m_DDPlace: OneRowDropDownView? = nil
    private var m_Data1: [NTRationStruct] = [NTRationStruct]()
    private let m_tfPicker: UITextField = UITextField()
    private var m_PickerData = [[String:[String]]]()
    private var bankCode = [String:String]()
    private var curPickerRow1 = 0
    private var curPickerRow2 = 0

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_tfPicker.delegate = self
        m_vPlace.addSubview(m_tfPicker)
        
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
        
        m_tvData.register(UINib(nibName: UIID.UIID_ExchangeRateCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ExchangeRateCell.NibName()!)
        
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
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let list = data["Result"] as? [[String:Any]] {
                    for info in list {
                        var FC_Name = "-"
                        if let temp = info["FC_Name"] as? String {
                            FC_Name = temp
                        }
                        var CashToBuy = "-"
                        if let temp = info["CashToBuy"] as? String {
                            CashToBuy = temp
                        }
                        var CashIsSold = "-"
                        if let temp = info["CashIsSold"] as? String {
                            CashIsSold = temp
                        }
                        m_Data1.append( NTRationStruct(FC_Name, CashToBuy, CashIsSold) )
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            m_tvData.reloadData()
            
        case "COMM0402":
            m_PickerData.removeAll()
            if let data = response.object(forKey: ReturnData_Key) as? [String : Any], let array = data["Result"] as? [[String:Any]] {
                let cCode = (SecurityUtility.utility.readFileByKey(SetKey: File_CityCode_Key, setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String) ?? ""
                let bCode = (SecurityUtility.utility.readFileByKey(SetKey: File_BankCode_Key, setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String) ?? ""
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
                    for index in 0..<m_PickerData.count {
                        if let array = m_PickerData[index][cCity!] {
                            curPickerRow1 = index
                            for i in 0..<array.count {
                                if array[i] == cBank! {
                                    curPickerRow2 = i
                                    break
                                }
                            }
                            break
                        }
                    }
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
    private func setPicker() {
        // UIPickerView
        let pickerView = UIPickerView(frame: CGRect(x:0, y:self.view.frame.height-PickView_Height, width:self.view.frame.width, height:PickView_Height))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.selectRow(curPickerRow1, inComponent: 0, animated: false)
        pickerView.selectRow(curPickerRow2, inComponent: 1, animated: false)
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barTintColor = ToolBar_barTintColor
        toolBar.tintColor = ToolBar_tintColor
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: Determine_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Cancel_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
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
        if m_PickerData.count > 0 {
            _ = textFieldShouldBeginEditing(m_tfPicker)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ExchangeRateCell.NibName()!, for: indexPath) as! ExchangeRateCell
        let data = m_Data1[indexPath.row]
        cell.setData(data.title!, data.data1!, data.data2!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.sectionFooterHeight))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.width-20, height: view.frame.height))
        label.text = ExchangeRate_Memo
        label.font = Default_Font
        label.textColor = Green_Color
        label.textAlignment = .left
        label.numberOfLines = 0
        view.addSubview(label)
        return view
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
            m_Data1.removeAll()
            m_tvData.reloadData()
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
            let a = m_PickerData[curPickerRow1]
            let city = [String](a.keys).first ?? ""
            return a[city]?.count ?? 0
        }
    }
    
    // MARK - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let a = m_PickerData[row]
            return [String](a.keys).first
        }
        else {
            if pickerView.selectedRow(inComponent: 0) < m_PickerData.count {
                let a = m_PickerData[pickerView.selectedRow(inComponent: 0)]
                let city = [String](a.keys).first ?? ""
                if let count = a[city]?.count, row < count {
                    return a[city]?[row]
                }
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            curPickerRow1 = row
            curPickerRow2 = 0
            pickerView.reloadComponent(1)
            pickerView.selectRow(curPickerRow2, inComponent: 1, animated: false)
        }
        else {
            curPickerRow2 = row
        }
    }
}
