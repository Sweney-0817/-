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
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "") {
            delegate?.changeInputTextfield(textField.text!.substring(to: textField.text!.index(textField.text!.endIndex, offsetBy:-1)))
        }
        else {
            let input = textField.text! + string
            delegate?.changeInputTextfield(input)
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
