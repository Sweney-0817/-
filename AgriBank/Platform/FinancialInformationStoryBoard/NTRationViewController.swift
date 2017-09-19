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

let NTRationView_TypeList = ["活存","定期","定儲","其他"]
let NTRationView_Bank_Title = "農會"

class NTRationViewController: BaseViewController, OneRowDropDownViewDelegate, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_vTitle: UIView!
    @IBOutlet weak var m_lbData1Title: UILabel!
    @IBOutlet weak var m_lbData2Title: UILabel!
    @IBOutlet weak var m_tvData: UITableView!

    private var m_DDPlace: OneRowDropDownView? = nil
    private var m_strType: String? = nil
    private var m_Data1: [NTRationStruct] = [NTRationStruct]()
    private var m_Data2: [NTRationStruct] = [NTRationStruct]()
    private var m_Data3: [NTRationStruct] = [NTRationStruct]()
    private var m_Data4: [NTRationStruct] = [NTRationStruct]()
    private let m_tfPicker:UITextField = UITextField()
    private var m_PickerData = [[String:[String]]]()
    private var bankCode = [String:String]()
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        initDataTitleForType(NTRationView_TypeList.first!)
        setShadowView(m_vChooseTypeView)
        setLoading(true)
        postRequest("Comm/COMM0402", "COMM0402", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07002","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description: String, _ response: NSDictionary) {
        switch description {
        case "MANG0101":
            m_Data1.removeAll()
            m_Data2.removeAll()
            m_Data3.removeAll()
            m_Data4.removeAll()
            if let data = response.object(forKey: "Data") as? [String:Any] {
                if let list = data["SurviveRateList"] as? [[String:Any]] {
                    for info in list {
                        var SurviveType = "-"
                        if let temp = info["SurviveType"] as? String {
                            SurviveType = temp
                        }
                        var SurviveRate = "-"
                        if let temp = info["SurviveRate"] as? String {
                            SurviveRate = temp
                        }
                        m_Data1.append( NTRationStruct(SurviveType, "", SurviveRate) )
                    }
                }
                if let list = data["TDRateList"] as? [[String:Any]] {
                    for info in list {
                        var TDType = "-"
                        if let temp = info["TDType"] as? String {
                            TDType = temp
                        }
                        var TDFixRate = "-"
                        if let temp = info["TDFixRate"] as? String {
                            TDFixRate = temp
                        }
                        var TDChangeRate = "-"
                        if let temp = info["TDChangeRate"] as? String {
                            TDChangeRate = temp
                        }
                        m_Data2.append( NTRationStruct(TDType, TDFixRate, TDChangeRate) )
                    }
                }
                if let list = data["RSRateList"] as? [[String:Any]] {
                    for info in list {
                        var RSType = "-"
                        if let temp = info["RSType"] as? String {
                            RSType = temp
                        }
                        var RSFixRate = "-"
                        if let temp = info["RSFixRate"] as? String {
                            RSFixRate = temp
                        }
                        var RSChangeRate = "-"
                        if let temp = info["RSChangeRate"] as? String {
                            RSChangeRate = temp
                        }
                        m_Data3.append( NTRationStruct(RSType, RSFixRate, RSChangeRate) )
                    }
                }
                if let list = data["OTRateList"] as? [[String:Any]] {
                    for info in list {
                        var OTType = "-"
                        if let temp = info["OTType"] as? String {
                            OTType = temp
                        }
                        var OTRate = "-"
                        if let temp = info["OTRate"] as? String {
                            OTRate = temp
                        }
                        m_Data4.append( NTRationStruct(OTType, "", OTRate) )
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
                    m_DDPlace?.setOneRow(NTRationView_Bank_Title, cCity!+" "+cBank!)
                    setLoading(true)
                    postRequest("Mang/MANG0101", "MANG0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"06001","Operate":"queryData","BR_CODE":"\(bCode)"], false), AuthorizationManage.manage.getHttpHead(false))
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func setAllSubView() {
        setDDPlace()
        setChooseTypeView()
        setDataTableView()
    }
    
    private func setDDPlace() {
        if m_DDPlace == nil {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow(NTRationView_Bank_Title, Choose_Title)
            m_DDPlace?.m_lbFirstRowTitle.textAlignment = .center
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
        m_vPlace.layer.borderColor = Gray_Color.cgColor
        m_vPlace.layer.borderWidth = 1
    }
    
    private func setChooseTypeView() {
        m_vChooseTypeView.setTypeList(NTRationView_TypeList, setDelegate: self)
        m_vChooseTypeView.layer.borderColor = Gray_Color.cgColor
        m_vChooseTypeView.layer.borderWidth = 1
    }
    
    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_NTRationCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_NTRationCell.NibName()!)
        m_tvData.allowsSelection = false
    }
    
    private func setPicker() {
        if m_PickerData.count == 0 {
            return
        }
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
    
    private func initDataTitleForType(_ type:String) {
        m_strType = type
        switch type {
            case NTRationView_TypeList[0], NTRationView_TypeList[3]:
                m_lbData1Title.text = ""
                m_lbData2Title.text = "利率"
            case NTRationView_TypeList[1], NTRationView_TypeList[2]:
                m_lbData1Title.text = "固定利率"
                m_lbData2Title.text = "機動利率"
        default:
            m_lbData1Title.text = ""
            m_lbData2Title.text = ""
            
        }
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        textFieldShouldBeginEditing(m_tfPicker)
        m_tfPicker.becomeFirstResponder()
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
            case NTRationView_TypeList[0]:
            return m_Data1.count
            case NTRationView_TypeList[1]:
            return m_Data2.count
            case NTRationView_TypeList[2]:
            return m_Data3.count
            case NTRationView_TypeList[3]:
            return m_Data4.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_NTRationCell.NibName()!, for: indexPath) as! NTRationCell
        switch m_strType! {
        case NTRationView_TypeList[0]:
            let data = m_Data1[indexPath.row]
            cell.setData(data.title!, data.data1!, data.data2!)
        case NTRationView_TypeList[1]:
            let data = m_Data2[indexPath.row]
            cell.setData(data.title!, data.data1!, data.data2!)
        case NTRationView_TypeList[2]:
            let data = m_Data3[indexPath.row]
            cell.setData(data.title!, data.data1!, data.data2!)
        case NTRationView_TypeList[3]:
            let data = m_Data4[indexPath.row]
            cell.setData(data.title!, data.data1!, data.data2!)
        default:
            cell.setData("", "", "")
        }
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
        m_DDPlace?.setOneRow(NTRationView_Bank_Title, city+" "+place)
        m_tfPicker.resignFirstResponder()
        
        if let code = bankCode["\(city)\(place)"] {
            setLoading(true)
            postRequest("Mang/MANG0101", "MANG0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"06001","Operate":"queryData","BR_CODE":"\(code)"], false), AuthorizationManage.manage.getHttpHead(false))
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
