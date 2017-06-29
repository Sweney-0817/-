//
//  CheckLoseApplyViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/28.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class CheckLoseApplyViewController: BaseViewController, DropDownViewDelegate, UIActionSheetDelegate, ImageConfirmCellDelegate {
    @IBOutlet weak var m_vDDType: UIView!
    @IBOutlet weak var m_vDDAccount: UIView!
    @IBOutlet weak var m_vCheckNumber: UIView!
    @IBOutlet weak var m_tfCheckNumber: TextField!
    @IBOutlet weak var m_vCheckAmount: UIView!
    @IBOutlet weak var m_tfCheckAmount: TextField!
    @IBOutlet weak var m_consCheckAmountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vCheckDate: UIView!
    @IBOutlet weak var m_consCheckDateHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vFeeAccount: UIView!
    @IBOutlet weak var m_consFeeAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vImageConfirmView: UIView!
    @IBAction func m_btnSendClick(_ sender: Any) {
    }
    var m_DDType: DropDownView? = nil
    var m_DDAccount: DropDownView? = nil
    var m_CheckDate: DropDownView? = nil
    var m_FeeAccount: DropDownView? = nil
    var m_curDropDownView: DropDownView? = nil
    var m_ImageConfirmView: ImageConfirmCell? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setAllSubView()
    }

    func setAllSubView() {
        setDDTypeView()
        setDDAccountView()
        setCheckNumberView()
        setCheckAmountView()
        setCheckDateView()
        setFeeAccountView()
        setImageConfirmView()
    }

    func setDDTypeView() {
        if (m_DDType == nil)
        {
            m_DDType = getUIByID(.UIID_DropDownView) as? DropDownView
            m_DDType?.delegate = self
            m_DDType?.initValue(m_vDDType.frame.width)
            m_DDType?.setOneRow("掛失類別", "空白支票掛失")
            m_vDDType.addSubview(m_DDType!)
        }
        m_DDType?.frame = CGRect(x:0, y:0, width:m_vDDType.frame.width, height:(m_DDType?.getHeight())!)
        m_vDDType.layer.borderColor = Gray_Color.cgColor
        m_vDDType.layer.borderWidth = 1
    }

    func setDDAccountView() {
        if (m_DDAccount == nil)
        {
            m_DDAccount = getUIByID(.UIID_DropDownView) as? DropDownView
            m_DDAccount?.delegate = self
            m_DDAccount?.initValue(m_vDDAccount.frame.width)
            m_DDAccount?.setOneRow("支票帳號", "12345678901234")
            m_vDDAccount.addSubview(m_DDAccount!)
        }
        m_DDAccount?.frame = CGRect(x:0, y:0, width:m_vDDAccount.frame.width, height:(m_DDAccount?.getHeight())!)
        m_vDDAccount.layer.borderColor = Gray_Color.cgColor
        m_vDDAccount.layer.borderWidth = 1
    }
    
    func setCheckNumberView() {
        m_vCheckNumber.layer.borderColor = Gray_Color.cgColor
        m_vCheckNumber.layer.borderWidth = 1
    }

    func setCheckAmountView() {
        m_vCheckAmount.layer.borderColor = Gray_Color.cgColor
        m_vCheckAmount.layer.borderWidth = 1
    }

    func setCheckDateView() {
        if (m_CheckDate == nil)
        {
            m_CheckDate = getUIByID(.UIID_DropDownView) as? DropDownView
            m_CheckDate?.delegate = self
            m_CheckDate?.initValue(m_vCheckDate.frame.width)
            m_CheckDate?.setOneRow("發票日", "2017/05/30")
            m_vCheckDate.addSubview(m_CheckDate!)
        }
        m_CheckDate?.frame = CGRect(x:0, y:0, width:m_vCheckDate.frame.width, height:(m_CheckDate?.getHeight())!)
        m_vCheckDate.layer.borderColor = Gray_Color.cgColor
        m_vCheckDate.layer.borderWidth = 1
    }

    func setFeeAccountView() {
        if (m_FeeAccount == nil)
        {
            m_FeeAccount = getUIByID(.UIID_DropDownView) as? DropDownView
            m_FeeAccount?.delegate = self
            m_FeeAccount?.initValue(m_vFeeAccount.frame.width)
            m_FeeAccount?.setOneRow("手續費轉帳帳號", "12345678901235")
            m_vFeeAccount.addSubview(m_FeeAccount!)
        }
        m_FeeAccount?.frame = CGRect(x:0, y:0, width:m_vFeeAccount.frame.width, height:(m_FeeAccount?.getHeight())!)
        m_vFeeAccount.layer.borderColor = Gray_Color.cgColor
        m_vFeeAccount.layer.borderWidth = 1
    }

    func setImageConfirmView() {
        if (m_ImageConfirmView == nil)
        {
            m_ImageConfirmView = getUIByID(.UIID_ImageConfirmCell) as? ImageConfirmCell
            m_ImageConfirmView?.delegate = self
            m_vImageConfirmView.addSubview(m_ImageConfirmView!)
            setShadowView(m_vImageConfirmView)
        }
        m_ImageConfirmView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - DropDownViewDelegate
    func clickDropDownView(_ sender: DropDownView) {
        m_curDropDownView = sender
        var a = [String]()
//        switch m_curDropDownView {
//        case m_DDType:
//            a.append("空白支票掛失")
//            a.append("支票掛失止付")
//        }
        if (m_curDropDownView == m_DDType) {
            a.append("空白支票掛失")
            a.append("支票掛失止付")
        }
        else if (m_curDropDownView == m_DDAccount) {
            a.append("12345678901234")
            a.append("12345678901235")
            a.append("12345678901236")
            a.append("12345678901237")
        }
        else if (m_curDropDownView == m_CheckDate) {
            a.append("選日期")
        }
        else if (m_curDropDownView == m_FeeAccount) {
            a.append("12345678901234")
            a.append("12345678901235")
            a.append("12345678901236")
            a.append("12345678901237")
        }
//        let a = ["account 1", "account 2", "account 3"]
        let action = UIActionSheet.init()
        action.delegate = self
        action.title = "select account"
        for s in a  {
            action.addButton(withTitle: s)
        }
        action.addButton(withTitle: "cancel")
        action.cancelButtonIndex = a.count
        
        action.show(in: self.view)
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        print("\(buttonIndex)")
        if (actionSheet.buttonTitle(at: buttonIndex)! != "cancel")
        {
            m_curDropDownView?.setOneRow((m_curDropDownView?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
        }
        m_curDropDownView = nil
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
    }
    
    func changeInputTextfield(_ input: String) {
    }
    
    func moveView(_ height: CGFloat) {
    }
    

}
