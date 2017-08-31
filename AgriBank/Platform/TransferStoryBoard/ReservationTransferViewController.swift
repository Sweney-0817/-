//
//  ReserveTransferViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/30.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ReservationTransfer_Choose_Type = "請選擇預約轉帳類型"
let ReservationTransfer_BankCode = "銀行代碼"
let ReservationTransfer_InAccount = "轉入帳號"
let ReservationTransfer_OutAccount = "轉出帳號"
let ReservationTransfer_Currency = "幣別"
let ReservationTransfer_Balance = "餘額"

class ReservationTransferViewController: BaseViewController, UITextFieldDelegate, ThreeRowDropDownViewDelegate, TwoRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var showBankAccountView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var transAmountTextfield: TextField!
    @IBOutlet weak var memoTextfield: TextField!
    private var topDropView:ThreeRowDropDownView? = nil
    private var showBankAccountDropView:TwoRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil      // 帳號列表
    private var accountIndex:Int? = nil                 // 目前選擇轉出帳號
    private var agreedAccountList:[[String:Any]]? = nil // 約定帳戶列表
    private var inAccountIndex:Int? = nil               // 目前選擇轉入帳號
    private var isFixedDate = true                      // 判斷是否為「固定每月」
    private var chooseDay = ""                          // 選擇的日
    private var chooseMonth = ""                        // 選擇的月
    private var chooseYear = ""                         // 選擇的年
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow(ReservationTransfer_OutAccount, Choose_Title, ReservationTransfer_Currency, "", ReservationTransfer_Balance, "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        setShadowView(topView)
        
        showBankAccountDropView = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        showBankAccountDropView?.setTwoRow(ReservationTransfer_BankCode, "", ReservationTransfer_InAccount, "")
        showBankAccountDropView?.frame = showBankAccountView.frame
        showBankAccountDropView?.frame.origin = .zero
        showBankAccountDropView?.delegate = self
        showBankAccountView.addSubview(showBankAccountDropView!)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        setShadowView(middleView)
        
        setShadowView(bottomView)
        
        addObserverToKeyBoard()
        
        setLoading(true)
        getTransactionID("03002", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSendBtn(_ sender: Any) {
        if InputIsCorrect() {
            let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0201", strSessionDescription: "TRAN0201", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03002","Operate":"dataConfirm","TransactionId":transactionId,"ACTNO":topDropView?.getContentByType(.First) ?? "","TRACTNO":showBankAccountDropView?.getContentByType(.Second) ?? "","TRBANK":showBankAccountDropView?.getContentByType(.First) ?? "","AMOUNT":transAmountTextfield.text!,"DSCPTX":memoTextfield.text!,"DD":(isFixedDate ? chooseDay:"00"),"RVDAY":(isFixedDate ? "00000000":"\(chooseYear)\(chooseMonth)\(chooseDay)")], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
            
            var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
            dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:topDropView?.getContentByType(.First) ?? ""])
            dataConfirm.list?.append([Response_Key: "預約轉帳日", Response_Value:(isFixedDate ? "固定每月\(chooseDay)日":"\(chooseYear)/\(chooseMonth)/\(chooseDay)")])
            dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:showBankAccountDropView?.getContentByType(.First) ?? ""])
            dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:showBankAccountDropView?.getContentByType(.Second) ?? ""])
            dataConfirm.list?.append([Response_Key: "轉帳金額", Response_Value:transAmountTextfield.text!])
            dataConfirm.list?.append([Response_Key: "備註/交易備記", Response_Value:memoTextfield.text!])
            enterConfirmResultController(true, dataConfirm, true)
        }
    }
    
    @IBAction func clickSpecificBtn(_ sender: Any) {
        isFixedDate = false
        if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
            dateView.frame = view.frame
            dateView.showOneDatePickerView(true) { start in
                self.chooseDay = start.day
                self.chooseMonth = start.month
                self.chooseYear = start.year
                let date = "\(start.year)/\(start.month)/\(start.day)"
                let detailDate = NSString(string:"特定日期(3個月內) \(date) 轉出")
                let attributeDate = NSMutableAttributedString(string: (detailDate as String), attributes: [NSFontAttributeName:Default_Font])
                attributeDate.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: detailDate.range(of: date))
                self.dateLabel.attributedText = attributeDate
            }
            view.addSubview(dateView)
        }
    }
    
    @IBAction func clickFixedBtn(_ sender: Any) {
        isFixedDate = true
        if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
            dateView.frame = view.frame
            dateView.showOneDatePickerView(false) { start in
                let date = start.day
                self.chooseDay = date.replacingOccurrences(of: "日", with: "")
                let detailDate = NSString(string:"固定每月 \(date) 轉出")
                let attributeDate = NSMutableAttributedString(string: (detailDate as String), attributes: [NSFontAttributeName:Default_Font])
                attributeDate.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: detailDate.range(of: date))
                self.dateLabel.attributedText = attributeDate
            }
            view.addSubview(dateView)
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
            toolBar.barTintColor = ToolBar_barTintColor
            toolBar.tintColor = ToolBar_tintColor
            toolBar.sizeToFit()
            // Adding Button ToolBar
            let doneButton = UIBarButtonItem(title: ToolBar_DoneButton_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: ToolBar_CancelButton_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ToolBar_Title_Weight, height: toolBar.frame.height))
            titleLabel.textColor = .black
            titleLabel.text = Choose_Title
            titleLabel.textAlignment = .center
            let titleButton = UIBarButtonItem(customView: titleLabel)
            
            toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            textField.inputAccessoryView = toolBar
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
            if agreedAccountList == nil {
                setLoading(true)
                postRequest("ACCT/ACCT0102", "ACCT0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                showInAccountList()
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_Choose_OutAccount)
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
    
    // MARK: - Private
    private func showInAccountList() {
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
    
    private func InputIsCorrect() -> Bool {
        var errorMessage = ""
        if accountList == nil {
            errorMessage.append("\(ErrorMsg_GetList_OutAccount)\n")
        }
        if accountIndex == nil {
            errorMessage.append("\(ErrorMsg_Choose_OutAccount)\n")
        }
        if dateLabel.text == ReservationTransfer_Choose_Type {
            errorMessage.append("\(ErrorMsg_Transfer_Date)\n")
        }
        if agreedAccountList == nil {
            errorMessage.append("\(ErrorMsg_GetList_InAgreedAccount)\n")
        }
        if inAccountIndex == nil {
            errorMessage.append("\(ErrorMsg_Choose_InAccount)\n")
        }
        if (transAmountTextfield.text?.isEmpty)! {
            errorMessage.append("\(ErrorMsg_Enter_TransAmount)\n")
        }
        if DetermineUtility.utility.checkStringContainIllegalCharacter(memoTextfield.text!) {
            errorMessage.append("\(ErrorMsg_Illegal_Character)\n")
        }
        
        if errorMessage.isEmpty {
            return true
        }
        else {
            showErrorMessage(nil, errorMessage)
            return false
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
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Saving_Type {
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
            
        case "ACCT0102":
            if let data = response.object(forKey: "Data") as? [String:Any], let array1 = data["Result"] as? [[String:Any]] {
                agreedAccountList = array1
                showInAccountList()
            }
            else {
                super.didRecvdResponse(description, response)
            }
        
        default: break
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                if let info = accountList?[accountIndex!] {
                    topDropView?.setThreeRow(ReservationTransfer_OutAccount, info.accountNO, ReservationTransfer_Currency, info.currency, ReservationTransfer_Balance, String(info.balance) )
                    inAccountIndex = nil
                    showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, "")
                    transAmountTextfield.text = ""
                    memoTextfield.text = ""
                }
                
            case ViewTag.View_InAccountActionSheet.rawValue:
                inAccountIndex = buttonIndex-1
                if let info = agreedAccountList?[inAccountIndex!], let account = info["TRAC"] as? String, let bankCode = info["BKNO"] as? String {
                    showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                }
                
            default: break
            }
        }
    }
}
