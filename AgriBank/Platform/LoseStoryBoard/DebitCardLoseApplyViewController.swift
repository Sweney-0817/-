//
//  LoseATMCardViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class DebitCardLoseApplyViewController: BaseViewController, DropDownViewDelegate, UIActionSheetDelegate, ImageConfirmCellDelegate {
    @IBOutlet weak var m_vDropDownView: UIView!
    @IBOutlet weak var m_tfWebBankPassword: TextField!
    @IBOutlet weak var m_vWebBankPassword: UIView!
    @IBOutlet weak var m_vImageConfirmView: UIView!
    @IBAction func m_btnSendClick(_ sender: Any) {
        var data = ConfirmResultStruct(ImageName.CowSuccess.rawValue, "掛失失敗", [[String:String]](), nil, nil, "繼續交易")
        data.list!.append(["Key": "交易時間", "Value":"2017/05/05 11:13:53"])
        data.list!.append(["Key": "掛失日期", "Value":"2017/05/05"])
        enterConfirmResultController(false, data, true)
    }
    var m_DropDownView: DropDownView? = nil
    var m_ImageConfirmView: ImageConfirmCell? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addDropDownView()
        m_vWebBankPassword.layer.borderColor = Gray_Color.cgColor
        m_vWebBankPassword.layer.borderWidth = 1
        addImageConfirmView()
        super.viewDidAppear(animated)
    }

    func addDropDownView()
    {
        m_DropDownView = getUIByID(.UIID_DropDownView) as? DropDownView
        m_DropDownView?.delegate = self
        m_DropDownView?.initValue(m_vDropDownView.frame.width)
        m_DropDownView?.setOneRow("存摺帳號", "12345678901234")
        m_DropDownView?.frame = CGRect(x:0, y:0, width:m_vDropDownView.frame.width, height:(m_DropDownView?.getHeight())!)
        m_vDropDownView.addSubview(m_DropDownView!)
        m_vDropDownView.layer.borderColor = Gray_Color.cgColor
        m_vDropDownView.layer.borderWidth = 1
    }

    func addImageConfirmView() {
        m_ImageConfirmView = getUIByID(.UIID_ImageConfirmCell) as? ImageConfirmCell
        m_ImageConfirmView?.delegate = self
        m_vImageConfirmView.addSubview(m_ImageConfirmView!)
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
        setShadowView(m_vImageConfirmView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if(string == "") {
//            delegate?.changeInputTextfield(textField.text!.substring(to: textField.text!.index(textField.text!.endIndex, offsetBy:-1)))
//        }
//        else {
//            let input = textField.text! + string
//            delegate?.changeInputTextfield(input)
//        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - UIActionSheetDelegate
    func clickDropDownView() {
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
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        print("\(buttonIndex)")
        if (actionSheet.buttonTitle(at: buttonIndex)! == "cancel")
        {
            return
        }
        else
        {
            m_DropDownView?.setOneRow(actionSheet.buttonTitle(at: buttonIndex)!, actionSheet.buttonTitle(at: buttonIndex)!)
        }
    }
    
    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
    }
    
    func changeInputTextfield(_ input: String) {
    }
    
    func moveView(_ height: CGFloat) {
    }

}
