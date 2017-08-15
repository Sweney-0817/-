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
    
    // MARK: - Life cycle
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
        var data = ConfirmResultStruct(ImageName.CowCheck.rawValue, "請確認本次交易資訊", [[String:String]](), nil, "確認送出", "繼續交易")
        data.list!.append(["Key": "轉出帳號", "Value":"12345678901234"])
        data.list!.append(["Key": "銀行代碼", "Value":"008"])
        data.list!.append(["Key": "轉入帳號", "Value":"12345678901235"])
        data.list!.append(["Key": "轉帳金額", "Value":"9,999,999.00"])
        data.list!.append(["Key": "備註/交易備註", "Value":"備註"])
        data.list!.append(["Key": "受款人E-mail", "Value":"1234@gmail.com"])
        enterConfirmResultController(true, data, true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
        }
        else {
            showErrorMessage(nil, "請先選擇轉出帳戶")
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
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: "Data") as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                postRequest("ACCT/ACCT0101", "ACCT0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"02001","Operate":"getAcnt","TransactionId":transactionId,"LogType":"0"], true), AuthorizationManage.manage.getHttpHead(true))
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "ACCT0101":
            setLoading(false)
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
            setLoading(false)
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:String]] {
                bankNameList = array
                showBankList()
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "ACCT0102":
            setLoading(false)
            if let data = response.object(forKey: "Data") as? [String:Any], let array1 = data["Result"] as? [[String:Any]], let array2 = data["Result2"] as? [[String:Any]] {
                agreedAccountList = array1
                commonAccountList = array2
                showInAccountList(isPredesignated)
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
}
