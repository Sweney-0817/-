//
//  LoginView.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/13.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit


let Login_PickView_Height:CGFloat = 250
let Login_ToolBar_tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
let Login_DoneButton_Title = "Done"
let Login_CancelButton_Title = "Cancel"

class LoginView: UIView, ConnectionUtilityDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var idTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var contentView: UIView!
    private var request:ConnectionUtility? = nil
    private var list:[String:[String]]? = nil
    private var currnetCity:String? = nil
    private var isLocker = false
    private var currentTextField:UITextField? = nil
    
    // MARK: - pubic
    func setInitialList(_ list:[String:[String]],_ city:String) {
        self.list = list
        currnetCity = city
    }
    
    func isNeedRise() -> Bool {
        if currentTextField == locationTextfield || currentTextField == accountTextfield {
            return false
        }
        
        return true
    }
    
    // MARK: - private
    private func postRequest(_ strMethod:String, _ strSessionDescription:String, _ needCertificate:Bool = false, _ dicHttpHead:[AnyHashable:Any]? = nil, _ strURL:String? = nil)  {
        request = ConnectionUtility()
        request?.postRequest(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, dicHttpHead, needCertificate)
    }
    
    private func addPickerView(_ textField:UITextField) {
        var frame = self.frame
        frame.origin.y = frame.maxY - Login_PickView_Height
        frame.size.height = Login_PickView_Height
        // UIPickerView
        let pickerView = UIPickerView(frame: frame)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.selectRow([String](list!.keys).index(of: currnetCity!)!, inComponent: 0, animated: false)
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
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerView
    }
    
    // MARK: - Xib Touch Event
    @IBAction func clickCloseBtn(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func clickLoginBtn(_ sender: Any) {
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
        let picker = locationTextfield.inputView as! UIPickerView
        locationTextfield.text = "\([String](list!.keys)[picker.selectedRow(inComponent: 0)])     \((list?[currnetCity!]?[picker.selectedRow(inComponent: 1)])!)"
        locationTextfield.resignFirstResponder()
    }
    
    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description:String, _ response: [String:Any]) {
        
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
            return true
        }
        else if textField == accountTextfield {
            return false
        }
        else {
            return true
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = 0
        component == 0 ? ( count = (list?.count)! ) : ( count = (list?[currnetCity!]?.count)! )
        return count
    }
    
    // MARK - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title:String? = nil
        if component == 0 {
            title = [String](list!.keys)[row]
        }
        else {
            if currnetCity != nil {
                title = list?[currnetCity!]?[row]
            }
        }
    
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currnetCity = [String](list!.keys)[row]
            pickerView.reloadComponent(1)
        }
    }
}
