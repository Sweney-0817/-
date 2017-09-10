//
//  LoginView.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/13.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let Login_Account_Length = 10
let Login_ID_Length = 16
let Login_Password_Length = 10

struct LoginStrcture {
    var bankCode = ""
    var account = ""
    var id = ""
    var password = ""
    var imgPassword = ""
    var cityCode = ""
}

protocol LoginDelegate {
    func clickLoginBtn(_ info:LoginStrcture)
    func clickLoginRefreshBtn()
    func clickLoginCloseBtn()
}

class LoginView: UIView, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ImageConfirmViewDelegate {
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var idTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageConfirmView: UIView!
    @IBOutlet weak var lockButton: UIButton!
    
    private var request:ConnectionUtility? = nil
    private var list = [[String:[String]]]()
    private var bankCode = [String:String]()
    private var cityCode = [String:String]()
    private var isLocker = false
    private var currentTextField:UITextField? = nil
    private var delegate:LoginDelegate? = nil
    private var loginInfo = LoginStrcture()
    private var imgConfirm:ImageConfirmView? = nil
    private var curAccount:String? = nil
    
    // MARK: - Override
    override func layoutSubviews() {
        super.layoutSubviews()
        imgConfirm = Platform.plat.getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
        imgConfirm?.frame = imageConfirmView.frame
        imgConfirm?.frame.origin = .zero
        imgConfirm?.delegate = self
        imageConfirmView.addSubview(imgConfirm!)
        contentView.layer.cornerRadius = Layer_BorderRadius
        if let account = SecurityUtility.utility.readFileByKey(SetKey: File_Account_Key, setDecryptKey: AES_Key) as? String {
            isLocker = true
            if isLocker {
                lockButton.setBackgroundImage(UIImage(named: ImageName.Locker.rawValue), for: .normal)
            }
            else {
                lockButton.setBackgroundImage(UIImage(named: ImageName.Unlocker.rawValue), for: .normal)
            }
            accountTextfield.text = account
        }
    }
    
    // MARK: - Public
    func setInitialList(_ list:[[String:[String]]], _ bankCode:[String:String], _ cityCode:[String:String], _ delegate:LoginDelegate) {
        self.list = list
        self.bankCode = bankCode
        self.cityCode = cityCode
        self.delegate = delegate
    
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
                locationTextfield.text = city + " " + bank
            }
        }
    }
    
    func isNeedRise() -> Bool { // 畫面是否需要提高
        if currentTextField == locationTextfield || currentTextField == accountTextfield {
            return false
        }
        
        return true
    }
    
    func setImageConfirm(_ image:UIImage?) { // 設圖形驗證碼
        imgConfirm?.m_ivShow.image = image
    }
    
    func saveDataInFile() { // 登入成功後，儲存登入成功的農漁會代碼
        if isLocker {
            SecurityUtility.utility.writeFileByKey(loginInfo.account, SetKey: File_Account_Key, setEncryptKey: AES_Key)
        }
        else {
            SecurityUtility.utility.writeFileByKey(nil, SetKey: File_Account_Key)
        }
        SecurityUtility.utility.writeFileByKey(loginInfo.cityCode, SetKey: File_CityCode_Key, setEncryptKey: AES_Key)
        SecurityUtility.utility.writeFileByKey(loginInfo.bankCode, SetKey: File_BankCode_Key, setEncryptKey: AES_Key)
    }
    
    // MARK: - Private
    private func addPickerView(_ textField:UITextField) {
        var frame = self.frame
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
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerView
    }
    
    private func inputIsCorrect() -> String? {
        if (locationTextfield.text?.isEmpty)! {
            return ErrorMsg_Choose_CityBank
        }
        if (accountTextfield.text?.isEmpty)! {
            return ErrorMsg_Enter_Identify
        }
        else {
            if !DetermineUtility.utility.isValidIdentify(accountTextfield.text!) {
                return ErrorMsg_Error_Identify
            }
        }
        if (idTextfield.text?.isEmpty)! {
            return ErrorMsg_Enter_UserID
        }
        if (passwordTextfield.text?.isEmpty)! {
            return ErrorMsg_Enter_UserPassword
        }
        
        return nil
    }
    
    // MARK: - Xib Touch Event
    @IBAction func clickCloseBtn(_ sender: Any) {
        delegate?.clickLoginCloseBtn()
    }
    
    @IBAction func clickLoginBtn(_ sender: Any) {
        if let message = inputIsCorrect() {
            let alert = UIAlertView(title: UIAlert_Default_Title, message: message, delegate: nil, cancelButtonTitle:UIAlert_Confirm_Title)
            alert.show()
        }
        else {
            self.endEditing(true)
            loginInfo.bankCode = bankCode[locationTextfield.text?.replacingOccurrences(of: " ", with: "") ?? ""] ?? loginInfo.bankCode
            loginInfo.account = accountTextfield.text ?? loginInfo.account
            loginInfo.id = idTextfield.text ?? loginInfo.id
            loginInfo.password = passwordTextfield.text ?? loginInfo.password
            let city = locationTextfield.text?.components(separatedBy: " ").first ?? ""
            loginInfo.cityCode = cityCode[city] ?? loginInfo.cityCode
            delegate?.clickLoginBtn(loginInfo)
        }
    }
    
    @IBAction func clickLockBtn(_ sender: Any) {
        let btn = sender as! UIButton
        if isLocker {
            btn.setBackgroundImage(UIImage(named: ImageName.Unlocker.rawValue), for: .normal)
        }
        else {
            btn.setBackgroundImage(UIImage(named: ImageName.Locker.rawValue), for: .normal)
        }
        
        isLocker = !isLocker
    }

    // MARK: - selector
    func clickCancelBtn(_ sender:Any) {
        locationTextfield.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        let pickerView = locationTextfield.inputView as! UIPickerView
        let dic = list[pickerView.selectedRow(inComponent: 0)]
        let city = [String](dic.keys).first ?? ""
        let place = dic[city]?[pickerView.selectedRow(inComponent: 1)] ?? ""
        locationTextfield.text = city + " " + place
        locationTextfield.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentTextField = nil
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        if textField == locationTextfield {
            if list.count != 0 {
                addPickerView(textField)
            }
            else {
                return false
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if DetermineUtility.utility.checkStringContainIllegalCharacter( newString ) {
            return false
        }
        
        let newLength = (textField.text?.characters.count)! - range.length + string.characters.count
        var maxLength = 0
        switch textField {
        case accountTextfield:
            maxLength = Login_Account_Length
            
        case idTextfield:
            maxLength = Login_ID_Length
            
        case passwordTextfield:
            maxLength = Login_Password_Length
        
        default: break
        }
        
        if newLength <= maxLength {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return list.count
        }
        else {
            let dic = list[pickerView.selectedRow(inComponent: 0)]
            let city = [String](dic.keys).first ?? ""
            return (dic[city]?.count)!
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let dic = list[row]
            return [String](dic.keys).first
        }
        else {
            let dic = list[pickerView.selectedRow(inComponent: 0)]
            let city = [String](dic.keys).first ?? ""
            return dic[city]?[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
    }
    
    // MARK: - ImageConfirmViewDelegate
    func clickRefreshBtn() {
        delegate?.clickLoginRefreshBtn()
    }
    
    func changeInputTextfield(_ input: String){
        loginInfo.imgPassword = input
    }
    
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {
        currentTextField = textfield
    }
}
