//
//  BillPaymentViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class BillPaymentViewController: BaseViewController, ThreeRowDropDownViewDelegate, OneRowDropDownViewDelegate, TwoRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var m_vTransOutAccount: UIView!
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vAccountType: UIView!
    @IBOutlet weak var m_segAccountType: UISegmentedControl!
    @IBAction func clickChangeActType(_ sender: Any) {
        let segCon:UISegmentedControl = sender as! UISegmentedControl
        initInputForType(segCon.titleForSegment(at: segCon.selectedSegmentIndex)!)
    }
    @IBOutlet weak var m_vTransInBank: UIView!
    @IBOutlet weak var m_consTransInBankHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vTransInAccount: UIView!
    @IBOutlet weak var m_tfTransInAccount: TextField!
    @IBOutlet weak var m_consTransInAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vTransInBA: UIView!
    @IBOutlet weak var m_consTransInBAHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vTransAmount: UIView!
    @IBOutlet weak var m_tfTransAmount: TextField!
    @IBOutlet weak var m_vTransMemo: UIView!
    @IBOutlet weak var m_tfTransMemo: TextField!
    @IBOutlet weak var m_vEmail: UIView!
    @IBOutlet weak var m_tfEmail: TextField!
    @IBAction func m_btnSendClick(_ sender: Any) {
        performSegue(withIdentifier: "goDeviceCheck", sender: nil)
    }

    var m_DDTransOutAccount: ThreeRowDropDownView? = nil
    var m_DDTransInBank: OneRowDropDownView? = nil
    var m_DDTransInBA: TwoRowDropDownView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
        initInputForType("自訂帳號")
        setShadowView(m_vShadowView)
        m_segAccountType.setTitleTextAttributes([NSFontAttributeName:Default_Font], for: .normal)
        addObserverToKeyBoard()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let deviceCheckController = segue.destination as! DeviceCheckViewController
        var data = [[String:String]]()
        data.append(["Key": "轉出帳號", "Value":"12345678901234"])
        data.append(["Key": "銀行代碼", "Value":"008"])
        data.append(["Key": "轉入帳號", "Value":"12345678901235"])
        data.append(["Key": "繳納金額", "Value":"9,999,999.00"])
        data.append(["Key": "備註/交易備記", "Value":"-"])
        data.append(["Key": "受款人E-mail", "Value":"1234@gmail.com"])
        deviceCheckController.setData(data)
    }
    
    func setAllSubView() {
        setDDTransOutAccount()
        setTransInBank()
        setDDTransInBA()
        setAccountTypeView()
        setTransInAccountView()
        setTransAmountView()
        setTransMemoView()
        setEmailView()
    }

    func setDDTransOutAccount() {
        if (m_DDTransOutAccount == nil)
        {
            m_DDTransOutAccount = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
            m_DDTransOutAccount?.delegate = self
            m_DDTransOutAccount?.setThreeRow("轉出帳號", "12345678901234", "幣別", "TWD", "餘額", "9,999,999.00")
            m_DDTransOutAccount?.frame = CGRect(x:0, y:0, width:m_vTransOutAccount.frame.width, height:(m_DDTransOutAccount?.getHeight())!)
            m_vTransOutAccount.addSubview(m_DDTransOutAccount!)
        }
        m_vTransOutAccount.layer.borderColor = Gray_Color.cgColor
        m_vTransOutAccount.layer.borderWidth = 1
    }
    func setTransInBank() {
        if (m_DDTransInBank == nil)
        {
            m_DDTransInBank = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDTransInBank?.delegate = self
            m_DDTransInBank?.setOneRow("銀行代碼", "008")
            m_DDTransInBank?.frame = CGRect(x:0, y:0, width:m_vTransInBank.frame.width, height:(m_DDTransInBank?.getHeight())!)
            m_vTransInBank.addSubview(m_DDTransInBank!)
        }
        m_vTransInBank.layer.borderColor = Gray_Color.cgColor
        m_vTransInBank.layer.borderWidth = 1
    }
    func setDDTransInBA() {
        if (m_DDTransInBA == nil)
        {
            m_DDTransInBA = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
            m_DDTransInBA?.delegate = self
            m_DDTransInBA?.setTwoRow("銀行代碼", "008", "轉入帳號", "12345678901234")
            m_DDTransInBA?.frame = CGRect(x:0, y:0, width:m_vTransInBA.frame.width, height:(m_DDTransInBA?.getHeight())!)
            m_vTransInBA.addSubview(m_DDTransInBA!)
        }
        m_vTransInBA.layer.borderColor = Gray_Color.cgColor
        m_vTransInBA.layer.borderWidth = 1
    }
    func setAccountTypeView() {
        m_vAccountType.layer.borderColor = Gray_Color.cgColor
        m_vAccountType.layer.borderWidth = 1
    }
    func setTransInAccountView() {
        m_vTransInAccount.layer.borderColor = Gray_Color.cgColor
        m_vTransInAccount.layer.borderWidth = 1
    }
    func setTransAmountView() {
        m_vTransAmount.layer.borderColor = Gray_Color.cgColor
        m_vTransAmount.layer.borderWidth = 1
    }
    func setTransMemoView() {
        m_vTransMemo.layer.borderColor = Gray_Color.cgColor
        m_vTransMemo.layer.borderWidth = 1
    }
    func setEmailView() {
        m_vEmail.layer.borderColor = Gray_Color.cgColor
        m_vEmail.layer.borderWidth = 1
    }
    func initInputForType(_ type:String) {
        if (type == "自訂帳號") {
            m_consTransInBankHeight.constant = 60
            m_consTransInAccountHeight.constant = 60
            m_consTransInBAHeight.constant = 0
            m_vTransInBank.isHidden = false
            m_vTransInAccount.isHidden = false
            m_vTransInBA.isHidden = true
        }
        else {
            m_consTransInBankHeight.constant = 0
            m_consTransInAccountHeight.constant = 0
            m_consTransInBAHeight.constant = 80
            m_vTransInBank.isHidden = true
            m_vTransInAccount.isHidden = true
            m_vTransInBA.isHidden = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        var a = [String]()
        a.append("12345678901234")
        a.append("12345678901235")
        a.append("12345678901236")
        a.append("12345678901237")
        a.append("12345678901238")
        let action = UIActionSheet.init()
        action.delegate = self
        action.title = "select"
        for s in a  {
            action.addButton(withTitle: s)
        }
        action.addButton(withTitle: "cancel")
        action.cancelButtonIndex = a.count
        action.tag = 3000
        
        action.show(in: self.view)
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        var a = [String]()
        a.append("001")
        a.append("002")
        a.append("003")
        a.append("004")
        a.append("005")
        let action = UIActionSheet.init()
        action.delegate = self
        action.title = "select"
        for s in a  {
            action.addButton(withTitle: s)
        }
        action.addButton(withTitle: "cancel")
        action.cancelButtonIndex = a.count
        action.tag = 1000

        action.show(in: self.view)
    }
    // MARK: - TwoRowDropDownViewDelegate
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView) {
        var a = [String]()
        a.append("008 12345678901234")
        a.append("008 12345678901235")
        a.append("009 12345678901236")
        a.append("009 12345678901237")
        a.append("010 12345678901238")
        let action = UIActionSheet.init()
        action.delegate = self
        action.title = "select"
        for s in a  {
            action.addButton(withTitle: s)
        }
        action.addButton(withTitle: "cancel")
        action.cancelButtonIndex = a.count
        action.tag = 2000

        action.show(in: self.view)
    }
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if (actionSheet.buttonTitle(at: buttonIndex)! != "cancel") {
            switch (actionSheet.tag) {
            case 1000:
                m_DDTransInBank?.setOneRow((m_DDTransInBank?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
//                break;
            case 2000:
                let select = actionSheet.buttonTitle(at: buttonIndex)!
                let bank = select.components(separatedBy: " ")
                m_DDTransInBA?.setTwoRow((m_DDTransInBA?.m_lbFirstRowTitle.text)!, bank[0], (m_DDTransInBA?.m_lbSecondRowTitle.text)!, bank[1])
                break;
            case 3000:
                m_DDTransOutAccount?.setThreeRow(
                    (m_DDTransOutAccount?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!,
                    (m_DDTransOutAccount?.m_lbSecondRowTitle.text)!, "TWD",
                    (m_DDTransOutAccount?.m_lbThirdRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
                break;
            default:
                break;
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
