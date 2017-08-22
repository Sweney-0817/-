//
//  DepositCombinedToDepositViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/4.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DepositCombinedToDeposit_Account_Title = "綜存帳號"
let DepositCombinedToDeposit_Currency_Title = "幣別"
let DepositCombinedToDeposit_Balance_Title = "餘額"
let DepositCombinedToDeposit_DepositType_Title = "存款種類"
let DepositCombinedToDeposit_Period_Title = "轉存期別"
let DepositCombinedToDeposit_Rate_Title = "利率方式"
let DepositCombinedToDeposit_AutoRateType_Title = "自動轉\n期利率"

class DepositCombinedToDepositViewController: BaseViewController, UITextFieldDelegate, ThreeRowDropDownViewDelegate, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var depositTypeView: UIView!
    @IBOutlet weak var periodView: UIView!
    @IBOutlet weak var currentRateLabel: UILabel!
    @IBOutlet weak var expireSaveType1tBtn: UIButton!      // "到期續存" - expireSaveType1
    @IBOutlet weak var expireSaveType2tBtn: UIButton!      // "到期續存" - expireSaveType2
    @IBOutlet weak var rateTypeView: UIView!
    @IBOutlet weak var autoTransRateType: UIView!
    @IBOutlet weak var expireSaveType1: UILabel!           // 到期續存 - 第一個顯示 Title from responseExpireSaveList[0]
    @IBOutlet weak var expireSaveType2: UILabel!           // 到期續存 - 第二個顯示 Title from responseExpireSaveList[1]
    @IBOutlet weak var transAmountTextfield: TextField!
    private var topDropView:ThreeRowDropDownView? = nil
    private var depositTypeDropView:OneRowDropDownView? = nil       // "存款種類"
    private var rateTypeDropView:OneRowDropDownView? = nil          // "利率方式"
    private var periodDropView:OneRowDropDownView? = nil            // "轉存期別"
    private var autoTransRateTypeDropView:OneRowDropDownView? = nil // "自動轉\n期利率"
    private var accountList:[AccountStruct]? = nil                  // 帳號列表
    private var responseExpireSaveList = [[String:Any]]()           // 電文response for "到期續存" "自動轉\n期利率"
    private var responseDepositList = [[String:Any]]()              // 電文response for "存款種類" "利率方式" "轉存期別" "目前利率"
    private var isExpireSaveType1 = true                            // "到期續存" 選擇的Button
    private var autoTransRateTypeIndex:Int? = nil                   // "自動轉\n期利率"的Index
    private var curDepositTypeIndex:Int? = nil                      // "存款種類"的Index
    private var curRateTypeIndex:Int? = nil                         // "利率方式"的Index
    private var curPeriodIndex:Int? = nil                           // "轉存期別"的Index
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_ThreeRowDropDownView) as? ThreeRowDropDownView
        topDropView?.setThreeRow(DepositCombinedToDeposit_Account_Title, "", DepositCombinedToDeposit_Currency_Title, "", DepositCombinedToDeposit_Balance_Title, "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        setShadowView(topView)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        
        depositTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        depositTypeDropView?.setOneRow(DepositCombinedToDeposit_DepositType_Title, "")
        depositTypeDropView?.frame = depositTypeView.frame
        depositTypeDropView?.frame.origin = .zero
        depositTypeDropView?.delegate = self
        depositTypeView.addSubview(depositTypeDropView!)
        
        rateTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        rateTypeDropView?.setOneRow(DepositCombinedToDeposit_Rate_Title, "")
        rateTypeDropView?.frame = rateTypeView.frame
        rateTypeDropView?.frame.origin = .zero
        rateTypeDropView?.delegate = self
        rateTypeView.addSubview(rateTypeDropView!)
        
        periodDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, "")
        periodDropView?.frame = periodView.frame
        periodDropView?.frame.origin = .zero
        periodDropView?.delegate = self
        periodView.addSubview(periodDropView!)
        
        autoTransRateTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        autoTransRateTypeDropView?.setOneRow(DepositCombinedToDeposit_AutoRateType_Title, "")
        autoTransRateTypeDropView?.frame = autoTransRateType.frame
        autoTransRateTypeDropView?.frame.origin = .zero
        autoTransRateTypeDropView?.delegate = self
        autoTransRateType.addSubview(autoTransRateTypeDropView!)
        
        setShadowView(middleView)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        
        setShadowView(bottomView)
        AddObserverToKeyBoard()
        setLoading(true)
        getTransactionID("03004", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickDepositBtn(_ sender: Any) {
        let btn = sender as? UIButton
        if btn == expireSaveType1tBtn {
            isExpireSaveType1 = true
            expireSaveType1tBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            expireSaveType2tBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
        else {
            isExpireSaveType1 = false
            expireSaveType2tBtn.setImage(UIImage(named: ImageName.RadioOn.rawValue), for: .normal)
            expireSaveType1tBtn.setImage(UIImage(named: ImageName.RadioOff.rawValue), for: .normal)
        }
        autoTransRateTypeIndex = nil
        autoTransRateTypeDropView?.setOneRow(DepositCombinedToDeposit_AutoRateType_Title, "")
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
        if InputIsCorrect() {
            setLoading(true)
            postRequest("ACCT/COMM0701", "COMM0701", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03004","Operate":"queryData"], true), AuthorizationManage.manage.getHttpHead(true))
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if sender == autoTransRateTypeDropView {
            var index:Int? = nil
            if isExpireSaveType1 {
                if responseExpireSaveList.count > 0 {
                    index = 0
                }
            }
            else {
                if responseExpireSaveList.count > 1 {
                    index = 1
                }
            }
            if index != nil {
                if let array = responseExpireSaveList[index!]["AIRTID"] as? [[String:Any]] {
                    let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
                    for info in array {
                        if let Name = info["Name"] as? String {
                            actSheet.addButton(withTitle: Name)
                        }
                    }
                    actSheet.tag = ViewTag.View_ExpireSaveActionSheet.rawValue
                    actSheet.show(in: view)
                }
            }
        }
        else {
            switch sender {
            case depositTypeDropView!: // "存款種類"
                let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
                for info in responseDepositList {
                    if let Name = info["Name"] as? String {
                        actSheet.addButton(withTitle: Name)
                    }
                }
                actSheet.tag = ViewTag.View_DepositTypeActionSheet.rawValue
                actSheet.show(in: view)
            
            case rateTypeDropView!: // "利率方式"
                if curDepositTypeIndex != nil {
                    if let Detail = responseDepositList[curDepositTypeIndex!]["Detail"] as? [[String:Any]] {
                        let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
                        for info in Detail {
                            if let IRTID = info["IRTID"] as? [String:String], let Name = IRTID["Name"] {
                                actSheet.addButton(withTitle: Name)
                            }
                        }
                        actSheet.tag = ViewTag.View_RateTypeActionSheet.rawValue
                        actSheet.show(in: view)
                    }
                }
                else {
                    showErrorMessage(ErrorMsg_Choose_DepositType, nil)
                }
                break
                
            case periodDropView!: // "轉存期別"
                var errorMessage = ""
                if curDepositTypeIndex == nil {
                    errorMessage.append("\(ErrorMsg_Choose_DepositType)\n")
                }
                if curRateTypeIndex == nil {
                    errorMessage.append("\(ErrorMsg_Choose_RateType)\n")
                }
                if errorMessage.isEmpty {
                    if let Detail = responseDepositList[curDepositTypeIndex!]["Detail"] as? [[String:Any]], let DetailRate = Detail[curRateTypeIndex!]["DetailRate"] as? [[String:String]] {
                        let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
                        for info in DetailRate {
                            if let PRDCD = info["PRDCD"] {
                                actSheet.addButton(withTitle: PRDCD)
                            }
                        }
                        actSheet.tag = ViewTag.View_TransPeriodActionSheet.rawValue
                        actSheet.show(in: view)
                    }
                }
                else {
                    showErrorMessage(errorMessage, nil)
                }
                break
                
            default: break
            }
            
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
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Deposit_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                
                if let info = AuthorizationManage.manage.GetLoginInfo() {
                    setLoading(true)
                    postRequest("TRAN/TRAN0402", "TRAN0402", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03004","Operate":"queryData","TransactionId":transactionId,"BR_CODE":info.bankCode], true), AuthorizationManage.manage.getHttpHead(true))
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "TRAN0402":
            if let data = response.object(forKey: "Data") as? [String:Any] {
                if let AUTTRN = data["AUTTRN"] as? [[String:Any]] {
                    responseExpireSaveList = AUTTRN
                    if responseExpireSaveList.count > 0, let name = responseExpireSaveList[0]["Name"] as? String {
                        expireSaveType1.text = name
                    }
                    else {
                        expireSaveType1.isHidden = true
                    }
                    if responseExpireSaveList.count > 1, let name = responseExpireSaveList[1]["Name"] as? String {
                        expireSaveType2.text = name
                    }
                    else {
                        expireSaveType2.isHidden = true
                    }
                }
                if let Result = data["Result"] as? [[String:Any]] {
                    responseDepositList = Result
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
        
        case "COMM0701":
            if let data = response.object(forKey: "Data") as? [String:Any], let status = data["CanTrans"] as? Int, status == Can_Transaction_Status {
                
            }
            else {
                
            }
            
        default: super.didRecvdResponse(description, response)
        }
    }
    
    // MARK: - Selector
    func clickCancelBtn(_ sender:Any) {
        transAmountTextfield?.text = ""
        transAmountTextfield?.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        transAmountTextfield?.resignFirstResponder()
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    topDropView?.setThreeRow(DepositCombinedToDeposit_Account_Title, info.accountNO, DepositCombinedToDeposit_Currency_Title, info.currency, DepositCombinedToDeposit_Balance_Title, String(info.balance))
                }
                
            case ViewTag.View_ExpireSaveActionSheet.rawValue:
                autoTransRateTypeIndex = buttonIndex-1
                autoTransRateTypeDropView?.setOneRow(DepositCombinedToDeposit_AutoRateType_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                
            case ViewTag.View_DepositTypeActionSheet.rawValue:
                curDepositTypeIndex = buttonIndex-1
                depositTypeDropView?.setOneRow(DepositCombinedToDeposit_DepositType_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                curRateTypeIndex = nil
                rateTypeDropView?.setOneRow(DepositCombinedToDeposit_Rate_Title, "")
                curPeriodIndex = nil
                periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, "")
                currentRateLabel.text = ""
                
            case ViewTag.View_RateTypeActionSheet.rawValue:
                curRateTypeIndex = buttonIndex-1
                rateTypeDropView?.setOneRow(DepositCombinedToDeposit_Rate_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                curPeriodIndex = nil
                periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, "")
                currentRateLabel.text = ""
                
            case ViewTag.View_TransPeriodActionSheet.rawValue:
                curPeriodIndex = buttonIndex-1
                periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                if let Detail = responseDepositList[curDepositTypeIndex!]["Detail"] as? [[String:Any]], let DetailRate = Detail[curRateTypeIndex!]["DetailRate"] as? [[String:String]], let INTRT = DetailRate[curPeriodIndex!]["INTRT"] {
                    currentRateLabel.text = INTRT
                }
                
            default: break
            }
        }
    }
    
    // MARK: - Private
    private func InputIsCorrect() -> Bool {
        var errorMessage = ""
        if accountList == nil {
            errorMessage.append("\(ErrorMsg_GetList_OutAccount)\n")
        }
        if (topDropView?.getContentByType(.First).isEmpty)! {
             errorMessage.append("\(ErrorMsg_Choose_DepositAccount)\n")
        }
        if curDepositTypeIndex == nil {
            errorMessage.append("\(ErrorMsg_Choose_DepositType)\n")
        }
        if curRateTypeIndex == nil {
            errorMessage.append("\(ErrorMsg_Choose_RateType)\n")
        }
        if curPeriodIndex == nil {
            errorMessage.append("\(ErrorMsg_Choose_TransPeriod)\n")
        }
        if autoTransRateTypeIndex == nil {
            errorMessage.append("\(ErrorMsg_Choose_AutoTransRate)\n")
        }
        if (transAmountTextfield.text?.isEmpty)! {
            errorMessage.append("\(ErrorMsg_Enter_TransSaveAmount)\n")
        }
        
        if errorMessage.isEmpty {
            return true
        }
        else {
            showErrorMessage(errorMessage, nil)
            return false
        }
    }
}
