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
}

class LoginView: UIView, ConnectionUtilityDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ImageConfirmViewDelegate {
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var idTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageConfirmView: UIView!
    private var request:ConnectionUtility? = nil
    private var list = [[String:[String]]]()
    private var bankCode = [String:String]()
    private var cityCode = [String:String]()
    private var currnetCity:String? = nil
    private var isLocker = false
    private var currentTextField:UITextField? = nil
    private var delegate:LoginDelegate? = nil
    private var loginInfo = LoginStrcture()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let view = Platform.plat.getUIByID(.UIID_ImageConfirmView) as! ImageConfirmView
        view.frame = imageConfirmView.frame
        view.frame.origin = .zero
        view.delegate = self
        imageConfirmView.addSubview(view)
    }
    
    // MARK: - pubic
    func setInitialList(_ list:[[String:[String]]], _ bankCode:[String:String], _ cityCode:[String:String], _ city:String, _ delegate:LoginDelegate) {
        self.list = list
        self.bankCode = bankCode
        self.cityCode = cityCode
        currnetCity = city
        self.delegate = delegate
        accountTextfield.text = "A123456789"
        idTextfield.text = "Systexsoftware"
        passwordTextfield.text = "systex6214"
    }
    
    func isNeedRise() -> Bool {
        if currentTextField == locationTextfield || currentTextField == accountTextfield {
            return false
        }
        
        return true
    }
    
    // MARK: - private
    private func postRequest(_ strMethod:String, _ strSessionDescription:String, _ needCertificate:Bool = false,  _ httpBody:Data? = nil, _ dicHttpHead:[String:String]? = nil, _ strURL:String? = nil)  {
        request = ConnectionUtility()
        request?.postRequest(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, dicHttpHead, needCertificate)
    }
    
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
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = ToolBar_tintColor
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: ToolBar_DoneButton_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: ToolBar_CancelButton_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerView
    }
    
    private func InputIsCorrect() -> Bool {
        return true
    }
    
    // MARK: - Xib Touch Event
    @IBAction func clickCloseBtn(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func clickLoginBtn(_ sender: Any) {
        if InputIsCorrect() {
            loginInfo.bankCode = bankCode[locationTextfield.text?.replacingOccurrences(of: " ", with: "") ?? ""] ?? loginInfo.bankCode
            loginInfo.account = accountTextfield.text ?? loginInfo.account
            loginInfo.id = idTextfield.text ?? loginInfo.id
            loginInfo.password = passwordTextfield.text ?? loginInfo.password
            let city = locationTextfield.text?.components(separatedBy: " ").first ?? ""
            loginInfo.cityCode = cityCode[city] ?? loginInfo.cityCode
            delegate?.clickLoginBtn(loginInfo)
            removeFromSuperview()
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
    
    @IBAction func clickRefreshBtn(_ sender: Any) {
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
    
    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        
    }
    
    func didFailedWithError(_ error: Error) {
        
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField != locationTextfield && textField != accountTextfield {
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        if textField == locationTextfield {
            addPickerView(textField)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !DetermineUtility.utility.checkStringContainIllegalCharacter( newString ) {
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
    
    // MARK - UIPickerViewDelegate
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
        
    }
    
    func changeInputTextfield(_ input: String){
        loginInfo.imgPassword = input
    }
}
