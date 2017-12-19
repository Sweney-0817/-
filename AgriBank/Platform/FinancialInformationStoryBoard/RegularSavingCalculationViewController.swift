//
//  RegularSavingCalculationViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/5.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let RegularSavingCalculation_TypeList = ["存本取息","零存整付","整存整付"]
let RegularSavingCalculation_MonthList = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36"]
let RegularSavingCalculation_MaxRate:CGFloat = 18
let RegularSavingCalculation_MaxLength = 12

class RegularSavingCalculationViewController: BaseViewController, ChooseTypeDelegate, UITextFieldDelegate, UIActionSheetDelegate {
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vAmount: UIView!
    @IBOutlet weak var m_tfAmount: TextField!
    @IBOutlet weak var m_vDuration: UIView!
    @IBOutlet weak var m_tfDuration: TextField!
    @IBOutlet weak var m_consDurationHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vRate: UIView!
    @IBOutlet weak var m_tfRate: TextField!
    @IBOutlet weak var m_vResult: UIView!
    @IBOutlet weak var m_lbResultTitle: UILabel!
    @IBOutlet weak var m_lbResult: UILabel!
    @IBOutlet weak var bottomView: UIView!
    private var currentType = RegularSavingCalculation_TypeList[0]
    private var currentTextField:UITextField? = nil
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnCalculateClick(_ sender: Any) {
        // 參照 https://ebank.naffic.org.tw/ibank/Login/A001_3
        if inputIsCorrect() {
            let sum = Double( m_tfAmount.text ?? "0" ) ?? 0
            let rate = (Double( m_tfRate.text ?? "0" ) ?? 0) / Double(12) / Double(100)
            switch currentType {
            case RegularSavingCalculation_TypeList[0]:
                //公式=1.存款金額 * (年利率/12) = 每月可領利息
                let interest = Int(sum * rate+0.5)
                m_lbResult.text = String(interest)
                
            case RegularSavingCalculation_TypeList[1]:
                var rate_t = Double(1)
                let month = Int(m_tfDuration.text ?? "0") ?? 0
                for _ in 0..<month {
                    rate_t *= (1 + rate)
                }
                let total = Int(sum * (rate_t - 1) / rate * (1 + rate) + 0.5)
                m_lbResult.text = String(total)
                
            case RegularSavingCalculation_TypeList[2]:
                var total = sum;
                let month = Int(m_tfDuration.text ?? "0") ?? 0
                for _ in 0..<month {
                    total *= (1 + rate)
                }
                m_lbResult.text = String(Int(total+0.5))
                
            default: break
            }
        }
    }
    
    @IBAction func m_btnClearClick(_ sender: Any) {
        clearData()
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        initInputForType(RegularSavingCalculation_TypeList.first!)
        setShadowView(m_vChooseTypeView)
        setShadowView(m_vShadowView)
        setShadowView(m_vResult)
        setShadowView(bottomView, .Top)
        addGestureForKeyBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    private func setAllSubView() {
        setChooseTypeView()
        setAmountView()
        setDurationView()
        setRateView()
        setResultView()
    }
    
    private func setChooseTypeView() {
        let width = view.frame.width / CGFloat(RegularSavingCalculation_TypeList.count)
        m_vChooseTypeView.setTypeList(RegularSavingCalculation_TypeList, setDelegate: self, nil, width)
    }
    
    private func setAmountView() {
        m_vAmount.layer.borderColor = Gray_Color.cgColor
        m_vAmount.layer.borderWidth = 1
    }
    
    private func setDurationView() {
        m_vDuration.layer.borderColor = Gray_Color.cgColor
        m_vDuration.layer.borderWidth = 1
    }
    
    private func setRateView() {
        m_vRate.layer.borderColor = Gray_Color.cgColor
        m_vRate.layer.borderWidth = 1
    }
    
    private func setResultView() {
        m_vResult.layer.borderColor = Gray_Color.cgColor
        m_vResult.layer.borderWidth = 1
    }
    
    private func clearData() {
        m_tfAmount.text = ""
        m_tfDuration.text = ""
        m_tfRate.text = ""
        m_lbResult.text = "-"
    }
    
    private func initInputForType(_ type:String) {
        currentType = type
        if type == RegularSavingCalculation_TypeList[0] {
            m_consDurationHeight.constant = 1
            m_tfDuration.isHidden = true
            m_lbResultTitle.text = "每月利息"
        }
        else {
            m_consDurationHeight.constant = 60
            m_tfDuration.isHidden = false
            m_lbResultTitle.text = "到期本利和(複利)"
        }
        clearData()
    }
    
    private func inputIsCorrect() -> Bool {
        if (m_tfAmount.text?.isEmpty)! {
            showErrorMessage(nil, ErrorMsg_Enter_SaveAmount)
            return false
        }
        else {
            if let amount = Int(m_tfAmount.text!), amount == 0 {
                showErrorMessage(nil, m_tfAmount.placeholder!+ErrorMsg_Not_Zero)
                return false
            }
        }
        
        switch currentType {
        case RegularSavingCalculation_TypeList[0]:
            if (m_tfRate.text?.isEmpty)! {
                showErrorMessage(nil, ErrorMsg_Enter_SaveRate)
                return false
            }
            let formatter = NumberFormatter()
            if let rate = formatter.number(from: m_tfRate.text!) {
                if CGFloat(rate) <= RegularSavingCalculation_MaxRate {
                    if CGFloat(rate) == 0 {
                        showErrorMessage(nil, m_tfRate.placeholder!+ErrorMsg_Not_Zero)
                        return false
                    }
                }
                else  {
                    showErrorMessage(nil, ErrorMsg_GreaterThan_MaxRate)
                    return false
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_Format)
                return false
            }
            
        case RegularSavingCalculation_TypeList[1], RegularSavingCalculation_TypeList[2]:
            if (m_tfDuration.text?.isEmpty)! {
                showErrorMessage(nil, ErrorMsg_Choose_SaveDuration)
                return false
            }
            if (m_tfRate.text?.isEmpty)! {
                showErrorMessage(nil, ErrorMsg_Enter_SaveRate)
                return false
            }
            let formatter = NumberFormatter()
            if let rate = formatter.number(from: m_tfRate.text!) {
                if CGFloat(rate) <= RegularSavingCalculation_MaxRate {
                    if CGFloat(rate) == 0 {
                        showErrorMessage(nil, m_tfRate.placeholder!+ErrorMsg_Not_Zero)
                        return false
                    }
                }
                else  {
                    showErrorMessage(nil, ErrorMsg_GreaterThan_MaxRate)
                    return false
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_Format)
                return false
            }
            
        default: break
        }
        
        return true
    }
    
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        initInputForType(name)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == m_tfDuration {
            if currentTextField != textField {
                currentTextField?.resignFirstResponder()
                currentTextField = textField
            }
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            RegularSavingCalculation_MonthList.forEach{ title in actSheet.addButton(withTitle: title) }
            actSheet.show(in: view)
            return false
        }
        else {
            currentTextField = textField
        }
  
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == m_tfAmount {
            if newString.count > RegularSavingCalculation_MaxLength {
                return false
            }
        }
        return true
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            m_tfDuration.text = actionSheet.buttonTitle(at: buttonIndex)
        }
    }
    
    // MARK: - LoginDelegate
    override func clickLoginCloseBtn() {
        /* 避免手勢被清除 and 把Observer移除 */
        loginView?.removeFromSuperview()
        loginView = nil
        curFeatureID = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}
