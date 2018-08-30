//
//  GPRegularChangeViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

let settingList: [String] = ["不設定", "暫停扣款", "停止扣款"]

class GPRegularChangeViewController: BaseViewController {
    var m_uiSettingView: OneRowDropDownView? = nil
    var m_uiPauseStartView: OneRowDropDownView? = nil
    var m_uiPauseEndView: OneRowDropDownView? = nil
    var m_strGPAct: String = ""
    var m_strTransOutAct: String = ""
    var m_strTradeDate: String = ""
    var m_strSetting: String = Choose_Title
    var m_strPauseStart: String = Choose_Title
    var m_strPauseEnd: String = Choose_Title

    @IBOutlet var m_lbGPAct: UILabel!
    @IBOutlet var m_lbTransOutAct: UILabel!
    @IBOutlet var m_lbTradeDate: UILabel!
    @IBOutlet var m_tfTradeInput: TextField!
    @IBOutlet var m_vSettingView: UIView!
    @IBOutlet var m_vPauseStartView: UIView!
    @IBOutlet var m_vPauseEndView: UIView!
    @IBOutlet var m_lbCommand: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_lbGPAct.text = m_strGPAct
        m_lbTransOutAct.text = m_strTransOutAct
        m_lbTradeDate.text = m_strTradeDate
        initSettingView()
        initPauseStartView()
        initPauseEndView()

        self.addGestureForKeyBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Init Methods
    func setData(_ GPAct: String, _ transOutAct: String, _ tradeDate: String) {
        m_strGPAct = GPAct
        m_strTransOutAct = transOutAct
        m_strTradeDate = tradeDate
    }
    private func initSettingView() {
        m_uiSettingView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiSettingView?.delegate = self
        m_uiSettingView?.frame = m_vSettingView.frame
        m_uiSettingView?.frame.origin = .zero
        m_uiSettingView?.setOneRow("扣款設定", m_strSetting)
        m_uiSettingView?.m_lbFirstRowTitle.textAlignment = .center
        m_vSettingView.addSubview(m_uiSettingView!)
    }
    private func initPauseStartView() {
        m_uiPauseStartView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiPauseStartView?.delegate = self
        m_uiPauseStartView?.frame = m_vPauseStartView.frame
        m_uiPauseStartView?.frame.origin = .zero
        m_uiPauseStartView?.setOneRow("暫停起日", m_strPauseStart)
        m_uiPauseStartView?.m_lbFirstRowTitle.textAlignment = .center
        m_vPauseStartView.addSubview(m_uiPauseStartView!)
    }
    private func initPauseEndView() {
        m_uiPauseEndView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiPauseEndView?.delegate = self
        m_uiPauseEndView?.frame = m_vPauseEndView.frame
        m_uiPauseEndView?.frame.origin = .zero
        m_uiPauseEndView?.setOneRow("暫停訖日", m_strPauseEnd)
        m_uiPauseEndView?.m_lbFirstRowTitle.textAlignment = .center
        m_vPauseEndView.addSubview(m_uiPauseEndView!)
    }
    // MARK:- UI Methods
    func showSettingList() {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for setting in settingList {
                actSheet.addButton(withTitle: setting)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
    }
    // MARK:- Logic Methods
    
    // MARK:- WebService Methods
    
    // MARK:- Handle Actions
    @IBAction func m_btnNextClick(_ sender: Any) {
    }
}
extension GPRegularChangeViewController : OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        self.dismissKeyboard()
        if (sender == m_uiSettingView) {
            showSettingList()
        }
        else if (sender == m_uiPauseStartView) {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = view.frame
                datePicker.frame.origin = .zero
                datePicker.showOneDatePickerView(true, nil) { start in
                    self.m_uiPauseStartView?.setOneRow("暫停起日", "\(start.year)/\(start.month)/\(start.day)")
                }
                view.addSubview(datePicker)
            }
            
        }
        else if (sender == m_uiPauseEndView) {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = view.frame
                datePicker.frame.origin = .zero
                datePicker.showOneDatePickerView(true, nil) {  end in
                    self.m_uiPauseEndView?.setOneRow("暫停訖日", "\(end.year)/\(end.month)/\(end.day)")
                }
                view.addSubview(datePicker)
            }
        }
    }
}
extension GPRegularChangeViewController : UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_AccountActionSheet.rawValue:
                let iIndex : Int = buttonIndex - 1
                m_uiSettingView?.setOneRow("扣款設定", settingList[iIndex])
            default:
                break
            }
        }
    }
}
extension GPRegularChangeViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard DetermineUtility.utility.isAllNumber(newString) else {
            return false
        }
        
//        let newLength = (textField.text?.count)! - range.length + string.count
//        let maxLength = Max_MobliePhone_Length
//        if newLength <= maxLength {
//            m_strBuyGram = newString
            return true
//        }
//        else {
//            return false
//        }
    }
}
