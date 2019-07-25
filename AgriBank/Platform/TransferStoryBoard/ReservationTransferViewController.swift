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
let ReservationTransfer_Max_Amount:Int = 2000000
let ReservationTransfer_TransAmount_Max_Length:Int = 7

class ReservationTransferViewController: BaseViewController, UITextFieldDelegate, ThreeRowDropDownViewDelegate, TwoRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var showBankAccountView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var transAmountTextfield: TextField!
    @IBOutlet weak var memoTextfield: TextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var middleHeight: NSLayoutConstraint!
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
    var m_strCurrentDate:String? = nil          // 電文取回的當前營業日
    //Guester 20181120 新增轉帳生效、終止日
    @IBOutlet var m_vTransStartDate: UIView!
    @IBOutlet var m_consTransStartDateHeight: NSLayoutConstraint!
    @IBOutlet var m_vTransStopDate: UIView!
    @IBOutlet var m_consTransStopDateHeight: NSLayoutConstraint!
    var m_uiTransStartDateView: OneRowDropDownView? = nil   //轉帳生效日
    var m_uiTransStopDateView: OneRowDropDownView? = nil    //轉帳終止日
    var m_strTransStartDate: String? = nil  //轉帳生效日
    var m_strTransStopDate: String? = nil  //轉帳終止日
    //Guester 20181120 新增轉帳生效、終止日 End
    
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
        showBankAccountDropView?.setTwoRow(ReservationTransfer_BankCode, "", ReservationTransfer_InAccount, Choose_Title)
        showBankAccountDropView?.frame = showBankAccountView.frame
        showBankAccountDropView?.frame.origin = .zero
        showBankAccountDropView?.delegate = self
        showBankAccountView.addSubview(showBankAccountDropView!)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        setShadowView(middleView)
        
        setShadowView(bottomView, .Top)
        
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        self.initTransDate()
        getTransactionID("03002", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*  為了因應3.5吋而做的調整 */
//        if middleView.frame.maxY < bottomView.frame.minY {
//            middleHeight.constant += (bottomView.frame.minY - middleView.frame.maxY)
//            scrollView.isScrollEnabled = false
//        }
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
                //Guester 20180605 多發 COMM0701 以取得 CurrentDate
                setLoading(true)
                postRequest("COMM/COMM0701", "COMM0701", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03004","Operate":"queryData"], false), AuthorizationManage.manage.getHttpHead(false))
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0102":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let array = data["Result"] as? [[String:Any]] {
                    agreedAccountList = array
                }
                showInAccountList()
            }
            else {
                super.didResponse(description, response)
            }
        case "COMM0701"://Guester 20180605 多發 COMM0701 以取得 CurrentDate
            if  let data = response.object(forKey: ReturnData_Key) as? [String:Any],
                let array = data["Result"] as? [[String:Any]],
                let date = array.first?["CurrentDate"] as? String {
                m_strCurrentDate = date
            }
            else {
                showErrorMessage(nil, ErrorMsg_IsNot_TransTime)
            }
        default: super.didResponse(description, response)
        }
    }
    //Guester 20181120 新增轉帳生效、終止日
    // MARK: - 轉帳生效終止日
    private func initTransDate() {
        m_uiTransStartDateView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiTransStartDateView?.delegate = self
        m_uiTransStartDateView?.frame = m_vTransStartDate.frame
        m_uiTransStartDateView?.frame.origin = .zero
        m_uiTransStartDateView?.setOneRow("轉帳生效日", Choose_Title)
        m_uiTransStartDateView?.m_lbFirstRowTitle.textAlignment = .center
        m_vTransStartDate.addSubview(m_uiTransStartDateView!)

        m_uiTransStopDateView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        m_uiTransStopDateView?.delegate = self
        m_uiTransStopDateView?.frame = m_vTransStartDate.frame
        m_uiTransStopDateView?.frame.origin = .zero
        m_uiTransStopDateView?.setOneRow("轉帳終止日", Choose_Title)
        m_uiTransStopDateView?.m_lbFirstRowTitle.textAlignment = .center
        m_vTransStopDate.addSubview(m_uiTransStopDateView!)
    }
    private func showTransDate(_ isShow: Bool) {
        m_consTransStartDateHeight.constant = isShow ? 60 : 0
        m_consTransStopDateHeight.constant = isShow ? 60 : 0
        m_uiTransStartDateView?.setOneRow("轉帳生效日", Choose_Title)
        m_uiTransStopDateView?.setOneRow("轉帳終止日", Choose_Title)
        m_strTransStartDate = nil
        m_strTransStopDate = nil
    }
    //Guester 20181120 新增轉帳生效、終止日 End
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickSendBtn(_ sender: Any) {
        if inputIsCorrect() {
            //Guester 20181120 新增轉帳生效、終止日
            var data : [String:String] = [String:String]()
            data["WorkCode"] = "03002"
            data["Operate"] = "dataConfirm"
            data["TransactionId"] = transactionId
            data["ACTNO"] = topDropView?.getContentByType(.First) ?? ""
            data["TRACTNO"] = showBankAccountDropView?.getContentByType(.Second) ?? ""
            data["TRBANK"] = showBankAccountDropView?.getContentByType(.First) ?? ""
            data["AMOUNT"] = transAmountTextfield.text!
            data["DSCPTX"] = memoTextfield.text!
            data["DD"] = isFixedDate ? chooseDay:"00"
            data["RVDAY"] = isFixedDate ? "00000000":"\(chooseYear)\(chooseMonth)\(chooseDay)"
            if (isFixedDate) {
                data["STDATE"] = m_strTransStartDate ?? "00000000"
                data["STPDAY"] = m_strTransStopDate ?? "00000000"
            }
            else {
                data["STDATE"] = "00000000"
                data["STPDAY"] = "00000000"
            }
            //Guester 20181120 新增轉帳生效、終止日 End
//            let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0201", strSessionDescription: "TRAN0201", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03002","Operate":"dataConfirm","TransactionId":transactionId,"ACTNO":topDropView?.getContentByType(.First) ?? "","TRACTNO":showBankAccountDropView?.getContentByType(.Second) ?? "","TRBANK":showBankAccountDropView?.getContentByType(.First) ?? "","AMOUNT":transAmountTextfield.text!,"DSCPTX":memoTextfield.text!,"DD":(isFixedDate ? chooseDay:"00"),"RVDAY":(isFixedDate ? "00000000":"\(chooseYear)\(chooseMonth)\(chooseDay)")], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
            let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0201", strSessionDescription: "TRAN0201", httpBody: AuthorizationManage.manage.converInputToHttpBody(data, true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: REQUEST_TIME_OUT)
            
            var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
            dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:topDropView?.getContentByType(.First) ?? ""])
            dataConfirm.list?.append([Response_Key: "預約轉帳日", Response_Value:(isFixedDate ? "固定每月\(chooseDay)日":"\(chooseYear)/\(chooseMonth)/\(chooseDay)")])
            dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:showBankAccountDropView?.getContentByType(.First) ?? ""])
            dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:showBankAccountDropView?.getContentByType(.Second) ?? ""])
            dataConfirm.list?.append([Response_Key: "轉帳金額", Response_Value:transAmountTextfield.text!.separatorThousand()])
            dataConfirm.list?.append([Response_Key: "備註/交易備記", Response_Value:memoTextfield.text!])
            if (isFixedDate) {
                if (m_strTransStartDate != nil) {
                    dataConfirm.list?.append([Response_Key: "轉帳生效日", Response_Value:(m_strTransStartDate?.dateFormatter(form: dataDateFormat, to: showDateFormat))!])
                }
                else {
                    dataConfirm.list?.append([Response_Key: "轉帳生效日", Response_Value: "-"])
                }
                if (m_strTransStopDate != nil) {
                    dataConfirm.list?.append([Response_Key: "轉帳終止日", Response_Value:(m_strTransStopDate?.dateFormatter(form: dataDateFormat, to: showDateFormat))!])
                }
                else {
                    dataConfirm.list?.append([Response_Key: "轉帳終止日", Response_Value: "-"])
                }
            }
            enterConfirmResultController(true, dataConfirm, true)
        }
    }
    
    @IBAction func clickSpecificBtn(_ sender: Any) {
        isFixedDate = false
        self.showTransDate(isFixedDate)
        if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
            dateView.frame = CGRect(origin: .zero, size: view.frame.size)
//            var componenets = Calendar.current.dateComponents([.day,.year,.month], from: Date())
            //Guester 20180605 多發 COMM0701 以取得 CurrentDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let date = dateFormatter.date(from: m_strCurrentDate!)
            var componenetsMin = Calendar.current.dateComponents([.day,.year,.month], from: date ?? Date())
            componenetsMin.day = componenetsMin.day!+1
            var componenetsMax = Calendar.current.dateComponents([.day,.year,.month], from: date ?? Date())
            componenetsMax.month = componenetsMax.month!+3
            let startDate = InputDatePickerStruct(minDate: Calendar.current.date(from: componenetsMin), maxDate: Calendar.current.date(from: componenetsMax), curDate: Calendar.current.date(from: componenetsMin))
            dateView.showOneDatePickerView(true, startDate) { start in
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
        self.showTransDate(isFixedDate)
        if let dateView = getUIByID(.UIID_DatePickerView) as? DatePickerView {
            dateView.frame = CGRect(origin: .zero, size: view.frame.size)
            dateView.showOneDatePickerView(false, nil) { start in
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count)! - range.length + string.count
        if textField == transAmountTextfield {
            if newLength > ReservationTransfer_TransAmount_Max_Length {
                return false
            }
        }
        else if textField == memoTextfield {
            if newLength > Max19_Memo_Length {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            accountList?.forEach{index in actSheet.addButton(withTitle: index.accountNO)}
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
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
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
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
        if agreedAccountList != nil && (agreedAccountList?.count)! > 0 {
            //Guester 20181120 轉入帳號增加暱稱
            var aryBank = [String]()
            var aryNote = [String]()
            for info in agreedAccountList! {
                if let account = info["TRAC"] as? String, let bankCode = info["BKNO"] as? String, let note = info["NOTE"] as? String {
                    aryBank.append("(\(bankCode)) \(account)")
                    aryNote.append(note)
                }
            }
            SGActionView.showSheet(withTitle: Choose_Title, itemTitles: aryBank, itemSubTitles: aryNote, selectedIndex: 0) { index in
                self.inAccountIndex = index
                if let info = self.agreedAccountList?[self.inAccountIndex!], let account = info["TRAC"] as? String, let bankCode = info["BKNO"] as? String {
                    self.showBankAccountDropView?.setTwoRow(ReservationTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                }
            }
            //Guester 20181120 轉入帳號增加暱稱 End
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(showBankAccountDropView?.m_lbSecondRowTitle.text ?? "")")
        }
    }
    
    private func inputIsCorrect() -> Bool {
        if accountIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if dateLabel.text == ReservationTransfer_Choose_Type {
            showErrorMessage(nil, ErrorMsg_Transfer_Date)
            return false
        }
        if inAccountIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(showBankAccountDropView?.m_lbSecondRowTitle.text ?? "")")
            return false
        }
        if (transAmountTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(transAmountTextfield.placeholder ?? "")")
            return false
        }
        if let amount = Int(transAmountTextfield.text!) {
            if amount == 0 {
                showErrorMessage(nil, ErrorMsg_Input_Amount)
                return false
            }
            if amount > ReservationTransfer_Max_Amount {
                showErrorMessage(nil, ErrorMsg_Reservation_Amount)
                return false
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        if DetermineUtility.utility.checkStringContainIllegalCharacter(memoTextfield.text!) {
            showErrorMessage(nil, "\(memoTextfield.placeholder ?? "")\(ErrorMsg_Illegal_Character)")
            return false
        }
        //Guester 20181120 新增轉帳生效、終止日
        if (isFixedDate == true) {
            if (m_strTransStartDate == nil) {//只選轉帳終止日，未選轉帳生效日
                showErrorMessage(nil, "請選擇轉帳生效日")
                return false
            }
            if (m_strTransStopDate == nil) {//只選轉帳生效日，未選轉帳終止日
                showErrorMessage(nil, "請選擇轉帳終止日")
                return false
            }
            if (m_strTransStartDate != nil && m_strTransStopDate != nil) {//轉帳終止日<轉帳生效日
                if let startDate = m_strTransStartDate?.toDate(dataDateFormat), let stopDate = m_strTransStopDate?.toDate(dataDateFormat) {
                    if startDate.compare(stopDate) != .orderedAscending {
                        showErrorMessage(nil, "轉帳終止日應大於轉帳生效日")
                        return false
                    }
                }
                else {
                    showErrorMessage(nil, "日期錯誤")
                    return false
                }
            }
        }
        //Guester 20181120 新增轉帳生效、終止日 End
        return true
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                if let info = accountList?[accountIndex!] {
                    topDropView?.setThreeRow(ReservationTransfer_OutAccount, info.accountNO, ReservationTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), ReservationTransfer_Balance, String(info.balance).separatorThousand())
                    inAccountIndex = nil
                    showBankAccountDropView?.setTwoRow(ReservationTransfer_BankCode, "", NTTransfer_InAccount, Choose_Title)
                    transAmountTextfield.text = ""
                    memoTextfield.text = ""
                    agreedAccountList = nil
                }
                
            case ViewTag.View_InAccountActionSheet.rawValue:
                inAccountIndex = buttonIndex-1
                if let info = agreedAccountList?[inAccountIndex!], let account = info["TRAC"] as? String, let bankCode = info["BKNO"] as? String {
                    showBankAccountDropView?.setTwoRow(ReservationTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                }
                
            default: break
            }
        }
    }
}

//Guester 20181120 新增轉帳生效、終止日
extension ReservationTransferViewController : OneRowDropDownViewDelegate {
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        self.dismissKeyboard()
        if (sender == m_uiTransStartDateView) {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = CGRect(origin: .zero, size: view.frame.size)
                let today: Date = self.m_strCurrentDate!.toDate(showDateFormat)!
                var componenetsMin = Calendar.current.dateComponents([.day, .month, .year], from: today)
                componenetsMin.day = componenetsMin.day!+1
                var componenetsMax = Calendar.current.dateComponents([.day, .month, .year], from: today)
                componenetsMax.year = componenetsMax.year!+3
                let curDate = InputDatePickerStruct(minDate: Calendar.current.date(from: componenetsMin), maxDate: Calendar.current.date(from: componenetsMax), curDate: Calendar.current.date(from: componenetsMin))
                datePicker.showOneDatePickerView(true, curDate) { start in
                    self.m_strTransStartDate = "\(start.year)\(start.month)\(start.day)"
                    self.m_uiTransStartDateView?.setOneRow("轉帳生效日", self.m_strTransStartDate!.dateFormatter(form: dataDateFormat, to: showDateFormat))
                }
                view.addSubview(datePicker)
            }
            
        }
        else if (sender == m_uiTransStopDateView) {
            if let datePicker = getUIByID(.UIID_DatePickerView) as? DatePickerView {
                datePicker.frame = CGRect(origin: .zero, size: view.frame.size)
                let today: Date = self.m_strCurrentDate!.toDate(showDateFormat)!
                var componenetsMin = Calendar.current.dateComponents([.day, .month, .year], from: today)
                componenetsMin.day = componenetsMin.day!+2
                var componenetsMax = Calendar.current.dateComponents([.day, .month, .year], from: today)
                componenetsMax.year = componenetsMax.year!+3
                let curDate = InputDatePickerStruct(minDate: Calendar.current.date(from: componenetsMin), maxDate: Calendar.current.date(from: componenetsMax), curDate: Calendar.current.date(from: componenetsMin))
                datePicker.showOneDatePickerView(true, curDate) { end in
                    self.m_strTransStopDate = "\(end.year)\(end.month)\(end.day)"
                    self.m_uiTransStopDateView?.setOneRow("轉帳終止日", self.m_strTransStopDate!.dateFormatter(form: dataDateFormat, to: showDateFormat))
                }
                view.addSubview(datePicker)
            }
        }
    }
}
//Guester 20181120 新增轉帳生效、終止日 End
