//
//  CheckLoseApplyViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/28.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let CheckLoseApply_ChooseType_Title = "掛失類別"
let CheckLoseApply_TypeList = ["支票掛失止付","空白支票掛失"]
let CheckLoseApply_CheckAccount_Title = "支票帳號"
let CheckLoseApply_Date_Title = "發票日"
let CheckLoseApply_TransAccount_Title = "手續費轉帳帳號"
let CheckLoseApply_Memo = "請您本人攜帶身分證及原留印鑑來行辦理取消掛失或重新申請作業"
let CheckLoseApply_Bill_Max_Length:Int = 10

class CheckLoseApplyViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ImageConfirmViewDelegate, UITextFieldDelegate {
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
    private var m_DDType: OneRowDropDownView? = nil
    private var m_DDAccount: OneRowDropDownView? = nil
    private var m_CheckDate: OneRowDropDownView? = nil
    private var m_FeeAccount: OneRowDropDownView? = nil
    private var m_curDropDownView: OneRowDropDownView? = nil
    private var m_ImageConfirmView: ImageConfirmView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var password = ""
    private var checkAccountList:[AccountStruct]? = nil // 支票帳號列表
    private var curTextfield:UITextField? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setAllSubView()
        setShadowView(m_vShadowView)
        getTransactionID("04003", TransactionID_Description)
        addObserverToKeyBoard()
        addGestureForKeyBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func keyboardWillShow(_ notification: NSNotification) {
        if m_DDType?.getContentByType(.First) == CheckLoseApply_TypeList[0] && curTextfield != m_tfCheckNumber && curTextfield != m_tfCheckAmount {
            super.keyboardWillShow(notification)
        }
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]] {
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]] {
                        if type == Account_Saving_Type {
                            accountList = [AccountStruct]()
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                    accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                                }
                            }
                        }
                        else if type == Account_Check_Type {
                            checkAccountList = [AccountStruct]()
                            for actInfo in result {
                                if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
                                    checkAccountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                                }
                            }
                        }
                    }
                }
                
                getImageConfirm(transactionId)
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0501":
            if let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage {
                m_ImageConfirmView?.m_ivShow.image = responseImage
            }
            
        case "COMM0502":
            if let flag = response[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] as? String, flag == ImageConfirm_Success {
                setLoading(true)
                if m_DDType?.m_lbFirstRowContent.text == CheckLoseApply_TypeList[0] {
                    postRequest("LOSE/LOSE0301", "LOSE0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"0403","Operate":"setLoseCheck1","TransactionId":transactionId,"TYPE":"11","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? "","TXAMT":m_tfCheckAmount.text ?? "","MACTNO":m_FeeAccount?.getContentByType(.First) ?? "","CKDAY":m_CheckDate?.getContentByType(.First).replacingOccurrences(of: "/", with: "") ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                }
                else {
                    postRequest("LOSE/LOSE0302", "LOSE0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"0403","Operate":"setLoseCheck2","TransactionId":transactionId,"TYPE":"13","REFNO":m_DDAccount?.getContentByType(.First) ?? "","CKNO":m_tfCheckNumber.text ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                getImageConfirm(transactionId)
                showErrorMessage(nil, ErrorMsg_Image_ConfirmFaild)
            }
            
        case "LOSE0301", "LOSE0302":
            var result = ConfirmResultStruct()
            result.resultBtnName = "繼續交易"
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                result.title = Lose_Successful_Title
                result.image = ImageName.CowSuccess.rawValue
                result.memo = CheckLoseApply_Memo
                if let data = response.object(forKey:ReturnData_Key) as? [String:String] {
                    result.list = [[String:String]]()
                    result.list?.append([Response_Key:"交易時間",Response_Value:data["TXTIME"] ?? ""])
                    result.list?.append([Response_Key:"掛失日期",Response_Value:data["TXDAY"] ?? ""])
                }
            }
            else {
                result.title = Lose_Faild_Title
                result.image = ImageName.CowFailure.rawValue
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    result.list = [[String:String]]()
                    result.list?.append([Response_Key:Error_Title,Response_Value:message])
                }
            }
            enterConfirmResultController(false, result, true)
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func setAllSubView() {
        setDDTypeView()
        setDDAccountView()
        setCheckNumberView()
        setCheckAmountView()
        setCheckDateView()
        setFeeAccountView()
        setImageConfirmView()
    }

    private func setDDTypeView() {
        if m_DDType == nil {
            m_DDType = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDType?.delegate = self
            m_DDType?.setOneRow(CheckLoseApply_ChooseType_Title, CheckLoseApply_TypeList[0])
            m_DDType?.frame = CGRect(x:0, y:0, width:m_vDDType.frame.width, height:(m_DDType?.getHeight())!)
            m_vDDType.addSubview(m_DDType!)
        }
        m_vDDType.layer.borderColor = Gray_Color.cgColor
        m_vDDType.layer.borderWidth = 1
    }

    private func setDDAccountView() {
        if m_DDAccount == nil {
            m_DDAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDAccount?.delegate = self
            m_DDAccount?.setOneRow(CheckLoseApply_CheckAccount_Title, Choose_Title)
            m_DDAccount?.frame = CGRect(x:0, y:0, width:m_vDDAccount.frame.width, height:(m_DDAccount?.getHeight())!)
            m_vDDAccount.addSubview(m_DDAccount!)
        }
        m_vDDAccount.layer.borderColor = Gray_Color.cgColor
        m_vDDAccount.layer.borderWidth = 1
    }
    
    private func setCheckNumberView() {
        m_vCheckNumber.layer.borderColor = Gray_Color.cgColor
        m_vCheckNumber.layer.borderWidth = 1
    }

    private func setCheckAmountView() {
        m_vCheckAmount.layer.borderColor = Gray_Color.cgColor
        m_vCheckAmount.layer.borderWidth = 1
    }

    private func setCheckDateView() {
        if m_CheckDate == nil {
            m_CheckDate = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_CheckDate?.delegate = self
            m_CheckDate?.setOneRow(CheckLoseApply_Date_Title, Choose_Title)
            m_CheckDate?.frame = CGRect(x:0, y:0, width:m_vCheckDate.frame.width, height:(m_CheckDate?.getHeight())!)
            m_vCheckDate.addSubview(m_CheckDate!)
        }
        
        m_vCheckDate.layer.borderColor = Gray_Color.cgColor
        m_vCheckDate.layer.borderWidth = 1
    }

    private func setFeeAccountView() {
        if m_FeeAccount == nil {
            m_FeeAccount = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_FeeAccount?.delegate = self
            m_FeeAccount?.setOneRow(CheckLoseApply_TransAccount_Title, Choose_Title)
            m_FeeAccount?.frame = CGRect(x:0, y:0, width:m_vFeeAccount.frame.width, height:(m_FeeAccount?.getHeight())!)
            m_vFeeAccount.addSubview(m_FeeAccount!)
        }
        m_vFeeAccount.layer.borderColor = Gray_Color.cgColor
        m_vFeeAccount.layer.borderWidth = 1
    }

    private func setImageConfirmView() {
        if m_ImageConfirmView == nil {
            m_ImageConfirmView = getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
            m_ImageConfirmView?.delegate = self
            m_vImageConfirmView.addSubview(m_ImageConfirmView!)
        }
        m_ImageConfirmView?.frame = CGRect(x:0, y:0, width:m_vImageConfirmView.frame.width, height:m_vImageConfirmView.frame.height)
        m_vImageConfirmView.layer.borderColor = Gray_Color.cgColor
        m_vImageConfirmView.layer.borderWidth = 1
    }
    
    private func hideSomeSubviews() {
        m_vCheckAmount.isHidden = true
        m_vCheckDate.isHidden = true
        m_vFeeAccount.isHidden = true
        m_consCheckAmountHeight.constant = 0
        m_consCheckDateHeight.constant = 0
        m_consFeeAccountHeight.constant = 0
    }
    
    private func showSomeSubviews() {
        m_vCheckAmount.isHidden = false
        m_vCheckDate.isHidden = false
        m_vFeeAccount.isHidden = false
        m_consCheckAmountHeight.constant = 60
        m_consCheckDateHeight.constant = 60
        m_consFeeAccountHeight.constant = 60
    }
    
    private func inputIsCorrect() -> Bool {
        if m_DDAccount?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDAccount?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (m_tfCheckNumber.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfCheckNumber.placeholder ?? "")")
            return false
        }
        if m_DDType?.m_lbFirstRowContent.text == CheckLoseApply_TypeList[0] {
            if (m_tfCheckAmount.text?.isEmpty)! {
                showErrorMessage(nil, "\(Enter_Title)\(m_tfCheckAmount.placeholder ?? "")")
                return false
            }
            if m_CheckDate?.getContentByType(.First) == Choose_Title {
                showErrorMessage(nil, "\(Choose_Title)\(m_CheckDate?.m_lbFirstRowTitle.text ?? "")")
                return false
            }
            if m_FeeAccount?.getContentByType(.First) == Choose_Title {
                showErrorMessage(nil, "\(Choose_Title)\(m_FeeAccount?.m_lbFirstRowTitle.text ?? "")")
                return false
            }
        }
        return true
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        view.endEditing(true)
        m_curDropDownView = sender
        if m_curDropDownView == m_CheckDate {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = view.frame
                datePicker.showOneDatePickerView(true, nil) { start in
                    self.m_CheckDate?.setOneRow(CheckLoseApply_Date_Title, "\(start.year)/\(start.month)/\(start.day)")
                }
                view.addSubview(datePicker)
            }
        }
        else {
            var list = [String]()
            var errorMessage = ""
            if m_curDropDownView == m_DDType {
                list = CheckLoseApply_TypeList
            }
            else if m_curDropDownView == m_DDAccount {
                if checkAccountList != nil {
                    for index in checkAccountList! {
                        list.append(index.accountNO)
                    }
                }
                else {
                    errorMessage = "\(Get_Null_Title)\(m_DDAccount?.m_lbFirstRowTitle.text ?? "")"
                }
            }
            else if m_curDropDownView == m_FeeAccount {
                if accountList != nil {
                    for index in accountList! {
                        list.append(index.accountNO)
                    }
                }
                else {
                    errorMessage = "\(Get_Null_Title)\(m_FeeAccount?.m_lbFirstRowTitle.text ?? "")"
                }
            }
            
            if errorMessage.isEmpty {
                let action = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                list.forEach{title in action.addButton(withTitle: title)}
                action.show(in: self.view)
            }
            else {
                showErrorMessage(nil, errorMessage)
            }
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            if m_curDropDownView == m_DDType {
                if (actionSheet.buttonTitle(at: buttonIndex) ?? "") == CheckLoseApply_TypeList[0] {
                    showSomeSubviews()
                }
                else {
                    hideSomeSubviews()
                }
            }
            m_curDropDownView?.setOneRow(m_curDropDownView?.m_lbFirstRowTitle.text ?? "", actionSheet.buttonTitle(at: buttonIndex) ?? "")
        }
        m_curDropDownView = nil
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        curTextfield = textField
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.characters.count)! - range.length + string.characters.count
        if textField == m_tfCheckNumber {
            if newLength > CheckLoseApply_Bill_Max_Length {
                return false
            }
        }
        return true
    }

    // MARK: - ImageConfirmCellDelegate
    func clickRefreshBtn() {
        getImageConfirm(transactionId)
    }
    
    func changeInputTextfield(_ input: String) {
        password = input
    }
    
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {
        curTextfield = textfield
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func m_btnSendClick(_ sender: Any) {
        if inputIsCorrect() {
            checkImageConfirm(password, transactionId)
        }
    }
}
