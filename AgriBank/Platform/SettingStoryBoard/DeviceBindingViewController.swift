//
//  DeviceBindingViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DeviceBindingResult_Segue = "GoDeviceBindingResult"
let DeviceBinding_Bank_Title = "農會"
let DeviceBinding_ID_Length:Int = 10
let DeviceBinding_UserCode_Length:Int = 16
let DeviceBinding_Password_Length:Int = 16
let DeviceBinding_CheckCode_Length:Int = 7
let DeviceBinding_Binding_Success_Title = "綁定成功"
let DeviceBinding_Binding_Faild_Title = "綁定失敗"
let DeviceBinding_Memo = "恭喜您已成功綁定此設備！\n若想取消此設備綁定，\n請至本中心網路銀行網頁辦理。"

class DeviceBindingViewController: BaseViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var identifyTextfield: TextField!
    @IBOutlet weak var userCodeTextfield: TextField!
    @IBOutlet weak var passwordTextfield: TextField!
    @IBOutlet weak var checkCodeTextfield: TextField!
    @IBOutlet weak var bottomVIew: UIView!
    @IBOutlet weak var topTextfield: UITextField!
    
    private var topDropView:OneRowDropDownView? = nil
    private var bankList = [[String:[String]]]()
    private var bankCode = [String:String]()
    private var cityCode = [String:String]()
    private var bindingSuccess = false
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.setOneRow(DeviceBinding_Bank_Title, Choose_Title)
        topDropView?.m_lbFirstRowTitle.textAlignment = .center
        topView.addSubview(topDropView!)
        
        setShadowView(bottomVIew)
        addGestureForKeyBoard()
        
        getCanLoginBankInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BasicInfoResultViewController
        controller.setInitial(nil, bindingSuccess, bindingSuccess ? DeviceBinding_Binding_Success_Title : DeviceBinding_Binding_Faild_Title, DeviceBinding_Memo)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0403":
            if let data = response.object(forKey: ReturnData_Key) as? [String : Any], let array = data["Result"] as? [[String:Any]] {
                for dic in array {
                    var bankNameList = [String]()
                    if let city = dic["hsienName"] as? String, let cityID = dic["hsienCode"] as? String, let list = dic["bankList"] as? [[String:Any]] {
                        for bank in list {
                            if let name = bank["bankName"] as? String {
                                bankNameList.append(name)
                                if let code = bank["bankCode"] as? String {
                                    bankCode["\(city)\(name)"] = code
                                }
                            }
                        }
                        bankList.append( [city:bankNameList] )
                        cityCode[city] = cityID
                    }
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
            if let cCode = SecurityUtility.utility.readFileByKey(SetKey: File_CityCode_Key, setDecryptKey: AES_Key) as? String, let bCode = SecurityUtility.utility.readFileByKey(SetKey: File_BankCode_Key, setDecryptKey: AES_Key) as? String {
                var city = ""
                for key in cityCode.keys {
                    if cityCode[key] == cCode {
                        city = key
                        break
                    }
                }
                var bank = ""
                for key in bankCode.keys {
                    if bankCode[key] == bCode {
                        bank = key.replacingOccurrences(of: city, with: "")
                        break
                    }
                }
                if !city.isEmpty && !bank.isEmpty {
                    topDropView?.setOneRow(DeviceBinding_Bank_Title, city + " " + bank)
                }
            }
            
        case "COMM0801":
            VaktenManager.sharedInstance().associationOperation(withAssociationCode: checkCodeTextfield.text ?? "") { resultCode in
                if VIsSuccessful(resultCode) {
                    self.bindingSuccess = true
                }
                self.performSegue(withIdentifier: DeviceBindingResult_Segue, sender: self)
            }
            
        default: break
        }
    }
    
    // MARK: - Private
    private func addPickerView(_ textField:UITextField) {
        var frame = view.frame
        frame.origin.y = frame.maxY - PickView_Height
        frame.size.height = PickView_Height
        // UIPickerView
        let pickerView = UIPickerView(frame: frame)
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
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerView
    }
    
    private func inputIsCorrect() -> Bool {
        if topDropView?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (identifyTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(identifyTextfield.placeholder ?? "")")
            return false
        }
        if !DetermineUtility.utility.isValidIdentify(identifyTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Error_Identify)
            return false
        }
        if DetermineUtility.utility.checkStringContainIllegalCharacter(identifyTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        if (userCodeTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(userCodeTextfield.placeholder ?? "")")
            return false
        }
        if DetermineUtility.utility.checkStringContainIllegalCharacter(userCodeTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        if (passwordTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(passwordTextfield.placeholder ?? "")")
            return false
        }
        if DetermineUtility.utility.checkStringContainIllegalCharacter(passwordTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        if (checkCodeTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(checkCodeTextfield.placeholder ?? "")")
            return false
        }
        return true
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == topTextfield {
            addPickerView(textField)
            textField.tintColor = .clear
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.characters.count)! - range.length + string.characters.count
        var maxLength = 0
        switch textField {
        case identifyTextfield:
            maxLength = DeviceBinding_ID_Length
            
        case userCodeTextfield:
            maxLength = DeviceBinding_UserCode_Length
            
        case passwordTextfield:
            maxLength = DeviceBinding_Password_Length
            
        case checkCodeTextfield:
            maxLength = DeviceBinding_CheckCode_Length
            
        default: break
        }
        
        if newLength <= maxLength {
            return true
        }
        else {
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickBindingBtn(_ sender: Any) {
        if inputIsCorrect() {
            setLoading(true)
            let uuid = UUID().uuidString
            VaktenManager.sharedInstance().authenticateOperation(withSessionID: uuid) { resultCode in
                if VIsSuccessful(resultCode) {
                    let bankCode = self.bankCode[self.topDropView?.getContentByType(.First).replacingOccurrences(of: " ", with: "") ?? ""] ?? ""
                    let id = SecurityUtility.utility.MD5(string: self.userCodeTextfield.text!)
                    let pd = SecurityUtility.utility.MD5(string: self.passwordTextfield.text!)
                    self.postRequest("COMM/COMM0801", "COMM0801", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08011","Operate":"queryData","BR_CODE":bankCode,"ID_DATA":self.identifyTextfield.text!,"USER_ID":id,"PWD":pd,"ASSOCIATIONCODE":self.checkCodeTextfield.text!,"SessionId":uuid], true), AuthorizationManage.manage.getHttpHead(true))
                }
                else {
                    self.showErrorMessage(nil, ErrorMsg_Verification_Faild)
                    self.setLoading(false)
                }
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return bankList.count
        }
        else {
            let dic = bankList[pickerView.selectedRow(inComponent: 0)]
            let city = [String](dic.keys).first ?? ""
            return (dic[city]?.count)!
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let dic = bankList[row]
            return [String](dic.keys).first
        }
        else {
            let dic = bankList[pickerView.selectedRow(inComponent: 0)]
            let city = [String](dic.keys).first ?? ""
            return dic[city]?[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
    }
    
    // MARK: - selector
    func clickCancelBtn(_ sender:Any) {
        topTextfield.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        let pickerView = topTextfield.inputView as! UIPickerView
        let dic = bankList[pickerView.selectedRow(inComponent: 0)]
        let city = [String](dic.keys).first ?? ""
        let place = dic[city]?[pickerView.selectedRow(inComponent: 1)] ?? ""
        topDropView?.setOneRow(DeviceBinding_Bank_Title, city + " " + place)
        topTextfield.resignFirstResponder()
    }
}
