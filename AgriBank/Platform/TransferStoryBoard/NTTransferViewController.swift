//
//  TransferViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//
// 2019-9-2 Change by sweney + 取預設轉出帳號
import UIKit

let NTTransfer_BankCode = "銀行代碼"
let NTTransfer_InAccount = "轉入帳號"
let NTTransfer_OutAccount = "轉出帳號"
let NTTransfer_Currency = "幣別"
let NTTransfer_Balance = "餘額"
let NTTransfer_PredesignatedTrans_Max_Amount:Int = 2000000
let NTTransfer_NotPredesignatedTrans_Max_Amount:Int = 30000
let NTTransfer_PredesignatedTrans_Max_Length:Int = 7
let NTTransfer_NotPredesignatedTrans_Max_Length:Int = 5

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
    @IBOutlet weak var SendBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var enterAccountTextfield: TextField!
    @IBOutlet weak var transAmountTextfield: TextField!
    @IBOutlet weak var memoTextfield: TextField!
    @IBOutlet weak var memoTextfield2: TextField!
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
    private var inputAccount:String? = nil              // 由「帳戶總覽」帶入的帳號
    
    // MARK: - Public
    func setInitial(_ account:String?)  {
        if accountList != nil && account != nil {
            for index in 0..<(accountList?.count)! {
                if let info = accountList?[index], info.accountNO == account! {
                    accountIndex = index
                    topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance))
                    break
                }
            }
        }
        else {
            inputAccount = account
        }
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accountTypeSegCon.layer.borderWidth = Layer_BorderWidth
        accountTypeSegCon.layer.cornerRadius = Layer_BorderRadius
        accountTypeSegCon.layer.borderColor = Green_Color.cgColor
       let SegConFont =  UIFont(name: "PingFangTC-Medium", size: CGFloat(14)) ?? UIFont.systemFont(ofSize: CGFloat(14))
        //accountTypeSegCon.setTitleTextAttributes([NSAttributedStringKey.font:Default_Font], for: .normal)
        accountTypeSegCon.setTitleTextAttributes([NSAttributedString.Key.font:SegConFont], for: .normal)
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
        topDropView?.setThreeRow(NTTransfer_OutAccount, Choose_Title, NTTransfer_Currency, "", NTTransfer_Balance, "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        setShadowView(topView)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor

        showBankAccountDropView = getUIByID(.UIID_TwoRowDropDownView) as? TwoRowDropDownView
        showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, Choose_Title)
        showBankAccountDropView?.frame = showBankAccountView.frame
        showBankAccountDropView?.frame.origin = .zero
        showBankAccountDropView?.delegate = self
        showBankAccountView.addSubview(showBankAccountDropView!)
        
        showBankDorpView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        showBankDorpView?.setOneRow(NTTransfer_BankCode, Choose_Title)
        showBankDorpView?.frame = showBankView.frame
        showBankDorpView?.frame.origin = .zero
        showBankDorpView?.delegate = self
        showBankView.addSubview(showBankDorpView!)
        
        setShadowView(middleView)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        
        setShadowView(bottomView, .Top)
        
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        enterAccountTextfield.setCanUseDefaultAction(bCanUse: true)
        memoTextfield.setCanUseDefaultAction(bCanUse: true)
        memoTextfield2.setCanUseDefaultAction(bCanUse: true)
        emailTextfield.setCanUseDefaultAction(bCanUse: true)
        
        getTransactionID("03001", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String, (ebkfg == Account_EnableTrans || ebkfg == Account_TransOnly) {
                               accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                //2019-9-2 add by sweney -取index=0轉出帳號
                if(accountList?.count)! > 0 {
                    accountIndex = 0
                    if let info = accountList?[accountIndex!]{
                        topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance).separatorThousandDecimal())
                       // break
                    }
                }
                
                if inputAccount != nil {
                    for index in 0..<(accountList?.count)! {
                        if let info = accountList?[index], info.accountNO == inputAccount! {
                            accountIndex = index
                            topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance).separatorThousandDecimal())
                            break
                        }
                    }
                    inputAccount = nil
                }
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0401":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:String]] {
                bankNameList = array
                showBankList()
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0102":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let array = data["Result"] as? [[String:Any]] {
                    agreedAccountList = array
                }
                showInAccountList(isPredesignated)
            }
            else {
                super.didResponse(description, response)
            }
            
        case "ACCT0104":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
                if let array = data["Result2"] as? [[String:Any]] {
                    commonAccountList = array
                }
                showInAccountList(isPredesignated)
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0802":
            showNonPredesignated()
            
        case "TRAN0103":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let Id = data["taskId"] as? String {
                VaktenManager.sharedInstance().getTasksOperation{ resultCode, tasks  in
                    if VIsSuccessful(resultCode) && tasks != nil {
                        self.transNonPredesignated(tasks! as! [VTask], Id)
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
    
    // MARK: - Private
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
                    if (code == "600"){
                        //600放在第一個
                        array.insert(temp, at: 0)
                    }else{
                    array.append(temp)
                    }
                }
            }
            SGActionView.showSheetQr(withTitle: Choose_Title, itemTitles: array, selectedIndex: 0) { index in
                self.bankNameIndex = index
                let title = array[index]
                let array = title.components(separatedBy: .whitespaces)
                self.showBankDorpView?.setOneRow(NTTransfer_BankCode, array.first ?? "")
            }
        }
    }
    
    private func showInAccountList(_ isAgreedAccount:Bool) {
        if isAgreedAccount {
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
                        self.showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                    }
                }
                //Guester 20181120 轉入帳號增加暱稱 End
            }
            else {
                showErrorMessage(nil, ErrorMsg_GetList_InAgreedAccount)
            }
        }
        else {
            if commonAccountList != nil && (commonAccountList?.count)! > 0 {
//                let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
//
//                for info in commonAccountList! {
//                    if let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String,let EXPLANATION = info["EXPLANATION"] as? String {
//                        actSheet.addButton(withTitle: "(\(bankCode)) \(account)-\(EXPLANATION)")
//
//                    }
//                }
//                actSheet.tag = ViewTag.View_InAccountActionSheet.rawValue
//                actSheet.show(in: view)
                //sweney 20200221 常用帳號加備註
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
                    if let info = self.commonAccountList?[self.inAccountIndex!], let account = info["ACTNO"] as? String, let bankCode = info["IN_BR_CODE"] as? String ,let Email = info["EMAIL_ADDR"] as? String {
                        self.emailTextfield.text = Email
                        self.showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, bankCode, NTTransfer_InAccount, account)
                        
                    }
                }
                //sweney 20200221 常用帳號加備註 End
            }
            else {
                showErrorMessage(nil, ErrorMsg_GetList_InCommonAccount)
            }
        }
    }
    
    private func inputIsCorrect() -> Bool {
        if accountIndex == nil  {
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        
        if isPredesignated {
            if inAccountIndex == nil {
                showErrorMessage(nil, ErrorMsg_Choose_InAccount)
                return false
            }
        }
        else {
            if isCustomizeAct {
                if showBankDorpView?.getContentByType(.First) == Choose_Title {
                    showErrorMessage(nil, "\(Choose_Title)\((showBankDorpView?.m_lbFirstRowTitle.text)!)")
                    return false
                }
                if (enterAccountTextfield.text?.isEmpty)! {
                    showErrorMessage(nil, "\(Enter_Title)\(enterAccountTextfield.placeholder!)")
                    return false
                }
            }
            else {
                if inAccountIndex == nil {
                    showErrorMessage(nil, ErrorMsg_Choose_InAccount)
                    return false
                }
            }
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
            if isPredesignated {
//                if amount > NTTransfer_PredesignatedTrans_Max_Amount {
//                    showErrorMessage(nil, ErrorMsg_Predesignated_Amount)
//                    return false
//                }
            }
            else {
                if amount > NTTransfer_NotPredesignatedTrans_Max_Amount {
//                    showErrorMessage(nil, ErrorMsg_NotPredesignated_Amount)
//                    return false
                }
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
        if DetermineUtility.utility.checkStringContainIllegalCharacter(memoTextfield2.text!) {
            showErrorMessage(nil, "\(memoTextfield2.placeholder ?? "")\(ErrorMsg_Illegal_Character)")
            return false
        }
        if !DetermineUtility.utility.isValidEmail(emailTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Invalid_Email)
            return false
        }
        
        return true
    }
    
    private func showNonPredesignated() {
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
        showBankDorpView?.setOneRow(NTTransfer_BankCode, Choose_Title)
        inAccountIndex = nil
        showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, Choose_Title)
        accountTypeSegCon.selectedSegmentIndex = 0
    }
    
    private func transNonPredesignated(_ taskList:[VTask], _ taskID:String) {
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
                            
                let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0102", strSessionDescription: "TRAN0102", httpBody: nil, loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)
                
                let CARDACTNO = (jsonDic?["CARDACTNO"] as? String) ?? ""
                let INACT = (jsonDic?["INACT"] as? String) ?? ""
                let INBANK = (jsonDic?["INBANK"] as? String) ?? ""
                let TXAMT = (jsonDic?["TXAMT"] as? String) ?? ""
                let TXMEMO = (jsonDic?["TXMEMO"] as? String) ?? ""
                let TXMEMO2 = (jsonDic?["TXMEMO2"] as? String) ?? ""
                let MAIL = (jsonDic?["MAIL"] as? String) ?? ""
                
                var dataConfirm = ConfirmOTPStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest, httpBodyList: ["WorkCode":"03001","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":CARDACTNO,"INACT":INACT,"INBANK":INBANK,"TXAMT":TXAMT,"TXMEMO":TXMEMO,"TXMEMO2":TXMEMO2,"MAIL":MAIL,"taskId":taskID,"otp":""],task: task)
                
                dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:CARDACTNO])
                dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:INBANK])
                dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:INACT])
                dataConfirm.list?.append([Response_Key: "轉帳金額", Response_Value:TXAMT.separatorThousand()])
                dataConfirm.list?.append([Response_Key: "轉出帳號備記", Response_Value:TXMEMO])
                dataConfirm.list?.append([Response_Key: "轉入帳號備記", Response_Value:TXMEMO2])
                dataConfirm.list?.append([Response_Key: "受款人E-mail", Response_Value:MAIL])
                
                enterConfirmOTPController(dataConfirm, true)
            }
            catch {
                showErrorMessage(nil, error.localizedDescription)
            }
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickPredesignatedBtn(_ sender: Any) { // 約定轉帳
        //2019-12-17 add by sweney 4=約轉非約轉-chris20210908
        if CheckEBKFG("1")  == false {
            SendBtn.isHidden = true
        }else
        {
            SendBtn.isHidden = false
        }
        
        SetBtnColor(true)
        chooseActTypeView.isHidden = true
        chooseActTypeHeight.constant = 0
        enterAccountView.isHidden = true
        enterAccountHeight.constant = 0
        gapHeight.constant = 0
        showBankAccountView.isHidden = false
        showBankAccountHeight.constant = sShowBankAccountHeight
        inAccountIndex = nil
        showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, Choose_Title)
    }
    
    ///Flag:1:約轉 2:非約轉
    func CheckEBKFG (_ Flag: String) -> Bool {
        if (accountList!.count > 0 ){
        if let info = accountList?[accountIndex!] {
            if Flag == "2" {
                if info.status == Account_TransOnly {
                    topDropView?.setThreeRow(NTTransfer_OutAccount, Choose_Title, NTTransfer_Currency, "", NTTransfer_Balance, "")
                    return false
                }else{
                    topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance).separatorThousandDecimal() )
                    return true
                }
            }else{
                topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance).separatorThousandDecimal() )
                return true
            }
        }
        }
        return false
    }
 
    @IBAction func clickNonPredesignatedBtn(_ sender: Any) { // 非約定轉帳
//        guard self.checkLocationAuthorization() == true else {
//            return
//        }
      
        //2019-12-17 add by sweney 4=約轉非約轉
        if  CheckEBKFG("2") == false {
            SendBtn.isHidden = true
        }else
        {
            SendBtn.isHidden = false
        }
          setLoading(true)
        if AuthorizationManage.manage.canEnterNTNonAgreedTransfer() {
            if !SecurityUtility.utility.isJailBroken() {
                if let info = AuthorizationManage.manage.getResponseLoginInfo() {
                    VaktenManager.sharedInstance().authenticateOperation(withSessionID: info.Token ?? "") { resultCode in
                        if VIsSuccessful(resultCode) {
                            self.postRequest("Comm/COMM0802", "COMM0802", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03001","Operate":"KPDeviceCF","TransactionId":self.transactionId,"userIp":self.getIP()], true), AuthorizationManage.manage.getHttpHead(true))
                        }
                        else {
                            self.SetBtnColor(true)
                            self.showErrorMessage(nil, "\(ErrorMsg_Verification_Faild) \(resultCode.rawValue)")
                            self.setLoading(false)
                        }
                    }
                }
            }
            else {
                SetBtnColor(true)
                showErrorMessage(ErrorMsg_IsJailBroken, nil)
                setLoading(false)
            }
        }
        else {
            SetBtnColor(true)
            showErrorMessage(nil, ErrorMsg_NoAuth)
            setLoading(false)
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
            showBankDorpView?.setOneRow(NTTransfer_BankCode, Choose_Title)
            enterAccountTextfield.text = ""
            
        case 1: // 常用帳號
            isCustomizeAct = false
            enterAccountView.isHidden = true
            enterAccountHeight.constant = 0
            showBankAccountView.isHidden = false
            showBankAccountHeight.constant = sShowBankAccountHeight
            inAccountIndex = nil
            showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, Choose_Title)
        case 2: //手機轉帳
            enterFeatureByID(.FeatureID_MobileNTTransfer, false)
    //Guester 20180626
        case 3: // QR Code轉帳
            enterFeatureByID(.FeatureID_QRCodeTrans, false)
//            let controller = getControllerByID(.FeatureID_AcceptRules)
//            (controller as! AcceptRulesViewController).m_nextFeatureID = .FeatureID_QRCodeTrans
//            navigationController?.pushViewController(controller, animated: true)
    //Guester 20180626 End
        default:
            break
        }
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
        if inputIsCorrect() {
            if isPredesignated {
                let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0101", strSessionDescription: "TRAN0101", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03001","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":topDropView?.getContentByType(.First) ?? "","INACT":showBankAccountDropView?.getContentByType(.Second) ?? "","INBANK":showBankAccountDropView?.getContentByType(.First) ?? "","TXAMT":transAmountTextfield.text!,"TXMEMO":memoTextfield.text!,"TXMEMO2":memoTextfield2.text!,"MAIL":emailTextfield.text!], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false, timeOut: TIME_OUT_125)
                
                var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
                dataConfirm.list?.append([Response_Key: "轉出帳號", Response_Value:topDropView?.getContentByType(.First) ?? ""])
                dataConfirm.list?.append([Response_Key: "銀行代碼", Response_Value:showBankAccountDropView?.getContentByType(.First) ?? ""])
                dataConfirm.list?.append([Response_Key: "轉入帳號", Response_Value:showBankAccountDropView?.getContentByType(.Second) ?? ""])
                dataConfirm.list?.append([Response_Key: "轉帳金額", Response_Value:transAmountTextfield.text!.separatorThousand()])
//                dataConfirm.list?.append([Response_Key: "交易備註", Response_Value:memoTextfield.text!])
                dataConfirm.list?.append([Response_Key: "轉出帳號備記", Response_Value:memoTextfield.text!])
                dataConfirm.list?.append([Response_Key: "轉入帳號備記", Response_Value:memoTextfield2.text!])
                dataConfirm.list?.append([Response_Key: "受款人E-mail", Response_Value:emailTextfield.text!])
                
                enterConfirmResultController(true, dataConfirm, true)
            }
            else {
                setLoading(true)
                var inAccount = ""
                var inBank = ""
                if isCustomizeAct {
                    inAccount = enterAccountTextfield.text ?? ""
                    inBank = showBankDorpView?.getContentByType(.First) ?? ""
                }
                else {
                    inAccount = showBankAccountDropView?.getContentByType(.Second) ?? ""
                    inBank = showBankAccountDropView?.getContentByType(.First) ?? ""
                }
                postRequest("TRAN/TRAN0103", "TRAN0103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03001","Operate":"dataConfirm","TransactionId":transactionId,"CARDACTNO":topDropView?.getContentByType(.First) ?? "","INACT":inAccount,"INBANK":inBank,"TXAMT":transAmountTextfield.text!,"TXMEMO":memoTextfield.text!,"TXMEMO2":memoTextfield2.text!,"MAIL":emailTextfield.text!], true), AuthorizationManage.manage.getHttpHead(true))
            }
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
            let maxLength = isPredesignated ? NTTransfer_PredesignatedTrans_Max_Length : NTTransfer_NotPredesignatedTrans_Max_Length
            if newLength > maxLength {
                return false
            }
        }
        else if textField == emailTextfield  {
            if newLength > Max_Email_Length {
                return false
            }
        }
        else if textField == memoTextfield {
            if isPredesignated {
                if newLength > Max19_Memo_Length {
                    return false
                }
            }
            else {
                if newLength > Max50_Memo_Length {
                    return false
                }
            }
        }
        else if textField == memoTextfield2 {
            if isPredesignated {
                if newLength > Max19_Memo_Length {
                    return false
                }
            }
            else {
                if newLength > Max50_Memo_Length {
                    return false
                }
            }
        }
        
        else if textField == enterAccountTextfield {
            if newLength > Max_Account_Length {
                return false
            }
        }

        return true
    }
    
    // MARK: - ThreeRowDropDownViewDelegate
    func clickThreeRowDropDownView(_ sender: ThreeRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                if isPredesignated == true {
                    actSheet.addButton(withTitle: index.accountNO)
                }else{
                    if index.status == Account_EnableTrans {
                        actSheet.addButton(withTitle: index.accountNO)
                    }
                }
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
        }
        else {
            showErrorMessage(nil, "\(Get_Null_Title)\(sender.m_lbFirstRowTitle.text ?? "")")
        }
    }
    
    // MARK: - TwoRowDropDownViewDelegate
    func clickTwoRowDropDownView(_ sender: TwoRowDropDownView) {
        if accountIndex != nil {
            if( isPredesignated ) {
                // ACCT0102 專門取「約定帳戶列表」
                if agreedAccountList == nil {
                    setLoading(true)
                    postRequest("ACCT/ACCT0102", "ACCT0102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02002","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                }
                else {
                    showInAccountList(isPredesignated)
                }
            }
            else {
                if commonAccountList == nil {
                    setLoading(true)
                    postRequest("ACCT/ACCT0104", "ACCT0104", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02004","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0","ACTNO":accountList?[accountIndex!].accountNO ?? ""], true), AuthorizationManage.manage.getHttpHead(true))
                }
                else {
                    showInAccountList(isPredesignated)
                }
            }
        }
        else {
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
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
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
//            case ViewTag.View_BankActionSheet.rawValue:
//                bankNameIndex = buttonIndex-1
//                let title = actionSheet.buttonTitle(at: buttonIndex)
//                let array = title?.components(separatedBy: .whitespaces)
//                showBankDorpView?.setOneRow(NTTransfer_BankCode, array?.first ?? "")
                
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                if let info = accountList?[accountIndex!] {
                    topDropView?.setThreeRow(NTTransfer_OutAccount, info.accountNO, NTTransfer_Currency, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), NTTransfer_Balance, String(info.balance).separatorThousandDecimal() )
                }
                agreedAccountList = nil
                commonAccountList = nil
                showBankDorpView?.setOneRow(NTTransfer_BankCode, Choose_Title)
                enterAccountTextfield.text = ""
                transAmountTextfield.text = ""
                memoTextfield.text = ""
                memoTextfield2.text = ""
                emailTextfield.text = ""
                SendBtn.isHidden = false
                showBankAccountDropView?.setTwoRow(NTTransfer_BankCode, "", NTTransfer_InAccount, Choose_Title)
                
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
}
