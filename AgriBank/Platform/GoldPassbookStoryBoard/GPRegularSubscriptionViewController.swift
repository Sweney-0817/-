//
//  GPRegularSubscriptionViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/31.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

class GPRegularSubscriptionViewController: BaseViewController {
    var m_strGPAct: String = ""
    var m_strCurrency: String = ""
    var m_strTransOutAct: String = ""
    var m_strTradeDate: String = ""
    var m_strBuyAmount: String = ""
    var m_bIsSameAmount: Bool = true
    @IBOutlet var m_vButtonView: UIView!
    @IBOutlet var m_btnSameAmount: UIButton!
    @IBOutlet var m_btnSameQuantity: UIButton!
    @IBOutlet var m_lbGPAct: UILabel!
    @IBOutlet var m_lbCurrency: UILabel!
    @IBOutlet var m_lbTransOutAct: UILabel!
    @IBOutlet var m_lbTradeDate: UILabel!
    @IBOutlet var m_tfTradeInput: TextField!
    @IBOutlet var m_lbCommand: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_lbGPAct.text = m_strGPAct
        m_lbCurrency.text = m_strCurrency
        m_lbTransOutAct.text = m_strTransOutAct
        m_lbTradeDate.text = m_strTradeDate
//        self.addObserverToKeyBoard()
        self.addGestureForKeyBoard()
        self.changeFunction(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Init Methods
    func setData(_ GPAct: String, _ currency: String, _ transOutAct: String, _ tradeDate: String) {
        m_strGPAct = GPAct
        m_strCurrency = currency
        m_strTransOutAct = transOutAct
        m_strTradeDate = tradeDate
    }
    // MARK:- UI Methods
    private func changeFunction(_ isSameAmount:Bool) {
        m_bIsSameAmount = isSameAmount
        m_strBuyAmount = ""
        if m_bIsSameAmount {
            m_btnSameAmount.backgroundColor = Green_Color
            m_btnSameAmount.setTitleColor(.white, for: .normal)
            m_btnSameQuantity.backgroundColor = .white
            m_btnSameQuantity.setTitleColor(.black, for: .normal)
            m_tfTradeInput.text = ""
            m_tfTradeInput.placeholder = "請輸入投資金額"
        }
        else {
            m_btnSameQuantity.backgroundColor = Green_Color
            m_btnSameQuantity.setTitleColor(.white, for: .normal)
            m_btnSameAmount.backgroundColor = .white
            m_btnSameAmount.setTitleColor(.black, for: .normal)
            m_tfTradeInput.text = ""
            m_tfTradeInput.placeholder = "請輸入投資數量"
        }
    }
    // MARK:- Logic Methods
    func enterConfirmView_SameAmount() {
        var data : [String:String] = [String:String]()
        data["WorkCode"] = "10008"
        data["Operate"] = "commitTxn"
        data["TransactionId"] = transactionId
        data["REFNO"] = m_strGPAct
        data["INVACT"] = m_strTransOutAct
        data["DD"] = m_strTradeDate
        data["AMT"] = m_strBuyAmount
        let confirmRequest = RequestStruct(strMethod: "Gold/Gold0401", strSessionDescription: "Gold0401", httpBody: AuthorizationManage.manage.converInputToHttpBody(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
        
        var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        dataConfirm.list?.append([Response_Key: "黃金存摺帳號", Response_Value: m_strGPAct])
        dataConfirm.list?.append([Response_Key: "計價幣別", Response_Value: m_strCurrency])
        dataConfirm.list?.append([Response_Key: "扣款帳號", Response_Value: m_strTransOutAct])
        dataConfirm.list?.append([Response_Key: "扣款日期", Response_Value: m_strTradeDate])
        dataConfirm.list?.append([Response_Key: "投資金額", Response_Value: m_strBuyAmount])
        enterConfirmResultController(true, dataConfirm, true)
    }
    func enterConfirmView_SameQuantity() {
        var data : [String:String] = [String:String]()
        data["WorkCode"] = "10010"
        data["Operate"] = "commitTxn"
        data["TransactionId"] = transactionId
        data["REFNO"] = m_strGPAct
        data["INVACT"] = m_strTransOutAct
        data["DD"] = m_strTradeDate
        data["QTY"] = m_strBuyAmount
        let confirmRequest = RequestStruct(strMethod: "Gold/Gold0403", strSessionDescription: "Gold0403", httpBody: AuthorizationManage.manage.converInputToHttpBody(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
        
        var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        dataConfirm.list?.append([Response_Key: "黃金存摺帳號", Response_Value: m_strGPAct])
        dataConfirm.list?.append([Response_Key: "計價幣別", Response_Value: m_strCurrency])
        dataConfirm.list?.append([Response_Key: "扣款帳號", Response_Value: m_strTransOutAct])
        dataConfirm.list?.append([Response_Key: "扣款日期", Response_Value: m_strTradeDate])
        dataConfirm.list?.append([Response_Key: "投資數量", Response_Value: m_strBuyAmount])
        enterConfirmResultController(true, dataConfirm, true)
    }
    // MARK:- WebService Methods
    
    // MARK:- Handle Actions
    @IBAction func m_btnSameAmountClick(_ sender: Any) {
        self.dismissKeyboard()
        self.changeFunction(true)
    }
    @IBAction func m_btnSameQuantityClick(_ sender: Any) {
        self.dismissKeyboard()
        self.changeFunction(false)
    }
    @IBAction func m_btnNextClick(_ sender: Any) {
        if (m_bIsSameAmount) {
            self.enterConfirmView_SameAmount()
        }
        else {
            self.enterConfirmView_SameQuantity()
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
extension GPRegularSubscriptionViewController : UITextFieldDelegate {
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
