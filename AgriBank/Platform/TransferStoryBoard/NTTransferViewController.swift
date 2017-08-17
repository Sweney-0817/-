//
//  TransferViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let NTTransfer_BankCode = "銀行代碼"
let NTTransfer_InAccount = "轉入帳號"
let NTTransfer_OutAccount = "轉出帳號"
let NTTransfer_Currency = "幣別"
let NTTransfer_Balance = "餘額"
let NTTransfer_Trans_Max_Amount:Int = 2000000
let NTTransfer_Email_Max_Length:Int = 50

class NTTransferViewController: BaseViewController, UITextFieldDelegate, ThreeRowDropDownViewDelegate, TwoRowDropDownViewDelegate, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topCons: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var accountTypeSegCon: UISegmentedControl!
    @IBOutlet weak var showBankAccountView: UIView!
    @IBOutlet weak var showBankAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var chooseActTypeView: UIView!
    @IBOutlet weak var chooseActTypeHeight: NSLayoutConstraint!
    @IBOutlet weak var enterAccountView: UIView!
    @IBOutlet weak var showBankView: UIView!
    @IBOutlet weak var enterAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var gapHeight: NSLayoutConstraint!
    @IBOutlet weak var predesignatedBtn: UIButton!
    @IBOutlet weak var nonPredesignatedBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var enterAccountTextfield: TextField!
    @IBOutlet weak var transAmountTextfield: TextField!
    @IBOutlet weak var memoTextfield: TextField!
    @IBOutlet weak var emailTextfield: TextField!
    
    private var isPredesignated = true     // 是否為約定轉帳
    private var isCustomizeAct = true      // 是否為自訂帳號
    private var sShowBankAccountHeight:CGFloat = 0
    private var sChooseActTypeHeight:CGFloat = 0
    private var sEnterAccountHeight:CGFloat = 0
    private var sGapHeight:CGFloat = 0
    private var topDropView:ThreeRowDropDownView? = nil
    private var showBankAccountDropView:TwoRowDropDownView? = nil
    private var showBankDorpView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var accountIndex:Int? = nil                 // 目前選擇轉出帳號
    private var bankNameList:[[String:String]]? = nil   // 銀行代碼列表
    private var bankNameIndex:Int? = nil                // 銀行代碼Index
    private var agreedAccountList:[[String:Any]]? = nil // 約定帳戶列表
    private var commonAccountList:[[String:Any]]? = nil // 常用帳戶列表
    private var inAccountIndex:Int? = nil               // 目前選擇轉入帳號
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accountTypeSegCon.layer.borderWidth = Layer_BorderWidth
        accountTypeSegCon.layer.cornerRadius = Layer_BorderRadius
        accountTypeSegCon.layer.borderColor = Green_Color.cgColor
        accountTypeSegCon.setTitleTextAttributes([NSFontAttributeName:Default_Font], for: .normal)
        
        sShowBankAccountHeight = showBankAccountHeight.constant
        sChooseActTypeHeight = chooseActTypeHeight.constant
        sEnterAccountHeight = enterAccountHeight.constant
        sGapHeight = gapHeight.constant
        
        if isPredesignated {
            chooseActTypeView.isHidden = true
            chooseActTypeHeight.constant = 0
            enterAccountView.isHidden = true
            enterAccountHeight.constant = 0
            gapHeight.constant = 0
            
        }
        else {
            if isCustomizeAct {
                showBankAccountView.isHidden = true
                showBankAccountHeight.constant = 0
            }
            else {
                enterAccountView.isHidden = true
                enterAccountHeight.constant = 0
            }
        }
        
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow(NTTransfer_OutAccount, "", NTTransfer_Currency, "", NTTransfer_Balance, "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        setShadowView(topView)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor

        showBankAccountDropView = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, "")
        showBankAccountDropView?.frame = showBankAccountView.frame
        showBankAccountDropView?.frame.origin = .zero
        showBankAccountDropView?.delegate = self
        showBankAccountView.addSubview(showBankAccountDropView!)
        
        showBankDorpView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        showBankDorpView?.setOneRow(NTTransfer_BankCode, "")
        showBankDorpView?.frame = showBankView.frame
        showBankDorpView?.frame.origin = .zero
        showBankDorpView?.delegate = self
        showBankView.addSubview(showBankDorpView!)
        
        setShadowView(middleView)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        
        setShadowView(bottomView)
        
        AddObserverToKeyBoard()
        
        setLoading(true)
        getTransactionID("03001", TransactionID_Description)
        
        emailTextfield.text = "test@test.com"
        transAmountTextfield.text = "1000"
        memoTextfield.text = "TEST1"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private 
    private func SetBtnColor(_ isPredesignated:Bool) {
        self.isPredesignated = isPredesignated
        if isPredesignated {
            predesignatedBtn.backgroundColor = Green_Color
            predesignatedBtn.setTitleColor(.white, for: .normal)
            nonPredesignatedBtn.backgroundColor = .white
            nonPredesignatedBtn.setTitleColor(.black, for: .normal)
        }
        else {
            nonPredesignatedBtn.backgroundColor = Green_Color
            nonPredesignatedBtn.setTitleColor(.white, for: .normal)
            predesignatedBtn.backgroundColor = .white
            predesignatedBtn.setTitleColor(.black, for: .normal)
        }
    }
    
    private func showBankList() {
        if bankNameList != nil {
            let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
            for index in bankNameList! {
                if let name = index["bankName"], let code = index["bankCode"] {
                    actSheet.addButton(withTitle: "\(code) \(name)")
                }
            }
            actSheet.tag = ViewTag.View_BankActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    private func showInAccountList(_ isAgreedAccount:Bool) {
        if isAgreedAccount {
            if agreedAccountList != nil {
                let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
                for info in agreedAccountList! {
                    if let account = info["TRAC"] as? String, let bankCode = info["BKNO"] as? String {
                        actSheet.addButton(withTitle: "\(account) \(bankCode)")
                    }
                }
                actSheet.tag = ViewTag.View_InAccountActionSheet.rawValue
                actSheet.show(in: view)
            }
        }
        else {
            if commonAccountList != nil {
                let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
                for info in commonAccountList! {
                    if let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String {
                        actSheet.addButton(withTitle: "\(account) \(bankCode)")
                    }
                }
                actSheet.tag = ViewTag.View_InAccountActionSheet.rawValue
                actSheet.show(in: view)
            }
        }
    }
    
    private func InputIsCorrect() -> Bool {
        var errorMessage = ""
        if accountList == nil {
            errorMessage.append("\(ErrorMsg_GetList_OutAccount)\n")
        }
        if accountIndex == nil {
            errorMessage.append("\(ErrorMsg_Choose_OutAccount)\n")
        }
        
        if isPredesignated {
            if agreedAccountList == nil {
                errorMessage.append("\(ErrorMsg_GetList_InAgreedAccount)\n")
            }
            if inAccountIndex == nil {
                errorMessage.append("\(ErrorMsg_Choose_InAccount)\n")
            }
            if (transAmountTextfield.text?.isEmpty)! {
                errorMessage.append("\(ErrorMsg_Enter_Amount)\n")
            }
            if DetermineUtility.utility.checkStringContainIllegalCharacter(memoTextfield.text!) {
                errorMessage.append("\(ErrorMsg_Illegal_Character)\n")
            }
            if !DetermineUtility.utility.isValidEmail(emailTextfield.text!) {
                errorMessage.append("\(ErrorMsg_Invalid_Email)\n")
            }
        }
        else {
            
        }
        
        if errorMessage.isEmpty {
            return true
        }
        else {
            showErrorMessage(nil, errorMessage)
            return false
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickPredesignatedBtn(_ sender: Any) { // 約定轉帳
        SetBtnColor(true)
        chooseActTypeView.isHidden = true
        chooseActTypeHeight.constant = 0
        enterAccountView.isHidden = true
        enterAccountHeight.constant = 0
        gapHeight.constant = 0
        showBankAccountView.isHidden = false
        showBankAccountHeight.constant = sShowBankAccountHeight
        inAccountIndex = nil
        showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, "")
    }
 
    @IBAction func clickNonPredesignatedBtn(_ sender: Any) { // 非約定轉帳
        if !SecurityUtility.utility.isJailBroken() {
            SetBtnColor(false)
            chooseActTypeView.isHidden = false
            chooseActTypeHeight.constant = sChooseActTypeHeight
            gapHeight.constant = sGapHeight
            if isCustomizeAct {
                showBankAccountView.isHidden = true
                showBankAccountHeight.constant = 0
                enterAccountView.isHidden = false
                enterAccountHeight.constant = sEnterAccountHeight
            }
            else {
                enterAccountView.isHidden = true
                enterAccountHeight.constant = 0
                showBankAccountView.isHidden = false
                showBankAccountHeight.constant = sShowBankAccountHeight
            }
            bankNameIndex = nil
            showBankDorpView?.setOneRow(NTTransfer_BankCode, "")
            inAccountIndex = nil
            showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, "")
            accountTypeSegCon.selectedSegmentIndex = 0
        }
        else {
            
        }
    }

    @IBAction func clickChangeActType(_ sender: Any) {
        let segCon:UISegmentedControl = sender as! UISegmentedControl
        switch segCon.selectedSegmentIndex {
        case 0: // 自訂帳號
            isCustomizeAct = true
            showBankAccountView.isHidden = true
            showBankAccountHeight.constant = 0
            enterAccountView.isHidden = false
            enterAccountHeight.constant = sEnterAccountHeight
            bankNameIndex = nil
            showBankDorpView?.setOneRow(NTTransfer_BankCode, "")
            enterAccountTextfield.text = ""
            
        default: // 常用帳號
            isCustomizeAct = false
            enterAccountView.isHidden = true
            enterAccountHeight.constant = 0
            showBankAccountView.isHidden = false
            showBankAccountHeight.constant = sShowBankAccountHeight
            inAccountIndex = nil
            showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, "")
        }
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
        if InputIsCorrect() {
            if isPredesignated {
                let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0101", strSessionDescription: "TRAN0101", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03001","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":topDropView?.getContentByType(.First) ?? "","INACT":showBankAccountDropView?.getContentByType(.Second) ?? "","INBANK":showBankAccountDropView?.getContentByType(.First) ?? "","TXAMT":transAmountTextfield.text!,"TXMEMO":memoTextfield.text!,"MAIL":emailTextfield.text!], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
                
                var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
                dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:topDropView?.getContentByType(.First) ?? ""])
                dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:showBankAccountDropView?.getContentByType(.First) ?? ""])
                dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:showBankAccountDropView?.getContentByType(.Second) ?? ""])
                dataConfirm.list?.append([Response_Key: "轉帳金額", Response_Value:transAmountTextfield.text!])
                dataConfirm.list?.append([Response_Key: "備註/交易備記", Response_Value:memoTextfield.text!])
                dataConfirm.list?.append([Response_Key: "受款人email", Response_Value:emailTextfield.text!])
                enterConfirmResultController(true, dataConfirm, true)
            }
            else {
                
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == transAmountTextfield {
            // ToolBar
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = ToolBar_tintColor
            toolBar.sizeToFit()
            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: ToolBar_DoneButton_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: ToolBar_CancelButton_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
            toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == transAmountTextfield {
            if let amount = Int(transAmountTextfield.text!), amount > NTTransfer_Trans_Max_Amount {
                return false
            }
        }
        if textField == emailTextfield {
            let newLength = (textField.text?.characters.count)! - range.length + string.characters.count
            if newLength > NTTransfer_Email_Max_Length {
                return false
            }
        }

        return true
    }
    
    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
    }
    
    // MARK: - TwoRowDropDownViewDelegate
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView) {
        if accountIndex != nil {
            if agreedAccountList == nil && commonAccountList == nil {
                setLoading(true)
                postRequest("ACCT/ACCT0102", "ACCT0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                showInAccountList(isPredesignated)
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_Choose_OutAccount)
        }
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if bankNameList == nil {
            setLoading(true)
            postRequest("COMM/COMM0401", "COMM0401", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07001","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
        }
        else {
            showBankList()
        }
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                setLoading(true)
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "ACCT0101":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["Result"] as? [[String:Any]], type == "P" {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "COMM0401":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:String]] {
                bankNameList = array
                showBankList()
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "ACCT0102":
            if let data = response.object(forKey: "Data") as? [String:Any], let array1 = data["Result"] as? [[String:Any]], let array2 = data["Result2"] as? [[String:Any]] {
                agreedAccountList = array1
                commonAccountList = array2
                showInAccountList(isPredesignated)
            }
            else {
                super.didRecvdResponse(description, response)
            }
        
        default: super.didRecvdResponse(description, response)
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_BankActionSheet.rawValue:
                bankNameIndex = buttonIndex-1
                let title = actionSheet.buttonTitle(at: buttonIndex)
                let array = title?.components(separatedBy: .whitespaces)
                showBankDorpView?.setOneRow(NTTransfer_BankCode, array?.first ?? "")
                
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                if let info = accountList?[accountIndex!] {
                    topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, info.currency, NTTransfer_Balance, String(info.balance) )
                }
                
            case ViewTag.View_InAccountActionSheet.rawValue:
                inAccountIndex = buttonIndex-1
                if isPredesignated {
                    if let info = agreedAccountList?[inAccountIndex!], let account = info["TRAC"] as? String, let bankCode = info["BKNO"] as? String {
                        showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                    }
                }
                else {
                    if let info = commonAccountList?[inAccountIndex!], let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String {
                        showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                    }
                }
                
            default: break
            }
        }
    }
    
    // MARK: - Selector
    func clickCancelBtn(_ sender:Any) {
        transAmountTextfield.text = ""
        transAmountTextfield.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        transAmountTextfield.resignFirstResponder()
    }
}
