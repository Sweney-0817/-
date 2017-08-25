//
//  LoanPrincipalInterestViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/7.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let LoanPrincipalInterest_PayLoan_Segue = "GoPayLoan"
let LoanPrincipalInterest_Detail_Segue = "GoDetail"
let LoanPrincipalInterest_Accout_Title = "放款帳號"

class LoanPrincipalInterestViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, OneRowDropDownViewDelegate, UIActionSheetDelegate {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var loanAmountLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var needPayAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private var topDropView:OneRowDropDownView? = nil
    private var accountList:[AccountStruct]? = nil                  // 帳號列表
    private var accountIndex:Int? = nil                             // 目前選擇放款帳號
    private var result:[String:Any]? = nil                          // 電文Response
    private var oneResult:[String:Any]? = nil                       // 電文Response
    private var curIndex:Int? = nil                                 // result["Result"] => Array, Array的Index
    private var memoStatus:String? = nil                            // 是否臨櫃結清作業
    private var inputAccount:String? = nil                          // 由「帳戶總覽」帶入的帳號
    
    // MARK: - Public
    func setInitial(_ account:String?)  {
        if accountList != nil && account != nil {
            for index in 0..<(accountList?.count)! {
                if let info = accountList?[index], info.accountNO == account! {
                    accountIndex = index
                    topDropView?.setOneRow(LoanPrincipalInterest_Accout_Title,info.accountNO)
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
        tableView.register(UINib(nibName: UIID.UIID_LoanPrincipalInterestCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_LoanPrincipalInterestCell.NibName()!)
        setShadowView(middleView!)
        
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.setOneRow(LoanPrincipalInterest_Accout_Title, Choose_Title)
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.delegate = self
        topView.addSubview(topDropView!)
        
        setLoading(true)
        getTransactionID("03006", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LoanPrincipalInterest_PayLoan_Segue {
            let controller = segue.destination as! PayLoanPrincipalInterestViewController
            controller.transactionId = transactionId
            controller.setList(oneResult, topDropView?.getContentByType(.First))
        }
        else {
            let controller = segue.destination as! LoanPrincipalInterestDetailViewController
            var list = [[String:String]]()
            list.append([Response_Key: "放款帳號", Response_Value:topDropView?.getContentByType(.First) ?? ""])
            if let ACTBAL = result?["ACTBAL"] as? String {
                list.append([Response_Key: "目前本金餘額", Response_Value:ACTBAL])
            }
            else {
                list.append([Response_Key: "目前本金餘額", Response_Value:""])
            }
            if let TPRIAMT = result?["TPRIAMT"] as? String {
                list.append([Response_Key: "應繳本金", Response_Value:TPRIAMT])
            }
            else {
                list.append([Response_Key: "應繳本金", Response_Value:""])
            }
            if let TINTAMT = result?["TINTAMT"] as? String {
                list.append([Response_Key: "應繳利息", Response_Value:TINTAMT])
            }
            else {
                list.append([Response_Key: "應繳利息", Response_Value:""])
            }
            if let TODIAMT = result?["TODIAMT"] as? String {
                list.append([Response_Key: "應繳諭期息", Response_Value:TODIAMT])
            }
            else {
                list.append([Response_Key: "應繳諭期息", Response_Value:""])
            }
            if let TDFAMT = result?["TDFAMT"] as? String {
                list.append([Response_Key: "應繳違約金", Response_Value:TDFAMT])
            }
            else {
                list.append([Response_Key: "應繳違約金", Response_Value:""])
            }
            if let SINTAMT = result?["SINTAMT"] as? String {
                list.append([Response_Key: "上次短收利息", Response_Value:SINTAMT])
            }
            else {
                list.append([Response_Key: "上次短收利息", Response_Value:""])
            }
            if let TOTAL = result?["TOTAL"] as? String {
                list.append([Response_Key: "應繳總額", Response_Value:TOTAL])
            }
            else {
                list.append([Response_Key: "應繳總額", Response_Value:""])
            }
            controller.setList(list)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = result?["Result"] as? [[String:String]] {
            return array.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_LoanPrincipalInterestCell.NibName()!, for: indexPath) as! LoanPrincipalInterestCell
        if let array = result?["Result"] as? [[String:String]] {
            if let Order = array[indexPath.row]["Order"], Order == "Y" {
                cell.payBtn.isHidden = false
            }
            else {
                cell.payBtn.isHidden = true
            }
            if let SDATE = array[indexPath.row]["SDATE"], let EDATE = array[indexPath.row]["EDATE"] {
                cell.calculatePeriodLabel.text = "\(SDATE) - \(EDATE)"
            }
            if let PRAMT = array[indexPath.row]["PRAMT"], let INT = array[indexPath.row]["INT"] {
                cell.principalInterestLabel.text = "\(PRAMT) / \(INT)"
            }
            if let PRAMT = array[indexPath.row]["DFAMT"] {
                cell.breachContractLabel.text = "\(PRAMT)"
            }
            if let DIAMT = array[indexPath.row]["DIAMT"] {
                cell.delayInterestLabel.text = "\(DIAMT)"
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let array = result?["Result"] as? [[String:String]], let Order = array[indexPath.row]["Order"], Order == "Y" {
            curIndex = indexPath.row
            if memoStatus != nil {
                var message = ""
                switch memoStatus! {
                case "1":
                    message = "請客戶親洽臨櫃辦理結清作業"
                    
                case "2":
                    message = "請客戶親洽臨櫃辦理還本作業"
                    
                default: break
                }
                if !message.isEmpty {
                    let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle:UIAlert_Cancel_Title)
                    alert.show()
                }
                else {
                    setLoading(true)
                    postRequest("TRAN/TRAN0601", "TRAN0601-1", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"getList","TransactionId":transactionId,"REFNO":topDropView?.getContentByType(.First) ?? "","PRDCNT":"1"], true), AuthorizationManage.manage.getHttpHead(true)) // PRDCNT:繳息期數=>0-為查回全部,1-為可繳交第一期
                }
            }
            else {
                showErrorMessage("Memo狀態不明", nil)
            }
        }
    }
    
    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        if accountList != nil {
            let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: UIActionSheet_Cancel_Title, destructiveButtonTitle: nil)
            for index in accountList! {
                actSheet.addButton(withTitle: index.accountNO)
            }
            actSheet.tag = ViewTag.View_AccountActionSheet.rawValue
            actSheet.show(in: view)
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
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["Result"] as? [[String:Any]] {
                for category in array {
                    if let type = category["ACTTYPE"] as? String, let result = category["AccountInfo"] as? [[String:Any]], type == Account_Loan_Type {
                        accountList = [AccountStruct]()
                        for actInfo in result {
                            if let actNO = actInfo["ACTNO"] as? String, let curcd = actInfo["CURCD"] as? String, let bal = actInfo["BAL"] as? Double, let ebkfg = actInfo["EBKFG"] as? Int, ebkfg == Account_EnableTrans {
                                accountList?.append(AccountStruct(accountNO: actNO, currency: curcd, balance: bal, status: ebkfg))
                            }
                        }
                    }
                }
                
                if inputAccount != nil {
                    for index in 0..<(accountList?.count)! {
                        if let info = accountList?[index], info.accountNO == inputAccount! {
                            accountIndex = index
                            topDropView?.setOneRow(LoanPrincipalInterest_Accout_Title,info.accountNO)
                            break
                        }
                    }
                    if accountIndex != nil {
                        setLoading(true)
                        postRequest("TRAN/TRAN0601", "TRAN0601-0", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"getList","TransactionId":transactionId,"REFNO":topDropView?.getContentByType(.First) ?? "","PRDCNT":"0"], true), AuthorizationManage.manage.getHttpHead(true)) // PRDCNT:繳息期數=>0-為查回全部,1-為可繳交第一期
                    }
                    inputAccount = nil
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            
        case "TRAN0601-0":
            if let data = response.object(forKey: "Data") as? [String:Any] {
                result = data
                if let APAMT = result?["APAMT"] as? String {
                    loanAmountLabel.text = APAMT
                }
                if let ACTBAL = result?["ACTBAL"] as? String {
                    currentAmountLabel.text = ACTBAL
                }
                if let TOTAL = result?["TOTAL"] as? String {
                    needPayAmountLabel.text = TOTAL
                }
                if let Memo = result?["Memo"] as? String {
                    memoStatus = Memo
                }
            }
            else {
                super.didRecvdResponse(description, response)
            }
            tableView.reloadData()
            
        case "TRAN0601-1":
            if let data = response.object(forKey: "Data") as? [String:Any] {
                oneResult = data
                performSegue(withIdentifier: LoanPrincipalInterest_PayLoan_Segue, sender: nil)
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
            case ViewTag.View_AccountActionSheet.rawValue:
                accountIndex = buttonIndex-1
                topDropView?.setOneRow(LoanPrincipalInterest_Accout_Title, actionSheet.buttonTitle(at: buttonIndex) ?? "")
                setLoading(true)
                postRequest("TRAN/TRAN0601", "TRAN0601-0", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03006","Operate":"getList","TransactionId":transactionId,"REFNO":actionSheet.buttonTitle(at: buttonIndex) ?? "","PRDCNT":"0"], true), AuthorizationManage.manage.getHttpHead(true)) // PRDCNT:繳息期數=>0-為查回全部,1-為可繳交第一期
                
            default: break
            }
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickMoreButton(_ sender: Any) {
        if accountIndex == nil {
            showErrorMessage(ErrorMsg_Choose_OutAccount, nil)
        }
        else {
            performSegue(withIdentifier: LoanPrincipalInterest_Detail_Segue, sender: nil)
        }
    }
}
