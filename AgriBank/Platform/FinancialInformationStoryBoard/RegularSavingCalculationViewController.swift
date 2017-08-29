//
//  RegularSavingCalculationViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/5.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let RegularSavingCalculation_TypeList = ["存本取息","零存整付","整存整付"]
let RegularSavingCalculation_MonthList = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"]
let RegularSavingCalculation_MaxRate:CGFloat = 18
let RegularSavingCalculation_MaxLength = 12

class RegularSavingCalculationViewController: BaseViewController, ChooseTypeDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
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
    private var currentType = "存本取息"
    private var currentTextField:UITextField? = nil
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnCalculateClick(_ sender: Any) {
        // 參照 https://ebank.naffic.org.tw/ibank/Login/A001_3
        let sum = Double( m_tfAmount.text ?? "0" ) ?? 0
        let rate = (Double( m_tfRate.text ?? "0" ) ?? 0) / Double(12) / Double(100)
        switch currentType {
        case "存本取息":
            //公式=1.存款金額 * (年利率/12) = 每月可領利息
            let interest = Int(sum * rate+0.5)
            m_lbResult.text = String(interest)
            
        case "零存整付":
            var rate_t = Double(1)
            let month = Int(m_tfDuration.text ?? "0") ?? 0
            for _ in 0..<month {
                rate_t *= (1 + rate)
            }
            let total = Int(sum * (rate_t - 1) / rate * (1 + rate) + 0.5)
            m_lbResult.text = String(total)
            
        case "整存整付":
            var total = sum;
            let month = Int(m_tfDuration.text ?? "0") ?? 0
            for _ in 0..<month {
                total *= (1 + rate)
            }
            m_lbResult.text = String(Int(total+0.5))
            
        default: break
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
    }
    
    func setAllSubView() {
        setChooseTypeView()
        setAmountView()
        setDurationView()
        setRateView()
        setResultView()
    }
    
    func setChooseTypeView() {
        m_vChooseTypeView.setTypeList(RegularSavingCalculation_TypeList, setDelegate: self)
    }
    
    func setAmountView() {
        m_vAmount.layer.borderColor = Gray_Color.cgColor
        m_vAmount.layer.borderWidth = 1
    }
    
    func setDurationView() {
        m_vDuration.layer.borderColor = Gray_Color.cgColor
        m_vDuration.layer.borderWidth = 1
    }
    
    func setRateView() {
        m_vRate.layer.borderColor = Gray_Color.cgColor
        m_vRate.layer.borderWidth = 1
    }
    
    func setResultView() {
        m_vResult.layer.borderColor = Gray_Color.cgColor
        m_vResult.layer.borderWidth = 1
    }
    
    func clearData() {
        m_tfAmount.text = ""
        m_tfDuration.text = ""
        m_tfRate.text = ""
        m_lbResult.text = "-"
    }
    
    func initInputForType(_ type:String) {
        currentType = type
        if (type == "存本取息") {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        initInputForType(name)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        if textField == m_tfDuration {
            // UIPickerView
            let pickerView = UIPickerView(frame: CGRect(x:0, y:self.view.frame.height-PickView_Height, width:self.view.frame.width, height:PickView_Height))
            pickerView.dataSource = self
            pickerView.delegate = self
            pickerView.backgroundColor = .white
            pickerView.selectRow(0, inComponent: 0, animated: false)
            textField.inputView = pickerView
        }
  
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barTintColor = ToolBar_barTintColor
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
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == m_tfRate {
            let formatter = NumberFormatter()
            if let rate = formatter.number(from: newString), CGFloat(rate) <= RegularSavingCalculation_MaxRate {
                return true
            }
            else {
                return newString.isEmpty
            }
        }
        else if textField == m_tfAmount {
            if newString.characters.count > RegularSavingCalculation_MaxLength {
                return false
            }
        }
        return true
    }
    
    // MARK: - Selector
    func clickDoneBtn(_ sender:Any) {
        if currentTextField == m_tfDuration {
            let pickerView = m_tfDuration.inputView as! UIPickerView
            currentTextField?.text = RegularSavingCalculation_MonthList[pickerView.selectedRow(inComponent: 0)]
        }
        currentTextField?.resignFirstResponder()
        currentTextField = nil
    }
    
    func clickCancelBtn(_ sender:Any) {
        currentTextField?.text = ""
        currentTextField?.resignFirstResponder()
        currentTextField = nil
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RegularSavingCalculation_MonthList.count
    }
    
    // MARK - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RegularSavingCalculation_MonthList[row]
    }
}
