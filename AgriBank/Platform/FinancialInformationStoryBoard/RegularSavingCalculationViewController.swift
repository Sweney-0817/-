//
//  RegularSavingCalculationViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/5.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class RegularSavingCalculationViewController: BaseViewController, ChooseTypeDelegate, UITextFieldDelegate {
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
    @IBAction func m_btnCalculateClick(_ sender: Any) {
        let result = "[\(m_tfAmount.text!)][\(m_tfDuration.text!)][\(m_tfRate.text!)]"
        m_lbResult.text = result
    }
    @IBAction func m_btnClearClick(_ sender: Any) {
        clearData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        initInputForType("存本取息")
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
        let typeList = ["存本取息","零存整付","整存整付"]
        m_vChooseTypeView.setTypeList(typeList, setDelegate: self)
        m_vChooseTypeView.layer.borderColor = Gray_Color.cgColor
        m_vChooseTypeView.layer.borderWidth = 1
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
