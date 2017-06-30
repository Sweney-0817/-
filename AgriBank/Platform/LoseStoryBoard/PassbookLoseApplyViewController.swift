//
//  LosePassbookViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class PassbookLoseApplyViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ImageConfirmCellDelegate
 {
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vDropDownView: UIView!
    @IBOutlet weak var m_vImageConfirmView: UIView!
    @IBAction func m_btnSendClick(_ sender: Any) {
        var data = ConfirmResultStruct(ImageName.CowSuccess.rawValue, "掛失成功", [[String:String]](), "您掛失的交易以正確處理完畢，請於3個營業日內來行辦理掛失解除手續，若未來行辦理者，視為永久掛失手續。(來行辦理請攜帶身分證及原存印鑑)", "", "繼續交易")
        data.list!.append(["Key": "交易時間", "Value":"2017/05/05 11:13:53"])
        data.list!.append(["Key": "掛失日期", "Value":"2017/05/05"])
        enterConfirmResultController(false, data, true)
    }
    var m_OneRow: OneRowDropDownView? = nil
    var m_ImageConfirmView: ImageConfirmCell? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
        setShadowView(m_vShadowView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setAllSubView()
    }
    
    func setAllSubView() {
        setDropDownView()
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
    
    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
    }
    
    func changeInputTextfield(_ input: String) {
    }
    
    func moveView(_ height: CGFloat) {
    }

}
