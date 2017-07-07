//
//  LoseATMCardViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class DebitCardLoseApplyViewController: BaseViewController, OneRowDropDownViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, ImageConfirmViewDelegate {
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vDropDownView: UIView!
    @IBOutlet weak var m_tfWebBankPassword: TextField!
    @IBOutlet weak var m_vWebBankPasswordView: UIView!
    @IBOutlet weak var m_vImageConfirmView: UIView!
    @IBAction func m_btnSendClick(_ sender: Any) {
        var data = ConfirmResultStruct(ImageName.CowFailure.rawValue, "掛失失敗", [[String:String]](), nil, "", "繼續交易")
        data.list!.append(["Key": "交易時間", "Value":"2017/05/05 11:13:53"])
        data.list!.append(["Key": "掛失日期", "Value":"2017/05/05"])
        enterConfirmResultController(false, data, true)
    }
    var m_OneRow: OneRowDropDownView? = nil
    var m_ImageConfirmView: ImageConfirmView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
        setShadowView(m_vShadowView)
    }
    
    func setAllSubView() {
        setDropDownView()
        setWebBankPasswordView()
        setImageConfirmView()
    }

    func setDropDownView() {
        if (m_OneRow == nil)
        {
            m_OneRow = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_OneRow?.delegate = self
            m_OneRow?.setOneRow("存摺帳號", "12345678901234")
            m_vDropDownView.addSubview(m_OneRow!)
        }
        m_OneRow?.frame = CGRect(x:0, y:0, width:m_vDropDownView.frame.width, height:(m_OneRow?.getHeight())!)
        m_vDropDownView.layer.borderColor = Gray_Color.cgColor
        m_vDropDownView.layer.borderWidth = 1
    }
    
    func setWebBankPasswordView() {
        m_vWebBankPasswordView.layer.borderColor = Gray_Color.cgColor
        m_vWebBankPasswordView.layer.borderWidth = 1
    }

    func setImageConfirmView() {
        if (m_ImageConfirmView == nil)
        {
            m_ImageConfirmView = getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
            m_ImageConfirmView?.delegate = self
            m_vImageConfirmView.addSubview(m_ImageConfirmView!)
        }
        m_ImageConfirmView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        let a = ["account 1", "account 2", "account 3"]
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
        if (actionSheet.buttonTitle(at: buttonIndex)! != "cancel")
        {
            m_OneRow?.setOneRow(actionSheet.buttonTitle(at: buttonIndex)!, actionSheet.buttonTitle(at: buttonIndex)!)
        }
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
