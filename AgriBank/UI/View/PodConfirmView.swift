//
//  PODConfirmView.swift
//  AgriBank
//
//  Created by ABOT on 2022/3/17.
//  Copyright © 2022 Systex. All rights reserved.
//

import UIKit

protocol PodConfirmViewDelegate {
    func changeInputTextfield(_ input: String)
    func PODConfirmTextfieldBeginEditing(_ textfield:UITextField)
}

class PodConfirmView: UIView, UITextFieldDelegate {
 
    @IBOutlet weak var m_podInput: TextField!

    var delegate:PodConfirmViewDelegate? = nil
    
 

    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.PODConfirmTextfieldBeginEditing(textField)
        textField.autocorrectionType=UITextAutocorrectionType.no
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !DetermineUtility.utility.isEnglishAndNumber(newString) {
            return false
        }
        delegate?.changeInputTextfield(newString)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
