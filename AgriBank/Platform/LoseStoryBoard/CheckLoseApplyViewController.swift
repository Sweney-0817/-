//
//  CheckLoseApplyViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/28.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class CheckLoseApplyViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ImageConfirmCellDelegate {
    @IBOutlet weak var m_vShadowView: UIView!
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
        if (m_DDType?.m_lbFirstRowContent.text == "空白支票掛失") {
            var data = ConfirmResultStruct(ImageName.CowSuccess.rawValue, "掛失成功", [[String:String]](), "您掛失的交易以正確處理完畢，請於3個營業日內來行辦理掛失解除手續，若未來行辦理者，視為永久掛失手續。(來行辦理請攜帶身分證及原存印鑑)", "", "繼續交易")
            data.list!.append(["Key": "交易時間", "Value":"2017/05/05 11:13:53"])
            data.list!.append(["Key": "掛失日期", "Value":"2017/05/05"])
            enterConfirmResultController(false, data, true)
        }
        else if (m_DDType?.m_lbFirstRowContent.text == "支票掛失止付") {
            var data = ConfirmResultStruct(ImageName.CowFailure.rawValue, "掛失失敗", [[String:String]](), nil, "", "繼續交易")
            data.list!.append(["Key": "交易時間", "Value":"2017/05/05 11:13:53"])
            data.list!.append(["Key": "掛失日期", "Value":"2017/05/05"])
            enterConfirmResultController(false, data, true)
        }
    }
    var m_DDType: OneRowDropDownView? = nil
    var m_DDAccount: OneRowDropDownView? = nil
    var m_CheckDate: OneRowDropDownView? = nil
    var m_FeeAccount: OneRowDropDownView? = nil
    var m_curDropDownView: OneRowDropDownView? = nil
    var m_ImageConfirmView: ImageConfirmCell? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
        setShadowView(m_vShadowView)
        hideSomeSubviews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
            m_DDType = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDType?.delegate = self
            m_DDType?.setOneRow("掛失類別", "空白支票掛失")
            m_DDType?.frame = CGRect(x:0, y:0, width:m_vDDType.frame.width, height:(m_DDType?.getHeight())!)
            m_vDDType.addSubview(m_DDType!)
        }
        m_vDDType.layer.borderColor = Gray_Color.cgColor
        m_vDDType.layer.borderWidth = 1
    }

    func setDDAccountView() {
        if (m_DDAccount == nil)
        {
            m_DDAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDAccount?.delegate = self
            m_DDAccount?.setOneRow("支票帳號", "12345678901234")
            m_DDAccount?.frame = CGRect(x:0, y:0, width:m_vDDAccount.frame.width, height:(m_DDAccount?.getHeight())!)
            m_vDDAccount.addSubview(m_DDAccount!)
        }
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
            m_CheckDate = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_CheckDate?.delegate = self
            m_CheckDate?.setOneRow("發票日", "2017/05/30")
            m_CheckDate?.frame = CGRect(x:0, y:0, width:m_vCheckDate.frame.width, height:(m_CheckDate?.getHeight())!)
            m_vCheckDate.addSubview(m_CheckDate!)
        }
        
        m_vCheckDate.layer.borderColor = Gray_Color.cgColor
        m_vCheckDate.layer.borderWidth = 1
    }

    func setFeeAccountView() {
        if (m_FeeAccount == nil)
        {
            m_FeeAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_FeeAccount?.delegate = self
            m_FeeAccount?.setOneRow("手續費轉帳帳號", "12345678901235")
            m_FeeAccount?.frame = CGRect(x:0, y:0, width:m_vFeeAccount.frame.width, height:(m_FeeAccount?.getHeight())!)
            m_vFeeAccount.addSubview(m_FeeAccount!)
        }
        m_vFeeAccount.layer.borderColor = Gray_Color.cgColor
        m_vFeeAccount.layer.borderWidth = 1
    }

    func setImageConfirmView() {
        if (m_ImageConfirmView == nil)
        {
            m_ImageConfirmView = getUIByID(.UIID_ImageConfirmCell) as? ImageConfirmCell
            m_ImageConfirmView?.delegate = self
            m_vImageConfirmView.addSubview(m_ImageConfirmView!)
        }
        m_ImageConfirmView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
    }
    
    func hideSomeSubviews() {
        m_vCheckAmount.isHidden = true
        m_vCheckDate.isHidden = true
        m_vFeeAccount.isHidden = true
        m_consCheckAmountHeight.constant = 0
        m_consCheckDateHeight.constant = 0
        m_consFeeAccountHeight.constant = 0
    }
    
    func showSomeSubviews() {
        m_vCheckAmount.isHidden = false
        m_vCheckDate.isHidden = false
        m_vFeeAccount.isHidden = false
        m_consCheckAmountHeight.constant = 60
        m_consCheckDateHeight.constant = 60
        m_consFeeAccountHeight.constant = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        m_curDropDownView = sender
        var a = [String]()
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
//        print("\(buttonIndex)")
        if (actionSheet.buttonTitle(at: buttonIndex)! != "cancel")
        {
            if (m_curDropDownView == m_DDType) {
                if (buttonIndex == 0) {//空白支票掛失
                    hideSomeSubviews()
                }
                else {//支票掛失止付
                    showSomeSubviews()
                }
            }
            else if (m_curDropDownView == m_DDAccount) {
            }
            else if (m_curDropDownView == m_CheckDate) {
            }
            else if (m_curDropDownView == m_FeeAccount) {
            }
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
