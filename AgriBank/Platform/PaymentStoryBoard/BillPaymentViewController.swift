//
//  BillPaymentViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/3.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let BillPayment_Type1 = "自訂帳號"
let BillPayment_Type2 = "常用帳號"
let BillPayment_OutAccout_Title = "轉出帳號"
let BillPayment_Currency_Ttile = "幣別"
let BillPayment_Balance_Ttile = "餘額"
let BillPayment_BankCode_Title = "銀行代碼"
let BillPayment_InAccout_Title = "轉入帳號"

class BillPaymentViewController: BaseViewController, ThreeRowDropDownViewDelegate, OneRowDropDownViewDelegate, TwoRowDropDownViewDelegate, UIActionSheetDelegate, UITextFieldDelegate {
    @IBOutlet weak var m_vTransOutAccount: UIView!
    @IBOutlet weak var m_vShadowView: UIView!
    @IBOutlet weak var m_vAccountType: UIView!
    @IBOutlet weak var m_segAccountType: UISegmentedControl!
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
    @IBOutlet weak var bottomView: UIView!
    
    private var m_DDTransOutAccount: ThreeRowDropDownView? = nil
    private var m_DDTransInBank: OneRowDropDownView? = nil
    private var m_DDTransInBA: TwoRowDropDownView? = nil
    private var curType = BillPayment_Type1
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var commonAccountList:[[String:Any]]? = nil // 常用帳戶列表
    private var commonAccountIndex:Int? = nil           // 目前選擇轉入常用帳戶
    private var bankNameList:[[String:String]]? = nil   // 銀行代碼列表
    private var curTextfield:UITextField? = nil

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_DDTransOutAccount = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        m_DDTransOutAccount?.delegate = self
        m_DDTransOutAccount?.setThreeRow(BillPayment_OutAccout_Title, Choose_Title, BillPayment_Currency_Ttile, "", BillPayment_Balance_Ttile, "")
        m_DDTransOutAccount?.frame = CGRect(x:0, y:0, width:m_vTransOutAccount.frame.width, height:m_vTransOutAccount.frame.height)
        m_vTransOutAccount.addSubview(m_DDTransOutAccount!)
        m_vTransOutAccount.layer.borderWidth = Layer_BorderWidth
        m_vTransOutAccount.layer.borderColor = Gray_Color.cgColor
        setShadowView(m_vTransOutAccount)
        m_vTransOutAccount.layer.borderWidth = Layer_BorderWidth
        m_vTransOutAccount.layer.borderColor = Gray_Color.cgColor
        
        m_DDTransInBank = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_DDTransInBank?.delegate = self
        m_DDTransInBank?.setOneRow(BillPayment_BankCode_Title, Choose_Title)
        m_DDTransInBank?.frame = CGRect(x:0, y:0, width:m_vTransInBank.frame.width, height:m_vTransInBank.frame.height)
        m_vTransInBank.addSubview(m_DDTransInBank!)
        
        m_DDTransInBA = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        m_DDTransInBA?.delegate = self
        m_DDTransInBA?.setTwoRow(BillPayment_BankCode_Title, Choose_Title, BillPayment_InAccout_Title, "")
        m_DDTransInBA?.frame = CGRect(x:0, y:0, width:m_vTransInBA.frame.width, height:m_vTransInBA.frame.height)
        m_vTransInBA.addSubview(m_DDTransInBA!)
        
        initInputForType(BillPayment_Type1)
        
        setShadowView(m_vShadowView)
        m_vShadowView.layer.borderWidth = Layer_BorderWidth
        m_vShadowView.layer.borderColor = Gray_Color.cgColor
    
        m_segAccountType.setTitleTextAttributes([NSFontAttributeName:Default_Font], for: .normal)
        
        setShadowView(bottomView)
        bottomView.layer.borderWidth = Layer_BorderWidth
        bottomView.layer.borderColor = Gray_Color.cgColor
        
        addObserverToKeyBoard()
        addGestureForKeyBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "ACCT0101":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didResponse(description, response)
            }
            showOutAccountList()
            
        case "ACCT0102":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array2 = data["Result2"] as? [[String:Any]] {
                commonAccountList = array2
                showCommonAccountList()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0401":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:String]] {
                bankNameList = array
                showBankNameList()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "PAY0106":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.payBill(tasks!, Id)
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode)")
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func initInputForType(_ type:String) {
        if type == BillPayment_Type1 {
            m_consTransInBankHeight.constant = 60
            m_consTransInAccountHeight.constant = 60
            m_consTransInBAHeight.constant = 0
            m_vTransInBank.isHidden = false
            m_vTransInAccount.isHidden = false
            m_vTransInBA.isHidden = true
            m_DDTransInBank?.setOneRow(BillPayment_BankCode_Title, Choose_Title)
            m_tfTransInAccount.text = ""
        }
        else {
            m_consTransInBankHeight.constant = 0
            m_consTransInAccountHeight.constant = 0
            m_consTransInBAHeight.constant = 80
            m_vTransInBank.isHidden = true
            m_vTransInAccount.isHidden = true
            m_vTransInBA.isHidden = false
            commonAccountIndex = nil
            m_DDTransInBA?.setTwoRow(BillPayment_BankCode_Title, Choose_Title, BillPayment_InAccout_Title, "")
        }
    }
    
    private func showOutAccountList() {
        if accountList != nil {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    private func showBankNameList() {
        if bankNameList != nil {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for index in bankNameList! {
                if let name = index["bankName"], let code = index["bankCode"] {
                    actSheet.addButton(withTitle: "\(code) \(name)")
                }
            }
            actSheet.tag = ViewTag.View_BankActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    private func showCommonAccountList() {
        if commonAccountList != nil {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for info in commonAccountList! {
                if let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String {
                    actSheet.addButton(withTitle: "(\(bankCode)) \(account)")
                }
            }
            actSheet.tag = ViewTag.View_InAccountActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    private func inputIsCorrect() -> Bool {
        if m_DDTransOutAccount?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDTransOutAccount?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if curType == BillPayment_Type1 {
            if m_DDTransInBank?.getContentByType(.First) == Choose_Title {
                showErrorMessage(nil, "\(Choose_Title)\(m_DDTransInBank?.m_lbFirstRowTitle.text ?? "")")
                return false
            }
            if (m_tfTransInAccount.text?.isEmpty)! {
                showErrorMessage(nil, "\(Enter_Title)\(m_tfTransInAccount.placeholder ?? "")")
                return false
            }
        }
        else {
            if commonAccountIndex == nil {
                showErrorMessage(nil, "\(Choose_Title)\(BillPayment_Type2)")
                return false
            }
        }
        if (m_tfTransAmount.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfTransAmount.placeholder ?? "")")
            return false
        }
        if (m_tfTransMemo.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfTransMemo.placeholder ?? "")")
            return false
        }
        if (m_tfEmail.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfEmail.placeholder ?? "")")
            return false
        }
        if DetermineUtility.utility.isValidEmail(m_tfEmail.text!) {
            showErrorMessage(nil, ErrorMsg_Invalid_Email)
            return false
        }
        return true
    }
    
    private func payBill(_ taskList:[Any], _ taskID:String) {
        var INACT = ""
        var INBANK = ""
        if curType == BillPayment_Type1 {
            INACT = m_tfTransInAccount.text!
            INBANK = m_DDTransInBank?.getContentByType(.First) ?? ""
        }
        else {
            INACT = m_DDTransInBA?.getContentByType(.First) ?? ""
            INBANK = m_DDTransInBA?.getContentByType(.Second) ?? ""
        }
        let confirmRequest = RequestStruct(strMethod: "PAY/PAY0107", strSessionDescription: "PAY0107", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
        
        let dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: nil, memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList: ["WorkCode":"05002","Operate":"commitTxn","TransactionId":transactionId,"OUTACT":m_DDTransOutAccount?.getContentByType(.First) ?? "","INACT": INACT,"INBANK":INBANK,"TXAMT":Int(m_tfTransAmount.text!) ?? 0,"MEMO":m_tfTransMemo.text!,"EMAIL":m_tfEmail.text!,"taskId":taskID,"otp":""],task: nil)
        enterConfirmOTPController(dataConfirm, true)
    }

    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        curTextfield?.resignFirstResponder()
        if accountList == nil {
            setLoading(true)
            postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
        }
        else {
            showOutAccountList()
        }
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        curTextfield?.resignFirstResponder()
        if m_DDTransOutAccount?.getContentByType(.First) != Choose_Title {
            if bankNameList == nil {
                setLoading(true)
                postRequest("COMM/COMM0401", "COMM0401", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07001","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
            }
            else {
                showBankNameList()
            }
        }
        else {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDTransOutAccount?.m_lbFirstRowTitle.text ?? "")")
        }
    }
    
    // MARK: - TwoRowDropDownViewDelegate
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView) {
        curTextfield?.resignFirstResponder()
        if m_DDTransOutAccount?.getContentByType(.First) != Choose_Title {
            if m_DDTransInBA?.getContentByType(.First) == Choose_Title {
                setLoading(true)
                postRequest("ACCT/ACCT0102", "ACCT0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":m_DDTransOutAccount?.getContentByType(.First) ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                showCommonAccountList()
            }
        }
        else {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDTransOutAccount?.m_lbFirstRowTitle.text ?? "")")
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.cancelButtonIndex != buttonIndex {
            switch (actionSheet.tag) {
            case ViewTag.View_BankActionSheet.rawValue:
                let title = actionSheet.buttonTitle(at: buttonIndex)
                let array = title?.components(separatedBy: .whitespaces)
                m_DDTransInBank?.setOneRow(BillPayment_BankCode_Title, array?.first ?? "")
                
            case ViewTag.View_InAccountActionSheet.rawValue:
                commonAccountIndex = buttonIndex-1
                if let info = commonAccountList?[commonAccountIndex!], let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String {
                    m_DDTransInBA?.setTwoRow(BillPayment_BankCode_Title, bankCode, BillPayment_InAccout_Title, account)
                }
                
            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    m_DDTransOutAccount?.setThreeRow(BillPayment_OutAccout_Title, info.accountNO, BillPayment_Currency_Ttile, info.currency, BillPayment_Balance_Ttile, String(info.balance) )
                }
                
            default: break
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        curTextfield = textField
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickChangeActType(_ sender: Any) {
        let segCon:UISegmentedControl = sender as! UISegmentedControl
        curType = segCon.titleForSegment(at: segCon.selectedSegmentIndex)!
        initInputForType(curType)
    }
    
    @IBAction func m_btnSendClick(_ sender: Any) {
        if inputIsCorrect() {
            var inAccount = ""
            var bankCode = ""
            if curType == BillPayment_Type1 {
                bankCode = m_DDTransInBank?.getContentByType(.First) ?? ""
                inAccount = m_tfTransInAccount.text ?? ""
            }
            else {
                bankCode = m_DDTransInBA?.getContentByType(.First) ?? ""
                inAccount = m_DDTransInBA?.getContentByType(.Second) ?? ""
            }
            setLoading(true)
            postRequest("PAY/PAY0106", "PAY0106", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"OUTACT":m_DDTransOutAccount?.getContentByType(.First) ?? "","INACT":inAccount,"INBANK":bankCode,"TXAMT":m_tfTransAmount.text!,"MEMO":m_tfTransMemo.text!,"EMAIL":m_tfEmail.text!], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
}
