//
//  TaxPaymentViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let TaxPayment_Type_Title = "稅費種類"
let TaxPayment_Kind_Title = "繳稅類別"
let TaxPayment_OutAccount_Title = "轉出帳號"
let TaxPayment_Type1_List = ["銷帳編號", "繳費期限(2017/05/01即20170501)", "繳納金額"]
let TaxPayment_Type2_List = ["機關代號", "身份證字號", "繳納金額"]
let TaxPayment_Type1 = "1"
let TaxPayment_Type2 = "2"

class TaxPaymentViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vDDType: UIView!
    @IBOutlet weak var m_vDDKind: UIView!
    @IBOutlet weak var m_vInput1: UIView!
    @IBOutlet weak var m_tfInput1: TextField!
    @IBOutlet weak var m_vInput2: UIView!
    @IBOutlet weak var m_tfInput2: TextField!
    @IBOutlet weak var m_vDDAccount: UIView!
    @IBOutlet weak var m_vInput3: UIView!
    @IBOutlet weak var m_tfInput3: TextField!

    var m_DDType: OneRowDropDownView? = nil
    var m_DDKind: OneRowDropDownView? = nil
    var m_DDAccount: OneRowDropDownView? = nil
    var m_curDropDownView: OneRowDropDownView? = nil

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
//        initInputForType("地價稅")
        setShadowView(m_vShadowView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let deviceCheckController = segue.destination as! DeviceCheckViewController
        var data = [[String:String]]()
        data.append(["Key": "繳稅種類", "Value":"地價稅"])
        data.append(["Key": "繳稅類別", "Value":"11331-定期開徵稅款"])
        data.append(["Key": "轉出帳號", "Value":"12345678901234"])
        data.append(["Key": "銷帳編號", "Value":"1234567890123456"])
        data.append(["Key": "繳費期限", "Value":"2017/05/01"])
        data.append(["Key": "繳納金額", "Value":"9,999,999.00"])
        deviceCheckController.setData(data)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
        }
    }

    // MARK: - Private
    func setAllSubView() {
        setDDTypeView()
        setDDKindView()
        setDDAccountView()
//        setInput1View()
//        setInput2View()
//        setInput3View()
    }
    
    func setDDTypeView() {
        if m_DDType == nil {
            m_DDType = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDType?.delegate = self
            m_DDType?.setOneRow(TaxPayment_Type_Title, Choose_Title)
            m_DDType?.frame = CGRect(x:0, y:0, width:m_vDDType.frame.width, height:(m_DDType?.getHeight())!)
            m_vDDType.addSubview(m_DDType!)
        }
    }
    
    func setDDKindView() {
        if m_DDKind == nil {
            m_DDKind = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDKind?.delegate = self
            m_DDKind?.setOneRow(TaxPayment_Kind_Title, Choose_Title)
            m_DDKind?.frame = CGRect(x:0, y:0, width:m_vDDKind.frame.width, height:(m_DDKind?.getHeight())!)
            m_vDDKind.addSubview(m_DDKind!)
        }
    }
    
    func setDDAccountView() {
        if m_DDAccount == nil {
            m_DDAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDAccount?.delegate = self
            m_DDAccount?.setOneRow(TaxPayment_OutAccount_Title, Choose_Title)
            m_DDAccount?.frame = CGRect(x:0, y:0, width:m_vDDAccount.frame.width, height:(m_DDAccount?.getHeight())!)
            m_vDDAccount.addSubview(m_DDAccount!)
        }
    }
    
//    func setInput1View() {
//        m_vInput1.layer.borderColor = Gray_Color.cgColor
//        m_vInput1.layer.borderWidth = 1
//    }
//    
//    func setInput2View() {
//        m_vInput2.layer.borderColor = Gray_Color.cgColor
//        m_vInput2.layer.borderWidth = 1
//    }
//    
//    func setInput3View() {
//        m_vInput3.layer.borderColor = Gray_Color.cgColor
//        m_vInput3.layer.borderWidth = 1
//    }
    
    func initInputForType(_ type:String) {
        if type == TaxPayment_Type1 {
            m_tfInput1.text = ""
            m_tfInput1.placeholder = TaxPayment_Type1_List[0]
            m_tfInput2.text = ""
            m_tfInput2.placeholder = TaxPayment_Type1_List[1]
            m_tfInput3.text = ""
            m_tfInput3.placeholder = TaxPayment_Type1_List[2]
        }
        else {
            m_tfInput1.text = ""
            m_tfInput1.placeholder = TaxPayment_Type2_List[0]
            m_tfInput2.text = ""
            m_tfInput2.placeholder = TaxPayment_Type2_List[1]
            m_tfInput3.text = ""
            m_tfInput3.placeholder = TaxPayment_Type2_List[2]
        }
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        m_curDropDownView = sender
        var a = [String]()
        if m_curDropDownView == m_DDType {
            a.append("地價稅")
            a.append("綜合所得稅")
        }
        else if m_curDropDownView == m_DDKind {
            a.append("11331-定期開徵稅款")
            a.append("15001-結算申報自繳稅款")
            a.append("12345678901236")
            a.append("12345678901237")
        }
        else if m_curDropDownView == m_DDAccount {
            a.append("12345678901234")
            a.append("12345678901235")
            a.append("12345678901236")
            a.append("12345678901237")
        }
        let action = UIActionSheet.init()
        action.delegate = self
        action.title = "select"
        for s in a  {
            action.addButton(withTitle: s)
        }
        action.addButton(withTitle: "cancel")
        action.cancelButtonIndex = a.count
        
        action.show(in: self.view)
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            if m_curDropDownView == m_DDType {
                initInputForType(actionSheet.buttonTitle(at: buttonIndex)!)
            }
            else if m_curDropDownView == m_DDKind {
                
            }
            else if m_curDropDownView == m_DDAccount {
            }
            m_curDropDownView?.setOneRow((m_curDropDownView?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
        }
        m_curDropDownView = nil
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnSendClick(_ sender: Any) {
        performSegue(withIdentifier: "goDeviceCheck", sender: nil)
    }
}
