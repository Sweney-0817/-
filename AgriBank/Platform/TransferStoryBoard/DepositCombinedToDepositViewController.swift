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
let DepositCombinedToDeposit_ExpireSaveType1 = "是，本金續存"
let DepositCombinedToDeposit_ExpireSaveType2 = "不續存"
let DepositCombinedToDeposit_Min_Amount:Int = 10000

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
        topDropView?.setThreeRow(DepositCombinedToDeposit_Account_Title, Choose_Title, DepositCombinedToDeposit_Currency_Title, "", DepositCombinedToDeposit_Balance_Title, "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        setShadowView(topView)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        
        depositTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        depositTypeDropView?.setOneRow(DepositCombinedToDeposit_DepositType_Title, Choose_Title)
        depositTypeDropView?.frame = depositTypeView.frame
        depositTypeDropView?.frame.origin = .zero
        depositTypeDropView?.delegate = self
        depositTypeView.addSubview(depositTypeDropView!)
        
        rateTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        rateTypeDropView?.setOneRow(DepositCombinedToDeposit_Rate_Title, Choose_Title)
        rateTypeDropView?.frame = rateTypeView.frame
        rateTypeDropView?.frame.origin = .zero
        rateTypeDropView?.delegate = self
        rateTypeView.addSubview(rateTypeDropView!)
        
        periodDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, Choose_Title)
        periodDropView?.frame = periodView.frame
        periodDropView?.frame.origin = .zero
        periodDropView?.delegate = self
        periodView.addSubview(periodDropView!)
        
        autoTransRateTypeDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        autoTransRateTypeDropView?.setOneRow(DepositCombinedToDeposit_AutoRateType_Title, Choose_Title)
        autoTransRateTypeDropView?.frame = autoTransRateType.frame
        autoTransRateTypeDropView?.frame.origin = .zero
        autoTransRateTypeDropView?.delegate = self
        autoTransRateType.addSubview(autoTransRateTypeDropView!)
        
        setShadowView(middleView)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        
        setShadowView(bottomView)
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        getTransactionID("03004", TransactionID_Description)
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
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Deposit_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? String, let ebkfg = actInfo["EBKFG"] as? String {
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
                super.didResponse(description, response)
            }
            
        case "TRAN0402":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any] {
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
                super.didResponse(description, response)
            }
            
        case "COMM0701":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]], let status = array.first?["CanTrans"] as? String, status == Can_Transaction_Status, let date = array.first?["CurrentDate"] as? String {

                let TACTNO = topDropView?.getContentByType(.First) ?? ""
                let TYPE = responseDepositList[curDepositTypeIndex!]["Type"] ?? ""
                let PRDCD = periodDropView?.getContentByType(.First) ?? ""
                var IRTID = ""
                if let Detail = responseDepositList[curDepositTypeIndex!]["Detail"] as? [[String:Any]], let irtid = Detail[curRateTypeIndex!]["IRTID"] as? [String:String], let Value = irtid["Value"] {
                    IRTID = Value
                }
                var AUTTRN = ""
                var AIRTID = ""
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
                    if let Value = responseExpireSaveList[index!]["Value"] as? String {
                        AUTTRN = Value
                    }
                    if let array = responseExpireSaveList[index!]["AIRTID"] as? [[String:Any]], let Value = array[autoTransRateTypeIndex!]["Value"] as? String {
                        AIRTID = Value
                    }
                }
                let TXAMT = transAmountTextfield.text ?? ""
                let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0401", strSessionDescription: "TRAN0401", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03004","Operate":"commitTxn","TransactionId":transactionId,"TACTNO":TACTNO,"TYPE":TYPE,"PRDCD":PRDCD,"IRTID":IRTID,"AUTTRN":AUTTRN,"AIRTID":AIRTID,"TXAMT":TXAMT,"BTXDAY":date.replacingOccurrences(of: "/", with: "")], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
                
                var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
                dataConfirm.list?.append([Response_Key: "綜合存款帳號", Response_Value:TACTNO])
                dataConfirm.list?.append([Response_Key: "餘額", Response_Value:topDropView?.getContentByType(.Third).separatorThousand() ?? ""])
                dataConfirm.list?.append([Response_Key: "存款種類", Response_Value:depositTypeDropView?.getContentByType(.First) ?? ""])
                dataConfirm.list?.append([Response_Key: "轉存期別", Response_Value:periodDropView?.getContentByType(.First) ?? ""])
                dataConfirm.list?.append([Response_Key: "利率方式", Response_Value:rateTypeDropView?.getContentByType(.First) ?? ""])
                dataConfirm.list?.append([Response_Key: "目前利率", Response_Value:currentRateLabel.text ?? ""])
                dataConfirm.list?.append([Response_Key: "轉存金額", Response_Value:transAmountTextfield.text?.separatorThousand() ?? ""])
                dataConfirm.list?.append([Response_Key: "到期續存", Response_Value:isExpireSaveType1 ? DepositCombinedToDeposit_ExpireSaveType1 : DepositCombinedToDeposit_ExpireSaveType2])
                dataConfirm.list?.append([Response_Key: "自動轉期利率", Response_Value:autoTransRateTypeDropView?.getContentByType(.First) ?? ""])
                enterConfirmResultController(true, dataConfirm, true)
            }
            else {
                showErrorMessage(nil, ErrorMsg_IsNot_TransTime)
            }
        
        default: super.didResponse(description, response)
        }
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
        autoTransRateTypeDropView?.setOneRow(DepositCombinedToDeposit_AutoRateType_Title, Choose_Title)
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
        if inputIsCorrect() {
            setLoading(true)
            postRequest("COMM/COMM0701", "COMM0701", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03004","Operate":"queryData"], false), AuthorizationManage.manage.getHttpHead(false))
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
                    let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                    for info in array {
                        if let Name = info["Name"] as? String {
                            actSheet.addButton(withTitle: Name)
                        }
                    }
                    actSheet.tag = ViewTag.View_ExpireSaveActionSheet.rawValue
                    actSheet.show(in: view)
                }
            }
            else {
                showErrorMessage(nil, "\(Get_Null_Title)\(autoTransRateTypeDropView?.m_lbFirstRowTitle.text ?? "")")
            }
        }
        else {
            switch sender {
            case depositTypeDropView!: // "存款種類"
                let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
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
                        let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
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
                    showErrorMessage(nil, "\(Choose_Title)\(depositTypeDropView?.m_lbFirstRowTitle.text ?? "")")
                }
                break
                
            case periodDropView!: // "轉存期別"
                if curDepositTypeIndex == nil {
                    showErrorMessage(nil, "\(Choose_Title)\(depositTypeDropView?.m_lbFirstRowTitle.text ?? "")")
                    break
                }
                if curRateTypeIndex == nil {
                    showErrorMessage(nil, "\(Choose_Title)\(rateTypeDropView?.m_lbFirstRowTitle.text ?? "")")
                    break
                }
                
                if let Detail = responseDepositList[curDepositTypeIndex!]["Detail"] as? [[String:Any]], let DetailRate = Detail[curRateTypeIndex!]["DetailRate"] as? [[String:String]] {
                    let actSheet = UIActionSheet(title: Choose_Title, delegate: self, cancelButtonTitle: Cancel_Title, destructiveButtonTitle: nil)
                    for info in DetailRate {
                        if let PRDCD = info["PRDCD"] {
                            actSheet.addButton(withTitle: PRDCD)
                        }
                    }
                    actSheet.tag = ViewTag.View_TransPeriodActionSheet.rawValue
                    actSheet.show(in: view)
                }
                break
                
            default: break
            }
            
        }
    }

    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            switch actionSheet.tag {
            case ViewTag.View_AccountActionSheet.rawValue:
                if let info = accountList?[buttonIndex-1] {
                    topDropView?.setThreeRow(DepositCombinedToDeposit_Account_Title, info.accountNO, DepositCombinedToDeposit_Currency_Title, (info.currency == Currency_TWD ? Currency_TWD_Title:info.currency), DepositCombinedToDeposit_Balance_Title, String(info.balance).separatorThousand())
                }
                
            case ViewTag.View_ExpireSaveActionSheet.rawValue:
                autoTransRateTypeIndex = buttonIndex-1
                autoTransRateTypeDropView?.setOneRow(DepositCombinedToDeposit_AutoRateType_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                
            case ViewTag.View_DepositTypeActionSheet.rawValue:
                curDepositTypeIndex = buttonIndex-1
                depositTypeDropView?.setOneRow(DepositCombinedToDeposit_DepositType_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                curRateTypeIndex = nil
                rateTypeDropView?.setOneRow(DepositCombinedToDeposit_Rate_Title, Choose_Title)
                curPeriodIndex = nil
                periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, Choose_Title)
                currentRateLabel.text = ""
                
            case ViewTag.View_RateTypeActionSheet.rawValue:
                curRateTypeIndex = buttonIndex-1
                rateTypeDropView?.setOneRow(DepositCombinedToDeposit_Rate_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                curPeriodIndex = nil
                periodDropView?.setOneRow(DepositCombinedToDeposit_Period_Title, Choose_Title)
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
    private func inputIsCorrect() -> Bool {
        if topDropView?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if curDepositTypeIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(depositTypeDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if curRateTypeIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(rateTypeDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if curPeriodIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(periodDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if autoTransRateTypeIndex == nil {
            showErrorMessage(nil, "\(Choose_Title)\(autoTransRateTypeDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (transAmountTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(transAmountTextfield.placeholder ?? "")")
            return false
        }
        if let amount = Int(transAmountTextfield.text!) {
            if amount < DepositCombinedToDeposit_Min_Amount {
                showErrorMessage(nil, ErrorMsg_DepositCombinedToDeposit_MinAmount)
                return false
            }
        }
        else {
            showErrorMessage(nil, ErrorMsg_Illegal_Character)
            return false
        }
        
        return true
    }
}
