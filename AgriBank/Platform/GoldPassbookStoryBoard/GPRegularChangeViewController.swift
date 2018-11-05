//
//  GPRegularChangeViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

let pauseDebit = "暫停扣款"
let stopDebit = "停止扣款"

class GPRegularChangeViewController: BaseViewController {
    var m_uiSettingView: OneRowDropDownView? = nil
    var m_uiPauseStartView: OneRowDropDownView? = nil
    var m_uiPauseEndView: OneRowDropDownView? = nil
    var m_objPassData: GPPassData? = nil
    var m_iSettingIndex: Int = 0
    var m_strPauseStart: String = Choose_Title
    var m_strPauseEnd: String = Choose_Title
    var m_arySettingList: [String] = [String]()
    var m_strBuyAmount: String = ""

    @IBOutlet var m_lbGPAct: UILabel!
    @IBOutlet var m_lbTransOutAct: UILabel!
    @IBOutlet var m_lbTradeDate: UILabel!
    @IBOutlet var m_lbTradeTitle: UILabel!
    @IBOutlet var m_tfTradeInput: TextField!
    @IBOutlet var m_lbTradeAmount: UILabel!
    @IBOutlet var m_vSettingView: UIView!
    @IBOutlet var m_vPauseStartView: UIView!
    @IBOutlet var m_vPauseStartBottomLine: UIView!
    @IBOutlet var m_vPauseEndView: UIView!
    @IBOutlet var m_vPauseEndBottomLine: UIView!
    @IBOutlet var m_lbCommand: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_lbGPAct.text = m_objPassData?.m_accountStruct.accountNO
        m_lbTransOutAct.text = m_objPassData?.m_strTransOutAct
        m_lbTradeDate.text = (m_objPassData?.m_settingData.m_strDate)! + "日"
        if (m_objPassData?.m_settingData.m_strType == sameAmount) {
            m_arySettingList = ["修改金額", pauseDebit, stopDebit]
        }
        else if (m_objPassData?.m_settingData.m_strType == sameQuantity) {
            m_arySettingList = ["修改數量", pauseDebit, stopDebit]
        }
        else {
            m_arySettingList = [m_objPassData?.m_settingData.m_strType, pauseDebit, stopDebit] as! [String]
        }
        
        initSettingView()
        initPauseStartView()
        initPauseEndView()

        self.addGestureForKeyBoard()
        self.changeView(m_arySettingList[m_iSettingIndex])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Init Methods
    func setData(_ data: GPPassData) {
        m_objPassData = data
    }
    private func initSettingView() {
        m_uiSettingView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiSettingView?.delegate = self
        m_uiSettingView?.frame = m_vSettingView.frame
        m_uiSettingView?.frame.origin = .zero
        m_uiSettingView?.setOneRow("扣款設定", m_arySettingList[m_iSettingIndex])
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
            for setting in m_arySettingList {
                actSheet.addButton(withTitle: setting)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
    }
    func changeView(_ setting: String) {
        if (setting == pauseDebit) {
            m_tfTradeInput.text = ""
            m_tfTradeInput.isHidden = true
            m_strBuyAmount = (m_objPassData?.m_settingData.m_strAmount)!.separatorDecimal()
            m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAmount.separatorThousand()
            m_lbTradeAmount.isHidden = false
            m_vPauseStartView.isHidden = false
            m_vPauseStartBottomLine.isHidden = false
            m_vPauseEndView.isHidden = false
            m_vPauseEndBottomLine.isHidden = false
        }
        else if (setting == stopDebit) {
            m_tfTradeInput.text = ""
            m_tfTradeInput.isHidden = true
            m_strBuyAmount = (m_objPassData?.m_settingData.m_strAmount)!.separatorDecimal()
            m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAmount.separatorThousand()
            m_lbTradeAmount.isHidden = false
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
        else {
            m_tfTradeInput.text = m_objPassData?.m_settingData.m_strAmount.separatorDecimal()
            m_tfTradeInput.isHidden = false
            m_strBuyAmount = (m_objPassData?.m_settingData.m_strAmount)!.separatorDecimal()
            m_lbTradeAmount.text = m_objPassData?.m_settingData.m_strAmount.separatorThousand()
            m_lbTradeAmount.isHidden = true
            m_vPauseStartView.isHidden = true
            m_vPauseStartBottomLine.isHidden = true
            m_vPauseEndView.isHidden = true
            m_vPauseEndBottomLine.isHidden = true
        }
    }
    // MARK:- Logic Methods
    func enterConfirmView_SameAmount() {
        var data : [String:String] = [String:String]()
        data["WorkCode"] = "10009"
        data["Operate"] = "commitTxn"
        data["TransactionId"] = transactionId
        data["REFNO"] = m_objPassData?.m_accountStruct.accountNO
        data["INVACT"] = m_objPassData?.m_strTransOutAct
        data["DD"] = m_objPassData?.m_settingData.m_strDate
        data["AMT"] = m_strBuyAmount
        data["SETUP"] = String(m_iSettingIndex)
        
        // 暫停起日, 暫停訖日
        if (m_iSettingIndex == 1) {
            data["STPSDAY"] = m_strPauseStart
            data["STPEDAY"] = m_strPauseEnd
        }
        else {
            data["STPSDAY"] = ""
            data["STPEDAY"] = ""
        }
        
        let confirmRequest = RequestStruct(strMethod: "Gold/Gold0402", strSessionDescription: "Gold0402", httpBody: AuthorizationManage.manage.converInputToHttpBody(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
        
        var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        dataConfirm.list?.append([Response_Key: "黃金存摺帳號", Response_Value: (m_objPassData?.m_accountStruct.accountNO)!])
        dataConfirm.list?.append([Response_Key: "扣款帳號", Response_Value: (m_objPassData?.m_strTransOutAct)!])
        dataConfirm.list?.append([Response_Key: "扣款日期", Response_Value: (m_objPassData?.m_settingData.m_strDate)! + "日"])
        dataConfirm.list?.append([Response_Key: "投資金額", Response_Value: m_strBuyAmount.separatorThousand()])
        dataConfirm.list?.append([Response_Key: "扣款設定", Response_Value: m_arySettingList[m_iSettingIndex]])
        if (m_iSettingIndex == 1) {
            dataConfirm.list?.append([Response_Key: "暫停起日", Response_Value: m_strPauseStart.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd")])
            dataConfirm.list?.append([Response_Key: "暫停訖日", Response_Value: m_strPauseEnd.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd")])
        }
        enterConfirmResultController(true, dataConfirm, true)
    }
    func enterConfirmView_SameQuantity() {
        var data : [String:String] = [String:String]()
        data["WorkCode"] = "10011"
        data["Operate"] = "commitTxn"
        data["TransactionId"] = transactionId
        data["REFNO"] = m_objPassData?.m_accountStruct.accountNO
        data["INVACT"] = m_objPassData?.m_strTransOutAct
        data["DD"] = m_objPassData?.m_settingData.m_strDate
        data["QTY"] = m_strBuyAmount
        data["SETUP"] = String(m_iSettingIndex)
        
        // 暫停起日, 暫停訖日
        if (m_iSettingIndex == 1) {
            data["STPSDAY"] = m_strPauseStart
            data["STPEDAY"] = m_strPauseEnd
        }
        else {
            data["STPSDAY"] = ""
            data["STPEDAY"] = ""
        }
        
        let confirmRequest = RequestStruct(strMethod: "Gold/Gold0404", strSessionDescription: "Gold0404", httpBody: AuthorizationManage.manage.converInputToHttpBody(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
        
        var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        dataConfirm.list?.append([Response_Key: "黃金存摺帳號", Response_Value: (m_objPassData?.m_accountStruct.accountNO)!])
        dataConfirm.list?.append([Response_Key: "扣款帳號", Response_Value: (m_objPassData?.m_strTransOutAct)!])
        dataConfirm.list?.append([Response_Key: "扣款日期", Response_Value: (m_objPassData?.m_settingData.m_strDate)! + "日"])
        dataConfirm.list?.append([Response_Key: "投資數量", Response_Value: m_strBuyAmount.separatorThousand() + "克"])
        dataConfirm.list?.append([Response_Key: "扣款設定", Response_Value: m_arySettingList[m_iSettingIndex]])
        if (m_iSettingIndex == 1) {
            dataConfirm.list?.append([Response_Key: "暫停起日", Response_Value: m_strPauseStart.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd")])
            dataConfirm.list?.append([Response_Key: "暫停訖日", Response_Value: m_strPauseEnd.dateFormatter(form: "yyyyMMdd", to: "yyyy/MM/dd")])
        }
        enterConfirmResultController(true, dataConfirm, true)
    }

    // MARK:- WebService Methods
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                if (m_objPassData?.m_settingData.m_strType == sameAmount) {
                    enterConfirmView_SameAmount()
                }
                else if (m_objPassData?.m_settingData.m_strType == sameQuantity) {
                    enterConfirmView_SameQuantity()
                }
            }
            else {
                super.didResponse(description, response)
            }
        default:
            super.didResponse(description, response)
        }
    }

    // MARK:- Handle Actions
    @IBAction func m_btnNextClick(_ sender: Any) {
        if (m_objPassData?.m_settingData.m_strType == sameAmount) {
            getTransactionID("10009", TransactionID_Description)
        }
        else if (m_objPassData?.m_settingData.m_strType == sameQuantity) {
            getTransactionID("10011", TransactionID_Description)
        }
        else {
            return
        }
    }
    override func clickBackBarItem() {
        for vc in (self.navigationController?.viewControllers)! {
            if (vc.isKind(of: GPRegularAccountInfomationViewController.self)) {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
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
                    self.m_strPauseStart = "\(start.year)\(start.month)\(start.day)"
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
                    self.m_strPauseEnd = "\(end.year)\(end.month)\(end.day)"
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
                m_iSettingIndex = buttonIndex - 1
                m_uiSettingView?.setOneRow("扣款設定", m_arySettingList[m_iSettingIndex])
                self.changeView(m_arySettingList[m_iSettingIndex])
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
        
        let newLength = (textField.text?.count)! - range.length + string.count
        let maxLength = Max_GoldGram_Length
        if newLength <= maxLength {
            m_strBuyAmount = newString
            return true
        }
        else {
            return false
        }
    }
}
