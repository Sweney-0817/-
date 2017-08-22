//
//  ImageConfirmView.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/6.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

protocol ImageConfirmViewDelegate {
    func clickRefreshBtn()
    func changeInputTextfield(_ input: String)
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField)
}

class ImageConfirmView: UIView, UITextFieldDelegate {
    @IBOutlet weak var m_tfInput: UITextField!
    @IBOutlet weak var m_ivShow: UIImageView!
    @IBOutlet weak var m_btnRefresh: UIButton!
    @IBOutlet weak var m_vSeparator: UIView!
    var delegate:ImageConfirmViewDelegate? = nil
    
    
    @IBAction func m_btnRefreshClick(_ sender: Any) {
        delegate?.clickRefreshBtn()
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.ImageConfirmTextfieldBeginEditing(textField)
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
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            delegate?.changeInputTextfield(textField.text!.substring(to: textField.text!.index(textField.text!.endIndex, offsetBy:-1)))
        }
        else {
            let input = textField.text! + string
            delegate?.changeInputTextfield(input)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - selector
    func clickCancelBtn(_ sender:Any) {
        m_tfInput.text = ""
        m_tfInput.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        m_tfInput.resignFirstResponder()
    }
}
