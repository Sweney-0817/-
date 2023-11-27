//
//  MobileNTTransferViewController.swift
//  AgriBank
//
//  Created by 傅意芸 on 2021/8/2.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit

let MobileTransfer_Type1 = "自訂帳號"
let MobileTransfer_Type2 = "常用帳號"
let MobileTransfer_OutAccout_Title = "轉出帳號"
let MobileTransfer_Currency_Ttile = "幣別"
let MobileTransfer_Balance_Ttile = "餘額"
let MobileTransfer_BankCode_Title = "銀行代碼"
let MobileTransfer_InAccout_Title = "轉入帳號"

class MobileNTTransferViewController: BaseViewController, ThreeRowDropDownViewDelegate, OneRowDropDownViewDelegate, TwoRowDropDownViewDelegate, UIActionSheetDelegate, UITextFieldDelegate {
    @IBOutlet weak var m_vTransOutAccount: UIView!
    @IBOutlet weak var m_vShadowView: UIView!
    
    // 常用-自訂
    @IBOutlet weak var m_vSelectAccountType: UIView!
    @IBOutlet weak var m_vAccountType: UIView!
    @IBOutlet weak var m_segAccountType: UISegmentedControl!
    @IBOutlet weak var m_vTransInBank: UIView!
    @IBOutlet weak var m_consTransInBankHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vTransInAccount: UIView!
    @IBOutlet weak var m_tfTransInAccount: TextField!
    @IBOutlet weak var m_consTransInAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var m_vTransInBA: UIView!
    @IBOutlet weak var m_consTransInBAHeight: NSLayoutConstraint!
    @IBOutlet weak var m_consSelectAccountTypeHeight: NSLayoutConstraint!

    // 輸入
    @IBOutlet weak var m_vInput: UIView!
    @IBOutlet weak var m_vTransPhone: UIView!
    @IBOutlet weak var m_tfTransPhone: TextField!
    @IBOutlet weak var m_vTransAmount: UIView!
    @IBOutlet weak var m_tfTransAmount: TextField!
    @IBOutlet weak var m_vTransMemo: UIView!
    @IBOutlet weak var m_tfTransMemo: TextField!
    @IBOutlet weak var m_tfTransMemo2: TextField!
    @IBOutlet weak var m_vEmail: UIView!
    @IBOutlet weak var m_tfEmail: TextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var m_separator1Height: NSLayoutConstraint!
    @IBOutlet weak var m_separator2Height: NSLayoutConstraint!
    @IBOutlet weak var m_consInputTop: NSLayoutConstraint!

    private var m_DDTransOutAccount: ThreeRowDropDownView? = nil
    private var m_DDTransInBank: OneRowDropDownView? = nil
    private var showBankAccountDropView:TwoRowDropDownView? = nil
    private var m_DDTransInBA: TwoRowDropDownView? = nil
    private var curType = MobileTransfer_Type1
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var commonAccountList:[[String:Any]]? = nil // 常用帳戶列表
    private var commonAccountIndex:Int? = nil           // 目前選擇轉入常用帳戶
    private var bankNameList:[[String:String]]? = nil   // 銀行代碼列表
    private var curTextfield:UITextField? = nil
    private var inAccountIndex:Int? = nil               // 目前選擇轉入帳號

    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_DDTransOutAccount = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        m_DDTransOutAccount?.delegate = self
        m_DDTransOutAccount?.setThreeRow(MobileTransfer_OutAccout_Title, Choose_Title, MobileTransfer_Currency_Ttile, "", MobileTransfer_Balance_Ttile, "")
        m_DDTransOutAccount?.frame = CGRect(x:0, y:0, width:m_vTransOutAccount.frame.width, height:m_vTransOutAccount.frame.height)
        m_vTransOutAccount.addSubview(m_DDTransOutAccount!)
        m_vTransOutAccount.layer.borderWidth = Layer_BorderWidth
        m_vTransOutAccount.layer.borderColor = Gray_Color.cgColor
        setShadowView(m_vTransOutAccount)
        m_vTransOutAccount.layer.borderWidth = Layer_BorderWidth
        m_vTransOutAccount.layer.borderColor = Gray_Color.cgColor
        
        m_DDTransInBank = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_DDTransInBank?.delegate = self
        m_DDTransInBank?.setOneRow(MobileTransfer_BankCode_Title, Choose_Title)
        m_DDTransInBank?.frame = CGRect(x:0, y:0, width:m_vTransInBank.frame.width, height:m_vTransInBank.frame.height)
        m_vTransInBank.addSubview(m_DDTransInBank!)
        
        m_DDTransInBA = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        m_DDTransInBA?.delegate = self
        m_DDTransInBA?.setTwoRow(MobileTransfer_BankCode_Title, Choose_Title, MobileTransfer_InAccout_Title, "")
        m_DDTransInBA?.frame = CGRect(x:0, y:0, width:m_vTransInBA.frame.width, height:m_vTransInBA.frame.height)
        m_vTransInBA.addSubview(m_DDTransInBA!)
        
        initInputForType(MobileTransfer_Type1)
        
        setShadowView(m_vShadowView)
        m_vShadowView.layer.borderWidth = Layer_BorderWidth
        m_vShadowView.layer.borderColor = Gray_Color.cgColor
    
        m_segAccountType.setTitleTextAttributes([NSAttributedString.Key.font:Default_Font], for: .normal)
        
        setShadowView(bottomView, .Top)
        bottomView.layer.borderWidth = Layer_BorderWidth
        bottomView.layer.borderColor = Gray_Color.cgColor
        
        showBankAccountDropView = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
               showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, Choose_Title)
               showBankAccountDropView?.frame = m_vTransInBA.frame
               showBankAccountDropView?.frame.origin = .zero
               showBankAccountDropView?.delegate = self
               m_vTransInBA.addSubview(showBankAccountDropView!)
        
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        m_tfTransPhone.setCanUseDefaultAction(bCanUse: true)
        m_tfTransMemo.setCanUseDefaultAction(bCanUse: true)
        m_tfTransMemo2.setCanUseDefaultAction(bCanUse: true)
        m_tfEmail.setCanUseDefaultAction(bCanUse: true)
        
        requestAcnt()

        // 第一階段不顯示常用-自訂選擇
        setAccountTypeHidden(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "ACCT0101": // 取得轉出帳號列表
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any],
               let array = data["Result"] as? [[String:Any]]
            {
                getAcntData(array)
                setAcnt()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0104": // 常用-自訂
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any]
            {
                if let array = data["Result2"] as? [[String:Any]] {
                    commonAccountList = array
                }
                showCommonAccountList()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0401": // 常用-自訂
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any],
               let array = data["Result"] as? [[String:String]]
            {
                bankNameList = array
                showBankNameList()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "TRAN1003": // 手機門號轉帳財金查詢
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any],
               let bankCode = data["BankCode"] as? String,
               let BankName = data["BankName"] as? String,
               let CustName = data["CustName"] as? String
            {
                if false == bankCode.isEmpty {
                    requestSignBegin(bankCode: bankCode, bankName: BankName, custName: CustName)
                } else {
                    showErrorMessage(nil, ErrorMsg_MobileNotRegisted) // 手機門號未註冊
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case "TRAN1004": // 手機門號轉帳確認
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any],
               let Id = data["taskId"] as? String
            {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.mobileTransfer(tasks! as! [VTask], Id)
                    }
                    else {
                        self.showErrorMessage(nil, "\(ErrorMsg_GetTasks_Faild) \(resultCode.rawValue)")
                    }
                }
            }
            else {
                showErrorMessage(nil, ErrorMsg_No_TaskId)
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    override func addObserverToKeyBoard() {
        removeObserverToKeyBoard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func keyboardWillShow(_ notification:NSNotification) {
        if loginView != nil, !(loginView?.isNeedRise())! {
            view.frame.origin.y = 0
            return
        }
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        
        // 換算 curTextfield 至 self.view的frame
        guard let txf = curTextfield,
              let frame1 = txf.superview?.convert(txf.frame, to: txf.superview?.superview),
              let frame2 = txf.superview?.superview?.superview?.convert(frame1, to: txf.superview?.superview?.superview?.superview),
              let frame3 = txf.superview?.superview?.superview?.superview?.superview?.convert(frame2, to: txf.superview?.superview?.superview?.superview?.superview?.superview)
        else { return }
        
        if (frame3.origin.y + originalY) >= keyboardRectangle.origin.y {
            let height = (frame3.origin.y + originalY + frame3.height) - keyboardRectangle.origin.y
            view.frame.origin.y = originalY - height
        }
    }

    // MARK: - API
    // 取得帳號列表
    private func requestAcnt() {
        setLoading(true)
        postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    // 手機門號轉帳財金查詢
    private func requestPhoneActno(phone: String) {
        let dict: [String: String] = ["WorkCode":"15003",
                                      "Operate":"queryData",
                                      "TransactionId":transactionId,
                                      "MobilePhone": phone,
        ]
        
        setLoading(true)
        postRequest("TRAN/TRAN1003", "TRAN1003", AuthorizationManage.manage.converInputToHttpBody(dict, true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    // 手機門號轉帳確認
    private func requestSignBegin(bankCode: String, bankName: String, custName: String) {
        let dict: [String: String] = ["WorkCode":"15005",
                                      "Operate":"queryData",
                                      "TransactionId":transactionId,
                                      "OUTACT":m_DDTransOutAccount?.getContentByType(.First) ?? "",
                                      "INACT":m_tfTransPhone.text ?? "",
                                      "INBANK":bankCode,
                                      "INBANKNAME":bankName,
                                      "INCUSTNAME":custName,
                                      "TXAMT":m_tfTransAmount.text ?? "",
                                      "TXMEMO":m_tfTransMemo.text ?? "", "TXMEMO2":m_tfTransMemo2.text ?? "",
                                      "MAIL":m_tfEmail.text ?? "",
        ]
        
        setLoading(true)
        postRequest("TRAN/TRAN1004", "TRAN1004", AuthorizationManage.manage.converInputToHttpBody(dict, true), AuthorizationManage.manage.getHttpHead(true))
    }
    
    // MARK: - Private
    
    // 是否需顯示常用-自訂選擇
    private func setAccountTypeHidden(_ isHidden: Bool) {
        m_vSelectAccountType.isHidden = isHidden
        m_consSelectAccountTypeHeight.constant = isHidden ? 0 : 263
        m_consInputTop.constant = isHidden ? 0 : 8
    }
    
    // 若轉出帳號只有一筆,則直接秀
    private func setAcnt() {
        if(accountList?.count)! > 0 {
            if let info = accountList?[0] {
                m_DDTransOutAccount?.setThreeRow(MobileTransfer_OutAccout_Title, info.accountNO, MobileTransfer_Currency_Ttile, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), MobileTransfer_Balance_Ttile, String(info.balance).separatorThousandDecimal())
            }
        }
    }
    
    private func getAcntData(_ array: [[String:Any]]) {
        accountList = [AccountStruct]()
        for category in array {
            if let type = category["ACTTYPE"] as? String,
               let result = category["AccountInfo"] as? [[String:Any]],
               type == Account_Saving_Type
            {
                for actInfo in result {
                    if let actNO = actInfo["ACTNO"] as? String, // 帳號
                       let curcd = actInfo["CURCD"] as? String, // 幣別
                       let bal = actInfo["BAL"] as? String, // 帳面餘額
                       let ebkfg = actInfo["EBKFG"] as? String, // 此帳號是否有轉出權限2:可轉帳 除了2 其他不可轉帳
                      // 1==1
                      ebkfg == Account_EnableTrans
                    {
                        accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                    }
                }
            }
        }
    }
    
    private func initInputForType(_ type:String) {
        if type == MobileTransfer_Type1 {
            m_consTransInBankHeight.constant = 60
            m_consTransInAccountHeight.constant = 60
            m_consTransInBAHeight.constant = 0
            m_separator1Height.constant = 1
            m_separator2Height.constant = 0
            m_vTransInBank.isHidden = false
            m_vTransInAccount.isHidden = false
            m_vTransInBA.isHidden = true
            m_DDTransInBank?.setOneRow(MobileTransfer_BankCode_Title, Choose_Title)
            m_tfTransInAccount.text = ""
        }
        else {
            //常用
             inAccountIndex = nil
            m_consTransInBankHeight.constant = 0
            m_consTransInAccountHeight.constant = 0
            m_consTransInBAHeight.constant = 80
            m_separator1Height.constant = 0
            m_separator2Height.constant = 0
            m_vTransInBank.isHidden = true
            m_vTransInAccount.isHidden = true
            m_vTransInBA.isHidden = false
            commonAccountIndex = nil
            m_DDTransInBA?.setTwoRow(MobileTransfer_BankCode_Title, Choose_Title, MobileTransfer_InAccout_Title, "")
        }
    }
    
    private func showOutAccountList() {
        if accountList != nil && (accountList?.count)! > 0 {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(m_DDTransOutAccount?.m_lbFirstRowTitle.text ?? "")")
        }
    }
    
    private func showBankNameList() {
        if bankNameList != nil {
//            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
//            for index in bankNameList! {
//                if let name = index["bankName"], let code = index["bankCode"] {
//                    let temp = "\(code) \(name)".trimmingCharacters(in: .whitespaces)
//                    actSheet.addButton(withTitle: temp)
//                }
//            }
//            actSheet.tag = ViewTag.View_BankActionSheet.rawValue
//            actSheet.show(in: view)
            var array = [String]()
            for index in bankNameList! {
                if let name = index["bankName"], let code = index["bankCode"] {
                    let temp = "\(code) \(name)".trimmingCharacters(in: .whitespaces)
                    array.append(temp)
                }
            }
            SGActionView.showSheet(withTitle: Choose_Title, itemTitles: array, selectedIndex: 0) { index in
                self.inAccountIndex = index
                let title = array[ self.inAccountIndex!]
                let array = title.components(separatedBy: .whitespaces)
                self.m_DDTransInBank?.setOneRow(MobileTransfer_BankCode_Title, array.first ?? "")
            }
        }
    }
    
    private func showCommonAccountList() {
        if commonAccountList != nil && (commonAccountList?.count)! > 0 {
            var aryBank = [String]()
            var aryNote = [String]()
            for info in commonAccountList! {
                if let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String, let note = info["EXPLANATION"] as? String {
                    aryBank.append("(\(bankCode)) \(account)")
                    aryNote.append(note)
                }
            }
            SGActionView.showSheet(withTitle: Choose_Title, itemTitles: aryBank, itemSubTitles: aryNote, selectedIndex: 0) { index in
                self.inAccountIndex = index
                if let info = self.commonAccountList?[index], let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String {
                    self.showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                }
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
        }
    }
    
    private func inputIsCorrect() -> Bool {
        // 轉出帳號
        if m_DDTransOutAccount?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(m_DDTransOutAccount?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        
        if !m_vSelectAccountType.isHidden // 可選擇常用-自訂
        {
            // 轉入帳號
            if curType == MobileTransfer_Type1 {
                if m_DDTransInBank?.getContentByType(.First) == Choose_Title
                {
                    showErrorMessage(nil, "\(Choose_Title)\(m_DDTransInBank?.m_lbFirstRowTitle.text ?? "")")
                    return false
                }
                if (m_tfTransInAccount.text?.isEmpty)! {
               
                    showErrorMessage(nil, "\(Enter_Title)\(m_tfTransInAccount.placeholder ?? "")")
                    return false
                }
                //支存03 只能繳虛擬帳號
                else{
                    let InAct = m_tfTransInAccount.text
                    let OutAct = m_DDTransOutAccount?.getContentByType(.First)
                    if InAct?.substring(from:3,length: 3) != "500" && OutAct?.substring(from:6, length:2) == "30" {
                        showErrorMessage(nil,  ErrorMsg_Pay03_for500)
                        return false
                    }
                }
            }
            else {
                if self.inAccountIndex == nil {
                    showErrorMessage(nil, "\(Choose_Title)\(BillPayment_Type2)")
                    return false
                }
                //支存03 只能繳虛擬帳號
                else{
                    let InAct = showBankAccountDropView?.getContentByType(.Second) ?? ""
                    let OutAct = m_DDTransOutAccount?.getContentByType(.First)
                    if InAct.substring(from:3,length: 3) != "500" && OutAct?.substring(from:6, length:2) == "30" {
                        showErrorMessage(nil,  ErrorMsg_Pay03_for500)
                        return false
                    }
                }
            }
        }
        
        // 轉入手機門號
        if (m_tfTransPhone.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfTransPhone.placeholder ?? "")")
            return false
        }
        
        // 轉帳金額
        if (m_tfTransAmount.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(m_tfTransAmount.placeholder ?? "")")
            return false
        }
        if let amount = Int(m_tfTransAmount.text!) {
            if amount == 0 {
                showErrorMessage(nil, ErrorMsg_Input_Amount)
                return false
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        
        // 備註/交易備記
        if DetermineUtility.utility.checkStringContainIllegalCharacter(m_tfTransMemo.text!) {
            showErrorMessage(nil, "\(m_tfTransMemo.placeholder ?? "")\(ErrorMsg_Illegal_Character)")
            return false
        }
        if DetermineUtility.utility.checkStringContainIllegalCharacter(m_tfTransMemo2.text!) {
            showErrorMessage(nil, "\(m_tfTransMemo2.placeholder ?? "")\(ErrorMsg_Illegal_Character)")
            return false
        }
        
        // 受款人Email
        if !DetermineUtility.utility.isValidEmail(m_tfEmail.text!) {
            showErrorMessage(nil, ErrorMsg_Invalid_Email)
            return false
        }
       
        return true
    }
    
    private func mobileTransfer(_ taskList:[VTask], _ taskID:String) {
        var task:VTask? = nil
        for info in taskList {
            if info.taskID == taskID {
                task = info
                break
            }
        }
        
        if task != nil, let data = task?.message.data(using: .utf8) {
            do {
                let jsonDic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                
                let OUTACT = (jsonDic?["OUTACT"] as? String) ?? ""
                let INACT = (jsonDic?["INACT"] as? String) ?? ""
                let INBANK = (jsonDic?["INBANK"] as? String) ?? ""
                let INBANKNAME = (jsonDic?["INBANKNAME"] as? String) ?? ""
                let INCUSTNAME = (jsonDic?["INCUSTNAME"] as? String) ?? ""
                let TXAMT = (jsonDic?["TXAMT"] as? String) ?? ""
                let MEMO = (jsonDic?["TXMEMO"] as? String) ?? ""
                let MEMO2 = (jsonDic?["TXMEMO2"] as? String) ?? ""
                let EMAIL = (jsonDic?["MAIL"] as? String) ?? ""
                
                let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN1005", strSessionDescription: "TRAN1005", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)
                
                var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue,
                                                   title: Check_Transaction_Title,
                                                   list: [[String:String]](),
                                                   memo: "",
                                                   confirmBtnName: "確認送出",
                                                   resultBtnName: "繼續交易",
                                                   checkRequest: confirmRequest,
                                                   httpBodyList: ["WorkCode":"15005",
                                                                  "Operate":"commitTxn",
                                                                  "TransactionId":transactionId,
                                                                  "OUTACT":OUTACT,
                                                                  "INACT": INACT,
                                                                  "INBANK":INBANK,
                                                                  "INBANKNAME":INBANKNAME,
                                                                  "INCUSTNAME":INCUSTNAME,
                                                                  "TXAMT":TXAMT,
                                                                  "TXMEMO":MEMO,
                                                                  "TXMEMO2":MEMO2,
                                                                  "MAIL":EMAIL,
                                                                  "taskId":taskID,
                                                                  "otp":""],task: task)
                
                dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:OUTACT])
                dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:INBANK])
                dataConfirm.list?.append([Response_Key: "銀行名稱", Response_Value:INBANKNAME])
                dataConfirm.list?.append([Response_Key: "轉入手機門號", Response_Value:INCUSTNAME])
                dataConfirm.list?.append([Response_Key: "戶名", Response_Value:INACT])
                dataConfirm.list?.append([Response_Key: "轉帳金額", Response_Value:TXAMT.separatorThousand()])
                dataConfirm.list?.append([Response_Key: "轉出帳號備記", Response_Value:MEMO])
                dataConfirm.list?.append([Response_Key: "轉入帳號備記", Response_Value:MEMO2])
                dataConfirm.list?.append([Response_Key: "受款人E-mail", Response_Value:EMAIL])
                enterConfirmOTPController(dataConfirm, true)
            }
            catch {
                showErrorMessage(nil, error.localizedDescription)
            }
        }
    }

    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        curTextfield?.resignFirstResponder()
        if accountList == nil {
            requestAcnt()
        }
        showOutAccountList()
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        curTextfield?.resignFirstResponder()
        if m_DDTransOutAccount?.getContentByType(.First) != Choose_Title {
            if bankNameList == nil {
//                setLoading(true)
//                postRequest("COMM/COMM0401", "COMM0401", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07001","Operate":"getList"], false), AuthorizationManage.manage.getHttpHead(false))
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
//                setLoading(true)
//                postRequest("ACCT/ACCT0104", "ACCT0104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02004","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":m_DDTransOutAccount?.getContentByType(.First) ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
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
//            case ViewTag.View_BankActionSheet.rawValue:
//                let title = actionSheet.buttonTitle(at: buttonIndex)
//                let array = title?.components(separatedBy: .whitespaces)
//                m_DDTransInBank?.setOneRow(MobileTransfer_BankCode_Title, array?.first ?? "")
                
            case ViewTag.View_InAccountActionSheet.rawValue:
                commonAccountIndex = buttonIndex-1
                if let info = commonAccountList?[commonAccountIndex!], let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String {
                    m_DDTransInBA?.setTwoRow(MobileTransfer_BankCode_Title, bankCode, MobileTransfer_InAccout_Title, account)
                }
                
            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    m_DDTransOutAccount?.setThreeRow(MobileTransfer_OutAccout_Title, info.accountNO, MobileTransfer_Currency_Ttile, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), MobileTransfer_Balance_Ttile, String(info.balance).separatorThousandDecimal())
                    commonAccountIndex = nil
                    m_DDTransInBA?.setTwoRow(MobileTransfer_BankCode_Title, Choose_Title, MobileTransfer_InAccout_Title, "")
                    m_tfTransAmount.text = ""
                    m_tfTransMemo.text = ""
                    m_tfTransMemo2.text = ""
                    m_tfEmail.text = ""
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count)! - range.length + string.count
        if textField == m_tfEmail {
            if newLength > Max_Email_Length {
                return false
            }
        }
        else if textField == m_tfTransMemo {
            if newLength > Max19_Memo_Length {
                return false
            }
        }
        else if textField == m_tfTransMemo2 {
            if newLength > Max19_Memo_Length {
                return false
            }
        }
        else if textField == m_tfTransInAccount {
            if newLength > Max_Account_Length {
                return false
            }
        }
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickChangeActType(_ sender: Any) {
        let segCon:UISegmentedControl = sender as! UISegmentedControl
        curType = segCon.titleForSegment(at: segCon.selectedSegmentIndex)!
        initInputForType(curType)
    }
    
    @IBAction func m_btnSendClick(_ sender: Any) {
        guard inputIsCorrect() else { return }
        requestPhoneActno(phone: m_tfTransPhone.text ?? "")
    }
}
